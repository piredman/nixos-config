"""Read-only capacity check matching the pinned systemd-boot installer's file layout."""

import argparse
import json
import os
from pathlib import Path
import re
import sys


MIB = 1024 * 1024
NIXOS_DIR = Path("EFI/nixos")
LOADER_ALLOWANCE = 16 * MIB


def generation_paths(profiles, limit):
    """Match systemd-boot's newest N generations, independently for each profile."""
    def latest(directory, name):
        pattern = re.compile(rf"{re.escape(name)}-(\d+)-link")
        generations = []
        for path in directory.iterdir():
            match = pattern.fullmatch(path.name)
            if match:
                generations.append((int(match[1]), path))
        return [path for _, path in sorted(generations)[-limit:]]

    selected = latest(profiles, "system")
    named_profiles = profiles / "system-profiles"
    if named_profiles.is_dir():
        for profile in named_profiles.iterdir():
            if not profile.name.endswith("-link"):
                selected.extend(latest(named_profiles, profile.name))
    if not selected:
        raise ValueError("no system generations found; refusing to guess the boot payload")
    return selected


def boot_path(source, store):
    source = Path(source).resolve(strict=True)
    store_subdir = source.relative_to(store).parts[0]
    filename = source.name if source.name == store_subdir else f"{store_subdir}-{source.name}"
    return NIXOS_DIR / f"{filename}.efi"


def boot_payload(generations, store=Path("/nix/store"), incoming=None):
    """Deduplicate by destination, including specialisations and device trees."""
    payload = {}
    incoming = incoming.resolve(strict=True) if incoming is not None else None
    includes_default = incoming is None

    def add_spec(document):
        nonlocal includes_default
        spec = document["org.nixos.bootspec.v1"]
        if incoming is not None and spec.get("toplevel"):
            includes_default |= Path(spec["toplevel"]).resolve(strict=True) == incoming
        # Secret appenders are arbitrary programs, so their output cannot be sized
        # safely without running them. Fail closed rather than under-budgeting.
        if spec.get("initrdSecrets") is not None:
            raise ValueError("initrd secret appenders require a separate boot-space budget")
        if document.get("org.nixos.extra-initrd.v1", {}).get("paths"):
            raise ValueError("extra initrd paths require a separate boot-space budget")
        sources = [spec["kernel"], spec["initrd"]]
        devicetree = document.get("org.nixos.systemd-boot", {}).get("devicetree")
        if devicetree:
            sources.append(devicetree)
        for source in sources:
            payload[boot_path(source, store)] = Path(source).stat().st_size
        for specialisation in document.get("org.nixos.specialisation.v1", {}).values():
            add_spec(specialisation)

    for generation in generations:
        includes_default |= generation.resolve(strict=True) == incoming
        with (generation / "boot.json").open() as stream:
            add_spec(json.load(stream))
    if not includes_default:
        raise ValueError(
            "requested boot default is outside the retained generations; "
            "refusing to replace it with a different default"
        )
    return payload


def round_up(size, block_size):
    return ((size + block_size - 1) // block_size) * block_size


def capacity_after_install(payload, existing, available, block_size, extra_files=None):
    """Credit only regular files that the installer actually removes before copying."""
    extra_files = extra_files or {}
    keep = payload.keys() | extra_files.keys()
    reclaimable = sum(size for path, size in existing.items() if path not in keep)
    missing = sum(
        round_up(size, block_size)
        for path, size in payload.items()
        if path not in existing
    )
    # extraFiles are reinstalled, not shared like kernels/initrds. Conservatively
    # reserve their full size, without crediting their old copies or marker files.
    missing += sum(round_up(size, block_size) for size in extra_files.values())
    return available + reclaimable - missing


def check_space(boot, esp, profiles, limit, reserve, extra_files, incoming=None):
    for mount in {boot, esp}:
        if not os.path.ismount(mount):
            raise ValueError(f"{mount} is not mounted; refusing to check the underlying filesystem")
        if os.statvfs(mount).f_flag & os.ST_RDONLY:
            raise ValueError(f"{mount} is mounted read-only")

    # bootctl updates the EFI loader before the installer's payload cleanup.
    # Do not count reclaimable kernel files as space available for that step.
    esp_stats = os.statvfs(esp)
    if esp_stats.f_bavail * esp_stats.f_frsize < LOADER_ALLOWANCE:
        raise ValueError(f"{esp} needs at least 16 MiB free before updating the EFI loader")

    payload = boot_payload(generation_paths(profiles, limit), incoming=incoming)
    if payload.keys() & extra_files.keys():
        raise ValueError("extraFiles overlap generated kernel/initrd destinations")

    existing = {}
    directory = boot / NIXOS_DIR
    if directory.is_dir():
        for path in directory.iterdir():
            if path.is_file() and not path.is_symlink():
                stats = path.stat()
                # A hard link outside the managed directory would prevent its
                # blocks being freed. Do not credit such files as reclaimable.
                existing[NIXOS_DIR / path.name] = stats.st_blocks * 512 if stats.st_nlink == 1 else 0

    stats = os.statvfs(boot)
    block_size = stats.f_frsize or stats.f_bsize
    available = stats.f_bavail * block_size
    remaining = capacity_after_install(payload, existing, available, block_size, extra_files)
    # Allow for loader updates and entry/directory metadata as well as payloads.
    remaining -= LOADER_ALLOWANCE
    print(
        f"Boot space: {remaining / MIB:.1f} MiB budgeted free after cleanup/copy and overhead; "
        f"{reserve / MIB:.0f} MiB reserve required (limit {limit} per profile)."
    )
    if remaining < reserve:
        raise ValueError(
            "retained boot files would leave insufficient update headroom; "
            "no additional backups will be deleted automatically"
        )


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--incoming", type=Path, required=True)
    parser.add_argument("--boot", type=Path, required=True)
    parser.add_argument("--esp", type=Path, required=True)
    parser.add_argument("--profiles", type=Path, default=Path("/nix/var/nix/profiles"))
    parser.add_argument("--limit", type=int, required=True)
    parser.add_argument("--reserve-mib", type=int, default=128)
    parser.add_argument("--extra-files", type=Path, required=True)
    args = parser.parse_args()
    try:
        if args.limit < 1 or args.reserve_mib < 1:
            raise ValueError("generation limit and reserve must be positive")
        with args.extra_files.open() as stream:
            sources = json.load(stream)
        extra_files = {}
        for destination, source in sources.items():
            path = Path(destination)
            if path.is_absolute() or ".." in path.parts:
                raise ValueError(f"invalid extraFiles destination: {destination}")
            extra_files[path] = Path(source).stat().st_size
        check_space(
            args.boot, args.esp, args.profiles, args.limit,
            args.reserve_mib * MIB, extra_files, args.incoming,
        )
    except (OSError, ValueError, KeyError, TypeError) as error:
        print(f"Boot-space check refused installation: {error}", file=sys.stderr)
        print("This check did not change any boot files.", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())

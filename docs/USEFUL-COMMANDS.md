# Useful Commands

## Build and Test Configuration

```bash
# Test configuration before making it the default
# Changes apply immediately but won't persist after reboot.
sudo nixos-rebuild test --flake .#terra
```

```bash
# Build the configuration to check for errors
sudo nixos-rebuild build --flake .#terra
```

## Rollback and Recovery

```bash
# See all previous system configurations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
```

```bash
# Rollback to the last working configuration
sudo nixos-rebuild switch --rollback
```

## Checking Status

```bash
# See what versions you're using
nix flake metadata
```

```bash
# System generation (includes home-manager)
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | tail -1
```

```bash
# Check for Broken Links
nix-store --verify --check-contents
```

## Multi-Host Management

```bash
# Build configuration on one machine, deploy to another
nixos-rebuild switch --flake .#hostname --target-host user@remote-host
```

## Troubleshooting

```bash
# The `--show-trace` flag shows more detailed error information.
sudo nixos-rebuild switch --flake .#terra --show-trace
```

```bash
# If system is broken after rebuild:
sudo nixos-rebuild switch --rollback
```

```bash
# View system logs:
journalctl -xe
```

```bash
# View build logs
nix log /nix/store/xxx-nixos-system-xxx
```

## Generations and Cleanup

**Policy:** keep 3 total generations: current plus 2 rollback generations. The
single retention setting is `configurationLimit = 3` in
`hosts/_modules/core/core.nix`. The active system publishes it in
`/etc/nixos-generation-retention`, which `nprune` reads for its default. Before
the first rebuild installs that file, the updated shell helper defaults to 3.

**Capacity protection:** `hosts/_modules/core/boot-space.nix` installs a read-only
`system.preSwitchChecks` hook for `switch` and `boot`, including `nrh` and `nrb`.
After the build, before bootloader installation, it budgets the newest 3 generations
of each system profile, sharing identical kernel/initrd files and accounting for
specialisations, device trees, extra files, filesystem allocation and other disk use.
It credits only managed files the pinned systemd-boot installer removes **before**
copying new files. It refuses installation unless at least **128 MiB** would remain;
the budget includes an additional 16 MiB allowance for loader/entry overhead.
It never reduces the backup count to make an update fit. Unmounted/read-only boot
partitions, missing artifacts and unsupported secret appenders/extra initrd paths
also fail closed. It refuses a boot default outside the retained generations rather
than silently replacing it (relevant to deeper rollbacks). The ESP also needs
16 MiB free **before** cleanup, since `bootctl` updates the EFI loader first.

The guard does not write boot files. A rejected rebuild may have already created
a system profile generation, but leaves the running system and existing boot menu
unchanged by the guard. Inspect the error rather than forcing the check off.
`nrt` does not install boot files or test a new initrd, so it skips this capacity check.

**Cleanup:** after a successful switch, `nrh` runs `nixos-prune` automatically:

1. Refuses to prune if the running configuration differs from the system profile
   (for example after `nrb` before reboot, or during an `nrt` test). This prevents
   resyncing the boot menu with the wrong default configuration.
2. Keeps 3 system profile generations via `nix-env --delete-generations +3`.
3. Resyncs boot entries using the system profile's `switch-to-configuration boot`.
4. Prunes the standalone home-manager profile if present and the default user profile.
5. Runs `sudo nix-collect-garbage` **without** generation-deleting flags.

Errors stop cleanup; a bootloader sync failure prevents the subsequent store GC.
Failed rebuilds skip pruning entirely. Cleanup failures after a successful rebuild
are reported separately. Weekly GC also runs without age-based generation deletion,
so it cannot remove backups retained by this count policy.

`nprune <n>` overrides profile retention, not the boot-menu limit. Keeping more
profile history does **not** make more than 3 generations available in the boot menu.
Once generations have been deleted, increasing the count cannot restore them.
Count-based pruning keeps the current generation and may retain additional newer
generations after a rollback; it does not force-delete those newer generations.

**Expected space use:** occupancy is driven by distinct kernel/initrd file paths,
not menu-entry count or kernel version alone. Removing a generation that shares all
its boot files can free almost nothing. At terra's measured sizes (~14 MiB kernel +
~195 MiB initrd), three distinct sets use ~624 MiB of its 1 GiB ESP. Around 61% used
is therefore a reasonable plateau, not evidence of failed cleanup. Five distinct
sets would not fit. Larger future payloads can still exceed the budget; retaining
five bootable generations reliably requires more boot storage. NVIDIA early loading
and initrd contents are unchanged by this retention policy.

For the first manual rebuild, load the edited helpers before using `nrh` so an old
shell does not run the previous retention code:

```bash
source ~/.dotfiles/home/_modules/core/shell/_functions.zsh
# Build/test as usual, then run nrh manually when ready.
```

To inspect state:

```bash
nix-env --list-generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
lsblk -o NAME,MOUNTPOINT,SIZE,FSUSED,FSAVAIL,FSUSE%
sudo du -ah /boot/EFI/nixos | sort -h
```

Read-only capacity and mocked shell tests (no Nix, sudo or real pruning involved):

```bash
python3 -B -m unittest discover -s lib -p '*_test.py' -v
```

Emergency nuke (kills ALL history — use NixOS generations instead whenever possible):

```bash
sudo nix-collect-garbage -d
```

`nix-store --optimize` is unnecessary here — `auto-optimise-store = true` in
`hosts/_modules/core/core.nix` dedupes store paths as they're written.

## See Also

- [Bootstrap Guide](BOOTSTRAP.md) - Initial setup

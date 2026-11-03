import contextlib
import importlib.util
import io
import json
from pathlib import Path
from types import SimpleNamespace
import tempfile
import unittest
from unittest.mock import patch


spec = importlib.util.spec_from_file_location(
    "boot_space_check", Path(__file__).with_name("boot-space-check.py")
)
checker = importlib.util.module_from_spec(spec)
spec.loader.exec_module(checker)
MIB = checker.MIB


class BootPayloadTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.store = self.root / "store"
        self.profiles = self.root / "profiles"
        self.store.mkdir()
        self.profiles.mkdir()

    def artifact(self, name, size):
        path = self.store / name
        path.parent.mkdir(parents=True, exist_ok=True)
        with path.open("wb") as stream:
            stream.truncate(size)
        return str(path)

    def document(self, kernel, initrd):
        return {"org.nixos.bootspec.v1": {"kernel": kernel, "initrd": initrd}}

    def generation(self, number, document):
        target = self.store / f"system-{number}"
        target.mkdir()
        (target / "boot.json").write_text(json.dumps(document))
        link = self.profiles / f"system-{number}-link"
        link.symlink_to(target)
        return link

    def test_numeric_selection_includes_only_newest_three(self):
        for number in (8, 9, 10, 11, 12):
            self.generation(number, {})
        (self.profiles / "system").symlink_to(self.profiles / "system-12-link")
        selected = checker.generation_paths(self.profiles, 3)
        self.assertEqual([p.name for p in selected], [f"system-{n}-link" for n in (10, 11, 12)])

    def test_named_profiles_are_also_budgeted(self):
        target = self.generation(255, {}).resolve()
        named = self.profiles / "system-profiles"
        named.mkdir()
        for number in (1, 2, 3, 4):
            (named / f"rescue-{number}-link").symlink_to(target)
        (named / "rescue").symlink_to(named / "rescue-4-link")
        selected = checker.generation_paths(self.profiles, 3)
        self.assertEqual(len(selected), 4)
        self.assertNotIn(named / "rescue-1-link", selected)

    def test_shared_kernel_and_initrd_are_counted_once(self):
        kernel = self.artifact("kernel-hash-linux-7.2.9/bzImage", 14 * MIB)
        initrd = self.artifact("initrd-hash-linux-7.2.9/initrd", 195 * MIB)
        generations = [self.generation(n, self.document(kernel, initrd)) for n in (252, 253)]
        payload = checker.boot_payload(generations, self.store)
        self.assertEqual(sum(payload.values()), 209 * MIB)
        self.assertEqual(len(payload), 2)

    def test_different_initrds_for_same_kernel_are_not_deduplicated(self):
        kernel = self.artifact("kernel-hash-linux-7.2.9/bzImage", 14 * MIB)
        generations = []
        for number in (252, 253):
            initrd = self.artifact(f"initrd-{number}-linux-7.2.9/initrd", 195 * MIB)
            generations.append(self.generation(number, self.document(kernel, initrd)))
        self.assertEqual(len(checker.boot_payload(generations, self.store)), 3)

    def test_specialisations_and_devicetree_are_included(self):
        kernel = self.artifact("kernel/bzImage", 100)
        initrd = self.artifact("initrd/initrd", 200)
        special_initrd = self.artifact("special/initrd", 300)
        tree = self.artifact("device-tree/board.dtb", 400)
        document = self.document(kernel, initrd)
        document["org.nixos.systemd-boot"] = {"devicetree": tree}
        document["org.nixos.specialisation.v1"] = {
            "special": self.document(kernel, special_initrd)
        }
        generation = self.generation(255, document)
        payload = checker.boot_payload([generation], self.store)
        self.assertEqual(sum(payload.values()), 1000)

    def test_requested_default_must_be_retained(self):
        kernel = self.artifact("kernel/bzImage", 100)
        initrd = self.artifact("initrd/initrd", 200)
        old = self.generation(251, self.document(kernel, initrd))
        new = self.generation(255, self.document(kernel, initrd))
        checker.boot_payload([new], self.store, incoming=new)
        with self.assertRaisesRegex(ValueError, "default is outside"):
            checker.boot_payload([new], self.store, incoming=old)

    def test_specialisation_can_be_the_requested_default(self):
        kernel = self.artifact("kernel/bzImage", 100)
        initrd = self.artifact("initrd/initrd", 200)
        special = self.store / "special-toplevel"
        special.mkdir()
        document = self.document(kernel, initrd)
        special_document = self.document(kernel, initrd)
        special_document["org.nixos.bootspec.v1"]["toplevel"] = str(special)
        document["org.nixos.specialisation.v1"] = {"special": special_document}
        generation = self.generation(255, document)
        checker.boot_payload([generation], self.store, incoming=special)

    def test_secret_appender_fails_closed(self):
        document = self.document("unused", "unused")
        document["org.nixos.bootspec.v1"]["initrdSecrets"] = "/some/appender"
        generation = self.generation(255, document)
        with self.assertRaisesRegex(ValueError, "secret appenders"):
            checker.boot_payload([generation], self.store)

    def test_extra_initrd_fails_closed(self):
        document = self.document("unused", "unused")
        document["org.nixos.extra-initrd.v1"] = {"paths": ["extra.efi"]}
        generation = self.generation(255, document)
        with self.assertRaisesRegex(ValueError, "extra initrd"):
            checker.boot_payload([generation], self.store)

    def test_missing_artifact_or_bootspec_is_not_silently_skipped(self):
        generation = self.generation(255, self.document("/missing/kernel", "/missing/initrd"))
        with self.assertRaises(FileNotFoundError):
            checker.boot_payload([generation], self.store)
        (generation / "boot.json").unlink()
        with self.assertRaises(FileNotFoundError):
            checker.boot_payload([generation], self.store)

    def test_no_generations_fails_closed(self):
        with self.assertRaisesRegex(ValueError, "no system generations"):
            checker.generation_paths(self.profiles, 3)


class CapacityTests(unittest.TestCase):
    def test_sixty_percent_is_not_itself_a_failure(self):
        payload = {Path(f"EFI/nixos/{n}"): 208 * MIB for n in range(3)}
        remaining = checker.capacity_after_install(payload, payload, 398 * MIB, 4096)
        self.assertEqual(remaining, 398 * MIB)

    def test_replacement_credits_cleanup_before_new_copy(self):
        existing = {Path(f"EFI/nixos/{n}"): 208 * MIB for n in range(3)}
        payload = {Path(f"EFI/nixos/{n}"): 208 * MIB for n in range(1, 4)}
        remaining = checker.capacity_after_install(payload, existing, 398 * MIB, 4096)
        self.assertEqual(remaining, 398 * MIB)

    def test_five_distinct_sets_exceed_one_gib(self):
        payload = {Path(f"EFI/nixos/{n}"): 208 * MIB for n in range(5)}
        self.assertLess(checker.capacity_after_install(payload, {}, 1024 * MIB, 4096), 0)

    def test_foreign_files_are_not_credited_as_reclaimable(self):
        # Only the managed directory is supplied as `existing`; a large Windows
        # loader or other partition contents have already reduced available space.
        payload = {Path("EFI/nixos/new"): 208 * MIB}
        remaining = checker.capacity_after_install(payload, {}, 300 * MIB, 4096)
        self.assertLess(remaining, 128 * MIB)

    def test_cluster_rounding_and_full_extra_file_copy(self):
        payload = {Path("EFI/nixos/new"): 4097}
        extra = {Path("EFI/custom.efi"): 1}
        self.assertEqual(checker.capacity_after_install(payload, {}, 16384, 4096, extra), 4096)

    def test_low_space_main_returns_failure_without_changing_files(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            boot = root / "boot"
            boot.mkdir()
            sentinel = boot / "known-good.efi"
            sentinel.write_bytes(b"preserve this fallback")
            extra_files = root / "extra.json"
            extra_files.write_text("{}")
            stats = SimpleNamespace(f_frsize=4096, f_bsize=4096, f_flag=0, f_bavail=8192)
            args = [
                "boot-space-check.py", "--boot", str(boot), "--esp", str(boot),
                "--incoming", str(root), "--limit", "3", "--extra-files", str(extra_files),
            ]
            with (
                patch.object(checker.sys, "argv", args),
                patch.object(checker.os.path, "ismount", return_value=True),
                patch.object(checker.os, "statvfs", return_value=stats),
                patch.object(checker, "generation_paths", return_value=[]),
                patch.object(checker, "boot_payload", return_value={Path("EFI/nixos/new"): 208 * MIB}),
                contextlib.redirect_stdout(io.StringIO()),
                contextlib.redirect_stderr(io.StringIO()) as errors,
            ):
                self.assertEqual(checker.main(), 1)
            self.assertIn("refused installation", errors.getvalue())
            self.assertEqual(sentinel.read_bytes(), b"preserve this fallback")
            self.assertEqual(list(boot.iterdir()), [sentinel])

    def test_unmounted_or_readonly_boot_is_rejected(self):
        with patch.object(checker.os.path, "ismount", return_value=False):
            with self.assertRaisesRegex(ValueError, "not mounted"):
                checker.check_space(Path("/boot"), Path("/boot"), Path("/profiles"), 3, MIB, {})
        stats = SimpleNamespace(f_flag=checker.os.ST_RDONLY)
        with (
            patch.object(checker.os.path, "ismount", return_value=True),
            patch.object(checker.os, "statvfs", return_value=stats),
        ):
            with self.assertRaisesRegex(ValueError, "read-only"):
                checker.check_space(Path("/boot"), Path("/boot"), Path("/profiles"), 3, MIB, {})

    def test_loader_update_needs_space_before_payload_cleanup(self):
        stats = SimpleNamespace(f_flag=0, f_bavail=256, f_frsize=4096)
        with (
            patch.object(checker.os.path, "ismount", return_value=True),
            patch.object(checker.os, "statvfs", return_value=stats),
            patch.object(checker, "boot_payload") as payload,
        ):
            with self.assertRaisesRegex(ValueError, "before updating the EFI loader"):
                checker.check_space(Path("/boot"), Path("/boot"), Path("/profiles"), 3, MIB, {})
            payload.assert_not_called()


if __name__ == "__main__":
    unittest.main()

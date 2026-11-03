"""Exercise the real zsh functions with all privileged/Nix operations mocked."""

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


FUNCTIONS = Path(__file__).resolve().parents[1] / "home/_modules/core/shell/_functions.zsh"
MOCKS = r'''
source "$FUNCTIONS"
nixos-generation-limit() { print -r -- 3 }
readlink() {
    if [[ "$FAIL_STAGE" == pending && "$2" == /nix/var/nix/profiles/system ]]; then
        print -r -- /pending-system
    else
        print -r -- /same-system
    fi
}
sudo() {
    print -r -- "sudo $*" >> "$CALLS"
    case "$FAIL_STAGE:$1" in
        system:nix-env|boot:/nix/var/nix/profiles/system/bin/switch-to-configuration|gc:nix-collect-garbage|rebuild:nixos-rebuild)
            return 1 ;;
    esac
    return 0
}
nix-env() {
    print -r -- "nix-env $*" >> "$CALLS"
    [[ "$FAIL_STAGE" != user ]]
}
lsblk() { print -r -- "lsblk $*" >> "$CALLS" }
'''


@unittest.skipUnless(shutil.which("zsh"), "zsh is required for shell function tests")
class PruneTests(unittest.TestCase):
    def run_prune(self, *arguments, fail_stage="", home_manager=True, body='nixos-prune "$@"'):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            if home_manager:
                (root / ".local/state/nix/profiles/home-manager").mkdir(parents=True)
            calls = root / "calls"
            result = subprocess.run(
                ["zsh", "-f", "-s", "--", *arguments],
                input=MOCKS + "\n" + body + "\n", text=True, capture_output=True,
                env={**os.environ, "HOME": str(root), "FUNCTIONS": str(FUNCTIONS),
                     "CALLS": str(calls), "FAIL_STAGE": fail_stage},
            )
            return result, calls.read_text().splitlines() if calls.exists() else []

    def test_default_keeps_three_and_boot_sync_precedes_store_gc(self):
        result, calls = self.run_prune()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("--delete-generations +3", calls[0])
        self.assertIn("switch-to-configuration boot", calls[1])
        self.assertEqual(calls[-2], "sudo nix-collect-garbage")

    def test_invalid_counts_do_not_run_any_commands(self):
        for count in ("0", "-1", "abc", "3d", "", "01"):
            # Empty argument explicitly falls back to the configured default.
            if count == "":
                continue
            with self.subTest(count=count):
                result, calls = self.run_prune(count)
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(calls, [])
        result, calls = self.run_prune("3", "extra")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(calls, [])

    def test_pending_boot_or_test_does_not_prune_or_change_boot_default(self):
        result, calls = self.run_prune(fail_stage="pending")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(calls, [])
        self.assertIn("pending boot/test/rollback", result.stderr)

    def test_system_prune_failure_stops_before_boot_sync(self):
        result, calls = self.run_prune(fail_stage="system")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(len(calls), 1)

    def test_boot_sync_failure_never_collects_store_paths(self):
        result, calls = self.run_prune(fail_stage="boot")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(len(calls), 2)
        self.assertNotIn("sudo nix-collect-garbage", calls)

    def test_user_profile_failure_stops_before_gc(self):
        result, calls = self.run_prune(fail_stage="user")
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn("sudo nix-collect-garbage", calls)

    def test_gc_failure_is_not_hidden_by_disk_usage_output(self):
        result, calls = self.run_prune(fail_stage="gc")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(calls[-1], "sudo nix-collect-garbage")

    def test_absent_home_manager_profile_is_skipped(self):
        result, calls = self.run_prune(home_manager=False)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(any("home-manager" in call for call in calls))

    def test_override_is_explicit_about_separate_boot_menu_limit(self):
        result, calls = self.run_prune("5")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("--delete-generations +5", calls[0])
        self.assertIn("boot menu limit is 3", result.stdout)

    def test_failed_rebuild_skips_prune(self):
        body = r'''
pushd() { return 0 }
popd() { return 0 }
git() { return 0 }
clear() { return 0 }
systemctl() { return 0 }
restart-services() { return 0 }
nixos-prune() { print -r -- PRUNE >> "$CALLS" }
nixos-rebuild-host
'''
        result, calls = self.run_prune(fail_stage="rebuild", body=body)
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(any("PRUNE" in call for call in calls))

    def test_boot_and_test_rebuilds_preserve_failure_status(self):
        for function in ("nixos-rebuild-boot", "nixos-rebuild-test"):
            with self.subTest(function=function):
                body = r'''
pushd() { return 0 }
popd() { return 0 }
git() { return 0 }
clear() { return 0 }
''' + function
                result, _ = self.run_prune(fail_stage="rebuild", body=body)
                self.assertNotEqual(result.returncode, 0)

    def test_cleanup_failure_after_successful_rebuild_is_reported(self):
        body = r'''
pushd() { return 0 }
popd() { return 0 }
git() { return 0 }
clear() { return 0 }
systemctl() { return 0 }
restart-services() { return 0 }
nixos-prune() { return 1 }
nixos-rebuild-host
'''
        result, _ = self.run_prune(body=body)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Rebuild succeeded, but cleanup failed", result.stderr)


if __name__ == "__main__":
    unittest.main()

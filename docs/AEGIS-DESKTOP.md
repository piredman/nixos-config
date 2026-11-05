# Aegis Desktop

Aegis Desktop is an **unofficial** port of Aegis Authenticator. It is enabled on
terra and luna through the existing `moduleGroups` mechanism:

- `"security"` in each host's `home.nix` installs the user application.
- `"security"` in each host's `configuration.nix` registers the system polkit
  policy needed for optional user-presence checks.

The module helper discovers the files in both `security/` groups automatically.
There are no application flags in `settings.nix` or per-user module imports.

## Installation and use

The existing dotfiles flake builds `pkgs/aegis-desktop` from a pinned upstream
commit. Gradle dependencies are fetched using the hashes in `deps.json` and
served by nixpkgs' local dependency-cache proxy inside the build sandbox.
Neither host needs a source checkout in `~/code`, a `shell.nix`, a populated
Gradle cache, or a manually built application archive.

After the changes are tested and committed, other hosts only need:

```bash
git pull
nrh
```

Launch `aegis` from a terminal or **Aegis Desktop** from Walker. The first rebuild
may take time to download dependencies and compile the application. Subsequent
unchanged rebuilds reuse the Nix store output.

The native application uses `~/.local/share/aegis/aegis.json` by default, or the
directory selected by `AEGIS_HOME`. Import a **copy** of an encrypted Android
export through the UI; keep the original export as a backup. Vault contents and
passwords must never be added to the dotfiles repository or the Nix store.

The installed application is not sandboxed at runtime. Nix's **build** sandbox
does not confine a running application. Keep a strong vault password, verify
codes against the phone, and test vault locking on screen lock and suspend on
each compositor before relying on it. Avoid two devices writing a synced vault.

## Package design

- `pkgs/aegis-desktop/default.nix`: pinned source, Gradle/toolchain, native
  runtime dependencies, and package metadata.
- `pkgs/aegis-desktop/deps.json`: dependency URLs and SHA-256 hashes, not JARs.
- `home/_modules/security/aegis-desktop.nix`: the user application, desktop entry,
  and icon, selected through the host's home module groups.
- `hosts/_modules/security/aegis-desktop.nix`: the small system-wide polkit action
  package used by optional user-presence checks. It does not install the GUI
  system-wide or automatically enable keychain unlock.

The package patches upstream's absolute `gdbus` and `pkcheck` paths to Nix store
paths. Its launcher supplies libsecret and the graphics libraries, forwards
arguments using `makeWrapper`, disables core dumps, and retains the JVM flags
that disable heap dumps and debugger attach. A Nix-built minimal Java 21 runtime
includes the modules the app needs; this is not a network sandbox.

Dependency JARs remain separate rather than being flattened into an uber-JAR,
which would invalidate signed dependencies such as Bouncy Castle.

The package currently supports `x86_64-linux`, matching terra and luna. Its
explicit protoc download and platform-specific renderer would need updating
before adding another architecture.

## Validation on terra

New files must be Git-tracked before a Git-backed flake can see them. Run build
checks manually; these commands do not activate a configuration:

```bash
nix build .#aegis-desktop
sudo nixos-rebuild build --flake .#terra
sudo nixos-rebuild build --flake .#luna
```

The application build runs the upstream core, platform, and desktop tests.
Native Secret Service tests may skip when no keyring is available in the sandbox.
After a successful build, launch `./result/bin/aegis` if `result` still points to
the standalone application build, or use `nix run .#aegis-desktop`. Verify import,
codes, lock/suspend behaviour, and optional keychain/polkit integration after
manually applying the configuration. Only then commit and push the changes.

## Updating upstream

Maintenance happens once on terra; luna still only pulls and runs `nrh`.

1. Update the source revision, source hash, and version in `default.nix`.
2. Check whether upstream changed its Java, Gradle, or protoc versions and update
   those pins as needed. Check that the source substitutions still apply.
3. From the dotfiles root, regenerate the dependency lock using nixpkgs' updater:

   ```bash
   updater=$(nix build --no-link --print-out-paths .#aegis-desktop.mitmCache.updateScript)
   "$updater"
   ```

   The updater intentionally fetches upstream dependencies to record their hashes.
   It runs the same source patches and build/test tasks as the package, with a
   fresh Gradle cache. Review changes to `deps.json` before committing them.

4. Build and test on terra, commit the package and dependency-lock changes, and
   push. On luna, `git pull` followed by `nrh` builds the same pinned package.

Do not restore the old `mk-aegis-artifact.sh` workflow or commit built JARs.

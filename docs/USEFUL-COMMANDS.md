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

**How cleanup works:** `nrh` (event: every `nixos-rebuild switch`) runs `nixos-prune` automatically:

1. Keeps the newest 5 generations of each profile (system, home-manager, user) via
   `nix-env --delete-generations +5`
2. Releases the store paths those generations were pinning (`sudo nix-collect-garbage`,
   without `-d`, so no generations beyond profiles' newest 5 are touched)
3. Resyncs the systemd-boot entry list via
   `sudo /run/current-system/bin/switch-to-configuration boot` — this is the step that
   actually reclaims freed space on `/boot`; plain GC commands alone do not update the ESP
4. `/boot` therefore plateaus (~20% used) instead of ratcheting up with every rebuild

Manual override: `nprune <n>` keeps n generations instead of 5. `nprune` with no argument
runs as configured. `configurationLimit = 5` in `hosts/_modules/core/core.nix` limits the
boot menu to match.

To inspect state:

```bash
nix-env --list-generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
lsblk -o NAME,MOUNTPOINT,SIZE,FSUSED,FSAVAIL,FSUSE%
```

Emergency nuke (kills ALL history — use NixOS generations instead whenever possible):

```bash
sudo nix-collect-garbage -d
```

`nix-store --optimize` is unnecessary here — `auto-optimise-store = true` in
`hosts/_modules/core/core.nix` dedupes store paths as they're written.

## See Also

- [Bootstrap Guide](BOOTSTRAP.md) - Initial setup

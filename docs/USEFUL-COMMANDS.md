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

## See Also

- [Bootstrap Guide](BOOTSTRAP.md) - Initial setup

# Bootstrap Guide

For installing NixOS on a machine that already has host configuration and user setup in the repository.

## Bootstrap Command

On a fresh NixOS install, run this single command:

```bash
nix-shell -p curl git --run "bash <(curl -fsSL https://raw.githubusercontent.com/piredman/nixos-config/master/bootstrap)"
```

## What Happens

The bootstrap script:

1. Auto-detects your hostname and username
2. Clones this repository to `~/.dotfiles`
3. Checks if your host configuration already exists in the repository

## If Host Config Exists

If your hostname matches an existing configuration (terra, luna, mini), the bootstrap script will automatically:

1. **Update settings** - Set hostname, username, timezone, and locale in `hosts/$HOSTNAME/settings.nix`
2. **Copy hardware config** - Copy `/etc/nixos/hardware-configuration.nix` to `hosts/$HOSTNAME/`
3. **Update LUKS settings** - If encryption was enabled, update the device UUID in settings.nix
4. **Show configuration** - Display the updated settings for your approval
5. **Apply configuration** - Run `sudo nixos-rebuild switch --flake .#$HOSTNAME`

The script will prompt for confirmation before applying the configuration.

## If Host Config Doesn't Exist

If your hostname doesn't match any existing configuration, the bootstrap script will provide instructions for manual setup.

## After Bootstrap

Once configuration is applied:

- Your system is fully configured with your software stack
- Home-manager settings are applied automatically
- All your aliases and tools are available
- Reboot

See [Useful Commands](USEFUL-COMMANDS.md) for common operations.

## See Also

- [Useful Commands](USEFUL-COMMANDS.md) - Common operations
- [Post-Bootstrap Setup](POST-BOOTSTRAP.md) - GPG, SSH, and secrets setup

# Daily Usage

Common commands and workflows for managing your NixOS configuration.

## Current Setup

- **Host:** terra (NixOS unstable)
- **User:** redman
- **Desktop:** Hyprland (wayland)
- **Terminal:** Ghostty
- **File Manager:** Dolphin
- **App Launcher:** Walker
- **Shell:** zsh

## System Configuration

### Rebuild Current System

Apply system configuration changes:

```bash
cd ~/.dotfiles
sudo nixos-rebuild switch --flake .#terra
```

Replace `terra` with your hostname.

### Rebuild Different Host

If you manage multiple hosts from one machine:

```bash
sudo nixos-rebuild switch --flake .#hostname
```

### Test Configuration Without Switching

Test configuration before making it the default:

```bash
sudo nixos-rebuild test --flake .#terra
```

Changes apply immediately but won't persist after reboot.

### Build Without Activating

Build the configuration to check for errors:

```bash
sudo nixos-rebuild build --flake .#terra
```

## Home Manager Configuration

### Apply Home Configuration

Apply your user configuration:

```bash
cd ~/.dotfiles
home-manager switch --flake .#redman
```

Replace `redman` with your username.

### Apply Different User Configuration

```bash
home-manager switch --flake .#username
```

## Updating Packages

### Update All Inputs

Update both unstable and stable package channels:

```bash
cd ~/.dotfiles
nix flake update
```

This updates `flake.lock` with the latest package versions.

### Update and Rebuild

Update packages and apply immediately:

```bash
nix flake update
sudo nixos-rebuild switch --flake .#terra
home-manager switch --flake .#redman
```

### Update Specific Input

Update only the unstable channel:

```bash
nix flake lock --update-input nixpkgs
```

Update only the stable channel:

```bash
nix flake lock --update-input nixpkgs-stable
```

Update only home-manager:

```bash
nix flake lock --update-input home-manager
```

## Rollback and Recovery

### List System Generations

See all previous system configurations:

```bash
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
```

### Rollback to Previous Generation

Rollback to the last working configuration:

```bash
sudo nixos-rebuild switch --rollback
```

### Boot Into Specific Generation

1. Reboot your system
2. In the bootloader menu, select an older generation
3. System boots with that configuration

### List Home Manager Generations

```bash
home-manager generations
```

Output:
```
2025-10-11 14:30 : id 5 -> /nix/store/xxx-home-manager-generation
2025-10-10 09:15 : id 4 -> /nix/store/yyy-home-manager-generation
```

### Rollback Home Manager

Activate a previous generation:

```bash
/nix/store/yyy-home-manager-generation/activate
```

Replace with the path from `home-manager generations` output.

## Garbage Collection

### Clean Old Generations

Remove old system generations older than 7 days:

```bash
sudo nix-collect-garbage --delete-older-than 7d
```

### Clean All Old Generations

Remove all old generations except the current one:

```bash
sudo nix-collect-garbage -d
```

### Optimize Nix Store

Deduplicate and optimize the Nix store:

```bash
sudo nix-store --optimize
```

### Full Cleanup Workflow

```bash
# Remove old generations
sudo nix-collect-garbage --delete-older-than 14d

# Optimize store
sudo nix-store --optimize

# Check disk usage
df -h /nix
```

## Common Workflows

### Make Configuration Change

1. Edit configuration files:
   ```bash
   cd ~/.dotfiles
   vim hosts/terra/configuration.nix
   ```

2. Test the change:
   ```bash
   sudo nixos-rebuild test --flake .#terra
   ```

3. If good, make it permanent:
   ```bash
   sudo nixos-rebuild switch --flake .#terra
   ```

4. Commit to git:
   ```bash
   git add .
   git commit -m "Add package X to configuration"
   git push
   ```

### Add a Package

#### System Package

Modify the appropriate module in `hosts/_modules/` (typically `core.nix`), or create a custom module and import it in your host's `configuration.nix`:

```nix
# hosts/_modules/core.nix or custom module
environment.systemPackages = with pkgs; [
    neovim
    git
    htop      # Add this
];
```

Apply:
```bash
sudo nixos-rebuild switch --flake .#terra
```

#### User Package

Edit `home/<username>/default.nix`:

```nix
home.packages = with pkgs; [
  discord
  vscode    # Add this
];
```

Apply:
```bash
home-manager switch --flake .#redman
```

### Remove a Package

Remove from configuration file and rebuild:

```bash
# Edit the file to remove package
vim hosts/terra/configuration.nix

# Rebuild
sudo nixos-rebuild switch --flake .#terra
```

### Update a Single Package

NixOS doesn't support updating individual packages. You update all packages together:

```bash
nix flake update
sudo nixos-rebuild switch --flake .#terra
```

If you need different versions, see [Package Management](PACKAGES.md) for using stable alongside unstable.

## Checking Status

### Check Flake Inputs

See what versions you're using:

```bash
nix flake metadata
```

### Check Current Generation

```bash
# System generation
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | tail -1

# Home generation
home-manager generations | head -1
```

### Check Disk Usage

```bash
# Nix store size
du -sh /nix/store

# Breakdown
nix path-info -rsSh /run/current-system | sort -hk2
```

### Check for Broken Links

```bash
nix-store --verify --check-contents
```

## Multi-Host Management

### Managing Multiple Hosts

If you manage configurations for multiple machines (e.g., `terra` and `mini`):

```bash
cd ~/.dotfiles

# Update all hosts
nix flake update
git add flake.lock
git commit -m "Update all hosts"
git push

# On each host, pull and rebuild
git pull
sudo nixos-rebuild switch --flake .#hostname
```

### Host-Specific Configuration

Each host has its own directory with separate settings:

```bash
# terra host (primary)
hosts/terra/
├── configuration.nix        # Imports modules from hosts/_modules/
├── hardware-configuration.nix
├── home.nix                 # Home-manager integration
└── settings.nix             # Hostname, arch, user, timezone, locale, etc.

# mini host
hosts/mini/
├── configuration.nix        # Imports modules from hosts/_modules/
├── hardware-configuration.nix
├── home.nix
└── settings.nix
```

The `configuration.nix` imports shared modules from `hosts/_modules/`. Customize modules or create new ones in `hosts/_modules/` and import them in your host's `configuration.nix`. The `home.nix` file controls which home-manager module groups are loaded. See [Host Modules Pattern](ADVANCED.md#host-modules-pattern) for details.

### Remote Rebuilds

Build configuration on one machine, deploy to another:

```bash
nixos-rebuild switch --flake .#hostname --target-host user@remote-host
```

Requires SSH access to the remote host.

## Troubleshooting

### Build Fails

Check the error message and fix configuration:

```bash
sudo nixos-rebuild switch --flake .#terra --show-trace
```

The `--show-trace` flag shows more detailed error information.

### Roll Back

If system is broken after rebuild:

```bash
sudo nixos-rebuild switch --rollback
```

### Check Logs

View system logs:

```bash
journalctl -xe
```

View build logs:

```bash
nix log /nix/store/xxx-nixos-system-xxx
```

## Performance Tips

### Parallel Builds

Speed up builds with parallel jobs (already set in most systems):

```nix
# In configuration.nix
nix.settings.max-jobs = "auto";
nix.settings.cores = 4;
```

### Use Binary Cache

Ensure binary cache is enabled (default):

```nix
nix.settings.substituters = [
  "https://cache.nixos.org"
];
```

### Local Builds

For slow internet, prefer local builds:

```bash
sudo nixos-rebuild switch --flake .#mini --option substitute false
```

## Quick Reference

```bash
# Update and rebuild everything
nix flake update && sudo nixos-rebuild switch --flake .#terra && home-manager switch --flake .#redman

# Quick system rebuild
sudo nixos-rebuild switch --flake .#terra

# Quick home rebuild  
home-manager switch --flake .#redman

# Rollback system
sudo nixos-rebuild switch --rollback

# Clean up (careful!)
sudo nix-collect-garbage -d && sudo nix-store --optimize

# Check disk space
du -sh /nix/store
```

## See Also

- [Bootstrap Guide](BOOTSTRAP.md) - Initial setup
- [Package Management](PACKAGES.md) - Managing packages
- [Advanced Topics](ADVANCED.md) - Advanced configuration

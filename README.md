# NixOS Configuration

A modular, declarative NixOS configuration with automatic host discovery and rolling release (unstable) + stable package support.

## Features

- 🚀 **One-command bootstrap** - Set up a new system in minutes
- 🔄 **Rolling release** - NixOS unstable with stable fallback
- 🔍 **Auto-discovery** - Automatically detects hosts and users
- 📝 **Declarative** - Everything is reproducible and version-controlled
- 🛠️ **Template-based** - Easy setup for new hosts
- 🏠 **Home Manager** - Integrated user-level package and configuration management

## Quick Start

On a fresh NixOS install, run this single command:

```bash
nix-shell -p curl git --run "bash <(curl -fsSL https://raw.githubusercontent.com/piredman/nixos-config/master/bootstrap)"
```

See the [Bootstrap Guide](docs/BOOTSTRAP.md) for setup on machines with existing configuration.

## Documentation

- 📦 [Bootstrap Guide](docs/BOOTSTRAP.md) - Installing on machines with existing config
- 💻 [Useful Commands](docs/USEFUL-COMMANDS.md) - Common commands & workflows

## Running Tests

```bash
nix run github:nix-community/nix-unit -- lib/moduleHelper_test.nix
```

## Repository Structure

```
nixos-config/
├── bootstrap                # Bootstrap script
├── hosts/                   # Per-host system configurations
│   ├── <hostname>/          # Host-specific config
│   └── _modules/            # Shared system modules
├── home/                    # User configurations
│   ├── <username>/          # User-specific config
│   └── _modules/            # Dynamic module groups
│       ├── core/            # Essential modules
│       ├── comms/           # Communication tools
│       ├── dev/             # Development tools
│       ├── gamedev/         # Game development
│       ├── notes/           # Note-taking apps
│       ├── office/          # Office applications
│       └── streaming/       # Streaming tools
├── lib/                     # Nix utilities and tests
├── docs/                    # Documentation
└── flake.nix               # Flake with auto-discovery
```

## Quick Reference

### Update Everything

```bash
nup && nrh  # Update flake + rebuild system (includes home-manager)
```

Or manually:

```bash
cd ~/.dotfiles
nix flake update
sudo nixos-rebuild switch --flake .#terra
```

### Rebuild System

```bash
nrh  # Rebuild current host (includes home-manager)
```

Or manually:

```bash
sudo nixos-rebuild switch --flake .#hostname
```

### Rollback System

```bash
sudo nixos-rebuild switch --rollback
```

### Clean Up

```bash
sudo nix-collect-garbage --delete-older-than 7d
sudo nix-store --optimize
```

### Check Disk Usage

```bash
# Check disk usage
df -h /nix

# Nix store size
du -sh /nix/store

# Breakdown
nix path-info -rsSh /run/current-system | sort -hk2
```

## Shell Aliases

After bootstrap, these aliases are available for common operations:

- `nrh` - Rebuild current host system (includes git add)
- `nup` - Update flake inputs (includes git add)
- `nru` - Rebuild user config (legacy - use nrh for integrated setup)

See [Useful Commands](docs/USEFUL-COMMANDS.md) for more commands.

## Current Hosts

- **terra** - Primary workstation (x86_64-linux, Hyprland desktop)
- **luna** - Secondary system (x86_64-linux)
- **mini** - Minimal setup (x86_64-linux)

## Current Users

- **redman** - Paul Redman (uses dynamic module groups)

## How It Works

### Auto-Discovery

The flake automatically discovers all hosts:

```nix
# All directories in hosts/ become available system configurations
hosts/terra/     -> nixosConfigurations.terra
hosts/luna/      -> nixosConfigurations.luna
hosts/mini/      -> nixosConfigurations.mini
```

Home-manager is integrated as a NixOS module, so user configurations are applied automatically during system rebuilds.

## Adding a New Host

### On Your Development Machine

```bash
cd ~/.dotfiles

# Copy an existing host as a template
cp -r hosts/terra hosts/laptop

# Edit settings for the new host
vim hosts/laptop/settings.nix
# Update: hostname, arch, user, timezone, locale, monitors, etc.

# Configure which home module groups to load
vim hosts/laptop/home.nix

# If this is a new user, create their configuration
mkdir -p home/alice
vim home/alice/settings.nix
# Add: username = "alice"; name = "Alice Smith";

vim home/alice/default.nix
# Copy structure from home/redman/default.nix

# Commit and push
git add .
git commit -m "Add laptop configuration"
git push
```

### On The New Machine

```bash
# Clone the repository
git clone https://github.com/piredman/nixos-config.git ~/.dotfiles
cd ~/.dotfiles

# Copy hardware configuration
sudo cp /etc/nixos/hardware-configuration.nix hosts/laptop/

# Apply the configuration
nrh  # Uses alias: git add -A && sudo nixos-rebuild switch --flake .#$HOST
```

See [Bootstrap Guide](docs/BOOTSTRAP.md) for detailed instructions and scenarios.

## Contributing

This is a personal configuration, but you're welcome to fork and adapt it for your own use.

## License

This configuration is provided as-is for personal use.

## Acknowledgments

Built with:

- [NixOS](https://nixos.org/)
- [Home Manager](https://github.com/nix-community/home-manager)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)

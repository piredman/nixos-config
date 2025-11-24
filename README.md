# NixOS Configuration

A modular, declarative NixOS configuration with automatic host discovery and rolling release (unstable) + stable package support.

## Features

- 🚀 **One-command bootstrap** - Set up a new system in minutes
- 🔄 **Rolling release** - NixOS unstable with stable fallback
- 🔍 **Auto-discovery** - Automatically detects hosts and users
- 📝 **Declarative** - Everything is reproducible and version-controlled
- 🛠️ **Template-based** - Easy setup for new hosts
- 🏠 **Home Manager** - User-level package and configuration management

## Quick Start

On a fresh NixOS install, run this single command:

```bash
nix-shell -p curl git --run "bash <(curl -fsSL https://raw.githubusercontent.com/piredman/nixos-config/master/bootstrap)"
```

See the [Bootstrap Guide](docs/BOOTSTRAP.md) for detailed scenarios and what happens during bootstrap.

## Documentation

- 📦 [Bootstrap Guide](docs/BOOTSTRAP.md) - Installation scenarios & workflows
- 🎯 [Package Management](docs/PACKAGES.md) - Using stable vs unstable packages
- 💻 [Daily Usage](docs/DAILY-USAGE.md) - Common commands & workflows
- ⚙️ [Advanced Topics](docs/ADVANCED.md) - Manual configuration & customization

## Repository Structure

```
nixos-config/
├── bootstrap                # Bootstrap script (clones repo, provides setup instructions)
├── hosts/                   # Per-host system configurations
│   ├── mini/
│   │   ├── configuration.nix
│   │   ├── hardware-configuration.nix
│   │   ├── home.nix                  # Home-manager integration
│   │   └── settings.nix
│   ├── terra/
│   │   ├── configuration.nix
│   │   ├── hardware-configuration.nix
│   │   ├── home.nix
│   │   └── settings.nix
│   ├── luna/
│   │   ├── configuration.nix
│   │   ├── hardware-configuration.nix
│   │   ├── home.nix
│   │   └── settings.nix
│   ├── _modules/            # Shared system modules
│   │   ├── core.nix         # Boot, environment, locale, nix
│   │   ├── fileSystems.nix
│   │   ├── networking.nix
│   │   ├── nvidia.nix
│   │   ├── programs.nix
│   │   ├── services.nix
│   │   ├── stylix.nix
│   │   └── users.nix
│   └── _settings/           # Shared settings
│       └── nas.nix
├── home/                    # Home Manager user configurations
│   ├── redman/
│   │   ├── default.nix
│   │   ├── settings.nix
│   │   └── nvim/            # Neovim configuration
│   │       ├── init.lua
│   │       ├── lsp/
│   │       └── lua/
│   └── _modules/            # Dynamic module groups
│       ├── default.nix      # Module group helper
│       ├── core/            # Essential modules
│       │   ├── shell/
│       │   ├── waybar/
│       │   ├── ghostty.nix
│       │   ├── git.nix
│       │   ├── hyprland.nix
│       │   └── ... (other modules)
│       ├── comms/           # Communication tools
│       ├── dev/             # Development tools
│       ├── gamedev/         # Game development
│       ├── notes/           # Note-taking apps
│       ├── office/          # Office applications
│       └── streaming/       # Streaming tools
├── docs/                    # Documentation
└── flake.nix               # Flake with auto-discovery
```

## Quick Reference

### Update Everything

```bash
cd ~/.dotfiles
nix flake update
sudo nixos-rebuild switch --flake .#terra
home-manager switch --flake .#redman
```

### Rebuild System

```bash
sudo nixos-rebuild switch --flake .#hostname
```

### Rebuild Home

```bash
home-manager switch --flake .#username
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

See [Daily Usage](docs/DAILY-USAGE.md) for more commands.

## Current Hosts

- **terra** - Primary workstation (x86_64-linux, Hyprland desktop)
- **mini** - Secondary system (x86_64-linux)

## Current Users

- **redman** - Paul Redman (uses dynamic module groups)

## How It Works

### Auto-Discovery

The flake automatically discovers all hosts and users:

```nix
# All directories in hosts/ become available configurations
hosts/terra/     -> nixosConfigurations.terra
hosts/mini/      -> nixosConfigurations.mini

# All directories in home/ become available configurations  
home/redman/     -> homeConfigurations.redman
home/alice/      -> homeConfigurations.alice
```

### Package Management

Default: **nixos-unstable** (rolling release)

```nix
environment.systemPackages = with pkgs; [
  firefox   # Latest from unstable
];
```

Fallback: **nixos-stable** (25.05) when needed

```nix
environment.systemPackages = with pkgs; [
  firefox
] ++ [
  pkgs-stable.vlc  # Stable version
];
```

See [Package Management](docs/PACKAGES.md) for details.

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
sudo nixos-rebuild switch --flake .#laptop
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

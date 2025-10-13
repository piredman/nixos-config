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
- 🛠️ [Scripts Reference](docs/SCRIPTS.md) - Helper scripts documentation
- ⚙️ [Advanced Topics](docs/ADVANCED.md) - Manual configuration & customization

## Repository Structure

```
nixos-config/
├── bootstrap                # Bootstrap script for new systems
├── scripts/
│   └── setup-host.sh       # Helper to create new host/user configs
├── hosts/                   # Per-host system configurations
│   ├── mini/
│   │   ├── configuration.nix
│   │   ├── hardware-configuration.nix
│   │   └── settings.nix
│   └── template/            # Template for new hosts
│       ├── configuration.nix
│       └── settings.nix
├── home/                    # Home Manager user configurations
│   ├── redman/
│   │   ├── default.nix
│   │   ├── settings.nix
│   │   ├── sh.nix
│   │   ├── hyprland.nix
│   │   ├── ghostty.nix
│   │   ├── dolphin.nix
│   │   ├── walker.nix
│   │   └── polkit.nix
│   └── template/            # Template for new users
│       ├── default.nix
│       └── settings.nix
├── common/                  # Shared configuration (unfree, flakes)
│   └── default.nix
├── docs/                    # Documentation
└── flake.nix               # Flake with auto-discovery
```

## Quick Reference

### Update Everything

```bash
cd ~/.dotfiles
nix flake update
sudo nixos-rebuild switch --flake .#mini
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

- **mini** - Primary workstation (x86_64-linux)

## Current Users

- **redman** - Paul Redman

## How It Works

### Auto-Discovery

The flake automatically discovers all hosts and users:

```nix
# All directories in hosts/ become available configurations
hosts/mini/      -> nixosConfigurations.mini
hosts/laptop/    -> nixosConfigurations.laptop

# All directories in home/ become available configurations  
home/redman/     -> homeConfigurations.redman
home/alice/      -> homeConfigurations.alice
```

The `template` directories are excluded from discovery.

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

### Option 1: Use Bootstrap (Recommended)

On the new machine, run the bootstrap command. It will:
- Auto-detect hostname and username
- Create configuration from templates
- Apply the configuration

### Option 2: Pre-Configure

Before installing NixOS:

```bash
cd ~/.dotfiles
./scripts/setup-host.sh laptop alice "Alice Smith" "America/New_York" "en_US.UTF-8"
git add . && git commit -m "Add laptop config" && git push
```

Then bootstrap the laptop - it will find and use the config.

See [Bootstrap Guide](docs/BOOTSTRAP.md) for all scenarios.

## Contributing

This is a personal configuration, but you're welcome to fork and adapt it for your own use.

## License

This configuration is provided as-is for personal use.

## Acknowledgments

Built with:
- [NixOS](https://nixos.org/)
- [Home Manager](https://github.com/nix-community/home-manager)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)

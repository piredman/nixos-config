# My NixOS Setup

## Quick Bootstrap (New System)

On a fresh NixOS install, run this single command:

```bash
nix-shell -p curl git --run "bash <(curl -fsSL https://raw.githubusercontent.com/piredman/nixos-config/master/bootstrap)"
```

This will:

- Auto-detect your hostname and username
- Clone this repository
- Set up your host and home configurations
- Apply the NixOS configuration

The bootstrap script will prompt you for:

- Hostname (defaults to current system hostname)
- Username (defaults to current user)
- Full name
- Timezone (defaults to America/Edmonton)
- Locale (defaults to en_GB.UTF-8)

## Repository Structure

```
nixos-config/
├── bootstrap           # Bootstrap script for new systems
├── scripts/            # Helper scripts
│   └── setup-host.sh
├── hosts/              # Per-host configurations
│   ├── mini/
│   │   ├── configuration.nix
│   │   ├── hardware-configuration.nix
│   │   └── settings.nix
│   └── template/       # Template for new hosts
├── home/               # Home Manager user configurations
│   ├── redman/
│   │   ├── default.nix
│   │   ├── settings.nix
│   │   ├── sh.nix
│   │   └── hyprland.nix
│   └── template/       # Template for new users
├── common/             # Shared system configuration
│   └── default.nix
└── flake.nix           # Auto-discovers hosts and users
```

## System Configuration

Update system packages:

```bash
nix flake update
```

Update system (current host):

```bash
sudo nixos-rebuild switch --flake .#mini
```

Update system for alternate host:

```bash
sudo nixos-rebuild switch --flake .#hostname
```

## Home Manager Configuration

Update user config (current user):

```bash
home-manager switch --flake .#redman
```

Update user config for alternate user:

```bash
home-manager switch --flake .#username
```

Rollback config:

```bash
home-manager generations

# output
2025-10-03 07:35 : id 5 -> /nix/store/i240y16jblsipy8dq5lnma8xszck8a2q-home-manager-generation
2025-10-03 07:30 : id 4 -> /nix/store/41v7pax83lby5c098j79g3lmmlrn6j6m-home-manager-generation

# use the generation path + /activate, so for id 4:
/nix/store/41v7pax83lby5c098j79g3lmmlrn6j6m-home-manager-generation/activate
```

## Adding a New Host

The flake automatically discovers all hosts in the `hosts/` directory (except `template`).

### Automated Method

Use the setup script:

```bash
./scripts/setup-host.sh <hostname> <username> <fullname> <timezone> <locale>
```

### Manual Method

1. Create host directory: `mkdir -p hosts/newhostname`
2. Copy generated hardware config: `sudo cp /etc/nixos/hardware-configuration.nix hosts/newhostname/`
3. Create `hosts/newhostname/configuration.nix` (use `hosts/template/configuration.nix` as template)
4. Create `hosts/newhostname/settings.nix` with your settings
5. Rebuild: `sudo nixos-rebuild switch --flake .#newhostname`

Note: The flake will automatically pick up the new host configuration.

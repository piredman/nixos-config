# My NixOS Setup

## Repository Structure

```
nixos-config/
├── hosts/              # Per-host configurations
│   └── mini/
│       ├── configuration.nix
│       └── hardware-configuration.nix
├── home/               # Home Manager user configurations
│   ├── redman.nix
│   ├── sh.nix
│   └── hyprland.nix
├── common/             # Shared system configuration
│   └── default.nix
└── flake.nix
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

1. Create host directory: `mkdir -p hosts/newhostname`
2. Copy generated hardware config: `sudo cp /etc/nixos/hardware-configuration.nix hosts/newhostname/`
3. Create `hosts/newhostname/configuration.nix` (use `hosts/mini/configuration.nix` as template)
4. Add host to `flake.nix` nixosConfigurations
5. Rebuild: `sudo nixos-rebuild switch --flake .#newhostname`


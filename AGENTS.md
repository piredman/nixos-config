# Agent Guidelines for NixOS Configuration

## Project Overview

This is a modular NixOS configuration with:
- Auto-discovery of hosts and users
- NixOS unstable (rolling release) with stable (25.05) fallback
- Bootstrap script for new system setup
- Template-based host/user creation
- Home Manager integration

## Repository Structure

```
nixos-config/
├── bootstrap                # Bootstrap script (bash)
├── scripts/
│   └── setup-host.sh       # Create new host/user configs (bash)
├── hosts/                   # System configurations
│   ├── <hostname>/
│   │   ├── configuration.nix
│   │   ├── hardware-configuration.nix
│   │   └── settings.nix
│   └── template/            # Template for new hosts
├── home/                    # User configurations  
│   ├── <username>/
│   │   ├── default.nix
│   │   ├── settings.nix
│   │   └── *.nix           # User-specific modules
│   └── template/            # Template for new users
├── common/
│   └── default.nix         # Shared config (unfree, flakes)
├── docs/                    # Documentation
│   ├── BOOTSTRAP.md
│   ├── PACKAGES.md
│   ├── DAILY-USAGE.md
│   ├── SCRIPTS.md
│   └── ADVANCED.md
└── flake.nix               # Auto-discovers hosts/users
```

## Key Concepts

### Auto-Discovery
- Flake automatically discovers all directories in `hosts/` and `home/`
- `template` directories are filtered out
- No need to edit flake.nix when adding new hosts/users

### Settings Files
- Each host has `settings.nix` with: hostname, timezone, local
- Each user has `settings.nix` with: username, name
- Settings imported automatically via `mkSystemSettings` and `mkUserSettings`

### Package Management
- `pkgs` - nixos-unstable (default)
- `pkgs-stable` - nixos-25.05 (fallback)
- Both available in all configs via `specialArgs`/`extraSpecialArgs`

### Bootstrap Workflow
1. User runs bootstrap one-liner
2. Bootstrap clones repo to `~/.dotfiles`
3. Bootstrap calls `setup-host.sh` with detected values
4. `setup-host.sh` creates host/user configs from templates
5. Bootstrap applies configuration

## Build/Deploy Commands

### System Configuration
```bash
# Rebuild current system
sudo nixos-rebuild switch --flake .#mini

# Rebuild specific host
sudo nixos-rebuild switch --flake .#hostname

# Test without making permanent
sudo nixos-rebuild test --flake .#mini

# Build only (check for errors)
sudo nixos-rebuild build --flake .#mini
```

### Home Manager Configuration
```bash
# Apply current user config
home-manager switch --flake .#redman

# Apply specific user config
home-manager switch --flake .#username
```

### Update Packages
```bash
# Update all inputs (unstable + stable)
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs
nix flake lock --update-input nixpkgs-stable

# Update and apply
nix flake update && sudo nixos-rebuild switch --flake .#mini
```

### Maintenance
```bash
# Rollback system
sudo nixos-rebuild switch --rollback

# Clean old generations
sudo nix-collect-garbage --delete-older-than 7d

# Optimize store
sudo nix-store --optimize
```

## Code Style

### Nix Expressions
- **Language:** Nix
- **Indentation:** 4 spaces (not tabs)
- **Imports:** Place at top in `imports = [ ./file.nix ];` block
- **Variables:** camelCase (e.g., `systemSettings`, `userSettings`)
- **Attribute sets:** Use `{ }` with consistent spacing
- **Lists:** Use `[ ]`, prefer `with pkgs;` for package lists
- **No trailing semicolons** on closing braces

### Bash Scripts
- **Language:** Bash
- **Shebang:** `#!/usr/bin/env bash`
- **Error handling:** `set -e` at top
- **Indentation:** 4 spaces (not tabs)
- **Quote variables:** Always use `"$VAR"`

### File Organization

**Host Configuration** (`hosts/hostname/configuration.nix`):
```nix
{ config, lib, pkgs, pkgs-stable, systemSettings, userSettings, ... }:

{
    imports = [ ./hardware-configuration.nix ../../common/default.nix ];
    
    # Configuration here
}
```

**User Configuration** (`home/username/default.nix`):
```nix
{ config, pkgs, pkgs-stable, userSettings, ... }:

{
    imports = [ ./module1.nix ./module2.nix ];
    
    home.username = userSettings.username;
    home.homeDirectory = "/home/" + userSettings.username;
    
    # Configuration here
}
```

**Settings Files:**
```nix
# hosts/hostname/settings.nix
{
    hostname = "hostname";
    timezone = "America/Edmonton";
    local = "en_GB.UTF-8";
}

# home/username/settings.nix
{
    username = "username";
    name = "Full Name";
}
```

## Testing

### No Automated Tests
Validation done via rebuild commands.

### Test Workflow
1. Make changes to configuration
2. Test: `sudo nixos-rebuild test --flake .#hostname`
3. If good: `sudo nixos-rebuild switch --flake .#hostname`
4. If bad: `sudo nixos-rebuild switch --rollback`

### Home Manager Testing
1. Make changes to home config
2. Apply: `home-manager switch --flake .#username`
3. Check: Verify applications/settings work
4. Rollback if needed: `home-manager generations` then activate old generation

## Common Tasks

### Add New Host
**Using script:**
```bash
./scripts/setup-host.sh hostname username "Full Name" "Timezone" "Locale"
```

**Manual:**
1. Create `hosts/hostname/` directory
2. Copy `hosts/template/configuration.nix`
3. Create `hosts/hostname/settings.nix`
4. Copy hardware config: `sudo cp /etc/nixos/hardware-configuration.nix hosts/hostname/`
5. Flake auto-discovers on next rebuild

### Add New User
Created automatically by `setup-host.sh` or manually:
1. Create `home/username/` directory
2. Copy `home/template/default.nix`
3. Create `home/username/settings.nix`
4. Flake auto-discovers on next rebuild

### Add Package
**System-wide:**
Edit `hosts/hostname/configuration.nix`:
```nix
environment.systemPackages = with pkgs; [
    package-name
];
```

**User-specific:**
Edit `home/username/default.nix`:
```nix
home.packages = with pkgs; [
    package-name
];
```

**Stable version:**
```nix
pkgs-stable.package-name
```

### Modify Templates
Edit `hosts/template/configuration.nix` or `home/template/default.nix` to change defaults for all new hosts/users created after modification.

## Important Files

### flake.nix
- Auto-discovers hosts and users
- Defines package inputs (unstable + stable)
- Creates `nixosConfigurations` and `homeConfigurations`
- Do NOT manually add host/user entries (auto-discovery handles it)

### bootstrap
- Bash script for initial system setup
- Calls `setup-host.sh` internally
- Clones repo to `~/.dotfiles`
- Applies configuration

### scripts/setup-host.sh
- Creates host/user configs from templates
- Handles hardware config with backup
- Accepts `--force` flag to skip prompts (used by bootstrap)
- Used by bootstrap or manually

### common/default.nix
- Enables unfree packages
- Enables flakes
- Imported by all host configs

## Documentation

All documentation is in `docs/`:
- `BOOTSTRAP.md` - Bootstrap scenarios and workflows
- `PACKAGES.md` - Package management (stable vs unstable)
- `DAILY-USAGE.md` - Common commands and operations
- `SCRIPTS.md` - Helper scripts reference
- `ADVANCED.md` - Advanced configuration topics

When helping users, refer them to appropriate docs.

## Best Practices

### Configuration Changes
1. Edit configuration files
2. Test with `test` or `build` flags first
3. Apply with `switch` when confirmed working
4. Commit to git: `git add . && git commit -m "message"`
5. Push to remote: `git push`

### Package Selection
1. Default to `pkgs` (unstable)
2. Use `pkgs-stable` only when needed
3. Document why stable is used (comments)

### Host Management
1. Each host gets own directory in `hosts/`
2. Each user gets own directory in `home/`
3. Use `template/` as base for new configs
4. Never edit `template/` unless changing defaults for all new hosts/users
5. LUKS configuration belongs in hardware-configuration.nix, NOT configuration.nix

### Bootstrap Best Practices
- Bootstrap always uses `--force` flag with setup-host.sh
- This ensures hardware config is always updated on fresh/reinstalls
- Manual use of setup-host.sh prompts for hardware config overwrite
- Hardware config must be regenerated on any fresh install (LUKS UUIDs change)

### Git Workflow
1. Make configuration changes
2. Test locally
3. Commit: descriptive message
4. Push to remote
5. Other hosts pull and rebuild when ready

## Troubleshooting

### Build Errors
```bash
# Show detailed trace
sudo nixos-rebuild switch --flake .#hostname --show-trace

# Check flake
nix flake check

# Show flake metadata
nix flake metadata
```

### Rollback
```bash
# System rollback
sudo nixos-rebuild switch --rollback

# Home rollback
home-manager generations
# Then activate specific generation path
```

### Debugging
```bash
# Evaluate specific option
nix eval .#nixosConfigurations.hostname.config.environment.systemPackages

# Show flake outputs
nix flake show

# Check logs
journalctl -xe
```

## Notes for AI Assistants

- This configuration uses auto-discovery - don't manually edit flake.nix for new hosts/users
- Settings are in separate `settings.nix` files, not hardcoded in configs
- `pkgs-stable` is available everywhere via specialArgs/extraSpecialArgs
- Bootstrap is for new systems; `setup-host.sh` can be used standalone
- Documentation is comprehensive - refer users to `docs/` for detailed info
- Always test changes before committing
- Repository location is `~/.dotfiles` (not `/etc/nixos`)

# Agent Guidelines for NixOS Configuration

## Project Overview

This is a modular NixOS configuration with:
- Auto-discovery of hosts and users
- NixOS unstable (rolling release) with stable (25.05) fallback
- Bootstrap script for new system setup
- Template-based host/user creation
- Home Manager integration
- Hyprland wayland compositor
- Modular user configurations (ghostty, dolphin, walker, polkit)

## Repository Structure

```
nixos-config/
├── bootstrap                # Bootstrap script
├── hosts/                   # System configurations
│   ├── <hostname>/          # Per-host config
│   └── _modules/            # Shared system module groups
│       ├── core/            # Essential modules
│       ├── android/         # Android tools
│       ├── nvidia/          # NVIDIA GPU
│       ├── printing/        # Printing
│       └── virtual_camera/  # Virtual camera
├── home/                    # User configurations
│   ├── <username>/          # Per-user config
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
└── flake.nix               # Auto-discovers hosts/users
```

## Key Concepts

### Auto-Discovery
- Flake automatically discovers all directories in `hosts/` and `home/`
- Directories starting with `_` are filtered out (used for shared modules)
- No need to edit flake.nix when adding new hosts/users

### Settings Files
- Each host has `settings.nix` with: hostname, arch, user, timezone, locale, and optional fields (luks, nas, monitors)
- Each user has `settings.nix` with: username, name
- Settings imported automatically and passed via `specialArgs`/`extraSpecialArgs`

### Package Management
- `pkgs` - nixos-unstable (default)
- `pkgs-stable` - nixos-25.05 (fallback)
- Both available in all configs via `specialArgs`/`extraSpecialArgs`

### Bootstrap Workflow
1. User runs bootstrap one-liner
2. Bootstrap clones repo to `~/.dotfiles`
3. Bootstrap provides instructions for manual setup
4. User copies existing host and customizes
5. User applies configuration manually

## Build/Deploy Commands

### System Configuration
```bash
# Rebuild current system
sudo nixos-rebuild switch --flake .#terra

# Rebuild specific host
sudo nixos-rebuild switch --flake .#hostname

# Test without making permanent
sudo nixos-rebuild test --flake .#mini

# Build only (check for errors)
sudo nixos-rebuild build --flake .#mini
```



### Update Packages
```bash
# Update all inputs (unstable + stable)
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs
nix flake lock --update-input nixpkgs-stable

# Update and apply
nix flake update && sudo nixos-rebuild switch --flake .#terra
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

let
  moduleGroups = [
    "core"
    # "android"  # Android tools (optional)
    # "nvidia"   # NVIDIA GPU (optional)
    # "printing" # Printing (optional)
    # "virtual_camera" # Virtual camera (optional)
  ];
  moduleHelper = import ../_modules/default.nix { inherit lib; };
  moduleImports = moduleHelper.importModuleGroups moduleGroups;
in
{
  imports = [
    ./hardware-configuration.nix
  ] ++ moduleImports;

  system.stateVersion = "25.05";
}
```

**User Configuration** (`home/username/default.nix`):
```nix
{ config, lib, pkgs, pkgs-stable, userSettings, ... }:

{
    # Module imports are handled by the host configuration via dynamic module groups
    # This keeps user config clean and focused on user-specific settings

    fonts.fontconfig.enable = true;

    home = {
        username = userSettings.username;
        homeDirectory = "/home/" + userSettings.username;
        stateVersion = "25.05";

        packages = with pkgs; [ ];
        file = { };
        sessionVariables = { };
    };

    programs.home-manager.enable = true;
}
```

**Settings Files:**
```nix
# hosts/hostname/settings.nix
{
    hostname = "hostname";
    arch = "x86_64-linux";              # System architecture
    user = "username";                   # Primary user
    timezone = "America/Edmonton";
    locale = "en_GB.UTF-8";
    luks.device = "/dev/disk/by-uuid/...";  # LUKS encryption (optional)
    nas = import ../_settings/nas.nix;       # NAS mounts (optional)
    monitors = {                              # Monitor setup (optional)
        primary = "DP-1";
        secondary = "DP-2";
        setup = [ 
            "DP-1,2560x1440@60,0x0,1"
            "DP-2,1920x1080@60,auto-right,1"
        ];
    };
}

# home/username/settings.nix
{
    username = "username";
    name = "Full Name";
}
```

### Host's home.nix File

Each host has a `home.nix` file that controls which home-manager module groups are loaded:

**hosts/hostname/home.nix:**
```nix
{ config, pkgs, userSettings, lib, ... }:

let
  # Specify which module groups to load for this host
  moduleGroups = [ 
    "core"      # Essential (always include)
    "dev"       # Development tools
    "notes"     # Note-taking apps
    # "comms"   # Communication tools
    # "gamedev" # Game development
    # "office"  # Office applications
    # "streaming" # Streaming tools
  ];
  
  moduleHelper = import ../../home/_modules/default.nix { inherit lib; };
  moduleImports = moduleHelper.importModuleGroups moduleGroups;
in
{
  imports = [
    ../../home/${userSettings.username}/default.nix
  ] ++ moduleImports;

  home = {
    username = userSettings.username;
    homeDirectory = "/home/${userSettings.username}";
    stateVersion = "25.05";
    packages = with pkgs; [ ];
  };
}
```

This allows each host to customize which applications and tools are installed.

## Testing

### Unit Tests
Unit tests validate Nix logic without rebuilding systems:

```bash
# Run unit tests for module helper functions
nix run github:nix-community/nix-unit -- lib/moduleHelper_test.nix
```

Tests cover:
- Module file discovery and filtering
- Path validation and recursion
- Import group functionality

### Integration Testing
Validation done via rebuild commands.

### Test Workflow
1. **Unit tests**: `nix run github:nix-community/nix-unit -- lib/moduleHelper_test.nix`
2. **Integration test**: `sudo nixos-rebuild test --flake .#hostname`
3. If good: `sudo nixos-rebuild switch --flake .#hostname` (MANUAL STEP - never run automatically)
4. If bad: `sudo nixos-rebuild switch --rollback`

**IMPORTANT: Never run `sudo nixos-rebuild switch` commands automatically. These must be executed manually by the user after verifying changes.**

## Common Tasks

### Add New Host
1. Copy an existing host as template:
```bash
cd ~/.dotfiles
cp -r hosts/terra hosts/newhostname
```

2. Edit settings:
```bash
vim hosts/newhostname/settings.nix
# Update: hostname, arch, user, timezone, locale, etc.
```

3. Copy hardware configuration:
```bash
sudo cp /etc/nixos/hardware-configuration.nix hosts/newhostname/
```

4. Configure module groups:
```bash
vim hosts/newhostname/home.nix
# Choose which module groups to load
```

5. Apply:
```bash
sudo nixos-rebuild switch --flake .#newhostname
```

Flake auto-discovers the new host. No flake.nix editing needed.

### Add New User
1. Create user directory:
```bash
mkdir -p home/newuser
```

2. Create settings:
```bash
cat > home/newuser/settings.nix <<EOF
{
    username = "newuser";
    name = "Full Name";
}
EOF
```

3. Copy default.nix from existing user:
```bash
cp home/redman/default.nix home/newuser/default.nix
```

4. Edit as needed:
```bash
vim home/newuser/default.nix
```

Flake auto-discovers the new user on next rebuild.

### Add Package
**System-wide (via modules):**
Edit or create a module in `hosts/_modules/`:
```nix
# hosts/_modules/core.nix (or create custom module)
{ config, lib, pkgs, ... }:

{
    environment.systemPackages = with pkgs; [
        package-name
    ];
}
```

**User-specific (preferred):**
Create or edit a module in `home/username/`:
```nix
{ config, lib, pkgs, ... }:

{
    home.packages = with pkgs; [
        package-name
    ];
}
```

Then import it in `home/username/default.nix`:
```nix
imports = [
    ./module-name.nix
];
```

**Stable version:**
```nix
pkgs-stable.package-name
```

**Using programs options (preferred when available):**
```nix
programs.ghostty = {
    enable = true;
    settings = { ... };
};
```



## Important Files

### flake.nix
- Auto-discovers hosts and users
- Defines package inputs (unstable + stable)
- Creates `nixosConfigurations` and `homeConfigurations`
- Do NOT manually add host/user entries (auto-discovery handles it)

### bootstrap
- Bash script for initial system setup
- Clones repo to `~/.dotfiles`
- Provides instructions for manual configuration setup

## Documentation

All documentation is in `docs/`:
- `BOOTSTRAP.md` - Bootstrap scenarios and workflows
- `PACKAGES.md` - Package management (stable vs unstable)
- `DAILY-USAGE.md` - Common commands and operations
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
3. Copy an existing host as base for new configs
4. LUKS configuration belongs in hardware-configuration.nix, NOT configuration.nix
5. Keep system packages minimal - prefer user-specific packages in home-manager
6. Use modular configuration - separate concerns into individual modules in `hosts/_modules/`
7. Each host's `configuration.nix` imports necessary modules from `hosts/_modules/`
8. Create custom system modules in `hosts/_modules/` for reusable system-level configuration
9. Each host's `home.nix` specifies which home module groups to load

### User Configuration Best Practices
1. Create separate module files for different applications (e.g., ghostty.nix, dolphin.nix)
2. Import all modules in `home/username/default.nix`
3. Use `programs.<app>` options when available instead of raw config files
4. Keep `home.packages` separate from program configurations
5. Polkit agent runs in home-manager, but `security.polkit.enable` must be set at system level

### Bootstrap Best Practices
- Bootstrap provides setup instructions, does not automate configuration creation
- Hardware config must be copied manually after cloning repository
- Hardware config must be regenerated on any fresh install (LUKS UUIDs change)
- Copy an existing host as template for new configurations

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

## Current Configuration

### Active Host: terra
- System: NixOS unstable
- Desktop: Hyprland (wayland)
- Shell: zsh
- Browser: Zen Browser
- Packages: home-manager, curl, git, wget, neovim, pciutils, usbutils, file

### Active User: redman
- Terminal: Ghostty (with catppuccin-mocha theme)
- File Manager: Nautilus
- App Launcher: Walker
- Polkit Agent: KDE polkit-kde-agent-1
- Font: CaskaydiaCove Nerd Font
- Shell aliases: la, ..
- Additional tools: tmux, yazi, starship, syncthing

### Module Structure

System module groups in hosts/_modules/:
- `core/` - Essential modules (boot loader, environment, locale, nix settings, networking, programs, services, stylix, users, etc.)
- `android/` - Android tools (udev rules, adb, fastboot)
- `nvidia/` - NVIDIA GPU configuration
- `printing/` - Printing support
- `virtual_camera/` - Virtual camera (v4l2loopback)

Home module groups in home/_modules/:
- `core/` - Essential (shell, waybar, ghostty, git, hyprland, neovim, polkit, ssh, starship, syncthing, terminal, tmux, vlc, walker, xdg, yazi, zen-browser, etc.)
- `comms/` - Communication (vesktop)
- `dev/` - Development (opencode)
- `gamedev/` - Game development (aseprite, godot, inkscape)
- `notes/` - Note-taking (logseq, obsidian)
- `office/` - Office (libreoffice, sparrow)
- `streaming/` - Streaming (obs-studio)

## Notes for AI Assistants

- This configuration uses auto-discovery - don't manually edit flake.nix for new hosts/users
- Settings are in separate `settings.nix` files, not hardcoded in configs
- `pkgs-stable` is available everywhere via specialArgs/extraSpecialArgs
- Bootstrap provides setup instructions, does not automate configuration creation
- Documentation is comprehensive - refer users to `docs/` for detailed info
- Always test changes before committing
- Repository location is `~/.dotfiles` (not `/etc/nixos`)
- Prefer modular configurations - one application per .nix file in home/username/
- Use `programs.<app>` options when available rather than raw config files
- Keep system packages minimal, put user-specific packages in home-manager
- XDG portals: both hyprland and gtk portals are configured for compatibility
- **Shell aliases available after bootstrap:** `nrh` (rebuild host), `nup` (update flake), `nru` (rebuild user - legacy)
- **IMPORTANT: NEVER run nixos-rebuild, home-manager, sudo, or nix commands** - you are not running on the target NixOS system and these commands are not available. Only edit configuration files and let the user apply changes manually. `nixos-rebuild switch` is always a manual step.

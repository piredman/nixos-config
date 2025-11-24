# Advanced Topics

Advanced configuration techniques and customization for power users.

## Host Modules Pattern

The host configuration uses a modular pattern similar to `home/_modules/`. System-wide configuration is split into focused modules that are imported by each host's `configuration.nix`.

### Available Host Modules

```
hosts/_modules/
├── core.nix           # Boot, environment, locale, nix settings
├── fileSystems.nix    # File system mounts
├── networking.nix     # Network configuration
├── nvidia.nix         # NVIDIA GPU configuration
├── programs.nix       # System programs
├── services.nix       # System services
├── stylix.nix         # System theming
└── users.nix         # User accounts
```

### Host Configuration Structure

Each host imports only the modules it needs:

```nix
# hosts/hostname/configuration.nix
{ config, lib, pkgs, pkgs-stable, systemSettings, userSettings, ... }:

{
    imports = [
        ./hardware-configuration.nix
        ../_modules/core.nix
        ../_modules/fileSystems.nix
        ../_modules/networking.nix
        ../_modules/programs.nix
        ../_modules/services.nix
        ../_modules/stylix.nix
        ../_modules/users.nix
    ];

    system.stateVersion = "25.05";
}
```

### Creating a New Host

To add a new host, copy an existing host and customize it:

```bash
cd ~/.dotfiles

# Copy an existing host as template
cp -r hosts/terra hosts/newhost
```

Edit `hosts/newhost/settings.nix`:

```nix
{
    hostname = "newhost";
    arch = "x86_64-linux";              # or "aarch64-linux"
    user = "username";
    timezone = "America/Edmonton";
    locale = "en_GB.UTF-8";
    luks.device = "/dev/disk/by-uuid/...";  # If using encryption
    nas = import ../_settings/nas.nix;       # If using NAS
    monitors = {                              # Monitor setup
        primary = "DP-1";
        secondary = "DP-2";
        setup = [ "DP-1,2560x1440@60,0x0,1" ];
    };
}
```

Copy hardware configuration:

```bash
sudo cp /etc/nixos/hardware-configuration.nix hosts/newhost/
```

Configure module groups in `hosts/newhost/home.nix`:

```nix
let
  moduleGroups = [ 
    "core"      # Essential
    "dev"       # Development tools
    # Add other groups as needed
  ];
  # ... rest of file
```

### Customizing Host Modules

Modules can be customized per-host by using `lib.mkForce` to override settings:

```nix
# hosts/hostname/configuration.nix
{ config, lib, pkgs, ... }:

{
    imports = [ /* ... modules ... */ ];

    # Override settings from modules
    services.openssh.enable = lib.mkForce false;
    environment.systemPackages = lib.mkForce (with pkgs; [ vim git ]);
}
```

### Creating Custom Host Modules

Create a new module in `hosts/_modules/mymodule.nix`:

```nix
{ config, lib, pkgs, ... }:

{
    services.myservice = {
        enable = true;
        port = 8080;
    };

    environment.systemPackages = with pkgs; [
        myapp
    ];
}
```

Then import it in any host's `configuration.nix`:

```nix
{
    imports = [
        ../_modules/mymodule.nix
    ];
}
```

## Creating a New Host Configuration

The recommended way to create a new host is to copy an existing one and customize it.

### Step 1: Choose a Template Host

Pick an existing host similar to your new system:

```bash
cd ~/.dotfiles
ls -la hosts/
# terra  - Full workstation with GPU
# mini   - Standard desktop
# luna   - Minimal setup
```

### Step 2: Copy Host Directory

```bash
cp -r hosts/terra hosts/newhostname
```

This copies:
- configuration.nix
- settings.nix  
- home.nix
- hardware-configuration.nix (will be replaced)

### Step 3: Customize settings.nix

Edit `hosts/newhostname/settings.nix`:

```nix
{
    hostname = "newhostname";
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
```

### Step 4: Copy Hardware Configuration

```bash
sudo cp /etc/nixos/hardware-configuration.nix hosts/newhostname/
```

### Step 5: Configure Module Groups

Edit `hosts/newhostname/home.nix` to choose which applications to install:

```nix
let
  moduleGroups = [ 
    "core"      # Essential (always include)
    "dev"       # Development tools
    "notes"     # Note-taking apps
    # "comms"   # Communication tools
    # "gamedev" # Game development
    # "office"  # Office applications
    # "streaming" # Streaming tools
  ];
  # ... rest of file
```

### Step 6: Create User Configuration (if needed)

If this is a new user, create their configuration:

```bash
mkdir -p home/newuser

# Create settings
cat > home/newuser/settings.nix <<EOF
{
    username = "newuser";
    name = "Full Name";
}
EOF

# Copy default.nix from existing user
cp home/redman/default.nix home/newuser/default.nix
```

### Step 7: Apply Configuration

```bash
sudo nixos-rebuild switch --flake .#newhostname
```

The home-manager configuration is applied automatically as part of the system configuration.

## Understanding Flake Auto-Discovery

### How It Works

The flake uses Nix builtins to discover configurations:

```nix
# From flake.nix
hostDirs = builtins.attrNames (
  lib.filterAttrs (name: type: type == "directory" && !lib.hasPrefix "_" name) (
    builtins.readDir ./hosts
  )
);
```

**What this does:**
1. Reads all directories in `hosts/`
2. Filters out directories starting with `_` (like `_modules`, `_settings`)
3. Creates a nixosConfiguration for each remaining directory
4. Uses the hostname from `settings.nix` as the configuration name

### Adding a Host Without Rebuilding Flake

Simply create the directory structure:

```bash
mkdir hosts/newhost
# Add files...
```

The flake automatically discovers it on next rebuild. No flake.nix editing needed.

### Excluding a Host Temporarily

Rename directory to start with `_`:

```bash
mv hosts/oldhost hosts/_oldhost  # Excluded from auto-discovery
```

## Dynamic Module Groups System

The configuration uses a dynamic module group system that allows each host to specify which categories of modules to load. This provides flexibility while maintaining organization.

### Module Group Structure

```
home/_modules/
├── default.nix        # Dynamic import helper functions
├── core/             # Essential modules (loaded by all hosts)
│   ├── shell/
│   ├── waybar/
│   ├── ghostty.nix
│   ├── git.nix
│   ├── hyprland.nix
│   └── ... (core functionality)
├── comms/            # Communication tools (optional)
│   └── vesktop.nix
├── dev/              # Development tools (optional)
│   └── opencode.nix
├── gamedev/          # Game development (optional)
│   └── godot.nix
├── notes/            # Note-taking apps (optional)
│   ├── logseq.nix
│   └── obsidian.nix
└── office/           # Office applications (optional)
    ├── libreoffice.nix
    └── sparrow.nix
```

### Host Module Group Configuration

Each host specifies which module groups to load in its `hosts/hostname/home.nix`:

```nix
# hosts/hostname/home.nix
{ config, pkgs, userSettings, lib, ... }:

let
  # Specify module groups for this host
  moduleGroups = [ "core" "dev" "notes" ];  # Customize per host
  
  # Import helper function and generate module list
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
    packages = with pkgs; [ starship ];
  };
}
```

### Per-Host Module Customization Examples

**Minimal Host (mini):**
```nix
moduleGroups = [ "core" ];  # Only essential functionality
```

**Development Host (luna):**
```nix
moduleGroups = [ "core" "dev" "gamedev" ];  # Core + development tools
```

**Full Workstation (terra):**
```nix
moduleGroups = [ "core" "dev" "notes" "office" "comms" "gamedev" ];  # Everything
```

### User Configuration Structure

User configurations remain clean and focused on user-specific settings:

```nix
# home/username/default.nix
{
  config,
  lib,
  pkgs,
  pkgs-stable,
  userSettings,
  ...
}:

{
  # Module imports are handled by the host configuration
  # This keeps user config clean and focused on user-specific settings

  fonts.fontconfig.enable = true;

  home = {
    username = userSettings.username;
    homeDirectory = "/home/" + userSettings.username;
    stateVersion = "25.05";

    packages = [ ];
    file = { };
    sessionVariables = { };
  };

  programs.home-manager.enable = true;
}
```

### Adding New Module Groups

1. **Create the group directory:**
   ```bash
   mkdir home/_modules/mygroup
   ```

2. **Add modules to the group:**
   ```bash
   # Create module files in the group
   touch home/_modules/mygroup/myapp.nix
   ```

3. **Use in host configurations:**
   ```nix
   moduleGroups = [ "core" "mygroup" ];
   ```

### Adding Modules to Existing Groups

Simply add `.nix` files to the appropriate group directory:

```bash
# Add new core module
vim home/_modules/core/newapp.nix

# Add new development tool
vim home/_modules/dev/newtool.nix
```

The dynamic import system will automatically discover and include them.

### Underscore Naming Convention

The system uses an underscore prefix convention to distinguish between modules and support files:

**Module Files** (imported automatically):
- `myapp.nix` - Proper modules that configure applications
- `shell.nix` - Main shell module
- `waybar.nix` - Main waybar module

**Support Files** (excluded from import, prefixed with `_`):
- `_aliases.nix` - Alias definitions imported by shell modules
- `_bash.nix` - Bash-specific configuration imported by shell.nix
- `_zsh.nix` - Zsh-specific configuration imported by shell.nix
- `_functions.zsh` - Shell functions sourced by zsh
- `_waybar.css` - Stylesheet read by waybar module

**Benefits of This Convention:**
1. **Self-Documenting:** Immediately clear which files are modules vs support files
2. **Maintainable:** No hardcoded exclusion lists to maintain
3. **Automatic:** The helper function automatically excludes `_*` files
4. **Flexible:** Easy to add new support files without code changes

**Example Structure:**
```
home/_modules/core/
├── shell/
│   ├── shell.nix       # Main module (imported)
│   ├── _bash.nix       # Support file (imported by shell.nix)
│   ├── _zsh.nix        # Support file (imported by shell.nix)
│   ├── _aliases.nix    # Data file (imported by _bash.nix and _zsh.nix)
│   └── _functions.zsh  # Script file (sourced by _zsh.nix)
├── waybar/
│   ├── waybar.nix      # Main module (imported)
│   └── _waybar.css     # Stylesheet (read by waybar.nix)
└── myapp.nix           # Simple module (imported)
```

### Benefits of Module Groups

1. **Host-Specific Functionality:** Each host loads only what it needs
2. **Automatic Discovery:** No manual import lists to maintain
3. **Organized by Purpose:** Modules grouped by functionality
4. **Scalable:** Easy to add new modules and groups
5. **Clean User Configs:** User configs focus on user-specific settings

## Legacy Shared Modules Pattern

**Note:** The dynamic module groups system has replaced the previous shared modules pattern. The old documentation is preserved below for reference.

The previous configuration used a centralized `home/_modules/` directory containing shared modules imported by all users:

```
home/_modules/
├── shell/
├── waybar/
├── dolphin.nix
├── ghostty.nix
├── git.nix
├── hyprland.nix
├── polkit.nix
├── starship.nix
└── ... (other modules)
```

### Legacy User Configuration Structure

Each user previously imported these shared modules:

```nix
# home/username/default.nix (old pattern)
{
    imports = [
        ../modules/shell/shell.nix
        ../modules/ghostty.nix
        ../modules/git.nix
        # ... other shared modules
    ];

    home.username = userSettings.username;
    home.homeDirectory = "/home/" + userSettings.username;
    home.stateVersion = "25.05";

    # User-specific packages or overrides
    home.packages = with pkgs; [ ];

    programs.home-manager.enable = true;
}
```

### Creating a New User

To add a new user, create a directory and import desired shared modules:

```bash
mkdir home/newuser
```

Create `home/newuser/default.nix`:

```nix
{ config, lib, pkgs, pkgs-stable, userSettings, ... }:

{
    imports = [
        ../modules/shell/shell.nix
        ../modules/git.nix
        # Include other modules your user needs
    ];

    home.username = userSettings.username;
    home.homeDirectory = "/home/" + userSettings.username;
    home.stateVersion = "25.05";

    home.packages = with pkgs; [ ];

    programs.home-manager.enable = true;
}
```

Create `home/newuser/settings.nix`:

```nix
{
    username = "newuser";
    name = "Full Name";
}
```

## Multi-User Setup

### Different Users on Same Host

Add multiple home configurations:

```bash
mkdir home/alice
mkdir home/bob
```

Each user imports shared modules but can customize:

```nix
# home/alice/default.nix
{
    fonts.fontconfig.enable = true;

    home = {
        username = userSettings.username;
        homeDirectory = "/home/" + userSettings.username;
        stateVersion = "25.05";

        packages = with pkgs; [ vscode python3 ];
        file = { };
        sessionVariables = { };
    };

    programs.home-manager.enable = true;
}

# home/bob/default.nix  
{
    fonts.fontconfig.enable = true;

    home = {
        username = userSettings.username;
        homeDirectory = "/home/" + userSettings.username;
        stateVersion = "25.05";

        packages = with pkgs; [ vim rust ];
        file = { };
        sessionVariables = { };
    };

    programs.home-manager.enable = true;
}
```

Module loading is controlled per-host in `hosts/hostname/home.nix`, not per-user.
Users get the modules specified by their host's configuration.
User-specific packages and settings go in the user's `default.nix`.

### System-Wide vs User-Specific Packages

**System packages** (available to all users):

```nix
# hosts/hostname/configuration.nix
environment.systemPackages = with pkgs; [
    git
    neovim
    htop
];
```

**User packages** (only for specific user):

```nix
# home/username/default.nix
home.packages = with pkgs; [
    vscode
    discord
];
```

## Adding Modules to home/_modules/

### Creating a Shared Module

Create a new module in `home/_modules/core/myapp.nix` (or appropriate group):

```nix
{ config, lib, pkgs, ... }:

{
    home.packages = with pkgs; [
        myapp
    ];

    xdg.configFile."myapp/config.yaml".text = ''
        setting1: value1
        setting2: value2
    '';
}
```

The module will be automatically discovered and loaded by any host that includes the `core` module group.

### Using Programs Options

Prefer `programs.<app>` when available:

```nix
{ config, lib, pkgs, ... }:

{
    programs.ghostty = {
        enable = true;
        settings = {
            theme = "catppuccin-mocha";
            font-family = "CaskaydiaCove Nerd Font";
            font-size = 12;
        };
    };
}
```

This is better than manual config files because:
- Type checking
- Option documentation
- Proper dependency management
- Automatic package installation

### Module Examples

Look at existing modules for patterns:
- `home/_modules/core/shell/shell.nix` - Shell configuration
- `home/_modules/core/ghostty.nix` - Terminal emulator
- `home/_modules/core/git.nix` - Git configuration
- `home/_modules/core/hyprland.nix` - Window manager

## Custom System Modules

System modules in `hosts/_modules/` provide reusable configuration across all hosts. You can create new modules or modify existing ones.

### Creating a Custom Module

Create `hosts/_modules/my-service.nix`:

```nix
{ config, lib, pkgs, ... }:

{
    services.myservice = {
        enable = true;
        port = 8080;
    };

    environment.systemPackages = with pkgs; [
        myapp
    ];
}
```

### Using Custom Modules

Import in host configuration:

```nix
# hosts/hostname/configuration.nix
{
    imports = [
        ./hardware-configuration.nix
        ../_modules/my-service.nix
    ];

    system.stateVersion = "25.05";
}
```

### Existing Host Modules

Reference the existing modules for patterns:
- `hosts/_modules/core.nix` - Boot, environment, locale, nix settings
- `hosts/_modules/fileSystems.nix` - File system mounts
- `hosts/_modules/networking.nix` - Network configuration
- `hosts/_modules/nvidia.nix` - NVIDIA GPU configuration
- `hosts/_modules/programs.nix` - System programs
- `hosts/_modules/services.nix` - System services
- `hosts/_modules/stylix.nix` - System theming
- `hosts/_modules/users.nix` - User accounts

## Overlays and Overrides

### Creating an Overlay

Create `overlays/default.nix`:

```nix
final: prev: {
    # Override package
    myPackage = prev.myPackage.overrideAttrs (old: {
        version = "custom";
    });
    
    # Add custom package
    customTool = prev.callPackage ./custom-tool.nix { };
}
```

### Using Overlays

In flake.nix, add to nixpkgs config:

```nix
pkgs = import nixpkgs {
    inherit system;
    overlays = [ (import ./overlays/default.nix) ];
};
```

## Secrets Management

### Using sops-nix

Add to flake inputs:

```nix
inputs.sops-nix.url = "github:Mic92/sops-nix";
```

Import in configuration:

```nix
imports = [ inputs.sops-nix.nixosModules.sops ];

sops.defaultSopsFile = ./secrets.yaml;
sops.secrets.example-key = { };
```

### Using agenix

Alternative secrets management with age:

```nix
inputs.agenix.url = "github:ryantm/agenix";
```

## Development Workflow

### Using Direnv

Create `.envrc` in project root:

```bash
use flake
```

Automatically loads development environment when entering directory.

### Development Shells

Add to flake.nix:

```nix
devShells.${system}.default = pkgs.mkShell {
    buildInputs = with pkgs; [
        nixpkgs-fmt
        nil  # Nix LSP
    ];
};
```

Enter shell:

```bash
nix develop
```

## Debugging

### Check Flake Outputs

```bash
nix flake show
```

### Evaluate Configuration

```bash
nix eval .#nixosConfigurations.mini.config.system.build.toplevel
```

### Trace Configuration

```bash
sudo nixos-rebuild switch --flake .#mini --show-trace
```

### Debug Specific Option

```bash
nix eval .#nixosConfigurations.mini.config.environment.systemPackages
```

## Building for Different Architectures

### Cross-Compilation

Build for ARM64 from x86_64:

```nix
nixosConfigurations.pi = nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    modules = [ ./hosts/pi/configuration.nix ];
};
```

### Remote Builds

Configure remote builders in `configuration.nix`:

```nix
nix.buildMachines = [{
    hostName = "builder.example.com";
    system = "x86_64-linux";
    maxJobs = 4;
    speedFactor = 2;
    supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
}];
```

## Performance Optimization

### Parallel Builds

```nix
nix.settings = {
    max-jobs = "auto";
    cores = 4;
};
```

### Binary Cache

Use Cachix for faster builds:

```nix
nix.settings = {
    substituters = [
        "https://cache.nixos.org"
        "https://your-cache.cachix.org"
    ];
    trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "your-cache.cachix.org-1:..."
    ];
};
```

### Sandboxing

Enable sandboxed builds for reproducibility:

```nix
nix.settings.sandbox = true;
```

## Custom ISO Creation

### Build Installation ISO

Create `iso.nix`:

```nix
{ config, pkgs, ... }:

{
    imports = [
        <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
    ];

    # Add your customizations
    environment.systemPackages = with pkgs; [
        git
        vim
    ];
}
```

Build:

```bash
nix build .#nixosConfigurations.iso.config.system.build.isoImage
```

## Advanced Flake Features

### Multiple System Types

```nix
outputs = { self, nixpkgs, ... }:
    let
        forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ];
    in {
        nixosConfigurations = {
            # x86_64 host
            desktop = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                modules = [ ./hosts/desktop/configuration.nix ];
            };
            
            # ARM host
            pi = nixpkgs.lib.nixosSystem {
                system = "aarch64-linux";
                modules = [ ./hosts/pi/configuration.nix ];
            };
        };
    };
```

### Flake Checks

Add tests:

```nix
checks.${system} = {
    format = pkgs.runCommand "check-format" {} ''
        ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt --check ${./.}
        touch $out
    '';
};
```

Run checks:

```bash
nix flake check
```

## See Also

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Pills](https://nixos.org/guides/nix-pills/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nixpkgs Manual](https://nixos.org/manual/nixpkgs/stable/)

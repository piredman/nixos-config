# Advanced Topics

Advanced configuration techniques and customization for power users.

## Manual Host Configuration

If you prefer not to use the `setup-host.sh` script, you can create configurations manually.

### Create Host Directory

```bash
mkdir -p hosts/newhostname
```

### Generate Hardware Configuration

```bash
sudo nixos-generate-config --show-hardware-config > hosts/newhostname/hardware-configuration.nix
```

Or copy from existing:

```bash
sudo cp /etc/nixos/hardware-configuration.nix hosts/newhostname/
```

### Create Configuration File

Copy and customize the template:

```bash
cp hosts/template/configuration.nix hosts/newhostname/configuration.nix
vim hosts/newhostname/configuration.nix
```

### Create Settings File

Create `hosts/newhostname/settings.nix`:

```nix
{
    hostname = "newhostname";
    timezone = "America/Edmonton";
    local = "en_GB.UTF-8";
}
```

### Create Home Configuration

```bash
mkdir -p home/newuser
cp home/template/default.nix home/newuser/default.nix
```

Create `home/newuser/settings.nix`:

```nix
{
    username = "newuser";
    name = "Full Name";
}
```

### Apply Configuration

```bash
sudo nixos-rebuild switch --flake .#newhostname
home-manager switch --flake .#newuser
```

## Understanding Flake Auto-Discovery

### How It Works

The flake uses Nix builtins to discover configurations:

```nix
# From flake.nix
hosts = builtins.attrNames (builtins.readDir ./hosts);
validHosts = builtins.filter (name: name != "template") hosts;

homeDirs = builtins.attrNames (builtins.readDir ./home);
validUsers = builtins.filter (name: name != "template") homeDirs;
```

**What this does:**
1. Reads all directories in `hosts/` and `home/`
2. Filters out `template` directories
3. Creates configurations for each remaining directory

### Adding a Host Without Rebuilding Flake

Simply create the directory structure:

```bash
mkdir hosts/newhost
# Add files...
```

The flake automatically discovers it on next rebuild. No flake.nix editing needed.

### Excluding a Host Temporarily

Rename directory to include `template` or start with `.`:

```bash
mv hosts/oldhost hosts/.oldhost  # Hidden, won't be discovered
mv hosts/oldhost hosts/oldhost-template  # Contains 'template', excluded
```

## Customizing Templates

### Modify Host Template

Edit `hosts/template/configuration.nix` to change defaults for all new hosts:

```nix
{ config, lib, pkgs, pkgs-stable, systemSettings, userSettings, ... }:

{
    imports = [ ./hardware-configuration.nix ../../common/default.nix ];

    # Your default packages for all new hosts
    environment.systemPackages = with pkgs; [
        neovim
        git
        htop
        curl
        wget
        # Add more defaults...
    ];

    # Your default services
    services.openssh.enable = true;
    
    # etc...
}
```

### Modify User Template

Edit `home/template/default.nix`:

```nix
{ config, pkgs, pkgs-stable, userSettings, ... }:

{
    imports = [ ];

    home.username = userSettings.username;
    home.homeDirectory = "/home/" + userSettings.username;
    home.stateVersion = "25.05";

    # Your default packages for all new users
    home.packages = with pkgs; [
        firefox
        discord
        # Add more defaults...
    ];

    programs.git = {
        enable = true;
        userName = userSettings.name;
        userEmail = "user@example.com";  # Change default email
        extraConfig = {
            init.defaultBranch = "main";
            safe.directory = "/home/" + userSettings.username + "/.dotfiles";
        };
    };

    programs.home-manager.enable = true;
}
```

## Multi-User Setup

### Different Users on Same Host

Add multiple home configurations:

```bash
mkdir home/alice
mkdir home/bob
```

Each user can have different configurations:

```nix
# home/alice/default.nix
home.packages = with pkgs; [ vscode python3 ];

# home/bob/default.nix  
home.packages = with pkgs; [ vim rust ];
```

Apply per user:

```bash
# Alice's configuration
home-manager switch --flake .#alice

# Bob's configuration
home-manager switch --flake .#bob
```

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

## Custom Modules

### Creating a Module

Create `modules/my-service.nix`:

```nix
{ config, lib, pkgs, ... }:

with lib;

{
    options.services.myService = {
        enable = mkEnableOption "My custom service";
        
        port = mkOption {
            type = types.int;
            default = 8080;
            description = "Port to listen on";
        };
    };

    config = mkIf config.services.myService.enable {
        # Service configuration here
    };
}
```

### Using Custom Modules

Import in host configuration:

```nix
# hosts/hostname/configuration.nix
{
    imports = [
        ./hardware-configuration.nix
        ../../common/default.nix
        ../../modules/my-service.nix
    ];

    services.myService = {
        enable = true;
        port = 9000;
    };
}
```

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

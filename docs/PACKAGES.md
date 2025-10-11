# Package Management

This configuration uses **nixos-unstable** (rolling release) as the default, with **nixos-stable** (25.05) available as a fallback for packages that need it.

## Overview

The configuration provides two package sets:

- **`pkgs`** - NixOS unstable (default)
- **`pkgs-stable`** - NixOS 25.05 (stable fallback)

Both are available in all configuration files (system and home).

## Using Unstable Packages (Default)

By default, all packages come from the unstable channel, giving you the latest versions.

### System Packages

In `hosts/<hostname>/configuration.nix`:

```nix
environment.systemPackages = with pkgs; [
  firefox    # Latest version from unstable
  neovim     # Latest version from unstable
  git        # Latest version from unstable
  kitty      # Latest version from unstable
];
```

### Home Manager Packages

In `home/<username>/default.nix`:

```nix
home.packages = with pkgs; [
  discord    # Latest version from unstable
  vscode     # Latest version from unstable
  spotify    # Latest version from unstable
];
```

## Using Stable Packages (Fallback)

When you need a stable version of a package, use `pkgs-stable`:

### System Packages

```nix
environment.systemPackages = with pkgs; [
  firefox    # unstable
  neovim     # unstable
] ++ [
  pkgs-stable.vlc        # Use stable version
  pkgs-stable.obs-studio # Use stable version
];
```

### Home Manager Packages

```nix
home.packages = with pkgs; [
  discord    # unstable
] ++ [
  pkgs-stable.zoom-us    # Use stable version
  pkgs-stable.slack      # Use stable version
];
```

## When to Use Stable

Consider using the stable version when:

### Package is Broken in Unstable

Sometimes the latest version has bugs or build issues:

```nix
environment.systemPackages = with pkgs; [
  # Use stable version if unstable is broken
  pkgs-stable.some-package
];
```

### You Need a Specific Version

For compatibility with other software or workflows:

```nix
home.packages = with pkgs; [
  # Keep older stable version for compatibility
  pkgs-stable.nodejs
  pkgs-stable.python3
];
```

### Critical Production Software

For servers or critical workstations where stability matters:

```nix
environment.systemPackages = with pkgs; [
  pkgs-stable.nginx      # Production web server
  pkgs-stable.postgresql # Production database
  pkgs-stable.docker     # Container runtime
];
```

## Mixed Configuration Example

Real-world example mixing unstable and stable:

```nix
{ config, lib, pkgs, pkgs-stable, systemSettings, userSettings, ... }:

{
  environment.systemPackages = with pkgs; [
    # Development tools - latest from unstable
    neovim
    git
    ripgrep
    fd
    
    # Shell and terminal - unstable
    zsh
    kitty
    tmux
    
  ] ++ [
    # Stable versions for compatibility
    pkgs-stable.firefox       # Stable browser for work
    pkgs-stable.libreoffice   # Document compatibility
    pkgs-stable.zoom-us       # Business critical
  ];
}
```

## Searching for Packages

### Search Unstable Packages

```bash
nix search nixpkgs firefox
```

### Search Stable Packages

```bash
nix search nixpkgs#nixos-25.05 firefox
```

### Online Search

Visit [search.nixos.org](https://search.nixos.org/packages) and select the channel (unstable or 25.05).

## Checking Package Versions

### Check Installed Version

```bash
nix-env -q firefox
```

### Check Available Version

```bash
nix eval nixpkgs#firefox.version
nix eval nixpkgs#nixos-25.05.firefox.version
```

## Updating Packages

### Update All Packages

Updates both unstable and stable channels:

```bash
nix flake update
sudo nixos-rebuild switch --flake .#<hostname>
```

### Update Specific Input

Update only unstable:

```bash
nix flake lock --update-input nixpkgs
```

Update only stable:

```bash
nix flake lock --update-input nixpkgs-stable
```

## Best Practices

### Start with Unstable

Default to unstable packages unless you have a specific reason to use stable:

```nix
# Good: Use unstable by default
environment.systemPackages = with pkgs; [
  package1
  package2
];

# Only add stable when needed
environment.systemPackages = with pkgs; [
  package1
] ++ [
  pkgs-stable.package2  # Has a good reason
];
```

### Document Why You Use Stable

Add comments when using stable versions:

```nix
environment.systemPackages = with pkgs; [
  firefox
] ++ [
  # Use stable: unstable version crashes on startup (as of 2025-10-11)
  pkgs-stable.obs-studio
  
  # Use stable: required for work compatibility
  pkgs-stable.zoom-us
];
```

### Test After Updates

After updating packages, test critical functionality:

```bash
nix flake update
sudo nixos-rebuild switch --flake .#<hostname>

# Test critical applications
firefox --version
obs --version
```

If something breaks, you can roll back (see [Daily Usage](DAILY-USAGE.md)).

## Rolling Release vs Stable

### Understanding the Trade-offs

**Unstable (Rolling Release):**
- ✅ Latest features and bug fixes
- ✅ Newest software versions
- ✅ Security updates faster
- ⚠️ Occasionally breaking changes
- ⚠️ May have temporary build issues

**Stable (25.05):**
- ✅ Thoroughly tested
- ✅ Predictable behavior
- ✅ Less frequent breaking changes
- ⚠️ Older software versions
- ⚠️ Security updates slower (but still backported)

### This Configuration Gives You Both

The beauty of this setup: you get the best of both worlds.

```nix
# Latest development tools
pkgs.neovim
pkgs.rust

# Stable production software
pkgs-stable.postgresql
pkgs-stable.nginx
```

## See Also

- [Daily Usage](DAILY-USAGE.md) - Updating and managing packages
- [Advanced Topics](ADVANCED.md) - Custom package overlays
- [NixOS Manual](https://nixos.org/manual/nixos/stable/) - Official documentation

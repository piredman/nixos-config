# Bootstrap Guide

This guide covers all scenarios for bootstrapping and deploying your NixOS configuration.

## Bootstrap Command

On a fresh NixOS install, run this single command:

```bash
nix-shell -p curl git --run "bash <(curl -fsSL https://raw.githubusercontent.com/piredman/nixos-config/master/bootstrap)"
```

## What Bootstrap Does

The bootstrap script:

1. Auto-detects your hostname and username (with interactive prompts)
2. Clones this repository to `~/.dotfiles`
3. Provides instructions for manual configuration setup
4. Guides you to create host configuration by copying an existing host

## Interactive Prompts

You'll be prompted for:

- **Hostname** (defaults to current system hostname from `hostname`)
- **Username** (defaults to current user from `$USER`)
- **Full name** (required, no default)
- **Timezone** (defaults to `/etc/timezone` or `America/Edmonton`)
- **Locale** (defaults to `$LANG` or `en_GB.UTF-8`)

Note: These values are collected for reference in the setup instructions. You'll need to manually create configuration files following the guide below.

## Manual Configuration Setup

After bootstrap clones the repository, you need to manually create your host configuration:

### Step 1: Copy Existing Host

Choose an existing host as your starting point:

```bash
cd ~/.dotfiles
ls hosts/  # See available hosts: terra, mini, luna

# Copy the one most similar to your setup
cp -r hosts/terra hosts/YOUR_HOSTNAME
```

### Step 2: Create settings.nix

Edit `hosts/YOUR_HOSTNAME/settings.nix`:

```nix
{
  hostname = "YOUR_HOSTNAME";
  arch = "x86_64-linux";              # or "aarch64-linux"
  user = "YOUR_USERNAME";
  timezone = "America/Edmonton";       # Your timezone
  locale = "en_GB.UTF-8";             # Your locale
  luks.device = "/dev/disk/by-uuid/...";  # If using encryption (optional)
  nas = import ../_settings/nas.nix;       # If using NAS (optional)
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

### Step 3: Copy Hardware Configuration

```bash
sudo cp /etc/nixos/hardware-configuration.nix hosts/YOUR_HOSTNAME/
```

### Step 4: Configure home.nix

Edit `hosts/YOUR_HOSTNAME/home.nix` to choose which module groups to load:

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

Available module groups:
- **core** - Essential (shell, git, hyprland, terminal, etc.) - Always include this
- **comms** - Communication tools (vesktop)
- **dev** - Development tools (opencode)
- **gamedev** - Game development (godot)
- **notes** - Note-taking apps (logseq, obsidian)
- **office** - Office applications (libreoffice, sparrow)
- **streaming** - Streaming tools (obs-studio)

### Step 5: Create User Configuration

If this is a new user, create their configuration:

```bash
mkdir -p home/YOUR_USERNAME

# Create settings
cat > home/YOUR_USERNAME/settings.nix <<EOF
{
  username = "YOUR_USERNAME";
  name = "Your Full Name";
}
EOF

# Create minimal default.nix
cat > home/YOUR_USERNAME/default.nix <<'EOF'
{ config, lib, pkgs, pkgs-stable, userSettings, ... }:

{
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
EOF
```

### Step 6: Apply Configuration

```bash
sudo nixos-rebuild switch --flake .#YOUR_HOSTNAME
```

If successful, your system is now configured! The home-manager configuration is applied automatically as part of the system configuration.

## Usage Scenarios

### Scenario 1: First-Time Bootstrap (New Host)

**When:** Installing NixOS on a machine for the first time, no configuration exists in git yet.

**What Happens:**

1. Bootstrap clones the repository to `~/.dotfiles`
2. Bootstrap provides setup instructions
3. You manually copy an existing host configuration
4. You customize the settings for your machine
5. You copy the hardware configuration
6. You apply the configuration

**Steps:**

Follow the [Manual Configuration Setup](#manual-configuration-setup) section above.

**Result:** New machine-specific configuration created and applied.

**Next Steps:**
- Test that everything works correctly
- Commit changes: `git add . && git commit -m "Add <hostname> configuration"`
- Push to remote: `git push`

---

### Scenario 2: Bootstrap Existing Host (Reinstall)

**When:** Reinstalling NixOS on a machine that already has configuration in the git repository.

**What Happens:**

1. Bootstrap clones the repository to `~/.dotfiles`
2. Finds existing `hosts/<hostname>/` configuration in git
3. You update the hardware configuration for the new install
4. You apply the existing configuration

**Steps:**

```bash
cd ~/.dotfiles

# Your host configuration already exists, but update hardware config
sudo cp /etc/nixos/hardware-configuration.nix hosts/<hostname>/

# If partition UUIDs changed, update settings.nix
vim hosts/<hostname>/settings.nix
# Update luks.device UUID if using encryption

# Apply configuration
sudo nixos-rebuild switch --flake .#<hostname>
```

**Result:** Your software configuration is restored with updated hardware config.

**Why hardware config must be updated:**
- Fresh install generates new disk UUIDs
- LUKS encryption creates new keys/UUIDs
- Partition layout may have changed
- Old hardware config would prevent system from booting

**Use Case:**
- Fresh reinstall of NixOS
- Migrating to new hardware with same hostname
- Disaster recovery

---

### Scenario 3: Pre-Configure Before Installation

**When:** You want to prepare configuration for a new machine before installing NixOS on it.

**How:**

```bash
# On your current system with repo cloned
cd ~/.dotfiles

# Copy an existing host as template
cp -r hosts/terra hosts/laptop

# Customize for the new machine
vim hosts/laptop/settings.nix
# Update: hostname, arch, user, timezone, locale, etc.

# Configure module groups
vim hosts/laptop/home.nix

# If new user, create their config
mkdir -p home/alice
cat > home/alice/settings.nix <<EOF
{
  username = "alice";
  name = "Alice Smith";
}
EOF

cp home/redman/default.nix home/alice/default.nix

# Commit and push
git add .
git commit -m "Add laptop configuration for Alice"
git push
```

**Later:** When you install NixOS on the laptop:
1. Clone the repository: `git clone <repo-url> ~/.dotfiles`
2. Copy hardware config: `sudo cp /etc/nixos/hardware-configuration.nix ~/.dotfiles/hosts/laptop/`
3. Apply: `cd ~/.dotfiles && sudo nixos-rebuild switch --flake .#laptop`

**Benefits:**
- Prepare configurations in advance
- Refine before physical installation
- Track all machine configs in git before deployment
- Only hardware config needed on actual install

---

### Scenario 4: Manually Add Host to Existing Setup

**When:** Adding another machine to your existing NixOS fleet.

**How:**

```bash
cd ~/.dotfiles

# Copy an existing host
cp -r hosts/terra hosts/desktop

# Customize the configuration
vim hosts/desktop/settings.nix
# Update: hostname, arch, user, monitors, etc.

vim hosts/desktop/home.nix
# Choose module groups for this host

# Commit and push
git add .
git commit -m "Add desktop host configuration"
git push
```

**Then on the new machine:**

```bash
# Clone repository
git clone https://github.com/piredman/nixos-config.git ~/.dotfiles
cd ~/.dotfiles

# Copy hardware configuration
sudo cp /etc/nixos/hardware-configuration.nix hosts/desktop/

# Apply configuration
sudo nixos-rebuild switch --flake .#desktop
```

The home-manager configuration is applied automatically as part of the system configuration.

---

## After Bootstrap

Once bootstrap completes successfully:

### Review Configurations

```bash
cd ~/.dotfiles

# Review system configuration
cat hosts/<hostname>/configuration.nix

# Review home configuration
cat home/<username>/default.nix
```

### Customize

Edit configurations to suit your needs:
- Add packages to `environment.systemPackages`
- Configure services
- Add user-specific packages to `home.packages`
- Set up shell aliases, git config, etc.

### Apply Changes

```bash
# Apply system configuration (includes home-manager)
sudo nixos-rebuild switch --flake .#<hostname>
```

### Commit and Push

```bash
git add .
git commit -m "Customize configuration for <hostname>"
git push
```

See [Daily Usage](DAILY-USAGE.md) for common operations.

---

## Troubleshooting

### Bootstrap Fails to Clone Repository

**Error:** `git clone` fails

**Solutions:**
- Ensure you have network connectivity
- Check GitHub is accessible
- Verify repository URL is correct
- Try manual clone: `git clone https://github.com/piredman/nixos-config.git ~/.dotfiles`

### Flakes Not Enabled

**Error:** `error: experimental Nix feature 'nix-command' is disabled`

**Solution:**
Enable flakes in `/etc/nixos/configuration.nix`:
```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

Then rebuild:
```bash
sudo nixos-rebuild switch
```

### Hardware Configuration Missing

**Error:** `error: getting status of '/etc/nixos/hardware-configuration.nix': No such file or directory`

**Solution:**
Generate hardware configuration:
```bash
sudo nixos-generate-config --show-hardware-config > /etc/nixos/hardware-configuration.nix
```

Then re-run bootstrap.

### Permission Denied

**Error:** `Permission denied` when cloning to `~/.dotfiles`

**Solution:**
Ensure you're running as your user (not root). The bootstrap script should be run as a normal user; it will prompt for sudo when needed.

---

## See Also

- [Daily Usage](DAILY-USAGE.md) - Common commands after bootstrap
- [Advanced Topics](ADVANCED.md) - Detailed configuration information
- [Package Management](PACKAGES.md) - Managing packages

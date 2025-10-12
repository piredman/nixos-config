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
3. Determines if a configuration exists for your hostname
4. Creates new configuration from templates (if needed) or uses existing
5. Copies hardware configuration from `/etc/nixos/`
6. Applies the NixOS system configuration
7. Optionally applies Home Manager configuration

## Interactive Prompts

You'll be prompted for:

- **Hostname** (defaults to current system hostname from `hostname`)
- **Username** (defaults to current user from `$USER`)
- **Full name** (required, no default)
- **Timezone** (defaults to `/etc/timezone` or `America/Edmonton`)
- **Locale** (defaults to `$LANG` or `en_GB.UTF-8`)

## Usage Scenarios

### Scenario 1: First-Time Bootstrap (New Host)

**When:** Installing NixOS on a machine for the first time, no configuration exists in git yet.

**What Happens:**

1. Bootstrap clones the repository to `~/.dotfiles`
2. Runs `setup-host.sh` to create new configuration from templates
3. Creates `hosts/<hostname>/` directory with:
   - `configuration.nix` (from template)
   - `settings.nix` (with your provided values)
   - `hardware-configuration.nix` (copied from `/etc/nixos/`)
4. Creates `home/<username>/` directory with:
   - `default.nix` (from template)
   - `settings.nix` (with your provided values)
5. Prompts to apply system configuration
6. Prompts to apply Home Manager configuration

**Result:** New machine-specific configuration created and applied.

**Next Steps:**
- Review and customize `hosts/<hostname>/configuration.nix`
- Review and customize `home/<username>/default.nix`
- Commit changes: `git add . && git commit -m "Add <hostname> configuration"`
- Push to remote: `git push`

---

### Scenario 2: Bootstrap Existing Host (Reinstall)

**When:** Reinstalling NixOS on a machine that already has configuration in the git repository.

**What Happens:**

1. Bootstrap clones the repository to `~/.dotfiles`
2. Finds existing `hosts/<hostname>/` configuration in git
3. Skips host configuration creation (already exists)
4. **Automatically overwrites `hardware-configuration.nix`** with current system:
   - Creates timestamped backup of existing file
   - Copies new hardware config from `/etc/nixos/`
   - No prompt (uses `--force` flag)
5. Prompts to apply system configuration
6. Prompts to apply Home Manager configuration

**Result:** Your software configuration is restored with updated hardware config.

**Why hardware config is overwritten:**
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

# Create configuration for the new machine
./scripts/setup-host.sh laptop alice "Alice Smith" "America/New_York" "en_US.UTF-8"

# Review the generated configuration
ls hosts/laptop/
ls home/alice/

# Customize as needed
vim hosts/laptop/configuration.nix
vim home/alice/default.nix

# Commit and push
git add .
git commit -m "Add laptop configuration for Alice"
git push
```

**Later:** When you install NixOS on the laptop:
1. Run the bootstrap command
2. Use hostname: `laptop`, username: `alice`
3. Bootstrap finds the existing configuration and uses it

**Benefits:**
- Prepare configurations in advance
- Test and refine before physical installation
- Review configurations as a team before deployment
- Track all machine configs in git before deployment
- No need for hardware config until actual install

---

### Scenario 4: Manually Add Host to Existing Setup

**When:** Adding another machine to your existing NixOS fleet.

**How:**

```bash
cd ~/.dotfiles

# Create configuration for new host
./scripts/setup-host.sh desktop redman "Paul Redman" "America/Edmonton" "en_GB.UTF-8"

# Customize the configuration
vim hosts/desktop/configuration.nix

# Commit and push
git add .
git commit -m "Add desktop host configuration"
git push
```

**Then on the new machine, either:**

**Option A: Use bootstrap** (recommended)
```bash
nix-shell -p curl git --run "bash <(curl -fsSL https://raw.githubusercontent.com/piredman/nixos-config/master/bootstrap)"
```
Bootstrap will find the configuration and apply it.

**Option B: Manual clone and apply**
```bash
git clone https://github.com/piredman/nixos-config.git ~/.dotfiles
cd ~/.dotfiles
sudo nixos-rebuild switch --flake .#desktop
home-manager switch --flake .#redman
```

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
# Apply system changes
sudo nixos-rebuild switch --flake .#<hostname>

# Apply home changes
home-manager switch --flake .#<username>
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

Then re-run bootstrap or `setup-host.sh`.

### Permission Denied

**Error:** `Permission denied` when cloning to `~/.dotfiles`

**Solution:**
Ensure you're running as your user (not root). The bootstrap script should be run as a normal user; it will prompt for sudo when needed.

---

## See Also

- [Scripts Reference](SCRIPTS.md) - Details on `setup-host.sh`
- [Daily Usage](DAILY-USAGE.md) - Common commands after bootstrap
- [Advanced Topics](ADVANCED.md) - Manual configuration methods

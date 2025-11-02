# Scripts Reference

Documentation for helper scripts included in this configuration.

## setup-host.sh

Creates a new host and user configuration from templates.

### Location

`scripts/setup-host.sh`

### Purpose

Automates the creation of configuration files for a new host and user by:
- Creating host directory structure
- Generating host configuration files
- Generating settings files with provided values
- Copying hardware configuration
- Creating home directory structure
- Generating user configuration files
- Generating user settings files

### Usage

```bash
./scripts/setup-host.sh <hostname> <username> <fullname> <timezone> <locale> [--force]
```

### Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `hostname` | System hostname | `laptop` |
| `username` | User login name | `alice` |
| `fullname` | User's full name (quoted if spaces) | `"Alice Smith"` |
| `timezone` | System timezone | `America/New_York` |
| `locale` | System locale | `en_US.UTF-8` |
| `--force` | Skip hardware config prompt, always overwrite | `--force` |

### Examples

**Create configuration for a laptop:**
```bash
./scripts/setup-host.sh laptop alice "Alice Smith" "America/New_York" "en_US.UTF-8"
```

**Create configuration for a server:**
```bash
./scripts/setup-host.sh server admin "System Administrator" "UTC" "en_US.UTF-8"
```

**Create configuration for a desktop:**
```bash
./scripts/setup-host.sh desktop redman "Paul Redman" "America/Edmonton" "en_GB.UTF-8"
```

### What It Does

#### 1. Creates Host Directory

Creates `hosts/<hostname>/` if it doesn't exist.

**If directory already exists:**
- Prints warning: `⚠️  Host directory already exists`
- Skips host creation
- Proceeds to user creation

#### 2. Creates Host Configuration

Creates a new `hosts/<hostname>/configuration.nix` configuration file.

#### 3. Creates Host Settings

Creates `hosts/<hostname>/settings.nix`:

```nix
{
    hostname = "provided-hostname";
    timezone = "provided-timezone";
    local = "provided-locale";
}
```

#### 4. Handles Hardware Configuration

**If `/etc/nixos/hardware-configuration.nix` exists:**

- **If `hosts/<hostname>/hardware-configuration.nix` doesn't exist:**
  - Copies hardware config
  - Prints: `✅ Copied hardware configuration`

- **If `hosts/<hostname>/hardware-configuration.nix` exists:**
  - **With `--force` flag (bootstrap mode):**
    - Automatically overwrites without prompting
    - Creates timestamped backup: `hardware-configuration.nix.backup.YYYYMMDD-HHMMSS`
    - Copies new hardware config
    - Prints: `✅ Backed up existing hardware configuration`
    - Prints: `✅ Copied new hardware configuration (forced)`
  
  - **Without `--force` flag (manual mode):**
    - Prompts: `Overwrite with /etc/nixos/hardware-configuration.nix? (y/N)`
    - **If yes:**
      - Creates timestamped backup: `hardware-configuration.nix.backup.YYYYMMDD-HHMMSS`
      - Copies new hardware config
      - Prints: `✅ Backed up existing hardware configuration`
      - Prints: `✅ Copied new hardware configuration`
    - **If no:**
      - Keeps existing configuration
      - Prints: `ℹ️  Keeping existing hardware configuration`

**If `/etc/nixos/hardware-configuration.nix` doesn't exist:**
- Prints warning with instructions to generate one
- Continues with rest of setup

#### 5. Creates User Directory

Creates `home/<username>/` if it doesn't exist.

**If directory already exists:**
- Prints warning: `⚠️  Home configuration already exists`
- Skips user creation

#### 6. Creates User Configuration

Creates a new `home/<username>/default.nix` configuration file.

#### 7. Creates User Settings

Creates `home/<username>/settings.nix`:

```nix
{
    username = "provided-username";
    name = "provided-fullname";
}
```

#### 8. Completion

Prints: `✅ Setup complete!`

### When to Use

#### Automatically (by Bootstrap)

The bootstrap script automatically calls `setup-host.sh` with the `--force` flag when setting up a new system:

```bash
# In bootstrap script (line 70)
./scripts/setup-host.sh "$HOSTNAME" "$USERNAME" "$FULLNAME" "$TIMEZONE" "$LOCALE" --force
```

The `--force` flag ensures hardware configuration is always updated on fresh/reinstalls without prompting.

You don't need to run it manually in this case.

#### Manually: Pre-Configure Before Installation

Prepare configuration for a machine before installing NixOS:

```bash
cd ~/.dotfiles
./scripts/setup-host.sh laptop bob "Bob Jones" "America/Chicago" "en_US.UTF-8"
git add .
git commit -m "Add laptop configuration for Bob"
git push
```

Later, when bootstrapping the laptop, the configuration already exists and will be used.

#### Manually: Add Host to Existing Setup

Add a new machine to your NixOS fleet:

```bash
cd ~/.dotfiles
./scripts/setup-host.sh server admin "Admin User" "UTC" "en_US.UTF-8"
git add .
git commit -m "Add server configuration"
git push
```

### Exit Codes

| Code | Meaning |
|------|---------|
| `0` | Success |
| `1` | Invalid arguments (missing required parameters) |

### Files Created

For hostname `laptop` and username `alice`:

```
hosts/laptop/
├── configuration.nix              # From template
├── settings.nix                   # Generated
└── hardware-configuration.nix     # Copied from /etc/nixos/

home/alice/
├── default.nix                    # From template
└── settings.nix                   # Generated
```

### Error Handling

#### Missing Parameters

**Error:**
```
Usage: ./scripts/setup-host.sh <hostname> <username> <fullname> <timezone> <locale>
```

**Solution:** Provide all 5 required parameters.

#### No Hardware Configuration

**Warning:**
```
⚠️  No hardware configuration found at /etc/nixos/hardware-configuration.nix
   You'll need to generate one with: nixos-generate-config
```

**Solution:**
```bash
sudo nixos-generate-config --show-hardware-config > /etc/nixos/hardware-configuration.nix
```

Then re-run the script.

#### Directory Exists

**Warning:**
```
⚠️  Host directory already exists: /home/user/.dotfiles/hosts/laptop
```

This is not an error. The script:
- Skips creating host configuration
- Still creates user configuration if it doesn't exist
- Allows you to update user without touching host

### Integration with Bootstrap

The bootstrap script uses `setup-host.sh` like this:

1. User runs bootstrap
2. Bootstrap prompts for hostname, username, etc.
3. Bootstrap calls `setup-host.sh` with those values
4. `setup-host.sh` creates configuration
5. Bootstrap applies configuration

This means:
- **Bootstrap handles the user interaction**
- **setup-host.sh handles the file creation**
- **Both work together seamlessly**

### Best Practices

#### Quote Full Names

Always quote full names with spaces:

```bash
# Good
./scripts/setup-host.sh laptop alice "Alice Smith" "America/New_York" "en_US.UTF-8"

# Bad - will fail
./scripts/setup-host.sh laptop alice Alice Smith "America/New_York" "en_US.UTF-8"
```

#### Use Standard Timezones

Use valid timezone names from `/usr/share/zoneinfo/`:

```bash
# Good
America/New_York
Europe/London
Asia/Tokyo
UTC

# Bad
EST
PST
GMT
```

#### Verify Created Files

After running, check the created files:

```bash
./scripts/setup-host.sh laptop alice "Alice Smith" "America/New_York" "en_US.UTF-8"

# Verify host files
ls -la hosts/laptop/
cat hosts/laptop/settings.nix

# Verify user files
ls -la home/alice/
cat home/alice/settings.nix
```

#### Commit Changes

Always commit after creating configurations:

```bash
./scripts/setup-host.sh laptop alice "Alice Smith" "America/New_York" "en_US.UTF-8"
git add hosts/laptop home/alice
git commit -m "Add laptop configuration for Alice"
git push
```

### Advanced Usage

#### The --force Flag

**What it does:**
- Skips interactive prompt for hardware configuration
- Always overwrites existing hardware-configuration.nix
- Creates timestamped backup before overwriting
- Used automatically by bootstrap script

**When to use:**
- Automated/scripted setups
- Fresh installs where hardware config must be updated
- Bootstrap scenarios (automatically added)

**When NOT to use:**
- Manual host configuration on existing systems
- When you want to keep existing hardware config
- When you want to be prompted

**Example with --force:**
```bash
./scripts/setup-host.sh laptop alice "Alice Smith" "America/New_York" "en_US.UTF-8" --force
```

#### Review Before Running

To understand what will be created, review existing configurations:

```bash
# View existing host configuration
cat hosts/mini/configuration.nix

# View existing user configuration
cat home/redman/default.nix
```

#### Batch Creation

Create multiple hosts at once:

```bash
#!/bin/bash
hosts=(
  "desktop:bob:Bob Jones:America/Chicago:en_US.UTF-8"
  "laptop:alice:Alice Smith:America/New_York:en_US.UTF-8"
  "server:admin:Admin User:UTC:en_US.UTF-8"
)

for host in "${hosts[@]}"; do
  IFS=: read -r hostname username fullname timezone locale <<< "$host"
  ./scripts/setup-host.sh "$hostname" "$username" "$fullname" "$timezone" "$locale"
done
```

## See Also

- [Bootstrap Guide](BOOTSTRAP.md) - How bootstrap uses this script
- [Advanced Topics](ADVANCED.md) - Manual configuration methods
- [Daily Usage](DAILY-USAGE.md) - Using created configurations

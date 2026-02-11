## Current cleanup

```
nix-env --list-generations
nixos-rebuild list-generations

sudo nix-collect-garbage  --delete-older-than 2d
sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 2d

sudo nix-collect-garbage --delete-old
sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 7d

sudo nix-store --optimize

lsblk -o NAME,MOUNTPOINT,SIZE,FSUSED,FSAVAIL,FSUSE%
```

## Comprehensive Plan to Prevent /boot from Filling Up

1. Add Boot-Specific Cleanup Service

Create a systemd service that runs after each nixos-rebuild to:

- Clean old boot entries aggressively
- Monitor available space
- Prevent operations if space < 200MB

2. Enhanced GC Configuration

Change from time-based to hybrid approach:

```nix
nix.gc = {
  automatic = true;
  dates = "daily"; # More frequent than weekly
  options = "--delete-older-than 3d --max-freed 2G";
};
```

3. Add Pre-Build Safety Check

Create a script that runs before nixos-rebuild:

- Checks available space in /boot
- Warns/aborts if insufficient space
- Suggests manual cleanup

4. Boot Space Monitoring

Add a service that:

- Monitors /boot usage daily
- Sends notifications if > 80% full
- Automatically cleans if > 90% full

## Useful commands

```nix
nix-env --list-generations

nix-collect-garbage  --delete-old

nix-collect-garbage  --delete-generations 1 2 3

# recommeneded to sometimes run as sudo to collect additional garbage
sudo nix-collect-garbage -d

# As a separation of concerns - you will need to run this command to clean out boot
sudo /run/current-system/bin/switch-to-configuration boot

sudo nixos-rebuild boot

# Remove old system profile generations (keeps current + few recent):
sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 7d

# Run garbage collection to delete unused store paths:
sudo nix-collect-garbage --delete-old

# Optimize the Nix store (optional, but helpful):
sudo nix-store --optimize

# More aggressive cleanup (keeps only current generation):
sudo nix-collect-garbage -d

# Clean but keep last 5 generations:
sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --keep 5
```

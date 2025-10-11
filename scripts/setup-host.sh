#!/usr/bin/env bash

set -e

HOSTNAME=$1
USERNAME=$2
FULLNAME=$3
TIMEZONE=$4
LOCALE=$5

if [ -z "$HOSTNAME" ] || [ -z "$USERNAME" ] || [ -z "$FULLNAME" ] || [ -z "$TIMEZONE" ] || [ -z "$LOCALE" ]; then
    echo "Usage: $0 <hostname> <username> <fullname> <timezone> <locale>"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

echo "Setting up host: $HOSTNAME"
echo "Setting up user: $USERNAME"

HOST_DIR="$REPO_ROOT/hosts/$HOSTNAME"
if [ -d "$HOST_DIR" ]; then
    echo "⚠️  Host directory already exists: $HOST_DIR"
else
    mkdir -p "$HOST_DIR"

    cp "$REPO_ROOT/hosts/template/configuration.nix" "$HOST_DIR/configuration.nix"

    cat >"$HOST_DIR/settings.nix" <<EOF
{
    hostname = "$HOSTNAME";
    timezone = "$TIMEZONE";
    local = "$LOCALE";
}
EOF

    if [ -f "/etc/nixos/hardware-configuration.nix" ]; then
        if [ -f "$HOST_DIR/hardware-configuration.nix" ]; then
            echo "⚠️  Hardware configuration already exists in $HOST_DIR"
            read -p "Overwrite with /etc/nixos/hardware-configuration.nix? (y/N): " OVERWRITE
            if [[ "$OVERWRITE" =~ ^[Yy]$ ]]; then
                BACKUP_FILE="$HOST_DIR/hardware-configuration.nix.backup.$(date +%Y%m%d-%H%M%S)"
                cp "$HOST_DIR/hardware-configuration.nix" "$BACKUP_FILE"
                echo "✅ Backed up existing hardware configuration to: $(basename $BACKUP_FILE)"
                cp /etc/nixos/hardware-configuration.nix "$HOST_DIR/hardware-configuration.nix"
                echo "✅ Copied new hardware configuration"
            else
                echo "ℹ️  Keeping existing hardware configuration"
            fi
        else
            cp /etc/nixos/hardware-configuration.nix "$HOST_DIR/hardware-configuration.nix"
            echo "✅ Copied hardware configuration"
        fi
    else
        echo "⚠️  No hardware configuration found at /etc/nixos/hardware-configuration.nix"
        echo "   You'll need to generate one with: nixos-generate-config"
    fi

    echo "✅ Created host configuration for $HOSTNAME"
fi

HOME_DIR="$REPO_ROOT/home/$USERNAME"

if [ -d "$HOME_DIR" ]; then
    echo "⚠️  Home configuration already exists: $HOME_DIR"
else
    mkdir -p "$HOME_DIR"

    cp "$REPO_ROOT/home/template/default.nix" "$HOME_DIR/default.nix"

    cat >"$HOME_DIR/settings.nix" <<EOF
{
    username = "$USERNAME";
    name = "$FULLNAME";
}
EOF

    echo "✅ Created home configuration for $USERNAME"
fi

echo "✅ Setup complete!"

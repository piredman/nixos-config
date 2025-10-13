#!/usr/bin/env bash

set -e

# ============================================================================
# FUNCTIONS
# ============================================================================

parse_arguments() {
    HOSTNAME=$1
    USERNAME=$2
    FULLNAME=$3
    TIMEZONE=$4
    LOCALE=$5
    FORCE_OVERWRITE=false

    for arg in "$@"; do
        if [ "$arg" = "--force" ]; then
            FORCE_OVERWRITE=true
        fi
    done

    if [ -z "$HOSTNAME" ] || [ -z "$USERNAME" ] || [ -z "$FULLNAME" ] || [ -z "$TIMEZONE" ] || [ -z "$LOCALE" ]; then
        echo "Usage: $0 <hostname> <username> <fullname> <timezone> <locale> [--force]"
        exit 1
    fi

    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    REPO_ROOT="$(dirname "$SCRIPT_DIR")"
    HOST_DIR="$REPO_ROOT/hosts/$HOSTNAME"
    HOME_DIR="$REPO_ROOT/home/$USERNAME"
}

prompt_user_overwrite() {
    local description=$1

    echo "⚠️  $description already exists"
    read -p "Overwrite? (y/N): " OVERWRITE

    if [[ "$OVERWRITE" =~ ^[Yy]$ ]]; then
        return 0
    else
        echo "ℹ️  Keeping existing $description"
        return 1
    fi
}

copy_hardware_configuration() {
    local source_file=$1
    local target_file=$2

    cp "$source_file" "$target_file"
    echo "✅ Copied: $source_file -> $target_file"

    git add -A
    echo "✅ All files staged in git"
}

create_host_directory() {
    if [ -d "$HOST_DIR" ]; then
        echo "⚠️  Host directory already exists: $HOST_DIR"
        return 0
    fi

    mkdir -p "$HOST_DIR"

    cp "$REPO_ROOT/hosts/template/configuration.nix" "$HOST_DIR/configuration.nix"

    cat >"$HOST_DIR/settings.nix" <<EOF
{
    hostname = "$HOSTNAME";
    timezone = "$TIMEZONE";
    locale = "$LOCALE";
}
EOF

    echo "✅ Created host configuration for $HOSTNAME"
}

handle_hardware_configuration() {
    local source_hw_config="/etc/nixos/hardware-configuration.nix"
    local target_hw_config="$HOST_DIR/hardware-configuration.nix"

    if [ ! -f "$source_hw_config" ]; then
        echo "⚠️  No hardware configuration found at $source_hw_config"
        echo "   You'll need to generate one with: nixos-generate-config"
        exit 1
    fi

    if [ ! -f "$target_hw_config" ] || [ "$FORCE_OVERWRITE" = true ]; then
        copy_hardware_configuration "$source_hw_config" "$target_hw_config"
        echo "✅ Copied hardware configuration"
        return 0
    fi

    if prompt_user_overwrite "Hardware configuration in $HOST_DIR"; then
        copy_hardware_configuration "$source_hw_config" "$target_hw_config"
        echo "✅ Copied hardware configuration"
    fi
}

create_home_directory() {
    if [ -d "$HOME_DIR" ]; then
        echo "⚠️  Home configuration already exists: $HOME_DIR"
        return 0
    fi

    mkdir -p "$HOME_DIR"

    cp "$REPO_ROOT/home/template/default.nix" "$HOME_DIR/default.nix"

    cat >"$HOME_DIR/settings.nix" <<EOF
{
    username = "$USERNAME";
    name = "$FULLNAME";
}
EOF

    echo "✅ Created home configuration for $USERNAME"
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

parse_arguments "$@"

echo "Setting up host: $HOSTNAME"
echo "Setting up user: $USERNAME"

create_host_directory
handle_hardware_configuration
create_home_directory

echo "✅ Setup complete!"

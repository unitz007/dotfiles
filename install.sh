#!/usr/bin/env bash

# Install script for the project
# Supports --dry-run to simulate actions without making changes.

set -euo pipefail

# Default values
DRY_RUN=0

# Helper functions
print_help() {
    cat <<EOF
Usage: $(basename "$0") [options]

Options:
  -h, --help        Show this help message and exit
  --dry-run         Show actions that would be performed without modifying the system
EOF
}

log_action() {
    echo "[DRY RUN] $*"
}

# Parse arguments
while (( "$#" )); do
    case "$1" in
        -h|--help)
            print_help
            exit 0
            ;;
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        *) # unknown option
            echo "Error: Unknown option: $1" >&2
            print_help
            exit 1
            ;;
    esac
done

# If dry‑run is enabled, replace common mutating commands with no‑op wrappers
if [[ "$DRY_RUN" -eq 1 ]]; then
    # Wrapper for creating symlinks
    ln() {
        if [[ "$1" == "-sf" ]]; then
            local src="${@: -2:1}"
            local dest="${@: -1}"
            log_action "Would create symlink: $dest -> $src"
        else
            log_action "Would run ln $*"
        fi
    }

    # Wrapper for moving files (used for backups)
    mv() {
        log_action "Would move: $*"
    }

    # Wrapper for removing files/directories
    rm() {
        log_action "Would remove: $*"
    }

    # Wrapper for package installation (apt-get, yum, etc.)
    apt-get() {
        log_action "Would run apt-get $*"
    }
    yum() {
        log_action "Would run yum $*"
    }
    pacman() {
        log_action "Would run pacman $*"
    }

    # Wrapper for git clone / pull
    git() {
        log_action "Would run git $*"
    }

    # Prevent any accidental writes
    touch() {
        log_action "Would touch: $*"
    }
    mkdir() {
        log_action "Would mkdir: $*"
    }
fi

# ----------------------------------------------------------------------
# Begin actual installation logic
# ----------------------------------------------------------------------

# Example: backup existing config and create symlink
CONFIG_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/config/myapp.conf"
CONFIG_DEST="${HOME}/.myapp.conf"

if [[ -e "$CONFIG_DEST" && ! -L "$CONFIG_DEST" ]]; then
    BACKUP="${CONFIG_DEST}.bak.$(date +%s)"
    echo "Backing up existing config to $BACKUP"
    mv "$CONFIG_DEST" "$BACKUP"
fi

echo "Creating symlink for config"
ln -sf "$CONFIG_SRC" "$CONFIG_DEST"

# Example: install required packages
REQUIRED_PKGS=("curl" "git")
if command -v apt-get >/dev/null 2>&1; then
    echo "Installing packages via apt-get"
    sudo apt-get update
    sudo apt-get install -y "${REQUIRED_PKGS[@]}"
elif command -v yum >/dev/null 2>&1; then
    echo "Installing packages via yum"
    sudo yum install -y "${REQUIRED_PKGS[@]}"
elif command -v pacman >/dev/null 2>&1; then
    echo "Installing packages via pacman"
    sudo pacman -Sy --noconfirm "${REQUIRED_PKGS[@]}"
else
    echo "No supported package manager found; please install ${REQUIRED_PKGS[*]} manually."
fi

# Additional installation steps would follow here...

echo "Installation complete."
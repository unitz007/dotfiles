#!/usr/bin/env bash

# Uninstall script for the project
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

# If dry‑run is enabled, replace mutating commands with no‑op wrappers
if [[ "$DRY_RUN" -eq 1 ]]; then
    # Wrapper for removing symlinks/files
    rm() {
        log_action "Would remove: $*"
    }

    # Wrapper for moving files (used for restoring backups)
    mv() {
        log_action "Would move: $*"
    }

    # Wrapper for package removal
    apt-get() {
        log_action "Would run apt-get $*"
    }
    yum() {
        log_action "Would run yum $*"
    }
    pacman() {
        log_action "Would run pacman $*"
    }

    # Wrapper for git operations (if any)
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
# Begin actual uninstallation logic
# ----------------------------------------------------------------------

# Example: remove symlinked config
CONFIG_DEST="${HOME}/.myapp.conf"
if [[ -L "$CONFIG_DEST" ]]; then
    echo "Removing symlinked config"
    rm "$CONFIG_DEST"
fi

# Example: restore backup if it exists
BACKUP_PATTERN="${CONFIG_DEST}.bak.*"
if compgen -G "$BACKUP_PATTERN" > /dev/null; then
    LATEST_BACKUP=$(ls -t $BACKUP_PATTERN | head -n1)
    echo "Restoring backup from $LATEST_BACKUP"
    mv "$LATEST_BACKUP" "$CONFIG_DEST"
fi

# Example: remove installed packages
UNNEEDED_PKGS=("curl" "git")
if command -v apt-get >/dev/null 2>&1; then
    echo "Removing packages via apt-get"
    sudo apt-get remove -y "${UNNEEDED_PKGS[@]}"
elif command -v yum >/dev/null 2>&1; then
    echo "Removing packages via yum"
    sudo yum remove -y "${UNNEEDED_PKGS[@]}"
elif command -v pacman >/dev/null 2>&1; then
    echo "Removing packages via pacman"
    sudo pacman -Rns --noconfirm "${UNNEEDED_PKGS[@]}"
else
    echo "No supported package manager found; please remove ${UNNEEDED_PKGS[*]} manually."
fi

# Additional uninstallation steps would follow here...

echo "Uninstallation complete."
#!/usr/bin/env bash
# restore.sh – Restore dotfiles backups created by install.sh
#
# Usage:
#   ./restore.sh --list                # list available backups
#   ./restore.sh --latest              # restore the most recent backup
#   ./restore.sh <timestamp>           # restore a specific backup (timestamp is the directory name)
#
# The backup directory can be overridden with the environment variable
#   DOTFILES_BACKUP_DIR (default: $HOME/.dotfiles_backup)

set -euo pipefail

# ----------------------------------------------------------------------
# Configuration
# ----------------------------------------------------------------------
BACKUP_ROOT="${DOTFILES_BACKUP_DIR:-$HOME/.dotfiles_backup}"

# ----------------------------------------------------------------------
# Helper functions
# ----------------------------------------------------------------------
usage() {
    cat <<EOF
Usage: $(basename "$0") [--list] [--latest] [timestamp]

  --list          List all available backups.
  --latest        Restore the most recent backup.
  timestamp       Name of the backup directory to restore (as shown by --list).

Environment:
  DOTFILES_BACKUP_DIR   Directory where backups are stored (default: $HOME/.dotfiles_backup)
EOF
    exit 1
}

list_backups() {
    if [[ ! -d "$BACKUP_ROOT" ]]; then
        echo "Backup directory not found: $BACKUP_ROOT"
        exit 1
    fi
    echo "Available backups:"
    # List only directories directly under BACKUP_ROOT, sorted chronologically
    find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort
}

latest_backup() {
    if [[ ! -d "$BACKUP_ROOT" ]]; then
        echo "Backup directory not found: $BACKUP_ROOT"
        exit 1
    fi
    # Find the most recently modified backup directory
    latest=$(find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d -printf '%T@ %p\n' |
        sort -nr | head -n1 | cut -d' ' -f2-)
    if [[ -z "$latest" ]]; then
        echo "No backups found in $BACKUP_ROOT"
        exit 1
    fi
    echo "$latest"
}

confirm_overwrite() {
    local target="$1"
    read -rp "File $target is newer than the backup. Overwrite? [y/N] " resp
    [[ "$resp" =~ ^[Yy]$ ]]
}

confirm_symlink_overwrite() {
    local target="$1"
    read -rp "Symlink $target points elsewhere. Overwrite? [y/N] " resp
    [[ "$resp" =~ ^[Yy]$ ]]
}

# ----------------------------------------------------------------------
# Argument parsing
# ----------------------------------------------------------------------
if [[ $# -eq 0 ]]; then
    usage
fi

case "$1" in
    --list)
        list_backups
        exit 0
        ;;
    --latest)
        BACKUP_DIR="$(latest_backup)"
        ;;
    *)
        BACKUP_DIR="${BACKUP_ROOT%/}/$1"
        if [[ ! -d "$BACKUP_DIR" ]]; then
            echo "Backup \"$1\" not found in $BACKUP_ROOT"
            exit 1
        fi
        ;;
esac

echo "Restoring backup: $(basename "$BACKUP_DIR")"
echo "Backup location: $BACKUP_DIR"
echo

# ----------------------------------------------------------------------
# Restore regular files
# ----------------------------------------------------------------------
while IFS= read -r -d '' src; do
    rel="${src#$BACKUP_DIR/}"
    dest="$HOME/$rel"

    # Ensure destination directory exists
    mkdir -p "$(dirname "$dest")"

    if [[ -e "$dest" && ! -L "$dest" ]]; then
        # Destination exists and is a regular file/dir
        if [[ "$src" -nt "$dest" ]]; then
            # Backup version is newer – safe to overwrite
            cp -a "$src" "$dest"
        else
            # Destination is newer – ask before overwriting
            if confirm_overwrite "$dest"; then
                cp -a "$src" "$dest"
            else
                echo "Skipping $dest"
            fi
        fi
    else
        # Destination does not exist or is a symlink – just copy
        cp -a "$src" "$dest"
    fi
done < <(find "$BACKUP_DIR" -type f -print0)

# ----------------------------------------------------------------------
# Restore symlinks
# ----------------------------------------------------------------------
while IFS= read -r -d '' link; do
    rel="${link#$BACKUP_DIR/}"
    target=$(readlink "$link")
    dest="$HOME/$rel"

    mkdir -p "$(dirname "$dest")"

    if [[ -L "$dest" ]]; then
        # Existing symlink – check if it points to the same target
        if [[ "$(readlink "$dest")" != "$target" ]]; then
            if confirm_symlink_overwrite "$dest"; then
                ln -sf "$target" "$dest"
            else
                echo "Skipping symlink $dest"
            fi
        fi
    else
        # Not a symlink (could be a regular file/dir) – replace with symlink
        if [[ -e "$dest" && ! -L "$dest" ]]; then
            echo "Warning: $dest exists and is not a symlink. Replacing with symlink."
            rm -rf "$dest"
        fi
        ln -s "$target" "$dest"
    fi
done < <(find "$BACKUP_DIR" -type l -print0)

echo
echo "Restore complete."
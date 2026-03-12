#!/usr/bin/env bash
# uninstall.sh - Revert changes made by install.sh
# Supports Linux, macOS, and WSL2.
# Usage: ./uninstall.sh [--dry-run]

set -euo pipefail

# -------------------------- Helper Functions --------------------------

log() {
    echo "[*] $*"
}

warn() {
    echo "[!] $*" >&2
}

dry_run=false

# Parse arguments
while (( "$#" )); do
    case "$1" in
        --dry-run)
            dry_run=true
            shift
            ;;
        -h|--help)
            cat <<EOF
Usage: $0 [--dry-run]

  --dry-run   Show what would be done without making any changes.
EOF
            exit 0
            ;;
        *)
            warn "Unknown option: $1"
            exit 1
            ;;
    esac
done

run() {
    if $dry_run; then
        echo "DRY-RUN: $*"
    else
        eval "$@"
    fi
}

# -------------------------- Determine Backup Directory --------------------------

# install.sh stores the backup location in a hidden file for easy lookup.
# If that file does not exist we fall back to the conventional default.
BACKUP_MARKER="${HOME}/.dotfiles_backup_path"
DEFAULT_BACKUP_DIR="${HOME}/.dotfiles_backup"

if [[ -f "${BACKUP_MARKER}" ]]; then
    BACKUP_DIR="$(< "${BACKUP_MARKER}")"
    log "Found backup marker. Using backup directory: ${BACKUP_DIR}"
else
    BACKUP_DIR="${DEFAULT_BACKUP_DIR}"
    log "No backup marker found. Assuming default backup directory: ${BACKUP_DIR}"
fi

if [[ ! -d "${BACKUP_DIR}" ]]; then
    warn "Backup directory '${BACKUP_DIR}' does not exist. Nothing to restore."
    exit 1
fi

# -------------------------- Restore Files --------------------------

log "Restoring original files from backup..."

# Use rsync to copy everything back, preserving permissions.
# The backup directory mirrors the home directory structure.
RSYNC_CMD="rsync -a --delete \"${BACKUP_DIR}/\" \"${HOME}/\""

run "${RSYNC_CMD}"

# -------------------------- Remove Symlinks Created by install.sh --------------------------

# List of known symlinks that install.sh creates.
declare -a SYMLINKS=(
    "${HOME}/.zshrc"
    "${HOME}/.bashrc"
    "${HOME}/.vimrc"
    "${HOME}/.config/nvim"
    "${HOME}/.tmux.conf"
)

log "Removing installer‑created symlinks (if any)..."
for link in "${SYMLINKS[@]}"; do
    if [[ -L "${link}" ]]; then
        log "Removing symlink: ${link}"
        run "rm -f \"${link}\""
    fi
done

# -------------------------- Remove Generated Config Directories --------------------------

declare -a GENERATED_DIRS=(
    "${HOME}/.oh-my-zsh"
    "${HOME}/.config/nvim"
)

log "Removing generated configuration directories (if they are not part of the backup)..."
for dir in "${GENERATED_DIRS[@]}"; do
    if [[ -d "${dir}" ]]; then
        # If the directory exists in the backup, we keep it (it was restored above).
        rel_path="${dir/#${HOME}\//}"
        if [[ -d "${BACKUP_DIR}/${rel_path}" ]]; then
            log "Directory ${dir} restored from backup – leaving it in place."
        else
            log "Removing generated directory: ${dir}"
            run "rm -rf \"${dir}\""
        fi
    fi
done

# -------------------------- Clean Up Backup Marker --------------------------

if [[ -f "${BACKUP_MARKER}" ]]; then
    log "Removing backup marker file."
    run "rm -f \"${BACKUP_MARKER}\""
fi

# Optionally delete the backup directory after a successful restore.
log "Removing backup directory '${BACKUP_DIR}'."
run "rm -rf \"${BACKUP_DIR}\""

log "Uninstall complete."
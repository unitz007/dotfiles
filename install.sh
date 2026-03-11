#!/usr/bin/env bash
#
# install.sh – Deploy dotfiles by creating symbolic links.
# Enhanced with safe backup handling: any existing target file is moved
# to a timestamped backup directory before the symlink is created.
#

set -euo pipefail

# ----------------------------------------------------------------------
# Configuration
# ----------------------------------------------------------------------
# Directory containing this script (the dotfiles repository)
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# List of dotfiles (relative to the repository root) to be linked into $HOME
DOTFILES=(
    .bashrc
    .vimrc
    .gitconfig
    # add more files here
)

# Backup location – a timestamped sub‑directory under $HOME/.dotfiles_backup
BACKUP_ROOT="${HOME}/.dotfiles_backup"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="${BACKUP_ROOT}/${TIMESTAMP}"

# Ensure the backup directory exists (created once)
mkdir -p "${BACKUP_DIR}"

# ----------------------------------------------------------------------
# Helper functions
# ----------------------------------------------------------------------
log() {
    echo "[install.sh] $*"
}

backup_target() {
    local target_path="$1"
    local target_name
    target_name="$(basename "${target_path}")"

    # Move the existing file/symlink to the backup directory
    log "Backing up existing '${target_path}' to '${BACKUP_DIR}/${target_name}'"
    mv "${target_path}" "${BACKUP_DIR}/${target_name}"
}

create_symlink() {
    local source_path="$1"
    local target_path="$2"

    ln -s "${source_path}" "${target_path}"
    log "Created symlink: '${target_path}' → '${source_path}'"
}

# ----------------------------------------------------------------------
# Main installation loop
# ----------------------------------------------------------------------
for dotfile in "${DOTFILES[@]}"; do
    src="${DOTFILES_DIR}/${dotfile}"
    dst="${HOME}/${dotfile}"

    # Verify source exists
    if [[ ! -e "${src}" ]]; then
        log "Source file '${src}' does not exist – skipping."
        continue
    fi

    # If a target already exists (regular file, directory, or symlink), back it up
    if [[ -e "${dst}" || -L "${dst}" ]]; then
        backup_target "${dst}"
    fi

    # Ensure the parent directory for the target exists (e.g., for nested dotfiles)
    mkdir -p "$(dirname "${dst}")"

    # Create the symbolic link
    create_symlink "${src}" "${dst}"
done

log "Installation complete. All backups (if any) are stored in '${BACKUP_DIR}'."
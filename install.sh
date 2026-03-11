#!/usr/bin/env bash

# Exit on any error
set -e

# Determine script directory (assumed to be the dotfiles repo root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Directory containing the dotfiles to be linked/copyed
DOTFILES_DIR="${SCRIPT_DIR}/dotfiles"

# Home directory of the user
HOME_DIR="${HOME}"

# ----------------------------------------------------------------------
# Backup existing dotfiles that would be overwritten
# ----------------------------------------------------------------------
timestamp="$(date +%Y%m%d_%H%M%S)"
BACKUP_ROOT="${HOME_DIR}/.dotfiles_backup"
BACKUP_DIR="${BACKUP_ROOT}/${timestamp}"

log() {
    echo "[install] $*"
}

log "Creating backup directory at ${BACKUP_DIR}"
mkdir -p "${BACKUP_DIR}"

# Function to backup a single file if it exists and would be overwritten
backup_if_exists() {
    local target_path="$1"   # path relative to $HOME_DIR (e.g., .bashrc)
    local src_path="$2"      # absolute path of the source dotfile in repo

    local full_target="${HOME_DIR}/${target_path}"

    # If the target exists and is not already the correct symlink, back it up
    if [[ -e "${full_target}" && ! ( -L "${full_target}" && "$(readlink "${full_target}")" == "${src_path}" ) ]]; then
        local backup_target="${BACKUP_DIR}/${target_path}"
        mkdir -p "$(dirname "${backup_target}")"
        log "Backing up existing ${full_target} → ${backup_target}"
        cp -a "${full_target}" "${backup_target}"
    fi
}

# ----------------------------------------------------------------------
# Install dotfiles
# ----------------------------------------------------------------------
log "Installing dotfiles from ${DOTFILES_DIR}"

# Iterate over all files (including hidden ones) in the dotfiles directory.
# Preserve directory structure relative to DOTFILES_DIR.
while IFS= read -r -d '' src_file; do
    # Compute relative path (e.g., .bashrc or .config/nvim/init.vim)
    rel_path="${src_file#${DOTFILES_DIR}/}"

    # Skip directories – we only link files (directories will be created as needed)
    if [[ -d "${src_file}" ]]; then
        continue
    fi

    # Ensure the target directory exists
    target_dir="${HOME_DIR}/$(dirname "${rel_path}")"
    mkdir -p "${target_dir}"

    # Backup any existing file that would be overwritten
    backup_if_exists "${rel_path}" "${src_file}"

    # Remove any existing file/symlink to make way for the new link
    rm -rf "${HOME_DIR}/${rel_path}"

    # Create a symbolic link from the repo dotfile to the home directory
    ln -s "${src_file}" "${HOME_DIR}/${rel_path}"
    log "Linked ${src_file} → ${HOME_DIR}/${rel_path}"
done < <(find "${DOTFILES_DIR}" -type f -print0)

log "Installation complete. Backup of any overwritten files is stored in ${BACKUP_DIR}"
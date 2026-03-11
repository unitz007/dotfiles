#!/usr/bin/env bash
# uninstall.sh - Revert changes made by install.sh
# Removes symlinks created by install.sh and restores original files from backup.

set -euo pipefail

# Directory where this script resides (assumed to be the dotfiles repo)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Backup directory used by install.sh (adjust if install.sh uses a different path)
BACKUP_DIR="${HOME}/.dotfiles_backup"

removed=0
restored=0

# Helper to output messages
info()   { echo -e "[\e[34mINFO\e[0m] $*"; }
success(){ echo -e "[\e[32mOK\e[0m]   $*"; }
warn()   { echo -e "[\e[33mWARN\e[0m] $*"; }
error()  { echo -e "[\e[31mERR\e[0m]  $*"; }

# ----------------------------------------------------------------------
# 1. Remove symlinks that point into the dotfiles repository
# ----------------------------------------------------------------------
info "Scanning for symlinks pointing to ${SCRIPT_DIR}..."

# Find all symlinks under $HOME that resolve inside the repo
while IFS= read -r -d '' link_path; do
    # Resolve the absolute target of the symlink
    target_path="$(readlink -f "$link_path")"
    # If the target is inside the repo, remove the symlink
    if [[ "$target_path" == "${SCRIPT_DIR}"* ]]; then
        rm -f "$link_path"
        ((removed++))
        success "Removed symlink: $link_path"
    fi
done < <(find "${HOME}" -maxdepth 1 -type l -print0)

# ----------------------------------------------------------------------
# 2. Restore original files from backup (if any)
# ----------------------------------------------------------------------
if [[ -d "${BACKUP_DIR}" ]]; then
    info "Restoring original files from backup (${BACKUP_DIR})..."
    while IFS= read -r -d '' backup_file; do
        # Compute the path relative to the backup directory
        rel_path="${backup_file#${BACKUP_DIR}/}"
        # Destination where the original file should live
        dest_path="${HOME}/${rel_path}"

        # Ensure the destination directory exists
        mkdir -p "$(dirname "${dest_path}")"

        # Move the backup file back to its original location
        mv -f "${backup_file}" "${dest_path}"
        ((restored++))
        success "Restored: ${dest_path}"
    done < <(find "${BACKUP_DIR}" -type f -print0)

    # Clean up the (now empty) backup directory
    if rmdir "${BACKUP_DIR}" 2>/dev/null; then
        success "Removed empty backup directory."
    else
        warn "Backup directory not empty; left untouched."
    fi
else
    warn "No backup directory found at ${BACKUP_DIR}. Nothing to restore."
fi

# ----------------------------------------------------------------------
# 3. Summary
# ----------------------------------------------------------------------
echo "------------------------------------------------------------"
echo "Uninstall summary:"
echo "  Symlinks removed : ${removed}"
echo "  Files restored   : ${restored}"
echo "------------------------------------------------------------"

exit 0
#!/usr/bin/env bash

# Exit on any error
set -e

HOME_DIR="${HOME}"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/dotfiles"

log() {
    echo "[uninstall] $*"
}

# ----------------------------------------------------------------------
# Helper: Remove installed dotfiles (symlinks)
# ----------------------------------------------------------------------
remove_installed() {
    log "Removing installed dotfiles..."

    while IFS= read -r -d '' src_file; do
        rel_path="${src_file#${DOTFILES_DIR}/}"
        target="${HOME_DIR}/${rel_path}"

        if [[ -L "${target}" && "$(readlink "${target}")" == "${src_file}" ]]; then
            rm -f "${target}"
            log "Removed symlink ${target}"
        fi
    done < <(find "${DOTFILES_DIR}" -type f -print0)

    log "Removal complete."
}

# ----------------------------------------------------------------------
# Helper: Restore the most recent backup (if any)
# ----------------------------------------------------------------------
restore_latest_backup() {
    BACKUP_ROOT="${HOME_DIR}/.dotfiles_backup"
    if [[ ! -d "${BACKUP_ROOT}" ]]; then
        log "No backup directory found at ${BACKUP_ROOT}. Nothing to restore."
        return 1
    fi

    latest_backup="$(ls -d "${BACKUP_ROOT}"/* 2>/dev/null | sort | tail -n 1)"
    if [[ -z "${latest_backup}" ]]; then
        log "No backups found in ${BACKUP_ROOT}."
        return 1
    fi

    log "Restoring files from latest backup: ${latest_backup}"
    # Copy everything back, preserving attributes
    cp -a "${latest_backup}/." "${HOME_DIR}/"
    log "Restore complete."
}

# ----------------------------------------------------------------------
# Argument parsing
# ----------------------------------------------------------------------
SHOW_HELP=false
RESTORE=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            SHOW_HELP=true
            shift
            ;;
        -r|--restore)
            RESTORE=true
            shift
            ;;
        *)
            log "Unknown option: $1"
            SHOW_HELP=true
            shift
            ;;
    esac
done

if $SHOW_HELP; then
    cat <<EOF
Usage: $(basename "$0") [options]

Options:
  -h, --help        Show this help message.
  -r, --restore     After uninstalling, restore the most recent backup
                    (if any) to the home directory.
EOF
    exit 0
fi

# Perform uninstall
remove_installed

# Optionally restore from backup
if $RESTORE; then
    restore_latest_backup || log "Restore failed or no backup available."
fi
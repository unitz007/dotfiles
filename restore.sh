#!/usr/bin/env bash
# restore.sh – restore the most recent (or a specific) dotfiles backup.
# If the backup is GPG‑encrypted and a key is configured, it will be decrypted automatically.
# Configuration is read from ~/dotfiles.yml (same keys as install.sh).

set -euo pipefail

# ----------------------------------------------------------------------
# Helper: read a simple scalar value from the YAML config.
# ----------------------------------------------------------------------
yaml_value() {
    local key="$1"
    grep -E "^[[:space:]]*${key}[[:space:]]*:" "${CONFIG_FILE}" \
        | grep -v '^[[:space:]]*#' \
        | head -n1 \
        | sed -E "s/^[[:space:]]*${key}[[:space:]]*:[[:space:]]*//" \
        | tr -d '\r'
}

# ----------------------------------------------------------------------
# Load configuration
# ----------------------------------------------------------------------
CONFIG_FILE="${HOME}/dotfiles.yml"

if [[ ! -f "${CONFIG_FILE}" ]]; then
    echo "Configuration file ${CONFIG_FILE} not found."
    exit 1
fi

BACKUP_DIR="$(yaml_value backup_dir)"
BACKUP_GPG_KEY="$(yaml_value backup_gpg_key)"
# Default fallback
: "${BACKUP_DIR:=${HOME}/.dotfiles_backups}"

# ----------------------------------------------------------------------
# Determine which backup to restore
# ----------------------------------------------------------------------
# If a filename is supplied as the first argument, use it; otherwise pick the newest.
if [[ $# -ge 1 ]]; then
    BACKUP_FILE="$1"
    if [[ ! -f "${BACKUP_FILE}" ]]; then
        echo "Specified backup file ${BACKUP_FILE} does not exist."
        exit 1
    fi
else
    cd "${BACKUP_DIR}"
    # Prefer encrypted backups first, then plain ones, sorted by newest.
    BACKUP_FILE="$(ls -1t dotfiles-backup-*.gpg 2>/dev/null | head -n1)"
    if [[ -z "${BACKUP_FILE}" ]]; then
        BACKUP_FILE="$(ls -1t dotfiles-backup-*.tar.gz 2>/dev/null | head -n1)"
    fi
    if [[ -z "${BACKUP_FILE}" ]]; then
        echo "No backup files found in ${BACKUP_DIR}."
        exit 1
    fi
fi

echo "Restoring from backup: ${BACKUP_FILE}"

# ----------------------------------------------------------------------
# Decrypt if needed
# ----------------------------------------------------------------------
if [[ "${BACKUP_FILE}" == *.gpg ]]; then
    DECRYPTED="${BACKUP_FILE%.gpg}"
    echo "Decrypting GPG backup..."
    if gpg --yes --batch --decrypt --output "${DECRYPTED}" "${BACKUP_FILE}"; then
        BACKUP_FILE="${DECRYPTED}"
        echo "Decryption successful."
    else
        echo "ERROR: GPG decryption failed."
        exit 1
    fi
fi

# ----------------------------------------------------------------------
# Extract the backup
# ----------------------------------------------------------------------
# The tarball is expected to contain files relative to $HOME.
tar -xzf "${BACKUP_FILE}" -C "${HOME}"

echo "Restore completed."
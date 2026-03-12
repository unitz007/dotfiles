#!/usr/bin/env bash
# install.sh – create a backup of the dotfiles and optionally encrypt it with GPG.
# The script reads configuration from ~/dotfiles.yml.
#   backup_dir:      directory where backups are stored
#   backup_gpg_key:  (optional) GPG key ID to encrypt the backup with
#   backup_keep:    (optional) number of backups to retain (default: 7)

set -euo pipefail

# ----------------------------------------------------------------------
# Helper: read a simple scalar value from the YAML config.
# ----------------------------------------------------------------------
yaml_value() {
    local key="$1"
    # Grab the first non‑comment line that starts with the key followed by a colon.
    # Strip the key and any surrounding whitespace.
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
BACKUP_KEEP="$(yaml_value backup_keep)"
# Default values
: "${BACKUP_DIR:=${HOME}/.dotfiles_backups}"
: "${BACKUP_KEEP:=7}"

mkdir -p "${BACKUP_DIR}"

# ----------------------------------------------------------------------
# Create the backup tarball
# ----------------------------------------------------------------------
TIMESTAMP="$(date +%Y%m%d%H%M%S)"
BACKUP_TAR="${BACKUP_DIR}/dotfiles-backup-${TIMESTAMP}.tar.gz"

# Adjust the source list as needed – here we back up the whole $HOME directory.
tar -czf "${BACKUP_TAR}" -C "${HOME}" . 

# ----------------------------------------------------------------------
# Optional GPG encryption
# ----------------------------------------------------------------------
if [[ -n "${BACKUP_GPG_KEY}" ]]; then
    echo "Encrypting backup with GPG key ${BACKUP_GPG_KEY}..."
    # The output will be <tar>.gpg
    if gpg --yes --batch --encrypt --recipient "${BACKUP_GPG_KEY}" --output "${BACKUP_TAR}.gpg" "${BACKUP_TAR}"; then
        rm -f "${BACKUP_TAR}"
        BACKUP_TAR="${BACKUP_TAR}.gpg"
        echo "Encryption successful: ${BACKUP_TAR}"
    else
        echo "WARNING: GPG encryption failed – keeping unencrypted backup."
    fi
fi

# ----------------------------------------------------------------------
# Rotate old backups (keep the newest $BACKUP_KEEP files)
# ----------------------------------------------------------------------
# List files sorted by modification time, keep the newest $BACKUP_KEEP, delete the rest.
cd "${BACKUP_DIR}"
ls -1t dotfiles-backup-* | tail -n +$((BACKUP_KEEP + 1)) | xargs -r rm -f --

echo "Backup created: ${BACKUP_TAR}"
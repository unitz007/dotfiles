#!/usr/bin/env bash
set -euo pipefail

# ----------------------------------------------------------------------
# Configuration
# ----------------------------------------------------------------------
# Directory where the application is installed
INSTALL_DIR="/opt/myapp"

# Directory where backups are stored
BACKUP_DIR="/opt/myapp/backup"

# Number of most recent backups to keep.
# Users can override this by exporting BACKUP_KEEP_COUNT before invoking the script.
BACKUP_KEEP_COUNT="${BACKUP_KEEP_COUNT:-3}"

# ----------------------------------------------------------------------
# Helper Functions
# ----------------------------------------------------------------------
log() {
    echo "[${0##*/}] $*"
}

# Create a timestamped backup of the current installation.
create_backup() {
    local timestamp
    timestamp=$(date +"%Y%m%d%H%M%S")
    local backup_path="${BACKUP_DIR}/backup_${timestamp}"

    log "Creating backup at ${backup_path} ..."
    mkdir -p "${BACKUP_DIR}"
    cp -a "${INSTALL_DIR}" "${backup_path}"
    log "Backup created."

    rotate_backups
}

# Remove older backups, keeping only the most recent $BACKUP_KEEP_COUNT.
rotate_backups() {
    # Ensure the backup directory exists.
    [[ -d "${BACKUP_DIR}" ]] || return

    # Find all backup directories, sort them by modification time (newest first),
    # skip the first $BACKUP_KEEP_COUNT entries, and delete the rest.
    local to_delete
    to_delete=$(ls -1dt "${BACKUP_DIR}"/backup_* 2>/dev/null | tail -n +$((BACKUP_KEEP_COUNT + 1))) || return

    if [[ -n "${to_delete}" ]]; then
        log "Rotating backups: keeping the most recent ${BACKUP_KEEP_COUNT}."
        # Use xargs to handle spaces in filenames safely.
        echo "${to_delete}" | xargs -d '\n' -r rm -rf --
        log "Old backups removed."
    else
        log "No old backups to remove."
    fi
}

# ----------------------------------------------------------------------
# Main Installation Logic
# ----------------------------------------------------------------------
main() {
    log "Starting installation..."

    # Example: backup existing installation before overwriting.
    if [[ -d "${INSTALL_DIR}" ]]; then
        create_backup
    else
        log "No existing installation found; skipping backup."
    fi

    # ... (rest of the installation steps go here) ...

    log "Installation completed."
}

# Execute the script.
main "$@"
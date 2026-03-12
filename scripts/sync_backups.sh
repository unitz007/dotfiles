#!/usr/bin/env bash
# sync_backups.sh
# Upload the latest dotfiles backup archive to a cloud remote using rclone
# and optionally prune old remote backups according to the rotation policy
# defined in dotfiles.yml.

set -euo pipefail

# Determine repository root (directory containing this script)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Path to configuration file
CONFIG_FILE="${REPO_ROOT}/dotfiles.yml"

# Helper to read a value from the yaml using yq (must be installed)
yq_read() {
    local query=$1
    yq eval -o=raw "${query}" "${CONFIG_FILE}"
}

# Verify yq is available
if ! command -v yq >/dev/null 2>&1; then
    echo "Error: 'yq' is required but not installed." >&2
    exit 1
fi

# Verify rclone is available
if ! command -v rclone >/dev/null 2>&1; then
    echo "Error: 'rclone' is required but not installed." >&2
    exit 1
fi

# -------------------------------------------------------------------------
# Read cloud backup configuration
# -------------------------------------------------------------------------
CLOUD_PROVIDER="$(yq_read '.cloud_backup.provider // ""')"
REMOTE_PATH="$(yq_read '.cloud_backup.remote_path // ""')"
RCLONE_CONFIG="$(yq_read '.cloud_backup.rclone_config // ""')"

if [[ -z "${CLOUD_PROVIDER}" || -z "${REMOTE_PATH}" ]]; then
    echo "Error: cloud_backup.provider and cloud_backup.remote_path must be defined in ${CONFIG_FILE}." >&2
    exit 1
fi

# Build rclone base command (include custom config if supplied)
RCLONE_BASE="rclone"
if [[ -n "${RCLONE_CONFIG}" ]]; then
    RCLONE_BASE+=" --config ${RCLONE_CONFIG}"
fi

# -------------------------------------------------------------------------
# Determine backup directory (fallback to $HOME/.dotfiles/backups)
# -------------------------------------------------------------------------
BACKUP_DIR="$(yq_read '.backup.path // ""')"
if [[ -z "${BACKUP_DIR}" ]]; then
    BACKUP_DIR="${HOME}/.dotfiles/backups"
fi

if [[ ! -d "${BACKUP_DIR}" ]]; then
    echo "Error: Backup directory '${BACKUP_DIR}' does not exist." >&2
    exit 1
fi

# -------------------------------------------------------------------------
# Find the latest backup archive (assumes *.tar.gz or *.zip)
# -------------------------------------------------------------------------
LATEST_ARCHIVE="$(ls -1t "${BACKUP_DIR}"/*.{tar.gz,zip} 2>/dev/null | head -n1 || true)"
if [[ -z "${LATEST_ARCHIVE}" ]]; then
    echo "Error: No backup archives found in '${BACKUP_DIR}'." >&2
    exit 1
fi

echo "Uploading latest backup: ${LATEST_ARCHIVE}"

# -------------------------------------------------------------------------
# Upload using rclone
# -------------------------------------------------------------------------
${RCLONE_BASE} copy "${LATEST_ARCHIVE}" "${REMOTE_PATH}" --progress

echo "Upload completed."

# -------------------------------------------------------------------------
# Optional remote pruning based on rotation policy
# -------------------------------------------------------------------------
# Read rotation policy (defaults to 0 if not set)
ROT_DAILY="$(yq_read '.backup.rotation.daily // 0')"
ROT_WEEKLY="$(yq_read '.backup.rotation.weekly // 0')"
ROT_MONTHLY="$(yq_read '.backup.rotation.monthly // 0')"

# If any rotation value is set, perform pruning
if (( ROT_DAILY > 0 || ROT_WEEKLY > 0 || ROT_MONTHLY > 0 )); then
    # Simple approach: keep the most recent N backups where N = sum of rotation counts
    KEEP_COUNT=$(( ROT_DAILY + ROT_WEEKLY + ROT_MONTHLY ))
    if (( KEEP_COUNT == 0 )); then
        KEEP_COUNT=0
    fi

    echo "Pruning remote backups, keeping the latest ${KEEP_COUNT} files..."

    # List remote files (non‑recursive, one per line)
    REMOTE_FILES=$(${RCLONE_BASE} lsf "${REMOTE_PATH}")

    # Sort files assuming they contain sortable timestamps (lexicographic order)
    # Reverse sort to have newest first
    MAPFILE -t SORTED_FILES < <(printf '%s\n' ${REMOTE_FILES} | sort -r)

    # Determine files to delete (those beyond KEEP_COUNT)
    if (( ${#SORTED_FILES[@]} > KEEP_COUNT )); then
        for (( i=KEEP_COUNT; i<${#SORTED_FILES[@]}; i++ )); do
            FILE_TO_DELETE="${SORTED_FILES[i]}"
            echo "Deleting remote old backup: ${FILE_TO_DELETE}"
            ${RCLONE_BASE} deletefile "${REMOTE_PATH}/${FILE_TO_DELETE}"
        done
    else
        echo "No remote files need pruning."
    fi
else
    echo "No rotation policy defined; skipping remote pruning."
fi

echo "Sync and optional pruning finished."
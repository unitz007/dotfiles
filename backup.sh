#!/usr/bin/env bash

# -------------------------------------------------
# backup.sh - Create a backup archive and rotate old backups
# -------------------------------------------------

set -euo pipefail

# Configuration
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
BACKUP_DIR="${BACKUP_DIR:-$HOME/backups}"
LOG_FILE="${LOG_FILE:-$HOME/backup.log}"

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

# -------------------------------------------------
# Helper: log messages with timestamp
# -------------------------------------------------
log() {
    local msg="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') $msg" | tee -a "$LOG_FILE"
}

# -------------------------------------------------
# Step 1: Create backup archive
# -------------------------------------------------
TIMESTAMP=$(date '+%Y%m%d-%H%M%S')
ARCHIVE_NAME="backup-${TIMESTAMP}.tar.gz"
ARCHIVE_PATH="${BACKUP_DIR}/${ARCHIVE_NAME}"

log "Creating backup archive: $ARCHIVE_NAME"

# Example: tar your home directory (customize as needed)
tar -czf "$ARCHIVE_PATH" "$HOME" 2>>"$LOG_FILE"

log "Backup created at $ARCHIVE_PATH"

# -------------------------------------------------
# Step 2: Load rotation policy from dotfiles.yml
# -------------------------------------------------
# Default policy (keep everything if not defined)
KEEP_DAILY=${KEEP_DAILY:-0}
KEEP_WEEKLY=${KEEP_WEEKLY:-0}
KEEP_MONTHLY=${KEEP_MONTHLY:-0}

if [[ -f "${DOTFILES_DIR}/dotfiles.yml" ]]; then
    # Simple YAML parsing – assumes one‑line key: value pairs without quotes
    KEEP_DAILY=$(grep -E '^keep_daily:' "${DOTFILES_DIR}/dotfiles.yml" | awk -F': ' '{print $2}' | tr -d '\r')
    KEEP_WEEKLY=$(grep -E '^keep_weekly:' "${DOTFILES_DIR}/dotfiles.yml" | awk -F': ' '{print $2}' | tr -d '\r')
    KEEP_MONTHLY=$(grep -E '^keep_monthly:' "${DOTFILES_DIR}/dotfiles.yml" | awk -F': ' '{print $2}' | tr -d '\r')
fi

# Fallback to 0 if values are empty or not numbers
[[ "$KEEP_DAILY" =~ ^[0-9]+$ ]] || KEEP_DAILY=0
[[ "$KEEP_WEEKLY" =~ ^[0-9]+$ ]] || KEEP_WEEKLY=0
[[ "$KEEP_MONTHLY" =~ ^[0-9]+$ ]] || KEEP_MONTHLY=0

log "Rotation policy – keep_daily: $KEEP_DAILY, keep_weekly: $KEEP_WEEKLY, keep_monthly: $KEEP_MONTHLY"

# -------------------------------------------------
# Step 3: Determine maximum age (in days) to retain backups
# -------------------------------------------------
# Approximate weeks as 7 days and months as 30 days
MAX_AGE_DAYS=$KEEP_DAILY
WEEK_AGE=$(( KEEP_WEEKLY * 7 ))
MONTH_AGE=$(( KEEP_MONTHLY * 30 ))

if (( WEEK_AGE > MAX_AGE_DAYS )); then MAX_AGE_DAYS=$WEEK_AGE; fi
if (( MONTH_AGE > MAX_AGE_DAYS )); then MAX_AGE_DAYS=$MONTH_AGE; fi

# If policy is all zeros, skip rotation
if (( MAX_AGE_DAYS == 0 )); then
    log "No rotation policy defined – skipping old backup pruning."
    exit 0
fi

log "Pruning backups older than $MAX_AGE_DAYS days."

# -------------------------------------------------
# Step 4: Prune old backups
# -------------------------------------------------
# Find archives older than MAX_AGE_DAYS and delete them, logging each removal.
while IFS= read -r old_file; do
    log "Removing old backup: $(basename "$old_file")"
    rm -f "$old_file"
done < <(find "$BACKUP_DIR" -type f -name "*.tar.gz" -mtime +"$MAX_AGE_DAYS")

log "Backup rotation completed."
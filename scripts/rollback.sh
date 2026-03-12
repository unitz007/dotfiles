#!/usr/bin/env bash
# rollback.sh – Restore a previous dotfiles backup
# ------------------------------------------------
# This script lists available backup archives (created by backup.sh),
# lets the user select one (or specify a timestamp / "latest"),
# decrypts it if necessary and restores the dotfiles to the home directory.
#
# Supported platforms: macOS, Linux, Windows (via Git Bash, WSL or PowerShell invoking bash).
#
# Configuration (can be overridden with environment variables):
#   DOTFILES_BACKUP_DIR        – Directory where backups are stored (default: $HOME/.dotfiles_backups)
#   DOTFILES_BACKUP_ENCRYPTION – Set to "true" if backups are encrypted with GPG (default: false)
#
# Usage:
#   ./rollback.sh                # interactive selection
#   ./rollback.sh --restore latest
#   ./rollback.sh --restore 20231115_1030
#
# Edge‑cases:
#   * No backups → script exits with an error.
#   * Specified timestamp not found → interactive fallback.
#   * Decryption fails → script aborts and leaves the system unchanged.

set -euo pipefail

# -------------------------------------------------------------------------
# Configuration
# -------------------------------------------------------------------------
BACKUP_DIR="${DOTFILES_BACKUP_DIR:-$HOME/.dotfiles_backups}"
ENCRYPTION="${DOTFILES_BACKUP_ENCRYPTION:-false}"   # "true" if .gpg files are used

# -------------------------------------------------------------------------
# Helper functions
# -------------------------------------------------------------------------
usage() {
  cat <<EOF >&2
Usage: ${0##*/} [--restore <timestamp|latest>]

  --restore <timestamp|latest>   Restore a specific backup (by timestamp) or the most recent one.
                                 If omitted, an interactive menu is shown.
  -h, --help                     Show this help message.
EOF
  exit 1
}

error_exit() {
  echo "Error: $*" >&2
  exit 1
}

# -------------------------------------------------------------------------
# Argument parsing
# -------------------------------------------------------------------------
RESTORE_TARGET=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --restore)
      [[ -n "${2-}" ]] || usage
      RESTORE_TARGET="$2"
      shift 2
      ;;
    -h|--help) usage ;;
    *) usage ;;
  esac
done

# -------------------------------------------------------------------------
# Verify backup directory
# -------------------------------------------------------------------------
if [[ ! -d "$BACKUP_DIR" ]]; then
  error_exit "Backup directory '$BACKUP_DIR' does not exist."
fi

# -------------------------------------------------------------------------
# Gather backup files
# -------------------------------------------------------------------------
# Backups are expected to be named like: backup-20231115_1030.tar.gz
# Encrypted backups have an additional .gpg suffix.
mapfile -t BACKUPS < <(
  find "$BACKUP_DIR" -maxdepth 1 -type f \
    -name 'backup-*.tar.gz' -o -name 'backup-*.tar.gz.gpg' \
    2>/dev/null | sort
)

if (( ${#BACKUPS[@]} == 0 )); then
  error_exit "No backup archives found in '$BACKUP_DIR'."
fi

# -------------------------------------------------------------------------
# Choose which backup to restore
# -------------------------------------------------------------------------
select_backup() {
  local target="$1"

  # 1️⃣  "latest" shortcut
  if [[ "$target" == "latest" ]]; then
    echo "${BACKUPS[-1]}"
    return
  fi

  # 2️⃣  Direct timestamp match (partial match allowed)
  if [[ -n "$target" ]]; then
    for file in "${BACKUPS[@]}"; do
      if [[ "$file" == *"$target"* ]]; then
        echo "$file"
        return
      fi
    done
  fi

  # 3️⃣  Interactive menu
  echo "Available backups:"
  for i in "${!BACKUPS[@]}"; do
    printf "  [%2d] %s\n" $((i+1)) "$(basename "${BACKUPS[i]}")"
  done

  while true; do
    read -rp "Select backup to restore (1-${#BACKUPS[@]}): " choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && ((choice >= 1 && choice <= ${#BACKUPS[@]})); then
      echo "${BACKUPS[choice-1]}"
      return
    fi
    echo "Invalid selection. Please enter a number between 1 and ${#BACKUPS[@]}."
  done
}

SELECTED_BACKUP=$(select_backup "$RESTORE_TARGET")
echo "Selected backup: $(basename "$SELECTED_BACKUP")"

# -------------------------------------------------------------------------
# Decrypt if necessary
# -------------------------------------------------------------------------
if [[ "$SELECTED_BACKUP" == *.gpg ]]; then
  if [[ "$ENCRYPTION" != "true" ]]; then
    echo "Warning: Backup appears encrypted but DOTFILES_BACKUP_ENCRYPTION is not set to true."
  fi
  TMP_ARCHIVE=$(mktemp)
  trap 'rm -f "$TMP_ARCHIVE"' EXIT
  echo "Decrypting backup..."
  if ! gpg --quiet --batch --yes --decrypt --output "$TMP_ARCHIVE" "$SELECTED_BACKUP"; then
    error_exit "Failed to decrypt the backup archive."
  fi
  ARCHIVE_PATH="$TMP_ARCHIVE"
else
  ARCHIVE_PATH="$SELECTED_BACKUP"
fi

# -------------------------------------------------------------------------
# Restore the archive
# -------------------------------------------------------------------------
echo "Extracting backup to home directory ($HOME)..."
# The backup archive is expected to contain files relative to $HOME (e.g., .bashrc, .config/…)
tar -xzf "$ARCHIVE_PATH" -C "$HOME"

echo "✅ Restore completed successfully."
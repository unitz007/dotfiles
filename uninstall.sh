#!/usr/bin/env bash
# uninstall.sh – reverse actions performed by install.sh
# Removes created symlinks, restores the most recent backups,
# and optionally deletes the backup directory.

set -euo pipefail

show_help() {
  cat <<EOF
Usage: ${0##*/} [OPTIONS]

Options:
  --force       Skip all confirmation prompts.
  --dry-run     Show what would be done without making changes.
  -h, --help    Show this help message and exit.
EOF
}

# Parse options
force=0
dry_run=0

while (( "$#" )); do
  case "$1" in
    --force)   force=1 ;;
    --dry-run) dry_run=1 ;;
    -h|--help) show_help; exit 0 ;;
    *) echo "Unknown option: $1" >&2; show_help; exit 1 ;;
  esac
  shift
done

# Resolve paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${HOME}"
BACKUP_DIR="${HOME_DIR}/.dotfiles_backup"
MANIFEST="${HOME_DIR}/.dotfiles_install_manifest"

if [[ ! -f "${MANIFEST}" ]]; then
  echo "Error: Manifest file not found at ${MANIFEST}" >&2
  exit 1
fi

# Process each entry in the manifest
while IFS= read -r target; do
  # Skip empty lines or comments
  [[ -z "${target}" || "${target}" == \#* ]] && continue

  # Remove symlink if it exists
  if [[ -L "${target}" ]]; then
    if (( dry_run )); then
      echo "Would remove symlink: ${target}"
    else
      echo "Removing symlink: ${target}"
      rm -f "${target}"
    fi
  fi

  # Determine relative path for backup lookup
  rel_path="${target#${HOME_DIR}/}"

  # Find the most recent backup for this file
  latest_backup=$(find "${BACKUP_DIR}" -type f -path "*/${rel_path}" -printf "%T@ %p\n" 2>/dev/null |
                  sort -nr |
                  head -n1 |
                  cut -d' ' -f2- || true)

  if [[ -n "${latest_backup}" ]]; then
    if (( dry_run )); then
      echo "Would restore backup from ${latest_backup} to ${target}"
    else
      echo "Restoring backup from ${latest_backup} to ${target}"
      mkdir -p "$(dirname "${target}")"
      cp -p "${latest_backup}" "${target}"
    fi
  fi
done < "${MANIFEST}"

# Prompt (or force) deletion of the backup directory
delete_backup=0
if (( force )); then
  delete_backup=1
else
  read -rp "Delete backup directory ${BACKUP_DIR}? (y/N): " answer
  if [[ "${answer}" =~ ^[Yy]$ ]]; then
    delete_backup=1
  fi
fi

if (( delete_backup )); then
  if (( dry_run )); then
    echo "Would delete backup directory ${BACKUP_DIR}"
  else
    echo "Deleting backup directory ${BACKUP_DIR}"
    rm -rf "${BACKUP_DIR}"
  fi
fi

exit 0
#!/usr/bin/env bash

# install.sh - Symlink dotfiles from this repository to the user's home directory.
# Features:
#   * Backs up existing files (unless --force is used).
#   * Idempotent – running multiple times will not create duplicate backups.
#   * Supports a --force flag to overwrite without prompting.
#   * Skips the script itself and any non‑dotfiles.

set -euo pipefail

# Determine script directory (repo root)
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse arguments
FORCE=0
while (( "$#" )); do
  case "$1" in
    --force)
      FORCE=1
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [--force]"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [--force]"
      exit 1
      ;;
  esac
done

# Function to create a backup of an existing file
backup_file() {
  local target="$1"
  local backup_dir="${HOME}/.dotfiles_backup"
  mkdir -p "${backup_dir}"
  local timestamp
  timestamp=$(date +"%Y%m%d%H%M%S")
  local base
  base=$(basename "${target}")
  mv "${target}" "${backup_dir}/${base}.${timestamp}"
  echo "Backed up ${target} → ${backup_dir}/${base}.${timestamp}"
}

# Gather dotfiles to install (files starting with a dot, excluding this script)
mapfile -t DOTFILES < <(
  find "${REPO_DIR}" -maxdepth 1 -type f -name ".*" ! -name ".git*" ! -name ".DS_Store" ! -name "install.sh"
)

# Process each dotfile
for src in "${DOTFILES[@]}"; do
  filename="$(basename "${src}")"
  target="${HOME}/${filename}"

  # If target already exists and is a symlink to the correct source, skip
  if [[ -L "${target}" && "$(readlink -f "${target}")" == "${src}" ]]; then
    echo "✔ ${target} already correctly linked."
    continue
  fi

  # If target exists and is not the desired symlink
  if [[ -e "${target}" || -L "${target}" ]]; then
    if [[ ${FORCE} -eq 1 ]]; then
      echo "⚠ Overwriting existing ${target} (force)."
    else
      backup_file "${target}"
    fi
  fi

  # Create (or replace) the symlink
  ln -sfn "${src}" "${target}"
  echo "🔗 Linked ${target} → ${src}"
done

echo "Installation complete."
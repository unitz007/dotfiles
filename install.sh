#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# install.sh - Install dotfiles based on configuration.
#
# Usage:
#   ./install.sh [--profile <name>]
#
# Options:
#   --profile <name>   Select a profile defined in dotfiles.yml.
#                      If omitted, the "default" profile is used.
# ------------------------------------------------------------

# Ensure required tools are available
if ! command -v yq >/dev/null 2>&1; then
  echo "Error: 'yq' is required but not installed." >&2
  exit 1
fi

# Default values
PROFILE="default"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile)
      if [[ -z "${2-}" ]]; then
        echo "Error: --profile requires a name argument." >&2
        exit 1
      fi
      PROFILE="$2"
      shift 2
      ;;
    -h|--help)
      grep '^#' "$0" | cut -c4-
      exit 0
      ;;
    *)
      echo "Error: Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

# Verify dotfiles.yml exists
CONFIG_FILE="dotfiles.yml"
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Error: $CONFIG_FILE not found in the current directory." >&2
  exit 1
fi

# Verify the requested profile exists
if ! yq e ".profiles.$PROFILE" "$CONFIG_FILE" >/dev/null; then
  echo "Error: Profile '$PROFILE' not defined in $CONFIG_FILE." >&2
  exit 1
fi

# Function to create a symlink safely
link_file() {
  local src_path="$1"
  local dest_path="$2"

  # Expand ~ in destination
  dest_path="${dest_path/#\~/$HOME}"

  # Ensure the source exists
  if [[ ! -e "$src_path" ]]; then
    echo "Warning: Source file '$src_path' does not exist. Skipping." >&2
    return
  fi

  # Create parent directory for destination if needed
  mkdir -p "$(dirname "$dest_path")"

  # Remove existing file/symlink if it exists
  if [[ -L "$dest_path" || -e "$dest_path" ]]; then
    rm -rf "$dest_path"
  fi

  ln -s "$(realpath "$src_path")" "$dest_path"
  echo "Linked $src_path -> $dest_path"
}

# Process each dotfile listed in the selected profile
# The profile should contain a list of keys that map to entries under .dotfiles
profile_keys=$(yq e ".profiles.$PROFILE[] | @sh" "$CONFIG_FILE")
if [[ -z "$profile_keys" ]]; then
  echo "Info: Profile '$PROFILE' contains no dotfiles to install."
  exit 0
fi

while IFS= read -r key; do
  # Remove surrounding quotes added by @sh
  key="${key%\"}"
  key="${key#\"}"
  src=$(yq e ".dotfiles.$key.src // empty" "$CONFIG_FILE")
  dest=$(yq e ".dotfiles.$key.dest // empty" "$CONFIG_FILE")

  if [[ -z "$src" || -z "$dest" ]]; then
    echo "Warning: Incomplete definition for dotfile key '$key'. Skipping." >&2
    continue
  fi

  # Resolve source relative to repository root
  src_path="$(realpath "$src")"

  link_file "$src_path" "$dest"
done <<< "$profile_keys"

echo "Installation complete for profile '$PROFILE'."
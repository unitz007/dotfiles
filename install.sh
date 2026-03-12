#!/usr/bin/env bash
set -euo pipefail

# Default flags
SKIP_VSCODE=false

# Parse command line arguments
while (( "$#" )); do
  case "$1" in
    --skip-vscode)
      SKIP_VSCODE=true
      shift
      ;;
    *)
      # Unknown option
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Load dotfiles configuration
DOTFILES_YML="${DOTFILES_YML:-dotfiles.yml}"
if [[ ! -f "$DOTFILES_YML" ]]; then
  echo "Configuration file $DOTFILES_YML not found."
  exit 1
fi

# Helper to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Ensure yq is available for YAML parsing
if ! command_exists yq; then
  echo "yq is required but not installed. Please install yq."
  exit 1
fi

# Source VSCode extension management if not skipped
if [[ "$SKIP_VSCODE" = false ]]; then
  if command_exists code; then
    # shellcheck source=/dev/null
    source "$(dirname "$0")/vscode.sh"
    manage_vscode_extensions "$DOTFILES_YML"
  else
    echo "VSCode command 'code' not found; skipping VSCode extension management."
  fi
fi

# ... existing install logic for other dotfiles components ...
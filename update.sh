#!/usr/bin/env bash
# dotfiles update – pull latest changes and re‑apply dotfiles
# Usage: dotfiles update [--dry-run] [--no-prompt]

set -euo pipefail

# ----------------------------------------------------------------------
# Parse flags
# ----------------------------------------------------------------------
DRY_RUN=0
NO_PROMPT=0

while (( "$#" )); do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      ;;
    --no-prompt)
      NO_PROMPT=1
      ;;
    *)
      echo "Error: unknown option: $1" >&2
      exit 1
      ;;
  esac
  shift
done

# ----------------------------------------------------------------------
# Determine remote and branch (configurable via dotfiles.yml)
# ----------------------------------------------------------------------
DEFAULT_REMOTE="origin"
DEFAULT_BRANCH="main"

REMOTE="${DEFAULT_REMOTE}"
BRANCH="${DEFAULT_BRANCH}"

if [[ -f dotfiles.yml ]]; then
  # Simple yaml parsing – works for flat key/value pairs
  remote_val=$(grep -E '^[[:space:]]*remote:' dotfiles.yml | awk -F': ' '{print $2}' | tr -d "\"'")
  branch_val=$(grep -E '^[[:space:]]*branch:' dotfiles.yml | awk -F': ' '{print $2}' | tr -d "\"'")
  if [[ -n "${remote_val}" ]]; then
    REMOTE="${remote_val}"
  fi
  if [[ -n "${branch_val}" ]]; then
    BRANCH="${branch_val}"
  fi
fi

# ----------------------------------------------------------------------
# Pull the latest changes
# ----------------------------------------------------------------------
echo "Fetching from remote '${REMOTE}'..."
git fetch "${REMOTE}"

echo "Checking out branch '${BRANCH}'..."
git checkout "${BRANCH}"

echo "Pulling latest changes..."
git pull "${REMOTE}" "${BRANCH}"

# ----------------------------------------------------------------------
# Dry‑run mode – only show what install would do
# ----------------------------------------------------------------------
if [[ "${DRY_RUN}" -eq 1 ]]; then
  echo "Running install.sh in dry‑run mode..."
  ./install.sh --dry-run
  exit 0
fi

# Show a preview of changes
echo "Running install.sh --dry-run to show pending changes..."
./install.sh --dry-run

# ----------------------------------------------------------------------
# Prompt for confirmation (unless --no-prompt)
# ----------------------------------------------------------------------
if [[ "${NO_PROMPT}" -eq 0 ]]; then
  read -rp "Apply these changes? [y/N] " answer
  if [[ ! "${answer}" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
  fi
fi

# ----------------------------------------------------------------------
# Apply the updates
# ----------------------------------------------------------------------
echo "Applying updates with install.sh..."
./install.sh

echo "Update complete."
#!/usr/bin/env bash
# sync_dotfiles.sh - Push and pull dotfiles repository with optional GPG encryption.
#
# Usage:
#   ./sync_dotfiles.sh [--encrypt]
#
# Options:
#   --encrypt   Encrypt the diff before committing. Requires the environment
#               variable GPG_RECIPIENT to be set to a valid GPG key identifier.
#
# This script:
#   1. Adds all changes to the repository.
#   2. If --encrypt is supplied, creates a diff of the changes, encrypts it
#      with GPG, adds the encrypted diff to the commit, and signs the commit.
#   3. Commits the changes.
#   4. Pushes to the remote repository (default branch 'main').
#   5. Pulls any remote updates (rebase).

set -euo pipefail

# Determine script directory (assumed repository root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Default values
ENCRYPT=0
REMOTE="${REMOTE:-origin}"
BRANCH="${BRANCH:-main}"

# Parse arguments
while (( "$#" )); do
  case "$1" in
    --encrypt)
      ENCRYPT=1
      shift
      ;;
    -h|--help)
      grep '^#' "$0" | cut -c4-
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Helper to clean up temporary files
cleanup() {
  [[ -f changes.diff ]] && rm -f changes.diff
}
trap cleanup EXIT

# Stage all changes
git add -A

if [[ "$ENCRYPT" -eq 1 ]]; then
  if [[ -z "${GPG_RECIPIENT:-}" ]]; then
    echo "Error: GPG_RECIPIENT environment variable is not set."
    exit 1
  fi

  # Create a diff of staged changes (relative to HEAD)
  git diff --cached > changes.diff

  # Encrypt the diff
  ENCRYPTED_DIFF="changes.diff.gpg"
  gpg --yes --encrypt --recipient "$GPG_RECIPIENT" -o "$ENCRYPTED_DIFF" changes.diff

  # Add encrypted diff to the index and remove the plain diff
  git add "$ENCRYPTED_DIFF"
  rm -f changes.diff

  # Commit with GPG signature
  git commit -S -m "Sync dotfiles (encrypted diff)"
else
  # Normal commit (no encryption)
  # If there is nothing to commit, skip commit step
  if git diff-index --quiet HEAD --; then
    echo "No changes to commit."
  else
    git commit -m "Sync dotfiles"
  fi
fi

# Push and pull
git push "$REMOTE" "$BRANCH"
git pull --rebase "$REMOTE" "$BRANCH"

echo "Sync complete."
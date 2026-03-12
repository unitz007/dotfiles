#!/usr/bin/env bash
# Helper script to install optional Git hooks for this repository.
# Currently installs the pre‑commit hook that validates dotfiles.yml.

set -euo pipefail

# Determine repository root (directory containing this script)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

HOOK_SRC="${REPO_ROOT}/hooks/pre-commit"
HOOK_DST="${REPO_ROOT}/.git/hooks/pre-commit"

# ----------------------------------------------------------------------
# Verify we are inside a Git repository
# ----------------------------------------------------------------------
if [ ! -d "${REPO_ROOT}/.git" ]; then
  echo "Error: .git directory not found – are you inside the repository root?" >&2
  exit 1
fi

# ----------------------------------------------------------------------
# Copy the hook and make it executable
# ----------------------------------------------------------------------
if [ ! -f "${HOOK_SRC}" ]; then
  echo "Error: Hook source '${HOOK_SRC}' does not exist." >&2
  exit 1
fi

cp "${HOOK_SRC}" "${HOOK_DST}"
chmod +x "${HOOK_DST}"
echo "Pre‑commit hook installed at .git/hooks/pre-commit"
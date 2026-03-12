#!/usr/bin/env bash
# sync_dotfiles.sh - Commit and push local changes of the dotfiles repository.
#
# Usage:
#   ./sync_dotfiles.sh [commit_message]
#
# If no commit_message is supplied, a default message of the form
# "Update dotfiles YYYY-MM-DD" is used.

set -euo pipefail

# Helper for error messages
error() {
    echo "Error: $*" >&2
    exit 1
}

# Verify we are inside a git working tree
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    error "Current directory is not inside a Git repository."
fi

# Ensure there are no unmerged (conflict) files
if git ls-files -u | grep -q .; then
    error "Repository has unmerged changes. Resolve conflicts before syncing."
fi

# Ensure a remote named 'origin' exists
if ! git remote get-url origin >/dev/null 2>&1; then
    error "No remote named 'origin' is configured."
fi

# Determine if there are any changes (tracked or untracked)
if [[ -n "$(git status --porcelain)" ]]; then
    # Stage all changes (including deletions, new files, etc.)
    git add -A
else
    echo "Working directory clean – nothing to commit."
fi

# Prepare commit message
if [[ $# -ge 1 ]]; then
    COMMIT_MSG="$*"
else
    COMMIT_MSG="Update dotfiles $(date +%Y-%m-%d)"
fi

# Commit if there is anything staged
if ! git diff --cached --quiet; then
    git commit -m "$COMMIT_MSG"
else
    echo "No staged changes to commit."
fi

# Push to the default branch of origin
git push origin HEAD

echo "Sync complete."
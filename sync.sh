#!/usr/bin/env bash

# sync.sh - Synchronize dotfiles with a remote Git repository.
# Supports pushing local changes, pulling remote updates, optional backup,
# conflict detection, and a --force flag to overwrite local changes.
#
# Usage:
#   ./sync.sh [options] [--push] [--pull]
#
# Options:
#   -b, --backup          Perform backup before pulling (default).
#   -n, --no-backup       Skip backup before pulling.
#   -f, --force           Overwrite local changes on conflict.
#   -h, --help            Show this help message and exit.
#
# If neither --push nor --pull is specified, both actions are performed
# (push then pull).

set -euo pipefail

# -------------------------- Configuration --------------------------

# Default backup directory (can be overridden by environment variable)
BACKUP_ROOT="${DOTFILES_BACKUP_DIR:-$HOME/.dotfiles_backup}"

# Determine the repository root (directory containing this script)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO_ROOT"

# -------------------------- Helper Functions --------------------------

print_help() {
    grep '^#' "$0" | cut -c4-
}

backup_current_state() {
    local timestamp
    timestamp="$(date +%Y%m%d%H%M%S)"
    local dest="${BACKUP_ROOT}/${timestamp}"
    echo "Backing up current dotfiles to ${dest} ..."
    mkdir -p "$dest"
    # Copy all tracked files except .git directory
    git ls-files -z | xargs -0 -I{} cp --parents -a "{}" "$dest"
    echo "Backup completed."
}

git_current_branch() {
    git rev-parse --abbrev-ref HEAD
}

push_changes() {
    echo "=== Pushing local changes ==="
    # Stage all changes (including deletions)
    git add -A

    # Check if there is anything to commit
    if git diff-index --quiet HEAD --; then
        echo "No local changes to commit."
    else
        local msg="Sync $(date '+%Y-%m-%d %H:%M:%S')"
        git commit -m "$msg"
        echo "Committed changes: $msg"
    fi

    echo "Pushing to remote..."
    git push
    echo "Push completed."
}

pull_changes() {
    echo "=== Pulling remote changes ==="
    local branch
    branch="$(git_current_branch)"

    # Fetch latest from remote
    git fetch

    # Attempt a fast‑forward merge first
    if git merge --ff-only "origin/${branch}"; then
        echo "Fast‑forward merge succeeded."
        return
    fi

    # If fast‑forward not possible, try a regular merge
    if git merge "origin/${branch}"; then
        echo "Merge succeeded without conflicts."
        return
    fi

    # Merge resulted in conflicts
    echo "Merge conflicts detected."
    if [[ "${FORCE_OVERWRITE:-false}" == true ]]; then
        echo "--force enabled: resetting local branch to remote state."
        git merge --abort || true
        git reset --hard "origin/${branch}"
        echo "Local branch reset to remote."
    else
        echo "Aborting merge. Resolve conflicts manually or re‑run with --force."
        git merge --abort || true
        exit 1
    fi
}

# -------------------------- Argument Parsing --------------------------

# Default actions
DO_PUSH=true
DO_PULL=true
DO_BACKUP=true
FORCE_OVERWRITE=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -b|--backup)
            DO_BACKUP=true
            shift
            ;;
        -n|--no-backup)
            DO_BACKUP=false
            shift
            ;;
        -f|--force)
            FORCE_OVERWRITE=true
            shift
            ;;
        --push)
            DO_PULL=false
            shift
            ;;
        --pull)
            DO_PUSH=false
            shift
            ;;
        -h|--help)
            print_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            print_help
            exit 1
            ;;
    esac
done

export FORCE_OVERWRITE

# -------------------------- Main Execution --------------------------

# Ensure we are inside a Git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Error: This directory is not a Git repository."
    exit 1
fi

# Create backup root if it does not exist
if [[ "$DO_BACKUP" == true ]]; then
    mkdir -p "$BACKUP_ROOT"
fi

# Push first (if requested)
if [[ "$DO_PUSH" == true ]]; then
    push_changes
fi

# Pull (if requested)
if [[ "$DO_PULL" == true ]]; then
    if [[ "$DO_BACKUP" == true ]]; then
        backup_current_state
    fi
    pull_changes
fi

echo "Sync operation completed successfully."
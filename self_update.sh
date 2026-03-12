#!/usr/bin/env bash
# self_update.sh - Update the dotfiles repository to the latest version.
# Usage: ./self_update.sh [--yes] [--no-install]
#   --yes          Automatically accept updates without prompting.
#   --no-install   Do not re-run install.sh after updating.

set -euo pipefail

# Helper functions
log() {
    echo -e "[self_update] $*"
}

error_exit() {
    echo -e "[self_update][ERROR] $*" >&2
    exit 1
}

# Parse arguments
AUTO_YES=false
RUN_INSTALL=true
while [[ $# -gt 0 ]]; do
    case "$1" in
        --yes)
            AUTO_YES=true
            shift
            ;;
        --no-install)
            RUN_INSTALL=false
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--yes] [--no-install]"
            exit 1
            ;;
    esac
done

# Determine repository root (works from any subdirectory)
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || error_exit "Not inside a git repository."
cd "$REPO_ROOT"

# Preserve current directory to return later
ORIG_PWD=$(pwd)

# Ensure we are on the default branch (usually main or master)
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@') || DEFAULT_BRANCH="main"
git checkout "$DEFAULT_BRANCH" >/dev/null 2>&1

# Stash any uncommitted changes
STASHED=false
if [[ -n "$(git status --porcelain)" ]]; then
    log "Uncommitted changes detected. Stashing them..."
    git stash push -m "self_update stash $(date +%s)" >/dev/null
    STASHED=true
fi

# Fetch latest changes and tags
log "Fetching latest changes from origin..."
if ! git fetch --tags origin; then
    error_exit "Network error: Unable to fetch from remote."
fi

# Determine if there are newer commits
LOCAL_HASH=$(git rev-parse HEAD)
REMOTE_HASH=$(git rev-parse "origin/$DEFAULT_BRANCH")

if [[ "$LOCAL_HASH" == "$REMOTE_HASH" ]]; then
    log "Repository is already up‑to‑date."
    # Restore stash if we created one
    if $STASHED; then
        log "Restoring stashed changes..."
        git stash pop || log "Warning: Could not apply stash cleanly."
    fi
    exit 0
fi

log "A newer version is available (remote $DEFAULT_BRANCH)."

# Prompt user unless --yes was supplied
if ! $AUTO_YES; then
    read -rp "Do you want to update now? [y/N] " answer
    case "$answer" in
        [Yy]* ) ;;
        * ) 
            log "Update aborted by user."
            if $STASHED; then
                log "Restoring stashed changes..."
                git stash pop || log "Warning: Could not apply stash cleanly."
            fi
            exit 0
            ;;
    esac
fi

# Pull the latest changes
log "Pulling latest changes..."
if ! git pull --rebase origin "$DEFAULT_BRANCH"; then
    error_exit "Failed to pull latest changes."
fi

# Re‑run install.sh if requested
if $RUN_INSTALL; then
    if [[ -x "./install.sh" ]]; then
        log "Re‑running install.sh..."
        if [[ -f ".install_opts" ]]; then
            # shellcheck disable=SC2086
            ./install.sh $(cat .install_opts)
        else
            ./install.sh
        fi
    else
        log "install.sh not found or not executable; skipping."
    fi
fi

# Restore stashed changes
if $STASHED; then
    log "Restoring stashed changes..."
    if ! git stash pop; then
        log "Warning: Could not apply stash cleanly. Manual resolution may be required."
    fi
fi

# Update backup rotation configuration if applicable
if [[ -f "backup.conf" ]]; then
    log "Updating backup rotation configuration..."
    # Placeholder: actual rotation logic would be repository‑specific.
    # For now we simply touch the file to indicate an update.
    touch backup.conf
fi

log "Update complete."
cd "$ORIG_PWD"
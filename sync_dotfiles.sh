#!/usr/bin/env bash
# sync_dotfiles.sh - Synchronize dotfiles repository with remote and optional GPG encryption.
# Usage: ./sync_dotfiles.sh [--pull|--push] [--dry-run]
#   --pull      Pull changes from the configured remote.
#   --push      Commit local changes and push to remote (default).
#   --dry-run   Show actions without executing them.

set -euo pipefail

# Helper to print messages
log() {
    echo "[sync_dotfiles] $*"
}

# Determine repository root (directory containing this script)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

# Load configuration from dotfiles.yml
CONFIG_FILE="dotfiles.yml"
if [[ ! -f "$CONFIG_FILE" ]]; then
    log "Configuration file $CONFIG_FILE not found."
    exit 1
fi

# Simple YAML parsing using awk (expects flat keys under sync:)
parse_yaml() {
    local key=$1
    awk -v key="$key" '
        $1 == "sync:" {found=1; next}
        found && $1 == key ":" {gsub(/^[ \t]+|[ \t]+$/,"",$3); print $3; exit}
    ' "$CONFIG_FILE"
}

REMOTE=$(parse_yaml "remote")
BRANCH=$(parse_yaml "branch")
ENCRYPT=$(parse_yaml "encrypt")

# Default values if not set
REMOTE=${REMOTE:-origin}
BRANCH=${BRANCH:-main}
ENCRYPT=${ENCRYPT:-false}

# Flags
DRY_RUN=false
ACTION="push"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --pull)
            ACTION="pull"
            shift
            ;;
        --push)
            ACTION="push"
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            log "Unknown argument: $1"
            exit 1
            ;;
    esac
done

run() {
    if $DRY_RUN; then
        echo "[dry-run] $*"
    else
        eval "$@"
    fi
}

git_pull() {
    log "Pulling from $REMOTE/$BRANCH"
    run "git fetch $REMOTE"
    run "git checkout $BRANCH"
    run "git pull $REMOTE $BRANCH"
}

git_commit_and_push() {
    # Detect changes
    if [[ -n "$(git status --porcelain)" ]]; then
        COMMIT_MSG="Sync dotfiles: $(date '+%Y-%m-%d %H:%M:%S')"
        log "Staging changes"
        run "git add -A"
        log "Committing: $COMMIT_MSG"
        run "git commit -m \"$COMMIT_MSG\""
    else
        log "No changes to commit."
    fi

    # Optional encryption of the latest diff
    if [[ "$ENCRYPT" == "true" ]]; then
        # Ensure GPG is available
        if ! command -v gpg >/dev/null 2>&1; then
            log "GPG not found but encryption is enabled. Skipping encryption."
        else
            # Generate diff of the most recent commit (if any)
            if git rev-parse HEAD~1 >/dev/null 2>&1; then
                DIFF_FILE="dotfiles.diff"
                ENC_FILE="${DIFF_FILE}.gpg"
                log "Creating diff for encryption"
                run "git diff HEAD~1 HEAD > $DIFF_FILE"
                log "Encrypting diff with GPG"
                run "gpg --yes --output $ENC_FILE --encrypt $DIFF_FILE"
                log "Adding encrypted diff to repository"
                run "git add $ENC_FILE"
                run "git commit -m \"Add encrypted diff $(date '+%Y-%m-%d %H:%M:%S')\""
                # Clean up plaintext diff
                run "rm -f $DIFF_FILE"
            else
                log "Not enough history to create diff for encryption."
            fi
        fi
    fi

    log "Pushing to $REMOTE/$BRANCH"
    run "git push $REMOTE $BRANCH"
}

case "$ACTION" in
    pull)
        git_pull
        ;;
    push)
        git_commit_and_push
        ;;
    *)
        log "Invalid action: $ACTION"
        exit 1
        ;;
esac
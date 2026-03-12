#!/usr/bin/env bash
# status.sh – report the state of managed dotfiles
#
# This script lists which managed files exist and, unless run with
# `--summary`, shows a unified diff between the repository (or backup)
# version and the file currently present on the system.
#
# Exit status:
#   0 – all managed files are identical to the source version
#   1 – at least one managed file differs or is missing

set -euo pipefail

# ----------------------------------------------------------------------
# Helper functions
# ----------------------------------------------------------------------
print_diff() {
    local src="$1"
    local dst="$2"
    local rel="$3"

    echo "Diff for $rel:"
    if command -v git >/dev/null 2>&1; then
        # git diff --no-index provides colourised output out‑of‑the‑box
        git diff --no-index --color "$src" "$dst" || true
    else
        # Fallback to classic diff with manual colourisation
        diff -u "$src" "$dst" |
            sed -e $'s/^\+/\\x1b[32m+/;s/^- /\\x1b[31m- /;s/^@@/\\x1b[36m@@/;s/$/\\x1b[0m/'
    fi
    echo
}

# ----------------------------------------------------------------------
# Argument parsing
# ----------------------------------------------------------------------
SUMMARY=0
if [[ "${1:-}" == "--summary" ]]; then
    SUMMARY=1
    shift
fi

# ----------------------------------------------------------------------
# Load configuration (if any)
# ----------------------------------------------------------------------
# Users may provide a config.sh that defines:
#   BACKUP_DIR – where backups are stored (default: $HOME/.dotfiles_backup)
#   MANAGED_FILES – an array of relative paths to managed files
#   REPO_ROOT – absolute path to the repository root (defaults to script's parent)
if [[ -f "./config.sh" ]]; then
    # shellcheck source=/dev/null
    source "./config.sh"
fi

# Default locations if not overridden by config.sh
REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
BACKUP_DIR="${BACKUP_DIR:-$HOME/.dotfiles_backup}"

# ----------------------------------------------------------------------
# Determine the list of managed files
# ----------------------------------------------------------------------
if declare -p MANAGED_FILES >/dev/null 2>&1; then
    : # already defined in config.sh
elif [[ -f "$REPO_ROOT/managed_files.txt" ]]; then
    mapfile -t MANAGED_FILES < "$REPO_ROOT/managed_files.txt"
else
    echo "Error: No managed files list found. Define MANAGED_FILES in config.sh or provide $REPO_ROOT/managed_files.txt"
    exit 2
fi

# ----------------------------------------------------------------------
# Main processing loop
# ----------------------------------------------------------------------
any_diff=0

for rel_path in "${MANAGED_FILES[@]}"; do
    # Resolve absolute paths
    repo_file="$REPO_ROOT/$rel_path"
    target_file="$HOME/$rel_path"
    backup_file="$BACKUP_DIR/$rel_path"

    # Choose source: backup if it exists, otherwise the repository version
    if [[ -f "$backup_file" ]]; then
        src_file="$backup_file"
    else
        src_file="$repo_file"
    fi

    # Report missing files
    if [[ ! -f "$target_file" ]]; then
        echo "Missing: $rel_path"
        any_diff=1
        continue
    fi

    # Compare files
    if diff -u "$src_file" "$target_file" >/dev/null 2>&1; then
        # Files are identical – nothing to report
        continue
    fi

    # Files differ
    any_diff=1
    if (( SUMMARY )); then
        echo "Changed: $rel_path"
    else
        print_diff "$src_file" "$target_file" "$rel_path"
    fi
done

# ----------------------------------------------------------------------
# Final status
# ----------------------------------------------------------------------
if (( any_diff )); then
    exit 1
else
    echo "All managed files are up‑to‑date."
    exit 0
fi
#!/usr/bin/env bash
#
# dotfiles clean – remove orphaned symlinks created by the dotfiles repository
#
# Usage:
#   dotfiles clean [--force] [--dry-run] [--help]
#
# Options:
#   --force    Remove orphaned symlinks without prompting.
#   --dry-run  Show what would be removed without actually deleting anything.
#   --help     Show this help message.
#
# The script scans the user's home directory (and any additional target
# directories defined in DOTFILES_TARGETS) for symlinks whose target resides
# inside the dotfiles repository. If the target file no longer exists, the
# symlink is considered orphaned and can be removed.

set -euo pipefail

# ------------------------------
# Helper functions
# ------------------------------

print_help() {
    grep '^#' "$0" | cut -c4-
    exit 0
}

error() {
    echo "error: $*" >&2
    exit 1
}

prompt_yes_no() {
    local prompt="$1"
    local reply
    while true; do
        read -r -p "$prompt [y/N] " reply
        case "$reply" in
            [Yy]*) return 0 ;;
            [Nn]*|'') return 1 ;;
        esac
    done
}

# ------------------------------
# Parse arguments
# ------------------------------

FORCE=0
DRY_RUN=0

while (( $# )); do
    case "$1" in
        --force) FORCE=1 ;;
        --dry-run) DRY_RUN=1 ;;
        --help) print_help ;;
        *) error "Unknown option: $1" ;;
    esac
    shift
done

# ------------------------------
# Determine repository root
# ------------------------------

# Assume this script lives in <repo_root>/bin/
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ------------------------------
# Determine target locations to scan
# ------------------------------

# By default we scan the user's home directory.
TARGET_DIRS=("$HOME")

# If the repository defines additional target directories via an env var
# or a file, honour them.  Users can export DOTFILES_TARGETS as a colon‑separated
# list (e.g. "$HOME/.config:$HOME/.local").
if [[ -n "${DOTFILES_TARGETS:-}" ]]; then
    IFS=':' read -ra ADDR <<< "$DOTFILES_TARGETS"
    TARGET_DIRS=("${ADDR[@]}")
fi

# ------------------------------
# Scan for orphaned symlinks
# ------------------------------

orphaned=()
while IFS= read -r -d '' link; do
    # Resolve the symlink target as an absolute path.
    # readlink -f works for both existing and broken links (it resolves as far as possible).
    target="$(readlink -f "$link" || true)"

    # If the target is empty, fallback to the raw link target (relative path).
    if [[ -z "$target" ]]; then
        target="$(readlink "$link")"
        # Resolve relative to the symlink's directory.
        if [[ "$target" != /* ]]; then
            target="$(cd "$(dirname "$link")" && pwd)/$target"
        fi
        target="$(cd -P "$target" 2>/dev/null || echo "$target")"
    fi

    # Consider only symlinks that point inside the repository.
    case "$target" in
        "$REPO_ROOT"/*) ;;
        *) continue ;;
    esac

    # If the source file no longer exists, mark as orphan.
    if [[ ! -e "$target" ]]; then
        orphaned+=("$link")
    fi
done < <(find "${TARGET_DIRS[@]}" -type l -print0)

# ------------------------------
# Report and act on orphans
# ------------------------------

if (( ${#orphaned[@]} == 0 )); then
    echo "No orphaned symlinks found."
    exit 0
fi

echo "Found ${#orphaned[@]} orphaned symlink(s):"
for link in "${orphaned[@]}"; do
    echo "  $link -> $(readlink "$link")"
done

if (( DRY_RUN )); then
    echo "Dry‑run mode: no changes will be made."
    exit 0
fi

if (( FORCE )); then
    echo "Removing all orphaned symlinks (force mode)..."
    for link in "${orphaned[@]}"; do
        rm -f "$link"
        echo "Removed $link"
    done
    exit 0
fi

# Interactive mode
echo "Proceed to remove the above symlinks?"
if prompt_yes_no "Confirm removal"; then
    for link in "${orphaned[@]}"; do
        if prompt_yes_no "Remove $link -> $(readlink "$link")?"; then
            rm -f "$link"
            echo "Removed $link"
        else
            echo "Skipped $link"
        fi
    done
else
    echo "Aborted."
    exit 0
fi
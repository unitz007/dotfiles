#!/usr/bin/env bash
# status.sh - Report the status of managed dotfiles.
# Supports a JSON output mode for CI integration.

set -euo pipefail

# ----------------------------------------------------------------------
# Configuration (these may be overridden by the surrounding environment)
# ----------------------------------------------------------------------
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
BACKUP_DIR="${BACKUP_DIR:-$HOME/.dotfiles_backup}"

# List of files managed by the dotfiles system.
# This list is expected to be maintained elsewhere; we provide a placeholder.
MANAGED_FILES=(
    ".bashrc"
    ".vimrc"
    ".gitconfig"
    # Add additional managed files here.
)

# ----------------------------------------------------------------------
# Argument parsing
# ----------------------------------------------------------------------
JSON_MODE=0
if [[ "${1:-}" == "--json" ]]; then
    JSON_MODE=1
    shift
fi

# ----------------------------------------------------------------------
# Helper functions
# ----------------------------------------------------------------------
file_present() {
    local target="$HOME/$1"
    [[ -e "$target" ]]
}

file_differs() {
    local target="$HOME/$1"
    local source="$DOTFILES_DIR/$1"
    if [[ -e "$target" && -e "$source" ]]; then
        ! diff -q "$target" "$source" >/dev/null 2>&1
    else
        false
    fi
}

backup_present() {
    local backup="$BACKUP_DIR/$1"
    [[ -e "$backup" ]]
}

# ----------------------------------------------------------------------
# Main processing
# ----------------------------------------------------------------------
if (( JSON_MODE )); then
    # Build a JSON array of status objects.
    json_items=()
    for file in "${MANAGED_FILES[@]}"; do
        present=$(file_present "$file" && echo true || echo false)
        diff=$(file_differs "$file" && echo true || echo false)
        backup=$(backup_present "$file" && echo true || echo false)

        # Escape double quotes in the filename (unlikely but safe)
        esc_file=$(printf '%s' "$file" | sed 's/"/\\"/g')
        json_items+=("{\"file\":\"$esc_file\",\"present\":$present,\"diff\":$diff,\"backup_exists\":$backup}")
    done

    # Output the JSON array
    printf '[\n'
    for i in "${!json_items[@]}"; do
        printf '  %s' "${json_items[$i]}"
        (( i < ${#json_items[@]} - 1 )) && printf ',\n' || printf '\n'
    done
    printf ']\n'
else
    # Human‑readable output (original behaviour)
    for file in "${MANAGED_FILES[@]}"; do
        echo "=== $file ==="
        if file_present "$file"; then
            echo "  Present: yes"
        else
            echo "  Present: no"
        fi

        if file_differs "$file"; then
            echo "  Diff:   differs from source"
        else
            echo "  Diff:   identical or missing source"
        fi

        if backup_present "$file"; then
            echo "  Backup: exists"
        else
            echo "  Backup: none"
        fi
        echo
    done
fi
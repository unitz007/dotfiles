#!/usr/bin/env bash
# diff.sh – compare repository dotfiles with those in the user's $HOME
#
# For each file tracked in this repository, this script prints a unified diff
# against the corresponding file in $HOME (if it exists).  Files that are not
# present in $HOME are skipped.  The script exits with status 0 when no
# differences are found, otherwise it exits with status 1.

set -euo pipefail

# Directory where this script resides – assumed to be the repository root.
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Files or directories that should never be considered dotfiles.
SKIP_PATTERNS=(
    ".git"
    ".gitignore"
    ".github"
    "README*"
    "LICENSE*"
    "install.sh"
    "diff.sh"
)

# Helper to decide whether a path should be ignored.
should_skip() {
    local path="$1"
    for pat in "${SKIP_PATTERNS[@]}"; do
        if [[ "$path" == $pat ]]; then
            return 0
        fi
    done
    return 1
}

has_diff=0

# Find all regular files in the repository (including sub‑directories).
while IFS= read -r -d '' repo_file; do
    # Compute path relative to the repository root.
    rel_path="${repo_file#$REPO_DIR/}"

    # Skip entries that match any of the skip patterns.
    should_skip "$rel_path" && continue

    # Only consider dotfiles (files whose relative path begins with a dot).
    # This also covers files inside dot‑directories such as .config/.
    if [[ "$rel_path" != .* ]]; then
        continue
    fi

    target_path="$HOME/$rel_path"

    # If the counterpart does not exist in $HOME, just note and continue.
    if [[ ! -e "$target_path" ]]; then
        echo "Skipping $rel_path – not present in \$HOME."
        continue
    fi

    # Perform a unified diff.  diff returns exit status 0 when files are identical,
    # 1 when differences are found, and >1 on error.
    if diff_output=$(diff -u "$target_path" "$repo_file") ; then
        # No differences – nothing to report.
        :
    else
        # diff exited with status 1 (differences) or >1 (error).  Treat any
        # non‑zero output as a difference to be shown.
        echo "Differences for $rel_path:"
        echo "$diff_output"
        has_diff=1
    fi
done < <(find "$REPO_DIR" -type f -print0)

exit $has_diff
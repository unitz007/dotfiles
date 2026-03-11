#!/usr/bin/env bash
# generate_docs.sh - Produce DOTFILES.md documentation for managed dotfiles
#
# This script scans the repository for files that are intended to be linked.
# It supports two discovery methods:
#   1. A `files.txt` manifest where each line contains: <source> <target>
#   2. A convention where files ending with `.symlink` are linked to $HOME/.<name>
#
# For each discovered file, the script extracts a short description from the
# leading comment block (first comment line after an optional shebang) and
# writes a markdown table to DOTFILES.md.

set -euo pipefail

# ---------------------------------------------------------------------------
# Helper: extract a one‑line description from the top of a file.
# ---------------------------------------------------------------------------
extract_description() {
    local file="$1"
    local desc="No description"

    # Only attempt extraction if the file exists and is readable.
    if [[ -r "$file" ]]; then
        while IFS= read -r line; do
            # Skip a possible shebang line.
            [[ "$line" =~ ^\#\! ]] && continue

            # Look for comment styles: # ...  or // ...
            if [[ "$line" =~ ^\#\ (.*) ]]; then
                desc="${BASH_REMATCH[1]}"
                break
            elif [[ "$line" =~ ^\#(.*) ]]; then
                desc="${BASH_REMATCH[1]}"
                break
            elif [[ "$line" =~ ^\/\/\ (.*) ]]; then
                desc="${BASH_REMATCH[1]}"
                break
            elif [[ "$line" =~ ^\/\/(.*) ]]; then
                desc="${BASH_REMATCH[1]}"
                break
            fi
        done < "$file"
    fi

    # Trim surrounding whitespace.
    desc="$(echo "$desc" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    echo "$desc"
}

# ---------------------------------------------------------------------------
# Prepare output file.
# ---------------------------------------------------------------------------
OUTPUT="DOTFILES.md"
TMPFILE="$(mktemp)"

{
    echo "# Dotfiles Overview"
    echo ""
    echo "| File | Target Path | Description |"
    echo "| ---- | ----------- | ----------- |"
} > "$TMPFILE"

# ---------------------------------------------------------------------------
# Discover managed files.
# ---------------------------------------------------------------------------
if [[ -f "files.txt" ]]; then
    # Manifest mode: each non‑empty, non‑comment line contains source and optional target.
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip blank lines and comments.
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

        src=$(echo "$line" | awk '{print $1}')
        tgt=$(echo "$line" | awk '{print $2}')

        # If target is omitted, assume $HOME/.<basename>.
        if [[ -z "$tgt" ]]; then
            base="$(basename "$src")"
            tgt="$HOME/.$base"
        fi

        desc="$(extract_description "$src")"
        printf "| \`%s\` | \`%s\` | %s |\n" "$src" "$tgt" "$desc" >> "$TMPFILE"
    done < "files.txt"
else
    # Convention mode: locate *.symlink files.
    while IFS= read -r src; do
        base="$(basename "$src")"
        name="${base%.symlink}"
        tgt="$HOME/.$name"

        desc="$(extract_description "$src")"
        printf "| \`%s\` | \`%s\` | %s |\n" "$src" "$tgt" "$desc" >> "$TMPFILE"
    done < <(find . -type f -name "*.symlink")
fi

# ---------------------------------------------------------------------------
# Write final markdown file.
# ---------------------------------------------------------------------------
mv "$TMPFILE" "$OUTPUT"
echo "Generated $OUTPUT"
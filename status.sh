#!/usr/bin/env bash
# dotfiles status – audit current setup
# Usage: dotfiles status [--json]

set -euo pipefail

# Repository root (directory containing this script)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$HOME"

# Containers for findings
declare -a mismatched_symlinks
declare -a missing_packages
declare -a outdated_fonts
declare -a missing_vscode_ext

# -------------------------------------------------------------------------
# 1. Symlink audit
# -------------------------------------------------------------------------
# For every regular file in the repo (excluding obvious non‑dotfile items)
# we expect a symlink at the same relative path inside $HOME.
find "$REPO_ROOT" -mindepth 1 -maxdepth 3 -type f \
    ! -name "status.sh" \
    ! -path "*/.git/*" \
    ! -name "*.md" \
    ! -name "*.txt" \
    ! -name "*.json" |
while IFS= read -r src; do
    rel="${src#$REPO_ROOT/}"
    target="$HOME_DIR/$rel"

    if [ -L "$target" ]; then
        link="$(readlink "$target")"
        if [ "$link" != "$src" ]; then
            mismatched_symlinks+=("$target -> $link (expected $src)")
        fi
    else
        mismatched_symlinks+=("$target (missing or not a symlink)")
    fi
done

# -------------------------------------------------------------------------
# 2. Package audit
# -------------------------------------------------------------------------
# packages.txt – one command name per line (comments start with #)
if [ -f "$REPO_ROOT/packages.txt" ]; then
    while IFS= read -r pkg; do
        [[ -z "$pkg" || "$pkg" == \#* ]] && continue
        if ! command -v "$pkg" >/dev/null 2>&1; then
            missing_packages+=("$pkg")
        fi
    done < "$REPO_ROOT/packages.txt"
fi

# -------------------------------------------------------------------------
# 3. Font audit
# -------------------------------------------------------------------------
# Fonts are stored in repo/fonts and should exist in
# $HOME/.local/share/fonts.  If the repo copy is newer, we flag it as outdated.
if [ -d "$REPO_ROOT/fonts" ]; then
    for font in "$REPO_ROOT"/fonts/*; do
        [ -e "$font" ] || continue
        fname="$(basename "$font")"
        target="$HOME_DIR/.local/share/fonts/$fname"

        if [ ! -f "$target" ]; then
            outdated_fonts+=("$fname (missing)")
        elif [ "$font" -nt "$target" ]; then
            outdated_fonts+=("$fname (outdated)")
        fi
    done
fi

# -------------------------------------------------------------------------
# 4. VSCode extension audit
# -------------------------------------------------------------------------
# vscode/extensions.txt – one extension identifier per line
if [ -f "$REPO_ROOT/vscode/extensions.txt" ]; then
    mapfile -t installed < <(code --list-extensions 2>/dev/null || true)
    while IFS= read -r ext; do
        [[ -z "$ext" || "$ext" == \#* ]] && continue
        if [[ ! " ${installed[*]} " =~ " $ext " ]]; then
            missing_vscode_ext+=("$ext")
        fi
    done < "$REPO_ROOT/vscode/extensions.txt"
fi

# -------------------------------------------------------------------------
# Output handling
# -------------------------------------------------------------------------
if [[ "${1:-}" == "--json" ]]; then
    # Build JSON manually – fallback to empty arrays if jq is unavailable
    json_array() {
        if command -v jq >/dev/null 2>&1; then
            printf '%s' "$1" | jq -R . | jq -s .
        else
            # Simple JSON array without escaping (good enough for our data)
            printf '['
            local first=1
            while IFS= read -r line; do
                [[ -z "$line" ]] && continue
                if (( first )); then first=0; else printf ','; fi
                printf '"%s"' "$(printf '%s' "$line" | sed 's/"/\\"/g')"
            done <<<"$1"
            printf ']'
        fi
    }

    printf '{\n'
    printf '  "mismatched_symlinks": %s,\n' "$(json_array "${mismatched_symlinks[*]}")"
    printf '  "missing_packages": %s,\n' "$(json_array "${missing_packages[*]}")"
    printf '  "outdated_fonts": %s,\n' "$(json_array "${outdated_fonts[*]}")"
    printf '  "missing_vscode_extensions": %s\n' "$(json_array "${missing_vscode_ext[*]}")"
    printf '}\n'
else
    echo "=== Symlink mismatches ==="
    if [ ${#mismatched_symlinks[@]} -eq 0 ]; then
        echo "All symlinks are correct."
    else
        printf '%s\n' "${mismatched_symlinks[@]}"
    fi
    echo

    echo "=== Missing packages ==="
    if [ ${#missing_packages[@]} -eq 0 ]; then
        echo "All packages are installed."
    else
        printf '%s\n' "${missing_packages[@]}"
    fi
    echo

    echo "=== Outdated or missing fonts ==="
    if [ ${#outdated_fonts[@]} -eq 0 ]; then
        echo "All fonts are up‑to‑date."
    else
        printf '%s\n' "${outdated_fonts[@]}"
    fi
    echo

    echo "=== Missing VSCode extensions ==="
    if [ ${#missing_vscode_ext[@]} -eq 0 ]; then
        echo "All VSCode extensions are installed."
    else
        printf '%s\n' "${missing_vscode_ext[@]}"
    fi
fi
#!/usr/bin/env bash
# status.sh - Report the status of managed dotfiles.
# Usage: ./status.sh [--json]
#   --json   Output results in JSON format.

set -euo pipefail

# Determine if JSON output is requested
JSON_OUTPUT=0
if [[ "${1:-}" == "--json" ]]; then
    JSON_OUTPUT=1
    shift
fi

# Resolve repository root (directory containing this script)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR" && pwd)"

# Path to the manifest file (fallback to files.txt)
MANIFEST="${REPO_ROOT}/files.txt"
if [[ ! -f "$MANIFEST" ]]; then
    echo "Error: Manifest file not found at $MANIFEST" >&2
    exit 1
fi

# Helper to escape JSON strings
json_escape() {
    printf '%s' "$1" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))'
}

# Collect results
declare -a RESULTS

while IFS= read -r line || [[ -n "$line" ]]; do
    # Trim leading/trailing whitespace
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    # Skip empty lines and comments
    [[ -z "$line" || "$line" == \#* ]] && continue

    # Support two-column format: <source> <target>
    # If only one column, target defaults to $HOME/.basename(source)
    read -r src_path target_path <<<"$line"

    src_abs="${REPO_ROOT}/${src_path}"
    if [[ ! -e "$src_abs" ]]; then
        echo "Warning: source file $src_abs does not exist; skipping." >&2
        continue
    fi

    if [[ -z "$target_path" ]]; then
        target_abs="${HOME}/.$(basename "$src_path")"
    else
        # If target_path starts with ~ or / treat as absolute, else relative to $HOME
        if [[ "$target_path" == /* || "$target_path" == ~* ]]; then
            target_abs="${target_path/#\~/$HOME}"
        else
            target_abs="${HOME}/${target_path}"
        fi
    fi

    # Determine status
    if [[ ! -e "$target_abs" ]]; then
        status="missing"
    elif [[ -L "$target_abs" ]]; then
        link_target="$(readlink -f "$target_abs")"
        src_real="$(readlink -f "$src_abs")"
        if [[ "$link_target" == "$src_real" ]]; then
            status="ok"
        else
            status="overridden"
        fi
    else
        status="overridden"
    fi

    if (( JSON_OUTPUT )); then
        # Build JSON object
        json_obj=$(printf '{"source":%s,"target":%s,"status":"%s"}' \
            "$(json_escape "$src_abs")" "$(json_escape "$target_abs")" "$status")
        RESULTS+=("$json_obj")
    else
        case "$status" in
            ok)        printf "[OK]        %s -> %s\n" "$target_abs" "$src_abs" ;;
            missing)   printf "[MISSING]   %s\n" "$target_abs" ;;
            overridden)printf "[OVERRIDDEN] %s (exists but not correct symlink)\n" "$target_abs" ;;
        esac
    fi
done < "$MANIFEST"

if (( JSON_OUTPUT )); then
    printf '[\n'
    for i in "${!RESULTS[@]}"; do
        printf '  %s' "${RESULTS[$i]}"
        (( i < ${#RESULTS[@]} - 1 )) && printf ','
        printf '\n'
    done
    printf ']\n'
fi
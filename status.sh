#!/usr/bin/env bash
# dotfiles status - audit current dotfiles setup
# Usage: dotfiles status [--json]

set -euo pipefail

# Determine script location and repository root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HOME_DIR="${HOME}"

# Parse flags
OUTPUT_JSON=false
while (( "$#" )); do
  case "$1" in
    --json) OUTPUT_JSON=true; shift ;;
    *) shift ;;
  esac
done

# Helper: escape JSON strings
json_escape() {
  printf '%s' "$1" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))'
}

# Gather all tracked files in the repository (excluding directories)
pushd "$REPO_ROOT" > /dev/null
mapfile -t REPO_FILES < <(git ls-files --recurse-submodules --exclude-standard)
popd > /dev/null

declare -A REPO_ABS
for rel in "${REPO_FILES[@]}"; do
  REPO_ABS["$rel"]="$REPO_ROOT/$rel"
done

# Result containers
declare -a SYMLINKED
declare -a MISSING_OR_BROKEN
declare -a MODIFIED
declare -a UNTRACKED

# Helper to compare files (binary safe)
files_differ() {
  cmp -s "$1" "$2"
}

# Scan repository files
for rel in "${!REPO_ABS[@]}"; do
  src="${REPO_ABS[$rel]}"
  tgt="$HOME_DIR/$rel"

  # Ensure target directory exists for comparison
  tgt_dir="$(dirname "$tgt")"
  if [[ ! -d "$tgt_dir" ]]; then
    MISSING_OR_BROKEN+=("$rel (target directory missing)")
    continue
  fi

  if [[ -L "$tgt" ]]; then
    link_target="$(readlink -f "$tgt")"
    if [[ "$link_target" == "$src" ]]; then
      SYMLINKED+=("$rel")
    else
      if [[ ! -e "$tgt" ]]; then
        MISSING_OR_BROKEN+=("$rel (broken symlink)")
      else
        MISSING_OR_BROKEN+=("$rel (symlink points elsewhere)")
      fi
    fi
  elif [[ -e "$tgt" ]]; then
    # Regular file exists – compare contents
    if files_differ "$src" "$tgt"; then
      MODIFIED+=("$rel")
    else
      # Identical file but not a symlink – treat as correctly linked for audit purposes
      SYMLINKED+=("$rel (identical regular file)")
    fi
  else
    MISSING_OR_BROKEN+=("$rel (missing)")
  fi
done

# Detect untracked files in target locations
# Walk through all files under $HOME that correspond to repo relative paths
while IFS= read -r -d '' file; do
  # Compute relative path from $HOME
  rel_path="${file#$HOME_DIR/}"
  # If this path is not managed by the repo, mark as untracked
  if [[ -z "${REPO_ABS[$rel_path]+_}" ]]; then
    # Exclude typical system directories (e.g., .cache, .local) to reduce noise
    case "$rel_path" in
      .cache*|.local*|.Trash*|.npm*|.nvm*|.config/*) continue ;;
    esac
    UNTRACKED+=("$rel_path")
  fi
done < <(find "$HOME_DIR" -type f -print0)

# Output
if $OUTPUT_JSON; then
  {
    printf '{'
    printf '"symlinked":['
    first=true
    for p in "${SYMLINKED[@]}"; do
      $first && first=false || printf ','
      json_escape "$p"
    done
    printf '],'
    printf '"missing_or_broken":['
    first=true
    for p in "${MISSING_OR_BROKEN[@]}"; do
      $first && first=false || printf ','
      json_escape "$p"
    done
    printf '],'
    printf '"modified":['
    first=true
    for p in "${MODIFIED[@]}"; do
      $first && first=false || printf ','
      json_escape "$p"
    done
    printf '],'
    printf '"untracked":['
    first=true
    for p in "${UNTRACKED[@]}"; do
      $first && first=false || printf ','
      json_escape "$p"
    done
    printf ']'
    printf '}'
  } > /dev/stdout
else
  echo "=== Dotfiles Status Report ==="
  echo
  echo "✅ Correctly symlinked files:"
  if [[ ${#SYMLINKED[@]} -eq 0 ]]; then
    echo "  (none)"
  else
    for p in "${SYMLINKED[@]}"; do echo "  $p"; done
  fi
  echo
  echo "⚠️  Missing or broken symlinks:"
  if [[ ${#MISSING_OR_BROKEN[@]} -eq 0 ]]; then
    echo "  (none)"
  else
    for p in "${MISSING_OR_BROKEN[@]}"; do echo "  $p"; done
  fi
  echo
  echo "✏️  Modified (different from repository):"
  if [[ ${#MODIFIED[@]} -eq 0 ]]; then
    echo "  (none)"
  else
    for p in "${MODIFIED[@]}"; do echo "  $p"; done
  fi
  echo
  echo "📁 Untracked files in $HOME:"
  if [[ ${#UNTRACKED[@]} -eq 0 ]]; then
    echo "  (none)"
  else
    for p in "${UNTRACKED[@]}"; do echo "  $p"; done
  fi
  echo
fi
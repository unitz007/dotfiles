#!/usr/bin/env bash
# dotfiles diff – show configuration drift between repository and system
# Usage: dotfiles diff [--tool <diff-tool>]
#   --tool   Specify the diff program to use (default: diff)

set -euo pipefail

# Default diff tool
DIFF_TOOL="diff"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --tool)
      if [[ -z "${2-}" ]]; then
        echo "Error: --tool requires an argument"
        exit 1
      fi
      DIFF_TOOL="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

# Determine repository root (assumes this script lives inside the repo)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "$SCRIPT_DIR/..")"
YAML_PATH="$REPO_ROOT/dotfiles.yml"

if [[ ! -f "$YAML_PATH" ]]; then
  echo "Error: dotfiles.yml not found at $YAML_PATH"
  exit 1
fi

# Load mapping from dotfiles.yml using Python (requires PyYAML)
# Expected format: { source_path: target_path, ... }
mapfile -t MAPPINGS < <(
python - <<PY
import yaml, sys, os
yaml_path = os.getenv('YAML_PATH')
with open(yaml_path, 'r') as f:
    data = yaml.safe_load(f) or {}
for src, tgt in data.items():
    # Normalise paths (strip surrounding whitespace)
    src = str(src).strip()
    tgt = str(tgt).strip()
    print(f"{src}\t{tgt}")
PY
)

# Helper to expand ~ to $HOME
expand_path() {
  local p="$1"
  if [[ "$p" == "~"* ]]; then
    echo "${p/#\~/$HOME}"
  else
    echo "$p"
  fi
}

# Iterate over each mapping and report status
for line in "${MAPPINGS[@]}"; do
  src_rel="${line%%$'\t'*}"
  tgt_raw="${line#*$'\t'}"

  src_path="$REPO_ROOT/$src_rel"
  tgt_path="$(expand_path "$tgt_raw")"

  if [[ ! -e "$tgt_path" ]]; then
    status="MISSING"
  elif [[ ! -e "$src_path" ]]; then
    status="SOURCE_MISSING"
  else
    if cmp -s "$src_path" "$tgt_path"; then
      status="UNCHANGED"
    else
      status="MODIFIED"
    fi
  fi

  printf "%-12s %s -> %s\n" "$status" "$src_path" "$tgt_path"

  if [[ "$status" == "MODIFIED" ]]; then
    if command -v "$DIFF_TOOL" >/dev/null 2>&1; then
      echo "Diff ($DIFF_TOOL):"
      "$DIFF_TOOL" -u "$src_path" "$tgt_path" | sed 's/^/  /'
    else
      echo "  [Error] Diff tool '$DIFF_TOOL' not found in PATH"
    fi
  fi
done
#!/bin/bash
set -euo pipefail

DRY_RUN=0

# Argument parsing
for arg in "$@"; do
  case "$arg" in
    --dry-run)
      DRY_RUN=1
      ;;
    *)
      echo "Usage: $0 [--dry-run]" >&2
      exit 1
      ;;
  esac
done

# Determine repo root
REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"

# Symlink mapping: "source_relative_to_repo|destination_relative_to_HOME"
MAPPINGS=(
  ".aerospace.toml|.aerospace.toml"
  ".skhdrc|.skhdrc"
  ".zshrc|.zshrc"
  ".oh-my-posh-theme.json|.oh-my-posh-theme.json"
  ".gitconfig|.gitconfig"
  "nvim|.config/nvim"
  "tmux/tmux.conf|.tmux.conf"
  "yazi.toml|.config/yazi.toml"
  "zed/settings.json|.config/zed/settings.json"
)

FAILED=0

for mapping in "${MAPPINGS[@]}"; do
  IFS='|' read -r SRC_REL DST_REL <<< "$mapping"

  SRC_ABS="$REPO_ROOT/$SRC_REL"
  DST_ABS="$HOME/$DST_REL"

  # Validate source exists
  if [ ! -e "$SRC_ABS" ]; then
    echo "⚠ Source not found, skipping: $SRC_REL" >&2
    continue
  fi

  # Check if already correctly linked
  if [ -L "$DST_ABS" ] && [ "$(readlink "$DST_ABS")" == "$SRC_ABS" ]; then
    echo "✓ Already linked: $DST_REL"
    continue
  fi

  # Handle existing target (backup)
  if [ -e "$DST_ABS" ] || [ -L "$DST_ABS" ]; then
    echo "⚠ Backing up: $DST_REL → $DST_REL.bak"
    if [ "$DRY_RUN" -eq 0 ]; then
      if ! mv "$DST_ABS" "$DST_ABS.bak"; then
        echo "Error: Failed to back up $DST_REL" >&2
        FAILED=1
        continue
      fi
    fi
  fi

  # Create parent directories
  DST_PARENT="$(dirname "$DST_ABS")"
  if [ ! -d "$DST_PARENT" ]; then
    echo "→ Creating directory: $DST_PARENT"
    if [ "$DRY_RUN" -eq 0 ]; then
      mkdir -p "$DST_PARENT"
    fi
  fi

  # Create symlink
  echo "→ Linking: $DST_REL → $SRC_REL"
  if [ "$DRY_RUN" -eq 0 ]; then
    if ! ln -s "$SRC_ABS" "$DST_ABS"; then
      echo "Error: Failed to create symlink $DST_REL" >&2
      FAILED=1
    fi
  fi
done

# Summary
if [ "$DRY_RUN" -eq 1 ]; then
  echo "Dry run complete. No changes were made."
fi

if [ "$FAILED" -eq 1 ]; then
  echo "Error: One or more symlinks failed to create." >&2
  exit 1
fi

echo "All dotfiles linked successfully."
exit 0

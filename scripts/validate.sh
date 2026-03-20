#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

ERRORS=0
CHECKED=0

check_file() {
  local description="$1"
  shift

  printf "Checking %s ... " "$description"
  if output=$("$@" 2>&1); then
    echo "OK"
    CHECKED=$((CHECKED + 1))
  else
    echo "FAILED"
    echo "$output"
    ERRORS=$((ERRORS + 1))
  fi
}

# a) Lua files — nvim loadfile syntax check
for lua_file in nvim/init.lua nvim/lua/*.lua nvim/lua/plugins/*.lua; do
  [ -f "$REPO_ROOT/$lua_file" ] || continue
  check_file "$lua_file" nvim --headless --clean \
    -c "lua local ok, err = loadfile('$REPO_ROOT/$lua_file'); if not ok then print(err); vim.cmd('cq') end" \
    -c "q"
done

# b) JSON files — Python json module
for json_file in .oh-my-posh-theme.json .sdlc.json zed/settings.json; do
  [ -f "$REPO_ROOT/$json_file" ] || continue
  check_file "$json_file" python3 -c "import json, sys; json.load(open(sys.argv[1]))" "$REPO_ROOT/$json_file"
done

# c) TOML files — Python tomllib (3.11+) with fallback
for toml_file in .aerospace.toml yazi.toml; do
  [ -f "$REPO_ROOT/$toml_file" ] || continue
  check_file "$toml_file" python3 -c "
import sys
try:
    import tomllib
except ImportError:
    try:
        import tomli as tomllib
    except ImportError:
        print('ERROR: Python 3.11+ or tomli package required for TOML validation')
        sys.exit(1)
tomllib.load(open(sys.argv[1], 'rb'))
" "$REPO_ROOT/$toml_file"
done

# d) Zsh syntax check
check_file ".zshrc" zsh -n "$REPO_ROOT/.zshrc"

# e) skhd config check (optional)
if command -v skhd &>/dev/null; then
  if pgrep -x skhd &>/dev/null; then
    echo "Skipping skhd check (skhd is already running)"
  else
    check_file ".skhdrc" skhd -c "$REPO_ROOT/.skhdrc"
  fi
else
  echo "Skipping skhd check (skhd not found)"
fi

# f) tmux config check
check_file "tmux/tmux.conf" tmux -f "$REPO_ROOT/tmux/tmux.conf" start-server \; kill-server

# Summary
echo ""
echo "=== Validation Summary ==="
echo "Checked: $CHECKED files"
if [ "$ERRORS" -gt 0 ]; then
  echo "Failed: $ERRORS files"
  exit 1
else
  echo "All checks passed!"
  exit 0
fi

#!/usr/bin/env sh
# Setup script to install repository‑wide Git hooks.
# Copies the hook scripts from the repository's hooks/ directory into the
# local .git/hooks directory and makes them executable.

set -e

# Determine the repository root.
REPO_ROOT="$(git rev-parse --show-toplevel)"

# Destination directory for Git hooks.
HOOKS_DIR="$REPO_ROOT/.git/hooks"

# Ensure the hooks directory exists.
if [ ! -d "$HOOKS_DIR" ]; then
    echo "Error: .git/hooks directory not found. Are you inside a Git repository?"
    exit 1
fi

# List of hooks to install.
HOOKS_TO_INSTALL="pre-commit"

for hook in $HOOKS_TO_INSTALL; do
    src="$REPO_ROOT/hooks/$hook"
    dest="$HOOKS_DIR/$hook"

    if [ -f "$src" ]; then
        cp "$src" "$dest"
        chmod +x "$dest"
        echo "Installed $hook hook."
    else
        echo "Warning: Hook script $src not found; skipping."
    fi
done

echo "All hooks installed successfully."
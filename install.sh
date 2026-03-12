#!/usr/bin/env bash
set -e

# ----------------------------------------------------------------------
# Helper Functions
# ----------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

backup_and_link() {
    local src="$1"
    local dest="$2"

    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        local backup="${dest}.backup.$(date +%s)"
        echo "Backing up existing $dest to $backup"
        mv "$dest" "$backup"
    fi

    echo "Linking $src → $dest"
    ln -sfn "$src" "$dest"
}

# ----------------------------------------------------------------------
# Bash Installer (existing logic – placeholder)
# ----------------------------------------------------------------------
install_bash() {
    if ! command -v bash >/dev/null 2>&1; then
        echo "Bash not found – skipping Bash configuration."
        return
    fi

    echo "Installing Bash configuration..."
    local bash_src="${SCRIPT_DIR}/bash"
    local bash_dest="${HOME}/.bashrc"

    backup_and_link "${bash_src}/.bashrc" "$bash_dest"
}

# ----------------------------------------------------------------------
# Zsh Installer (existing logic – placeholder)
# ----------------------------------------------------------------------
install_zsh() {
    if ! command -v zsh >/dev/null 2>&1; then
        echo "Zsh not found – skipping Zsh configuration."
        return
    fi

    echo "Installing Zsh configuration..."
    local zsh_src="${SCRIPT_DIR}/zsh"
    local zsh_dest="${HOME}/.zshrc"

    backup_and_link "${zsh_src}/.zshrc" "$zsh_dest"
}

# ----------------------------------------------------------------------
# Fish Installer (new)
# ----------------------------------------------------------------------
install_fish() {
    if ! command -v fish >/dev/null 2>&1; then
        echo "Fish shell not detected – skipping Fish configuration."
        return
    fi

    echo "Installing Fish configuration..."
    local fish_config_dir="${HOME}/.config/fish"
    local repo_fish_dir="${SCRIPT_DIR}/fish"

    backup_and_link "$repo_fish_dir" "$fish_config_dir"

    # Install Fisher (a popular Fish plugin manager) if it's not already present
    if command -v fisher >/dev/null 2>&1; then
        echo "Fisher already installed."
    else
        echo "Installing Fisher..."
        fish -c 'curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher'
    fi
}

# ----------------------------------------------------------------------
# OS‑specific handling (WSL detection)
# ----------------------------------------------------------------------
if grep -qi microsoft /proc/version 2>/dev/null; then
    echo "Detected Windows Subsystem for Linux (WSL)."
    # Currently no special handling is required for Fish on WSL,
    # but this block is kept for future adjustments.
fi

# ----------------------------------------------------------------------
# Run installers
# ----------------------------------------------------------------------
install_bash
install_zsh
install_fish

echo "All supported shells have been processed."
exit 0
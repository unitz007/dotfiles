#!/usr/bin/env bash

set -e

# Existing installation logic...
# (Assumed to be present above)

# -------------------------------------------------
# Zsh component handling
# -------------------------------------------------

# Function to check if a key is enabled in dotfiles.yml
yaml_key_enabled() {
    local key="$1"
    # Simple grep to find a line like "zsh: true" (ignoring case and spaces)
    grep -E "^\s*${key}\s*:\s*true\s*$" dotfiles.yml >/dev/null 2>&1
}

# Detect Zsh and process if enabled
if command -v zsh >/dev/null 2>&1 && yaml_key_enabled "zsh"; then
    echo "Zsh detected and enabled in configuration."

    ZINIT_DIR="${HOME}/.zinit"

    # Clone Zinit if not already present
    if [ ! -d "${ZINIT_DIR}" ]; then
        echo "Cloning Zinit plugin manager..."
        git clone https://github.com/zdharma-continuum/zinit.git "${ZINIT_DIR}"
    else
        echo "Zinit already installed."
    fi

    # Install minimal .zshrc
    ZSHRC_SOURCE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/zsh/.zshrc"
    ZSHRC_TARGET="${HOME}/.zshrc"

    echo "Installing .zshrc to ${ZSHRC_TARGET}"
    cp -f "${ZSHRC_SOURCE}" "${ZSHRC_TARGET}"

    echo "Zsh setup complete."
else
    echo "Zsh not detected or disabled in dotfiles.yml – skipping Zsh component."
fi

# Continue with any remaining installation steps...
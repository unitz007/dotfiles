#!/usr/bin/env bash

# Existing install script content...
# (Assuming the original script performs necessary setup tasks)

# Install Zsh completion for dotfiles management scripts
COMPLETION_DIR="${HOME}/.zsh/completions"
mkdir -p "${COMPLETION_DIR}"

# Determine the directory where this install script resides
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Copy the completion file to the user's Zsh completions directory
if [[ -f "${SCRIPT_DIR}/_dotfiles" ]]; then
    cp "${SCRIPT_DIR}/_dotfiles" "${COMPLETION_DIR}/_dotfiles"
    echo "Zsh completion installed to ${COMPLETION_DIR}/_dotfiles"
else
    echo "Warning: _dotfiles completion file not found; skipping Zsh completion installation."
fi

# Continue with any remaining install steps...
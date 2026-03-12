#!/usr/bin/env bash
# Installation script for dotfiles manager.
# Copies configuration files, scripts, and shell completions to the appropriate locations.

set -e

# ... existing installation logic ...

# Install Zsh completion (existing)
if [[ -d "${ZSH_COMPLETION_DIR:-$HOME/.zsh/completions}" ]]; then
    cp "completions/_dotfiles.zsh" "${ZSH_COMPLETION_DIR:-$HOME/.zsh/completions}/_dotfiles"
fi

# Install Bash completion
if [[ -d "${BASH_COMPLETION_DIR:-$HOME/.bash_completion.d}" ]]; then
    cp "completions/_dotfiles.bash" "${BASH_COMPLETION_DIR:-$HOME/.bash_completion.d}/_dotfiles"
fi

# Install Fish completion
if [[ -d "${FISH_COMPLETION_DIR:-$HOME/.config/fish/completions}" ]]; then
    cp "completions/dotfiles.fish" "${FISH_COMPLETION_DIR:-$HOME/.config/fish/completions}/dotfiles.fish"
fi

# ... any remaining installation steps ...

echo "Installation complete. Shell completions have been installed."
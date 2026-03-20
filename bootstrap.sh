#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Kitty
mkdir -p "$HOME/.config/kitty"
ln -sfn "$DOTFILES_DIR/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"

# Neovim
mkdir -p "$HOME/.config/nvim"
ln -sfn "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

# tmux
mkdir -p "$HOME/.config/tmux"
ln -sfn "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"

# Zed
mkdir -p "$HOME/.config/zed"
ln -sfn "$DOTFILES_DIR/zed/settings.json" "$HOME/.config/zed/settings.json"

# AeroSpace
ln -sfn "$DOTFILES_DIR/.aerospace.toml" "$HOME/.aerospace.toml"

# skhd
ln -sfn "$DOTFILES_DIR/.skhdrc" "$HOME/.skhdrc"

# Zsh
ln -sfn "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

# Oh My Posh theme
ln -sfn "$DOTFILES_DIR/.oh-my-posh-theme.json" "$HOME/.oh-my-posh-theme.json"

# Yazi
ln -sfn "$DOTFILES_DIR/yazi.toml" "$HOME/.config/yazi.toml"

echo "✓ Dotfiles deployed successfully"

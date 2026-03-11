#!/usr/bin/env bash
set -e

# Determine the directory where this script resides
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# List of dotfiles to symlink (add new Zsh files here)
DOTFILES=(
  .bashrc
  .vimrc
  .gitconfig
  .zshrc
  .zshenv
)

backup_and_link() {
  local src="$1"
  local dest="$2"

  # If a regular file/directory exists (and is not already a symlink), back it up
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    local timestamp
    timestamp=$(date +%s)
    local backup="${dest}.backup.${timestamp}"
    echo "Backing up existing $dest to $backup"
    mv "$dest" "$backup"
  fi

  # Create/replace the symlink
  ln -sf "$src" "$dest"
  echo "Linked $src -> $dest"
}

# Symlink each dotfile
for file in "${DOTFILES[@]}"; do
  src="${DIR}/${file}"
  dest="${HOME}/${file}"
  if [ -e "$src" ]; then
    backup_and_link "$src" "$dest"
  else
    echo "Warning: $src does not exist, skipping."
  fi
done

# ----------------------------------------------------------------------
# Optional Oh My Zsh installation
# ----------------------------------------------------------------------
read -p "Do you want to install Oh My Zsh? (y/N): " omz_answer
if [[ "$omz_answer" =~ ^[Yy]$ ]]; then
  if [ -d "${HOME}/.oh-my-zsh" ]; then
    echo "Oh My Zsh is already installed at ${HOME}/.oh-my-zsh."
  else
    echo "Installing Oh My Zsh..."
    # Use the official unattended installer
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi
fi

# ----------------------------------------------------------------------
# Optional zinit (Zsh plugin manager) installation
# ----------------------------------------------------------------------
read -p "Do you want to install zinit plugin manager? (y/N): " zinit_answer
if [[ "$zinit_answer" =~ ^[Yy]$ ]]; then
  ZINIT_DIR="${ZDOTDIR:-$HOME}/.zinit"
  if [ -d "$ZINIT_DIR" ]; then
    echo "zinit is already installed at $ZINIT_DIR."
  else
    echo "Installing zinit..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma-continuum/zinit/master/doc/install.sh)"
  fi
fi

echo "Installation complete."
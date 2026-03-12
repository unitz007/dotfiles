#!/usr/bin/env bash
set -euo pipefail

# ----------------------------------------------------------------------
# Load user configuration (dotfiles.yml) to enable/disable components.
# ----------------------------------------------------------------------
# Determine repository root (directory containing this script)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${REPO_ROOT}/dotfiles.yml"

# Default: all components enabled
ENABLE_ZSH=true
ENABLE_NEOVIM=true
ENABLE_FISH=true
ENABLE_FONTS=true
ENABLE_SECRETS=true

if [[ -f "${CONFIG_FILE}" ]]; then
  # Use yq (https://github.com/mikefarah/yq) to read boolean values.
  # If a key is missing, fall back to true (enabled).
  ENABLE_ZSH=$(yq e '.components.zsh // true' "${CONFIG_FILE}")
  ENABLE_NEOVIM=$(yq e '.components.neovim // true' "${CONFIG_FILE}")
  ENABLE_FISH=$(yq e '.components.fish // true' "${CONFIG_FILE}")
  ENABLE_FONTS=$(yq e '.components.fonts // true' "${CONFIG_FILE}")
  ENABLE_SECRETS=$(yq e '.components.secrets // true' "${CONFIG_FILE}")
fi

# Helper to normalize yq output (true/false) to lowercase strings
normalize_bool() {
  local val="${1,,}"
  if [[ "$val" == "true" || "$val" == "yes" || "$val" == "1" ]]; then
    echo "true"
  else
    echo "false"
  fi
}

ENABLE_ZSH=$(normalize_bool "$ENABLE_ZSH")
ENABLE_NEOVIM=$(normalize_bool "$ENABLE_NEOVIM")
ENABLE_FISH=$(normalize_bool "$ENABLE_FISH")
ENABLE_FONTS=$(normalize_bool "$ENABLE_FONTS")
ENABLE_SECRETS=$(normalize_bool "$ENABLE_SECRETS")

# ----------------------------------------------------------------------
# Installation functions for each component.
# ----------------------------------------------------------------------
install_zsh() {
  echo "Installing Zsh configuration..."
  # ---- Begin original Zsh installation steps ----
  # (Place the original Zsh installation commands here)
  # Example:
  # sudo apt-get install -y zsh
  # chsh -s "$(which zsh)"
  # ---- End original Zsh installation steps ----
}

install_neovim() {
  echo "Installing Neovim configuration..."
  # ---- Begin original Neovim installation steps ----
  # (Place the original Neovim installation commands here)
  # Example:
  # sudo apt-get install -y neovim
  # ---- End original Neovim installation steps ----
}

install_fish() {
  echo "Installing Fish configuration..."
  # ---- Begin original Fish installation steps ----
  # (Place the original Fish installation commands here)
  # Example:
  # sudo apt-get install -y fish
  # ---- End original Fish installation steps ----
}

install_fonts() {
  echo "Installing fonts..."
  # ---- Begin original fonts installation steps ----
  # (Place the original fonts installation commands here)
  # Example:
  # mkdir -p "${HOME}/.local/share/fonts"
  # cp ./fonts/* "${HOME}/.local/share/fonts/"
  # fc-cache -fv
  # ---- End original fonts installation steps ----
}

install_secrets() {
  echo "Setting up secrets..."
  # ---- Begin original secrets installation steps ----
  # (Place the original secrets installation commands here)
  # Example:
  # gpg --import ./secrets/*.gpg
  # ---- End original secrets installation steps ----
}

# ----------------------------------------------------------------------
# Conditional execution based on configuration.
# ----------------------------------------------------------------------
if [[ "$ENABLE_ZSH" == "true" ]]; then
  install_zsh
else
  echo "Skipping Zsh installation (disabled in config)."
fi

if [[ "$ENABLE_NEOVIM" == "true" ]]; then
  install_neovim
else
  echo "Skipping Neovim installation (disabled in config)."
fi

if [[ "$ENABLE_FISH" == "true" ]]; then
  install_fish
else
  echo "Skipping Fish installation (disabled in config)."
fi

if [[ "$ENABLE_FONTS" == "true" ]]; then
  install_fonts
else
  echo "Skipping fonts installation (disabled in config)."
fi

if [[ "$ENABLE_SECRETS" == "true" ]]; then
  install_secrets
else
  echo "Skipping secrets setup (disabled in config)."
fi

echo "Installation complete."
#!/usr/bin/env bash
set -e

# ------------------------------------------------------------------
# Existing installation steps
# (Preserve any logic that was already present in this script)
# ------------------------------------------------------------------

# ------------------------------------------------------------------
# Neovim configuration setup
# ------------------------------------------------------------------
if command -v nvim >/dev/null 2>&1; then
    echo "Neovim detected – setting up configuration..."

    CONFIG_DIR="${HOME}/.config/nvim"
    REPO_NVIM_DIR="$(pwd)/nvim"

    # Remove any existing config (symlink or directory)
    if [ -L "${CONFIG_DIR}" ] || [ -d "${CONFIG_DIR}" ]; then
        echo "Removing existing ${CONFIG_DIR}"
        rm -rf "${CONFIG_DIR}"
    fi

    echo "Creating symlink: ${REPO_NVIM_DIR} -> ${CONFIG_DIR}"
    ln -s "${REPO_NVIM_DIR}" "${CONFIG_DIR}"

    # ------------------------------------------------------------------
    # Install packer.nvim if it is not already present
    # ------------------------------------------------------------------
    PACKER_DIR="${XDG_DATA_HOME:-${HOME}/.local/share}/nvim/site/pack/packer/start/packer.nvim"
    if [ ! -d "${PACKER_DIR}" ]; then
        echo "Installing packer.nvim..."
        git clone --depth 1 https://github.com/wbthomason/packer.nvim "${PACKER_DIR}"
    else
        echo "packer.nvim already installed."
    fi

    # ------------------------------------------------------------------
    # Install/Update plugins defined in init.lua
    # ------------------------------------------------------------------
    echo "Synchronizing plugins with Packer..."
    nvim --headless +PackerSync +qa

    echo "Neovim configuration setup complete."
else
    echo "Neovim not found – skipping Neovim configuration."
fi
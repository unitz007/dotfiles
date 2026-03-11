#!/usr/bin/env bash
# install_deps.sh - Detect and optionally install common plugin managers.
# Supported managers:
#   * oh-my-zsh
#   * fisher (Fish)
#   * vim-plug (Vim/Neovim)
#   * packer.nvim (Neovim)

set -euo pipefail

# Helper to ask yes/no questions
prompt_yes_no() {
    local prompt_msg="$1"
    while true; do
        read -rp "$prompt_msg [y/N]: " answer
        case "$answer" in
            [Yy]* ) return 0 ;;
            [Nn]*|"" ) return 1 ;;
            * ) echo "Please answer y or n." ;;
        esac
    done
}

# Detect OS (used for potential future extensions)
OS_TYPE="$(uname -s)"
case "$OS_TYPE" in
    Linux*)   OS=Linux ;;
    Darwin*)  OS=Mac ;;
    *)        OS=Other ;;
esac

# ---------- oh-my-zsh ----------
if [ -d "${HOME}/.oh-my-zsh" ]; then
    echo "✅ oh-my-zsh is already installed."
else
    echo "⚠️ oh-my-zsh not found."
    if prompt_yes_no "Install oh-my-zsh?"; then
        echo "Installing oh-my-zsh..."
        # The official installer works on both Linux and macOS
        RUNZSH=no KEEP_ZSHRC=yes \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        echo "✅ oh-my-zsh installed."
    else
        echo "⏭️ Skipping oh-my-zsh."
    fi
fi

# ---------- fisher (Fish) ----------
if command -v fish >/dev/null 2>&1 && fish -c 'type -q fisher' >/dev/null 2>&1; then
    echo "✅ fisher is already installed."
else
    echo "⚠️ fisher not found."
    if command -v fish >/dev/null 2>&1; then
        if prompt_yes_no "Install fisher (Fish plugin manager)?"; then
            echo "Installing fisher..."
            fish -c 'curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher'
            echo "✅ fisher installed."
        else
            echo "⏭️ Skipping fisher."
        fi
    else
        echo "❌ Fish shell is not installed; cannot install fisher."
    fi
fi

# ---------- vim-plug ----------
VIM_PLUG_PATH_VIM="${HOME}/.vim/autoload/plug.vim"
VIM_PLUG_PATH_NVIM="${HOME}/.local/share/nvim/site/autoload/plug.vim"

if [ -f "$VIM_PLUG_PATH_VIM" ] || [ -f "$VIM_PLUG_PATH_NVIM" ]; then
    echo "✅ vim-plug is already installed."
else
    echo "⚠️ vim-plug not found."
    if prompt_yes_no "Install vim-plug for Vim and Neovim?"; then
        echo "Installing vim-plug..."
        # Vim
        curl -fLo "$VIM_PLUG_PATH_VIM" --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        # Neovim
        curl -fLo "$VIM_PLUG_PATH_NVIM" --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        echo "✅ vim-plug installed."
    else
        echo "⏭️ Skipping vim-plug."
    fi
fi

# ---------- packer.nvim ----------
PACKER_PATH="${HOME}/.local/share/nvim/site/pack/packer/start/packer.nvim"

if [ -d "$PACKER_PATH" ]; then
    echo "✅ packer.nvim is already installed."
else
    echo "⚠️ packer.nvim not found."
    if command -v git >/dev/null 2>&1; then
        if prompt_yes_no "Install packer.nvim (Neovim plugin manager)?"; then
            echo "Installing packer.nvim..."
            git clone --depth 1 https://github.com/wbthomason/packer.nvim "$PACKER_PATH"
            echo "✅ packer.nvim installed."
        else
            echo "⏭️ Skipping packer.nvim."
        fi
    else
        echo "❌ git is not installed; cannot install packer.nvim."
    fi
fi

echo "✅ Dependency check complete."
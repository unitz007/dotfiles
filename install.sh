#!/usr/bin/env bash
# install.sh - Setup dotfiles and required packages for Linux and macOS

set -euo pipefail

# Helper functions
log() {
    echo -e "\033[1;32m[INFO]\033[0m $*"
}
error() {
    echo -e "\033[1;31m[ERROR]\033[0m $*" >&2
    exit 1
}

# Determine OS
OS_TYPE="$(uname -s)"
log "Detected OS: $OS_TYPE"

# ----------------------------------------------------------------------
# macOS specific installation
# ----------------------------------------------------------------------
if [[ "$OS_TYPE" == "Darwin" ]]; then
    log "Running macOS specific setup"

    # Ensure Homebrew is installed
    if ! command -v brew >/dev/null 2>&1; then
        log "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || error "Failed to install Homebrew"
        # Add brew to PATH for the current script session
        if [[ -d /opt/homebrew/bin ]]; then
            export PATH="/opt/homebrew/bin:$PATH"
        elif [[ -d /usr/local/bin ]]; then
            export PATH="/usr/local/bin:$PATH"
        fi
    else
        log "Homebrew already installed"
    fi

    # Install required packages via Homebrew
    BREW_PACKAGES=(
        coreutils   # GNU core utilities (g-prefixed)
        git
        fish
    )
    for pkg in "${BREW_PACKAGES[@]}"; do
        if brew list "$pkg" >/dev/null 2>&1; then
            log "Homebrew package '$pkg' already installed"
        else
            log "Installing Homebrew package: $pkg"
            brew install "$pkg" || error "Failed to install $pkg via Homebrew"
        fi
    done

    # Copy or symlink macOS‑specific dotfiles
    DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    MACOS_DOTFILES_DIR="${DOTFILES_DIR}/macos"

    # Ensure the macos directory exists
    if [[ ! -d "$MACOS_DOTFILES_DIR" ]]; then
        error "macOS dotfiles directory not found at $MACOS_DOTFILES_DIR"
    fi

    # List of macOS‑only dotfiles to install (source => target)
    declare -A MACOS_DOTFILES=(
        ["${MACOS_DOTFILES_DIR}/.bash_profile"]="${HOME}/.bash_profile"
        ["${MACOS_DOTFILES_DIR}/.zshrc"]="${HOME}/.zshrc"
    )

    for src target in "${!MACOS_DOTFILES[@]}"; do
        if [[ -e "$target" || -L "$target" ]]; then
            log "Backing up existing $target to ${target}.bak"
            mv -f "$target" "${target}.bak"
        fi
        log "Linking $src -> $target"
        ln -sfn "$src" "$target"
    done

    log "macOS setup complete."
    exit 0
fi

# ----------------------------------------------------------------------
# Linux / generic setup (existing logic)
# ----------------------------------------------------------------------
log "Running generic (Linux) setup"

# Example generic dotfile handling – adjust as needed for the actual repo
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
declare -A LINUX_DOTFILES=(
    ["${DOTFILES_DIR}/bashrc"]="${HOME}/.bashrc"
    ["${DOTFILES_DIR}/gitconfig"]="${HOME}/.gitconfig"
    # Add more generic dotfiles here
)

for src target in "${!LINUX_DOTFILES[@]}"; do
    if [[ -e "$target" || -L "$target" ]]; then
        log "Backing up existing $target to ${target}.bak"
        mv -f "$target" "${target}.bak"
    fi
    log "Linking $src -> $target"
    ln -sfn "$src" "$target"
done

log "All done! 🎉"
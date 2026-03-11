#!/usr/bin/env bash
# install.sh - Link dotfiles into the user's home directory.
# Enhanced to automatically select OS‑specific configuration files when available.
# Supports Linux, macOS (Darwin) and WSL (Windows Subsystem for Linux).

set -euo pipefail

# ----------------------------------------------------------------------
# Determine the operating system.
# ----------------------------------------------------------------------
detect_os() {
    local uname_out
    uname_out="$(uname -s)"
    case "${uname_out}" in
        Linux*)
            # Detect WSL (both legacy and WSL2)
            if grep -qi microsoft /proc/version 2>/dev/null; then
                echo "wsl"
            else
                echo "linux"
            fi
            ;;
        Darwin*)
            echo "macos"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

OS="$(detect_os)"
# Normalise OS string for file suffixes
case "$OS" in
    linux)   OS_SUFFIX="linux" ;;
    macos)   OS_SUFFIX="macos" ;;
    wsl)     OS_SUFFIX="wsl" ;;
    *)       OS_SUFFIX="generic" ;;
esac

# ----------------------------------------------------------------------
# Resolve the directory containing this script (the dotfiles repository).
# ----------------------------------------------------------------------
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ----------------------------------------------------------------------
# List of dotfiles to install (base names without leading dot).
# Add new entries here as needed.
# ----------------------------------------------------------------------
DOTFILES=(
    bashrc
    vimrc
    gitconfig
    # Example: add more files like "zshrc" etc.
)

# ----------------------------------------------------------------------
# Helper: Return the best source file for a given base name.
# Preference order:
#   1. OS‑specific file (e.g., .bashrc.linux)
#   2. Generic file without suffix (e.g., .bashrc)
# If neither exists, the function prints an empty string.
# ----------------------------------------------------------------------
source_file() {
    local base_name="$1"
    local candidate

    # 1. OS‑specific version
    candidate="${DOTFILES_DIR}/.${base_name}.${OS_SUFFIX}"
    if [[ -f "$candidate" ]]; then
        echo "$candidate"
        return
    fi

    # 2. Generic version (no suffix)
    candidate="${DOTFILES_DIR}/.${base_name}"
    if [[ -f "$candidate" ]]; then
        echo "$candidate"
        return
    fi

    # No matching file
    echo ""
}

# ----------------------------------------------------------------------
# Main linking loop.
# ----------------------------------------------------------------------
for base in "${DOTFILES[@]}"; do
    src="$(source_file "$base")"
    if [[ -z "$src" ]]; then
        echo "⚠️  No source file found for .$base (OS: $OS). Skipping."
        continue
    fi

    dest="${HOME}/.${base}"
    echo "🔗 Linking ${src} → ${dest}"
    ln -sf "$src" "$dest"
done

echo "✅ Installation complete for OS: $OS"
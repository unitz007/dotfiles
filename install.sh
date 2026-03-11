#!/usr/bin/env bash
# install.sh - Symlink dotfiles into the user's home directory.
# Supports Bash, Zsh, and Fish shells.

set -euo pipefail

# Determine the directory containing this script (the dotfiles repo root)
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default shell detection (can be overridden with --shell=)
DEFAULT_SHELL="$(basename "${SHELL:-}")"

# Parse command‑line arguments
TARGET_SHELL="${DEFAULT_SHELL}"
while [[ $# -gt 0 ]]; do
    case "$1" in
        --shell=*)
            TARGET_SHELL="${1#--shell=}"
            shift
            ;;
        -h|--help)
            cat <<EOF
Usage: $0 [--shell=sh]

Options:
  --shell=sh   Specify the target shell (bash, zsh, fish). If omitted,
               the script auto‑detects the current user shell.
  -h, --help   Show this help message.
EOF
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Helper to create a symlink, backing up any existing file
link_file() {
    local src="$1"
    local dest="$2"

    if [[ -e "${dest}" && ! -L "${dest}" ]]; then
        echo "Backing up existing file ${dest} to ${dest}.bak"
        mv "${dest}" "${dest}.bak"
    fi

    ln -sf "${src}" "${dest}"
    echo "Linked ${src} → ${dest}"
}

# ----------------------------------------------------------------------
# Common dotfiles (bash, zsh, git, etc.)
# ----------------------------------------------------------------------
COMMON_FILES=(
    .bashrc
    .zshrc
    .gitconfig
    .vimrc
)

for file in "${COMMON_FILES[@]}"; do
    src="${DOTFILES_DIR}/${file}"
    if [[ -e "${src}" ]]; then
        link_file "${src}" "${HOME}/${file}"
    fi
done

# ----------------------------------------------------------------------
# Shell‑specific configuration
# ----------------------------------------------------------------------
case "${TARGET_SHELL}" in
    bash)
        # Bash specific files are already covered in COMMON_FILES
        ;;
    zsh)
        # Zsh specific files are already covered in COMMON_FILES
        ;;
    fish)
        # Ensure the Fish config directory exists
        FISH_CONFIG_DIR="${HOME}/.config/fish"
        mkdir -p "${FISH_CONFIG_DIR}"

        # Link config.fish
        src="${DOTFILES_DIR}/fish/config.fish"
        if [[ -e "${src}" ]]; then
            link_file "${src}" "${FISH_CONFIG_DIR}/config.fish"
        fi

        # Link optional fish_plugins if it exists
        src_plugins="${DOTFILES_DIR}/fish/fish_plugins"
        if [[ -e "${src_plugins}" ]]; then
            link_file "${src_plugins}" "${FISH_CONFIG_DIR}/fish_plugins"
        fi
        ;;
    *)
        echo "Warning: Unrecognised shell '${TARGET_SHELL}'. No shell‑specific files will be linked."
        ;;
esac

echo "Installation complete."
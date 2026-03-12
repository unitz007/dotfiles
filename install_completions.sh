#!/usr/bin/env bash
# install_completions.sh – Install Bash and Fish completions for the `dotfiles` CLI.
# The script copies the generated completion files into the standard locations
# for each shell. It is safe to run multiple times; existing files will be
# overwritten.

set -euo pipefail

# Resolve the directory containing this script (repo root).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install_bash_completion() {
    # Prefer the system-wide directory if it exists and is writable.
    local target_dir="/etc/bash_completion.d"
    if [[ -d "$target_dir" && -w "$target_dir" ]]; then
        local target_path="${target_dir}/dotfiles"
    else
        # Fallback to the user’s home directory.
        local target_path="${HOME}/.bash_completion"
    fi

    echo "Installing Bash completion to ${target_path}"
    cp "${SCRIPT_DIR}/_dotfiles.bash" "${target_path}"
    echo "Bash completion installed."
}

install_fish_completion() {
    local target_dir="${HOME}/.config/fish/completions"
    mkdir -p "${target_dir}"
    local target_path="${target_dir}/dotfiles.fish"

    echo "Installing Fish completion to ${target_path}"
    cp "${SCRIPT_DIR}/dotfiles.fish" "${target_path}"
    echo "Fish completion installed."
}

install_bash_completion
install_fish_completion

echo "All completions installed. Restart your shell or source the completion files to activate them."
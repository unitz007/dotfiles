#!/usr/bin/env bash
# install_zsh.sh - Install Oh My Zsh, configure .zshrc and required plugins.

set -euo pipefail

# ----------------------------------------------------------------------
# Helper: Print messages with a consistent prefix
# ----------------------------------------------------------------------
log() {
    echo "[install_zsh] $*"
}

# ----------------------------------------------------------------------
# Determine repository root (where this script lives)
# ----------------------------------------------------------------------
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ----------------------------------------------------------------------
# 1. Install Oh My Zsh if missing
# ----------------------------------------------------------------------
if [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
    log "Oh My Zsh not found. Installing..."
    # Use the official unattended installer
    RUNZSH=no KEEP_ZSHRC=yes sh -c \
        "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    log "Oh My Zsh installed."
else
    log "Oh My Zsh already present."
fi

# ----------------------------------------------------------------------
# 2. Symlink the repository's .zshrc to the user's home directory
# ----------------------------------------------------------------------
if [[ -f "${REPO_ROOT}/.zshrc" ]]; then
    ln -sf "${REPO_ROOT}/.zshrc" "${HOME}/.zshrc"
    log "Symlinked .zshrc to ${HOME}/.zshrc"
else
    log "Warning: ${REPO_ROOT}/.zshrc not found – skipping symlink."
fi

# ----------------------------------------------------------------------
# 3. Ensure required plugins are installed
# ----------------------------------------------------------------------
ZSH_CUSTOM="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}"
PLUGIN_DIR="${ZSH_CUSTOM}/plugins"

declare -A PLUGIN_REPOS=(
    ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions.git"
    ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting.git"
)

install_plugin() {
    local name=$1
    local repo=$2
    local target="${PLUGIN_DIR}/${name}"

    if [[ -d "${target}" ]]; then
        log "Plugin '${name}' already installed."
        return
    fi

    log "Installing plugin '${name}' from ${repo}..."
    git clone --depth=1 "${repo}" "${target}"
    log "Plugin '${name}' installed."
}

# Ensure the plugins directory exists
mkdir -p "${PLUGIN_DIR}"

for plugin in "${!PLUGIN_REPOS[@]}"; do
    install_plugin "${plugin}" "${PLUGIN_REPOS[${plugin}]}"
done

# ----------------------------------------------------------------------
# 4. Enable plugins in .zshrc
# ----------------------------------------------------------------------
# Build the plugins list: include built‑in 'git' plus the custom ones
ENABLED_PLUGINS=("git")
for plugin in "${!PLUGIN_REPOS[@]}"; do
    ENABLED_PLUGINS+=("${plugin}")
done

# Convert array to space‑separated string
PLUGIN_STRING="${ENABLED_PLUGINS[*]}"

# Use sed to replace the plugins line in .zshrc (if it exists)
ZSHRC_PATH="${HOME}/.zshrc"
if grep -qE '^plugins=' "${ZSHRC_PATH}"; then
    sed -i.bak -E "s/^plugins=.*/plugins=(${PLUGIN_STRING})/" "${ZSHRC_PATH}"
    log "Updated plugins line in .zshrc."
else
    # Append a plugins line at the end if none exists
    echo -e "\nplugins=(${PLUGIN_STRING})" >> "${ZSHRC_PATH}"
    log "Appended plugins line to .zshrc."
fi

log "Zsh environment setup complete."
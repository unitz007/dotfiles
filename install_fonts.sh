#!/usr/bin/env bash
# install_fonts.sh - Install fonts defined in dotfiles.yml
# Supports macOS (Homebrew), Linux (apt), and Windows (Chocolatey)
# Font entries can be URLs (downloaded) or package names (installed via package manager)

set -euo pipefail

# Determine OS
OS_TYPE="unknown"
case "$(uname -s)" in
    Darwin) OS_TYPE="macos" ;;
    Linux) OS_TYPE="linux" ;;
    CYGWIN*|MINGW*|MSYS*) OS_TYPE="windows" ;;
    *) echo "Unsupported OS: $(uname -s)"; exit 1 ;;
esac

# Determine font directory based on OS
case "$OS_TYPE" in
    macos) FONT_DIR="${HOME}/Library/Fonts" ;;
    linux) FONT_DIR="${HOME}/.local/share/fonts" ;;
    windows) FONT_DIR="${HOME}/AppData/Local/Microsoft/Windows/Fonts" ;;
esac

mkdir -p "$FONT_DIR"

# Helper to check if a string is a URL
is_url() {
    [[ "$1" =~ ^https?:// ]]
}

# Load fonts array from dotfiles.yml using yq (assumes yq is available)
if ! command -v yq >/dev/null 2>&1; then
    echo "yq is required to parse dotfiles.yml"
    exit 1
fi

if [[ ! -f "dotfiles.yml" ]]; then
    echo "dotfiles.yml not found in current directory"
    exit 1
fi

# Read fonts array; if not present, exit gracefully
mapfile -t fonts < <(yq eval '.fonts[]?' dotfiles.yml 2>/dev/null || true)

if [[ ${#fonts[@]} -eq 0 ]]; then
    echo "No fonts defined in dotfiles.yml"
    exit 0
fi

install_package() {
    local pkg="$1"
    case "$OS_TYPE" in
        macos)
            if command -v brew >/dev/null 2>&1; then
                brew install "$pkg"
            else
                echo "Homebrew not found; cannot install $pkg"
                return 1
            fi
            ;;
        linux)
            if command -v apt-get >/dev/null 2>&1; then
                sudo apt-get update -qq
                sudo apt-get install -y "$pkg"
            else
                echo "apt-get not found; cannot install $pkg"
                return 1
            fi
            ;;
        windows)
            if command -v choco >/dev/null 2>&1; then
                choco install "$pkg" -y
            else
                echo "Chocolatey not found; cannot install $pkg"
                return 1
            fi
            ;;
    esac
}

download_font() {
    local url="$1"
    local filename
    filename="$(basename "$url")"
    local dest="${FONT_DIR}/${filename}"
    echo "Downloading $url → $dest"
    curl -L -o "$dest" "$url"
    # On Linux, refresh font cache
    if [[ "$OS_TYPE" == "linux" ]]; then
        if command -v fc-cache >/dev/null 2>&1; then
            fc-cache -f "$FONT_DIR"
        fi
    fi
}

for entry in "${fonts[@]}"; do
    if is_url "$entry"; then
        download_font "$entry"
    else
        install_package "$entry"
    fi
done

echo "Font installation complete."
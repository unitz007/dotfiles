#!/usr/bin/env bash
# install_fonts.sh - Download and install the latest FiraCode Nerd Font
# Supports Linux, macOS, and Windows (via PowerShell)

set -euo pipefail

# Determine OS
OS_TYPE="$(uname -s)"
case "$OS_TYPE" in
    Linux*)   OS="Linux" ;;
    Darwin*)  OS="Mac" ;;
    CYGWIN*|MINGW*|MSYS*) OS="Windows" ;;
    *) echo "Unsupported OS: $OS_TYPE" >&2; exit 1 ;;
esac

# Font configuration
FONT_NAME="FiraCode"
ASSET_NAME="${FONT_NAME}.zip"
DOWNLOAD_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${ASSET_NAME}"

# Temporary directories
TMP_DIR="$(mktemp -d)"
ZIP_PATH="${TMP_DIR}/${ASSET_NAME}"
EXTRACT_DIR="${TMP_DIR}/extracted"

# Cleanup function
cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

echo "Downloading ${FONT_NAME} Nerd Font..."
curl -L -o "$ZIP_PATH" "$DOWNLOAD_URL"

echo "Extracting font archive..."
mkdir -p "$EXTRACT_DIR"
unzip -q "$ZIP_PATH" -d "$EXTRACT_DIR"

# Determine install directory based on OS
case "$OS" in
    Linux)
        FONT_DIR="${HOME}/.local/share/fonts"
        ;;
    Mac)
        FONT_DIR="${HOME}/Library/Fonts"
        ;;
    Windows)
        # PowerShell will handle the destination path
        FONT_DIR="$(powershell -NoProfile -Command \"[System.Environment]::GetFolderPath('LocalApplicationData')\")\\Microsoft\\Windows\\Fonts"
        ;;
esac

echo "Installing fonts to ${FONT_DIR}..."
mkdir -p "$FONT_DIR"

# Copy .ttf and .otf files
shopt -s nullglob
FONT_FILES=("$EXTRACT_DIR"/*.ttf "$EXTRACT_DIR"/*.otf)
if [ ${#FONT_FILES[@]} -eq 0 ]; then
    echo "No font files found in the archive." >&2
    exit 1
fi

if [ "$OS" = "Windows" ]; then
    # Use PowerShell to copy files (handles Windows path quirks)
    for f in "${FONT_FILES[@]}"; do
        powershell -NoProfile -Command "Copy-Item -Path '$(cygpath -w "$f")' -Destination '${FONT_DIR}' -Force"
    done
else
    cp "${FONT_FILES[@]}" "$FONT_DIR/"
fi

# Refresh font cache on Linux
if [ "$OS" = "Linux" ]; then
    echo "Refreshing font cache..."
    fc-cache -f "$FONT_DIR"
fi

echo "Font installation completed successfully."
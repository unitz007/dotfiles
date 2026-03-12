#!/usr/bin/env bash
# install_deps.sh
# -------------------------------------------------
# Checks for essential development tools and installs any that are missing.
# Supports macOS (Homebrew), Linux (apt, dnf, pacman) and Windows (winget).
# The script is idempotent – it only installs tools that are not already present.
# -------------------------------------------------

set -u

# List of required tools
REQUIRED_TOOLS=(
    git
    zsh
    fish
    curl
    gnupg   # provides the `gpg` command
)

# Detect OS and set package manager commands
detect_os_and_pkg_manager() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        PKG_INSTALL_CMD="brew install"
        SUDO_CMD=""   # Homebrew manages its own permissions
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        if command -v apt-get >/dev/null 2>&1; then
            PKG_MANAGER="apt"
            PKG_INSTALL_CMD="sudo apt-get update && sudo apt-get install -y"
        elif command -v dnf >/dev/null 2>&1; then
            PKG_MANAGER="dnf"
            PKG_INSTALL_CMD="sudo dnf install -y"
        elif command -v pacman >/dev/null 2>&1; then
            PKG_MANAGER="pacman"
            PKG_INSTALL_CMD="sudo pacman -Sy --noconfirm"
        else
            echo "Unsupported Linux distribution: no known package manager found."
            exit 1
        fi
    elif command -v winget >/dev/null 2>&1; then
        OS="windows"
        PKG_INSTALL_CMD="winget install --silent --accept-source-agreements --accept-package-agreements"
    else
        echo "Unsupported operating system: $OSTYPE"
        exit 1
    fi
}

# Check if a command exists
is_installed() {
    command -v "$1" >/dev/null 2>&1
}

# Install a single package using the previously detected command
install_package() {
    local pkg="$1"
    echo "Attempting to install $pkg..."
    if [[ "$OS" == "macos" ]]; then
        $PKG_INSTALL_CMD "$pkg"
    elif [[ "$OS" == "linux" ]]; then
        eval "$PKG_INSTALL_CMD $pkg"
    elif [[ "$OS" == "windows" ]]; then
        $PKG_INSTALL_CMD "$pkg"
    else
        echo "Unknown OS, cannot install $pkg."
        return 1
    fi
}

# Main execution
main() {
    detect_os_and_pkg_manager
    echo "Detected OS: $OS"
    echo "Using package install command: $PKG_INSTALL_CMD"
    echo ""

    for tool in "${REQUIRED_TOOLS[@]}"; do
        echo -n "Checking for $tool... "
        if is_installed "$tool"; then
            echo "found."
        else
            echo "not found."
            # Map tool name to package name if they differ (currently they match)
            pkg_name="$tool"
            # Special case: gnupg provides the `gpg` binary
            if [[ "$tool" == "gnupg" ]]; then
                pkg_name="gnupg"
            fi
            install_package "$pkg_name"
            if is_installed "$tool"; then
                echo "$tool installed successfully."
            else
                echo "Failed to install $tool. Please install it manually."
                EXIT_CODE=1
            fi
        fi
        echo ""
    done

    if [[ "${EXIT_CODE:-0}" -ne 0 ]]; then
        echo "One or more tools failed to install."
        exit $EXIT_CODE
    else
        echo "All required tools are present."
    fi
}

main
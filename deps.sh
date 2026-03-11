#!/usr/bin/env bash

# deps.sh - Install required development tools if missing.
# Supports apt-get (Debian/Ubuntu), brew (macOS), pacman (Arch Linux).
# Safe to run multiple times; only installs missing tools.

set -euo pipefail

# List of required commands/tools
REQUIRED_TOOLS=(git tmux zsh fish)

# Detect package manager
detect_pkg_manager() {
    if [[ "$(uname -s)" == "Darwin" ]]; then
        if command -v brew >/dev/null 2>&1; then
            echo "brew"
            return
        else
            echo "Error: Homebrew not found. Please install Homebrew first." >&2
            exit 1
        fi
    elif [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian)
                echo "apt-get"
                ;;
            arch|archlinux)
                echo "pacman"
                ;;
            *)
                echo "Error: Unsupported Linux distribution: $ID" >&2
                exit 1
                ;;
        esac
    else
        echo "Error: Unable to detect operating system." >&2
        exit 1
    fi
}

PKG_MANAGER=$(detect_pkg_manager)

# Build install command based on package manager
install_cmd() {
    case "$PKG_MANAGER" in
        apt-get)
            sudo apt-get update -qq
            echo sudo apt-get install -y "$@"
            ;;
        brew)
            echo brew install "$@"
            ;;
        pacman)
            sudo pacman -Sy --noconfirm "$@"
            ;;
        *)
            echo "Error: Unknown package manager $PKG_MANAGER" >&2
            exit 1
            ;;
    esac
}

# Determine which tools are missing
MISSING=()
for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        MISSING+=("$tool")
    fi
done

if [[ ${#MISSING[@]} -eq 0 ]]; then
    echo "All required tools are already installed."
    exit 0
fi

echo "The following tools are missing and will be installed: ${MISSING[*]}"

# Run the appropriate install command
install_cmd "${MISSING[@]}"

echo "Installation complete. Verifying installations..."

# Verify each tool is now available
for tool in "${REQUIRED_TOOLS[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "✔ $tool is installed."
    else
        echo "✖ $tool could not be installed. Please install it manually."
    fi
done
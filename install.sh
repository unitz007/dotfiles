#!/usr/bin/env bash

# install.sh - Setup script for dotfiles
# Supports macOS (Homebrew) and various Linux distributions.

set -euo pipefail

# Function to read package list from dotfiles.yml
read_packages() {
    local yaml_file="dotfiles.yml"
    if [[ ! -f "$yaml_file" ]]; then
        echo "Error: $yaml_file not found."
        exit 1
    fi

    # Extract the list under the top‑level key 'packages:'
    # Supports simple YAML lists:
    # packages:
    #   - git
    #   - curl
    awk '
        $0 ~ /^packages:/ { flag=1; next }
        flag && $0 ~ /^[[:space:]]*-/ {
            sub(/^[[:space:]]*-[[:space:]]*/, "", $0)
            print $0
        }
        flag && $0 !~ /^[[:space:]]*-/ { flag=0 }
    ' "$yaml_file"
}

# Detect OS and install missing dependencies
install_missing_packages() {
    local packages=("$@")
    local missing=()

    # Determine which command to use for checking existence
    for pkg in "${packages[@]}"; do
        if ! command -v "$pkg" >/dev/null 2>&1; then
            missing+=("$pkg")
        fi
    done

    if [[ ${#missing[@]} -eq 0 ]]; then
        echo "All required packages are already installed."
        return
    fi

    echo "The following packages are missing: ${missing[*]}"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS – use Homebrew
        if ! command -v brew >/dev/null 2>&1; then
            echo "Homebrew not found. Installing Homebrew first..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        echo "Installing missing packages via Homebrew..."
        brew install "${missing[@]}"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux – detect package manager
        local installer_cmd=""
        if command -v apt-get >/dev/null 2>&1; then
            installer_cmd="sudo apt-get update && sudo apt-get install -y"
        elif command -v dnf >/dev/null 2>&1; then
            installer_cmd="sudo dnf install -y"
        elif command -v pacman >/dev/null 2>&1; then
            installer_cmd="sudo pacman -Sy --noconfirm"
        elif command -v zypper >/dev/null 2>&1; then
            installer_cmd="sudo zypper install -y"
        else
            echo "Unsupported or unknown Linux package manager."
            echo "Please install the following packages manually: ${missing[*]}"
            return 1
        fi

        echo "Installing missing packages via detected package manager..."
        eval "$installer_cmd \"${missing[@]}\""
    else
        echo "Unsupported operating system: $OSTYPE"
        echo "Please install the following packages manually: ${missing[*]}"
        return 1
    fi
}

main() {
    # Read required packages from dotfiles.yml
    mapfile -t pkg_list < <(read_packages)

    if [[ ${#pkg_list[@]} -eq 0 ]]; then
        echo "No packages defined in dotfiles.yml."
        exit 0
    fi

    install_missing_packages "${pkg_list[@]}"

    # Add any additional setup steps below
    # e.g., linking dotfiles, configuring shells, etc.
}

main "$@"
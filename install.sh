#!/usr/bin/env bash
set -e

# ----------------------------------------------------------------------
# Existing setup logic (Linux / Windows) is assumed to be present above.
# ----------------------------------------------------------------------

# Determine the operating system
OS_TYPE="unknown"
case "$(uname -s)" in
    Linux*)   OS_TYPE="Linux" ;;
    Darwin*)  OS_TYPE="Mac" ;;
    CYGWIN*|MINGW*|MSYS*) OS_TYPE="Windows" ;;
    *)        OS_TYPE="Unknown" ;;
esac

# ----------------------------------------------------------------------
# macOS specific installation
# ----------------------------------------------------------------------
if [[ "$OS_TYPE" == "Mac" ]]; then
    echo "Detected macOS. Starting macOS specific setup..."

    # --------------------------------------------------------------
    # Homebrew installation
    # --------------------------------------------------------------
    if ! command -v brew >/dev/null 2>&1; then
        echo "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Ensure brew is on PATH for the remainder of this script
        if [[ -x "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"   # Apple Silicon
        elif [[ -x "/usr/local/bin/brew" ]]; then
            eval "$(/usr/local/bin/brew shellenv)"     # Intel
        fi
    else
        echo "Homebrew is already installed."
    fi

    # --------------------------------------------------------------
    # Install packages from Brewfile
    # --------------------------------------------------------------
    if [[ -f "./Brewfile" ]]; then
        echo "Running 'brew bundle' with Brewfile..."
        brew bundle --file=./Brewfile
    else
        echo "Warning: Brewfile not found in repository root. Skipping brew bundle."
    fi

    # --------------------------------------------------------------
    # Apply common macOS defaults
    # --------------------------------------------------------------
    echo "Applying macOS defaults..."
    # Show hidden files in Finder
    defaults write com.apple.finder AppleShowAllFiles -bool true
    # Disable press-and-hold for keys (enables key repeat)
    defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
    # Add additional defaults here as needed

    # Restart Finder to apply Finder related defaults
    killall Finder 2>/dev/null || true

    # --------------------------------------------------------------
    # macOS‑only symlinks / configuration directories
    # --------------------------------------------------------------
    # Example: create a directory for macOS specific app support files
    # mkdir -p "$HOME/Library/Application Support/MyApp"
    # Example symlink (adjust paths as appropriate for your repo)
    # ln -sf "$DOTFILES_DIR/mac/config.example" "$HOME/.myappconfig"

    echo "macOS specific setup completed."
fi

# ----------------------------------------------------------------------
# Continue with the rest of the original install script (Linux / Windows)
# ----------------------------------------------------------------------
# ... (rest of the original script) ...
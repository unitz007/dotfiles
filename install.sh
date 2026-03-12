#!/usr/bin/env bash
# Main installation script for dotfiles
# Supports optional --install-fonts flag to trigger font installation

set -euo pipefail

# Default flags
INSTALL_FONTS=false

# Parse arguments
while (( "$#" )); do
    case "$1" in
        --install-fonts)
            INSTALL_FONTS=true
            shift
            ;;
        *) # unknown option
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Existing installation steps (placeholder)
# ... (other install logic would be here)

# Font installation step
if $INSTALL_FONTS; then
    if [[ -f "./install_fonts.sh" ]]; then
        echo "Running font installation..."
        bash "./install_fonts.sh"
    else
        echo "install_fonts.sh not found; skipping font installation."
    fi
fi

echo "Installation script completed."
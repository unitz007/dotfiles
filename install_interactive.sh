#!/usr/bin/env bash
# install_interactive.sh
# Interactive wrapper around the various install sub‑scripts.
# Supports a --non‑interactive mode for CI pipelines which installs the
# default set of components without prompting.

set -euo pipefail

# ----------------------------------------------------------------------
# Configuration – list of components.
# Each entry is a space‑separated string:
#   <display name> <default (yes|no)> <script path>
# ----------------------------------------------------------------------
components=(
    "Oh‑My‑Zsh yes ./install_oh_my_zsh.sh"
    "Fish yes ./install_fish.sh"
    "Neovim yes ./install_neovim.sh"
    "Nerd Fonts yes ./install_nerd_fonts.sh"
    "PowerShell profile yes ./install_powershell_profile.sh"
    "Secret handling yes ./install_secret_handling.sh"
)

# ----------------------------------------------------------------------
# Helper: print a formatted prompt and read a yes/no answer.
# Returns 0 for yes, 1 for no.
# ----------------------------------------------------------------------
prompt_yes_no() {
    local prompt="$1"
    local default="$2"   # "yes" or "no"
    local answer

    # Build the prompt suffix showing the default choice.
    if [[ "$default" == "yes" ]]; then
        prompt="${prompt} [Y/n]: "
    else
        prompt="${prompt} [y/N]: "
    fi

    while true; do
        read -r -p "$prompt" answer
        # If the user just hits enter, use the default.
        if [[ -z "$answer" ]]; then
            [[ "$default" == "yes" ]] && return 0 || return 1
        fi
        case "${answer,,}" in
            y|yes)  return 0 ;;
            n|no)   return 1 ;;
            *)      echo "Please answer yes or no." ;;
        esac
    done
}

# ----------------------------------------------------------------------
# Parse command‑line arguments.
# ----------------------------------------------------------------------
NON_INTERACTIVE=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        --non-interactive)
            NON_INTERACTIVE=true
            shift
            ;;
        -h|--help)
            cat <<EOF
Usage: $0 [--non-interactive]

  --non-interactive   Run without prompting, installing the default set
                     of components. Useful for CI.
  -h, --help         Show this help message.
EOF
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# ----------------------------------------------------------------------
# Main installation loop.
# ----------------------------------------------------------------------
selected_scripts=()

if $NON_INTERACTIVE; then
    # In non‑interactive mode we simply honour the defaults.
    for entry in "${components[@]}"; do
        # shellcheck disable=SC2086
        set -- $entry
        name=$1
        default=$2
        script=$3
        if [[ "$default" == "yes" ]]; then
            selected_scripts+=("$script")
        fi
    done
else
    echo "Interactive installer – select which components to install."
    echo "Press <Enter> to accept the default choice shown in brackets."
    echo

    for entry in "${components[@]}"; do
        # shellcheck disable=SC2086
        set -- $entry
        name=$1
        default=$2
        script=$3

        if prompt_yes_no "Install $name?" "$default"; then
            selected_scripts+=("$script")
        fi
    done
fi

# ----------------------------------------------------------------------
# Execute the selected installation scripts.
# ----------------------------------------------------------------------
if [[ ${#selected_scripts[@]} -eq 0 ]]; then
    echo "No components selected – exiting."
    exit 0
fi

echo "Running selected installers..."
for script in "${selected_scripts[@]}"; do
    if [[ -x "$script" ]]; then
        echo "▶ $script"
        "$script"
    else
        echo "⚠️  Skipping $script – file not found or not executable."
    fi
done

echo "Installation complete."
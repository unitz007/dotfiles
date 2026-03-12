#!/usr/bin/env bash
set -euo pipefail

# Determine repository root
DOTFILES="${DOTFILES:-$(git rev-parse --show-toplevel)}"
BACKUP_ROOT="${HOME}/.dotfiles_backup"

# Ensure backup directory exists
mkdir -p "${BACKUP_ROOT}"

# Function to rotate backups (keep last 5)
rotate_backups() {
    local component="$1"
    local backups=($(ls -1d "${BACKUP_ROOT}/${component}"* 2>/dev/null | sort))
    local keep=5
    if (( ${#backups[@]} > keep )); then
        local remove_count=$(( ${#backups[@]} - keep ))
        for ((i=0; i<remove_count; i++)); do
            rm -rf "${backups[i]}"
        done
    fi
}

# Backup existing target and create a symlink
backup_and_link() {
    local src="$1"
    local dest="$2"
    local component_name="$3"

    if [ -e "${dest}" ] || [ -L "${dest}" ]; then
        local timestamp
        timestamp=$(date +"%Y%m%d%H%M%S")
        local backup_path="${BACKUP_ROOT}/${component_name}_${timestamp}"
        mkdir -p "$(dirname "${backup_path}")"
        mv "${dest}" "${backup_path}"
        rotate_backups "${component_name}"
        echo "Backed up ${dest} → ${backup_path}"
    fi

    mkdir -p "$(dirname "${dest}")"
    ln -s "${src}" "${dest}"
    echo "Linked ${src} → ${dest}"
}

# Load components from dotfiles.yml (requires yq)
if command -v yq >/dev/null; then
    COMPONENTS=$(yq e '.components | keys | .[]' "${DOTFILES}/dotfiles.yml")
else
    echo "yq is required to parse dotfiles.yml"
    exit 1
fi

for comp in ${COMPONENTS}; do
    case "${comp}" in
        bash)
            src="${DOTFILES}/bash"
            dest="${HOME}/.bashrc"
            backup_and_link "${src}" "${dest}" "bash"
            ;;
        zsh)
            src="${DOTFILES}/zsh"
            dest="${HOME}/.zshrc"
            backup_and_link "${src}" "${dest}" "zsh"
            ;;
        fish)
            src="${DOTFILES}/fish"
            dest="${HOME}/.config/fish"
            backup_and_link "${src}" "${dest}" "fish"

            # Post‑install: install Fisher if not already present
            if command -v fish >/dev/null; then
                fish -c '
                    if not type -q fisher
                        curl -sL https://git.io/fisher | source
                        fisher install jorgebucaran/fisher
                    fi
                '
            else
                echo "Fish shell not found; skipping Fisher installation."
            fi
            ;;
        *)
            echo "Unknown component: ${comp}"
            ;;
    esac
done
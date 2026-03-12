#!/usr/bin/env bash

# uninstall.sh - Revert dotfile installations created by install.sh
# Supports:
#   --dry-run          Show actions without performing them
#   --profile <name>  Uninstall only the specified profile (if profiles are used)

set -euo pipefail

# Determine script directory (repo root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default locations
MANIFEST_FILE="${SCRIPT_DIR}/.dotfiles_manifest"
BACKUP_DIR="${SCRIPT_DIR}/backup"

# Flags
DRY_RUN=false
PROFILE=""

# Helper functions
log() {
    echo "[*] $*"
}
warn() {
    echo "[!] $*" >&2
}
error_exit() {
    echo "[ERROR] $*" >&2
    exit 1
}
usage() {
    cat <<EOF
Usage: $0 [--dry-run] [--profile <name>]

  --dry-run          Show what would be removed/restored without making changes.
  --profile <name>   Uninstall only the specified profile (if the manifest contains profile entries).
EOF
    exit 1
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --profile)
            if [[ -z "${2:-}" ]]; then
                warn "Missing profile name after --profile"
                usage
            fi
            PROFILE="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            warn "Unknown argument: $1"
            usage
            ;;
    esac
done

# Verify manifest exists
if [[ ! -f "${MANIFEST_FILE}" ]]; then
    error_exit "Manifest file not found at ${MANIFEST_FILE}. Cannot determine installed symlinks."
fi

# Read manifest and process entries
# Expected manifest format (one entry per line):
#   [profile] <source_path> <target_path>
#   If profile is omitted, the line starts directly with source_path.
# Example without profile:
#   /abs/path/to/repo/.vimrc /home/user/.vimrc
# Example with profile:
#   work /abs/path/to/repo/.work_vimrc /home/user/.vimrc

while IFS= read -r line || [[ -n "$line" ]]; do
    # Skip empty lines or comments
    [[ -z "$line" || "$line" =~ ^# ]] && continue

    # Split line into fields
    read -ra fields <<<"$line"
    if [[ ${#fields[@]} -eq 3 ]]; then
        entry_profile="${fields[0]}"
        src_path="${fields[1]}"
        tgt_path="${fields[2]}"
    elif [[ ${#fields[@]} -eq 2 ]]; then
        entry_profile=""
        src_path="${fields[0]}"
        tgt_path="${fields[1]}"
    else
        warn "Malformed manifest line: $line"
        continue
    fi

    # If a profile filter is set, skip non‑matching entries
    if [[ -n "$PROFILE" && "$entry_profile" != "$PROFILE" ]]; then
        continue
    fi

    # Resolve absolute paths
    src_path="$(realpath -m "$src_path")"
    tgt_path="$(realpath -m "$tgt_path")"

    # Verify the target is a symlink pointing to the source
    if [[ -L "$tgt_path" ]]; then
        link_target="$(readlink "$tgt_path")"
        # readlink may return a relative path; resolve it relative to the symlink's directory
        link_target_resolved="$(realpath -m "$(dirname "$tgt_path")/$link_target")"
        if [[ "$link_target_resolved" == "$src_path" ]]; then
            if $DRY_RUN; then
                log "[DRY‑RUN] Would remove symlink: $tgt_path"
            else
                log "Removing symlink: $tgt_path"
                rm "$tgt_path"
            fi

            # Restore backup if it exists
            backup_path="${BACKUP_DIR}${tgt_path#$HOME}"
            if [[ -f "$backup_path" ]]; then
                if $DRY_RUN; then
                    log "[DRY‑RUN] Would restore backup: $backup_path -> $tgt_path"
                else
                    log "Restoring backup: $backup_path -> $tgt_path"
                    mkdir -p "$(dirname "$tgt_path")"
                    mv "$backup_path" "$tgt_path"
                fi
            fi
        else
            log "Skipping $tgt_path (not a symlink to $src_path)"
        fi
    else
        log "Skipping $tgt_path (not a symlink)"
    fi
done < "${MANIFEST_FILE}"

log "Uninstall completed."
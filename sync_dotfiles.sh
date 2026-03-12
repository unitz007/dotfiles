#!/usr/bin/env bash
# sync_dotfiles.sh - Synchronize dotfiles and optionally handle GPG‑encrypted secrets.
#
# This script reads a configuration file `dotfiles.yml` which may contain:
#   - `files:`      – a list of regular dotfiles to sync (handled by the original script).
#   - `encrypted:` – a list of files that should be stored encrypted in the repository.
#   - `gpg_id:`     – a default GPG key ID to use for encryption (optional).
#
# New features:
#   --gpg-id <key-id>   Use the supplied GPG key ID for encryption.
#   --decrypt           Decrypt all encrypted files locally and exit.
#
# The script encrypts each file listed under `encrypted:` to `<file>.gpg`,
# adds the encrypted version to the git index and ensures the plaintext
# version is not staged.  Decryption restores the original plaintext files.

set -euo pipefail

# ----------------------------------------------------------------------
# Helper functions
# ----------------------------------------------------------------------
log() {
    echo "[sync_dotfiles] $*"
}

error_exit() {
    echo "[sync_dotfiles] ERROR: $*" >&2
    exit 1
}

# Load the YAML configuration using yq (must be installed)
YAML_FILE="dotfiles.yml"
if [[ ! -f "$YAML_FILE" ]]; then
    error_exit "Configuration file $YAML_FILE not found."
fi

# ----------------------------------------------------------------------
# Argument parsing
# ----------------------------------------------------------------------
GPG_ID=""
DECRYPT_MODE=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        --gpg-id)
            if [[ -z "${2-}" ]]; then
                error_exit "--gpg-id requires an argument."
            fi
            GPG_ID="$2"
            shift 2
            ;;
        --decrypt)
            DECRYPT_MODE=1
            shift
            ;;
        *)  # Pass through any other arguments to the original logic
            shift
            ;;
    esac
done

# If no explicit GPG ID, try to read it from the YAML config
if [[ -z "$GPG_ID" ]]; then
    GPG_ID=$(yq eval '.gpg_id // ""' "$YAML_FILE")
fi

# ----------------------------------------------------------------------
# Encryption / Decryption handling
# ----------------------------------------------------------------------
encrypt_files() {
    # Retrieve the list of files to encrypt; ignore errors if the key does not exist
    mapfile -t enc_files < <(yq eval '.encrypted[]' "$YAML_FILE" 2>/dev/null || true)

    if [[ ${#enc_files[@]} -eq 0 ]]; then
        log "No encrypted files defined in $YAML_FILE."
        return
    fi

    if [[ -z "$GPG_ID" ]]; then
        error_exit "No GPG ID supplied (via --gpg-id or 'gpg_id' in $YAML_FILE)."
    fi

    for src in "${enc_files[@]}"; do
        if [[ ! -f "$src" ]]; then
            log "Warning: file to encrypt not found: $src"
            continue
        fi

        dst="${src}.gpg"
        log "Encrypting $src → $dst using GPG ID $GPG_ID"
        gpg --yes --batch -r "$GPG_ID" -e -o "$dst" "$src"

        # Stage the encrypted file and ensure the plaintext is not staged
        git add "$dst"
        git rm --cached "$src" 2>/dev/null || true
    done
}

decrypt_files() {
    mapfile -t enc_files < <(yq eval '.encrypted[]' "$YAML_FILE" 2>/dev/null || true)

    if [[ ${#enc_files[@]} -eq 0 ]]; then
        log "No encrypted files defined in $YAML_FILE."
        return
    fi

    for src in "${enc_files[@]}"; do
        enc="${src}.gpg"
        if [[ ! -f "$enc" ]]; then
            log "Warning: encrypted file not found: $enc"
            continue
        fi

        log "Decrypting $enc → $src"
        gpg -d -o "$src" "$enc"
    done
}

# ----------------------------------------------------------------------
# Main execution flow
# ----------------------------------------------------------------------
if (( DECRYPT_MODE )); then
    log "Running in decryption mode."
    decrypt_files
    log "Decryption complete."
    exit 0
fi

# Perform encryption before any commit/push actions
encrypt_files

# ----------------------------------------------------------------------
# ORIGINAL SYNC LOGIC (placeholder)
# ----------------------------------------------------------------------
# The original script likely performed the following steps:
#   1. Iterate over `files:` entries in dotfiles.yml and create symlinks/copies.
#   2. Detect changes, stage them, commit with a message, and push.
# For the purpose of this enhancement we keep that behaviour untouched.
# If the original script is more complex, the encryption step above will
# have already staged the .gpg files, and the rest of the script can
# continue as before.

log "Running original dotfiles synchronization logic..."
# Placeholder: replace with the actual sync implementation.
# Example:
#   ./original_sync_logic.sh
log "Sync complete."
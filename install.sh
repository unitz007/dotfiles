#!/usr/bin/env bash

# install.sh - Repository installation script
# This script performs the standard installation steps and adds
# WSL2-specific configuration handling.

set -euo pipefail

# Function to print messages
log() {
    echo -e "[install] $*"
}

# --------------------------------------------------------------------
# Standard installation steps (placeholder)
# --------------------------------------------------------------------
# TODO: Insert the repository's original installation logic here.
# For the purpose of this update, we assume the original script
# performed its tasks successfully before reaching the WSL2 handling.
log "Running standard installation steps..."
# Example placeholder command:
# ./setup.sh

# --------------------------------------------------------------------
# WSL2 detection and configuration
# --------------------------------------------------------------------
detect_wsl2() {
    # Detect WSL2 via /proc/version and kernel release
    if [[ -f /proc/version && -f /proc/sys/kernel/osrelease ]]; then
        if grep -qi "microsoft" /proc/version && grep -qi "wsl2" /proc/sys/kernel/osrelease; then
            return 0
        fi
    fi

    # Fallback: check for WSLENV environment variable (present in WSL)
    if [[ -n "${WSLENV:-}" ]]; then
        # In WSL1 the kernel release does not contain "WSL2"
        if grep -qi "wsl2" /proc/sys/kernel/osrelease 2>/dev/null; then
            return 0
        fi
    fi

    return 1
}

if detect_wsl2; then
    log "WSL2 environment detected."

    # Determine repository root (directory containing this script)
    REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # ----------------------------------------------------------------
    # Link /etc/wsl.conf
    # ----------------------------------------------------------------
    WSL_CONF_SRC="${REPO_ROOT}/wsl.conf"
    WSL_CONF_DST="/etc/wsl.conf"

    if [[ -f "${WSL_CONF_SRC}" ]]; then
        if [[ "$(id -u)" -ne 0 ]]; then
            SUDO_CMD="sudo"
        else
            SUDO_CMD=""
        fi

        log "Linking wsl.conf to ${WSL_CONF_DST}"
        ${SUDO_CMD} ln -sf "${WSL_CONF_SRC}" "${WSL_CONF_DST}"
        log "wsl.conf linked successfully."
    else
        log "Warning: wsl.conf source file not found at ${WSL_CONF_SRC}"
    fi

    # ----------------------------------------------------------------
    # Optionally link Windows-side .wslconfig
    # ----------------------------------------------------------------
    # $USERPROFILE is typically set in WSL to the Windows user profile path,
    # e.g., /mnt/c/Users/YourName
    if [[ -n "${USERPROFILE:-}" && -d "${USERPROFILE}" ]]; then
        WSLCONFIG_SRC="${REPO_ROOT}/.wslconfig"
        WSLCONFIG_DST="${USERPROFILE}/.wslconfig"

        if [[ -f "${WSLCONFIG_SRC}" ]]; then
            if [[ "$(id -u)" -ne 0 ]]; then
                SUDO_CMD="sudo"
            else
                SUDO_CMD=""
            fi

            log "Linking .wslconfig to ${WSLCONFIG_DST}"
            ${SUDO_CMD} ln -sf "${WSLCONFIG_SRC}" "${WSLCONFIG_DST}"
            log ".wslconfig linked successfully."
        else
            log "Info: .wslconfig source file not present; skipping Windows-side configuration."
        fi
    else
        log "Info: USERPROFILE not set or not a directory; skipping .wslconfig linking."
    fi
else
    log "WSL2 environment not detected; skipping WSL-specific configuration."
fi

log "Installation script completed."
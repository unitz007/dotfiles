#!/usr/bin/env bash

# =============================================================================
# install.sh - Automated dependency installer
# =============================================================================
# This script detects missing command‑line tools and installs them using the
# appropriate package manager. It now supports macOS with Homebrew in addition
# to the existing Linux support.
# =============================================================================

set -euo pipefail

# ------------------------------
# Logging helpers
# ------------------------------
log() {
    local level="$1"
    shift
    local msg="$*"
    printf '[%s] %s: %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$level" "$msg"
}
log_info()  { log "INFO" "$@"; }
log_warn()  { log "WARN" "$@"; }
log_error() { log "ERROR" "$@"; }

# ------------------------------
# Prompt helper (yes/no)
# ------------------------------
prompt_yes_no() {
    local prompt_msg="$1"
    while true; do
        read -rp "$prompt_msg [y/n]: " yn
        case "$yn" in
            [Yy]*) return 0 ;;
            [Nn]*) return 1 ;;
            *) echo "Please answer y or n." ;;
        esac
    done
}

# ------------------------------
# Detect OS
# ------------------------------
detect_os() {
    case "$OSTYPE" in
        darwin*)   echo "macos" ;;
        linux*)    echo "linux" ;;
        *)         echo "unknown" ;;
    esac
}

# ------------------------------
# Check for Homebrew (macOS)
# ------------------------------
ensure_homebrew() {
    if command -v brew >/dev/null 2>&1; then
        log_info "Homebrew is already installed."
        return 0
    fi

    log_warn "Homebrew is not installed."
    if ! prompt_yes_no "Homebrew is required to install missing dependencies. Install Homebrew now?"; then
        log_error "Homebrew installation declined. Cannot continue on macOS."
        exit 1
    fi

    log_info "Installing Homebrew..."
    # Official Homebrew installation script
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
        log_error "Homebrew installation failed."
        exit 1
    }

    # Add Homebrew to PATH for the current session
    if [[ -d "/opt/homebrew/bin" ]]; then
        export PATH="/opt/homebrew/bin:$PATH"
    elif [[ -d "/usr/local/bin" ]]; then
        export PATH="/usr/local/bin:$PATH"
    fi

    # Verify installation
    if command -v brew >/dev/null 2>&1; then
        log_info "Homebrew installed successfully."
    else
        log_error "Homebrew installation completed but brew command not found."
        exit 1
    fi
}

# ------------------------------
# Install missing packages on macOS using Homebrew
# ------------------------------
install_missing_macos() {
    local missing=("$@")
    if [[ ${#missing[@]} -eq 0 ]]; then
        log_info "No missing packages to install on macOS."
        return
    fi

    ensure_homebrew

    for pkg in "${missing[@]}"; do
        log_info "Installing $pkg via Homebrew..."
        if brew install "$pkg"; then
            log_info "$pkg installed successfully."
        else
            log_error "Failed to install $pkg via Homebrew."
            exit 1
        fi
    done
}

# ------------------------------
# Install missing packages on Linux (existing logic)
# ------------------------------
install_missing_linux() {
    local missing=("$@")
    if [[ ${#missing[@]} -eq 0 ]]; then
        log_info "No missing packages to install on Linux."
        return
    fi

    # Detect available package manager
    if command -v apt-get >/dev/null 2>&1; then
        PKG_MANAGER="apt-get"
        UPDATE_CMD="apt-get update -y"
        INSTALL_CMD="apt-get install -y"
    elif command -v dnf >/dev/null 2>&1; then
        PKG_MANAGER="dnf"
        UPDATE_CMD="dnf makecache"
        INSTALL_CMD="dnf install -y"
    elif command -v yum >/dev/null 2>&1; then
        PKG_MANAGER="yum"
        UPDATE_CMD="yum makecache"
        INSTALL_CMD="yum install -y"
    elif command -v pacman >/dev/null 2>&1; then
        PKG_MANAGER="pacman"
        UPDATE_CMD="pacman -Sy"
        INSTALL_CMD="pacman -S --noconfirm"
    else
        log_error "No supported package manager found on this Linux system."
        exit 1
    fi

    log_info "Updating package lists using $PKG_MANAGER..."
    if ! sudo $UPDATE_CMD; then
        log_error "Package list update failed."
        exit 1
    fi

    for pkg in "${missing[@]}"; do
        log_info "Installing $pkg via $PKG_MANAGER..."
        if sudo $INSTALL_CMD "$pkg"; then
            log_info "$pkg installed successfully."
        else
            log_error "Failed to install $pkg via $PKG_MANAGER."
            exit 1
        fi
    done
}

# ------------------------------
# Main execution
# ------------------------------

# List of required commands/tools (adjust as needed for the project)
REQUIRED_TOOLS=(
    git
    curl
    wget
    python3
    node
)

# Determine which tools are missing
MISSING=()
for cmd in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        MISSING+=("$cmd")
    fi
done

if [[ ${#MISSING[@]} -eq 0 ]]; then
    log_info "All required tools are already installed."
    exit 0
fi

log_info "Missing tools detected: ${MISSING[*]}"

OS_TYPE=$(detect_os)
case "$OS_TYPE" in
    macos)
        log_info "Detected macOS."
        install_missing_macos "${MISSING[@]}"
        ;;
    linux)
        log_info "Detected Linux."
        install_missing_linux "${MISSING[@]}"
        ;;
    *)
        log_error "Unsupported or unknown operating system: $OSTYPE"
        exit 1
        ;;
esac

log_info "Dependency installation completed successfully."
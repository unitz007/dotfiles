#!/usr/bin/env bash
# Installation script for dotfiles project
# Existing installation steps ...

# ----------------------------------------------------------------------
# PowerShell completion (Windows)
# ----------------------------------------------------------------------
# Detect a Windows environment (Git Bash, MSYS, Cygwin, WSL with Windows path)
if [[ "$(uname -s)" == *NT* ]] || [[ "$(uname -s)" == MINGW* ]] || [[ "$(uname -s)" == CYGWIN* ]] || [[ "$(uname -s)" == MSYS* ]]; then
    PS_MODULE_DIR="${HOME}/Documents/PowerShell/Modules/dotfiles"
    mkdir -p "${PS_MODULE_DIR}"
    cp "$(dirname "$0")/dotfiles.ps1" "${PS_MODULE_DIR}/dotfiles.ps1"
    echo "PowerShell completion script installed to ${PS_MODULE_DIR}/dotfiles.ps1"
fi

# Continue with any remaining installation steps ...
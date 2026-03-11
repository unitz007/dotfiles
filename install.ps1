<#
.SYNOPSIS
    Installer script for dotfiles on Windows.

.DESCRIPTION
    Detects a Windows environment, backs up any existing PowerShell profile,
    and copies the repository's PowerShell profile and optional modules to the
    appropriate user location ($HOME\Documents\PowerShell).

    This script mirrors the behavior of the existing Unix‑like `install.sh`
    but uses native PowerShell commands for Windows compatibility.
#>

# Ensure script stops on errors
$ErrorActionPreference = 'Stop'

# Resolve the directory where this script resides (the repository root)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Target PowerShell profile directory
$profileDir = Join-Path $HOME 'Documents\PowerShell'
$profilePath = Join-Path $profileDir 'Microsoft.PowerShell_profile.ps1'

# Create the target directory if it does not exist
if (-not (Test-Path $profileDir)) {
    Write-Host "Creating profile directory: $profileDir"
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

# Backup existing profile if present
if (Test-Path $profilePath) {
    $timestamp = Get-Date -Format 'yyyyMMddHHmmss'
    $backupPath = "$profilePath.bak.$timestamp"
    Write-Host "Backing up existing profile to $backupPath"
    Rename-Item -Path $profilePath -NewName $backupPath
}

# Copy the repository's PowerShell profile into the target location
$sourceProfile = Join-Path $scriptDir 'Microsoft.PowerShell_profile.ps1'
if (-not (Test-Path $sourceProfile)) {
    Write-Error "Source profile not found at $sourceProfile"
    exit 1
}
Write-Host "Installing PowerShell profile to $profilePath"
Copy-Item -Path $sourceProfile -Destination $profilePath -Force

# Optional modules handling
$modules = @('posh-git', 'oh-my-posh')
$destModulesPath = Join-Path $HOME 'Documents\PowerShell\Modules'

# Ensure the modules destination exists
if (-not (Test-Path $destModulesPath)) {
    Write-Host "Creating modules directory: $destModulesPath"
    New-Item -ItemType Directory -Path $destModulesPath -Force | Out-Null
}

foreach ($module in $modules) {
    $src = Join-Path $scriptDir $module
    $dst = Join-Path $destModulesPath $module

    if (Test-Path $src) {
        # Remove any existing module directory to avoid stale files
        if (Test-Path $dst) {
            Write-Host "Removing existing module directory: $dst"
            Remove-Item -Recurse -Force $dst
        }

        Write-Host "Copying module '$module' to $dst"
        Copy-Item -Path $src -Destination $dst -Recurse -Force
    } else {
        Write-Host "Module source not found for '$module' – skipping."
    }
}

Write-Host "`nInstallation complete. Your PowerShell profile is now located at:"
Write-Host "    $profilePath"
Write-Host "You may need to restart your PowerShell session for changes to take effect."
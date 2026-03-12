<#
.SYNOPSIS
    Install dotfiles on Windows (PowerShell) with backup/restore support.

.DESCRIPTION
    Reads `dotfiles.yml`, selects a profile, backs up any existing files that would be overwritten,
    and creates symbolic links from the repository to the target locations.

    Supports:
      - Installing a specific profile: `.\install.ps1 -Profile work`
      - Restoring a previous backup: `.\install.ps1 -Restore <BackupFolder>`
      - Dry‑run mode: `.\install.ps1 -WhatIf`

.PARAMETER Profile
    Name of the profile defined in `dotfiles.yml`. Defaults to `default`.

.PARAMETER Restore
    Path to a backup directory previously created by this script. When supplied, the script
    restores the backup instead of installing.

.PARAMETER WhatIf
    Shows what would happen without making any changes.

.EXAMPLE
    .\install.ps1 -Profile work

    Installs the `work` profile.

.EXAMPLE
    .\install.ps1 -Restore "$HOME\.dotfiles_backup\20231101_123045"

    Restores the backup taken on 2023‑11‑01 at 12:30:45.

.NOTES
    Requires PowerShell 7+ (for ConvertFrom-Yaml). On older versions, install the `Microsoft.PowerShell.Yaml` module.
#>

[CmdletBinding(SupportsShouldProcess=$true)]
param (
    [Parameter(Position=0)]
    [string]$Profile = 'default',

    [Parameter()]
    [ValidateScript({ Test-Path $_ -PathType Container })]
    [string]$Restore
)

# Helper: Resolve ~ to $HOME
function Resolve-Home([string]$Path) {
    if ($Path -like '~*') {
        return $Path -replace '^~', $HOME
    }
    return $Path
}

# Helper: Create backup directory with timestamp
function New-BackupDirectory {
    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $backupRoot = Join-Path -Path $HOME -ChildPath '.dotfiles_backup'
    $backupDir = Join-Path -Path $backupRoot -ChildPath $timestamp
    if (-not (Test-Path $backupRoot)) {
        New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
    }
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    return $backupDir
}

# Helper: Load YAML configuration
function Get-DotfilesConfig {
    $yamlPath = Join-Path -Path $PSScriptRoot -ChildPath 'dotfiles.yml'
    if (-not (Test-Path $yamlPath)) {
        Throw "Configuration file 'dotfiles.yml' not found at $yamlPath"
    }
    $yamlContent = Get-Content -Path $yamlPath -Raw
    try {
        $config = $yamlContent | ConvertFrom-Yaml
    } catch {
        Throw "Failed to parse 'dotfiles.yml': $_"
    }
    return $config
}

# ----------------------------------------------------------------------
# MAIN LOGIC
# ----------------------------------------------------------------------
if ($Restore) {
    # ------------------------------------------------------------------
    # Restore mode
    # ------------------------------------------------------------------
    Write-Host "Restoring backup from '$Restore'..."
    Get-ChildItem -Path $Restore -Recurse -File | ForEach-Object {
        $relative = $_.FullName.Substring($Restore.Length).TrimStart('\')
        $targetPath = Join-Path -Path $HOME -ChildPath $relative
        $targetDir = Split-Path -Parent $targetPath
        if (-not (Test-Path $targetDir)) {
            New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        }
        if ($PSCmdlet.ShouldProcess($targetPath, "Restore backup")) {
            Move-Item -Path $_.FullName -Destination $targetPath -Force
        }
    }
    Write-Host "Restore completed."
    exit 0
}

# ------------------------------------------------------------------
# Installation mode
# ------------------------------------------------------------------
$config = Get-DotfilesConfig

if (-not $config.profiles) {
    Throw "Invalid configuration: missing 'profiles' section."
}
if (-not $config.profiles.$Profile) {
    Throw "Profile '$Profile' not found in 'dotfiles.yml'. Available profiles: $($config.profiles.Keys -join ', ')"
}

$entries = $config.profiles.$Profile
if (-not $entries) {
    Write-Warning "Profile '$Profile' contains no entries. Nothing to do."
    exit 0
}

$backupDir = New-BackupDirectory
Write-Host "Backup directory created at: $backupDir"

foreach ($entry in $entries) {
    # Expect each entry to have 'src' and 'dest' keys
    if (-not $entry.src -or -not $entry.dest) {
        Write-Warning "Skipping malformed entry: $($entry | ConvertTo-Json -Compress)"
        continue
    }

    $srcPath = Join-Path -Path $PSScriptRoot -ChildPath $entry.src
    $destPath = Resolve-Home $entry.dest

    if (-not (Test-Path $srcPath)) {
        Write-Warning "Source file not found: $srcPath. Skipping."
        continue
    }

    $destDir = Split-Path -Parent $destPath
    if (-not (Test-Path $destDir)) {
        if ($PSCmdlet.ShouldProcess($destDir, "Create directory")) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
    }

    # If destination exists and is not the correct symlink, back it up
    $needsLink = $true
    if (Test-Path $destPath) {
        $attributes = Get-Item $destPath -Force | Select-Object -ExpandProperty Attributes
        $isSymlink = $attributes -band [System.IO.FileAttributes]::ReparsePoint
        if ($isSymlink) {
            $linkTarget = (Get-Item $destPath -Force).Target
            if ($linkTarget -eq $srcPath) {
                $needsLink = $false
                Write-Host "Link already correct: $destPath -> $srcPath"
            }
        }

        if ($needsLink) {
            $relativeBackup = $destPath.Substring($HOME.Length).TrimStart('\')
            $backupPath = Join-Path -Path $backupDir -ChildPath $relativeBackup
            $backupParent = Split-Path -Parent $backupPath
            if (-not (Test-Path $backupParent)) {
                New-Item -ItemType Directory -Path $backupParent -Force | Out-Null
            }
            if ($PSCmdlet.ShouldProcess($destPath, "Move existing file to backup")) {
                Move-Item -Path $destPath -Destination $backupPath -Force
                Write-Host "Backed up $destPath to $backupPath"
            }
        }
    }

    if ($needsLink) {
        if ($PSCmdlet.ShouldProcess($destPath, "Create symbolic link to $srcPath")) {
            # New-Item -ItemType SymbolicLink works for both files and directories
            New-Item -ItemType SymbolicLink -Path $destPath -Target $srcPath -Force | Out-Null
            Write-Host "Created symlink: $destPath -> $srcPath"
        }
    }
}

Write-Host "Installation of profile '$Profile' completed."
Write-Host "To restore a previous state, run:"
Write-Host "    .\install.ps1 -Restore `"$backupDir`""
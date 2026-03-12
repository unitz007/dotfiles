<#
.SYNOPSIS
  uninstall.ps1 – reverse actions performed by install.ps1 (or install.sh).

.DESCRIPTION
  Removes symlinks created by the installer, restores the most recent backup for each
  managed file, and optionally deletes the backup directory. Supports -Force and
  -DryRun switches.

.PARAMETER Force
  Skip all confirmation prompts.

.PARAMETER DryRun
  Show what would be done without making any changes.

.EXAMPLE
  .\uninstall.ps1 -Force
#>

param(
    [switch]$Force,
    [switch]$DryRun,
    [switch]$Help
)

function Show-Help {
    Write-Host @"
Usage: uninstall.ps1 [-Force] [-DryRun] [-Help]

  -Force   Skip all confirmation prompts.
  -DryRun  Show actions without performing them.
  -Help    Show this help message.
"@
}

if ($Help) {
    Show-Help
    exit 0
}

$home = $env:USERPROFILE
$backupDir = Join-Path $home ".dotfiles_backup"
$manifest = Join-Path $home ".dotfiles_install_manifest"

if (-not (Test-Path $manifest)) {
    Write-Error "Manifest file not found at $manifest"
    exit 1
}

Get-Content $manifest | ForEach-Object {
    $target = $_.Trim()
    if ([string]::IsNullOrWhiteSpace($target) -or $target.StartsWith('#')) {
        return
    }

    # Remove symlink if present
    if (Test-Path $target -PathType SymbolicLink) {
        if ($DryRun) {
            Write-Host "Would remove symlink: $target"
        } else {
            Write-Host "Removing symlink: $target"
            Remove-Item -Path $target -Force
        }
    }

    # Determine relative path for backup lookup
    $relative = $target.Substring($home.Length + 1)

    # Find the most recent backup file
    $latest = Get-ChildItem -Path $backupDir -Recurse -File -Filter $relative |
              Sort-Object LastWriteTime -Descending |
              Select-Object -First 1

    if ($null -ne $latest) {
        if ($DryRun) {
            Write-Host "Would restore backup from $($latest.FullName) to $target"
        } else {
            Write-Host "Restoring backup from $($latest.FullName) to $target"
            $destDir = Split-Path $target -Parent
            if (-not (Test-Path $destDir)) {
                New-Item -ItemType Directory -Path $destDir -Force | Out-Null
            }
            Copy-Item -Path $latest.FullName -Destination $target -Force
        }
    }
}

$deleteBackup = $Force.IsPresent
if (-not $Force.IsPresent) {
    $answer = Read-Host "Delete backup directory $backupDir? (y/N)"
    if ($answer -match '^[Yy]$') {
        $deleteBackup = $true
    }
}

if ($deleteBackup) {
    if ($DryRun) {
        Write-Host "Would delete backup directory $backupDir"
    } else {
        Write-Host "Deleting backup directory $backupDir"
        Remove-Item -Path $backupDir -Recurse -Force
    }
}
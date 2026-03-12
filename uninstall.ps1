Param(
    [switch]$DryRun
)

# Ensure we are running on Windows
if (-not $IsWindows) {
    Write-Host "uninstall.ps1 is intended for Windows platforms only. Exiting."
    exit 0
}

# Resolve repository root (directory where this script resides)
$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Define where the dotfiles live inside the repository
$DotfilesDir = Join-Path $RepoRoot "dotfiles"
if (-not (Test-Path $DotfilesDir)) {
    Write-Error "Dotfiles directory not found at $DotfilesDir"
    exit 1
}

# Backup root (where previous backups were stored)
$BackupRoot = Join-Path $HOME ".dotfiles_backup"

function Restore-Backup($target) {
    $relative = $target.Substring($HOME.Length).TrimStart('\')
    $backupPattern = "$relative*"
    $candidates = Get-ChildItem -Path $BackupRoot -Recurse -Filter $backupPattern -File |
        Sort-Object LastWriteTime -Descending

    if ($candidates.Count -eq 0) {
        Write-Host "No backup found for $target"
        return
    }

    $latest = $candidates[0]
    if ($DryRun) {
        Write-Host "Would restore backup $($latest.FullName) to $target"
    } else {
        # Remove the (now) symlink/junction if it exists
        if (Test-Path $target) {
            Remove-Item -Force $target
        }
        Move-Item -Force $latest.FullName $target
        Write-Host "Restored backup $($latest.Name) to $target"
    }
}

function Remove-Link($target) {
    if (Test-Path $target) {
        $attr = Get-Item $target -Force
        if ($attr.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            if ($DryRun) {
                Write-Host "Would remove link $target"
            } else {
                Remove-Item -Force $target
                Write-Host "Removed link $target"
            }
            Restore-Backup $target
        } else {
            Write-Host "$target exists but is not a link; leaving untouched."
        }
    } else {
        Write-Host "$target does not exist; nothing to remove."
    }
}

# -------------------------------------------------------------------------
# 1. Remove links and restore backups
# -------------------------------------------------------------------------
Get-ChildItem -Path $DotfilesDir -Recurse -Force |
    Where-Object { -not $_.PSIsContainer } |
    ForEach-Object {
        $relativePath = $_.FullName.Substring($DotfilesDir.Length).TrimStart('\')
        $targetPath = Join-Path $HOME $relativePath
        Remove-Link $targetPath
    }

# -------------------------------------------------------------------------
# 2. Uninstall packages (Chocolatey or winget)
# -------------------------------------------------------------------------
$PackagesFile = Join-Path $RepoRoot "packages.txt"
if (Test-Path $PackagesFile) {
    $packages = Get-Content $PackagesFile |
        Where-Object { $_ -and -not $_.StartsWith('#') } |
        ForEach-Object { $_.Trim() }

    foreach ($pkg in $packages) {
        if (Get-Command choco -ErrorAction SilentlyContinue) {
            $cmd = "choco uninstall $pkg -y"
        } elseif (Get-Command winget -ErrorAction SilentlyContinue) {
            $cmd = "winget uninstall $pkg"
        } else {
            Write-Warning "Neither Chocolatey nor winget is available. Skipping package removal for $pkg."
            continue
        }

        if ($DryRun) {
            Write-Host "Would run: $cmd"
        } else {
            Write-Host "Uninstalling package: $pkg"
            Invoke-Expression $cmd
        }
    }
} else {
    Write-Host "No packages.txt found; skipping package removal."
}
Param(
    [switch]$DryRun
)

# Ensure we are running on Windows
if (-not $IsWindows) {
    Write-Host "install.ps1 is intended for Windows platforms only. Exiting."
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

# Backup directory for existing files
$BackupRoot = Join-Path $HOME ".dotfiles_backup"
if (-not (Test-Path $BackupRoot)) {
    if ($DryRun) {
        Write-Host "Would create backup root: $BackupRoot"
    } else {
        New-Item -ItemType Directory -Path $BackupRoot | Out-Null
        Write-Host "Created backup root: $BackupRoot"
    }
}

function Get-BackupPath($targetPath) {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $relative = $targetPath.Substring($HOME.Length).TrimStart('\')
    $backupPath = Join-Path $BackupRoot ("$relative`_$timestamp")
    $backupDir = Split-Path $backupPath -Parent
    if (-not (Test-Path $backupDir)) {
        if ($DryRun) {
            Write-Host "Would create backup subdirectory: $backupDir"
        } else {
            New-Item -ItemType Directory -Path $backupDir | Out-Null
        }
    }
    return $backupPath
}

function Ensure-Link($source, $target) {
    # If target exists, back it up (unless it's already the correct link)
    if (Test-Path $target) {
        $attr = Get-Item $target -Force
        if ($attr.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            $existingLink = $attr.Target
            if ($existingLink -eq $source) {
                Write-Host "Link already correct: $target -> $source"
                return
            }
        }

        $backupPath = Get-BackupPath $target
        if ($DryRun) {
            Write-Host "Would move existing $target to $backupPath"
        } else {
            Move-Item -Force $target $backupPath
            Write-Host "Moved existing $target to $backupPath"
        }
    }

    # Determine link type
    $linkType = if ((Get-Item $source).PSIsContainer) { "Directory" } else { "File" }

    if ($DryRun) {
        Write-Host "Would create $linkType link: $target -> $source"
        return
    }

    try {
        New-Item -ItemType SymbolicLink -Path $target -Target $source -Force | Out-Null
        Write-Host "Created $linkType symbolic link: $target -> $source"
    } catch {
        # SymbolicLink may require admin; fall back to Junction for directories
        if ($linkType -eq "Directory") {
            try {
                New-Item -ItemType Junction -Path $target -Target $source -Force | Out-Null
                Write-Host "Created $linkType junction: $target -> $source"
            } catch {
                Write-Warning "Failed to create link for $target -> $source: $_"
            }
        } else {
            Write-Warning "Failed to create symbolic link for $target -> $source: $_"
        }
    }
}

# -------------------------------------------------------------------------
# 1. Symlink/Junction creation for each dotfile
# -------------------------------------------------------------------------
Get-ChildItem -Path $DotfilesDir -Recurse -Force |
    Where-Object { -not $_.PSIsContainer } |
    ForEach-Object {
        $relativePath = $_.FullName.Substring($DotfilesDir.Length).TrimStart('\')
        $targetPath = Join-Path $HOME $relativePath
        Ensure-Link $_.FullName $targetPath
    }

# -------------------------------------------------------------------------
# 2. Install required packages (Chocolatey or winget)
# -------------------------------------------------------------------------
$PackagesFile = Join-Path $RepoRoot "packages.txt"
if (Test-Path $PackagesFile) {
    $packages = Get-Content $PackagesFile |
        Where-Object { $_ -and -not $_.StartsWith('#') } |
        ForEach-Object { $_.Trim() }

    foreach ($pkg in $packages) {
        if (Get-Command choco -ErrorAction SilentlyContinue) {
            $cmd = "choco install $pkg -y"
        } elseif (Get-Command winget -ErrorAction SilentlyContinue) {
            $cmd = "winget install --silent --accept-source-agreements --accept-package-agreements $pkg"
        } else {
            Write-Warning "Neither Chocolatey nor winget is available. Skipping package installation for $pkg."
            continue
        }

        if ($DryRun) {
            Write-Host "Would run: $cmd"
        } else {
            Write-Host "Installing package: $pkg"
            Invoke-Expression $cmd
        }
    }
} else {
    Write-Host "No packages.txt found; skipping package installation."
}
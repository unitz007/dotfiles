param(
    [string[]]$Components = @(),
    [string]$BackupDir = "$env:USERPROFILE\dotfiles_backup"
)

$ErrorActionPreference = 'Stop'

function Write-Info($msg) {
    Write-Host "[INFO] $msg" -ForegroundColor Cyan
}
function Write-ErrorMsg($msg) {
    Write-Host "[ERROR] $msg" -ForegroundColor Red
}

# Determine repository root (directory containing this script)
$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

# Load dotfiles.yml
$dotfilesPath = Join-Path $RepoRoot "dotfiles.yml"
if (-not (Test-Path $dotfilesPath)) {
    Write-ErrorMsg "dotfiles.yml not found at $dotfilesPath"
    exit 1
}
$dotfiles = Get-Content $dotfilesPath -Raw | ConvertFrom-Yaml

# Resolve selected components
$selected = @()
if ($Components.Count -eq 0) {
    foreach ($compName in $dotfiles.components.Keys) {
        $comp = $dotfiles.components.$compName
        if ($comp.enabled -eq $true) {
            $selected += $compName
        }
    }
} else {
    $selected = $Components
}
Write-Info "Selected components: $($selected -join ', ')"

# Ensure backup directory exists
if (-not (Test-Path $BackupDir)) {
    New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
    Write-Info "Created backup directory at $BackupDir"
}

function Backup-Item($path) {
    $relative = Resolve-Path -Relative $path -ErrorAction SilentlyContinue
    $dest = Join-Path $BackupDir $relative
    $destDir = Split-Path $dest -Parent
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }
    Move-Item -Path $path -Destination $dest -Force
    Write-Info "Backed up $path to $dest"
}

function Install-File($srcRel, $destPath) {
    $src = Join-Path $RepoRoot $srcRel
    if (-not (Test-Path $src)) {
        Write-ErrorMsg "Source file $src does not exist."
        return
    }

    $destExpanded = $destPath -replace '^~', $env:USERPROFILE
    $destDir = Split-Path $destExpanded -Parent
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }

    if (Test-Path $destExpanded) {
        Backup-Item $destExpanded
    }

    try {
        New-Item -ItemType SymbolicLink -Path $destExpanded -Target $src -Force -ErrorAction Stop | Out-Null
        Write-Info "Created symlink: $destExpanded -> $src"
    } catch {
        Write-Info "Symlink creation failed, falling back to copy."
        Copy-Item -Path $src -Destination $destExpanded -Force
        Write-Info "Copied $src to $destExpanded"
    }
}

function Install-Dependency($dep) {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Info "Installing $dep via winget..."
        winget install --silent --accept-source-agreements --accept-package-agreements $dep
    } elseif (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Info "Installing $dep via Chocolatey..."
        choco install $dep -y
    } else {
        Write-Info "No supported package manager found. Please install $dep manually."
    }
}

# Process each selected component
foreach ($compName in $selected) {
    if (-not $dotfiles.components.ContainsKey($compName)) {
        Write-ErrorMsg "Component '$compName' not defined in dotfiles.yml"
        continue
    }

    $comp = $dotfiles.components.$compName

    foreach ($file in $comp.files) {
        $src = $file.src
        $dest = $file.dest
        Install-File $src $dest
    }

    if ($comp.dependencies) {
        foreach ($dep in $comp.dependencies) {
            Install-Dependency $dep
        }
    }
}

Write-Info "Installation completed successfully."
exit 0
# PowerShell installation script
# Existing installation logic assumed to be present above

# -------------------------------------------------
# Zsh component handling
# -------------------------------------------------

function Test-YamlKeyEnabled {
    param(
        [string]$Key
    )
    # Simple regex search for a line like "zsh: true"
    $pattern = "^\s*$Key\s*:\s*true\s*$"
    return (Select-String -Path "dotfiles.yml" -Pattern $pattern -SimpleMatch -Quiet)
}

# Detect Zsh (command availability) and check configuration
$zshCmd = Get-Command zsh -ErrorAction SilentlyContinue
if ($zshCmd -and (Test-YamlKeyEnabled -Key "zsh")) {
    Write-Host "Zsh detected and enabled in configuration."

    $zinitDir = Join-Path $HOME ".zinit"

    if (-not (Test-Path $zinitDir)) {
        Write-Host "Cloning Zinit plugin manager..."
        git clone https://github.com/zdharma-continuum/zinit.git $zinitDir
    } else {
        Write-Host "Zinit already installed."
    }

    $zshrcSource = Join-Path $PSScriptRoot "zsh/.zshrc"
    $zshrcTarget = Join-Path $HOME ".zshrc"

    Write-Host "Installing .zshrc to $zshrcTarget"
    Copy-Item -Path $zshrcSource -Destination $zshrcTarget -Force

    Write-Host "Zsh setup complete."
} else {
    Write-Host "Zsh not detected or disabled in dotfiles.yml – skipping Zsh component."
}

# Continue with any remaining installation steps...
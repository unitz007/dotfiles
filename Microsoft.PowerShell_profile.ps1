# PowerShell profile for dotfiles repository
# This profile sets up a consistent environment across Windows machines.
# It imports optional modules if they are available.

# Set strict mode for better scripting practices
Set-StrictMode -Version Latest

# Import posh-git if installed
if (Test-Path "$HOME\Documents\PowerShell\Modules\posh-git\posh-git.psd1") {
    Import-Module "$HOME\Documents\PowerShell\Modules\posh-git\posh-git.psd1"
}

# Import oh-my-posh if installed
if (Test-Path "$HOME\Documents\PowerShell\Modules\oh-my-posh\oh-my-posh.psd1") {
    Import-Module "$HOME\Documents\PowerShell\Modules\oh-my-posh\oh-my-posh.psd1"
    # Example theme configuration – adjust as needed
    Set-PoshPrompt -Theme Paradox
}

# Add any additional customizations below
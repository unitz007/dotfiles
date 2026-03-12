<#
.SYNOPSIS
  Windows dotfiles installer with profile support.

.DESCRIPTION
  This script reads `dotfiles.yml`, selects a profile (defaulting to "default"),
  and installs the components defined for that profile. Optional overrides are
  exported as environment variables for downstream scripts.

.PARAMETER Profile
  Name of the profile to use. If omitted, the "default" profile is used.
#>

param(
    [string]$Profile = "default"
)

# Ensure required modules are available
if (-not (Get-Command yq -ErrorAction SilentlyContinue)) {
    Write-Error "The 'yq' executable is required but not found in PATH. Install it from https://github.com/mikefarah/yq."
    exit 1
}

$ConfigFile = "dotfiles.yml"
if (-not (Test-Path $ConfigFile)) {
    Write-Error "Configuration file '$ConfigFile' not found."
    exit 1
}

# Verify profile exists
$profileExists = & yq e ".profiles.$Profile" $ConfigFile 2>$null
if (-not $profileExists) {
    Write-Error "Profile '$Profile' not found in $ConfigFile."
    exit 1
}

# Load components array for the selected profile
$components = & yq e ".profiles.$Profile.components[]" $ConfigFile

# Load optional overrides (as a JSON object)
$overridesJson = & yq e -j ".profiles.$Profile.overrides // {}" $ConfigFile

if ($overridesJson -and $overridesJson -ne "{}") {
    $overrides = $overridesJson | ConvertFrom-Json
    foreach ($kvp in $overrides.PSObject.Properties) {
        $envName = $kvp.Name
        $envValue = $kvp.Value.ToString()
        Write-Verbose "Setting override: $envName=$envValue"
        $env:$envName = $envValue
    }
}

# -------------------------------------------------------------------------
# Existing installation logic (unchanged) – iterate over components
# -------------------------------------------------------------------------
foreach ($component in $components) {
    Write-Host "Installing component: $component"
    # Assume each component has a corresponding PowerShell script under ./components/
    $scriptPath = Join-Path -Path $PSScriptRoot -ChildPath "components\$component.ps1"
    if (Test-Path $scriptPath) {
        & $scriptPath
    } else {
        Write-Warning "No installer script found for component '$component'. Skipping."
    }
}
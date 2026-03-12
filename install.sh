#!/usr/bin/env bash

set -euo pipefail

# Default profile name
PROFILE="default"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile)
      if [[ -z "${2-}" ]]; then
        echo "Error: --profile requires a value"
        exit 1
      fi
      PROFILE="$2"
      shift 2
      ;;
    *)
      # Preserve other arguments for downstream processing
      shift
      ;;
  esac
done

# Verify that yq is available (used for parsing dotfiles.yml)
if ! command -v yq >/dev/null 2>&1; then
  echo "Error: 'yq' is required but not installed. Please install yq (https://github.com/mikefarah/yq)."
  exit 1
fi

# Resolve the configuration file path
CONFIG_FILE="dotfiles.yml"
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Error: Configuration file '$CONFIG_FILE' not found."
  exit 1
fi

# Check that the requested profile exists
if ! yq e ".profiles.${PROFILE}" "$CONFIG_FILE" >/dev/null; then
  echo "Error: Profile '$PROFILE' not found in $CONFIG_FILE."
  exit 1
fi

# Load the list of components for the selected profile
mapfile -t COMPONENTS < <(yq e ".profiles.${PROFILE}.components[]" "$CONFIG_FILE")

# Load optional overrides for the selected profile (if any)
OVERRIDES=$(yq e -j ".profiles.${PROFILE}.overrides // {}" "$CONFIG_FILE")

# Export overrides as environment variables (key=value pairs)
if [[ -n "$OVERRIDES" && "$OVERRIDES" != "{}" ]]; then
  # Convert JSON object to bash associative array
  declare -A OVERRIDE_MAP
  while IFS="=" read -r key value; do
    OVERRIDE_MAP["$key"]="$value"
  done < <(echo "$OVERRIDES" | jq -r 'to_entries|map("\(.key)=\(.value|tostring)")|.[]')
  for key in "${!OVERRIDE_MAP[@]}"; do
    export "$key"="${OVERRIDE_MAP[$key]}"
  done
fi

# -------------------------------------------------------------------------
# Existing installation logic (unchanged) – iterate over COMPONENTS
# -------------------------------------------------------------------------
for component in "${COMPONENTS[@]}"; do
  echo "Installing component: $component"
  # The actual installation routine for each component is assumed to be
  # defined in a function or separate script named after the component.
  # For example, a component named 'git' would be handled by a function
  # called install_git or a script ./components/git.sh.
  #
  # The original repository likely contains a dispatch mechanism; we keep
  # that behaviour intact while simply feeding it the filtered component list.
  if declare -f "install_${component}" > /dev/null; then
    "install_${component}"
  elif [[ -x "./components/${component}.sh" ]]; then
    "./components/${component}.sh"
  else
    echo "Warning: No installer found for component '$component'. Skipping."
  fi
done
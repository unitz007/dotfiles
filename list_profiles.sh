#!/usr/bin/env bash
# list_profiles.sh - List available dotfile profiles defined in dotfiles.yml
# Usage:
#   ./list_profiles.sh          # human readable list, active profile marked with *
#   ./list_profiles.sh --json   # JSON output for machine consumption
#
# The script expects a file named `dotfiles.yml` in the same directory as this script.
# An optional file `.current_profile` (also in the same directory) can be used to
# indicate the currently active profile. If the file does not exist, no profile is
# marked as active.

set -euo pipefail

# Determine script directory (repository root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
YAML_FILE="${SCRIPT_DIR}/dotfiles.yml"
ACTIVE_FILE="${SCRIPT_DIR}/.current_profile"

# Verify dotfiles.yml exists
if [[ ! -f "${YAML_FILE}" ]]; then
  echo "Error: dotfiles.yml not found at ${YAML_FILE}" >&2
  exit 1
fi

# Determine active profile (if any)
ACTIVE_PROFILE=""
if [[ -f "${ACTIVE_FILE}" ]]; then
  ACTIVE_PROFILE="$(<"${ACTIVE_FILE}")"
  ACTIVE_PROFILE="${ACTIVE_PROFILE#"${ACTIVE_PROFILE%%[![:space:]]*}"}"   # trim leading whitespace
  ACTIVE_PROFILE="${ACTIVE_PROFILE%"${ACTIVE_PROFILE##*[![:space:]]}"}"   # trim trailing whitespace
fi

# Extract profile names from dotfiles.yml
# Assumes structure:
# profiles:
#   profile1:
#   profile2:
PROFILE_NAMES=()
# Find the line where "profiles:" starts, then capture subsequent indented keys
while IFS= read -r line; do
  # Match lines like "  profile_name:" (two spaces indentation)
  if [[ "$line" =~ ^[[:space:]]{2}([^:[:space:]]+): ]]; then
    PROFILE_NAMES+=("${BASH_REMATCH[1]}")
  elif [[ "$line" =~ ^[^[:space:]] ]]; then
    # Stop when we reach a non-indented line (end of profiles block)
    break
  fi
done < <(awk '/^[[:space:]]*profiles:/ {found=1; next} found {print}' "${YAML_FILE}")

# Output
if [[ "${1:-}" == "--json" ]]; then
  # Build JSON array: [{ "name": "profile1", "active": true }, ...]
  json="["
  first=true
  for name in "${PROFILE_NAMES[@]}"; do
    [[ $first = true ]] && first=false || json+=","
    if [[ "$name" == "$ACTIVE_PROFILE" ]]; then
      json+="{\"name\":\"$name\",\"active\":true}"
    else
      json+="{\"name\":\"$name\",\"active\":false}"
    fi
  done
  json+="]"
  echo "$json"
else
  for name in "${PROFILE_NAMES[@]}"; do
    if [[ "$name" == "$ACTIVE_PROFILE" ]]; then
      echo "* $name (active)"
    else
      echo "  $name"
    fi
  done
fi
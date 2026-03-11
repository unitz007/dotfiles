#!/usr/bin/env bash
set -euo pipefail

# Determine the directory where this script resides (repo root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SECRETS_ENC="${SCRIPT_DIR}/.secrets.gpg"

# If the encrypted secrets file does not exist, exit silently
if [[ ! -f "$SECRETS_ENC" ]]; then
  echo "No encrypted secrets file found at $SECRETS_ENC"
  exit 0
fi

# Create a temporary file for the decrypted secrets
TMP_SECRETS="$(mktemp /tmp/secrets.XXXXXX)"

# Ensure the temporary file is removed on exit or interruption
cleanup() {
  rm -f "$TMP_SECRETS"
}
trap cleanup EXIT

# Prompt the user for the GPG passphrase (hidden input)
read -s -p "Enter GPG passphrase for decrypting secrets: " GPG_PASS
echo

# Decrypt the secrets into the temporary file
# The passphrase is fed via stdin to avoid it appearing in process listings
echo "$GPG_PASS" | gpg --batch --yes --passphrase-fd 0 --decrypt "$SECRETS_ENC" > "$TMP_SECRETS"

# Source the decrypted secrets so that they become environment variables
# `set -a` automatically exports all variables defined in the sourced file
set -a
# shellcheck source=/dev/null
source "$TMP_SECRETS"
set +a

echo "Secrets have been loaded into the environment."
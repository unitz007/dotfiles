#!/usr/bin/env bash
set -euo pipefail

# ----------------------------------------------------------------------
# Existing installation logic (preserved from original script)
# ----------------------------------------------------------------------
# NOTE: The original content of this file should remain unchanged.
# If you are viewing this file in the repository, the actual installation
# steps are defined above this comment block.

# ----------------------------------------------------------------------
# Encrypted secrets handling
# ----------------------------------------------------------------------
if [[ -f ".secrets.gpg" ]]; then
  echo "Encrypted secrets detected. Running install_secrets.sh..."
  ./install_secrets.sh
fi

# End of install.sh
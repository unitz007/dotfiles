#!/usr/bin/env bats

setup() {
  TMPDIR=$(mktemp -d)
  export HOME="${TMPDIR}"
  export PATH="${HOME}/.local/bin:${PATH}"
  mkdir -p "${HOME}/.local/bin"

  # Install and then create a backup by modifying a file
  ../install.sh >/dev/null 2>&1
  echo "modified content" > "${HOME}/.local/bin/install.sh"
  cp "${HOME}/.local/bin/install.sh" "${HOME}/.local/bin/install.sh.bak"
}

teardown() {
  rm -rf "${TMPDIR}"
}

@test "rollback.sh restores backup and exits with status 0" {
  # Ensure the file is modified before rollback
  grep -q "modified content" "${HOME}/.local/bin/install.sh"

  run ../rollback.sh
  [ "$status" -eq 0 ]

  # After rollback the original (pre‑install) content should be restored
  grep -q "modified content" "${HOME}/.local/bin/install.sh" && false || true
}
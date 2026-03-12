#!/usr/bin/env bats

setup() {
  TMPDIR=$(mktemp -d)
  export HOME="${TMPDIR}"
  export PATH="${HOME}/.local/bin:${PATH}"
  mkdir -p "${HOME}/.local/bin"

  # Simulate an existing installation
  ../install.sh >/dev/null 2>&1
}

teardown() {
  rm -rf "${TMPDIR}"
}

@test "update.sh exits with status 0" {
  run ../update.sh
  [ "$status" -eq 0 ]
}

@test "update.sh --dry-run does not modify installed files" {
  # Capture checksum before dry‑run
  before=$(sha256sum "${HOME}/.local/bin/install.sh" | cut -d' ' -f1)

  run ../update.sh --dry-run
  [ "$status" -eq 0 ]

  after=$(sha256sum "${HOME}/.local/bin/install.sh" | cut -d' ' -f1)
  [ "$before" = "$after" ]
}
#!/usr/bin/env bats

setup() {
  TMPDIR=$(mktemp -d)
  export HOME="${TMPDIR}"
  export PATH="${HOME}/.local/bin:${PATH}"
  mkdir -p "${HOME}/.local/bin"

  # Create two temporary files for diff comparison
  echo "line1" > "${TMPDIR}/file_a"
  echo "line2" > "${TMPDIR}/file_b"
}

teardown() {
  rm -rf "${TMPDIR}"
}

@test "diff.sh exits with status 0 on identical files" {
  cp "${TMPDIR}/file_a" "${TMPDIR}/file_copy"
  run ../diff.sh "${TMPDIR}/file_a" "${TMPDIR}/file_copy"
  [ "$status" -eq 0 ]
}

@test "diff.sh exits with non‑zero status on differing files" {
  run ../diff.sh "${TMPDIR}/file_a" "${TMPDIR}/file_b"
  [ "$status" -ne 0 ]
}
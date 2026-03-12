#!/usr/bin/env bats

setup() {
  TMPDIR=$(mktemp -d)
  export HOME="${TMPDIR}"
  export PATH="${HOME}/.local/bin:${PATH}"
  mkdir -p "${HOME}/.local/bin"
}

teardown() {
  rm -rf "${TMPDIR}"
}

@test "status.sh exits with status 0" {
  run ../status.sh
  [ "$status" -eq 0 ]
}

@test "status.sh reports installed state correctly" {
  # No installation yet
  run ../status.sh
  [ "$status" -eq 0 ]
  [[ "$output" =~ "not installed" ]]

  # Install then check status
  ../install.sh >/dev/null 2>&1
  run ../status.sh
  [ "$status" -eq 0 ]
  [[ "$output" =~ "installed" ]]
}
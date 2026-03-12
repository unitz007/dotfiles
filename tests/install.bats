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

@test "install.sh exits with status 0" {
  run ../install.sh
  [ "$status" -eq 0 ]
}

@test "install.sh creates symlinks for core scripts" {
  run ../install.sh
  [ "$status" -eq 0 ]

  for script in install.sh uninstall.sh status.sh diff.sh update.sh rollback.sh; do
    [ -L "${HOME}/.local/bin/${script}" ]
  done
}

@test "install.sh --dry-run does not create symlinks" {
  run ../install.sh --dry-run
  [ "$status" -eq 0 ]

  for script in install.sh uninstall.sh status.sh diff.sh update.sh rollback.sh; do
    [ ! -e "${HOME}/.local/bin/${script}" ]
  done
}
#!/usr/bin/env bats

setup() {
  TMPDIR=$(mktemp -d)
  export HOME="${TMPDIR}"
  export PATH="${HOME}/.local/bin:${PATH}"
  mkdir -p "${HOME}/.local/bin"

  # Ensure symlinks exist before uninstall
  ../install.sh >/dev/null 2>&1
}

teardown() {
  rm -rf "${TMPDIR}"
}

@test "uninstall.sh exits with status 0" {
  run ../uninstall.sh
  [ "$status" -eq 0 ]
}

@test "uninstall.sh removes previously installed symlinks" {
  run ../uninstall.sh
  [ "$status" -eq 0 ]

  for script in install.sh uninstall.sh status.sh diff.sh update.sh rollback.sh; do
    [ ! -e "${HOME}/.local/bin/${script}" ]
  done
}

@test "uninstall.sh --dry-run does not remove symlinks" {
  run ../uninstall.sh --dry-run
  [ "$status" -eq 0 ]

  for script in install.sh uninstall.sh status.sh diff.sh update.sh rollback.sh; do
    [ -L "${HOME}/.local/bin/${script}" ]
  done
}
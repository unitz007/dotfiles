#!/usr/bin/env bats

setup() {
  # Create an isolated HOME directory for the test
  TMP_HOME=$(mktemp -d)
  export HOME="$TMP_HOME"

  # Path to the backup directory used by restore.sh (default location)
  BACKUP_DIR="${HOME}/.dotfiles_backup"
  mkdir -p "$BACKUP_DIR"

  # Create a dummy managed file that will be backed‑up
  echo "original content" > "${HOME}/.dummy"

  # Simulate the backup that install.sh would have created
  cp "${HOME}/.dummy" "${BACKUP_DIR}/.dummy"
}

teardown() {
  rm -rf "$TMP_HOME"
}

@test "restore.sh restores original file from backup" {
  # Modify the managed file to simulate user changes
  echo "modified content" > "${HOME}/.dummy"

  # Execute the restore script (relative to repository root)
  run bash "${BATS_TEST_DIRNAME}/../restore.sh"

  # The script should exit cleanly
  [ "$status" -eq 0 ]

  # The file should be restored to its original content
  diff -q "${HOME}/.dummy" "${BACKUP_DIR}/.dummy"
}
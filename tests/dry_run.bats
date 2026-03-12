#!/usr/bin/env bats

setup() {
  # Create a temporary directory for the test run
  TMPDIR=$(mktemp -d)
  # Copy the scripts into the temporary directory
  cp "$BATS_TEST_DIRNAME/../install.sh" "$TMPDIR/install.sh"
  cp "$BATS_TEST_DIRNAME/../restore.sh" "$TMPDIR/restore.sh"
  chmod +x "$TMPDIR/install.sh" "$TMPDIR/restore.sh"
}

teardown() {
  rm -rf "$TMPDIR"
}

@test "install.sh dry-run prints actions without modifying filesystem" {
  run "$TMPDIR/install.sh" -n
  [ "$status" -eq 0 ]
  [[ "$output" == *"[dry-run]"* ]]
}

@test "restore.sh dry-run prints actions without modifying filesystem" {
  run "$TMPDIR/restore.sh" -n
  [ "$status" -eq 0 ]
  [[ "$output" == *"[dry-run]"* ]]
}
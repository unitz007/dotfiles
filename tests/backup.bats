#!/usr/bin/env bats

setup() {
  TMPDIR=$(mktemp -d)
  export HOME="$TMPDIR"
  REPO_ROOT="$(pwd)"
  cp -r "$REPO_ROOT"/{backup.sh,dotfiles.yml,.dotfiles} "$TMPDIR"/
  cd "$TMPDIR"
}

teardown() {
  rm -rf "$TMPDIR"
}

@test "backup rotation respects keep policy" {
  # Run backup several times to generate multiple snapshots.
  for i in {1..4}; do
    run bash "$REPO_ROOT/backup.sh"
    [ "$status" -eq 0 ]
    # Ensure each backup has a unique timestamp.
    sleep 1
  done

  backup_root="$HOME/.dotfiles_backup"
  # Count the number of backup directories created.
  count=$(find "$backup_root" -mindepth 1 -maxdepth 1 -type d | wc -l)

  # The keep policy is defined in dotfiles.yml (default to 3 if not set).
  # The test asserts that we never keep more than 3 backups.
  [ "$count" -le 3 ]
}
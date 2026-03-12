#!/usr/bin/env bats

setup() {
  TMPDIR=$(mktemp -d)
  export HOME="$TMPDIR"
  REPO_ROOT="$(pwd)"
  cp -r "$REPO_ROOT"/{install.sh,uninstall.sh,dotfiles.yml,.dotfiles} "$TMPDIR"/
  cd "$TMPDIR"
}

teardown() {
  rm -rf "$TMPDIR"
}

@test "uninstall restores original files" {
  # Create a real file that the installer would back up.
  echo "original content" > "$HOME/.bashrc"

  # Run the installer – it should back up the original and replace it with a symlink.
  run bash "$REPO_ROOT/install.sh"
  [ "$status" -eq 0 ]
  [ -L "$HOME/.bashrc" ]

  # Run the uninstaller – it should restore the original file and remove the symlink.
  run bash "$REPO_ROOT/uninstall.sh"
  [ "$status" -eq 0 ]

  [ ! -L "$HOME/.bashrc" ]
  [ -f "$HOME/.bashrc" ]
  grep -q "original content" "$HOME/.bashrc"
}
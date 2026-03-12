#!/usr/bin/env bats

setup() {
  # Create an isolated HOME directory
  TMPDIR=$(mktemp -d)
  export HOME="$TMPDIR"

  # Preserve the repository root path
  REPO_ROOT="$(pwd)"

  # Copy the scripts and configuration needed for the test
  cp -r "$REPO_ROOT"/{install.sh,dotfiles.yml,.dotfiles} "$TMPDIR"/
  cd "$TMPDIR"
}

teardown() {
  rm -rf "$TMPDIR"
}

@test "install creates symlinks" {
  run bash "$REPO_ROOT/install.sh"
  [ "$status" -eq 0 ]

  # The repository's dotfiles are expected to be under .dotfiles/
  # Verify that a typical dotfile (e.g., .bashrc) is linked.
  [ -L "$HOME/.bashrc" ]

  target=$(readlink "$HOME/.bashrc")
  # The target may be an absolute path or relative to the repo root.
  [[ "$target" == "$REPO_ROOT/.dotfiles/.bashrc" ]] || [[ "$target" == ".dotfiles/.bashrc" ]]
}

@test "install dry‑run does not create symlinks" {
  run bash "$REPO_ROOT/install.sh" --dry-run
  [ "$status" -eq 0 ]

  # The dry‑run output should mention the file it would link.
  [[ "$output" == *".bashrc"* ]]

  # No symlink should actually exist.
  [ ! -e "$HOME/.bashrc" ]
}
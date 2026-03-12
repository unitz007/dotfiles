#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
  # Create a temporary directory for the test repository
  TMP_REPO=$(mktemp -d)
  cd "$TMP_REPO"

  # Create dummy source files
  echo "export PS1='\\u:\\w\\$ '" > bashrc
  echo "set number" > vimrc
  echo "[user]\n\tname = Test User" > gitconfig

  # Create dotfiles.yml with two profiles
  cat > dotfiles.yml <<'EOF'
dotfiles:
  bashrc:
    src: bashrc
    dest: ~/.bashrc
  vimrc:
    src: vimrc
    dest: ~/.vimrc
  gitconfig:
    src: gitconfig
    dest: ~/.gitconfig

profiles:
  default: [bashrc, vimrc, gitconfig]
  work:    [bashrc, gitconfig]
EOF

  # Ensure a clean HOME for the test
  export HOME="$TMP_REPO/home"
  mkdir -p "$HOME"
}

teardown() {
  rm -rf "$TMP_REPO"
}

@test "install.sh without --profile installs default profile" {
  run bash "$TMP_REPO/../install.sh"
  [ "$status" -eq 0 ]

  # All three symlinks should exist
  assert [ -L "$HOME/.bashrc" ]
  assert [ -L "$HOME/.vimrc" ]
  assert [ -L "$HOME/.gitconfig" ]

  # Verify they point to the correct source files
  assert_equal "$(readlink "$HOME/.bashrc")" "$(realpath bashrc)"
  assert_equal "$(readlink "$HOME/.vimrc")" "$(realpath vimrc)"
  assert_equal "$(readlink "$HOME/.gitconfig")" "$(realpath gitconfig)"
}

@test "install.sh --profile work installs only work profile files" {
  run bash "$TMP_REPO/../install.sh" --profile work
  [ "$status" -eq 0 ]

  # Only bashrc and gitconfig should be linked
  assert [ -L "$HOME/.bashrc" ]
  assert [ -L "$HOME/.gitconfig" ]
  refute [ -e "$HOME/.vimrc" ]

  # Verify they point to the correct source files
  assert_equal "$(readlink "$HOME/.bashrc")" "$(realpath bashrc)"
  assert_equal "$(readlink "$HOME/.gitconfig")" "$(realpath gitconfig)"
}
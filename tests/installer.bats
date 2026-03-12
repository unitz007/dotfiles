#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
  # Create a temporary HOME directory for each test
  export ORIGINAL_HOME="${HOME}"
  export HOME="$(mktemp -d)"
  REPO_ROOT="$(pwd)"
  export REPO_ROOT
  # Ensure a clean state before each test
  rm -rf "${HOME:?}"/*
}

teardown() {
  # Restore original HOME and clean up
  rm -rf "${HOME:?}"
  export HOME="${ORIGINAL_HOME}"
  unset REPO_ROOT
}

# Helper to get list of dotfiles in the repository
dotfiles() {
  find "${REPO_ROOT}/dotfiles" -type f -printf "%f\n"
}

@test "fresh install creates symlinks without backups" {
  run "${REPO_ROOT}/install.sh" <<< $'y\n'  # assume script prompts for confirmation
  assert_success

  for file in $(dotfiles); do
    target="${HOME}/.${file}"
    source="${REPO_ROOT}/dotfiles/${file}"
    assert_file_exists "${target}"
    assert_symlink "${target}"
    assert_equal "$(readlink "${target}")" "${source}"
  done

  # No backup directory should be created on a fresh install
  [ ! -d "${HOME}/.dotfiles_backup" ]
}

@test "re‑install backs up existing files and recreates symlinks" {
  # Create a pre‑existing dotfile that will be backed up
  echo "original content" > "${HOME}/.bashrc"

  run "${REPO_ROOT}/install.sh" <<< $'y\n'
  assert_success

  # Backup should exist
  backup_file="${HOME}/.dotfiles_backup/.bashrc"
  assert_file_exists "${backup_file}"
  run cat "${backup_file}"
  assert_output "original content"

  # Symlink should now point to the repository version
  target="${HOME}/.bashrc"
  source="${REPO_ROOT}/dotfiles/bashrc"
  assert_symlink "${target}"
  assert_equal "$(readlink "${target}")" "${source}"
}

@test "uninstall restores backups and removes links" {
  # First perform an install to set up state
  echo "old content" > "${HOME}/.vimrc"
  run "${REPO_ROOT}/install.sh" <<< $'y\n'
  assert_success

  # Now run uninstall
  run "${REPO_ROOT}/uninstall.sh"
  assert_success

  # Backed‑up files should be restored
  restored="${HOME}/.vimrc"
  assert_file_exists "${restored}"
  run cat "${restored}"
  assert_output "old content"

  # No symlinks should remain
  for file in $(dotfiles); do
    target="${HOME}/.${file}"
    [ ! -L "${target}" ]
  done

  # Backup directory should be removed
  [ ! -d "${HOME}/.dotfiles_backup" ]
}

@test "interactive installer respects user selections" {
  # Simulate user selecting only a subset of dotfiles (e.g., bashrc and vimrc)
  # Assuming the interactive script asks a yes/no per file in alphabetical order
  # Provide 'y' for the first two files and 'n' for the rest
  selections=$(printf 'y\ny\nn\nn\nn\n')
  run "${REPO_ROOT}/install_interactive.sh" <<< "${selections}"
  assert_success

  # Expected selected files (adjust according to actual dotfiles list)
  selected=("bashrc" "vimrc")
  for file in "${selected[@]}"; do
    target="${HOME}/.${file}"
    source="${REPO_ROOT}/dotfiles/${file}"
    assert_file_exists "${target}"
    assert_symlink "${target}"
    assert_equal "$(readlink "${target}")" "${source}"
  done

  # Files not selected should remain untouched (no symlink, no backup)
  for file in $(dotfiles); do
    if [[ ! " ${selected[*]} " =~ " ${file} " ]]; then
      target="${HOME}/.${file}"
      [ ! -e "${target}" ]
    fi
  done
}
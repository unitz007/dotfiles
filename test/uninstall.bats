#!/usr/bin/env bats

setup() {
  # Create isolated HOME and repository directories
  TMPDIR=$(mktemp -d)
  export HOME="${TMPDIR}/home"
  mkdir -p "${HOME}"
  export DOTFILES_REPO="${TMPDIR}/repo"
  mkdir -p "${DOTFILES_REPO}"

  # Sample dotfile in the repository
  echo "repo content" > "${DOTFILES_REPO}/.bashrc"

  # Simulate a pre‑existing user file that will be backed up
  echo "original user content" > "${HOME}/.bashrc"

  # Create a backup directory with a timestamped sub‑folder
  BACKUP_DIR="${HOME}/.dotfiles_backup"
  mkdir -p "${BACKUP_DIR}/20230101"
  cp "${HOME}/.bashrc" "${BACKUP_DIR}/20230101/.bashrc"

  # Replace the user file with a symlink to the repo version (as install.sh would)
  ln -s "${DOTFILES_REPO}/.bashrc" "${HOME}/.bashrc"

  # Manifest used by uninstall.sh to know which files were managed
  echo "${HOME}/.bashrc" > "${HOME}/.dotfiles_install_manifest"
}

teardown() {
  rm -rf "${TMPDIR}"
}

@test "dry‑run does not modify files or backup directory" {
  run bash uninstall.sh --dry-run --force
  [ "$status" -eq 0 ]

  # The symlink should still exist
  [ -L "${HOME}/.bashrc" ]

  # Its content should still be the repo content (symlink target)
  diff <(readlink -f "${HOME}/.bashrc") <(realpath "${DOTFILES_REPO}/.bashrc")

  # Backup directory must still be present
  [ -d "${HOME}/.dotfiles_backup" ]
}

@test "uninstall restores original file, removes symlink and deletes backup directory" {
  run bash uninstall.sh --force
  [ "$status" -eq 0 ]

  # Symlink should be gone
  [ ! -L "${HOME}/.bashrc" ]

  # Original content should be restored from backup
  diff <(cat "${HOME}/.bashrc") <(echo "original user content")

  # Backup directory should be removed
  [ ! -d "${HOME}/.dotfiles_backup" ]
}
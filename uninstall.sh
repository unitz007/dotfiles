#!/usr/bin/env bash
set -e

# ------------------------------------------------------------
#  Dotfiles uninstaller
#  Added support for --dry-run flag (Issue #179)
# ------------------------------------------------------------

# ----------------------------------------------------------------
#  Global flags
# ----------------------------------------------------------------
DRY_RUN=0

# ----------------------------------------------------------------
#  Helper: print usage information
# ----------------------------------------------------------------
print_usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
  --dry-run        Show the actions that would be performed without
                   making any changes to the filesystem.
  -h, --help       Show this help message and exit.

Examples:
  $(basename "$0")               # Perform a real uninstallation
  $(basename "$0") --dry-run    # Show what would happen without changing anything
EOF
}

# ----------------------------------------------------------------
#  Argument parsing
# ----------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      print_usage
      exit 0
      ;;
    *)
      echo "Error: Unknown option: $1"
      print_usage
      exit 1
      ;;
  esac
done

# ----------------------------------------------------------------
#  Helper: conditionally execute a command
# ----------------------------------------------------------------
maybe() {
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "[dry-run] $*"
  else
    "$@"
  fi
}

# ----------------------------------------------------------------
#  Override common filesystem / package commands so they respect
#  the dry‑run flag.
# ----------------------------------------------------------------
ln()      { maybe command ln "$@"; }
cp()      { maybe command cp "$@"; }
mv()      { maybe command mv "$@"; }
rm()      { maybe command rm "$@"; }
mkdir()   { maybe command mkdir "$@"; }
apt-get() { maybe command apt-get "$@"; }
brew()    { maybe command brew "$@"; }

# ----------------------------------------------------------------
#  Configuration
# ----------------------------------------------------------------
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${HOME}"

# ----------------------------------------------------------------
#  Remove symlinks and restore backups if they exist
# ----------------------------------------------------------------
restore_file() {
  local target="$1"
  local backup="${HOME_DIR}/${target}.backup"

  if [[ -L "${HOME_DIR}/${target}" ]]; then
    echo "Removing symlink ${HOME_DIR}/${target}"
    rm "${HOME_DIR}/${target}"
  fi

  if [[ -e "${backup}" ]]; then
    echo "Restoring backup ${backup} → ${HOME_DIR}/${target}"
    mv "${backup}" "${HOME_DIR}/${target}"
  fi
}

# ----------------------------------------------------------------
#  Uninstall packages (example for Debian/Ubuntu)
# ----------------------------------------------------------------
uninstall_packages() {
  if command -v apt-get >/dev/null 2>&1; then
    echo "Removing installed packages"
    sudo apt-get purge -y git curl zsh
    sudo apt-get autoremove -y
  elif command -v brew >/dev/null 2>&1; then
    echo "Removing installed packages via Homebrew"
    brew uninstall git curl zsh
  else
    echo "No supported package manager found (apt-get or brew). Skipping package removal."
  fi
}

# ----------------------------------------------------------------
#  Main execution
# ----------------------------------------------------------------
main() {
  echo "Starting dotfiles uninstallation (dry‑run: ${DRY_RUN})"

  # Example list of dotfiles that were installed
  declare -a files=(
    ".bashrc"
    ".zshrc"
    ".gitconfig"
    ".vimrc"
  )

  for file in "${files[@]}"; do
    restore_file "${file}"
  done

  uninstall_packages

  echo "Uninstallation complete."
}

main
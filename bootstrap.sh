#!/usr/bin/env bash
set -euo pipefail

# --- Argument parsing ---
DRY_RUN=0
for arg in "$@"; do
  if [[ "$arg" == "--dry-run" ]]; then
    DRY_RUN=1
  fi
done

# --- Helper: run or dry-run ---
run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[DRY RUN] $*"
    return 0
  else
    eval "$@"
  fi
}

# --- macOS guard ---
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Error: This script only supports macOS. Detected: $(uname -s)" >&2
  exit 1
fi

# --- Repository root detection ---
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Homebrew installation ---
if ! command -v brew &>/dev/null; then
  echo "Homebrew not found. Installing..."
  run NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Add brew to PATH for Apple Silicon or Intel
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# --- Brew package installation ---
BREW_PACKAGES=("stow" "oh-my-posh" "tmux" "neovim")
for pkg in "${BREW_PACKAGES[@]}"; do
  if brew list --formula "$pkg" &>/dev/null; then
    echo "[SKIP] $pkg already installed"
  else
    run brew install "$pkg"
  fi
done

# --- TPM (Tmux Plugin Manager) installation ---
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [[ ! -d "$TPM_DIR" ]]; then
  run mkdir -p "$(dirname "$TPM_DIR")"
  run git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
  echo "[SKIP] TPM already installed"
fi

# --- Symlink creation ---
LINKED=0
SKIPPED=0

link_dotfile() {
  local source_relative_path="$1"
  local target_absolute_path="$2"
  local source="$DOTFILES_DIR/$source_relative_path"

  if [[ ! -e "$source" ]]; then
    echo "Warning: Source '$source' does not exist. Skipping." >&2
    return 1
  fi

  run mkdir -p "$(dirname "$target_absolute_path")"

  if [[ -L "$target_absolute_path" && "$(readlink "$target_absolute_path")" == "$source" ]]; then
    echo "[SKIP] $target_absolute_path already linked"
    SKIPPED=$((SKIPPED + 1))
  else
    run ln -sf "$source" "$target_absolute_path"
    LINKED=$((LINKED + 1))
  fi
}

link_dotfile ".zshrc" "$HOME/.zshrc" || true
link_dotfile ".oh-my-posh-theme.json" "$HOME/.oh-my-posh-theme.json" || true
link_dotfile ".skhdrc" "$HOME/.skhdrc" || true
link_dotfile ".aerospace.toml" "$HOME/.aerospace.toml" || true
link_dotfile "nvim" "$HOME/.config/nvim" || true
link_dotfile "tmux/tmux.conf" "$HOME/.tmux.conf" || true
link_dotfile "yazi.toml" "$HOME/.config/yazi/yazi.toml" || true
link_dotfile "zed/settings.json" "$HOME/.config/zed/settings.json" || true

# --- Summary ---
echo ""
echo "--- Summary ---"
echo "Linked: $LINKED"
echo "Skipped: $SKIPPED"
echo "Bootstrap complete. Restart your shell or run 'exec zsh' to apply changes."
# This is the main zsh configuration file.
# It sources modular configuration files from this repo (aliases.zsh, functions.zsh, etc).

# Source exports first: plugins.zsh depends on OH_MY_POSH_THEME being set
source ~/zsh/exports.zsh

# Initialize zsh plugins and theme settings
source ~/zsh/plugins.zsh

# Source remaining modular files in appropriate order
source ~/zsh/aliases.zsh
source ~/zsh/functions.zsh
source ~/zsh/path.zsh
source ~/zsh/options.zsh
source ~/zsh/keybindings.zsh

# Automatically attach interactive terminals to tmux.
# Set DOTSYNC_NO_TMUX=1 before starting zsh to open a plain shell.
if [[ -o interactive && -z "${TMUX:-}" && -z "${DOTSYNC_NO_TMUX:-}" ]] && command -v tmux >/dev/null 2>&1; then
  exec tmux new-session -A -s main
fi

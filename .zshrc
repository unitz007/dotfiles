# .zshrc – interactive Zsh configuration
# This file is sourced for interactive shells only.

# ----------------------------------------------------------------------
# Load Oh My Zsh if it is installed
# ----------------------------------------------------------------------
if [ -d "$HOME/.oh-my-zsh" ]; then
  export ZSH="$HOME/.oh-my-zsh"
  ZSH_THEME="robbyrussell"
  plugins=(git)
  source "$ZSH/oh-my-zsh.sh"
fi

# ----------------------------------------------------------------------
# Load zinit (if installed) – a fast Zsh plugin manager
# ----------------------------------------------------------------------
if [ -f "${ZDOTDIR:-$HOME}/.zinit/bin/zinit.zsh" ]; then
  source "${ZDOTDIR:-$HOME}/.zinit/bin/zinit.zsh"
fi

# ----------------------------------------------------------------------
# General Zsh options
# ----------------------------------------------------------------------
setopt autocd               # Change to a directory just by typing its name
setopt correct              # Auto‑correct minor spelling errors
setopt hist_ignore_all_dups # Do not record duplicate commands
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# ----------------------------------------------------------------------
# Handy aliases
# ----------------------------------------------------------------------
alias ll='ls -lah'
alias gs='git status'
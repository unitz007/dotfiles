# Key bindings

# Vi-style command-line editing.
bindkey -v
export KEYTIMEOUT=1

# Publish the current zsh vi mode to tmux so the status bar can show it.
function dotsync-tmux-vi-mode {
  if [[ -n "${TMUX:-}" ]]; then
    tmux set-option -gq @zsh_vi_mode "$1"
  fi
}

function dotsync-zle-mode-refresh {
  if [[ ${KEYMAP} == vicmd ]]; then
    dotsync-tmux-vi-mode NORMAL
  else
    dotsync-tmux-vi-mode INSERT
  fi
}

function zle-keymap-select {
  dotsync-zle-mode-refresh
}

function zle-line-init {
  zle -K viins
  dotsync-tmux-vi-mode INSERT
}

function zle-line-finish {
  dotsync-tmux-vi-mode INSERT
}

zle -N zle-keymap-select
zle -N zle-line-init
zle -N zle-line-finish
zle -N dotsync-zle-mode-refresh
autoload -Uz add-zle-hook-widget
add-zle-hook-widget -d line-pre-redraw dotsync-zle-mode-refresh 2>/dev/null

# Keep common Emacs-style shortcuts available while in insert mode.
bindkey -M viins '^A' beginning-of-line
bindkey -M viins '^E' end-of-line
bindkey -M viins '^P' up-line-or-history
bindkey -M viins '^N' down-line-or-history
bindkey -M viins '^R' history-incremental-search-backward

# Key bindings

# Vi-style command-line editing.
bindkey -v
export KEYTIMEOUT=1

# Make the cursor show which mode the prompt is in:
# insert mode = beam, normal mode = block.
function dotsync-tmux-vi-mode {
  if [[ -n "${TMUX:-}" ]]; then
    tmux set-option -gq @zsh_vi_mode "$1"
    tmux refresh-client -S
  fi
}

function dotsync-zle-mode-refresh {
  if [[ ${KEYMAP} == vicmd ]]; then
    echo -ne '\e[2 q'
    dotsync-tmux-vi-mode NORMAL
  else
    echo -ne '\e[6 q'
    dotsync-tmux-vi-mode INSERT
  fi
}

function zle-keymap-select {
  dotsync-zle-mode-refresh
}

function zle-line-init {
  zle -K viins
  echo -ne '\e[6 q'
  dotsync-tmux-vi-mode INSERT
}

function zle-line-finish {
  echo -ne '\e[0 q'
  dotsync-tmux-vi-mode INSERT
}

zle -N zle-keymap-select
zle -N zle-line-init
zle -N zle-line-finish
zle -N dotsync-zle-mode-refresh
autoload -Uz add-zle-hook-widget
add-zle-hook-widget line-pre-redraw dotsync-zle-mode-refresh

# Keep common Emacs-style shortcuts available while in insert mode.
bindkey -M viins '^A' beginning-of-line
bindkey -M viins '^E' end-of-line
bindkey -M viins '^P' up-line-or-history
bindkey -M viins '^N' down-line-or-history
bindkey -M viins '^R' history-incremental-search-backward

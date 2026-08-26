# Key bindings

# Vi-style command-line editing.
bindkey -v
export KEYTIMEOUT=1

# Make the cursor show which mode the prompt is in:
# insert mode = beam, normal mode = block.
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]]; then
    echo -ne '\e[2 q'
  else
    echo -ne '\e[6 q'
  fi
}

function zle-line-init {
  zle -K viins
  echo -ne '\e[6 q'
}

function zle-line-finish {
  echo -ne '\e[0 q'
}

zle -N zle-keymap-select
zle -N zle-line-init
zle -N zle-line-finish

# Keep common Emacs-style shortcuts available while in insert mode.
bindkey -M viins '^A' beginning-of-line
bindkey -M viins '^E' end-of-line
bindkey -M viins '^P' up-line-or-history
bindkey -M viins '^N' down-line-or-history
bindkey -M viins '^R' history-incremental-search-backward

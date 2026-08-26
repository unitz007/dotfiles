# Key bindings

# Vi-style command-line editing.
bindkey -v
export KEYTIMEOUT=1

# Clear older tmux mode-indicator hooks if this file is sourced in a shell
# that loaded a previous version.
autoload -Uz add-zle-hook-widget
add-zle-hook-widget -d line-pre-redraw dotsync-zle-mode-refresh 2>/dev/null
zle -D zle-keymap-select 2>/dev/null
zle -D zle-line-init 2>/dev/null
zle -D zle-line-finish 2>/dev/null
zle -D dotsync-zle-mode-refresh 2>/dev/null

# Keep common Emacs-style shortcuts available while in insert mode.
bindkey -M viins '^A' beginning-of-line
bindkey -M viins '^E' end-of-line
bindkey -M viins '^P' up-line-or-history
bindkey -M viins '^N' down-line-or-history
bindkey -M viins '^R' history-incremental-search-backward

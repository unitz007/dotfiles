# fzf configuration
# Guard: only load if fzf is installed
if command -v fzf &>/dev/null; then

  # --- fzf-tmux integration ---
  # Open fzf in a tmux split pane when inside a tmux session
  export FZF_TMUX=1
  export FZF_TMUX_OPTS="-d 40%"

  # --- Default options ---
  export FZF_DEFAULT_OPTS="
    --layout=reverse
    --height 40%
    --border
    --cycle
    --preview 'bat --color=always --style=numbers --line-range=:500 {}'
    --bind 'ctrl-/:toggle-preview'
    --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
    --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
    --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
  "

  # --- History search (Ctrl+R) ---
  export FZF_CTRL_R_OPTS="
    --preview 'echo {}'
    --preview-window down:3:wrap
    --tac
  "

  # --- File finding (Ctrl+T) ---
  export FZF_CTRL_T_OPTS="
    --multi
  "

  # --- Directory cd (Alt+C) ---
  export FZF_ALT_C_OPTS="
    --preview 'command -v eza &>/dev/null && eza --tree --color=always {} | head -200 || ls --color=always {}'
  "

  # --- Source fzf keybindings and completion ---
  # Use dynamic detection of fzf installation path
  if command -v fzf >/dev/null 2>&1; then
    local fzf_base="$(dirname $(dirname $(command -v fzf)))"
    if [[ -d "$fzf_base/shell" ]]; then
      source "$fzf_base/shell/key-bindings.zsh"
      source "$fzf_base/shell/completion.zsh"
    fi
  fi

fi
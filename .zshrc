# Amazon Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"
# Q pre block. Keep at the top of this file.
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.

# Variables & Assignments
eval "$(oh-my-posh init zsh --config ~/.oh-my-posh-theme.json)"
if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
  tmux attach-session -t default || tmux new-session -s default
fi


export KUBE_EDITOR="nvim"
#plugins=(zsh-syntax-highlighting)
#source $ZSH/oh-my-zsh.sh

# Aliases
alias ls="nu -c ls"
alias la="nu -c 'ls -la'"
alias python=python3
alias run="sdlc run"
alias tst="sdlc test"
alias build="sdlc build"
alias vim=nvim
alias update="brew upgrade && upgrade"
alias k=kubectl
alias kgs="kubectl get services"
alias kgp="kubectl get pods"
alias kgd="kubectl get deployments"
alias ka="kubectl apply -f"
alias kd="kubectl delete"
alias pull="git pull"
alias g="git"
alias gc="git checkout"
alias ..="cd ../"
alias cls='clear'
alias tf=terraform
alias tfp="terraform plan"
alias tfa="tf apply"
alias rmDir="rm -rf $1"
#alias gwp="cd ~/Personal/Golang" # Golang workspace

function commit() {
	if [[ "$1" == "" ]]
  then
		echo "Error: missing 'commit message'"
		echo "Usage: commit <commit message>"
	else
		git add .
		git commit -m "$1"
    if [[ "$2" == "-p" ]]
    then
      if [[ "$3" == "" ]]
      then
        git push origin main
      else
        git push origin "$3"    
      fi
    fi
	fi
}

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# function vm() {
#   if [[ $# -eq 0 ]]; then
#     echo "Usage: vm $arg"
#     return
#   fi

#   if [[ $1 == 'up' ]]; then
#     ustart()
#   fi

#   if [[ $1 == 'down']]; then
#     uend()
#   fi
# }

function ustart() {
  echo "Spinning Up Ubuntu VM..."
  multipass launch -n ubuntu --cpus 4 --disk 20G --memory 2G  --cloud-init ~/cloud-init.yaml
  multipass shell ubuntu
}

function uend() {
  echo "Tearing Down Ubuntu VM..."
  multipass delete ubuntu
  multipass purge 
}

# set language
export LANG=en_US.UTF-8

# neofetch
neofetch

[[ -f "$HOME/fig-export/dotfiles/dotfile.zsh" ]] && builtin source "$HOME/fig-export/dotfiles/dotfile.zsh"

# Q post block. Keep at the bottom of this file.
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Amazon Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"

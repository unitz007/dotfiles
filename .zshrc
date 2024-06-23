# Amazon Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"
# Q pre block. Keep at the top of this file.
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Variables & Assignments
eval "$(oh-my-posh init zsh --config ~/.oh-my-posh-theme.json)"

export KUBE_EDITOR="nvim"
#plugins=(zsh-autosuggestions zsh-syntax-highlighting)
#source $ZSH/oh-my-zsh.sh

# Aliases
alias ls="nu -c ls"
alias la="nu -c 'ls -la'"
# alias python=python3
alias run="sdlc run"
alias tst="sdlc test"
alias build="sdlc build"
alias vim=nvim
alias update="brew update"
alias upgrade="brew upgrade"
alias k=kubectl
alias kgs="kubectl get services"
alias kgp="kubectl get pods"
alias kgd="kubectl get deployments"
alias ka="kubectl apply -f"
alias kd="kubectl delete"
alias pull="git pull"
# alias g="git"
alias gc="git checkout"
alias ..="cd .."

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

[[ -f "$HOME/fig-export/dotfiles/dotfile.zsh" ]] && builtin source "$HOME/fig-export/dotfiles/dotfile.zsh"

# Q post block. Keep at the bottom of this file.
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Amazon Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"

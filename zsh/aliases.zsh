# Aliases
if command -v nu >/dev/null 2>&1; then
  alias ls="nu -c ls"
  alias la="nu -c 'ls -la'"
else
  alias ls="ls"
  alias la="ls -la"
fi
alias run="sdlc run"
alias tst="sdlc test"
alias build="sdlc build"
alias vim=nvim
alias vi=nvim
alias update="brew update && brew upgrade && brew cleanup && echo '✅ Brew update complete' || echo '❌ Brew update failed'"
alias k=kubectl
alias kgs="kubectl get services"
alias kgp="kubectl get pods"
alias kgd="kubectl get deployments"
alias ka="kubectl apply -f"
alias kd="kubectl delete --wait"
alias gpl="git pull"
alias g="git"
alias gco="git checkout"
alias ..="cd ../"
alias ...="cd ../../"
alias ....="cd ../../../"
alias cls='clear'
alias tf=terraform
alias tfp="tf plan"
alias tfa="tf apply"
alias h="cd ~/"
alias nf=neofetch

# Safety-enhanced commands
alias rm='rm -i'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gm='git commit -m'
alias gp='git push'
alias gb="git branch"
alias glog="git log --oneline --graph --decorate --all"

# System monitoring
alias df='df -h'
alias du='du -h'
alias psa='ps aux'

# Networking
alias ports='netstat -tulanp'

# Personal workspace
gwp() { cd ~/Personal/Golang 2>/dev/null || echo "⚠️ Golang workspace not found at ~/Personal/Golang"; }

# Docker
alias d="docker"
alias dc="docker compose"
alias dkx="docker exec -it"
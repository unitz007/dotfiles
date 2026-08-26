# Aliases
alias ls="ls"
alias la="ls -la"
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
# kd moved to functions.zsh: kubectl delete is destructive and now confirms before running
alias gpl="git pull"
alias g="git"
alias gco="git checkout"
alias gd="git diff" # missing counterpart to gs/ga/gm/gp/gb — diff is used constantly alongside status/add/commit
alias ..="cd ../"
alias ...="cd ../../"
alias ....="cd ../../../"
alias cls='clear'
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

# Networking (macOS-compatible; netstat -tulanp is Linux/net-tools only)
alias ports='lsof -iTCP -sTCP:LISTEN -nP'

# Personal workspace
gwp() { cd $GOWORK 2>/dev/null || echo "⚠️ Golang workspace not found at $GOWORK"; }

# Docker
alias d="docker"
alias dc="docker compose"
alias dkx="docker exec -it"

# New useful aliases for productivity
alias ll='ls -alF'
# la intentionally not redefined here: it was silently overriding the
# nu-aware "la" set above (line 4), so the nu -c 'ls -la' version never ran
alias l='ls -CF'
alias hh='history'
alias j='jobs'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Random fun aliases
alias starwars='telnet towel.blinkenlights.nl'
alias weather='curl wttr.in'
alias matrix='echo -e "\e[32m"; while :; do for i in {1..16}; do r="$(($RANDOM % 2))"; if [[ $(($RANDOM % 5)) == 1 ]]; then if [[ $(($RANDOM % 4)) == 1 ]]; then v+="\e[1m $r   "; else v+="\e[2m $r   "; fi; else v+="     "; fi; done; echo -e "$v"; v=""; done'

# Additional Git aliases
alias gl='git log --oneline'

# Additional Docker aliases
alias dps='docker ps'
alias dpa='docker ps -a'
alias di='docker images'
alias drm='docker rm'
alias drmi='docker rmi'

# Additional Kubernetes aliases
alias kgn='kubectl get nodes'
alias kdp='kubectl describe pod'
alias kdnp='kubectl describe node'
alias kl='kubectl logs' # missing despite 8 other kubectl shortcuts — logs is used as often as get/describe

# Additional safety aliases
alias cp='cp -i'
alias mv='mv -i'

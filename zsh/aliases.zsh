# Aliases
alias ls="nu -c ls"
alias la="nu -c 'ls -la'"
alias run="sdlc run"
alias tst="sdlc test"
alias build="sdlc build"
alias vim=nvim
alias vi=nvim
alias update="brew update && brew upgrade && brew cleanup"
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
alias ...="cd ../../"
alias ....="cd ../../../"
alias cls='clear'
alias tf=terraform
alias tfp="terraform plan"
alias tfa="tf apply"
alias gwp="cd ~/Personal/Golang" # Golang workspace
alias h="cd ~/"
alias nf=neofetch

# Safety-enhanced commands
alias rm='rm -i'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gm='git commit -m'
alias gp='git push'

# System monitoring
alias df='df -h'
alias du='du -h'
alias ps='ps aux'

# Networking
alias ports='netstat -tulanp'
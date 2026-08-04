# Amazon Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"
# Q pre block. Keep at the top of this file.
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.

# Variables & Assignments
eval "$(oh-my-posh init zsh --config ~/.oh-my-posh-theme.json)"

export KUBE_EDITOR="nvim"
export VISUAL=nvim

# Aliases
alias ls="nu -c ls"
alias la="nu -c 'ls -la'"
alias run="sdlc run"
alias tst="sdlc test"
alias build="sdlc build"
alias vim=nvim
alias vi=nvim
alias update="brew upgrade && brew upgrade"
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
alias gwp="cd ~/Personal/Golang" # Golang workspace
alias h="cd ~/"

# Improved Functions
commit() {
	if [[ -z "$1" ]]; then
		echo "Error: missing 'commit message'"
		echo "Usage: commit <commit message> [-p] [branch]"
		return 1
	else
		git add .
		git commit -m "$1"
    if [[ "$2" == "-p" ]]; then
      if [[ -z "$3" ]]; then
        git push origin "$(git rev-parse --abbrev-ref HEAD)"
      else
        git push origin "$3"    
      fi
    fi
	fi
}

# Enhanced yazi function with error handling
y() {
	if ! command -v yazi >/dev/null 2>&1; then
		echo "Error: yazi is not installed"
		return 1
	fi
	
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	
	rm -f -- "$tmp"
}

ustart() {
  echo "Spinning Up Ubuntu VM..."
  if ! command -v multipass >/dev/null 2>&1; then
		echo "Error: multipass is not installed"
		return 1
	fi
	
  multipass launch -n ubuntu --cpus 4 --disk 20G --memory 2G --cloud-init ~/cloud-init.yaml
  multipass shell ubuntu
}

uend() {
  echo "Tearing Down Ubuntu VM..."
  if ! command -v multipass >/dev/null 2>&1; then
		echo "Error: multipass is not installed"
		return 1
	fi
	
  multipass delete ubuntu
  multipass purge 
}

# New utility functions
backup() {
	if [[ -z "$1" ]]; then
		echo "Error: missing filename"
		echo "Usage: backup <filename>"
		return 1
	fi
	
	if [[ ! -f "$1" ]]; then
		echo "Error: '$1' is not a file"
		return 1
	fi
	
	cp "$1" "$1.backup.$(date +%Y%m%d%H%M%S)"
	echo "Backup created: $1.backup.$(date +%Y%m%d%H%M%S)"
}

# Enhanced navigation functions
mkcd() {
	if [[ -z "$1" ]]; then
		echo "Error: missing directory name"
		echo "Usage: mkcd <directory>"
		return 1
	fi
	
	mkdir -p "$1" && cd "$1"
}

# System information function
sysinfo() {
	echo "=== System Information ==="
	echo "OS: $(uname -s)"
	echo "Kernel: $(uname -r)"
	echo "Architecture: $(uname -m)"
	echo "Uptime: $(uptime)"
	echo "Load Average: $(uptime | awk -F'load averages:' '{print $2}')"
	echo "Memory Usage: $(free -h | grep Mem | awk '{print $3 "/" $2}')"
	echo "Disk Usage: $(df -h / | tail -1 | awk '{print $3 "/" $2}')"
}

# set language
export LANG=en_US.UTF-8

# neofetch moved to function for on-demand execution
alias nf=neofetch

# Q post block. Keep at the bottom of this file.
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Amazon Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"
# Improved Functions

# Commit function with optional push
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

# Start Ubuntu VM with multipass
ustart() {
  echo "Spinning Up Ubuntu VM..."
  if ! command -v multipass >/dev/null 2>&1; then
		echo "Error: multipass is not installed"
		return 1
	fi
	
  multipass launch -n ubuntu --cpus 4 --disk 20G --memory 2G --cloud-init $CLOUD_INIT_PATH
  multipass shell ubuntu
}

# End Ubuntu VM with multipass
uend() {
  echo "Tearing Down Ubuntu VM..."
  if ! command -v multipass >/dev/null 2>&1; then
		echo "Error: multipass is not installed"
		return 1
	fi
	
  multipass delete ubuntu
  multipass purge 
}

# Backup function
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

# Create directory and cd into it
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

# Fixed rmDir as a function instead of alias
rmDir() {
  if [[ -z "$1" ]]; then
    echo "Error: missing directory name"
    echo "Usage: rmDir <directory>"
    return 1
  fi
  # rm -rf has no built-in confirmation (unlike the rm -i/cp -i/mv -i aliases
  # elsewhere in this repo), so prompt before deleting recursively.
  read -q "REPLY?Delete directory '$1' and everything in it? [y/N] "
  echo
  if [[ "$REPLY" != [Yy] ]]; then
    echo "Aborted."
    return 1
  fi
  rm -rf "$1"
}

# kubectl delete is destructive and had no safety consideration as a plain
# alias; confirm before running, same spirit as the rm -i/cp -i/mv -i aliases.
kd() {
  if [[ -z "$1" ]]; then
    echo "Usage: kd <resource> [name] [flags...]"
    return 1
  fi
  echo "About to run: kubectl delete --wait $*"
  read -q "REPLY?Proceed? [y/N] "
  echo
  if [[ "$REPLY" != [Yy] ]]; then
    echo "Aborted."
    return 1
  fi
  kubectl delete --wait "$@"
}

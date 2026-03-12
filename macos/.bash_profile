# macOS .bash_profile
# Load the standard bashrc if it exists
if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
fi

# Homebrew environment (added by install.sh if needed)
if [ -f "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f "/usr/local/bin/brew" ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# Enable GNU coreutils prefixed with 'g' (e.g., gls, gsed)
export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
# Minimal .zshrc for Zsh with Zinit plugin manager

# Ensure Zinit is on the PATH
if [ -d "${HOME}/.zinit/bin" ]; then
    source "${HOME}/.zinit/bin/zinit.zsh"
else
    echo "Zinit not found. Please ensure it is installed."
fi

# Example plugin: fast-syntax-highlighting
zinit light zdharma-continuum/fast-syntax-highlighting

# You can add more plugins or custom configuration below
# ...

# End of .zshrc
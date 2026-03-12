# macOS .zshrc – minimal tweaks
# Load the generic .zshrc if present in the repo root
if [ -f "$HOME/.zshrc_generic" ]; then
    source "$HOME/.zshrc_generic"
fi

# Ensure Homebrew is in the PATH
if command -v brew >/dev/null 2>&1; then
    eval "$(brew shellenv)"
fi

# Prefer GNU utilities installed via Homebrew coreutils
export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"

# Enable fish as an alternative shell (optional)
# Uncomment the following line to set fish as default for new terminals
# if command -v fish >/dev/null 2>&1; then
#     exec fish
# fi
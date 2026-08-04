# Main .zshrc file that sources all modular components

# Source plugin initializations (keep at top)
source ~/.oh-my-posh-theme.json
source ~/zsh/plugins.zsh

# Source all modular files in appropriate order
source ~/zsh/exports.zsh
source ~/zsh/aliases.zsh
source ~/zsh/functions.zsh
source ~/zsh/path.zsh
source ~/zsh/options.zsh
source ~/zsh/keybindings.zsh

# Additional configurations can be added here as needed
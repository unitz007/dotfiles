# This is the main zsh configuration file.
# It sources modular configuration files from this repo (aliases.zsh, functions.zsh, etc).

# Source plugin initializations (keep at top)
# Initialize zsh plugins and theme settings
source $OH_MY_POSH_THEME
source ~/zsh/plugins.zsh

# Source all modular files in appropriate order
source ~/zsh/exports.zsh
source ~/zsh/aliases.zsh
source ~/zsh/functions.zsh
source ~/zsh/path.zsh
source ~/zsh/options.zsh
source ~/zsh/keybindings.zsh

# Additional configurations can be added here as needed
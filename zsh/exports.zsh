# Environment variable exports
export KUBE_EDITOR="nvim"
export VISUAL=nvim
export LANG=en_US.UTF-8

# New environment variables with defaults
: ${GOWORKSPACE:=$HOME/Personal/Golang}
export GOWORKSPACE

: ${CLOUD_INIT_PATH:=$HOME/cloud-init.yaml}
export CLOUD_INIT_PATH

: ${OH_MY_POSH_THEME:=$HOME/.oh-my-posh-theme.json}
export OH_MY_POSH_THEME

: ${DOTFILES_REPO:=https://github.com/unitz007/dotfiles.git}
export DOTFILES_REPO

: ${SCREENSHOT_DIR:=$HOME/Screenshots}
export SCREENSHOT_DIR
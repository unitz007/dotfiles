# Dotfiles Brewfile — declarative dependency management
# Install all dependencies:  brew bundle --file=Brewfile
# Check installation status: brew bundle check --file=Brewfile

# Taps — third-party repositories required by formulae/casks below
tap "koekeishiya/formulae" # required for skhd (referenced by .skhdrc)

# Brews — CLI formulae referenced across the dotfiles
brew "zsh" # .zshrc, dotfile-config.yaml, cloud-init.yaml
brew "bash" # dotfile-config.yaml
brew "git" # .zshrc aliases, dotfile-config.yaml
brew "neovim" # .zshrc (VISUAL, KUBE_EDITOR), nvim/ directory, dotfile-config.yaml, cloud-init.yaml
brew "vim" # dotfile-config.yaml
brew "tmux" # tmux/tmux.conf, dotfile-config.yaml
brew "oh-my-posh" # .zshrc line 9, .oh-my-posh-theme.json, cloud-init.yaml
brew "yazi" # .zshrc lines 61-68 (yazi wrapper function), yazi.toml
brew "skhd" # .skhdrc (hotkey daemon config)
brew "nushell" # .zshrc lines 15-16 (nu -c ls aliases), cloud-init.yaml
brew "kubectl" # .zshrc lines 23-29 (k8s aliases), .oh-my-posh-theme.json line 120 (kubectl segment)
brew "terraform" # .zshrc lines 34-36 (tf aliases)
brew "neofetch" # .zshrc line 101
brew "starship" # dotfile-config.yaml line 113
brew "stow" # cloud-init.yaml line 14
brew "direnv" # .zshrc line 12 (direnv hook), .direnvrc, direnv.toml
brew "ripgrep" # required by nvim Telescope plugin (AstroNvim dependency)
brew "fd" # required by nvim Telescope plugin (AstroNvim dependency)
brew "node" # required by some nvim plugins (AstroNvim ecosystem)
brew "gcc" # required for treesitter C parser compilation in nvim
brew "zoxide" # .zshrc (zoxide init zsh), zoxide config file
brew "bat" # bat/config, .zshrc (BAT_THEME), fzf preview integration

# Casks — GUI applications referenced across the dotfiles
cask "aerospace" # .aerospace.toml (tiling window manager config)
cask "zed" # zed/settings.json, .skhdrc line 4
cask "ghostty" # .skhdrc line 7, .aerospace.toml line 173 (window rule)
cask "goland" # .skhdrc line 2, .aerospace.toml line 168 (window rule)
cask "fleet" # .skhdrc line 3
cask "postman" # .skhdrc line 9
cask "whatsapp" # .skhdrc line 10, .aerospace.toml line 181 (window rule)
cask "microsoft-teams" # .skhdrc line 13
cask "google-chrome" # .skhdrc line 14, .aerospace.toml line 189 (window rule)
cask "pycharm-ce" # .skhdrc line 17
cask "alacritty" # dotfile-config.yaml line 100
cask "kitty" # kitty/kitty.conf, dotfile-config.yaml line 108
cask "multipass" # .zshrc lines 85-95 (ustart/uend functions)

# Keyboard customization
cask "karabiner-elements" # karabiner/karabiner.json (Caps Lock → Hyper key, Vim-style navigation)

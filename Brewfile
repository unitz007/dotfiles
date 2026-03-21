# Dotfiles Brewfile — declarative dependency management
# Install all dependencies:  brew bundle --file=Brewfile
# Check installation status: brew bundle check --file=Brewfile

# Taps — third-party repositories required by formulae/casks below
tap "homebrew/cask-fonts" # required for font-jetbrains-mono-nerd-font cask
tap "koekeishiya/formulae" # required for skhd (available in homebrew/core on newer versions, retained for compatibility)

# Brews — CLI formulae referenced across the dotfiles
brew "git"
brew "zsh" # default shell; configured in .zshrc
brew "oh-my-posh" # shell prompt engine; theme in .oh-my-posh-theme.json
brew "neovim" # terminal editor; configured in nvim/
brew "tmux" # terminal multiplexer; configured in tmux/tmux.conf
brew "ripgrep" # fast search; required by nvim Telescope plugin
brew "fd" # fast find; required by nvim Telescope plugin
brew "fzf" # fuzzy finder; configured in fzf/.fzf.zsh
brew "zoxide" # smarter cd; configured in .zshrc (z command)
brew "bat" # syntax-highlighted cat; configured in bat/config
brew "eza" # modern ls replacement; aliased in .zshrc
brew "atuin" # shell history; configured in .zshrc
brew "lazygit" # terminal Git UI
brew "git-delta" # syntax-highlighted git diffs; configured in delta/config
brew "direnv" # auto-loading env vars; configured in .direnvrc, direnv.toml
brew "yazi" # terminal file manager; configured in yazi.toml
# NOTE: yazi is a Homebrew formula (not a cask) despite some criteria listing it as a cask.
#       Using `cask "yazi"` would cause `brew bundle check` to fail.
brew "skhd" # hotkey daemon; configured in .skhdrc
brew "kubectl" # Kubernetes CLI; aliased in .zshrc (k, kgs, kgp, kgd, ka, kd), shown in .oh-my-posh-theme.json
brew "terraform" # infrastructure-as-code CLI; aliased in .zshrc (tf, tfp, tfa)
brew "nushell" # modern shell; installed in cloud-init.yaml VM provisioning
brew "stow" # GNU Stow for managing symlinks; referenced in cloud-init.yaml
brew "node" # Node.js runtime; required by some nvim LSP servers and tools
brew "gcc" # C compiler; required for building native nvim modules (e.g., treesitter parsers)

# Casks — GUI applications referenced across the dotfiles
cask "kitty" # terminal emulator; configured in kitty/kitty.conf
cask "aerospace" # tiling window manager; configured in .aerospace.toml
cask "karabiner-elements" # keyboard remapper; configured in karabiner/karabiner.json
cask "font-jetbrains-mono-nerd-font" # Nerd Font; required by Oh-My-Posh and AstroNvim icons
cask "ghostty" # terminal emulator; referenced in .skhdrc (ctrl-t) and .aerospace.toml (workspace assignment)
cask "zed" # code editor; configured in zed/settings.json, referenced in .skhdrc (ctrl-z)
cask "goland" # JetBrains Go IDE; referenced in .skhdrc (ctrl-g) and .aerospace.toml (workspace assignment)
cask "fleet" # JetBrains Fleet IDE; referenced in .skhdrc (ctrl-v)
cask "google-chrome" # web browser; referenced in .skhdrc (ctrl-h) and .aerospace.toml (workspace assignment)
cask "whatsapp" # messaging app; referenced in .skhdrc (ctrl-w) and .aerospace.toml (workspace assignment)
cask "multipass" # Ubuntu VM manager; used by ustart/uend functions in .zshrc

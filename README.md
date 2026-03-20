# dotfiles

Personal macOS dotfiles for reproducible development environment setup.

## Configured Tools

| Tool | Config File | Description |
|------|------------|-------------|
| **AeroSpace** | `.aerospace.toml` | i3-like tiling window manager for macOS (qwerty keymap, alt-based bindings, workspaces: CODING / BROWSER / MESSAGING / UTILITY) |
| **skhd** | `.skhdrc` | macOS hotkey daemon — `ctrl+letter` shortcuts to launch apps (Goland, Zed, Safari, Ghostty, Chrome, etc.) |
| **Zsh + Oh My Posh** | `.zshrc`, `.oh-my-posh-theme.json` | Shell configuration with a custom powerline prompt theme, kubectl/terraform/git aliases, yazi wrapper function, and multipass VM helpers |
| **Neovim** | `nvim/` | AstroNvim v4+ template with LSP (mason), treesitter, null-ls, and custom keymaps |
| **Tmux** | `tmux/tmux.conf` | Terminal multiplexer with TPM plugin manager, catppuccin theme, and `Ctrl+Space` prefix |
| **Yazi** | `yazi.toml` | Terminal file manager configured to show hidden files by default |
| **Zed** | `zed/settings.json` | Code editor with 16pt font and Atelier Cave Dark theme |

## Prerequisites

The following tools must be installed before deploying these dotfiles:

- **macOS** (Sonoma or later — required for AeroSpace)
- **Homebrew** — package manager (`brew install` commands in `dotfile-config.yaml`)
- **Oh My Posh** — prompt engine (installed via `curl -s https://ohmyposh.dev/install.sh | bash -s`; referenced in `.zshrc` line 9)
- **TPM (Tmux Plugin Manager)** — `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm` (referenced in `tmux/tmux.conf` line 10)
- **Nushell** — used by `ls`/`la` aliases in `.zshrc` lines 15–16 (`nu -c ls`)
- **Neofetch** — runs on shell startup (`.zshrc` line 101)
- **Git** — version control (referenced throughout `.zshrc` aliases and `dotfile-config.yaml`)

## Deployment

1. Clone the repo:

   ```sh
   git clone https://github.com/unitz007/dotfiles.git ~/dotfiles
   ```

2. Install prerequisites (Homebrew formulae listed above).

3. Use `dotfile-config.yaml` as the manifest. It defines software entries with `install` commands per platform and `files` entries mapping repo paths to `$HOME` targets (directories end with `;`).

4. Create symlinks for each config file:

   ```sh
   ln -sf ~/dotfiles/.aerospace.toml ~/.aerospace.toml
   ln -sf ~/dotfiles/.skhdrc ~/.skhdrc
   ln -sf ~/dotfiles/.zshrc ~/.zshrc
   ln -sf ~/dotfiles/.oh-my-posh-theme.json ~/.oh-my-posh-theme.json
   ln -sf ~/dotfiles/nvim ~/.config/nvim
   ln -sf ~/dotfiles/tmux/tmux.conf ~/.tmux.conf
   ln -sf ~/dotfiles/yazi.toml ~/.config/yazi.toml
   ln -sf ~/dotfiles/zed/settings.json ~/.config/zed/settings.json
   ```

5. Install tmux plugins: open tmux and press `prefix + I` (`Ctrl+Space` then `I`).

## Manual Post-Deploy Steps

- **AeroSpace permissions**: System Settings → Privacy & Security → grant **Accessibility** and **Screen Recording** permissions to AeroSpace
- **skhd permissions**: System Settings → Privacy & Security → grant **Accessibility** permission to skhd; also enable the skhd launch agent via `brew services start skhd`
- **Neovim plugins**: Open `nvim` once — Lazy.nvim will auto-install all plugins (mason LSP servers, treesitter parsers, etc.)
- **Tmux plugins**: Open `tmux`, press `Ctrl+Space` then `I` to install TPM plugins
- **Shell**: Restart terminal or run `exec zsh` to load the new `.zshrc`

## Optional / Referenced Tools

The following tools are referenced in `.zshrc` aliases but not shipped as config files in this repo:

- **kubectl** — Kubernetes CLI (aliased as `k`)
- **Terraform** — Infrastructure as Code (aliased as `tf`)
- **Multipass** — Ubuntu VM helper functions `ustart`/`uend` using `cloud-init.yaml`
- **Amazon Q** — Shell integration blocks in `.zshrc`
- **iTerm2** — Shell integration sourced in `.zshrc`

## Cloud VM Provisioning

`cloud-init.yaml` can be used with Multipass to spin up an Ubuntu VM with zsh, neovim, nushell, and oh-my-posh pre-installed (as shown by the `ustart()` function in `.zshrc`).

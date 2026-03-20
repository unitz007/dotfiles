# Dotfiles

Personal macOS dotfiles repository managing shell, window manager, editor, terminal multiplexer, file manager, and editor configurations. Designed for macOS (Apple Silicon / Intel) and includes a cloud-init file for spinning up a matching Ubuntu VM via Multipass.

## Table of Contents

- [Managed Tools](#managed-tools)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration Details](#configuration-details)
- [Deployment Manifest](#deployment-manifest)
- [Notes](#notes)
- [License](#license)

## Managed Tools

| Tool | Description | Link |
|------|-------------|------|
| **AeroSpace** | Tiling window manager for macOS | <https://nikitabobko.github.io/AeroSpace/> |
| **skhd** | macOS hotkey daemon | <https://github.com/koekeishiya/skhd> |
| **Zsh** | Shell | <https://www.zsh.org/> |
| **Oh My Posh** | Cross-shell prompt theme engine | <https://ohmyposh.dev/> |
| **Neovim** (AstroNvim v4) | Code editor | <https://neovim.io/>, <https://astronvim.com/> |
| **Tmux** | Terminal multiplexer | <https://github.com/tmux/tmux> |
| **Yazi** | Terminal file manager | <https://yazi-rs.github.io/> |
| **Zed** | Code editor | <https://zed.dev/> |
| **Multipass** (cloud-init) | Local Ubuntu VM | <https://multipass.run/> |

## Prerequisites

The primary target is **macOS** — AeroSpace and skhd are macOS-only.

Install the following tools before deploying the dotfiles:

- [Homebrew](https://brew.sh/) — package manager
- [Zsh](https://www.zsh.org/) — shell (usually pre-installed on macOS)
- [Oh My Posh](https://ohmyposh.dev/) — `brew install jandedobbeleer/oh-my-posh/oh-my-posh`
- [Neovim](https://neovim.io/) 0.9+ — `brew install neovim`
- [Tmux](https://github.com/tmux/tmux) — `brew install tmux`
- [Tmux Plugin Manager (TPM)](https://github.com/tmux-plugins/tpm) — cloned to `~/.tmux/plugins/tpm`
- [Yazi](https://yazi-rs.github.io/) — `brew install yazi`
- [Zed](https://zed.dev/) — `brew install --cask zed`
- [AeroSpace](https://nikitabobko.github.io/AeroSpace/) — `brew install --cask nikitabobko/tap/aerospace`
- [skhd](https://github.com/koekeishiya/skhd) — `brew install koekeishiya/formulae/skhd`
- [Nushell](https://www.nushell.sh/) — used by `ls`/`la` aliases in `.zshrc`
- [Neofetch](https://github.com/dylanaraps/neofetch) — called at shell startup in `.zshrc`
- A **Nerd Font** (e.g., [JetBrains Mono Nerd Font](https://www.nerdfonts.com/font-downloads)) — required for icons in Oh My Posh and AstroNvim

Optional tools referenced in aliases/functions: `kubectl`, `terraform`, `multipass`, `git`.

## Installation

1. Clone the repo:

   ```sh
   git clone https://github.com/unitz007/dotfiles.git ~/dotfiles && cd ~/dotfiles
   ```

2. Install all prerequisites via Homebrew:

   ```sh
   brew install neovim tmux yazi jandedobbeleer/oh-my-posh/oh-my-posh nushell neofetch koekeishiya/formulae/skhd && brew install --cask zed nikitabobko/tap/aerospace
   ```

3. Install a Nerd Font and configure your terminal emulator to use it.

4. Install TPM:

   ```sh
   git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
   ```

5. Create symlinks for each config file (see [`dotfile-config.yaml`](dotfile-config.yaml) for the canonical deployment manifest):

   ```sh
   ln -sf ~/dotfiles/.zshrc ~/.zshrc
   ln -sf ~/dotfiles/.oh-my-posh-theme.json ~/.oh-my-posh-theme.json
   ln -sf ~/dotfiles/.aerospace.toml ~/.aerospace.toml
   ln -sf ~/dotfiles/.skhdrc ~/.skhdrc
   ln -sf ~/dotfiles/nvim ~/.config/nvim
   ln -sf ~/dotfiles/tmux/tmux.conf ~/.tmux.conf
   ln -sf ~/dotfiles/yazi.toml ~/.config/yazi.toml
   ln -sf ~/dotfiles/zed/settings.json ~/.config/zed/settings.json
   ln -sf ~/dotfiles/cloud-init.yaml ~/cloud-init.yaml
   ```

6. Restart the shell (`exec zsh`) or open a new terminal window.

7. In tmux, press `prefix + I` (Ctrl+Space then I) to install tmux plugins.

8. Open Neovim once to trigger Lazy.nvim plugin installation.

9. (Optional) Start AeroSpace and skhd — note that skhd requires Input Monitoring permission in macOS System Settings → Privacy & Security.

## Configuration Details

### Shell (Zsh + Oh My Posh)

Files: [`.zshrc`](.zshrc), [`.oh-my-posh-theme.json`](.oh-my-posh-theme.json)

Oh My Posh is initialized with a custom powerline theme showing OS icon, shell, path, and git status on the left; Java, Go, Rust versions and kubectl context on the right. The theme uses color-coded git status backgrounds (yellow for dirty/staged changes, orange for ahead and behind, purple for ahead only, purple for behind only) and a green `❯` prompt that turns red on command failure.

Key aliases and functions:

- `vim` / `vi` → `nvim`
- `k` → `kubectl` (plus `kgs`, `kgp`, `kgd`, `ka`, `kd` for common operations)
- `tf` → `terraform` (plus `tfp` for plan, `tfa` for apply)
- `g` → `git` (plus `gc` for checkout, `pull` for pull)
- `ls` / `la` — powered by Nushell (`nu -c ls`)
- `commit <message> [-p [branch]]` — stages all changes, commits, and optionally pushes
- `y()` — wrapper for Yazi that changes directory to the last browsed path on exit
- `ustart()` / `uend()` — Multipass Ubuntu VM lifecycle (launch with cloud-init / delete and purge)

Note: Amazon Q shell integration blocks are at the top and bottom of `.zshrc`. iTerm2 shell integration is conditionally sourced near the bottom.

### Window Manager (AeroSpace + skhd)

Files: [`.aerospace.toml`](.aerospace.toml), [`.skhdrc`](.skhdrc)

**AeroSpace** starts at login with a QWERTY key layout. Navigation uses vim-style bindings: `alt+h/j/k/l` to focus and `alt+shift+h/j/k/l` to move windows. Four named workspaces are configured with `alt+c` (CODING), `alt+b` (BROWSER), `alt+m` (MESSAGING), and `alt+t` (UTILITY). Apps are automatically assigned to workspaces on open: GoLand and Ghostty → CODING, Safari and Chrome → BROWSER, WhatsApp → MESSAGING, Finder → UTILITY (also set to floating layout). Service mode (`alt+shift+;`) provides reload (`esc`), reset layout (`r`), toggle floating (`f`), and close all but current (`backspace`).

**skhd** provides `ctrl+letter` global hotkeys to launch apps:

| Shortcut | App |
|----------|-----|
| `ctrl+g` | Goland |
| `ctrl+v` | Fleet |
| `ctrl+z` | Zed |
| `ctrl+t` | Ghostty |
| `ctrl+b` | Safari |
| `ctrl+h` | Chrome |
| `ctrl+f` | Finder |
| `ctrl+w` | WhatsApp |
| `ctrl+m` | Mail |
| `ctrl+p` | Postman |
| `ctrl+i` | Teams |
| `ctrl+n` | Notes |
| `ctrl+d` | Dictionary |
| `ctrl+a` | Preview |
| `ctrl+y` | PyCharm |
| `ctrl+s` | Settings |

### Editor (Neovim / AstroNvim)

Files: [`nvim/`](nvim/) directory (specifically [`nvim/init.lua`](nvim/init.lua), [`nvim/lua/lazy_setup.lua`](nvim/lua/lazy_setup.lua), [`nvim/lua/community.lua`](nvim/lua/community.lua), [`nvim/lua/plugins/`](nvim/lua/plugins/))

AstroNvim v4 distribution with Lazy.nvim plugin manager. Leader key is `Space`, local leader is `,`. Community plugins add Palenight and Catppuccin colorschemes, with Catppuccin set as the active theme in [`astroui.lua`](nvim/lua/plugins/astroui.lua). The plugin directory includes configs for AstroCore, AstroLSP, AstroUI, Mason (LSP installer), Treesitter, and none-ls. The [`polish.lua`](nvim/lua/polish.lua) and [`plugins/user.lua`](nvim/lua/plugins/user.lua) files are placeholder templates (disabled with `if true then return end` / `if true then return {} end`) containing example customizations including presence.nvim, lsp_signature, an alpha-nvim dashboard, and nvim-autopairs rules.

### Terminal Multiplexer (Tmux)

Files: [`tmux/tmux.conf`](tmux/tmux.conf)

True color is enabled, the prefix is remapped to `Ctrl+Space`, and TPM is used with the catppuccin theme plugin alongside tmux-sensible.

### File Manager (Yazi)

Files: [`yazi.toml`](yazi.toml)

Minimal config enabling hidden file display (`show_hidden = true`). The `y()` shell function in `.zshrc` wraps Yazi and changes the working directory to the last browsed location on exit.

### Editor — Zed

Files: [`zed/settings.json`](zed/settings.json)

Sets UI and buffer font size to 16, uses the "Atelier Cave Dark" theme in dark mode.

### Cloud VM (Multipass / cloud-init)

Files: [`cloud-init.yaml`](cloud-init.yaml)

Cloud-init config for spinning up an Ubuntu VM via Multipass (using the `ustart()` function in `.zshrc`). Installs zsh, unzip, stow, neovim, nushell, and Oh My Posh, then clones this dotfiles repo and copies `.zshrc` and `.oh-my-posh-theme.json` into the VM home directory, appending `exec zsh` to `.bashrc` to switch the default shell.

## Deployment Manifest

[`dotfile-config.yaml`](dotfile-config.yaml) is a structured deployment manifest listing each tool, its platform-specific install commands, and the files to symlink. It serves as the machine-readable source of truth for which files go where. Note that it covers additional tools (bash, git, vim, alacritty, kitty, starship) whose config files are not yet present in the repo.

## Notes

- **macOS-specific**: AeroSpace and skhd require macOS. skhd needs Input Monitoring permission (System Settings → Privacy & Security → Input Monitoring). AeroSpace needs Accessibility permission.
- The `.zshrc` references Amazon Q CLI integration — remove those blocks if not using Amazon Q.
- iTerm2 shell integration is conditionally sourced — harmless if not using iTerm2.
- The `nvim/lua/polish.lua` and `nvim/lua/plugins/user.lua` files are disabled by default (guard `if true then return end`); remove the guard line to activate customizations.

## License

MIT — feel free to fork and adapt.

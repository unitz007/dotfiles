# Dotfiles

Personal macOS dotfiles for Neovim, Tmux, Zsh, AeroSpace, skhd, Yazi, and Zed.

## Prerequisites

- macOS
- Internet connection

## Setup

```sh
git clone https://github.com/unitz007/dotfiles.git
cd dotfiles
./bootstrap.sh
```

## Dry-run

To preview every action the script would take without making any changes, use the `--dry-run` flag:

```sh
./bootstrap.sh --dry-run
```

## What gets installed

**Homebrew packages:**

- `stow`
- `oh-my-posh`
- `tmux`
- `neovim`

**TPM (Tmux Plugin Manager):** cloned to `~/.tmux/plugins/tpm`

**Symlinked dotfiles:**

| Source | Target |
|--------|--------|
| `.zshrc` | `~/.zshrc` |
| `.oh-my-posh-theme.json` | `~/.oh-my-posh-theme.json` |
| `.skhdrc` | `~/.skhdrc` |
| `.aerospace.toml` | `~/.aerospace.toml` |
| `nvim/` | `~/.config/nvim` |
| `tmux/tmux.conf` | `~/.tmux.conf` |
| `yazi.toml` | `~/.config/yazi/yazi.toml` |
| `zed/settings.json` | `~/.config/zed/settings.json` |

The bootstrap script is safe to re-run — it skips already-installed packages and existing symlinks.

## Included tools

- **Neovim** — AstroNvim v4 with lazy.nvim plugin manager
- **Tmux** — TPM plugin manager with catppuccin theme
- **Zsh** — oh-my-posh powerline prompt
- **AeroSpace** — i3-like tiling window manager for macOS
- **skhd** — macOS hotkey daemon for global keyboard shortcuts
- **Yazi** — Rust-based terminal file manager
- **Zed** — Code editor with Atelier Cave Dark theme
# macOS Dotfiles

Personal configuration files for a macOS development environment, covering terminal, editor, window manager, shell prompt, and more.

## Table of Contents

- [GPG Commit Signing](#gpg-commit-signing)
- [Configured Tools](#configured-tools)
- [Setup](#setup)
- [Manual Post-Install Steps](#manual-post-install-steps)

## GPG Commit Signing

Git commits are cryptographically signed with GPG to verify author identity on platforms like GitHub. The GPG configuration files live in [`gpg/`](gpg/) and are symlinked to `~/.gnupg/` by `bootstrap.sh`.

### Prerequisites

Install GnuPG and a pinentry program:

```sh
# macOS
brew install gnupg pinentry-mac

# Linux (Debian/Ubuntu)
sudo apt install gnupg pinentry-curses
```

### Generate a new GPG key

```sh
# RSA 4096 (recommended for broad compatibility)
gpg --full-generate-key

# Or Ed25519 (modern, shorter keys — requires --expert)
gpg --expert --full-generate-key
```

When prompted, use the **same email address** as your git config (`user.email`).

### List keys and get the ID

```sh
gpg --list-secret-keys --keyid-format=long
```

Look for the line `sec   rsa4096/<KEY_ID>` — the `<KEY_ID>` is the 16-character hex string after the slash.

### Export the public key

```sh
gpg --armor --export <KEY_ID> > public.key
```

### Add to GitHub

Using the GitHub CLI:

```sh
gh auth login
gh gpg-key add public.key
```

Or manually: go to **GitHub Settings → SSH and GPG keys → New GPG key** and paste the contents of `public.key`.

### Configure git to use the key

```sh
git config --global user.signingkey <KEY_ID>
git config --global commit.gpgsign true
```

> **Note:** `commit.gpgsign` is already set to `true` in [`.gitconfig`](.gitconfig). You only need to set `user.signingkey`.

### Import on a new machine

Export your private key from the original machine:

```sh
gpg --armor --export-secret-keys <KEY_ID> > private.key
```

Transfer `private.key` to the new machine **securely** (e.g., USB drive, encrypted channel — never over plain text), then import and clean up:

```sh
gpg --import private.key
gpg --edit-key <KEY_ID> trust quit   # Choose "5" (I trust ultimately)
shred -u private.key                  # or: rm -P private.key (macOS)
```

### Verify it works

```sh
git commit -S -m "Test signed commit"
git log --show-signature
```

You should see `Good signature from ...` in the output. On GitHub, signed commits display a **Verified** badge.

## Configured Tools

| Tool | Description | Config File |
|------|-------------|-------------|
| **GPG** | GnuPG configuration for git commit signing (algorithm preferences, keyserver, agent) | `gpg/gpg.conf`, `gpg/gpg-agent.conf` |
| **Neovim** | AstroNvim v4+ distribution with LSP, Treesitter, and Mason plugin management | `nvim/` |
| **Tmux** | Terminal multiplexer with TPM, catppuccin theme, and `Ctrl+Space` prefix | `tmux/tmux.conf` |
| **AeroSpace** | Tiling window manager with vim-like navigation and per-app workspace assignment | `.aerospace.toml` |
| **skhd** | Global hotkey daemon for launching apps via `ctrl+key` shortcuts | `.skhdrc` |
| **Oh-My-Posh** | Custom shell prompt theme showing git status, kubectl context, and language versions | `.oh-my-posh-theme.json` |
| **Yazi** | Terminal file manager configured to show hidden files | `yazi.toml` |
| **Zed** | Code editor with Atelier Cave Dark theme | `zed/settings.json` |
| **Zsh** | Shell configuration with aliases for git, kubectl, terraform, and a Yazi cwd-wrapper function | `.zshrc` |
| **Git** | Global git config with aliases, GPG commit signing, default branch, and macOS credential helper | `.gitconfig` |
| **Karabiner-Elements** | Keyboard remapper — Caps Lock as Hyper key (⌃⌥⌘⇧) + Escape, Vim-style arrow keys | `karabiner/karabiner.json` |
| **direnv** | Auto-loading project-specific environment variables on directory change | `.direnvrc`, `direnv.toml` |
| **Zoxide** | Smarter `cd` that learns from navigation habits; integrates with fzf for interactive directory selection | `zoxide` |
| **Bat** | Syntax-highlighted `cat` replacement with git integration and line numbers | `bat/config` |
| **fzf** | General-purpose fuzzy finder for files, directories, and command history | `fzf/.fzf.zsh` |

## Setup

Run the following commands in order from the repository root:

### Phase 1 — Install dependencies via Homebrew

```sh
brew bundle --file=Brewfile
```

### Phase 2 — Create symlinks

```sh
bash bootstrap.sh
```

Existing files are backed up with a `.bak` suffix. Use `bash bootstrap.sh --dry-run` to preview changes.

### Phase 3 — Apply macOS system defaults

```sh
bash macos-defaults.sh
```

Some changes require logging out and back in to take full effect.

### Phase 4 — Post-symlink initialization

```sh
nvim   # triggers Lazy.nvim bootstrap and plugin install on first launch
```

## Manual Post-Install Steps

- **Set Git user name, email, and signing key:**
  ```sh
  git config --global user.name "Your Name"
  git config --global user.email "you@example.com"
  git config --global user.signingkey <YOUR_GPG_KEY_ID>
  ```
- **Grant Accessibility permissions to AeroSpace:** System Settings → Privacy & Security → Accessibility → add AeroSpace
- **Grant Accessibility permissions to skhd:** System Settings → Privacy & Security → Accessibility → add skhd
- **Grant Input Monitoring permissions to Karabiner-Elements:** System Settings → Privacy & Security → Input Monitoring → add Karabiner-Elements
- **Install a Nerd Font** (e.g., JetBrains Mono Nerd Font) and set it as the terminal font
- **Start AeroSpace and skhd services:** AeroSpace has `start-at-login = true` in `.aerospace.toml`, but skhd may need `brew services start skhd`

# macOS Dotfiles

Personal configuration files for a macOS development environment, covering terminal, editor, window manager, shell prompt, and more.

## Configured Tools

| Tool | Description | Config File |
|------|-------------|-------------|
| **Neovim** | AstroNvim v4+ distribution with LSP, Treesitter, and Mason plugin management | `nvim/` |
| **Tmux** | Terminal multiplexer with TPM, catppuccin theme, and `Ctrl+Space` prefix | `tmux/tmux.conf` |
| **AeroSpace** | Tiling window manager with vim-like navigation and per-app workspace assignment | `.aerospace.toml` |
| **skhd** | Global hotkey daemon for launching apps via `ctrl+key` shortcuts | `.skhdrc` |
| **Oh-My-Posh** | Custom shell prompt theme showing git status, kubectl context, and language versions | `.oh-my-posh-theme.json` |
| **Yazi** | Terminal file manager configured to show hidden files | `yazi.toml` |
| **Zed** | Code editor with Atelier Cave Dark theme | `zed/settings.json` |
| **Zsh** | Shell configuration with aliases for git, kubectl, terraform, and a Yazi cwd-wrapper function | `.zshrc` |
| **Git** | Global git config with aliases, GPG commit signing, default branch, and macOS credential helper | `.gitconfig` |
| **direnv** | Auto-loading project-specific environment variables on directory change | `.direnvrc`, `direnv.toml` |

## Prerequisites

- **macOS Sonoma or later** (required by AeroSpace)
- **Homebrew** installed:
  ```sh
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ```
- **Apple ID** signed in to App Store (required for apps referenced in `.skhdrc` such as WhatsApp, Microsoft Teams, PyCharm Community Edition)
- **A Nerd Font** installed in the terminal (required by Oh-My-Posh icons and AstroNvim icon support — see `icons_enabled = true` in `nvim/lua/lazy_setup.lua`)

## Setup

Run the following commands in order from the repository root:

### Phase 1 — Install dependencies via Homebrew

```sh
brew bundle --file=Brewfile
```

This installs all CLI tools (neovim, tmux, oh-my-posh, yazi, etc.) and GUI applications (AeroSpace, Ghostty, Zed, GoLand, etc.) declared in the Brewfile.

> **Note:** WhatsApp and Microsoft Teams require manual installation from the App Store (Homebrew casks are not available for these).

### Phase 2 — Create symlinks

```sh
bash bootstrap.sh
```

This symlinks all dotfiles to their target locations under `$HOME`. Existing files are backed up with a `.bak` suffix. Use `bash bootstrap.sh --dry-run` to preview changes without making them.

### Phase 3 — Apply macOS system defaults

```sh
bash macos-defaults.sh
```

This configures macOS preferences (key repeat speed, Dock auto-hide, Finder settings, screenshot location, etc.). Some changes require logging out and back in to take full effect.

### Phase 4 — Post-symlink initialization

```sh
nvim   # triggers Lazy.nvim bootstrap and plugin install on first launch
```

### direnv

[direnv](https://direnv.net/) automatically loads project-specific environment variables when you `cd` into a directory.

- **Install:** `brew install direnv` (or via `brew bundle --file=Brewfile`)
- **Shell hook:** The `eval "$(direnv hook zsh)"` line in `.zshrc` activates direnv automatically in every new shell session
- **Usage:** Place an `.envrc` file in any project directory — it is auto-evaluated on `cd`. Run `direnv allow` the first time to trust it
- **Global layout helpers:** `~/.direnvrc` provides reusable functions (`use_node`, `use_python`, `use_flake`) that can be called from any `.envrc` via `source_up` or `source_env ~/.direnvrc`
- **Global settings:** `direnv.toml` enforces `strict_env = true` (explicit variable declarations required)

### Tmux Plugins

The tmux configuration uses [TPM](https://github.com/tmux-plugins/tpm) (Tmux Plugin Manager) with the following plugins:

| Plugin | Purpose |
|--------|---------|
| **tmux-sensible** | Sane default options |
| **catppuccin_tmux** | Catppuccin color theme |
| **tmux-resurrect** | Save and restore tmux sessions |
| **tmux-continuum** | Automatic session saving and restoring |
| **tmux-yank** | System clipboard integration |

TPM is automatically cloned by `bootstrap.sh`. If you need to install it manually:

```sh
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

**One-time plugin install:** Open tmux and press `prefix + I` (i.e., `Ctrl-Space` then `I`) to install all plugins via TPM.

**Session persistence:**
- `prefix + Ctrl-s` — save the current tmux session
- `prefix + Ctrl-r` — restore a previously saved session
- Sessions auto-save every 15 minutes and auto-restore on tmux server start (via tmux-continuum)

## Manual Post-Install Steps

- **Set Git user name, email, and signing key:**
  ```sh
  git config --global user.name "Your Name"
  git config --global user.email "you@example.com"
  git config --global user.signingkey <YOUR_GPG_KEY_ID>
  ```
- **Grant Accessibility permissions to AeroSpace:** System Settings → Privacy & Security → Accessibility → add AeroSpace (required for window management)
- **Grant Accessibility permissions to skhd:** System Settings → Privacy & Security → Accessibility → add skhd (required for global hotkeys)
- **Install a Nerd Font** (e.g., JetBrains Mono Nerd Font) and set it as the terminal font in Ghostty/iTerm2 (required for Oh-My-Posh and AstroNvim icons to render)
- **Sign into App Store** and manually install WhatsApp, Microsoft Teams, and PyCharm Community Edition if desired (referenced in `.skhdrc` hotkeys)
- **Start AeroSpace and skhd services:** AeroSpace has `start-at-login = true` in `.aerospace.toml`, but skhd may need `brew services start skhd`

## Git Configuration

The `.gitconfig` file provides consistent git settings across all machines, including common aliases, GPG commit signing, and macOS credential storage.

> **Note:** `user.name`, `user.email`, and `user.signingkey` must be configured per-machine (see [Manual Post-Install Steps](#manual-post-install-steps)).

### Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `git co` | `checkout` | Switch branches |
| `git br` | `branch` | List/create branches |
| `git ci` | `commit` | Create a commit |
| `git st` | `status` | Show working tree status |
| `git lg` | `log --oneline --graph --decorate --all` | Pretty log graph |
| `git unstage` | `reset HEAD --` | Unstage files |
| `git last` | `log -1 HEAD` | Show last commit |
| `git amend` | `commit --amend --no-edit` | Amend last commit |
| `git pushf` | `push --force-with-lease` | Safe force push |
| `git fetchp` | `fetch --prune` | Fetch and prune remote branches |
| `git rb` | `rebase` | Rebase |
| `git rs` | `rebase --skip` | Skip current rebase commit |

### Settings

| Setting | Value | Description |
|---------|-------|-------------|
| `init.defaultBranch` | `main` | Default branch name for new repos |
| `pull.rebase` | `true` | Always rebase on pull |
| `credential.helper` | `osxkeychain` | Store credentials in macOS Keychain |
| `commit.gpgsign` | `true` | Sign all commits with GPG |
| `gpg.program` | `gpg` | GPG program for signing |
| `core.excludesfile` | `~/.gitignore_global` | Global gitignore file |

## Other Configurations

- **Neovim** — AstroNvim v4 distribution with LSP, Treesitter, and Mason plugin management ([`nvim/`](nvim/))
- **Tmux** — Terminal multiplexer with TPM, catppuccin theme, and `Ctrl+Space` prefix ([`tmux/tmux.conf`](tmux/tmux.conf))
- **Zsh** — Shell configuration with aliases for git, kubectl, terraform, and a Yazi cwd-wrapper function ([`.zshrc`](.zshrc))
- **AeroSpace** — Tiling window manager with vim-like navigation and per-app workspace assignment ([`.aerospace.toml`](.aerospace.toml))
- **skhd** — Global hotkey daemon for launching apps via `ctrl+key` shortcuts ([`.skhdrc`](.skhdrc))
- **Oh-My-Posh** — Custom shell prompt theme showing git status, kubectl context, and language versions ([`.oh-my-posh-theme.json`](.oh-my-posh-theme.json))
- **Yazi** — Terminal file manager configured to show hidden files ([`yazi.toml`](yazi.toml))
- **Zed** — Code editor with Atelier Cave Dark theme ([`zed/settings.json`](zed/settings.json))

## VM Provisioning

The `cloud-init.yaml` file provisions an Ubuntu VM via [Multipass](https://multipass.run/) with zsh, neovim, nushell, and oh-my-posh pre-installed. Use the `ustart` and `uend` functions defined in [`.zshrc`](.zshrc) to launch and stop the VM.

## Troubleshooting / FAQ

**"Oh-My-Posh icons appear as broken boxes or question marks"**
- **Cause:** No Nerd Font configured in the terminal.
- **Fix:** Install a Nerd Font (e.g., `brew install --cask font-jetbrains-mono-nerd-font`) and set it as the terminal's font.

**"AeroSpace/skhd hotkeys don't work"**
- **Cause:** Missing Accessibility permissions.
- **Fix:** System Settings → Privacy & Security → Accessibility → add the app, then restart it.

**"Tmux plugins not loading"**
- **Cause:** TPM (Tmux Plugin Manager) not installed.
- **Fix:** Run `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`, then open tmux and press `prefix + I` (i.e., `Ctrl+Space` then `I`).

**"Neovim shows errors on first launch"**
- **Cause:** Lazy.nvim and plugins need to download.
- **Fix:** Open `nvim`, wait for the installation to complete, then restart.

## Acknowledgments / References

- [AstroNvim](https://astronvim.com/) — Neovim distribution framework
- [AeroSpace](https://github.com/nikitabobko/AeroSpace) — Tiling window manager for macOS
- [Oh-My-Posh](https://ohmyposh.dev/) — Cross-platform shell prompt engine
- [Yazi](https://yazi-rs.github.io/) — Terminal file manager written in Rust
- [TPM (Tmux Plugin Manager)](https://github.com/tmux-plugins/tpm) — Plugin manager for tmux

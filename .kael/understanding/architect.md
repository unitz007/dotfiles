# Architect Onboarding: dotfiles

## High-Level Architecture

This is a **personal developer environment configuration repository** — a single Git repo that acts as the source of truth for shell, editor, window manager, terminal multiplexer, and provisioning configurations. The target platform is **macOS** (Darwin), with secondary support for Linux VMs via cloud-init.

There is no runtime application or service. The "architecture" is a collection of declarative and imperative config files consumed by third-party tools at login/shell-start/editor-start time.

```
┌─────────────────────────────────────────────────────────────────┐
│                     dotfiles/ (Git Repo)                        │
│                                                                 │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌───────────────┐  │
│  │  .zshrc  │  │  nvim/   │  │ tmux/    │  │ .aerospace.toml│  │
│  │  (shell) │  │ (editor) │  │ (mux)    │  │ (window mgr)  │  │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └──────┬────────┘  │
│       │              │              │                │           │
│  ┌────┴─────┐  ┌─────┴──────┐  ┌───┴──────┐  ┌────┴────────┐  │
│  │.skhdrc   │  │zed/        │  │yazi.toml │  │cloud-init   │  │
│  │(hotkeys) │  │(Zed editor)│  │(file mgr)│  │.yaml (VM)   │  │
│  └──────────┘  └────────────┘  └──────────┘  └─────────────┘  │
│                                                                 │
│  ┌──────────────────┐  ┌──────────────────────────────────────┐ │
│  │dotfile-config.yaml│  │ .sdlc.json / .oh-my-posh-theme.json │ │
│  │(sync manifest)   │  │ (tool integration / prompt theme)   │ │
│  └──────────────────┘  └──────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## Component Responsibilities

### 1. Shell Layer — `.zshrc`
- **File**: `.zshrc`
- Initializes Oh My Posh prompt via `eval "$(oh-my-posh init zsh --config ~/.oh-my-posh-theme.json)"`
- Sets environment variables (`KUBE_EDITOR`, `VISUAL`, `LANG`)
- Defines ~30 aliases covering: Git shortcuts, kubectl shorthands, terraform, directory navigation, and an `sdlc` CLI integration (`run`, `tst`, `build`)
- Provides shell functions:
  - `commit <msg> [-p [branch]]` — stage-all + commit + optional push
  - `y()` — Yazi file manager wrapper with cwd-on-exit
  - `ustart()` / `uend()` — Multipass Ubuntu VM lifecycle
- Sources Amazon Q shell integration (pre/post blocks) and iTerm2 shell integration
- Runs `neofetch` on every shell launch

### 2. Editor Layer — `nvim/`
- **Framework**: AstroNvim v4+ with lazy.nvim plugin manager
- **Bootstrap**: `init.lua` → clones lazy.nvim if absent → loads `lazy_setup.lua` → loads `polish.lua`
- **Plugin loading order** (defined in `lua/lazy_setup.lua`):
  1. AstroNvim core (`import = "astronvim.plugins"`)
  2. Community plugins (`lua/community.lua`) — Palenight + Catppuccin colorschemes
  3. User plugins (`lua/plugins/`)
- **User plugin modules** (all currently **disabled** via `if true then return {} end` guard):
  - `astrocore.lua` — vim options, diagnostics, buffer navigation mappings
  - `astrolsp.lua` — LSP features (codelens, semantic tokens, format-on-save)
  - `astroui.lua` — **Active**: sets Catppuccin colorscheme, custom LSP loading icons
  - `mason.lua` — Mason package manager (lua_ls, stylua, python DAP)
  - `treesitter.lua` — Treesitter parsers (lua, vim)
  - `none-ls.lua` — null-ls formatter/linter sources
  - `user.lua` — Example plugins (presence.nvim, lsp_signature, alpha-nvim dashboard, LuaSnip, nvim-autopairs)
  - `polish.lua` — Custom filetype definitions
- **Performance**: Disables gzip, netrw, tar, tohtml, zip RTP plugins

### 3. Window Manager — `.aerospace.toml`
- **Tool**: AeroSpace (i3-inspired tiling WM for macOS)
- **Layout**: Tiles with auto orientation, 30px accordion padding, minimal gaps (10px top only)
- **Workspaces**: CODING, BROWSER, MESSAGING, UTILITY
- **Keybindings**: Vim-style navigation (alt+hjkl), alt+shift+hjkl for moving, alt+slash/comma for layout toggle
- **Auto-assignment**: Routes Goland, Ghostty → CODING; Safari, Chrome → BROWSER; WhatsApp → MESSAGING; Finder → UTILITY (floating)
- **Service mode**: reload-config, flatten, floating toggle, close-all-but-current, volume controls

### 4. Global Hotkeys — `.skhdrc`
- **Tool**: skhd (macOS hotkey daemon)
- Maps `ctrl+<letter>` to launch specific applications (Goland, Fleet, Zed, Safari, Ghostty, Chrome, etc.)

### 5. Terminal Multiplexer — `tmux/tmux.conf`
- True color support via terminal overrides
- Prefix remapped from `C-b` to `C-Space`
- Plugins via TPM: tmux-sensible, catppuccin theme

### 6. File Manager — `yazi.toml`
- Minimal config: enables `show_hidden = true`

### 7. Secondary Editor — `zed/settings.json`
- Font size 16, dark mode with "Atelier Cave Dark" theme

### 8. VM Provisioning — `cloud-init.yaml`
- Targets Multipass Ubuntu VMs
- Installs: zsh, unzip, stow, neovim, nushell
- Post-install: Oh My Posh, Nushell snap, clones this dotfiles repo, copies `.zshrc` and theme, sets zsh as default shell

### 9. Dotfile Sync Manifest — `dotfile-config.yaml`
- Structured YAML describing software → install commands → file mappings
- Supports platform-specific install commands (`linux`, `darwin`, `windows`, `all`)
- Defines target paths using `home` placeholder (expanded to `$HOME`)
- Directory paths denoted with trailing `;`
- Includes commented-out entries for npm, yarn, rust, docker, awscli, kubectl
- Contains security warnings about never committing secrets

### 10. SDLC Integration — `.sdlc.json`
- Maps build system manifests to standard commands (`run`, `test`, `build`)
- Supports: Maven, Go, Cargo, npm, Gradle
- Referenced by `sdlc` CLI tool (external, not in repo) via shell aliases

### 11. Prompt Theme — `.oh-my-posh-theme.json`
- Oh My Posh v3 theme with powerline/accordion styling
- Left segments: OS icon, shell type, root indicator, path, git status (with color-coded backgrounds for dirty/ahead/behind)
- Right segments: Java version, Go version, Rust version, kubectl context/namespace
- Status line: `❯` prompt, turns red on non-zero exit code

## Data Flow

```
                    ┌─────────────────────┐
                    │   macOS Login       │
                    └─────────┬───────────┘
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
     ┌────────────────┐ ┌──────────┐ ┌──────────────┐
     │ AeroSpace WM   │ │  skhd    │ │ Terminal App  │
     │ (.aerospace.toml)│ (.skhdrc)│ │ (Ghostty/    │
     └────────────────┘ └──────────┘ │  iTerm2)     │
                                        └──────┬──────┘
                                               │
                                    ┌──────────┴──────────┐
                                    ▼                     ▼
                             ┌────────────┐       ┌────────────┐
                             │   zsh      │       │   tmux     │
                             │  (.zshrc)  │──────▶│(tmux.conf) │
                             └─────┬──────┘       └────────────┘
                                   │
                    ┌──────────────┼──────────────┐
                    ▼              ▼              ▼
             ┌────────────┐ ┌───────────┐ ┌────────────┐
             │ Oh My Posh │ │  Aliases  │ │ Functions  │
             │ (theme)    │ │ (git, k8s,│ │ (commit, y,│
             │            │ │  tf, sdlc)│ │  ustart)   │
             └────────────┘ └───────────┘ └─────┬──────┘
                                                  │
                                         ┌────────┴────────┐
                                         ▼                 ▼
                                  ┌────────────┐   ┌────────────┐
                                  │   nvim     │   │  yazi      │
                                  │(AstroNvim) │   │(file mgr)  │
                                  └────────────┘   └────────────┘
                                         │
                              ┌──────────┴──────────┐
                              ▼                     ▼
                       ┌────────────┐       ┌────────────┐
                       │ lazy.nvim  │       │ LSP/Mason  │
                       │ (plugins)  │       │ (on-demand)│
                       └────────────┘       └────────────┘
```

**Provisioning flow** (for new machines/VMs):
```
cloud-init.yaml ──▶ Multipass VM
    │
    ├─▶ apt install packages
    ├─▶ curl Oh My Posh installer
    ├─▶ snap install nushell
    ├─▶ git clone dotfiles repo
    ├─▶ cp .zshrc + theme → $HOME
    └─▶ exec zsh
```

## API Surface & Contracts

This repository has no traditional API. Its "contracts" are the **expected file paths and formats** consumed by external tools:

| Config File | Consumer | Format | Expected Location |
|---|---|---|---|
| `.zshrc` | zsh | Shell script | `~/.zshrc` |
| `.oh-my-posh-theme.json` | Oh My Posh | JSON (v3 schema) | `~/.oh-my-posh-theme.json` |
| `.aerospace.toml` | AeroSpace | TOML | `~/.aerospace.toml` |
| `.skhdrc` | skhd | Key-binding DSL | `~/.skhdrc` |
| `nvim/` | Neovim | Lua (AstroNvim v4) | `~/.config/nvim/` |
| `tmux/tmux.conf` | tmux | tmux config | `~/.config/tmux/tmux.conf` or `~/.tmux.conf` |
| `yazi.toml` | Yazi | TOML | `~/.config/yazi/yazi.toml` |
| `zed/settings.json` | Zed | JSON | `~/.config/zed/settings.json` |
| `cloud-init.yaml` | cloud-init / Multipass | YAML (cloud-config) | Referenced by `ustart()` |
| `dotfile-config.yaml` | Custom sync tool | YAML | Repo root (manifest) |
| `.sdlc.json` | `sdlc` CLI | JSON | Repo root (per-project) |

**External dependencies** (not in repo, expected on PATH):
- `oh-my-posh`, `neofetch`, `sdlc`, `kubectl`, `terraform`, `yazi`, `nu` (Nushell), `multipass`

## Scalability & Performance Considerations

### Neovim Startup
- AstroNvim v4 with lazy.nvim provides **lazy loading** — plugins load on-demand by event/filetype
- RTP plugins disabled: gzip, netrw, tar, tohtml, zip — reduces startup overhead
- `lazy-lock.json` present — ensures reproducible plugin versions

### Shell Startup
- `neofetch` runs on **every** shell open — this adds ~200-500ms latency. Consider gating behind a flag or moving to a profile/motd hook
- Amazon Q and iTerm2 integration are conditionally sourced (good pattern)
- Oh My Posh init via `eval` is standard but adds startup cost

### Dotfile Sync
- `dotfile-config.yaml` provides a structured manifest for programmatic deployment, but **no deployment script exists** in the repo. The manifest is ready for a stow-like or ansible-like consumer that hasn't been built yet
- `cloud-init.yaml` handles VM provisioning but uses `sudo mv` with hardcoded paths — fragile if repo structure changes

### Growth Concerns
- As more tools are added, the flat repo root will become cluttered. Currently manageable at ~15 items
- No Makefile/stow/script for automated installation — deployment is manual

## Security Posture

### Strengths
- **`.gitignore`** excludes sensitive directories: `.oh-my-zsh/custom`, `.config/gh`, `.config/linode-cli`, `.config/github-copilot`, `.nixpkgs`, IDE directories
- **`dotfile-config.yaml`** contains explicit security warnings about never committing SSH keys, AWS credentials, API tokens, or GPG keys
- No hardcoded secrets found in any config file
- kubectl context alias in Oh My Posh theme uses a placeholder ARN (`1234567890`), not a real account ID

### Concerns
- **`cloud-init.yaml`** grants `NOPASSWD:ALL` sudo to the `ubuntu` user — acceptable for local VMs but should be documented as intentional
- **`commit()` function** in `.zshrc` runs `git add .` before every commit — risks staging sensitive files that were accidentally created. No `.gitignore` protection at the function level
- **`rmDir` alias** (`rm -rf $1`) is dangerous — the `$1` won't expand correctly in alias context (aliases don't take positional parameters in zsh; this should be a function)
- **`curl | sh`** pattern used in cloud-init for Oh My Posh installation — standard but inherently risky without checksum verification
- Amazon Q shell integration is sourced blindly without integrity checks

## Structural Improvement Suggestions

### 1. Add an Installation/Bootstrap Script
Create a `install.sh` (or `Makefile`) that consumes `dotfile-config.yaml` and symlinks/copies files to their expected locations. This makes the repo self-deploying rather than requiring manual setup.

### 2. Fix the `rmDir` Alias
```zsh
# Current (broken — $1 doesn't work in aliases):
alias rmDir="rm -rf $1"

# Should be:
rmDir() { rm -rf "$1"; }
```
Better yet, consider removing it entirely — `rm -rf` wrappers are footguns.

### 3. Gate `neofetch` Behind a Flag
```zsh
# Only run neofetch on interactive login shells, not every subshell
if [[ $- == *i* ]] && [[ ! -n "$TMUX" ]]; then
  neofetch
fi
```

### 4. Activate or Remove Disabled Neovim Configs
Six of eight plugin files in `nvim/lua/plugins/` are disabled with `if true then return {} end`. Either:
- Remove them if they're just AstroNvim template boilerplate, or
- Activate and customize them to match the developer's actual workflow

### 5. Add a `README.md` at Repo Root
The repo lacks a top-level README. A README should document:
- Prerequisites (Homebrew, Oh My Posh, etc.)
- Installation steps
- Tool overview
- Screenshot of the desktop/terminal setup

### 6. Structure the Repo for Scalability
Consider grouping by tool category:
```
shell/
  zsh/.zshrc
  zsh/.oh-my-posh-theme.json
wm/
  aerospace/.aerospace.toml
  skhd/.skhdrc
editors/
  nvim/
  zed/
terminal/
  tmux/
  yazi/
provisioning/
  cloud-init.yaml
```
This scales better as more tools are added.

### 7. Add Pre-Commit Hooks
Use a tool like `pre-commit` or `lefthook` to validate:
- JSON syntax (`.oh-my-posh-theme.json`, `zed/settings.json`)
- TOML syntax (`.aerospace.toml`, `yazi.toml`)
- Lua syntax (`nvim/**/*.lua`)
- Shell script linting (`.zshrc`)

### 8. Make `commit()` Function Safer
Add `--dry-run` awareness and consider not using `git add .`:
```zsh
function commit() {
  if [[ -z "$1" ]]; then
    echo "Usage: commit <message> [-p [branch]]"
    return 1
  fi
  git add -A
  git diff --cached --stat  # Show what will be committed
  git commit -m "$1"
  # ... push logic
}
```

### 9. Version Pin External Tools
The `cloud-init.yaml` and `dotfile-config.yaml` install commands use latest versions. For reproducibility, consider pinning versions (e.g., `brew install neovim@0.10` or specifying Oh My Posh version in the curl URL).

### 10. Consolidate Duplicate Comments in `dotfile-config.yaml`
The header comment block is duplicated (lines 1-16 and 1-33 contain the same documentation). Remove the duplication.

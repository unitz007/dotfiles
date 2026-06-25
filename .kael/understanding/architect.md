# Architect Onboarding: dotfiles

## High-Level Architecture

This repository is a **personal developer environment configuration management system** — a curated collection of dotfiles and tool configurations designed to provision a consistent macOS-centric development workspace. It is not an application; it is a declarative, version-controlled snapshot of a developer's entire shell, editor, window manager, and terminal experience.

The architecture is **flat and file-oriented**: each tool's configuration lives at the repository root or in a single subdirectory, with a central manifest (`dotfile-config.yaml`) describing how each piece maps to the filesystem.

```
dotfiles/
├── dotfile-config.yaml        # Central manifest: software → install → file mappings
├── .sdlc.json                 # SDLC command runner config (run/test/build shortcuts)
├── .zshrc                     # Shell initialization (aliases, functions, env vars)
├── .oh-my-posh-theme.json     # Oh My Posh prompt theme
├── .aerospace.toml            # AeroSpace tiling window manager config
├── .skhdrc                    # skhd hotkey daemon bindings
├── yazi.toml                  # Yazi file manager config
├── cloud-init.yaml            # Multipass VM provisioning template
├── nvim/                      # Neovim (AstroNvim v4) configuration tree
│   ├── init.lua               # Bootstrap: Lazy.nvim installer + entry point
│   ├── lua/
│   │   ├── lazy_setup.lua     # Lazy.nvim plugin registry
│   │   ├── community.lua      # AstroCommunity plugin imports
│   │   ├── polish.lua         # Post-setup hooks (currently disabled)
│   │   └── plugins/           # Per-concern plugin overrides
│   │       ├── astrocore.lua  # Core vim options, mappings, diagnostics
│   │       ├── astrolsp.lua   # LSP server config, formatting, handlers
│   │       ├── astroui.lua    # Colorscheme (catppuccin), icons
│   │       ├── mason.lua      # Mason: LSP/formatter/DAP installer pins
│   │       ├── none-ls.lua    # null-ls external linter/formatter sources
│   │       ├── treesitter.lua # Treesitter parser pins
│   │       └── user.lua       # Custom plugins (presence, lsp_signature, alpha)
│   └── lazy-lock.json         # Pinned plugin versions (65 plugins)
├── tmux/
│   └── tmux.conf              # tmux: TPM, catppuccin theme, Ctrl-Space prefix
└── zed/
    └── settings.json          # Zed editor: font size, dark theme
```

**Target platform:** Primarily macOS (darwin), with Linux support declared in the manifest and a `cloud-init.yaml` for Ubuntu VM provisioning via Multipass.

## Component Responsibilities

### 1. `dotfile-config.yaml` — Deployment Manifest
The single source of truth for **which software is managed**, **how to install it** (per-platform), and **which files to symlink/copy where**. Supports `linux`, `darwin`, `windows`, `freebsd`, `openbsd`, and `all` platform keys. File paths ending with `;` denote directories. Target `home` is expanded to `$HOME`.

### 2. `.zshrc` — Shell Environment
The primary shell initialization file. Responsibilities:
- **Prompt engine:** Initializes Oh My Posh with a custom JSON theme
- **Environment variables:** `KUBE_EDITOR=nvim`, `VISUAL=nvim`, `LANG=en_US.UTF-8`
- **Aliases:** ~30 shortcuts covering git, kubectl, terraform, navigation, and an `sdlc` integration
- **Functions:**
  - `commit <msg> [-p [branch]]` — stage-all + commit + optional push
  - `y` — Yazi file manager wrapper with cwd tracking via temp file
  - `ustart` / `uend` — Multipass Ubuntu VM lifecycle (launch with cloud-init / delete+purge)
- **Integration hooks:** Amazon Q CLI (pre/post blocks), iTerm2 shell integration, Fig export

### 3. `nvim/` — Neovim IDE (AstroNvim v4)
A full-featured IDE configuration built on the AstroNvim framework:
- **Plugin manager:** Lazy.nvim (bootstrapped from `init.lua`)
- **Plugin ecosystem:** 65 locked plugins including LSP (mason + nvim-lspconfig), DAP, completion (nvim-cmp + LuaSnip), fuzzy finding (telescope), file browsing (neo-tree), git (gitsigns), AI (copilot.lua, tabnine-nvim), and UI (heirline, which-key, alpha dashboard)
- **Colorscheme:** Catppuccin (with Palenight available via community)
- **Key design decision:** Most plugin override files are **disabled** (`if true then return {} end`), meaning the configuration runs largely on AstroNvim defaults with only `astroui.lua` (colorscheme) and `lazy_setup.lua` (plugin registry) actively customized

### 4. `.aerospace.toml` — Tiling Window Manager
AeroSpace (i3-like tiling WM for macOS) configuration:
- **Layout:** Tiles with auto orientation, 30px accordion padding
- **Workspaces:** CODING, BROWSER, MESSAGING, UTILITY (with a typo: `BROSWER` in one binding)
- **Keybindings:** Vim-style (alt+hjkl) for focus/move, alt+slash/comma for layout toggle
- **Auto-assignment:** JetBrains GoLand, Ghostty → CODING; Safari, Chrome → BROWSER; WhatsApp → MESSAGING; Finder → UTILITY (floating)
- **Service mode:** reload-config, flatten, floating toggle, volume controls

### 5. `.skhdrc` — Global Hotkey Daemon
17 `ctrl+<key>` application launcher bindings for rapid app switching (Goland, Fleet, Zed, Safari, Ghostty, Chrome, etc.).

### 6. `.oh-my-posh-theme.json` — Shell Prompt Theme
A three-block Oh My Posh v3 theme:
- **Left:** OS icon, shell type, root indicator, full path, git status (with color-coded branch state)
- **Right:** Java/Go/Rust version detection, kubectl context+namespace
- **Bottom:** Status indicator (❯, turns red on error)

### 7. `.sdlc.json` — SDLC Command Runner
Maps build tool manifest files to standard `run`/`test`/`build` commands. Supports Maven, Go, Cargo, npm, and Gradle. Used via the `sdlc` CLI tool aliased in `.zshrc`.

### 8. `cloud-init.yaml` — VM Provisioning
Cloud-config for Multipass Ubuntu VMs: installs zsh, unzip, stow, neovim, nushell; clones this dotfiles repo; deploys `.zshrc` and theme; sets zsh as default shell.

### 9. `tmux/tmux.conf` — Terminal Multiplexer
Minimal tmux config: true color support, `Ctrl-Space` prefix (matching no leader conflict with nvim's Space), TPM plugin manager, catppuccin theme.

### 10. `yazi.toml` — File Manager
Single setting: `show_hidden = true`.

### 11. `zed/settings.json` — Zed Editor
Font size 16, Atelier Cave Dark theme.

## Data Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    PROVISIONING FLOW                            │
│                                                                 │
│  dotfile-config.yaml                                            │
│       │                                                         │
│       ├──► [Deploy Agent] ──► reads software[].install          │
│       │         │              runs platform-appropriate cmd     │
│       │         └──► reads software[].files                     │
│       │                symlinks/copies path → $HOME/target       │
│       │                                                         │
│  cloud-init.yaml (alternative path for fresh VMs)               │
│       │                                                         │
│       └──► [Multipass] ──► apt install packages                │
│                │         └──► clone dotfiles repo               │
│                └──► deploy .zshrc + theme                       │
│                   └──► chsh to zsh                              │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    RUNTIME FLOW (Shell Session)                 │
│                                                                 │
│  zsh launch                                                     │
│    │                                                            │
│    ├─► Amazon Q pre-block                                       │
│    ├─► Oh My Posh init ──► .oh-my-posh-theme.json               │
│    │     └─► Renders prompt with git/java/go/rust/k8s context   │
│    ├─► Export env vars (KUBE_EDITOR, VISUAL, LANG)              │
│    ├─► Load aliases & functions                                 │
│    ├─► neofetch                                                  │
│    ├─► Fig export (if present)                                  │
│    ├─► iTerm2 integration (if present)                          │
│    └─► Amazon Q post-block                                      │
│                                                                 │
│  User types `nvim`                                              │
│    └─► init.lua ──► bootstrap Lazy.nvim                         │
│         └─► lazy_setup.lua ──► AstroNvim v4 + plugins           │
│              ├─► astroui.lua (catppuccin theme)                 │
│              ├─► community.lua (palenight, catppuccin extras)    │
│              └─► plugins/* (mostly defaults, user.lua active)   │
│                                                                 │
│  User types `tmux`                                              │
│    └─► tmux.conf ──► TPM + catppuccin theme                     │
│                                                                 │
│  AeroSpace (runs at login)                                      │
│    └─► .aerospace.toml ──► tiling layout + workspace rules      │
│                                                                 │
│  skhd (runs at login)                                           │
│    └─► .skhdrc ──► global ctrl+key app launchers                │
└─────────────────────────────────────────────────────────────────┘
```

## API Surface & Contracts

This repository defines no executable API. Its "contracts" are:

| Contract | Mechanism | Consumer |
|---|---|---|
| **File mapping spec** | `dotfile-config.yaml` schema (software, install, files) | Hypothetical deploy agent / stow |
| **Shell interface** | `.zshrc` exports: aliases (`run`, `tst`, `build`, `commit`, `y`, `ustart`, `uend`, `k`, `tf`), env vars (`KUBE_EDITOR`, `VISUAL`) | Interactive zsh sessions |
| **SDLC commands** | `.sdlc.json` maps manifest files to run/test/build | `sdlc` CLI tool |
| **Neovim plugin API** | Lazy.nvim spec format (`---@type LazySpec`) | Lazy.nvim plugin loader |
| **AeroSpace config** | TOML schema per AeroSpace documentation | AeroSpace WM |
| **skhd bindings** | `key : command` format | skhd daemon |
| **Oh My Posh theme** | JSON schema v3 with blocks/segments | Oh My Posh prompt engine |
| **cloud-init** | cloud-config YAML spec | cloud-init / Multipass |

## Scalability & Performance Considerations

### Neovim Startup Performance
- **Lazy.nvim** provides lazy-loading, but the current config loads AstroNvim's full default plugin set (~65 plugins) eagerly. The `lazy-lock.json` pins all versions, ensuring reproducible builds.
- **Disabled RTP plugins** (`gzip`, `netrwPlugin`, `tarPlugin`, `tohtml`, `zipPlugin`) in `lazy_setup.lua` reduce startup overhead.
- **Large file detection** is configured at 256KB / 10,000 lines to disable treesitter and other heavy features.
- **Opportunity:** Many plugin override files are disabled (`if true then return {} end`). Activating them (especially `none-ls.lua` for formatters and `treesitter.lua` for more parsers) will increase startup time proportionally.

### Shell Performance
- Oh My Posh prompt evaluation runs on every prompt render. The theme fetches git status, Java/Go/Rust versions, and kubectl context — each potentially slow in large repos or with many toolchains installed.
- `neofetch` runs on every shell launch, adding ~200-500ms to new terminal windows.

### Deploy Agent Scalability
- The `dotfile-config.yaml` manifest is human-maintained. There is no automation script in the repo to consume it. Scaling to more machines requires either manual stow/symlink or building the referenced deploy agent.

## Security Posture

### Strengths
- **`.gitignore`** explicitly excludes sensitive directories: `.oh-my-zsh/custom`, `.config/gh`, `.config/linode-cli`, `.nixpkgs`, IDE directories
- **`dotfile-config.yaml`** contains a prominent security warning: "Never include sensitive files like Private SSH keys, AWS credentials, API tokens or passwords, GPG private keys"
- **No secrets detected** in any tracked file — the kubectl context alias in the theme uses a placeholder ARN (`1234567890`)

### Concerns
- **`cloud-init.yaml`** grants `NOPASSWD:ALL` sudo to the `ubuntu` user — appropriate for local VMs but dangerous if the template is reused in production contexts
- **`commit()` function** in `.zshrc` runs `git add .` before every commit, which could accidentally stage sensitive files that were recently created but not yet gitignored
- **`rmDir` alias** (`rm -rf $1`) is a footgun — the `$1` is not properly quoted and the alias form doesn't pass arguments correctly in zsh (aliases don't accept positional parameters; this would need to be a function)
- **No GPG signing** or commit verification configured in the git setup
- **Oh My Posh install** in cloud-init uses `curl | bash` without checksum verification

## Structural Improvement Suggestions

### 1. Add a Deploy/Bootstrap Script
The `dotfile-config.yaml` manifest describes the desired state but nothing enacts it. A `bootstrap.sh` or `Makefile` that reads the manifest and creates symlinks would make the repo self-contained and immediately useful on a fresh machine.

### 2. Fix the `rmDir` Alias
```zsh
# Current (broken — aliases don't take $1):
alias rmDir="rm -rf $1"
# Should be:
rmDir() { rm -rf "$@"; }
```
Additionally, consider adding a safety confirmation or using `trash` instead.

### 3. Activate or Remove Disabled Plugin Configs
Six of seven files in `nvim/lua/plugins/` are disabled with `if true then return {} end`. Either activate them with meaningful configuration or remove them to reduce confusion about what's actually in effect.

### 4. Fix Typo in Aerospace Config
Line 119: `alt-b = 'workspace BROSWER'` should be `BROWSER` to match the workspace name used everywhere else in the file.

### 5. Add Conditional `neofetch` Launch
Running `neofetch` unconditionally on every shell open slows down terminal startup. Wrap it:
```zsh
if [[ -z "$NOFETCH" ]]; then neofetch; fi
```

### 6. Modularize `.zshrc`
At 109 lines, `.zshrc` is manageable but growing. Consider splitting into `~/.config/zsh/aliases.zsh`, `functions.zsh`, `exports.zsh` and sourcing them — the `dotfile-config.yaml` already declares a `zsh;` directory target at `home/.config`.

### 7. Add a `Makefile` or `justfile` for Common Operations
```makefile
deploy:
    # stow or symlink files per dotfile-config.yaml
update:
    brew upgrade && brew cleanup
vm-up:
    multipass launch -n ubuntu --cloud-init cloud-init.yaml
vm-down:
    multipass delete ubuntu && multipass purge
```

### 8. Version-Lock Oh My Posh Theme
The theme references `$schema` from GitHub main branch. Pin to a specific commit hash or tag for reproducibility.

### 9. Add `.editorconfig`
With configurations spanning Lua, TOML, YAML, JSON, and shell, an `.editorconfig` at the repo root would ensure consistent formatting across editors.

### 10. Consider Nix or Guix for Reproducibility
For true cross-machine reproducibility (the stated goal of the manifest), a `flake.nix` or `guix.scm` would provide hermetic, declarative package management that goes beyond the current install-command approach.

# Architect Onboarding: dotfiles

## High-Level Architecture

This is a **personal developer environment configuration repository** — a curated collection of dotfiles and tool configs designed to provision a consistent macOS-centric development workspace. The repo is not a software application; it is a **declarative, version-controlled representation of a developer's entire shell, editor, window manager, and terminal stack**.

The architecture is flat and file-oriented, with no build system or runtime. It follows a "clone and symlink" philosophy, augmented by a structured manifest (`dotfile-config.yaml`) that describes which files map to which target locations and how to install the underlying software.

```
dotfiles/                          (repo root)
├── .zshrc                         ← Shell entrypoint
├── .oh-my-posh-theme.json         ← Prompt theme
├── .aerospace.toml                ← Tiling window manager config
├── .skhdrc                        ← Global hotkey daemon config
├── .sdlc.json                     ← Dev command shortcuts (run/test/build)
├── yazi.toml                      ← File manager config
├── cloud-init.yaml                ← VM provisioning template
├── dotfile-config.yaml            ← Manifest: software + file mappings
├── nvim/                          ← Neovim (AstroNvim v4 distribution)
│   ├── init.lua                   ← Bootstrap: lazy.nvim installer
│   ├── lua/
│   │   ├── lazy_setup.lua         ← Plugin registry (lazy.nvim spec)
│   │   ├── community.lua          ← Community plugin imports
│   │   ├── polish.lua             ← Post-init customizations
│   │   └── plugins/               ← Per-concern plugin overrides
│   │       ├── astrocore.lua      ← Core: mappings, options, autocmds
│   │       ├── astrolsp.lua       ← LSP: servers, formatting, handlers
│   │       ├── astroui.lua        ← UI: colorscheme, icons
│   │       ├── mason.lua          ← Mason: LSP/formatter/DAP installs
│   │       ├── none-ls.lua        ← None-ls: external linters/formatters
│   │       ├── treesitter.lua     ← Treesitter: parser installs
│   │       └── user.lua           ← User plugins (presence, snippets, etc.)
│   └── lazy-lock.json             ← Plugin version lockfile
├── tmux/
│   └── tmux.conf                  ← Tmux: prefix, plugins, truecolor
└── zed/
    └── settings.json              ← Zed editor: font, theme
```

**Target platform:** Primarily macOS (darwin), with Linux support declared in the manifest. The tooling choices (Homebrew, AeroSpace, skhd, iTerm2, Ghostty) are macOS-native.

## Component Responsibilities

### 1. Shell Layer (`.zshrc`)
The central shell configuration. Responsibilities:
- **Prompt engine:** Initializes Oh My Posh with a custom JSON theme (`.oh-my-posh-theme.json`)
- **Environment variables:** Sets `KUBE_EDITOR=nvim`, `VISUAL=nvim`, `LANG=en_US.UTF-8`
- **Aliases:** ~30 shortcuts covering git, kubectl, terraform, navigation, and a custom `sdlc` command runner
- **Functions:**
  - `commit(msg, [-p, branch])` — staged git commit with optional push
  - `y()` — Yazi file manager wrapper with cwd persistence via temp file
  - `ustart()` / `uend()` — Multipass Ubuntu VM lifecycle management
- **Integration hooks:** Amazon Q CLI (pre/post blocks), iTerm2 shell integration, Fig export

### 2. Neovim Editor (`nvim/`)
Built on **AstroNvim v4**, a batteries-included Neovim distribution using **lazy.nvim** as the plugin manager.

| File | Role | Status |
|------|------|--------|
| `init.lua` | Bootstrap: clones lazy.nvim if absent, loads setup | Active |
| `lazy_setup.lua` | Plugin registry: AstroNvim core + community + user plugins | Active |
| `community.lua` | Imports community colorschemes (palenight, catppuccin) | Active |
| `astroui.lua` | Sets catppuccin as default colorscheme | Active |
| `astrocore.lua` | Core options (relative line numbers, no wrap, diagnostics) | **Guarded** (`if true then return {} end`) |
| `astrolsp.lua` | LSP config (format-on-save, codelens, semantic tokens) | **Guarded** |
| `mason.lua` | Mason: auto-install lua_ls, stylua, python DAP | **Guarded** |
| `none-ls.lua` | External linter/formatter sources | **Guarded** |
| `treesitter.lua` | Parser installs (lua, vim) | **Guarded** |
| `user.lua` | Custom plugins (presence.nvim, lsp_signature, alpha dashboard) | **Guarded** |
| `polish.lua` | Custom filetype definitions | **Guarded** |

**Key observation:** Most plugin config files are guarded with `if true then return {} end`, meaning they are **templates awaiting activation**. Only the bootstrap chain (`init.lua` → `lazy_setup.lua` → `community.lua` → `astroui.lua`) is live.

### 3. Tiling Window Manager (`.aerospace.toml`)
**AeroSpace** — an i3-like tiling WM for macOS. Configuration:
- **Layout:** Tiles with auto orientation, zero inner gaps, 10px top outer gap
- **Keybindings:** Vim-style navigation (alt+hjkl), workspace switching (alt+c/b/m/t for CODING/BROWSER/MESSAGING/UTILITY)
- **Service mode:** alt+shift+; enters service mode for layout reset, floating toggle, reload
- **Auto-assignment:** JetBrains GoLand, Ghostty → CODING; Safari, Chrome → BROWSER; WhatsApp → MESSAGING; Finder → UTILITY (floating)

### 4. Global Hotkeys (`.skhdrc`)
**skhd** — macOS hotkey daemon. Maps `ctrl+<key>` to application launches:
- `ctrl+g` → GoLand, `ctrl+z` → Zed, `ctrl+t` → Ghostty, `ctrl+h` → Chrome, etc.
- 15 application shortcuts total

### 5. Terminal Multiplexer (`tmux/tmux.conf`)
Minimal tmux configuration:
- True color support via terminal overrides
- Custom prefix: `Ctrl+Space` (replaces default `Ctrl+b`)
- Plugin management via TPM: tmux-sensible + catppuccin theme

### 6. Prompt Theme (`.oh-my-posh-theme.json`)
Oh My Posh v3 theme with three prompt blocks:
- **Left:** OS icon → shell type → root indicator → working directory → git status (with color-coded branch state)
- **Right:** Java version → Go version → Rust version → kubectl context/namespace
- **Bottom:** Status arrow (❯), turns red on non-zero exit code

### 7. Dev Command Shortcuts (`.sdlc.json`)
Maps build tool manifests to standardized `run`/`test`/`build` commands:
- `pom.xml` → Maven, `go.mod` → Go, `Cargo.toml` → Rust, `package.json` → npm, `build.gradle.kts` → Gradle
- Consumed via shell aliases: `run` → `sdlc run`, `tst` → `sdlc test`, `build` → `sdlc build`

### 8. File Manager (`yazi.toml`)
Single-line config enabling hidden file display in Yazi.

### 9. VM Provisioning (`cloud-init.yaml`)
Cloud-init template for Multipass Ubuntu VMs:
- Installs: zsh, unzip, stow, neovim, nushell
- Clones this dotfiles repo and deploys `.zshrc` + theme
- Installs Oh My Posh and Nushell via snap

### 10. Deployment Manifest (`dotfile-config.yaml`)
Structured YAML describing the full software stack:
- **Active entries:** bash, zsh, git, vim, neovim, tmux, alacritty, kitty, starship
- **Commented entries:** npm, yarn, rust, docker, awscli, kubectl
- Each entry has platform-specific install commands (linux/darwin/windows) and file→target mappings
- Directories denoted with trailing `;` (e.g., `nvim;` → `home/.config`)

## Data Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    PROVISIONING FLOW                            │
│                                                                 │
│  dotfile-config.yaml                                            │
│       │                                                         │
│       ├──► Install commands (brew/apt/choco/curl)               │
│       │         per platform (linux/darwin/windows)              │
│       │                                                         │
│       └──► Symlink/Stow mappings                                │
│                 repo file ──► $HOME target                      │
│                                                                 │
│  cloud-init.yaml (alternative path for VMs)                     │
│       │                                                         │
│       └──► Multipass VM ──► apt install ──► git clone ──► cp   │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    SHELL INIT CHAIN                             │
│                                                                 │
│  zsh starts                                                     │
│    │                                                            │
│    ├─► Amazon Q pre-block                                       │
│    ├─► oh-my-posh init (reads .oh-my-posh-theme.json)           │
│    ├─► Export env vars (KUBE_EDITOR, VISUAL, LANG)              │
│    ├─► Define aliases & functions                               │
│    ├─► neofetch                                                 │
│    ├─► Fig export (if present)                                  │
│    ├─► iTerm2 shell integration (if present)                    │
│    └─► Amazon Q post-block                                      │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    NEOVIM INIT CHAIN                            │
│                                                                 │
│  nvim starts                                                    │
│    │                                                            │
│    ├─► init.lua                                                 │
│    │     ├─► Clone lazy.nvim if missing                         │
│    │     └─► require("lazy_setup")                              │
│    │           └─► require("polish")                            │
│    │                                                            │
│    ├─► lazy_setup.lua                                           │
│    │     ├─► AstroNvim v4 (import "astronvim.plugins")          │
│    │     ├─► community.lua (palenight, catppuccin)              │
│    │     └─► plugins/* (all guarded except astroui.lua)         │
│    │                                                            │
│    └─► polish.lua (guarded — no-op)                             │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    DESKTOP ENVIRONMENT                          │
│                                                                 │
│  macOS Login                                                    │
│    │                                                            │
│    ├─► AeroSpace (start-at-login: true)                        │
│    │     ├─► .aerospace.toml (layout, gaps, bindings)           │
│    │     └─► Auto-assigns windows to workspaces                 │
│    │                                                            │
│    └─► skhd (hotkey daemon)                                    │
│          └─► .skhdrc (ctrl+key → open app)                     │
└─────────────────────────────────────────────────────────────────┘
```

## API Surface & Contracts

This repository has no traditional API. Its "contracts" are:

| Contract | Mechanism | Consumer |
|----------|-----------|----------|
| File layout convention | `dotfile-config.yaml` path/target schema | Symlink/stow scripts |
| Platform detection | `linux`/`darwin`/`windows` keys in install maps | Provisioning tooling |
| Neovim plugin interface | lazy.nvim `LazySpec` return type | AstroNvim + lazy.nvim |
| Shell function signatures | `commit <msg> [-p [branch]]`, `y [args]`, `ustart()`, `uend()` | Interactive shell |
| Hotkey bindings | skhd `key : command` syntax | macOS skhd daemon |
| WM keybindings | AeroSpace TOML `[mode.main.binding]` | AeroSpace WM |
| SDLC commands | `.sdlc.json` manifest → `sdlc` CLI tool | Shell aliases (`run`, `tst`, `build`) |
| Cloud-init spec | `cloud-init.yaml` cloud-config format | Multipass/cloud-init |

## Scalability & Performance Considerations

### Shell Performance
- **Oh My Posh** is initialized on every shell spawn via `eval "$(oh-my-posh init zsh ...)"`. This is a known performance cost. Consider using the [transient prompt](https://ohmyposh.dev/docs/configuration/transient) feature or caching the prompt for faster shell startup.
- **neofetch** runs on every shell open (line 101 of `.zshrc`). This adds ~200-500ms latency. Should be gated behind a flag or moved to a profile/login script.
- The `commit()` function uses `git add .` which stages everything — a potential footgun in large repos.

### Neovim Performance
- AstroNvim v4 with lazy.nvim provides **lazy-loading** by default, which is good.
- Several RTP plugins are explicitly disabled (`gzip`, `netrwPlugin`, `tarPlugin`, `tohtml`, `zipPlugin`) — a solid optimization.
- The guarded plugin files mean the active plugin surface is minimal today, keeping startup fast.

### Manifest Design
- `dotfile-config.yaml` is well-structured for scaling — new tools are added as list entries with platform-conditional installs.
- The trailing-`;` convention for directories is unconventional and error-prone. A `type: directory` field would be clearer.

## Security Posture

### Strengths
- **`.gitignore`** explicitly excludes sensitive paths: `.oh-my-zsh/custom`, `.config/gh`, `.config/linode-cli`, `.nixpkgs`, IDE directories
- **`dotfile-config.yaml`** contains a prominent security warning (lines 171-176) against committing private SSH keys, AWS credentials, API tokens, or GPG keys
- No hardcoded secrets found in any config file

### Concerns
- **`cloud-init.yaml` line 18:** `curl -s https://ohmyposh.dev/install.sh | bash -s` — piping remote scripts directly into bash without integrity verification (no checksum, no pinned version). This is a supply-chain risk in VM provisioning.
- **`cloud-init.yaml` line 7:** `sudo: ALL=(ALL) NOPASSWD:ALL` — passwordless sudo for the ubuntu user in VMs. Acceptable for local dev VMs but should be documented as intentional.
- **`.sdlc.json`** runs arbitrary project commands (`mvn spring-boot:run`, `npm run dev`, etc.) — these are project-defined and trusted by convention.
- **`.zshrc` line 37:** `alias rmDir="rm -rf $1"` — this alias is broken (aliases don't take arguments this way in zsh; `$1` expands at definition time, not call time). Not a security risk per se, but could cause unexpected behavior.
- **No GPG signing** configuration visible for git commits.

## Structural Improvement Suggestions

### 1. Add a Bootstrap/Install Script
The `dotfile-config.yaml` manifest describes what to install and where to link, but there is **no script that actually performs these actions**. A `bootstrap.sh` or `install.sh` that reads the manifest and:
- Detects the current platform
- Runs install commands
- Creates symlinks (or uses GNU Stow, which is already in the cloud-init packages)
...would make this repo truly portable.

### 2. Activate or Remove Guarded Plugin Configs
Six of seven Neovim plugin files are no-ops due to `if true then return {} end`. Either:
- Remove them to reduce confusion (they can be regenerated from AstroNvim templates)
- Or activate them and customize — the current state suggests incomplete migration

### 3. Fix the `rmDir` Alias
```zsh
# Current (broken — $1 expands at definition time)
alias rmDir="rm -rf $1"

# Fix: use a function instead
rmDir() { rm -rf "$@"; }
```

### 4. Gate neofetch on Interactive Shell
```zsh
# Only run neofetch for interactive, non-TMUX sessions
if [[ $- == *i* ]] && [[ -z "$TMUX" ]] && [[ -z "$VSCODE_INJECTION" ]]; then
  neofetch
fi
```

### 5. Replace Directory Semicolon Convention
```yaml
# Current (confusing)
- path: nvim;
  target: home/.config

# Proposed (explicit)
- path: nvim
  target: home/.config
  type: directory
```

### 6. Add a README.md
The repo has no README. A README should document:
- Prerequisites (Homebrew, Oh My Posh, etc.)
- Installation/bootstrap instructions
- Platform support matrix
- Key features and tool choices
- Screenshot of the desktop environment

### 7. Pin Oh My Posh Version in cloud-init
```yaml
# Instead of latest:
- curl -s https://ohmyposh.dev/install.sh | bash -s

# Pin a version for reproducibility:
- curl -s https://ohmyposh.dev/install.sh | bash -s -- -v 21.7.0
```

### 8. Consider a Makefile/Justfile for Common Operations
A task runner at the repo root would standardize operations:
```
just install    # Bootstrap everything
just link       # Create symlinks
just update     # Update brew, npm, etc.
just clean      # Remove all symlinks
```

### 9. Add Zsh Plugin Manager
The `.zshrc` references Oh My Zsh custom directory in `.gitignore` but doesn't initialize Oh My Zsh. Consider either:
- Committing to Oh My Zsh and adding it to the bootstrap
- Or removing the `.gitignore` entry to avoid confusion

### 10. Typo in Aerospace Config
Line 119: `alt-b = 'workspace BROSWER'` should be `'workspace BROWSER'` (and line 129 has the same typo in `move-node-to-workspace BROSWER`). Line 185 also has `UTILITY` vs `UTILTY` inconsistency.

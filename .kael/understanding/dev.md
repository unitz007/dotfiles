# Developer Onboarding: dotfiles

## Technical Stack

This is a **personal macOS dotfiles repository** — not a software project. It contains configuration files for a macOS-centric development environment. The "stack" is the collection of CLI tools, terminal emulators, editors, and window managers configured here:

- **Shell**: Zsh with [Oh My Posh](https://ohmyposh.dev/) prompt theming (`.oh-my-posh-theme.json`, `.zshrc`)
- **Window Manager**: [AeroSpace](https://github.com/nikitabobko/AeroSpace) (i3-like tiling WM for macOS) — `.aerospace.toml`
- **Hotkey Daemon**: [skhd](https://github.com/koekeishiya/skhd) — `.skhdrc`
- **Terminal Editor**: Neovim via [AstroNvim v4](https://astronvim.com/) distribution with lazy.nvim plugin manager — `nvim/`
- **GUI Editor**: Zed — `zed/settings.json`
- **Terminal Multiplexer**: tmux with TPM plugin manager and Catppuccin theme — `tmux/tmux.conf`
- **File Manager**: [Yazi](https://yazi-rs.github.io/) (Rust-based terminal file manager) — `yazi.toml`
- **VM Provisioning**: Multipass + cloud-init for Ubuntu VMs — `cloud-init.yaml`
- **Dev Tool Helper**: Custom `sdlc` CLI (defined in `.sdlc.json`) for run/test/build shortcuts across Java, Go, Rust, Node, Gradle projects
- **Dotfile Management**: `dotfile-config.yaml` — a declarative YAML schema for tracking which dotfiles map to which software, with platform-specific install commands (linux/darwin/windows)

## Repository Structure

```
.
├── .aerospace.toml          # AeroSpace tiling WM config (keybindings, workspaces, gaps)
├── .skhdrc                  # skhd global hotkey daemon (ctrl+letter → open apps)
├── .zshrc                   # Zsh shell config (aliases, functions, env vars, prompt init)
├── .oh-my-posh-theme.json   # Oh My Posh prompt theme (powerline, git, kubectl, language versions)
├── .sdlc.json               # SDLC CLI config: maps project manifests to run/test/build commands
├── dotfile-config.yaml      # Declarative dotfile manifest (software → install commands → file mappings)
├── cloud-init.yaml          # Multipass Ubuntu VM cloud-init (installs zsh, neovim, nushell, oh-my-posh)
├── yazi.toml                # Yazi file manager config (show hidden files)
├── nvim/                    # Neovim (AstroNvim v4) configuration
│   ├── init.lua             # Bootstrap: installs lazy.nvim, loads lazy_setup + polish
│   ├── lazy-lock.json       # Pinned plugin versions (65 plugins)
│   ├── lua/
│   │   ├── lazy_setup.lua   # lazy.nvim setup: AstroNvim v4, community, user plugins
│   │   ├── community.lua    # AstroCommunity imports (palenight, catppuccin colorschemes)
│   │   ├── polish.lua       # Post-setup hooks (currently disabled with `if true then return end`)
│   │   └── plugins/
│   │       ├── astroui.lua      # UI config: catppuccin colorscheme, LSP loading icons
│   │       ├── astrocore.lua    # Core: vim options, diagnostics, buffer mappings (DISABLED)
│   │       ├── astrolsp.lua     # LSP: formatting on save, codelens, semantic tokens (DISABLED)
│   │       ├── mason.lua        # Mason: ensure_installed for lua_ls, stylua, python DAP (DISABLED)
│   │       ├── treesitter.lua   # Treesitter: lua, vim parsers (DISABLED)
│   │       ├── none-ls.lua      # none-ls: custom formatters/linters (DISABLED)
│   │       └── user.lua         # User plugins: presence.nvim, lsp_signature, alpha dashboard (DISABLED)
│   ├── .neoconf.json        # neoconf.nvim LSP settings
│   ├── .stylua.toml         # StyLua formatter config
│   ├── selene.toml          # Selene Lua linter config
│   └── neovim.yml           # Neovim GitHub Actions CI config
├── tmux/
│   └── tmux.conf            # tmux: true color, Ctrl-Space prefix, TPM + catppuccin theme
├── zed/
│   └── settings.json        # Zed editor: font size 16, Atelier Cave Dark theme
└── .gitignore               # Ignores oh-my-zsh custom, IDE dirs, sensitive configs
```

## Entry Points & Main Flow

There is no runtime "entry point" — this is a configuration repository. The deployment flow is:

1. **Clone** the repo to `$HOME` (or a subdirectory)
2. **Symlink/copy** dotfiles to their target locations (guided by `dotfile-config.yaml`)
3. **Install software** using the platform-specific commands in `dotfile-config.yaml`
4. **First shell launch**: `.zshrc` initializes Oh My Posh prompt, sets env vars (`KUBE_EDITOR=nvim`, `VISUAL=nvim`), runs `neofetch`, and sources Amazon Q / iTerm2 integrations
5. **Neovim first launch**: `init.lua` bootstraps lazy.nvim from GitHub if missing, then loads the AstroNvim v4 distribution with community plugins and user overrides
6. **tmux first launch**: `tmux.conf` installs TPM and the catppuccin theme plugin automatically
7. **VM provisioning**: `ustart()` function in `.zshrc` launches a Multipass Ubuntu VM using `cloud-init.yaml`, which auto-installs zsh, neovim, nushell, and oh-my-posh

## External Dependencies & Integrations

### System-Level (macOS primary)
- **Homebrew** — primary package manager (referenced in aliases and `dotfile-config.yaml`)
- **AeroSpace** — tiling window manager (`.aerospace.toml`)
- **skhd** — hotkey daemon (`.skhdrc`)
- **Multipass** — Ubuntu VM management (`cloud-init.yaml`, `.zshrc` functions)
- **Nushell (nu)** — used for `ls`/`la` aliases (`.zshrc` lines 15-16)
- **Oh My Posh** — cross-platform prompt engine (`.oh-my-posh-theme.json`)
- **neofetch** — system info display on shell start
- **Amazon Q** — AI coding assistant shell integration (`.zshrc` pre/post blocks)
- **iTerm2** — terminal emulator integration (`.zshrc` line 106)

### Neovim Plugin Ecosystem (65 plugins via lazy.nvim)
- **AstroNvim v4** — distribution framework (`AstroNvim/AstroNvim`)
- **AstroCommunity** — community plugin packs (colorschemes: palenight, catppuccin)
- **LSP**: nvim-lspconfig, mason.nvim, mason-lspconfig, mason-null-ls, mason-nvim-dap, none-ls.nvim
- **Completion**: nvim-cmp, cmp-buffer, cmp-nvim-lsp, cmp-path, cmp-dap, cmp_luasnip, LuaSnip, Tabnine
- **AI**: copilot.lua, tabnine-nvim
- **UI**: heirline.nvim, alpha-nvim, neo-tree.nvim, nvim-notify, dressing.nvim, nvim-colorizer, nvim-web-devicons, indent-blankline, nvim-ufo
- **Editing**: nvim-autopairs, nvim-treesitter (+ textobjects, autotag, context-commentstring), gitsigns, Comment.nvim, vim-illuminate, todo-comments
- **Navigation**: telescope.nvim (+ fzf-native), smart-splits, nvim-window-picker
- **Debugging**: nvim-dap, nvim-dap-ui
- **Session**: resession.nvim
- **Utility**: plenary.nvim, which-key, guess-indent, friendly-snippets, presence.nvim, lsp_signature, better-escape

### tmux Plugins (via TPM)
- tmux-plugins/tpm (plugin manager)
- tmux-plugins/tmux-sensible (sane defaults)
- dreamsofcode-io/catppuccin_tmux (theme)

### Applications Referenced in skhd
Goland, Fleet, Zed, Safari, Settings, Ghostty, Mail, Postman, WhatsApp, Finder, Notes, Microsoft Teams, Chrome, Dictionary, Preview, PyCharm Community Edition

## Build / Test / Deploy

There is no traditional build/test/deploy pipeline. The `neovim.yml` file suggests a GitHub Actions workflow for Neovim plugin validation, but it's minimal.

**Deployment is manual** — the `dotfile-config.yaml` serves as documentation for which files go where, but there is no automated stow/symlink script. The `cloud-init.yaml` provides an automated path for VM provisioning only.

The `.sdlc.json` file defines a `sdlc` CLI tool (aliased in `.zshrc` as `run`, `tst`, `build`) that auto-detects project type from manifest files and runs appropriate commands:
- `pom.xml` → `mvn spring-boot:run` / `mvn test` / `mvn package`
- `go.mod` → `go run ./...` / `go test ./...` / `go build .`
- `Cargo.toml` → `cargo run` / `cargo test` / `cargo build`
- `package.json` → `npm run dev` / `npm run test` / `npm run build`
- `build.gradle.kts` → `gradle bootRun` / `gradle test` / `gradle build`

## Code Quality Notes

- **Lua tooling is configured but unused**: `.stylua.toml` (formatter config), `selene.toml` (linter config), and `.neoconf.json` (LSP settings) exist in `nvim/` but most plugin config files are **disabled** with `if true then return end` guards at line 1
- **AstroNvim scaffold**: The nvim config is largely the default AstroNvim v4 template. Only `astroui.lua` (colorscheme = catppuccin) and `community.lua` (two colorscheme imports) have active customizations
- **Duplicate comment blocks**: `dotfile-config.yaml` has the header comment block duplicated (lines 1-16 and 13-33)
- **Typo in AeroSpace config**: Workspace `BROSWER` (line 119) should be `BROWSER`; workspace `MESSAGING` move binding references `MESSAGING` (line 130) but the on-window-detected callback for Finder references `UTILTY` (line 185, missing the second 'I')
- **Zsh function `rmDir`** (line 37) uses `$1` inside an alias which won't work — aliases don't accept positional arguments; should be a function
- **Zsh `commit` function** (lines 41-59) has inconsistent indentation (tabs vs spaces)
- **Hardcoded AWS ARN** in `.oh-my-posh-theme.json` line 117: `arn:aws:eks:eu-west-1:1234567890:cluster/posh` — placeholder or leaked credential context
- **No README.md** at the repository root explaining setup instructions

## Known Pain Points & Technical Debt

1. **No automated deployment**: `dotfile-config.yaml` defines the mapping schema but there's no script (stow, GNU Stow, chezmoi, or custom) to actually symlink files. Deployment is entirely manual.
2. **Most Neovim customizations are disabled**: 5 of 7 plugin config files (`astrocore.lua`, `astrolsp.lua`, `mason.lua`, `treesitter.lua`, `none-ls.lua`, `user.lua`) are gated behind `if true then return end`. The editor runs with near-default AstroNvim settings plus catppuccin theme only.
3. **No backup/rollback strategy**: No Makefile, justfile, or script to safely link dotfiles or revert changes.
4. **macOS-only in practice**: Despite `dotfile-config.yaml` declaring linux/windows install commands, the actual configs (AeroSpace, skhd, iTerm2, Amazon Q, Multipass) are macOS-specific. The cloud-init.yaml is the only Linux-targeted config.
5. **Security concern**: `cloud-init.yaml` line 21 runs `sudo mv` of dotfiles and line 22 appends `exec zsh` to `.bashrc` — this is for personal VMs but the pattern of auto-executing shell changes from a git clone is risky.
6. **Stale references**: `.zshrc` sources `$HOME/fig-export/dotfiles/dotfile.zsh` (line 103) — Fig was acquired by AWS and rebranded to Amazon Q, suggesting this line may be dead code.
7. **Inconsistent tooling**: Uses both Oh My Posh (active) and Powerlevel10k (commented reference in `.zshrc` line 4) — migration may be incomplete.

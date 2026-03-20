# Developer Onboarding: dotfiles

## Technical Stack

This is a **personal macOS dotfiles repository** — not a software project. It contains configuration files for a macOS-centric development environment. The primary platform is macOS (Darwin), with some Linux support via `cloud-init.yaml` for Ubuntu VMs.

**Core tools configured:**
- **Shell:** Zsh with [Oh My Posh](https://ohmyposh.dev/) prompt (JSON theme at `.oh-my-posh-theme.json`)
- **Editor:** Neovim via [AstroNvim v4](https://astronvim.com/) (Lua-based, lazy.nvim plugin manager)
- **Terminal multiplexer:** Tmux with TPM plugin manager and Catppuccin theme
- **Window manager:** [AeroSpace](https://nikitabobko.github.io/AeroSpace/) (i3-like tiling WM for macOS)
- **Hotkey daemon:** [skhd](https://github.com/koekeishiya/skhd) for global macOS keyboard shortcuts
- **File manager:** [Yazi](https://yazi-rs.github.io/) (Rust-based terminal file manager)
- **Editor (secondary):** Zed (`zed/settings.json`)
- **VM management:** Multipass (Ubuntu VMs via `cloud-init.yaml`)
- **CLI helpers:** Custom `sdlc` tool (`.sdlc.json`) for project-type-aware run/test/build commands

**Languages in use (based on prompt theme & aliases):** Go, Java, Rust, Python, Lua, JavaScript/TypeScript.

## Repository Structure

```
.
├── .zshrc                    # Main shell config — aliases, functions, env vars, prompt init
├── .oh-my-posh-theme.json    # Oh My Posh prompt theme (powerline-style, git/java/go/rust/kubectl segments)
├── .aerospace.toml           # AeroSpace tiling WM config (workspaces, keybindings, window rules)
├── .skhdrc                   # skhd global hotkey bindings (ctrl+letter → app launch)
├── .sdlc.json                # Project-type detection map (pom.xml, go.mod, Cargo.toml, etc.)
├── yazi.toml                 # Yazi file manager config (show hidden files)
├── cloud-init.yaml           # Multipass Ubuntu VM provisioning (zsh, neovim, nushell, oh-my-posh)
├── dotfile-config.yaml       # Structured manifest of all dotfiles + install commands per platform
├── nvim/                     # Neovim (AstroNvim v4) configuration
│   ├── init.lua              # Bootstrap: installs lazy.nvim, loads lazy_setup + polish
│   ├── lazy-lock.json        # Pinned plugin versions (~65 plugins)
│   ├── lua/
│   │   ├── lazy_setup.lua    # lazy.nvim setup: AstroNvim v4, community, user plugins
│   │   ├── community.lua     # Community plugin imports (palenight, catppuccin colorschemes)
│   │   ├── polish.lua        # Post-setup hooks (currently disabled)
│   │   └── plugins/
│   │       ├── astroui.lua       # UI config: catppuccin colorscheme, LSP loading icons
│   │       ├── astrocore.lua     # Core: vim options, diagnostics, buffer mappings (DISABLED)
│   │       ├── astrolsp.lua      # LSP: formatting on save, codelens, semantic tokens (DISABLED)
│   │       ├── mason.lua         # Mason: ensure_installed for lua_ls, stylua, python DAP (DISABLED)
│   │       ├── treesitter.lua    # Treesitter parsers: lua, vim (DISABLED)
│   │       ├── none-ls.lua       # null-ls formatters/linters (DISABLED)
│   │       └── user.lua          # Extra plugins: presence.nvim, lsp_signature, alpha dashboard (DISABLED)
├── tmux/
│   └── tmux.conf             # Tmux: true color, Ctrl-Space prefix, TPM + catppuccin theme
└── zed/
    └── settings.json         # Zed editor: font size 16, Atelier Cave Dark theme
```

## Entry Points & Main Flow

There is no "application" to run. The entry points are the config files themselves, loaded by their respective tools:

1. **Shell session:** `.zshrc` is sourced on every new Zsh session. It initializes Oh My Posh, sets env vars (`KUBE_EDITOR=nvim`, `VISUAL=nvim`), defines aliases and helper functions (`commit`, `y` for yazi, `ustart`/`uend` for VMs), and runs `neofetch`.

2. **Neovim:** `nvim/init.lua` bootstraps lazy.nvim (clones from GitHub if missing), then loads `lua/lazy_setup.lua` which configures AstroNvim v4 with community and user plugin specs. The active customization is in `astroui.lua` (catppuccin theme). All other plugin files in `lua/plugins/` are **disabled** via `if true then return {} end` guards.

3. **Tmux:** `tmux/tmux.conf` sets true color, remaps prefix to `Ctrl-Space`, loads TPM with catppuccin theme.

4. **AeroSpace:** `.aerospace.toml` defines 4 named workspaces (CODING, BROWSER, MESSAGING, UTILITY), vim-like navigation (alt+hjkl), and auto-assigns apps to workspaces.

5. **skhd:** `.skhdrc` maps `ctrl+letter` shortcuts to launch specific macOS apps (Goland, Ghostty, Safari, Chrome, etc.).

6. **VM provisioning:** `cloud-init.yaml` is used with `multipass launch --cloud-init` to spin up Ubuntu VMs with a curated dev environment.

## External Dependencies & Integrations

**Required tools (must be installed separately):**
- `zsh` — shell
- `oh-my-posh` — prompt engine (installed via curl script)
- `neovim` (>= 0.9) — editor
- `tmux` + TPM (`tmux-plugins/tpm`) — terminal multiplexer
- `aerospace` — tiling window manager (macOS only)
- `skhd` — hotkey daemon (macOS only)
- `yazi` — file manager
- `multipass` — VM management
- `neofetch` — system info display
- `nushell` (nu) — used for `ls` aliases
- `kubectl` — Kubernetes CLI (aliases + prompt segment)
- `terraform` — IaC tool (aliases)
- `sdlc` — custom CLI tool for project-type-aware commands (run/test/build)
- `ghostty` — terminal emulator (referenced in skhd and aerospace)

**Neovim plugins (managed by lazy.nvim, ~65 total):**
- AstroNvim ecosystem: astrocore, astrolsp, astroui, astrotheme, astrocommunity
- LSP: nvim-lspconfig, mason.nvim, mason-lspconfig, mason-null-ls, mason-nvim-dap
- Completion: nvim-cmp, cmp-buffer, cmp-nvim-lsp, cmp-path, cmp-dap, cmp_luasnip, LuaSnip
- UI: heirline, neo-tree, alpha-nvim, nvim-notify, dressing.nvim, nvim-colorizer, indent-blankline
- Editing: nvim-autopairs, nvim-treesitter, nvim-ts-autotag, gitsigns, Comment.nvim, todo-comments
- Navigation: telescope.nvim, telescope-fzf-native, smart-splits, nvim-window-picker
- DAP: nvim-dap, nvim-dap-ui
- AI: copilot.lua, tabnine-nvim
- Themes: catppuccin, palenight
- Misc: which-key, toggleterm, resession, presence.nvim, lsp_signature, plenary, nvim-ufo

## Build / Test / Deploy

There is no build system. Deployment is manual:

1. Clone the repo
2. Symlink or copy config files to their target locations (`~/.zshrc`, `~/.config/nvim/`, `~/.config/tmux/tmux.conf`, etc.)
3. The `dotfile-config.yaml` file serves as a structured manifest describing where each file should go and what software to install per platform — but there is no automated deployment script in this repo.

For Neovim specifically, lazy.nvim auto-installs plugins on first launch. TPM plugins for tmux are installed via `<prefix>I` (Ctrl-Space then I).

## Code Quality Notes

- **Neovim config is mostly stock AstroNvim v4.** Only `astroui.lua` (colorscheme selection) and `community.lua` (colorscheme imports) are active. All other plugin customization files (`astrocore.lua`, `astrolsp.lua`, `mason.lua`, `treesitter.lua`, `none-ls.lua`, `user.lua`) are disabled with `if true then return {} end` guards. This means the Neovim setup is essentially uncustomized beyond theme choice.
- **`lazy-lock.json` is committed**, providing reproducible plugin versions.
- **`.zshrc` has some issues:** the `commit` function uses `git add .` (stages everything), the `rmDir` alias doesn't work correctly (shell aliases don't take positional arguments via `$1`), and there's commented-out code for a `vm` function with a syntax error (`]]` missing space).
- **`dotfile-config.yaml` has duplicated header comments** (lines 1-16 and 13-33 are near-identical).
- **AeroSpace config has a typo:** workspace `BROSWER` (line 119) vs `BROWSER` used elsewhere (lines 128, 189). Also `UTILITY` (line 120) vs `UTILTY` (line 185).
- **Zed settings** has a likely typo: `ui_front_size` instead of `ui_font_size` (line 2 of `zed/settings.json`).
- **No README.md** exists at the repo root to document setup instructions.

## Known Pain Points & Technical Debt

1. **No automated deployment.** The `dotfile-config.yaml` manifest exists but no script consumes it. Setup is fully manual, which is error-prone and doesn't match the manifest's intent.

2. **Disabled Neovim customizations.** Six plugin config files are disabled with early-return guards. The user likely intended to customize these but hasn't activated them. The `polish.lua` file is also disabled. This means LSP servers, formatters, treesitter parsers, and custom keymaps are all using AstroNvim defaults only.

3. **Shell config quality.** The `.zshrc` mixes concerns (aliases, functions, env vars, tool initialization, neofetch) without organization. The `rmDir` alias is broken. The `commit` function is dangerous (`git add .`).

4. **Typos in configs.** `BROSWER`/`BROWSER` inconsistency in aerospace, `UTILTY`/`UTILITY` inconsistency, `ui_front_size` in Zed settings.

5. **No stow/GNU Stow integration** despite `stow` being installed in the VM cloud-init. The repo structure doesn't follow stow's expected package layout.

6. **Hardcoded paths and values.** The Oh My Posh theme has a hardcoded AWS EKS cluster ARN (`arn:aws:eks:eu-west-1:1234567890:cluster/posh`) as a kubectl context alias. The `.zshrc` references `~/Personal/Golang` as a workspace path.

7. **No `.gitconfig` or `.bashrc`/`.bash_profile`** present despite being listed in `dotfile-config.yaml`. The manifest is aspirational rather than reflective of the repo's actual contents.

8. **Security consideration:** The `cloud-init.yaml` runs `curl | bash` for Oh My Posh installation and clones the dotfiles repo — standard for personal dotfiles but worth noting.

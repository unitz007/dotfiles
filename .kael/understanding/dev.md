# Developer Onboarding: dotfiles

## Technical Stack

This is a **personal dotfiles repository** for a macOS-centric development environment. There is no application code — it is a collection of configuration files, shell scripts, and declarative setup manifests.

- **Shell**: Zsh (primary), with Nushell (`nu`) used for `ls` aliases
- **Terminal prompt**: Oh My Posh (JSON theme at `.oh-my-posh-theme.json`)
- **Window manager**: AeroSpace (i3-like tiling WM for macOS) — config at `.aerospace.toml`
- **Hotkey daemon**: skhd — config at `.skhdrc`
- **Editor (primary)**: Neovim via AstroNvim v4 distribution (Lua-based, lazy.nvim plugin manager)
- **Editor (secondary)**: Zed — config at `zed/settings.json`
- **Terminal multiplexer**: tmux with TPM plugin manager — config at `tmux/tmux.conf`
- **File manager**: Yazi (Rust-based terminal file manager) — config at `yazi.toml`
- **VM provisioning**: Multipass + cloud-init — config at `cloud-init.yaml`
- **Dev tooling shortcuts**: Custom `sdlc` CLI (`.sdlc.json`) for run/test/build commands across Java, Go, Rust, Node, Gradle projects
- **Languages in use** (inferred from prompt theme, aliases, and LSP config): Java, Go, Rust, Python, JavaScript/TypeScript, Terraform
- **Container/infra**: kubectl, Terraform, Docker (referenced in aliases)

## Repository Structure

```
.
├── .aerospace.toml          # AeroSpace tiling WM config (keybindings, workspaces, gaps)
├── .skhdrc                  # skhd hotkey daemon — app launcher shortcuts (ctrl+key)
├── .zshrc                   # Zsh shell config — aliases, functions, env vars, prompt init
├── .oh-my-posh-theme.json   # Oh My Posh prompt theme (powerline, git, kubectl, language versions)
├── .sdlc.json               # Declarative run/test/build commands per project type
├── .gitignore               # Ignores IDE dirs, oh-my-zsh custom, sensitive configs
├── dotfile-config.yaml      # Structured manifest for dotfile deployment (install cmds + file mappings)
├── cloud-init.yaml          # Multipass VM cloud-init for Ubuntu dev environment
├── yazi.toml                # Yazi file manager config (show hidden files)
├── nvim/                    # Neovim (AstroNvim v4) configuration
│   ├── init.lua             # Bootstrap: lazy.nvim installer + entry point
│   ├── lazy-lock.json       # Pinned plugin versions (65 plugins)
│   ├── lazy_setup.lua       # lazy.nvim setup: AstroNvim v4, community, user plugins
│   ├── community.lua        # AstroCommunity imports (palenight, catppuccin colorschemes)
│   ├── polish.lua           # Post-setup hooks (currently disabled)
│   └── lua/plugins/
│       ├── astroui.lua      # UI config — colorscheme set to "catppuccin"
│       ├── astrocore.lua    # Core vim options, diagnostics, buffer mappings (disabled)
│       ├── astrolsp.lua     # LSP config — formatting, codelens, semantic tokens (disabled)
│       ├── mason.lua        # Mason package manager — LSP/formatter/DAP installs (disabled)
│       ├── treesitter.lua   # Treesitter parsers — lua, vim (disabled)
│       ├── none-ls.lua      # null-ls formatter/linter sources (disabled)
│       └── user.lua         # Custom plugins — presence.nvim, lsp_signature, alpha dashboard (disabled)
├── tmux/
│   └── tmux.conf            # tmux config — true color, Ctrl+Space prefix, catppuccin theme
└── zed/
    └── settings.json        # Zed editor — font size 16, Atelier Cave Dark theme
```

## Entry Points & Main Flow

There is no runtime application. The "entry points" are the configuration files consumed by their respective tools:

1. **Shell initialization**: `.zshrc` is sourced on every new Zsh session. It initializes Oh My Posh, sets env vars (`KUBE_EDITOR=nvim`, `VISUAL=nvim`), defines aliases, and sources Amazon Q / iTerm2 integrations.

2. **Neovim initialization**: `nvim/init.lua` → bootstraps lazy.nvim → loads `lazy_setup.lua` → loads AstroNvim v4 + community plugins + user plugins. The active colorscheme is **catppuccin** (set in `astroui.lua`).

3. **Window manager**: `.aerospace.toml` is read by AeroSpace on launch. Defines 4 named workspaces (CODING, BROWSER, MESSAGING, UTILITY), vim-like navigation (alt+hjkl), and auto-assignment rules for specific apps (Goland, Ghostty → CODING; Chrome/Safari → BROWSER; WhatsApp → MESSAGING; Finder → UTILITY).

4. **Hotkey daemon**: `.skhdrc` provides `ctrl+<key>` shortcuts to launch apps (Goland, Fleet, Zed, Safari, Ghostty, Chrome, etc.).

5. **VM provisioning**: `cloud-init.yaml` is used with `multipass launch --cloud-init` to spin up an Ubuntu VM with zsh, neovim, nushell, oh-my-posh, and clones this dotfiles repo.

6. **Dotfile deployment**: `dotfile-config.yaml` is a structured manifest describing which files map where and how to install each tool. This appears designed for a custom deployment script/agent (not present in the repo).

## External Dependencies & Integrations

### System-level (macOS)
- **Homebrew**: Primary package manager (referenced in install commands and `update` alias)
- **AeroSpace**: Tiling window manager for macOS
- **skhd**: macOS hotkey daemon (requires SIP modifications or accessibility permissions)
- **Multipass**: Ubuntu VM manager (Canonical)
- **iTerm2**: Terminal emulator (shell integration sourced in `.zshrc`)
- **Amazon Q**: AI assistant (pre/post block integration in `.zshrc`)

### CLI Tools
- **Oh My Posh**: Cross-platform prompt theme engine
- **Neofetch**: System info display (runs on shell startup)
- **kubectl**: Kubernetes CLI (extensive aliases)
- **Terraform**: Infrastructure as Code (aliases `tf`, `tfp`, `tfa`)
- **Yazi**: Terminal file manager (with shell wrapper function `y()` in `.zshrc`)
- **Nushell**: Used for `ls` and `ls -la` aliases
- **sdlc**: Custom CLI tool for project-type-aware run/test/build commands

### Neovim Plugin Ecosystem (65 plugins via lazy.nvim)
- **AstroNvim v4**: Distribution framework (core, LSP, UI modules)
- **AstroCommunity**: Community plugin packs (palenight, catppuccin colorschemes)
- **Mason**: LSP/formatter/DAP installer
- **nvim-treesitter**: Syntax highlighting
- **nvim-cmp**: Autocompletion (with buffer, path, LSP, DAP, LuaSnip sources)
- **telescope.nvim**: Fuzzy finder
- **nvim-dap / nvim-dap-ui**: Debug adapter protocol
- **neo-tree.nvim**: File explorer
- **gitsigns.nvim**: Git integration
- **copilot.lua + tabnine-nvim**: AI completion
- **presence.nvim**: Discord rich presence
- **toggleterm.nvim**: Terminal integration
- **catppuccin**: Active colorscheme

### tmux Plugins (via TPM)
- **tmux-sensible**: Sensible default settings
- **catppuccin_tmux**: Catppuccin theme for tmux

## Build / Test / Deploy

There is no build system. Deployment is manual:

1. **Clone** the repository
2. **Symlink/copy** files to their target locations (`~/.zshrc`, `~/.config/nvim/`, `~/.aerospace.toml`, etc.)
3. **Install tools** via Homebrew or the commands in `dotfile-config.yaml`
4. **tmux plugins**: Install TPM first (`git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`), then press `prefix + I` inside tmux
5. **Neovim plugins**: Auto-installed on first launch by lazy.nvim

The `cloud-init.yaml` provides an automated path for Ubuntu VM setup via Multipass.

## Code Quality Notes

- **Neovim config**: Well-structured following AstroNvim v4 conventions. Plugin configs are properly separated into `lua/plugins/` files. However, **most plugin override files are disabled** via `if true then return {} end` guards at the top — meaning the Neovim config is running almost entirely on AstroNvim defaults with only the colorscheme override active.
- **Shell config**: Functional but informal — no shellcheck compliance expected. The `commit()` function has a minor inconsistency (missing `then` alignment on line 43). The `rmDir` alias uses `$1` which won't work as expected in an alias (should be a function).
- **AeroSpace config**: Clean, well-commented, follows official documentation structure. Has a typo in workspace name: `BROSWER` (line 119) vs `BROWSER` (lines 128-129, 189).
- **dotfile-config.yaml**: Well-documented with clear structure, but many entries are commented out. The trailing `;` convention for directories is unusual and would need custom parsing logic.
- **No automated testing or linting** for any configuration files.
- **`.sdlc.json`**: Simple and clean mapping of project types to build commands.

## Known Pain Points & Technical Debt

1. **Disabled Neovim customizations**: 6 of 7 plugin config files (`astrocore.lua`, `astrolsp.lua`, `mason.lua`, `treesitter.lua`, `none-ls.lua`, `user.lua`) are completely disabled with `if true then return {} end`. Only `astroui.lua` (colorscheme) is active. This means LSP servers, formatters, treesitter parsers, and custom keybindings are all running on AstroNvim defaults — the config is essentially uncustomized beyond theme.

2. **No deployment automation**: `dotfile-config.yaml` describes a structured deployment format, but there is no script to consume it. Deployment is manual symlink/copy.

3. **macOS-only**: The `.skhdrc` and `.aerospace.toml` configs are macOS-specific. The `dotfile-config.yaml` has multi-platform install commands, but no Linux/BSD window manager configs are present.

4. **Inconsistencies**:
   - `.aerospace.toml` line 119: workspace name `BROSWER` (typo) vs `BROWSER` used elsewhere
   - `.aerospace.toml` line 185: workspace `UTILTY` (typo) vs `UTILITY` on line 120
   - `.zshrc` line 37: `rmDir` alias uses `$1` which doesn't expand in aliases
   - `.zshrc` line 22: `brew upgrade && brew upgrade` is duplicated

5. **Shell startup overhead**: `neofetch` runs on every shell open (line 101), adding latency. Amazon Q and iTerm2 integrations are also sourced unconditionally.

6. **No `.bashrc` / `.bash_profile` / `.gitconfig` / `.vimrc`**: Referenced in `dotfile-config.yaml` as managed files but not present in the repository.

7. **Hardcoded AWS EKS cluster ARN** in `.oh-my-posh-theme.json` line 117 (`arn:aws:eks:eu-west-1:1234567890:cluster/posh`) — this is a context alias, not a credential, but reveals infrastructure details.

8. **Zed settings typo**: `ui_front_size` (line 2 of `zed/settings.json`) should likely be `ui_font_size`.

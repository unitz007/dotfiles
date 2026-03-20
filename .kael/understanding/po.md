# Product Owner Onboarding: dotfiles

## What This Product Does

This is a **personal developer environment configuration repository** (dotfiles) maintained by the GitHub user `unitz007`. It serves as a single source of truth for replicating a consistent, productive macOS-centric development workspace across machines. The repo contains configuration files for shell, terminal multiplexer, window manager, text editors, file manager, and a structured manifest (`dotfile-config.yaml`) that describes how each tool should be installed and which files should be symlinked to their target locations.

The repository also includes a `cloud-init.yaml` for provisioning Ubuntu VMs via Multipass with the same core tooling (zsh, neovim, nushell, oh-my-posh), demonstrating intent for cross-environment consistency.

## Target Users & Personas

**Primary User: The repository owner (`unitz007`)** — a software developer who works across multiple languages (Java, Go, Rust, Python) and platforms (macOS primary, Ubuntu VMs secondary). Evidence:

- Oh-my-posh theme shows Java, Go, and Rust version segments on the right side of the prompt
- `.sdlc.json` defines run/test/build commands for Maven (Java), Go, Cargo (Rust), npm (Node), and Gradle (Java/Kotlin)
- `cloud-init.yaml` provisions Ubuntu VMs with zsh, neovim, nushell
- Kubernetes aliases (`k`, `kgs`, `kgp`, `kgd`, `ka`, `kd`) and kubectl context display in the prompt indicate cloud-native work
- Terraform aliases (`tf`, `tfp`, `tfa`) indicate infrastructure-as-code work
- Amazon Q shell integration blocks in `.zshrc` suggest AWS development context

**Secondary Users: Other developers** who might fork or reference this repo as a starting point for their own dotfiles setup. The `dotfile-config.yaml` manifest with structured install commands and file mappings suggests the owner has considered (or plans to build) automation for dotfile deployment.

## Core Value Proposition

**Zero-friction machine provisioning.** The combination of:
1. A declarative manifest (`dotfile-config.yaml`) mapping software → install commands → config files
2. A cloud-init script for VM bootstrapping
3. A curated set of shell aliases and functions (`commit`, `y`, `ustart`, `uend`, `sdlc run/test/build`)

...means the owner can get a new machine (or VM) to a fully functional development state with minimal manual steps. The value is in **consistency** (same keybindings, same theme, same aliases everywhere) and **speed** (not reconfiguring tools from scratch).

## Key Features (observed)

### Shell Configuration (`.zshrc`)
- **Oh-my-posh** prompt with a custom JSON theme showing: OS icon, shell type, root indicator, working directory, git status (with color-coded branch/ahead/behind/dirty states), and right-aligned Java/Go/Rust versions + kubectl context
- **40+ aliases** covering: git shortcuts (`g`, `gc`, `pull`, `commit`), kubectl (`k`, `kgs`, `kgp`, `kgd`, `ka`, `kd`), terraform (`tf`, `tfp`, `tfa`), navigation (`..`, `h`, `gwp`), and tool shortcuts (`vim`→`nvim`, `ls`→`nu -c ls`)
- **Custom functions**: `commit` (git add + commit + optional push), `y` (yazi file manager with cwd tracking), `ustart`/`uend` (Multipass Ubuntu VM lifecycle)
- **Amazon Q** and **iTerm2** shell integration hooks
- **neofetch** runs on shell startup

### Window Manager (`.aerospace.toml`)
- **AeroSpace** tiling window manager for macOS with i3-inspired keybindings (alt+hjkl for focus, alt+shift+hjkl for move)
- **Named workspaces**: CODING, BROWSER, MESSAGING, UTILITY — with automatic app assignment (GoLand → CODING, Ghostty → CODING, Safari/Chrome → BROWSER, WhatsApp → MESSAGING, Finder → UTILITY)
- **Service mode** with layout reset, floating toggle, flatten, and volume controls
- Mouse-follows-focus behavior, auto-start at login

### Hotkey Daemon (`.skhdrc`)
- **17 application launcher shortcuts** via `ctrl+letter`: Goland, Fleet, Zed, Safari, Settings, Ghostty, Mail, Postman, WhatsApp, Finder, Notes, Teams, Chrome, Dictionary, Preview, PyCharm

### Neovim (`nvim/`)
- **AstroNvim v4** distribution with Lazy.nvim plugin manager
- **Catppuccin** color scheme (with Palenight also available via AstroCommunity)
- **Plugin configuration files** for Mason (LSP/formatter/DAP installer), Treesitter, none-ls, AstroCore, AstroLSP, AstroUI — all currently **disabled** (`if true then return {} end`), suggesting this is a fresh template that hasn't been customized yet
- **User plugins file** includes examples: Discord presence, LSP signatures, custom alpha-nvim dashboard with ASCII art, LuaSnip JS/JSX extension, nvim-autopairs LaTeX rules — also currently disabled
- Leader key: Space, LocalLeader: Comma

### Tmux (`tmux/tmux.conf`)
- True color support, `Ctrl+Space` prefix (replacing default `Ctrl+b`)
- **TPM** (Tmux Plugin Manager) with catppuccin theme

### Zed Editor (`zed/settings.json`)
- Dark theme (Atelier Cave Dark), 16px font sizes for UI and buffer

### File Manager (`yazi.toml`)
- Hidden files shown by default

### SDLC Helper (`.sdlc.json`)
- Maps project manifest files to standard run/test/build commands, used via `sdlc run`, `sdlc test`, `sdlc build` aliases

### VM Provisioning (`cloud-init.yaml`)
- Multipass Ubuntu VM with zsh, unzip, stow, neovim, nushell, oh-my-posh, and clones this dotfiles repo

### Dotfile Manifest (`dotfile-config.yaml`)
- Structured YAML defining 10+ tools (bash, zsh, git, vim, neovim, tmux, alacritty, kitty, starship) with platform-specific install commands (linux/darwin/windows) and file→target mappings
- Commented-out sections for npm, yarn, rust, docker, awscli, kubectl
- Security warning about never including private keys or credentials

## Product Gaps & Opportunities

1. **No automated deployment script.** The `dotfile-config.yaml` manifest is well-structured but there's no script (e.g., a `Makefile`, `install.sh`, or Chezmoi/Stow integration) that actually reads it and performs the symlinks. The `cloud-init.yaml` does manual `mv` commands rather than using the manifest. This is the biggest gap — the manifest is documentation-only today.

2. **Neovim config is entirely template-default.** All five plugin customization files (`astrocore.lua`, `astrolsp.lua`, `astroui.lua`, `mason.lua`, `treesitter.lua`, `none-ls.lua`, `user.lua`, `polish.lua`) are disabled with `if true then return {} end`. The only active customizations are the color scheme (catppuccin) and community color imports. The owner hasn't yet tailored LSP servers, formatters, or keybindings to their actual workflow.

3. **No version pinning for CLI tools.** The install commands use `brew install` without version pinning, which means reproducibility across time is not guaranteed. A `Brewfile` or `nix` flake would solve this.

4. **Missing tool configs referenced in manifest.** The manifest references `.bashrc`, `.bash_profile`, `.bash_aliases`, `.gitconfig`, `.gitignore_global`, `.vimrc`, alacritty config, kitty config, and starship config — none of which exist in the repo. These are either not yet committed or the manifest is aspirational.

5. **No README.md at repo root.** There's no top-level documentation explaining how to use these dotfiles, prerequisites, or installation steps. The nvim subdirectory has a README but the root does not.

6. **Hardcoded paths and values.** The kubectl context alias in the oh-my-posh theme has a hardcoded AWS account ID (`1234567890`). The `commit` function hardcodes `main` as the default push branch. The `ustart` function hardcodes VM specs (4 CPUs, 20G disk, 2G RAM).

7. **No backup/rollback strategy.** There's no script to back up existing dotfiles before linking, which is risky for anyone (including the owner) setting up a new machine.

8. **`sdlc` tool is undefined.** The `.sdlc.json` config and aliases (`run`, `tst`, `build`) reference a `sdlc` CLI tool, but there's no installation step for it anywhere in the repo.

## Suggested Priorities

| Priority | Item | Rationale |
|----------|------|-----------|
| **P0** | Create an `install.sh` or `Makefile` that reads `dotfile-config.yaml` and performs symlinks with backup | Unlocks the core value proposition of the manifest |
| **P0** | Add a root `README.md` with prerequisites, install steps, and tool overview | Essential for the repo to be usable by anyone (including future-self) |
| **P1** | Activate and customize Neovim config — at minimum add Go, Java, Rust LSP servers to Mason's `ensure_installed` | The owner clearly works in these languages; the editor should support them out of the box |
| **P1** | Add missing config files referenced in the manifest (`.gitconfig`, `.bashrc`, alacritty, kitty, starship) or remove them from the manifest | Manifest should match reality |
| **P2** | Create a `Brewfile` (`brew bundle dump`) for reproducible macOS package installation | Complements the manifest with actual version pinning |
| **P2** | Parameterize hardcoded values (AWS account ID, default branch, VM specs) | Makes the configs more portable and shareable |
| **P3** | Add CI/CD validation (e.g., shellcheck for `.zshrc`, luacheck for nvim configs, YAML lint for manifests) | Prevents config drift and syntax errors |
| **P3** | Consider adopting Chezmoi or GNU Stow for dotfile management instead of a custom solution | Battle-tested tooling reduces maintenance burden |

## Risks & Unknowns

- **Secret leakage risk.** The `.gitignore` excludes some sensitive paths (`.config/gh`, `.config/linode-cli`) but the `.zshrc` contains Amazon Q integration paths and the oh-my-posh theme has an AWS account ID. If this repo is public, these could be information leaks. The `dotfile-config.yaml` has a security warning but no enforcement mechanism.

- **macOS lock-in.** AeroSpace and skhd are macOS-only. The `.zshrc` references macOS-specific paths (`~/Library/Application Support/amazon-q/`). The `cloud-init.yaml` only provisions the shell layer, not the full experience. The repo is fundamentally a macOS-first setup with partial Linux support.

- **`sdlc` tool dependency.** Three shell aliases depend on a `sdlc` CLI that has no installation instructions or source reference in the repo. If this tool is lost or unmaintained, those aliases break silently.

- **Template vs. active config ambiguity.** The Neovim configuration is clearly an AstroNvim template with zero customization active. It's unclear whether the owner uses Neovim daily (with just the defaults) or primarily uses other editors (Goland, Zed, Fleet — all bound in skhdrc). The Zed config is minimal (just font size and theme), suggesting it may also be freshly set up.

- **No testing.** There are no tests to verify that configs are syntactically valid, that symlinks would resolve correctly, or that the cloud-init script produces a working environment. A bad commit could break the owner's workflow on the next machine setup.

# Product Owner Onboarding: dotfiles

## What This Product Does

This is a **personal developer environment configuration repository** (dotfiles) that provides a reproducible, version-controlled setup for a macOS-centric software engineer's entire development workflow. It covers the full stack from shell prompt to window manager, editor, terminal multiplexer, and cloud VM provisioning.

The repository serves two distinct "products":

1. **Local dev environment bootstrap** — A collection of config files for zsh, Neovim (AstroNvim v4), tmux, AeroSpace (tiling window manager), skhd (hotkey daemon), Yazi (file manager), Zed editor, and oh-my-posh (shell prompt). These are deployed to `~/` and `~/.config/` on macOS.

2. **Cloud VM provisioning** — A `cloud-init.yaml` that spins up an Ubuntu VM via Multipass, pre-installs zsh, neovim, nushell, and oh-my-posh, then clones this very repo and symlinks the shell config — giving the user a consistent shell experience in ephemeral Linux VMs.

A structured manifest (`dotfile-config.yaml`) describes each tool, its platform-specific install commands (Linux/macOS/Windows), and the files to sync — designed to be consumed programmatically by a "dotfile agent."

## Target Users & Personas

**Primary Persona: The Author (unitz007)**

A full-stack/backend software engineer who:
- Works primarily on **macOS** (evidence: AeroSpace, skhd, Homebrew, iTerm2 shell integration, Amazon Q CLI integration)
- Codes in **Go, Java, Rust, and JavaScript/TypeScript** (evidence: oh-my-posh segments for Java/Go/Rust, `.sdlc.json` mappings for Maven/Gradle/Cargo/npm/Go, Golang workspace alias)
- Operates **Kubernetes clusters and Terraform infrastructure** (evidence: kubectl aliases, `tf`/`tfp`/`tfa` aliases, kubectl context in oh-my-posh prompt, `KUBE_EDITOR=nvim`)
- Uses **AWS** (evidence: Amazon Q integration, EKS cluster reference in oh-my-posh config)
- Values **keyboard-driven workflows** (evidence: AeroSpace vim-style tiling, skhd hotkeys for 15+ apps, tmux with Ctrl-Space prefix)
- Prefers **modern Rust-based CLI tools** (evidence: Yazi file manager, Ghostty terminal, Nushell for `ls`)

**Secondary Persona: Developers who fork this repo**

The `dotfile-config.yaml` manifest and `cloud-init.yaml` suggest intent for the repo to be reusable by others, though it is currently personalized (specific app IDs, EKS cluster names, Golang workspace paths).

## Core Value Proposition

**"One clone, fully configured."** The repository eliminates the hours of manual configuration typically required when setting up a new machine or VM. It encodes years of ergonomic refinement into version-controlled, declarative configs that can be reproduced in minutes.

Key value pillars:
- **Reproducibility** — `cloud-init.yaml` proves the concept: a fresh Ubuntu VM is fully configured with one `multipass launch` command.
- **Ergonomic velocity** — Every alias, hotkey, and workspace rule reduces friction. The `commit` function, `sdlc` aliases, and AeroSpace workspace auto-assignment (GoLand → CODING, Safari → BROWSER) are force multipliers.
- **Cross-tool consistency** — Catppuccin theme in both Neovim and tmux; oh-my-posh prompt shows git status, k8s context, and language versions at a glance.

## Key Features (observed)

### Shell Environment (`.zshrc`)
- **oh-my-posh prompt** with segments: OS icon, shell type, root indicator, full path, git status (with color-coded branch state: yellow for dirty, purple for ahead, orange for diverged), Java/Go/Rust version, and kubectl context/namespace
- **40+ aliases** covering git (`g`, `gc`, `pull`, `commit`), kubectl (`k`, `kgs`, `kgp`, `kgd`, `ka`, `kd`), terraform (`tf`, `tfp`, `tfa`), and navigation (`..`, `h`, `gwp`)
- **Custom `commit()` function** — `commit "message" -p [branch]` does `git add .`, `git commit`, and optionally `git push`
- **Custom `y()` function** — Wraps Yazi file manager with cwd tracking (changes directory on exit)
- **VM lifecycle functions** — `ustart()` and `uend()` for Multipass Ubuntu VM management
- **Amazon Q CLI integration** (pre/post blocks)
- **Nushell integration** — `ls` and `la` aliased to `nu -c ls`

### Window Management (`.aerospace.toml`)
- **AeroSpace tiling WM** with vim-style navigation (alt+h/j/k/l)
- **4 named workspaces**: CODING, BROWSER, MESSAGING, UTILITY
- **Auto-assignment rules**: GoLand and Ghostty → CODING, Safari and Chrome → BROWSER, WhatsApp → MESSAGING, Finder → UTILITY (floating)
- **Service mode** with layout reset, floating toggle, flatten, and volume controls

### Global Hotkeys (`.skhdrc`)
- **17 ctrl-key shortcuts** to launch apps: Goland (ctrl-g), Ghostty (ctrl-t), Zed (ctrl-z), Chrome (ctrl-h), Safari (ctrl-b), Postman (ctrl-p), Teams (ctrl-i), etc.

### Editor — Neovim (`nvim/`)
- **AstroNvim v4** distribution with Lazy.nvim plugin manager
- **Catppuccin** colorscheme (also Palenight available via AstroCommunity)
- **Community plugins**: catppuccin and palenight color schemes
- **Plugin configs mostly at defaults** — `user.lua`, `mason.lua`, `none-ls.lua`, `treesitter.lua`, `astrocore.lua`, `astrolsp.lua` are all still guarded by `if true then return {} end` (template state, not yet customized)
- **Active customizations**: Space leader key, comma localleader, relative line numbers, format-on-save enabled, autopairs, diagnostics with virtual text

### Editor — Zed (`zed/settings.json`)
- Dark theme (Atelier Cave Dark), font size 16

### Terminal Multiplexer (`tmux/tmux.conf`)
- **Ctrl-Space** prefix (matching no conflict with AeroSpace's alt-based bindings)
- True color support
- TPM plugin manager with catppuccin theme

### File Manager (`yazi.toml`)
- Hidden files shown by default

### Dev Workflow Tooling (`.sdlc.json`)
- Maps project manifest files to run/test/build commands: `pom.xml` → Maven, `go.mod` → Go, `Cargo.toml` → Cargo, `package.json` → npm, `build.gradle.kts` → Gradle
- Exposed via shell aliases: `run` → `sdlc run`, `tst` → `sdlc test`, `build` → `sdlc build`

### Dotfile Management (`dotfile-config.yaml`)
- Structured YAML manifest with software name, platform-specific install commands, and file mappings
- Supports Linux, macOS (darwin), Windows, FreeBSD, OpenBSD
- Includes commented-out entries for npm, yarn, Rust, Docker, AWS CLI, kubectl
- Security warning about never committing secrets

### Cloud VM Provisioning (`cloud-init.yaml`)
- Multipass Ubuntu VM with zsh, neovim, nushell, stow, unzip
- Auto-clones this repo and deploys `.zshrc` and oh-my-posh theme
- Drops into zsh by default

## Product Gaps & Opportunities

### 1. No Automated Bootstrap Script
The `dotfile-config.yaml` describes what to install and where to put files, but there is **no script that actually executes this manifest**. Deploying to a new machine requires manual steps. A `bootstrap.sh` or `install.sh` that reads the YAML and performs installations + symlinks would close the loop.

### 2. Neovim Configs Are Mostly Untouched
Five of six plugin config files (`user.lua`, `mason.lua`, `none-ls.lua`, `treesitter.lua`, `astrocore.lua`, `astrolsp.lua`) are still in AstroNvim's template state with `if true then return {} end` guards. The editor is functional but not personalized. This is low-hanging fruit for productivity gains — adding language servers for Go, Java, Rust, and Terraform would align the editor with the user's actual tech stack.

### 3. No Git Config Present
`dotfile-config.yaml` references `.gitconfig` and `.gitignore_global`, but neither file exists in the repo. These are likely in `.gitignore` or simply missing.

### 4. No Stow/GNU Stow Integration
`cloud-init.yaml` installs `stow`, and the `dotfile-config.yaml` manifest has a structure that would work well with GNU Stow, but no Stow packages or stow commands are present. The repo structure doesn't follow Stow's package convention (e.g., `stow/nvim/.config/nvim/`).

### 5. macOS-Only Tooling Without Linux Parity
AeroSpace and skhd are macOS-exclusive. The `dotfile-config.yaml` has no entries for i3/Sway or equivalent Linux tiling WMs. A developer switching between macOS and Linux (or using the Multipass VM for real work) would lose the window management and hotkey experience.

### 6. No Secrets Management Strategy
The security warning in `dotfile-config.yaml` mentions not committing secrets, but there's no tooling (e.g., age, SOPS, git-crypt) to actually manage sensitive configs that vary per machine.

### 7. No Version Pinning for CLI Tools
Homebrew, curl-pipe-sh installers, and snap installs are all unpinned. A `Brewfile` or `nix` flake would provide reproducibility.

### 8. Typo in AeroSpace Config
Line 185: `run = 'move-node-to-workspace UTILTY'` — missing an 'I' (should be `UTILITY`). Line 129 has the correct spelling.

## Suggested Priorities

| Priority | Item | Effort | Impact |
|----------|------|--------|--------|
| **P0** | Fix `UTILTY` typo in `.aerospace.toml` | Trivial | Prevents workspace misassignment for Finder |
| **P1** | Create `bootstrap.sh` that reads `dotfile-config.yaml` and automates install + symlink | Medium | Unlocks the core value prop: one-command setup |
| **P1** | Activate Neovim plugin configs — add Go (`gopls`), Java (`jdtls`), Rust (`rust-analyzer`), Terraform (`terraform-ls`) to Mason | Low | Massive editor productivity gain |
| **P2** | Add `.gitconfig` and `.gitignore_global` to the repo | Low | Completes the git experience |
| **P2** | Add a `Brewfile` for macOS package pinning | Low | Reproducible Homebrew installs |
| **P3** | Add Linux tiling WM config (i3/sway) for parity with AeroSpace | Medium | Consistent experience across macOS and Linux VMs |
| **P3** | Integrate GNU Stow or adopt a symlink manager | Medium | Cleaner dotfile deployment |
| **P4** | Add secrets management (e.g., age-encrypted files) | Medium | Safe multi-machine use |

## Risks & Unknowns

1. **Single-user maturity** — This repo is clearly personal and in active evolution. Several configs are template-default. The "product" is the developer's own workflow, not a shared tool. Any effort to generalize should be weighed against the maintenance burden.

2. **Amazon Q / Fig dependencies** — The `.zshrc` sources Amazon Q pre/post blocks and a Fig export file. If these tools are uninstalled, the shell will silently degrade (no error, but missing features). No fallback or guard clauses exist.

3. **`sdlc` CLI is external** — The `run`, `tst`, `build` aliases depend on a `sdlc` CLI tool that is not installed or documented in this repo. If it's a custom tool, it should be included or documented.

4. **Nushell as `ls`** — Aliasing `ls` to `nu -c ls` changes output format and flags. This could break scripts or muscle memory. The alias is global with no opt-out.

5. **No CI/CD validation** — There are no tests, linting, or pre-commit hooks to validate that configs are syntactically correct (e.g., TOML lint for `.aerospace.toml`, Lua check for Neovim configs). A broken push could leave the developer with a non-functional environment on next clone.

6. **Cloud-init hardcodes repo URL** — `cloud-init.yaml` clones `https://github.com/unitz007/dotfiles.git` and copies files with `sudo mv`. If the repo structure changes, the VM provisioning breaks silently.

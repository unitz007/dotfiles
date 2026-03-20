# Product Owner Onboarding: dotfiles

## What This Product Does

This is a **personal developer environment configuration repository** (dotfiles) maintained by a single developer (`unitz007`). It serves as a portable, version-controlled blueprint for reproducing a consistent macOS-centric development environment across machines. The repo captures shell configuration, terminal emulator settings, window manager tiling rules, editor setup, and cloud VM provisioning — all in one place.

The repository also includes a **structured manifest** (`dotfile-config.yaml`) that describes each piece of software, its cross-platform installation commands, and which config files to symlink — suggesting an aspiration toward an automated provisioning agent or script.

## Target Users & Personas

**Primary Persona: The Author (unitz007)**
- A full-stack/cloud developer working primarily on **macOS** (evidence: Homebrew, AeroSpace, iTerm2, Ghostty, skhd, Amazon Q CLI integration).
- Works with **Go, Java, Rust, Python, and JavaScript/TypeScript** (evidence: oh-my-posh theme segments for Java/Go/Rust, `.sdlc.json` covering Maven/Gradle/npm/Cargo/go.mod, `gwp` alias for Golang workspace).
- Uses **Kubernetes** heavily (kubectl aliases, kube context in prompt, `KUBE_EDITOR=nvim`).
- Uses **Terraform** (tf/tfp/tfa aliases).
- Leverages **AI coding assistants** (Amazon Q shell integration blocks in `.zshrc`).

**Secondary Persona: New Machine Setup**
- The `cloud-init.yaml` and `dotfile-config.yaml` suggest the author provisions Ubuntu VMs (via Multipass) and wants them bootstrapped with the same shell/prompt setup quickly.

**Tertiary Persona: Other Developers (Potential)**
- The structured `dotfile-config.yaml` with platform-specific install commands hints at a desire to share or open-source this setup, though it currently contains no README or installation instructions.

## Core Value Proposition

1. **Zero-friction machine provisioning** — Clone the repo, run a few commands (or let cloud-init do it), and get a fully configured dev environment.
2. **Muscle-memory preservation** — Consistent keybindings across tools: vim-style hjkl navigation in AeroSpace (tiling WM), tmux prefix (`Ctrl-Space`), and neovim leader (`Space`).
3. **Context-aware terminal** — Oh-My-Posh prompt shows OS, shell, git status (with color-coded dirty/ahead/behind), active language versions (Java/Go/Rust), and current Kubernetes context/namespace at a glance.
4. **Rapid app launching** — `skhd` provides single-key shortcuts (`ctrl+g` for GoLand, `ctrl+z` for Zed, `ctrl+t` for Ghostty, etc.) to eliminate app-switching friction.

## Key Features (observed)

### Shell Environment (`.zshrc`)
- **Oh-My-Posh** prompt with custom theme (`.oh-my-posh-theme.json`) showing git status, language versions, and k8s context
- **40+ aliases** covering git, kubectl, terraform, navigation, and a custom `sdlc` wrapper for polyglot project commands
- **Custom functions**: `commit()` (git add + commit + optional push), `y()` (yazi file manager with cwd tracking), `ustart()`/`uend()` (Multipass Ubuntu VM lifecycle)
- **Amazon Q CLI** integration (pre/post blocks)
- **Nushell** used for `ls` commands (`alias ls="nu -c ls"`)

### Window Management (`.aerospace.toml`)
- **AeroSpace** tiling window manager with vim-style hjkl focus/move bindings
- Named workspaces: `CODING`, `BROWSER`, `MESSAGING`, `UTILITY`
- Auto-assignment rules: GoLand → CODING, Ghostty → CODING, Safari/Chrome → BROWSER, WhatsApp → MESSAGING, Finder → UTILITY
- Service mode with layout reset, floating toggle, volume controls

### App Launcher (`.skhdrc`)
- 17 single-key shortcuts (`ctrl+letter`) for launching apps: GoLand, Fleet, Zed, Safari, Ghostty, Mail, Postman, WhatsApp, Finder, Notes, Teams, Chrome, Dictionary, Preview, PyCharm

### Editor — Neovim (`nvim/`)
- **AstroNvim v4** distribution with Lazy.nvim plugin manager
- Community plugins: **Palenight** and **Catppuccin** color schemes
- LSP support via Mason (lua_ls pre-configured), format-on-save enabled
- Treesitter for Lua and Vim
- All customization files (`astrocore.lua`, `astrolsp.lua`, `mason.lua`, `treesitter.lua`, `none-ls.lua`, `user.lua`, `polish.lua`) are **disabled** (`if true then return {} end`) — the editor runs on AstroNvim defaults with only color scheme additions active

### Editor — Zed (`zed/settings.json`)
- Minimal config: 16px font, dark mode with "Atelier Cave Dark" theme

### Terminal Multiplexer (`tmux/tmux.conf`)
- True color support, `Ctrl-Space` prefix (matching neovim leader)
- TPM plugin manager with **Catppuccin** tmux theme

### File Manager (`yazi.toml`)
- Yazi configured to show hidden files by default

### VM Provisioning (`cloud-init.yaml`)
- Multipass Ubuntu VM setup with zsh, neovim, nushell, oh-my-posh, and dotfiles auto-deployed from GitHub

### Polyglot Build Runner (`.sdlc.json`)
- Maps project manifest files to run/test/build commands for Maven, Gradle, Go, Cargo, and npm
- Used via `sdlc run`, `sdlc test`, `sdlc build` aliases

### Dotfile Manifest (`dotfile-config.yaml`)
- Structured YAML describing 9 active software entries (bash, zsh, git, vim, neovim, tmux, alacritty, kitty, starship) and 6 commented-out entries (npm, yarn, rust, docker, awscli, kubectl)
- Each entry has platform-specific install commands (linux/darwin/windows) and file mapping with source path and target location

## Product Gaps & Opportunities

1. **No README or onboarding documentation** — A new user (or the author on a fresh machine) has no instructions on how to install or deploy these dotfiles. The `dotfile-config.yaml` manifest exists but no script consumes it.

2. **No automated deployment script** — The `dotfile-config.yaml` is a well-structured spec waiting for an implementation. Building a `install.sh` or `stow`-based script that reads this manifest would unlock the core value proposition.

3. **Neovim customizations are all disabled** — Every plugin config file in `nvim/lua/plugins/` has `if true then return {} end` at the top. The editor runs on AstroNvim defaults only. This suggests either early-stage setup or intentional minimalism, but the commented-out examples (presence.nvim, lsp_signature, custom alpha dashboard with "UNITZ" ASCII art) indicate intended future customization.

4. **Missing dotfiles referenced in manifest** — The manifest references `.bashrc`, `.bash_profile`, `.bash_aliases`, `.gitconfig`, `.gitignore_global`, `.vimrc`, `.tmux.conf`, and various `~/.config/` directories that don't exist in the repo. Only a subset of the declared software actually has config files present.

5. **No version pinning** — Software installations use `brew install` without version locks. Reproducibility degrades over time.

6. **Security: AWS EKS cluster ARN in prompt theme** — `.oh-my-posh-theme.json` line 117 contains `arn:aws:eks:eu-west-1:1234567890:cluster/posh` as a kubectl context alias. While the account ID appears placeholder-ish, this pattern risks leaking real infrastructure details if the repo were made public.

7. **No stow/symlink management** — Despite `stow` being installed in the cloud-init VM, there's no GNU Stow package structure (no `stow/` directory with per-package subdirectories). Files are flat in the repo root.

8. **Inconsistent tooling choices** — Multiple terminal emulators configured (Alacritty, Kitty, Ghostty, iTerm2) but no config files present for Alacritty or Kitty. Multiple editors (Neovim, Zed, GoLand, Fleet, PyCharm) but only Neovim and Zed have configs.

## Suggested Priorities

| Priority | Item | Rationale |
|----------|------|-----------|
| **P0** | Write a README with install/bootstrap instructions | Without this, the repo fails its primary purpose of reproducibility |
| **P0** | Build an install script that consumes `dotfile-config.yaml` | The manifest exists but nothing uses it — this is the core automation gap |
| **P1** | Add missing dotfiles or remove them from the manifest | `.bashrc`, `.gitconfig`, `.vimrc`, alacritty/kitty configs are declared but absent |
| **P1** | Activate or remove disabled neovim configs | The "UNITZ" dashboard and LSP signature plugins are clearly desired but gated behind `return {}` |
| **P2** | Add GNU Stow structure for clean symlinking | `stow` is already a dependency; reorganizing into `stow/zsh/`, `stow/nvim/`, etc. would enable `stow */` |
| **P2** | Pin software versions in install commands | Use `brew install package@version` or a Brewfile for reproducibility |
| **P3** | Add a `Makefile` or `Justfile` for common operations | `just bootstrap`, `just update`, `just vm-up` would formalize the ad-hoc functions in `.zshrc` |
| **P3** | Remove or anonymize the AWS ARN from the prompt theme | Security hygiene for any future public sharing |

## Risks & Unknowns

- **macOS lock-in**: Heavy reliance on Homebrew, AeroSpace, skhd, and Multipass makes this nearly unusable on Linux or Windows as-is, despite the `dotfile-config.yaml` claiming multi-platform support.
- **No testing**: There are no tests, CI/CD, or linting. A broken alias or config change ships directly.
- **Cloud-init hardcodes GitHub URL**: `cloud-init.yaml` clones from `https://github.com/unitz007/dotfiles.git` — if the repo moves or goes private, VM provisioning breaks silently.
- **Oh-My-Posh + Powerlevel10k conflict**: `.zshrc` comments reference "Powerlevel10k instant prompt" but the actual prompt is Oh-My-Posh. This is a stale comment from a previous setup that could confuse future debugging.
- **`rmDir` alias is dangerous**: `alias rmDir="rm -rf $1"` — shell aliases don't accept arguments this way; `$1` will always be empty, making this equivalent to `rm -rf` in the current directory. This is a data-loss risk.
- **No backup strategy**: There's no mechanism to back up existing dotfiles before symlinking, risking loss of machine-specific configurations during setup.

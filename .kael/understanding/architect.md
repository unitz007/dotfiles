# Architect Understanding: dotfiles
## High-Level Architecture
The repository is a *declarative dot‑file bundle* that configures a developer workstation.  It is composed of:

```
root/
├── dotfile-config.yaml        # declarative install spec + list of files to stow
├── dotfiles directory tree   # actual configuration fragments
├── .zshrc, .oh‑my‑posh‑theme.json  # global shell config
├── nvim/                     # Neovim + AstroNvim lazy‑plugin manifest
├── tmux/                     # tmux config + tpm bootstrap
├── yazi.toml                  # file‑manager settings
├── cloud‑init.yaml            # cloud‑init for VMs
└── .kael/... (docs & tooling)
```

- **Installation Engine** – Reads `dotfile‑config.yaml`, runs platform‑specific package managers (apt, brew, choco) and uses GNU `stow` to symlink the dot‑file fragments into $HOME.
- **Runtime Configuration** – The dot‑files control the behaviour of user‑level tools: shells, editors, terminals, multiplexers, and file managers.
- **Self‑bootstrap** – `cloud-init.yaml` demonstrates how the config can be applied automatically in a VM – it clones the repo, installs base packages, copies the files and runs `oh‑my‑posh` install.

The system is intentionally *stateless*: the repo contains only immutable resource descriptors; side‑effects happen only during the bootstrap phase.

---
## Component Responsibilities
| Component | Responsibility | Key Files | Notes |
|---|---|---|---|
| `dotfile‑config.yaml` | Declarative spec of required binaries and target file paths. | `dotfile-config.yaml` | Provides cross‑platform install commands, ensures repeatable sync via `stow`. |
| GNU `stow` | Symlink dot‐files into `$HOME`. | `.stow/…` (implicit) | Not part of repo, assumed installed. |
| Shell (`zsh`, `bash`) | Interactive session, alias definition, functions (`commit`, `y`, `ustart`). | `.zshrc`, `.oh‑my‑posh‑theme.json` | Uses `oh-my-posh` for prompt, `nushell`‐style aliases. |
| Neovim | Editor, LSP, plugins via Lazy & AstroNvim. | `nvim/init.lua`, `lua/lazy_setup.lua`, `lua/plugins/…` | Lazy loads AstroNvim, user plugins in `nvim/lua/plugins/user.lua`. |
| tmux | Terminal multiplexing & keybindings. | `tmux/tmux.conf` | Uses `tpm`, `catppuccin_tmux`. |
| yazi | Terminal‑based file manager. | `yazi.toml` | Minimal config – show hidden files. |
| Cloud‑init | Bootstrap an Ubuntu instance. | `cloud-init.yaml` | Pastes config into HOME after installation. |
| `.kael` | Metadocs & CI tooling (PoMs). | `.kael/understanding/…` | Contains product‑owner view. |

---
## Data Flow
```
┌────────────────────┐
│  User sources repo │
└─────────┬──────────┘
          │ clone
          ▼
┌────────────────────┐
│  dotfile‑config.yaml│ = list of publishable assets + install cmds
└───────┬────────────┘
        │ render
        ▼
┌────────────────────┐
│  install platforms│ (apt, brew, choco) – side‑effects on host
└───────┬────────────┘
        │ dependencies
        ▼
┌────────────────────┐
│  GNU stow executes │ symlinks from dotfile fragments
└───────┬────────────┘
        │ symlinks
        ▼
┌────────────────────┐
│  $HOME layout       │ (.zshrc, .config/...)
└────────────────────┘
```

During **bootstrap**:
1. `apt/brew/choco` installs packages.
2. `stow` places config files.
3. Remote scripts (`oh-my-posh`, `powerlevel10k`) are executed in cloud-init.
4. User launches shells, `zsh` sources `.zshrc`, which pulls in imported configs.

No explicit API layer exists between components; the system is driven by declarative data and shell scripts.

---
## API Surface & Contracts
| Element | Interface | Contract |
|---|---|---|
| `dotfile-config.yaml` | YAML | Validates presence of `software`, `install`, `files` fields. `install` may be scalar or mapping per platform. `files` contain `path` (relative to repo root) and `target` (relative to `$HOME`). |
| `stow` | `stow -t $HOME <stow‑dir>` | Produces symlinks; assumes `stow -R` for recursive; symlinks must be idempotent. |
| `cloud-init.yaml` | YAML | Follows standard `cloud-init` schema; `runcmd` runs post‑setup. |
| Plugin manifests (`lazy_setup.lua`, `plugins/*.lua`) | Lua tables | Must return LazySpec; dependencies listed by `import` key. |
| Shell scripts | sh/bash | Use `$HOME`, `$VENDOR` env; no side‑effects beyond idempotent package installs. |

---
## Scalability & Performance Considerations
| Area | Current State | Recommendation |
|---|---|---|
| Bootstrap time | ~30 s for apt + stow | Parallelize installs; cache packages; use `sudo apt-get -y --no-install-recommends`. |
| Disk usage | The dotfile tree ~10 KB | Keep lean; separate theme repo for large assets. |
| Idempotency | Manual symlinks | Use `stow -R` and add guard `if [ ! -L ~/.config ]; then stow -t ~/. config .; fi`. |
| Multi‑OS support | Explicit mapping in `dotfile-config.yaml` | Add macro `install: all: <cmd>` and platform detection script. |
| Feature churn | Manual modifications in many places | Adopt a configuration generator (e.g., Python script that flattens dotfiles into stow layout). |

---
## Security Posture
| Concern | Current Handling | Mitigations |
|---|---|---|
| Sensitive files | Explicitly excluded via comments in `dotfile-config.yaml` | Enforce file‑level .gitignore & LFS; require manual inclusion via separate private repo. |
| Remote scripts | `curl | sh` (oh‑my‑posh, starship) | Prefer use of signed installers; verify checksums. |
| Privilege escalation | `sudo` used in cloud‑init; apt installation | Run bootstrap in user context, only `sudo` for specific packages. |
| Data leakage | None | Ensure `stow` does not expose intermediate paths through debug output. |

---
## Structural Improvement Suggestions
1. **Add a Dependency Installer** – A small Go/Python wrapper that parses `dotfile-config.yaml`, runs platform‑specific commands, and reports missing packages.
2. **Central Theme Engine** – Store theme colors in a single JSON/YAML file; generate `alacritty.toml`, `kitty.conf`, `tmux.conf`, `oh‑my‑posh-theme.json` from it.
3. **Versioned Sync** – Use Git tag or semantic version to match dotfile revision when syncing with a host.
4. **Integrated CI** – Run `dotfiles` build on GitHub Actions: lint YAML, run `stow --check`, verify all symlinks.
5. **Cleaner File Structure** – Separate `stow/` directories per component (bash, zsh, nvim, tmux) instead of a flat folder.
6. **Avoid Hardcoded Paths** – Use `$HOME/.config` anchors; offer `$DOTFILES` env variable to point at repo.
7. **Automated Backup** – Script that packages current $HOME config state and pushes to a backup bucket.

---

*This document captures the system’s architecture, responsibilities, and areas for enhancement from a principal architect’s perspective.*

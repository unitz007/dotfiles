# Project Name

[![CI Status](https://github.com/yourusername/yourrepo/actions/workflows/ci.yml/badge.svg)](https://github.com/yourusername/yourrepo/actions)

## Table of Contents

- [Project Purpose](#project-purpose)
- [Supported Platforms](#supported-platforms)
- [Quick‑Start Installation](#quick-start-installation)
- [Components Overview](#components-overview)
  - [Zsh](#zsh)
  - [Fish](#fish)
  - [Neovim](#neovim)
  - [Fonts](#fonts)
  - [PowerShell](#powershell)
  - [Secrets Management](#secrets-management)
- [Interactive Installer](#interactive-installer)
- [Running the CI Locally](#running-the-ci-locally)
- [Contributing](#contributing)
  - [Branching Model](#branching-model)
  - [Pull‑Request Template](#pull-request-template)
  - [Linting & Formatting](#linting--formatting)
- [License](#license)

## Project Purpose

This repository provides a **personal development environment** that can be provisioned on any supported platform with a single command. It bundles:

- Shell configurations for **zsh** and **fish**
- A curated **Neovim** setup with plugins and LSP support
- A collection of **programming fonts**
- PowerShell profile customizations
- Secure handling of secrets (API keys, tokens, etc.)

The goal is to make onboarding new machines fast, reproducible, and maintainable.

## Supported Platforms

| Platform | Tested Versions |
|----------|-----------------|
| macOS    | 12.x – 14.x |
| Linux (Debian/Ubuntu) | 20.04, 22.04 |
| Windows (via WSL2) | 10, 11 |
| WSL2 (Ubuntu) | 20.04, 22.04 |

> **Note:** The installer detects the host OS and applies the appropriate configuration steps.

## Quick‑Start Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/yourrepo.git
cd yourrepo

# Run the interactive installer (recommended)
./install.sh
```

The installer will:

1. Detect your OS.
2. Prompt you for optional components (e.g., fonts, PowerShell).
3. Install required packages via the system package manager.
4. Symlink configuration files into your home directory.
5. Verify the installation.

If you prefer a non‑interactive install, see the **Interactive Installer** section below.

## Components Overview

### Zsh

- **`.zshrc`** – loads `oh-my-zsh`, custom aliases, and theme.
- **Plugins** – `git`, `docker`, `kubectl`, `fzf`, etc.
- **Theme** – `powerlevel10k` (auto‑configured).

### Fish

- **`config.fish`** – sets up `fish` with `fisher` plugins.
- **Plugins** – `bass`, `z`, `peco`, `bobthefish` theme.

### Neovim

- **`init.lua`** – Lua‑based configuration.
- **Plugin manager** – `packer.nvim`.
- **Key plugins** – `nvim‑lspconfig`, `telescope.nvim`, `treesitter`, `lualine`, `which-key`.

### Fonts

- **Nerd Fonts** – `FiraCode Nerd Font`, `Hack Nerd Font`.
- Installation scripts download and install the fonts system‑wide.

### PowerShell

- **`Microsoft.PowerShell_profile.ps1`** – loads `posh-git`, `oh-my-posh`, and custom functions.
- Works on Windows PowerShell 7+ and PowerShell Core on macOS/Linux.

### Secrets Management

- **`.env.example`** – template for environment variables.
- **`scripts/load_secrets.sh`** – loads secrets from an encrypted vault (e.g., `git‑crypt` or `age`).

## Interactive Installer

The installer (`install.sh`) is a Bash script that guides you through a step‑by‑step setup.

```bash
./install.sh
```

Features:

- **OS detection** – automatically selects the correct package manager (`brew`, `apt`, `pacman`, etc.).
- **Component selection** – choose which parts of the environment you want (e.g., only Neovim and fonts).
- **Dry‑run mode** – preview actions without making changes (`./install.sh --dry-run`).
- **Rollback** – on failure, the script attempts to revert changes.

All prompts are colour‑coded for clarity. The script logs its actions to `install.log` in the repository root.

## Running the CI Locally

The CI pipeline uses GitHub Actions and runs the following jobs:

1. **Linting** – `shellcheck`, `markdownlint`, `stylua`.
2. **Tests** – unit tests for any scripts (via `bats-core`).
3. **Build** – packaging of fonts and verification of symlinks.

To run the same checks locally:

```bash
# Install required tools (once)
./scripts/setup_ci_deps.sh

# Run linting
make lint

# Run tests
make test

# Run the full CI workflow
make ci
```

The `Makefile` targets mirror the GitHub Actions steps, ensuring consistency between local and remote runs.

## Contributing

We welcome contributions! Follow these guidelines to keep the project healthy.

### Branching Model

- **`main`** – always stable, reflects the latest released configuration.
- **Feature branches** – `feature/<short-description>` (e.g., `feature/add-fish-plugins`).
- **Bugfix branches** – `bugfix/<short-description>`.
- **Release branches** – `release/vX.Y.Z` (created by maintainers).

All PRs must be opened against `main`.

### Pull‑Request Template

A PR template (`.github/PULL_REQUEST_TEMPLATE.md`) is already in the repo. Ensure you:

- Provide a clear description of the change.
- List any new dependencies.
- Include screenshots if UI changes are involved.
- Reference the related issue (e.g., `Closes #88`).

### Linting & Formatting

- **Shell scripts** – `shellcheck` (run via `make lint-shell`).
- **Markdown** – `markdownlint` (run via `make lint-md`).
- **Lua** – `stylua` (run via `make lint-lua`).
- **Git style** – commit messages should follow the Conventional Commits spec.

The CI will reject any PR that fails linting. Run `make lint` locally before pushing.

## License

This project is licensed under the MIT License – see the [LICENSE](LICENSE) file for details.

---

*Happy hacking! 🎉*
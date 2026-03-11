# Dotfiles Repository

Welcome to the **dotfiles** repository! This collection provides a curated set of configuration files to streamline and personalize your development environment across multiple tools such as **bash**, **zsh**, **vim**, and **tmux**.  

The goal is to make it easy to set up a consistent, reproducible environment on any Unix‑like system.

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Provided Configuration Files](#provided-configuration-files)
- [Installation](#installation)
- [Backup Mechanism](#backup-mechanism)
- [Uninstall / Clean‑up](#uninstall--clean‑up)
- [Contributing](#contributing)
- [License](#license)

---

## Prerequisites

Before running the installer, ensure the following tools are available on your system:

| Tool | Minimum Version | Why? |
|------|----------------|------|
| `bash` | 4.0+ | Core shell for the install script |
| `git` | 2.20+ | Required to clone the repository (if not already) |
| `curl` or `wget` | any | Used by the installer to fetch optional resources |
| `vim` | 8.0+ | For the provided Vim configuration |
| `tmux` | 2.6+ | For the provided tmux configuration |
| `zsh` | 5.0+ | For the provided Zsh configuration (optional) |
| `sed`, `awk`, `grep` | standard Unix utilities | Used by the install script |

> **Note:** The installer is designed to work on Linux and macOS. Windows users can run it under WSL or a compatible POSIX environment.

---

## Provided Configuration Files

| File | Description |
|------|-------------|
| `.bashrc` | Custom Bash prompt, aliases, and environment variables |
| `.bash_profile` | Login‑shell configuration that sources `.bashrc` |
| `.zshrc` | Zsh equivalents of the Bash settings (optional) |
| `.vimrc` | Vim settings with sensible defaults, plugin manager (vim-plug) and a curated plugin list |
| `.tmux.conf` | tmux configuration with a modern status line, mouse support, and useful key bindings |
| `install.sh` | Automated installer that symlinks the dotfiles, creates backups, and sets up plugins |
| `uninstall.sh` | Reverses the installation, restores original files from backups |
| `README.md` | This documentation file |
| `CONTRIBUTING.md` | Guidelines for contributing to the project |

All configuration files are stored in the repository root for easy access.

---

## Installation

The repository ships with an **idempotent** installer (`install.sh`). It will:

1. **Detect** existing dotfiles in your home directory.
2. **Create a backup** of any existing files (saved under `~/.dotfiles_backup/<timestamp>/`).
3. **Symlink** the repository versions into your home directory.
4. **Install** Vim plugins (via `vim-plug`) and any optional dependencies.

### Step‑by‑step

```bash
# 1️⃣ Clone the repository (if you haven't already)
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# 2️⃣ Make the installer executable
chmod +x install.sh

# 3️⃣ Run the installer
./install.sh
```

The script will output a summary of actions taken. If you see `All done! 🎉`, your environment is now using the new dotfiles.

#### Options

| Flag | Description |
|------|-------------|
| `-f`, `--force` | Overwrite existing backups and symlinks without prompting |
| `-n`, `--no-backup` | Skip the backup step (use with caution) |
| `-h`, `--help` | Show help message |

Example with force:

```bash
./install.sh --force
```

---

## Backup Mechanism

- **Location:** `~/.dotfiles_backup/<timestamp>/`
- **What is backed up:** Any file that would be overwritten by the installer (e.g., `~/.bashrc`, `~/.vimrc`, etc.).
- **Restoration:** You can manually copy files back from the backup directory, or use the provided `uninstall.sh` script (see below) which automatically restores the most recent backup.

---

## Uninstall / Clean‑up

To revert to your previous configuration:

```bash
# From the repository root
./uninstall.sh
```

The uninstall script will:

1. Remove the symlinks created by `install.sh`.
2. Restore the latest backup of each dotfile.
3. Optionally delete the backup directory after confirmation.

You can also pass `--keep-backup` to retain the backup files for future reference.

---

## Contributing

We welcome contributions! Please read our [CONTRIBUTING.md](CONTRIBUTING.md) for details on:

- Reporting bugs
- Submitting pull requests
- Coding style guidelines
- Testing procedures

---

## License

This repository is licensed under the **MIT License** – see the `LICENSE` file for details.

---

*Happy hacking!* 🚀
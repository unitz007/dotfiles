# Dotfiles Manager

[![CI Status](https://github.com/yourusername/dotfiles-manager/actions/workflows/ci.yml/badge.svg)](https://github.com/yourusername/dotfiles-manager/actions)

A lightweight, cross‑platform dotfiles manager that lets you **install**, **backup**, **sync**, and **track** your configuration files with a single command line interface. It supports multiple profiles, backup rotation, optional GPG encryption, and works on macOS, Linux, and Windows.

---

## Table of Contents

- [Features](#features)
- [Quick‑Start](#quick-start)
- [Installation](#installation)
  - [macOS (Homebrew)](#macos-homebrew)
  - [Windows (PowerShell)](#windows-powershell)
  - [Manual / Linux](#manual-linux)
- [Configuration (`dotfiles.yml`)](#configuration-dotfilesyml)
- [Available Commands](#available-commands)
- [Profile Selection](#profile-selection)
- [Backup Rotation](#backup-rotation)
- [Encryption Options](#encryption-options)
- [Example Workflows](#example-workflows)
- [Contributing](#contributing)
- [License](#license)

---

## Features

- **Declarative configuration** – define source → destination mappings in `dotfiles.yml`.
- **Multiple profiles** – keep separate sets of dotfiles (e.g., `work`, `personal`).
- **Backup rotation** – keep a configurable number of historic backups.
- **Optional GPG encryption** – protect sensitive backups.
- **Cross‑platform** – works on macOS, Linux, and Windows (PowerShell).
- **Zero‑dependency scripts** – pure Bash / PowerShell, no external runtimes required.

---

## Quick‑Start

```bash
# 1️⃣ Clone the repository
git clone https://github.com/yourusername/dotfiles-manager.git
cd dotfiles-manager

# 2️⃣ Install (macOS example)
brew tap yourusername/dotfiles-manager
brew install dotfiles-manager

# 3️⃣ Create a minimal config
cat > dotfiles.yml <<'EOF'
profile: default
files:
  - src: ~/.bashrc
    dest: ~/.bashrc
  - src: ~/.gitconfig
    dest: ~/.gitconfig
backup:
  keep: 5
  encrypt: false
EOF

# 4️⃣ Install your dotfiles
./install.sh

# 5️⃣ Verify status
./status.sh
```

That’s it – your dotfiles are now symlinked, and a backup of any existing files lives in `~/.dotfiles_backups`.

---

## Installation

### macOS (Homebrew)

```bash
brew tap yourusername/dotfiles-manager
brew install dotfiles-manager
```

The formula installs the scripts to `/usr/local/bin` and makes them available system‑wide.

### Windows (PowerShell)

```powershell
# Install via PowerShell Gallery
Install-Module -Name DotfilesManager -Scope CurrentUser
```

The module adds the scripts to your `$env:PATH`. You can also run the scripts directly from the cloned repository.

### Manual / Linux

```bash
git clone https://github.com/yourusername/dotfiles-manager.git
cd dotfiles-manager
# Optionally copy scripts to /usr/local/bin
sudo cp *.sh /usr/local/bin/
```

Make sure the scripts are executable:

```bash
chmod +x *.sh
```

---

## Configuration (`dotfiles.yml`)

The manager reads a single YAML file named `dotfiles.yml` placed in the repository root (or any path passed via `DOTFILES_CONFIG` env var).

```yaml
# dotfiles.yml – full reference
profile: default               # optional, defaults to "default"
files:
  - src: ~/.bashrc            # path on the host machine
    dest: ~/.bashrc           # where the symlink should point
    mode: 0644                # optional file mode (octal)
    owner: $USER              # optional owner (defaults to current user)
  - src: ~/.vimrc
    dest: ~/.vimrc
backup:
  dir: ~/.dotfiles_backups    # where backups are stored (default)
  keep: 7                     # number of historic backups to retain
  rotate: daily               # rotation strategy: daily|weekly|monthly
  encrypt: true               # true to GPG‑encrypt backups
  gpg_key: "0xDEADBEEF"       # GPG key ID used for encryption (optional)
```

**Key sections**

| Section | Description |
|---------|-------------|
| `profile` | Allows you to maintain separate sets of files. Use `PROFILE=work ./install.sh` to apply a different profile. |
| `files` | List of file mappings. `src` is the source (the file you keep under version control); `dest` is where the symlink will be created on the target machine. |
| `backup` | Controls where backups are stored, how many to keep, rotation cadence, and encryption. |

---

## Available Commands

All scripts are located in the repository root and can be executed directly (`./install.sh`) or via the installed binary name (`install.sh`).

| Script | Description | Usage |
|--------|-------------|-------|
| `install.sh` | Symlinks files defined in `dotfiles.yml`. Existing files are backed up first. | `./install.sh [--profile <name>]` |
| `uninstall.sh` | Removes symlinks and restores the most recent backup. | `./uninstall.sh [--profile <name>]` |
| `backup.sh` | Creates a fresh backup of all managed files (useful before a major change). | `./backup.sh [--profile <name>]` |
| `status.sh` | Shows which files are linked, which are missing, and backup health. | `./status.sh [--profile <name>]` |
| `sync_backups.sh` | Pushes local backups to a remote (e.g., S3, rsync, or a Git repo). Configurable via `sync:` block in `dotfiles.yml`. | `./sync_backups.sh` |
| `sync_dotfiles.sh` | Pulls the latest `dotfiles.yml` and associated files from a remote repository, then runs `install.sh`. | `./sync_dotfiles.sh` |

All scripts respect the `PROFILE` environment variable or the `--profile` flag to select a configuration profile.

---

## Profile Selection

You can maintain multiple profiles inside a single `dotfiles.yml` by nesting them under a top‑level `profiles:` key:

```yaml
profiles:
  default:
    files: [...]
    backup: {...}
  work:
    files: [...]
    backup: {...}
```

Select a profile with:

```bash
export PROFILE=work
./install.sh
# or
./install.sh --profile work
```

If no profile is specified, `default` is used.

---

## Backup Rotation

The `backup.keep` field defines how many historic backups are retained. The manager automatically deletes the oldest backup when the limit is exceeded.

Rotation strategies (`backup.rotate`) determine the naming scheme:

| Strategy | Example filename |
|----------|------------------|
| `daily`   | `2024-03-12_01.tar.gpg` |
| `weekly`  | `2024-W10_01.tar.gpg` |
| `monthly` | `2024-03_01.tar.gpg` |

You can change the strategy at any time; the next backup will follow the new cadence.

---

## Encryption Options

When `backup.encrypt` is set to `true`, backups are encrypted with GPG:

- If `gpg_key` is provided, that key is used for encryption.
- If omitted, the default GPG key of the current user is used.

```yaml
backup:
  encrypt: true
  gpg_key: "0xDEADBEEF"
```

Decryption is handled automatically by `uninstall.sh` and `sync_backups.sh` (they invoke `gpg --decrypt`). Ensure the private key is available on the machine performing the restore.

---

## Example Workflows

### 1️⃣ Install a new profile

```bash
export PROFILE=work
./install.sh
```

### 2️⃣ Create a manual backup before a risky change

```bash
./backup.sh --profile work
```

### 3️⃣ Rotate backups and keep only the last 3

Edit `dotfiles.yml`:

```yaml
backup:
  keep: 3
  rotate: weekly
  encrypt: true
```

Run a backup to enforce the new policy:

```bash
./backup.sh
```

### 4️⃣ Sync backups to a remote Git repository

```yaml
sync:
  remote: git@github.com:yourusername/dotfiles-backups.git
  branch: main
```

```bash
./sync_backups.sh
```

### 5️⃣ Restore a previous state

```bash
# List available backups
ls ~/.dotfiles_backups

# Restore the most recent backup
./uninstall.sh && ./install.sh
```

---

## Contributing

Contributions are welcome! Please:

1. Fork the repository.
2. Create a feature branch (`git checkout -b feat/awesome-feature`).
3. Write tests (if applicable) and ensure `./status.sh` passes.
4. Submit a Pull Request with a clear description.

See `CONTRIBUTING.md` for detailed guidelines.

---

## License

Distributed under the MIT License. See `LICENSE` for more information.

---

*Happy dot‑file managing!*
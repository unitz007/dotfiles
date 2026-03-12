# Dotfiles Manager

A cross‑platform, opinionated dotfiles manager that lets you **install**, **update**, **uninstall**, and **sync** your configuration files across macOS, Linux, and Windows.  
It reads a declarative `dotfiles.yml` configuration, handles encrypted secrets, backs up existing files, and can even install VS Code extensions for you.

---

## Table of Contents

1. [Purpose](#purpose)  
2. [Installation](#installation)  
   - [macOS (Homebrew)](#macos-homebrew)  
   - [Linux (apt / dnf / pacman)](#linux)  
   - [Windows (Scoop)](#windows)  
3. [Quick Start](#quick-start)  
4. [Available Commands](#available-commands)  
5. [Configuration Schema (`dotfiles.yml`)](#configuration-schema)  
   - [Top‑level keys](#top-level-keys)  
   - [Example file](#example-config)  
6. [FAQ](#faq)  
7. [Contributing](#contributing)  
8. [License](#license)  

---

## Purpose <a name="purpose"></a>

Managing dotfiles manually quickly becomes error‑prone:

* You forget to back up existing files.
* Secrets (API keys, passwords) end up in plain text.
* Different OSes need slightly different paths.
* Keeping VS Code extensions in sync is a pain.

This project solves those problems by:

* Declaring **what** should be linked, copied, or templated in a single `dotfiles.yml`.
* Automatically **backing up** existing files before overwriting them.
* Supporting **encrypted** sections (via `sops` or `age`).
* Providing a **wizard** to bootstrap a new machine.
* Offering a **backup** command to archive your current home directory.
* Managing **VS Code extensions** directly from the config.

---

## Installation <a name="installation"></a>

> **Prerequisite:** You need a recent version of **Python 3.9+** and **Git** installed.

### macOS (Homebrew) <a name="macos-homebrew"></a>

```bash
# Install dependencies
brew install git python3

# Clone the repository
git clone https://github.com/yourname/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Install the CLI (editable mode)
python3 -m pip install -e .

# Verify
dotfiles --version
```

### Linux <a name="linux"></a>

#### Debian / Ubuntu

```bash
sudo apt update
sudo apt install -y git python3 python3-pip

git clone https://github.com/yourname/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
python3 -m pip install -e .
dotfiles --version
```

#### Fedora

```bash
sudo dnf install -y git python3 python3-pip
# …same steps as above
```

#### Arch Linux

```bash
sudo pacman -Syu git python-pip
# …same steps as above
```

### Windows (Scoop) <a name="windows"></a>

```powershell
# Install Scoop (if you don't have it)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
iwr -useb get.scoop.sh | iex

# Install dependencies
scoop install git python

# Clone the repo
git clone https://github.com/yourname/dotfiles.git $HOME\.dotfiles
cd $HOME\.dotfiles

# Install the CLI
python -m pip install -e .

# Verify
dotfiles --version
```

> **Tip:** On Windows you may also use **WSL** and follow the Linux instructions.

---

## Quick Start <a name="quick-start"></a>

```bash
# 1. Create a config (or copy the example)
cp dotfiles.example.yml dotfiles.yml

# 2. Edit dotfiles.yml to match your preferences (see schema below)

# 3. Run the wizard to see what will happen
dotfiles wizard

# 4. Install the dotfiles
dotfiles install
```

Your home directory now contains symlinks (or copies) as defined in `dotfiles.yml`.

---

## Available Commands <a name="available-commands"></a>

| Command | Description |
|---------|-------------|
| `dotfiles install` | Install (link/copy) all files defined in `dotfiles.yml`. Backs up existing files to `~/.dotfiles.backup`. |
| `dotfiles uninstall` | Remove all managed links/copies and restore the original files from the backup. |
| `dotfiles update` | Re‑run the install process – useful after editing `dotfiles.yml`. |
| `dotfiles status` | Show which files are managed, which are missing, and any conflicts. |
| `dotfiles diff` | Show a `git diff`‑style view of differences between the source files and the installed versions. |
| `dotfiles clean` | Delete any stray files in the target locations that are **not** managed by the current config. |
| `dotfiles wizard` | Interactive walkthrough that previews actions, asks for confirmation, and can generate a starter config. |
| `dotfiles backup` | Archive the current `$HOME` (or a custom directory) into `~/.dotfiles.backup/YYYYMMDD.tar.gz`. |
| `dotfiles list` | List all entries defined in `dotfiles.yml` with their source → destination mapping. |
| `dotfiles encrypt` | Encrypt the `encrypted` section of the config using `sops` or `age`. |
| `dotfiles decrypt` | Decrypt the `encrypted` section for local editing. |
| `dotfiles help` | Show the help message (or `dotfiles <command> --help`). |

All commands accept `-v/--verbose` for more output and `--dry-run` to simulate actions without touching the filesystem.

---

## Configuration Schema (`dotfiles.yml`) <a name="configuration-schema"></a>

The file lives at the repository root (`dotfiles.yml`). It is a **YAML** document with the following top‑level keys:

```yaml
# dotfiles.yml
dotfiles:
  - src: path/to/source/file   # relative to repository root
    dest: ~/.config/file       # absolute or ~‑expanded path
    mode: symlink|copy|template
    template_vars: {}          # optional, used when mode == template

vscode:
  extensions:
    - ms-python.python
    - eamodio.gitlens
    - ...

encrypted:
  # Any key/value pair that should be stored encrypted.
  # The value can be a string, list, or nested map.
  secrets:
    github_token: "ghp_XXXXXXXXXXXXXXXXXXXX"
    aws_access_key_id: "AKIA..."
    aws_secret_access_key: "..."

backup:
  enabled: true               # whether `dotfiles backup` creates a tarball
  location: ~/.dotfiles.backup # directory where backups are stored
  retain: 7                   # keep the last N backups, older ones are pruned

settings:
  # Miscellaneous options
  follow_symlinks: false
  dry_run_default: false
```

### Top‑level keys <a name="top-level-keys"></a>

| Key | Type | Description |
|-----|------|-------------|
| `dotfiles` | list of maps | Each entry describes a file or directory to manage. |
| `vscode.extensions` | list of strings | VS Code extension identifiers to install (`code --install-extension`). |
| `encrypted` | map | Sensitive data that will be encrypted on disk. Use `dotfiles encrypt`/`decrypt`. |
| `backup` | map | Controls automatic backup behavior. |
| `settings` | map | Global flags for the CLI. |

#### `dotfiles` entry fields

| Field | Values | Required | Description |
|-------|--------|----------|-------------|
| `src` | string | yes | Path **relative** to the repository root. |
| `dest` | string | yes | Destination path on the target machine. `~` is expanded to `$HOME`. |
| `mode` | `symlink` \| `copy` \| `template` | no (default `symlink`) | How the file is installed. |
| `template_vars` | map | only when `mode: template` | Variables passed to the Jinja‑like templating engine. |

### Example Config <a name="example-config"></a>

```yaml
dotfiles:
  - src: bash/.bashrc
    dest: ~/.bashrc
    mode: symlink

  - src: git/.gitconfig
    dest: ~/.gitconfig
    mode: copy

  - src: nvim/init.lua
    dest: ~/.config/nvim/init.lua
    mode: template
    template_vars:
      theme: "gruvbox"
      enable_lsp: true

vscode:
  extensions:
    - ms-python.python
    - ms-vscode.cpptools
    - esbenp.prettier-vscode

encrypted:
  secrets:
    github_token: "ghp_XXXXXXXXXXXXXXXXXXXX"
    ssh_private_key: |
      -----BEGIN OPENSSH PRIVATE KEY-----
      ...
      -----END OPENSSH PRIVATE KEY-----

backup:
  enabled: true
  location: ~/.dotfiles.backup
  retain: 14

settings:
  follow_symlinks: true
  dry_run_default: false
```

> **Tip:** After editing the `encrypted` section, run `dotfiles encrypt` to store it safely. The CLI will automatically decrypt it at runtime (requires `sops` or `age` installed).

---

## FAQ <a name="faq"></a>

**Q: I already have a `.bashrc`. Will it be overwritten?**  
A: No. The installer first creates a backup in `~/.dotfiles.backup/<timestamp>/`. You can restore it with `dotfiles uninstall` or manually from the backup directory.

**Q: How does the `template` mode work?**  
A: Files are processed with a tiny Jinja‑style engine. Variables are supplied via `template_vars`. Example: `{{ theme }}` in the source file will be replaced with the value from the config.

**Q: Can I manage Windows-specific files?**  
A: Yes. Use Windows paths (`C:\\Users\\%USERNAME%\\...`) or the `~` shortcut. The CLI detects the OS and only installs entries whose `dest` is valid for the current platform.

**Q: What encryption back‑ends are supported?**  
A: `sops` (AWS KMS, GCP KMS, PGP, Azure) and `age`. The CLI automatically picks the first available binary in `$PATH`.

**Q: I want to add a new dotfile but don’t want to edit `dotfiles.yml` manually.**  
A: Run `dotfiles wizard` → “Add new file” → it will ask for source, destination, and mode, then append the entry to the config.

**Q: How do I remove a dotfile from management?**  
A: Delete the entry from `dotfiles.yml` and run `dotfiles uninstall` (or `dotfiles clean` to purge stray files).

**Q: Does this work with Zsh, Fish, or other shells?**  
A: Absolutely. The manager is shell‑agnostic; you just point `src` to the appropriate config file.

**Q: Where are backups stored?**  
A: By default in `~/.dotfiles.backup`. Each run creates a timestamped directory or tarball, and the `retain` setting prunes older backups.

**Q: I get “Permission denied” on macOS when linking to `/usr/local/bin`.**  
A: The installer only writes inside your home directory by default. For system‑wide locations you must run `sudo dotfiles install` (or adjust the `dest` path accordingly).

---

## Contributing <a name="contributing"></a>

1. Fork the repository.  
2. Create a feature branch (`git checkout -b feat/awesome`).  
3. Write tests (if applicable) and ensure `flake8`/`black` pass.  
4. Submit a Pull Request.

Please see `CONTRIBUTING.md` for detailed guidelines.

---

## License <a name="license"></a>

Distributed under the **MIT License**. See `LICENSE` for details.

---

*Happy hacking! 🎉*
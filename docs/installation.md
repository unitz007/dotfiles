# Installation

This guide walks you through installing the dotfiles on a new machine.

## Prerequisites

- Git
- Bash (or Zsh)
- `curl` or `wget`

## Steps

1. **Clone the repository**

   ```bash
   git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
   ```

2. **Run the bootstrap script**

   ```bash
   cd ~/.dotfiles
   ./bootstrap.sh
   ```

   The bootstrap script will:

   - Create symbolic links for configuration files.
   - Install optional dependencies (see the `components.md` page for details).
   - Set up the backup/restore system.

3. **Verify installation**

   ```bash
   dotfiles --version
   ```

   You should see the current version printed.

## Post‑install checklist

- Review the generated `~/.dotfiles.yml` configuration file.
- Run `dotfiles --help` to see available commands.
- Enable the automatic backup service if desired (see the backup/restore guide).

--- 

*For advanced installation options, see the [Configuration](configuration.md) page.*
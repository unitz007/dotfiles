# Dotfiles Manager

A simple set of scripts to install and uninstall my personal dotfiles across macOS and Linux systems.

## Installation

```bash
./install.sh
```

## Uninstallation

```bash
./uninstall.sh
```

## Dry‑Run Mode

Both `install.sh` and `uninstall.sh` now support a `--dry-run` flag.  
When this flag is supplied, the scripts will **print** each action they would take (creating symlinks, backing up files, installing or removing packages, etc.) **without** modifying the filesystem. This allows you to preview changes safely.

### Examples

```bash
# Show what would happen during installation without making changes
./install.sh --dry-run
```

```bash
# Show what would happen during uninstallation without making changes
./uninstall.sh --dry-run
```

## Usage

```bash
./install.sh [options]
./uninstall.sh [options]
```

### Options

- `--dry-run` Show actions without performing them.
- `-h, --help` Display help information.

## License

MIT © Your Name
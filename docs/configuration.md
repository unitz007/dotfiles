# Configuration (`dotfiles.yml` schema)

The dotfiles project is driven by a single YAML configuration file located at `~/.dotfiles.yml`. This file defines which components are enabled, backup locations, and custom overrides.

## Schema Overview

```yaml
# ~/.dotfiles.yml
components:
  vim: true          # Install and configure Vim
  zsh: true          # Install and configure Zsh
  tmux: false        # Disable tmux configuration
  git: true          # Enable Git settings
backup:
  enabled: true
  remote: "git@github.com:yourusername/dotfiles-backup.git"
  schedule: "daily" # Options: hourly, daily, weekly
paths:
  vimrc: "~/.vimrc"
  zshrc: "~/.zshrc"
  tmux_conf: "~/.tmux.conf"
```

## Detailed Fields

| Section   | Key          | Type   | Description |
|-----------|--------------|--------|-------------|
| `components` | *component name* | boolean | Enable (`true`) or disable (`false`) a component. |
| `backup`   | `enabled`   | boolean | Turn the backup system on or off. |
|            | `remote`    | string  | Git remote URL where backups are pushed. |
|            | `schedule`  | string  | Frequency of automatic backups (`hourly`, `daily`, `weekly`). |
| `paths`    | *path name* | string  | Custom location for a configuration file. Supports `~` expansion. |

## Editing the Configuration

```bash
# Open the config in your preferred editor
$EDITOR ~/.dotfiles.yml
```

After editing, apply changes with:

```bash
dotfiles apply
```

## Validation

The `dotfiles validate` command checks the YAML for syntax errors and unknown keys.

```bash
dotfiles validate
```

--- 

*For a full list of available components, see the [Components](components.md) page.*
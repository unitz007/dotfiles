# Component List

The dotfiles project ships with a modular set of components. Each component can be toggled via the `components` section of `~/.dotfiles.yml`.

| Component | Description | Files Managed | Dependencies |
|-----------|-------------|---------------|--------------|
| **vim**   | Vim editor configuration, plugins, and colorschemes. | `~/.vimrc`, `~/.vim/` | `vim`, `git` (for plugin manager) |
| **zsh**   | Zsh shell configuration, Oh‑My‑Zsh, and custom plugins. | `~/.zshrc`, `~/.zsh/` | `zsh`, `git` |
| **tmux**  | Tmux terminal multiplexer configuration. | `~/.tmux.conf` | `tmux` |
| **git**   | Global Git settings and aliases. | `~/.gitconfig` | `git` |
| **bash**  | Bash shell configuration (if you prefer Bash). | `~/.bashrc` | `bash` |
| **starship** | Minimal, fast, and customizable prompt. | `~/.config/starship.toml` | `starship` |

## Enabling / Disabling

Edit `~/.dotfiles.yml`:

```yaml
components:
  vim: true
  zsh: false   # disables Zsh configuration
```

Run `dotfiles apply` to apply the changes.

--- 

*For backup and restore instructions, see the [Backup & Restore Workflow](backup_restore.md) page.*
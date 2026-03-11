# My Dotfiles

A collection of my personal configuration files for various tools and shells.

## Installation

```sh
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh [--shell=sh]
```

- `--shell=sh` – Specify the target shell (`bash`, `zsh`, or `fish`).  
  If omitted, the script will auto‑detect your current default shell.

### Fish shell support

A basic Fish configuration is provided in `fish/config.fish`.  
Run the installer with `--shell=fish` (or let it auto‑detect if Fish is your default shell) to symlink the configuration into `~/.config/fish/`.

## Contents

- `.bashrc` – Bash configuration
- `.zshrc` – Zsh configuration
- `fish/config.fish` – Fish configuration
- `fish/fish_plugins` – Optional Fish plugins list (compatible with **fisher**)
- `.gitconfig` – Git configuration
- `.vimrc` – Vim configuration

## License

MIT © Your Name
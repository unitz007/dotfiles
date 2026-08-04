# Dotfiles

This repository contains my personal configuration files.

## Files included:
- `.zshrc` - Shell configuration with enhanced functions and aliases
- `.aerospace.toml` - Window manager configuration
- `cloud-init.yaml` - Cloud initialization script
- `dotfile-config.yaml` - Dotfile configuration and references

## Improvements in Phase 3:
- Converted `rmDir` alias to a safer interactive function
- Standardized and enhanced the `commit` function with validation
- Removed dead references and invalid configurations
- Fixed typos in file references
- Updated shell configuration from bash to zsh
- Added version tracking to dotfile config

## Installation
Clone this repository and symlink the files to your home directory:

```bash
git clone <repository-url>
cd dotfiles
ln -s ~/.zshrc .zshrc
ln -s ~/.aerospace.toml .aerospace.toml
```

## Usage
After installation, restart your shell or run:
```bash
source ~/.zshrc
```
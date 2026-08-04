# Dotfiles

This repository contains my personal configuration files for various tools and environments.

## Files included:

### .zshrc
Shell configuration with custom aliases and functions:
- `commit` - Git add all and commit with message
- `rmdir_safe` - Interactive directory removal with confirmation
- `deploy` - Cloud deployment helper function

### .aerospace.toml
Aerospace window manager configuration with workspace definitions.

### cloud-init.yaml
Cloud initialization script for setting up new instances with required packages and configurations.

### dotfile-config.yaml
Dotfile configuration with references and settings for backup and synchronization.

## Installation

1. Clone this repository:
   ```bash
   git clone <repository-url>
   ```

2. Symlink the files to your home directory:
   ```bash
   ln -s /path/to/dotfiles/.zshrc ~/.zshrc
   ln -s /path/to/dotfiles/.aerospace.toml ~/.aerospace.toml
   ```

3. Reload your shell configuration:
   ```bash
   source ~/.zshrc
   ```

## Usage

### Shell Functions

#### commit
Adds all changes and creates a git commit with the provided message:
```bash
commit "Your commit message"
```

#### rmdir_safe
Safely removes directories with confirmation prompt:
```bash
rmdir_safe /path/to/directory
```

#### deploy
Placeholder function for cloud deployment operations:
```bash
deploy
```

## Configuration Management

The `dotfile-config.yaml` file manages references to all dotfiles and includes settings for:
- Backup automation
- Sync intervals

## Version Tracking

Current dotfiles version: 1.0

Check for updates regularly to get the latest improvements and fixes.
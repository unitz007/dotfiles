# Dotfiles Repository

This repository contains my personal configuration files (dotfiles) that I keep in sync across multiple machines.

## Getting Started

```bash
git clone git@github.com:yourusername/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh   # or whatever installation script you provide
```

## Sync Dotfiles

A helper script `sync_dotfiles.sh` is provided to automate pushing local changes to the remote repository and pulling updates from other machines.

### Basic Usage

```bash
./sync_dotfiles.sh
```

This will:

1. Add all changes.
2. Commit them with a generic message.
3. Push to the remote `origin/main`.
4. Pull any remote updates (rebase).

### Encrypted Sync

If you want to keep the actual changes confidential, you can encrypt the diff before committing. Set the `GPG_RECIPIENT` environment variable to the GPG key identifier that should receive the encrypted diff.

```bash
export GPG_RECIPIENT="your@email.com"
./sync_dotfiles.sh --encrypt
```

The script will:

1. Generate a diff of the staged changes.
2. Encrypt the diff with GPG for the specified recipient.
3. Add the encrypted diff (`changes.diff.gpg`) to the commit.
4. Sign the commit with your GPG key.
5. Push and pull as usual.

### Configuration

- `REMOTE` – Remote name (default: `origin`).
- `BRANCH` – Branch to sync (default: `main`).

You can override these by setting the environment variables before running the script:

```bash
REMOTE=upstream BRANCH=master ./sync_dotfiles.sh
```

## License

MIT License

--- 

*Feel free to customize the script and README to match your workflow.*
# Dotfiles Repository

Welcome to my dotfiles repository. This collection contains my personal configuration files and scripts to set up a development environment quickly.

## Installation

```sh
./install.sh [options]
```

The `install.sh` script supports various options to customize the setup. For a full list of options, run:

```sh
./install.sh --help
```

## Self‑Update

A new script `self_update.sh` has been added to simplify keeping the repository up‑to‑date.

### Usage

```sh
./self_update.sh [--yes] [--no-install]
```

- `--yes` – Automatically accept the update without prompting.
- `--no-install` – Update the repository but do **not** re‑run `install.sh`.

The script will:

1. Detect the repository root even if run from a subdirectory.
2. Stash any uncommitted changes.
3. Check the remote GitHub repository for newer commits or tags.
4. Prompt for confirmation (unless `--yes` is supplied).
5. Pull the latest changes.
6. Optionally re‑run `install.sh` with the same options you used previously (saved in `.install_opts` if present).
7. Restore any stashed changes.
8. Update the local backup rotation configuration if a `backup.conf` file exists.

### Example

```sh
# Interactive update (you will be prompted)
./self_update.sh

# Non‑interactive update that also runs install.sh automatically
./self_update.sh --yes
```

## Contributing

Feel free to open issues or submit pull requests.

## License

MIT License
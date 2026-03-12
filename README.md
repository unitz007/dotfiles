# Dotfiles Installer

`install.sh` installs your dotfiles by creating symlinks from the repository into your home directory.

## Usage

```bash
./install.sh [--profile <name>]
```

- `--profile <name>` – Choose a profile defined in `dotfiles.yml`.  
  If omitted, the `default` profile is used.

## Configuration (`dotfiles.yml`)

```yaml
dotfiles:
  bashrc:
    src: bashrc
    dest: ~/.bashrc
  vimrc:
    src: vimrc
    dest: ~/.vimrc
  gitconfig:
    src: gitconfig
    dest: ~/.gitconfig

profiles:
  default: [bashrc, vimrc, gitconfig]
  work:    [bashrc, gitconfig]
  personal: [bashrc, vimrc]
```

- **dotfiles** – Map each dotfile identifier to its source (`src`) and destination (`dest`).
- **profiles** – Define named groups of dotfiles. The installer will only process the dotfiles listed for the selected profile.

## Examples

Install the default set of dotfiles:

```bash
./install.sh
```

Install only the `work` profile:

```bash
./install.sh --profile work
```

## Testing

Run the test suite with:

```bash
bats tests/
```

The tests include verification of the `--profile` flag behavior.

## Requirements

- `bash` (>= 4)
- [`yq`](https://github.com/mikefarah/yq) – a lightweight and portable command‑line YAML processor.

## License

MIT © Your Name
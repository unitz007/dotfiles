# Project Name

<!-- Existing README content -->

## Installation

```sh
make install
```

Running `make install` now automatically checks for common plugin managers
(oh‑my‑zsh, fisher, vim‑plug, packer.nvim) and offers to install any that are
missing.

### Dependency Installer

A helper script `install_deps.sh` is invoked during `make install`. It:

* Detects whether each supported plugin manager is already present.
* Prompts you to install missing managers.
* Installs them using the official installation methods for Linux/macOS.

You can also run the script manually:

```sh
./install_deps.sh
```

Follow the prompts to install any desired dependencies.

<!-- Rest of the README -->
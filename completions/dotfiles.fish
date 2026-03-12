# Fish completion for the `dotfiles` command.
# Mirrors the Zsh completion, offering subcommands and global options.

# Subcommands
complete -c dotfiles -f -a "install uninstall status update sync"

# Global options
complete -c dotfiles -l dry-run -d "Perform a trial run with no changes"
complete -c dotfiles -l verbose -d "Increase output verbosity"
complete -c dotfiles -s h -l help -d "Show help message"
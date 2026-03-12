# Fish completion for the `dotfiles` command.
# Mirrors the Zsh completion, offering script names, flags, and enum values.

# ----------------------------------------------------------------------
# Flags
# ----------------------------------------------------------------------
complete -c dotfiles -l profile -d "Select a profile (e.g. work, personal)" -a "work personal"
complete -c dotfiles -l dry-run -d "Run without making changes"
complete -c dotfiles -l json -d "Output in JSON format"
complete -c dotfiles -s h -l help -d "Show help information"

# ----------------------------------------------------------------------
# Script names (sub‑commands)
# ----------------------------------------------------------------------
# Detect scripts located in the repository's `scripts/` directory.
# This is evaluated at runtime, so newly added scripts are automatically
# available for completion.
set -l script_dir (realpath (status dirname)/../scripts)
if test -d $script_dir
    for f in $script_dir/*.sh
        set -l name (basename $f .sh)
        complete -c dotfiles -a $name -d "Run the `$name` script"
    end
end
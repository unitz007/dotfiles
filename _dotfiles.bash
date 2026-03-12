# Bash completion for the `dotfiles` command.
# This mirrors the existing Zsh completion and provides tab‑completion for
# script names, flags, and enum values defined in `dotfiles.yml`.

# Load bash‑completion helper functions if available.
if type _init_completion &>/dev/null; then
    _init_completion -n = || return
else
    # Fallback: initialise the variables used by the completion logic.
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    words=("${COMP_WORDS[@]}")
    cword=$COMP_CWORD
fi

# ----------------------------------------------------------------------
# Configuration – keep this in sync with `dotfiles.yml` and the CLI.
# ----------------------------------------------------------------------
# Flags supported by the CLI.
_dotfiles_opts="--profile --dry-run --json --help -h"

# Enum values for the `--profile` flag (example values; adjust as needed).
_dotfiles_profiles="work personal"

# ----------------------------------------------------------------------
# Completion logic.
# ----------------------------------------------------------------------
case "$prev" in
    --profile)
        COMPREPLY=( $(compgen -W "$_dotfiles_profiles" -- "$cur") )
        return 0
        ;;
esac

# If the current word starts with a dash, suggest flags.
if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "$_dotfiles_opts" -- "$cur") )
    return 0
fi

# Otherwise, suggest script names (files in the `scripts/` directory).
# This mirrors the Zsh completion which offers the same set.
if [[ -d "${BASH_SOURCE%/*}/../scripts" ]]; then
    local scripts
    scripts=$(cd "${BASH_SOURCE%/*}/../scripts" && printf "%s\n" *.sh 2>/dev/null | sed 's/\.sh$//')
    COMPREPLY=( $(compgen -W "$scripts" -- "$cur") )
    return 0
fi

# Fallback to filename completion.
_filedir
return 0
}
complete -F _dotfiles dotfiles
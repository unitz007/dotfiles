# Bash completion for the `dotfiles` command.
# This mirrors the Zsh completion and provides subcommand and option suggestions.

_dotfiles_completion() {
    local cur prev words cword
    # Initialize completion variables.
    # Compatibility with both bash-completion's _init_completion and a manual fallback.
    if declare -F _init_completion >/dev/null 2>&1; then
        _init_completion || return
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
        words=("${COMP_WORDS[@]}")
        cword=$COMP_CWORD
    fi

    local subcommands="install uninstall status update sync"
    local opts="--dry-run --verbose -h --help"

    # If we are completing the first argument after the command, suggest subcommands.
    if [[ $cword -eq 1 ]]; then
        COMPREPLY=( $(compgen -W "$subcommands" -- "$cur") )
        return 0
    fi

    # After a subcommand, suggest global options.
    COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
    return 0
}

complete -F _dotfiles_completion dotfiles
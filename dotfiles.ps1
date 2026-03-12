# dotfiles.ps1 - PowerShell argument completion for the dotfiles CLI
# This script registers argument completions for the `dotfiles` command,
# supporting sub‑commands and common global flags.

# List of supported sub‑commands
$script:DotfilesCommands = @(
    'install',
    'uninstall',
    'update',
    'status',
    'diff',
    'clean',
    'wizard',
    'backup',
    'list'
)

# List of common global options
$script:DotfilesGlobalOptions = @(
    '--dry-run',
    '--output',
    '--gpg'
)

function Register-DotfilesCompletion {
    Register-ArgumentCompleter -CommandName 'dotfiles' -ScriptBlock {
        param(
            [string] $commandName,
            [string] $parameterName,
            [string] $wordToComplete,
            [System.Management.Automation.Language.CommandAst] $commandAst,
            [hashtable] $fakeBoundParameters
        )

        # Extract the arguments already typed (excluding the command itself)
        $args = $commandAst.CommandElements |
                Where-Object { $_ -isnot [System.Management.Automation.Language.CommandParameterAst] } |
                ForEach-Object { $_.Extent.Text } |
                Select-Object -Skip 1

        # Determine which argument we are completing
        $argIndex = $args.Count

        # If we are completing the first argument, suggest sub‑commands
        if ($argIndex -eq 0) {
            $script:DotfilesCommands |
                Where-Object { $_ -like "$wordToComplete*" } |
                ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new(
                        $_,
                        $_,
                        'ParameterValue',
                        "dotfiles sub‑command: $_"
                    )
                }
        }
        else {
            # After a sub‑command, suggest global options
            $script:DotfilesGlobalOptions |
                Where-Object { $_ -like "$wordToComplete*" } |
                ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new(
                        $_,
                        $_,
                        'ParameterName',
                        "global option: $_"
                    )
                }
        }
    }
}

# Register the completions when the script is dot‑sourced
Register-DotfilesCompletion
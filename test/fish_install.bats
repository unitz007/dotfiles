#!/usr/bin/env bats

setup() {
    # Create a temporary HOME directory
    export HOME="$(mktemp -d)"
    mkdir -p "${HOME}/.config"

    # Simulate an existing fish configuration to test backup rotation
    mkdir -p "${HOME}/.config/fish"
    echo "old config" > "${HOME}/.config/fish/old.fish"

    # Clone the repository into a temporary location for testing
    REPO_ROOT="$(git rev-parse --show-toplevel)"
    export DOTFILES="${REPO_ROOT}"
}

teardown() {
    rm -rf "${HOME}"
}

@test "Fish component installs, backs up existing config, and creates symlink" {
    run bash "${DOTFILES}/install.sh"
    [ "$status" -eq 0 ]

    # Verify that the destination is a symlink pointing to the repository fish directory
    [ -L "${HOME}/.config/fish" ]
    target=$(readlink "${HOME}/.config/fish")
    [ "$target" = "${DOTFILES}/fish" ]

    # Verify that the old configuration was backed up
    backup_dir=$(ls "${HOME}/.dotfiles_backup" | grep '^fish_' | head -n1)
    [ -d "${HOME}/.dotfiles_backup/${backup_dir}" ]
    [ -f "${HOME}/.dotfiles_backup/${backup_dir}/old.fish" ]

    # Verify Fisher was installed (type -q fisher should succeed in fish)
    fish -c 'type -q fisher'
    [ "$status" -eq 0 ]
}
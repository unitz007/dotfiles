#!/usr/bin/env bash
# VSCode extension management utilities

# Install missing extensions and optionally remove unlisted ones
manage_vscode_extensions() {
  local config_file="$1"

  # Read declared extensions into an array
  mapfile -t declared_extensions < <(yq -r '.vscode.extensions[]?' "$config_file" | grep -v '^null$' || true)

  # If no extensions are declared, nothing to do
  if [[ ${#declared_extensions[@]} -eq 0 ]]; then
    echo "No VSCode extensions declared in $config_file."
    return
  fi

  # Determine if we should remove extensions not listed
  local remove_unlisted
  remove_unlisted=$(yq -r '.vscode.remove_unlisted // false' "$config_file")
  if [[ "$remove_unlisted" != "true" && "$remove_unlisted" != "false" ]]; then
    echo "Invalid value for vscode.remove_unlisted in $config_file; expected true or false."
    remove_unlisted="false"
  fi

  # Get currently installed extensions
  mapfile -t installed_extensions < <(code --list-extensions)

  # Install missing extensions
  for ext in "${declared_extensions[@]}"; do
    if [[ ! " ${installed_extensions[*]} " =~ " ${ext} " ]]; then
      echo "Installing VSCode extension: $ext"
      code --install-extension "$ext" --force
    fi
  done

  # Optionally remove extensions that are not declared
  if [[ "$remove_unlisted" == "true" ]]; then
    for ext in "${installed_extensions[@]}"; do
      if [[ ! " ${declared_extensions[*]} " =~ " ${ext} " ]]; then
        echo "Removing unlisted VSCode extension: $ext"
        code --uninstall-extension "$ext"
      fi
    done
  fi
}
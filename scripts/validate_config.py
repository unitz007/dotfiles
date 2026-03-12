#!/usr/bin/env python3
"""
Validate the repository's dotfiles configuration file (dotfiles.yml).

The script checks that the YAML file is syntactically correct and conforms
to a minimal schema:

- The top‑level document must be a mapping (dictionary).
- Optional top‑level keys:
  * repositories: a list of mappings, each with a required "url" (string)
    and optional "dest" (string).
  * symlinks: a list of mappings, each with required "src" and "dest"
    (both strings).

If any validation rule fails, the script prints a clear error message to
stderr and exits with a non‑zero status code, causing CI to fail.
"""

import sys
import os
import yaml

CONFIG_FILE = os.getenv("DOTFILES_CONFIG", "dotfiles.yml")


def error(msg: str):
    """Print an error message to stderr."""
    print(f"ERROR: {msg}", file=sys.stderr)


def validate_top_level(config):
    if not isinstance(config, dict):
        error("Top‑level YAML structure must be a mapping (dictionary).")
        return False
    return True


def validate_repositories(repos):
    if not isinstance(repos, list):
        error("'repositories' must be a list.")
        return False

    ok = True
    for idx, item in enumerate(repos):
        if not isinstance(item, dict):
            error(f"'repositories[{idx}]' must be a mapping.")
            ok = False
            continue
        if "url" not in item:
            error(f"'repositories[{idx}]' missing required key 'url'.")
            ok = False
        elif not isinstance(item["url"], str):
            error(f"'repositories[{idx}].url' must be a string.")
            ok = False

        if "dest" in item and not isinstance(item["dest"], str):
            error(f"'repositories[{idx}].dest' must be a string if present.")
            ok = False
    return ok


def validate_symlinks(symlinks):
    if not isinstance(symlinks, list):
        error("'symlinks' must be a list.")
        return False

    ok = True
    for idx, item in enumerate(symlinks):
        if not isinstance(item, dict):
            error(f"'symlinks[{idx}]' must be a mapping.")
            ok = False
            continue
        for key in ("src", "dest"):
            if key not in item:
                error(f"'symlinks[{idx}]' missing required key '{key}'.")
                ok = False
            elif not isinstance(item[key], str):
                error(f"'symlinks[{idx}].{key}' must be a string.")
                ok = False
    return ok


def main():
    if not os.path.isfile(CONFIG_FILE):
        error(f"Configuration file '{CONFIG_FILE}' not found.")
        sys.exit(1)

    try:
        with open(CONFIG_FILE, "r", encoding="utf-8") as f:
            config = yaml.safe_load(f)
    except yaml.YAMLError as exc:
        error(f"YAML parsing error in '{CONFIG_FILE}': {exc}")
        sys.exit(1)
    except Exception as exc:
        error(f"Failed to read '{CONFIG_FILE}': {exc}")
        sys.exit(1)

    valid = True

    # Top‑level validation
    if not validate_top_level(config):
        valid = False
        # If top level is not a dict, further checks would raise exceptions.
        # Bail out early.
        sys.exit(1)

    # Optional sections
    if "repositories" in config:
        if not validate_repositories(config["repositories"]):
            valid = False

    if "symlinks" in config:
        if not validate_symlinks(config["symlinks"]):
            valid = False

    if not valid:
        sys.exit(1)

    print(f"Configuration '{CONFIG_FILE}' is valid.")
    sys.exit(0)


if __name__ == "__main__":
    main()
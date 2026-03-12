#!/usr/bin/env python3
"""
Generate a Markdown file (`docs/usage.md`) that contains the `--help`
output of every executable script in the repository.

The script scans the `bin/` directory (or any other directory you
specify) for files that are executable and have a `--help` flag.
It then writes a Jinja‑like template that MkDocs can render.

If no executable scripts are found, a placeholder message is written.
"""

import os
import subprocess
from pathlib import Path
import shlex

# Directory containing the CLI scripts – adjust if your layout differs
SCRIPTS_DIR = Path(__file__).resolve().parent.parent / "bin"

# Output markdown file
OUTPUT_FILE = Path(__file__).resolve().parent.parent / "docs" / "usage.md"

def is_executable(file_path: Path) -> bool:
    return os.access(file_path, os.X_OK) and file_path.is_file()

def get_help_output(script_path: Path) -> str:
    """Run `<script> --help` and capture stdout. Return empty string on failure."""
    try:
        result = subprocess.run(
            [str(script_path), "--help"],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            check=False,
            text=True,
            timeout=10,
        )
        return result.stdout.strip()
    except Exception as e:
        return f"Error retrieving help: {e}"

def main() -> None:
    if not SCRIPTS_DIR.is_dir():
        print(f"Scripts directory not found: {SCRIPTS_DIR}")
        return

    entries = []
    for script in sorted(SCRIPTS_DIR.iterdir()):
        if is_executable(script):
            help_text = get_help_output(script)
            if help_text:
                entries.append({"name": script.name, "output": help_text})

    # Simple Jinja‑like rendering – we avoid adding a full templating dependency
    header = "# Command‑Line Usage (auto‑generated)\n\n"
    header += "The following sections are generated automatically from the `--help` output of each executable script in the repository.\n\n"

    if not entries:
        body = "*No executable scripts with `--help` were found.*\n"
    else:
        body = ""
        for entry in entries:
            body += f"## {entry['name']}\n\n"
            body += "```text\n"
            body += f"{entry['output']}\n"
            body += "```\n\n"

    footer = "*To refresh this page, run `python scripts/generate_help.py` and commit the changes.*\n"

    OUTPUT_FILE.write_text(header + body + footer, encoding="utf-8")
    print(f"Generated usage documentation at {OUTPUT_FILE}")

if __name__ == "__main__":
    main()
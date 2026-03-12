#!/usr/bin/env bash
# dotfiles list – display managed files from dotfiles.yml
# Usage: dotfiles list [--json]

set -euo pipefail

# Determine repository root (assumes this script lives in <repo>/scripts)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
YAML_FILE="${REPO_ROOT}/dotfiles.yml"

if [[ ! -f "${YAML_FILE}" ]]; then
  echo "Error: ${YAML_FILE} not found." >&2
  exit 1
fi

# Convert YAML to a JSON array of entries.
# Expected YAML shape:
# files:
#   - src: path/to/source
#     dest: path/to/target
#     encrypted: true|false
#     vscode_extension: true|false
JSON_DATA=$(python3 - <<'PY'
import sys, json, yaml, pathlib

yaml_path = pathlib.Path(sys.argv[1])
with yaml_path.open() as f:
    data = yaml.safe_load(f)

entries = []
if isinstance(data, dict):
    items = data.get('files', [])
else:
    items = []

for item in items:
    if not isinstance(item, dict):
        continue
    src = item.get('src') or item.get('source') or ''
    dest = item.get('dest') or item.get('target') or ''
    encrypted = bool(item.get('encrypted', False))
    vscode_ext = bool(item.get('vscode_extension', False))
    entries.append({
        "src": src,
        "dest": dest,
        "encrypted": encrypted,
        "vscode_extension": vscode_ext
    })

print(json.dumps(entries))
PY "${YAML_FILE}")

# If --json flag is supplied, output raw JSON.
if [[ "${1:-}" == "--json" ]]; then
  echo "${JSON_DATA}"
  exit 0
fi

# Pretty‑print a table.
printf "%-30s %-30s %-10s %-15s\n" "Source" "Target" "Encrypted" "VSCode Ext"
printf "%-30s %-30s %-10s %-15s\n" "------" "------" "---------" "-----------"

python3 - <<'PY'
import sys, json, textwrap
data = json.loads(sys.stdin.read())
for entry in data:
    src = entry.get('src', '')
    dest = entry.get('dest', '')
    enc = 'yes' if entry.get('encrypted') else ''
    vs = 'yes' if entry.get('vscode_extension') else ''
    print(f"{src:<30} {dest:<30} {enc:<10} {vs:<15}")
PY <<< "${JSON_DATA}"
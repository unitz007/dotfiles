#!/usr/bin/env bash
# dotfiles backup script
# Creates a tar.gz archive of all managed dotfiles defined in dotfiles.yml.
# Supports optional GPG encryption, custom output path, and dry-run mode.

set -euo pipefail

# Default values
OUTPUT="${HOME}/dotfiles_backup.tar.gz"
GPG_KEY=""
DRY_RUN=false

# Helper functions
print_usage() {
    cat <<EOF
Usage: dotfiles backup [options]

Options:
  --output <path>   Specify backup file location (default: ${HOME}/dotfiles_backup.tar.gz)
  --gpg <key-id>    Encrypt the archive with the provided GPG key ID
  --dry-run         Show files that would be backed up without creating the archive
  -h, --help        Show this help message
EOF
    exit 0
}

error() {
    echo "Error: $*" >&2
    exit 1
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --output)
            if [[ -z "${2:-}" ]]; then error "--output requires a path argument"; fi
            OUTPUT="$2"
            shift 2
            ;;
        --gpg)
            if [[ -z "${2:-}" ]]; then error "--gpg requires a key-id argument"; fi
            GPG_KEY="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            print_usage
            ;;
        *)
            error "Unknown option: $1"
            ;;
    esac
done

# Resolve absolute path for output
OUTPUT="$(realpath -m "${OUTPUT}")"

# Determine directory of this script to locate dotfiles.yml
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_YML="${SCRIPT_DIR}/dotfiles.yml"

if [[ ! -f "${DOTFILES_YML}" ]]; then
    error "dotfiles.yml not found at ${DOTFILES_YML}"
fi

# Extract file list from dotfiles.yml.
# Expect a top-level key "files:" followed by a list of paths (one per line, prefixed with "- ").
# This simple parser works for the typical format used by this project.
mapfile -t FILES < <(
    awk '/^[[:space:]]*files:/ {found=1; next}
         found && /^[[:space:]]*-[[:space:]]*/ {gsub(/^[[:space:]]*-[[:space:]]*/, "", $0); print $0}
         found && !/^[[:space:]]*-/ {found=0}
    ' "${DOTFILES_YML}"
)

if [[ ${#FILES[@]} -eq 0 ]]; then
    error "No files found in dotfiles.yml under the 'files:' key."
fi

# Expand tilde and make paths absolute
EXPANDED_FILES=()
for f in "${FILES[@]}"; do
    # Preserve empty lines/comments
    [[ -z "$f" ]] && continue
    # Expand ~ and relative paths
    EXPANDED="$(realpath -m "${f/#\~/$HOME}")"
    if [[ ! -e "${EXPANDED}" ]]; then
        echo "Warning: Managed file does not exist and will be skipped: ${f}" >&2
        continue
    fi
    EXPANDED_FILES+=("${EXPANDED}")
done

if [[ ${#EXPANDED_FILES[@]} -eq 0 ]]; then
    error "No existing files to backup."
fi

if $DRY_RUN; then
    echo "Dry run: the following files would be backed up:"
    for f in "${EXPANDED_FILES[@]}"; do
        echo "  $f"
    done
    exit 0
fi

# Create temporary directory for tar
TMPDIR="$(mktemp -d)"
trap 'rm -rf "${TMPDIR}"' EXIT

# Preserve directory structure relative to HOME (or root if absolute)
# We'll store files preserving their original absolute paths inside the tar.
# To achieve that, we cd to / and add files with leading slash.
(
    cd /
    tar -czf "${OUTPUT}" "${EXPANDED_FILES[@]/#/}"
)

echo "Backup created at ${OUTPUT}"

# Optional GPG encryption
if [[ -n "${GPG_KEY}" ]]; then
    ENCRYPTED_OUTPUT="${OUTPUT}.gpg"
    gpg --yes --output "${ENCRYPTED_OUTPUT}" --encrypt --recipient "${GPG_KEY}" "${OUTPUT}"
    echo "Encrypted backup created at ${ENCRYPTED_OUTPUT}"
    # Optionally remove the unencrypted archive
    rm -f "${OUTPUT}"
fi
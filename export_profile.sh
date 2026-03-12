#!/usr/bin/env bash
# export_profile.sh – create a portable archive for a given dotfiles profile
#
# Usage: ./export_profile.sh <profile_name>
#
# The script reads `dotfiles.yml` (expected to be in the repository root) and
# extracts the list of files associated with the supplied profile. It then
# creates a temporary directory, copies the listed files preserving their
# relative paths, adds a minimal installer script, and finally packs everything
# into a self‑contained <profile>.tar.gz archive.
#
# The resulting archive can be distributed and installed on another machine by
# extracting it and running the bundled `install.sh` script.

set -euo pipefail

# ---------- Helper functions ----------
error() {
    echo "Error: $*" >&2
    exit 1
}

usage() {
    echo "Usage: $0 <profile_name>"
    exit 1
}

# ---------- Argument handling ----------
if [[ $# -ne 1 ]]; then
    usage
fi

PROFILE="$1"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_YML="${REPO_ROOT}/dotfiles.yml"

[[ -f "${DOTFILES_YML}" ]] || error "dotfiles.yml not found in repository root."

# ---------- Extract file list for the profile ----------
# We use a small Python snippet to parse the YAML safely.
FILE_LIST=$(python3 - <<PYTHON
import sys, yaml, os
repo_root = os.getenv('REPO_ROOT')
dotfiles_path = os.path.join(repo_root, 'dotfiles.yml')
with open(dotfiles_path, 'r') as f:
    data = yaml.safe_load(f)

profile = sys.argv[1]
# Support both top‑level mapping or a 'profiles' key.
files = []
if isinstance(data, dict):
    if 'profiles' in data and isinstance(data['profiles'], dict):
        files = data['profiles'].get(profile, [])
    else:
        files = data.get(profile, [])
if not isinstance(files, list):
    files = []

# Print one file per line, ignoring empty entries.
for item in files:
    if item:
        print(item)
PYTHON "${PROFILE}")

if [[ -z "${FILE_LIST}" ]]; then
    error "No files found for profile '${PROFILE}'. Check dotfiles.yml."
fi

# ---------- Prepare temporary workspace ----------
TMPDIR="$(mktemp -d)"
cleanup() {
    rm -rf "${TMPDIR}"
}
trap cleanup EXIT

# Copy each listed file preserving directory structure.
while IFS= read -r relpath; do
    src_path="${REPO_ROOT}/${relpath}"
    if [[ ! -e "${src_path}" ]]; then
        echo "Warning: source file '${relpath}' does not exist – skipping."
        continue
    fi
    dest_dir="${TMPDIR}/$(dirname "${relpath}")"
    mkdir -p "${dest_dir}"
    cp -a "${src_path}" "${TMPDIR}/${relpath}"
done <<< "${FILE_LIST}"

# ---------- Create minimal installer ----------
INSTALLER_PATH="${TMPDIR}/install.sh"
cat > "${INSTALLER_PATH}" <<'EOS'
#!/usr/bin/env bash
# Minimal installer for a dotfiles profile archive.
# It copies every file (except this script) into the user's home directory,
# preserving the original relative paths.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Installing profile files to \$HOME..."

# Find all regular files except the installer itself.
while IFS= read -r -d '' src; do
    rel_path="${src#${SCRIPT_DIR}/}"
    dest_path="${HOME}/${rel_path}"
    mkdir -p "$(dirname "${dest_path}")"
    cp -a "${src}" "${dest_path}"
done < <(find "${SCRIPT_DIR}" -type f ! -name install.sh -print0)

echo "Installation complete."
EOS
chmod +x "${INSTALLER_PATH}"

# ---------- Create the archive ----------
OUTPUT_ARCHIVE="${REPO_ROOT}/${PROFILE}.tar.gz"
tar -czf "${OUTPUT_ARCHIVE}" -C "${TMPDIR}" .

echo "Profile '${PROFILE}' exported to '${OUTPUT_ARCHIVE}'."
echo "To install, extract the archive and run ./install.sh"
#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
  # Create a temporary repository layout
  TMP_REPO="$(mktemp -d)"
  export REPO_ROOT="${TMP_REPO}"
  mkdir -p "${TMP_REPO}/scripts"
  cp "${BATS_TEST_DIRNAME}/../scripts/list.sh" "${TMP_REPO}/scripts/"

  # Write a minimal dotfiles.yml
  cat > "${TMP_REPO}/dotfiles.yml" <<'YAML'
files:
  - src: .bashrc
    dest: ~/.bashrc
    encrypted: false
  - src: .vscode/extensions.json
    dest: ~/.vscode/extensions.json
    vscode_extension: true
YAML

  # Make a wrapper that mimics the real CLI but points to our temp repo
  cat > "${TMP_REPO}/dotfiles" <<'EOS'
#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="${REPO_ROOT}/scripts"
CMD="${1:-}"
shift || true
case "${CMD}" in
  list)
    exec "${SCRIPTS_DIR}/list.sh" "$@"
    ;;
  *)
    echo "Unsupported in test" >&2
    exit 1
    ;;
esac
EOS
  chmod +x "${TMP_REPO}/dotfiles"
  PATH="${TMP_REPO}:$PATH"
}

teardown() {
  rm -rf "${TMP_REPO}"
}

@test "dotfiles list prints a table" {
  run dotfiles list
  assert_success
  assert_output --partial ".bashrc"
  assert_output --partial "~/.bashrc"
  assert_output --partial "VSCode Ext"
  assert_output --partial "yes"
}

@test "dotfiles list --json outputs valid JSON" {
  run dotfiles list --json
  assert_success
  # Verify JSON is an array with two objects
  echo "${output}" | python3 -c 'import sys, json; data=json.load(sys.stdin); assert isinstance(data, list) and len(data)==2'
}
#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    # Create a temporary dotfiles.yml for testing
    TMPDIR=$(mktemp -d)
    export TMPDIR
    cd "$TMPDIR"
    cat > dotfiles.yml <<'EOF'
fonts:
  - "https://example.com/fakefont.ttf"
  - "font-awesome"
EOF
    # Mock yq to output the fonts array
    mkdir -p bin
    cat > bin/yq <<'EOS'
#!/usr/bin/env bash
if [[ "$1" == "eval" ]]; then
    shift
    # Simple parser for the test yaml
    while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]*-\ (.*) ]]; then
            echo "${BASH_REMATCH[1]}"
        fi
    done
fi
EOS
    chmod +x bin/yq
    PATH="$PWD/bin:$PATH"
    # Mock package managers to avoid real installs
    cat > bin/brew <<'EOS'
#!/usr/bin/env bash
echo "brew install $@"
EOS
    cat > bin/apt-get <<'EOS'
#!/usr/bin/env bash
echo "apt-get install $@"
EOS
    cat > bin/choco <<'EOS'
#!/usr/bin/env bash
echo "choco install $@"
EOS
    cat > bin/curl <<'EOS'
#!/usr/bin/env bash
echo "curl -L -o $3 $2"
EOS
    chmod +x bin/brew bin/apt-get bin/choco bin/curl
    PATH="$PWD/bin:$PATH"
}

teardown() {
    rm -rf "$TMPDIR"
}

@test "install_fonts.sh processes URLs and package names" {
    run bash "$PWD/../install_fonts.sh"
    assert_success
    # Expect download message for the URL
    assert_output --partial "Downloading https://example.com/fakefont.ttf"
    # Expect brew/apt/choco install for the package name (depends on OS)
    case "$(uname -s)" in
        Darwin) assert_output --partial "brew install font-awesome" ;;
        Linux)  assert_output --partial "apt-get install font-awesome" ;;
        CYGWIN*|MINGW*|MSYS*) assert_output --partial "choco install font-awesome" ;;
    esac
}
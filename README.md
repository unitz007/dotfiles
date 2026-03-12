# sync_dotfiles

A simple Bash utility to keep your dotfiles in sync across machines.

## Features

- Synchronize regular dotfiles defined in `dotfiles.yml`.
- **GPG‑encrypted backup support** for sensitive files (e.g., API keys, credentials).

## Configuration (`dotfiles.yml`)

```yaml
files:
  - ~/.bashrc
  - ~/.vimrc

encrypted:
  - ~/.aws/credentials
  - ~/.myapp/secret.conf

# Optional: default GPG key ID used for encryption
gpg_id: "0xDEADBEEF"
```

## Usage

```bash
# Basic sync (no encryption handling)
./sync_dotfiles.sh

# Encrypt sensitive files using a specific GPG key
./sync_dotfiles.sh --gpg-id 0xDEADBEEF

# Decrypt all encrypted files locally
./sync_dotfiles.sh --decrypt
```

### Arguments

| Argument      | Description                                                                 |
|---------------|-----------------------------------------------------------------------------|
| `--gpg-id`    | GPG key identifier to use for encryption. Overrides `gpg_id` in the YAML. |
| `--decrypt`   | Decrypt all files listed under `encrypted:` back to their original names.  |

When encrypting, each file listed under `encrypted:` is transformed into `<file>.gpg`.  
The encrypted version is added to the Git commit, while the plaintext version is **not** staged (ensure it is ignored via `.gitignore` if desired).

## Installation

```bash
# Ensure yq and GPG are installed
sudo apt-get install -y yq gnupg

# Make the script executable
chmod +x sync_dotfiles.sh
```

## License

MIT © Your Name
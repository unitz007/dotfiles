# dotfiles

*(existing README content...)*

## Development

*(existing development section...)*

## Git Hooks

To help keep the repository in a consistent state and avoid committing malformed configuration files, a **pre‑commit hook** is provided.

### What the hook does

1. Runs `status.sh --json` to verify the repository’s internal state.
2. Validates `dotfiles.yml` against the JSON schema defined in `dotfiles.schema.json`.
3. Aborts the commit if any of the above steps fail.

### Installing the hook (optional)

The hook is not installed automatically – you can add it to your local clone when you need it.

```bash
# From the repository root
./setup-hooks.sh
```

Running the script copies `hooks/pre-commit` into `.git/hooks/pre-commit` and makes it executable.

### Skipping the hook

If you prefer not to use the hook, simply do not run `setup-hooks.sh`. The repository works without it; the hook only adds an extra safety net.

### Dependencies

- **yq** (for YAML → JSON conversion) – required only if `ajv` is used.
- **ajv** (Node.js JSON‑Schema validator) **or** **Python 3** with the `jsonschema` package.
- `status.sh` (already part of the repository).

Make sure the above tools are available in your `PATH` before committing.

*(rest of README...)*
# Project Title

<!-- Existing README content ... -->

## Pre‑commit Hook: Validate `dotfiles.yml`

To ensure that `dotfiles.yml` always conforms to the expected structure, a pre‑commit hook is provided. The hook validates the file against a JSON Schema and aborts the commit if validation fails.

### Installation

1. **Install a JSON Schema validator**

   - **Using `ajv-cli` (recommended)**  
     ```bash
     npm install -g ajv-cli
     ```

   - **Or using Python's `jsonschema` library**  
     ```bash
     pip install pyyaml jsonschema
     ```

   - *(Optional)* Install `yq` for faster YAML‑to‑JSON conversion when using `ajv-cli`  
     ```bash
     pip install yq   # or brew install yq, etc.
     ```

2. **Copy the hook into your repository**

   ```bash
   cp .git/hooks/pre-commit .git/hooks/pre-commit
   chmod +x .git/hooks/pre-commit
   ```

   > **Note:** The hook is already present in the repository at `.git/hooks/pre-commit`. The above command ensures it has the executable bit set.

3. **Verify the hook works**

   ```bash
   # Make a change to dotfiles.yml that violates the schema
   # Then try to commit
   git add dotfiles.yml
   git commit -m "Test invalid dotfiles"
   ```

   You should see validation errors and the commit will be aborted.

### Customising the Schema

The schema file `dotfiles.schema.json` lives at the repository root. Adjust it to reflect the exact structure you expect in `dotfiles.yml`. After updating the schema, the pre‑commit hook will automatically use the new rules.

### Troubleshooting

- **`ajv` not found:** The hook falls back to the Python validator if `ajv` is unavailable.
- **Missing `yq`:** If `yq` is not installed, the hook will convert YAML to JSON using a small Python snippet.
- **Permission denied:** Ensure the hook file is executable (`chmod +x .git/hooks/pre-commit`).

Happy committing! 🎉
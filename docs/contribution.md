# Contribution Guidelines

We welcome contributions! Follow these steps to get your changes merged.

## Getting Started

1. **Fork the repository** on GitHub.
2. **Clone your fork** locally:

   ```bash
   git clone https://github.com/yourusername/dotfiles.git
   cd dotfiles
   ```

3. **Create a new branch** for your feature or bug‑fix:

   ```bash
   git checkout -b feature/awesome-feature
   ```

## Development Workflow

- **Run tests** (if any) and linting before committing:

  ```bash
  ./scripts/lint.sh
  ```

- **Update documentation** – If you add a new script or option, run the help‑generation script (see below) and commit the updated docs.

- **Commit messages** – Use clear, concise messages. Follow the [Conventional Commits](https://www.conventionalcommits.org/) style.

## Generating Help Output for Docs

The documentation site automatically includes the latest `--help` output from all CLI scripts.

```bash
# From the repository root
python scripts/generate_help.py
```

This command regenerates `docs/usage.md`. Commit the changes together with your code.

## Pull Request Process

1. Push your branch to your fork:

   ```bash
   git push origin feature/awesome-feature
   ```

2. Open a **Pull Request** against the `main` branch of the upstream repository.
3. Ensure the CI checks pass (documentation build, linting, etc.).
4. Address any review feedback.

## Code Style

- Bash scripts should be POSIX‑compatible where possible.
- Use `shellcheck` for linting.
- Python scripts (if added) should follow PEP 8.

## Reporting Issues

If you encounter a bug or have a feature request, please open an issue with:

- A clear title.
- Steps to reproduce (for bugs).
- Expected vs. actual behavior.

--- 

*For a full overview of the project, see the [Installation](installation.md) page.*
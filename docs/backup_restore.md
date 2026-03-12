# Backup & Restore Workflow

The dotfiles project includes a built‑in backup system that stores your configuration files in a separate Git repository. This ensures you can restore your environment on any machine.

## How It Works

1. **Backup Repository** – A dedicated Git repo (e.g., `git@github.com:yourusername/dotfiles-backup.git`) stores a snapshot of all tracked dotfiles.
2. **Scheduled Jobs** – When enabled, a cron job (or systemd timer) runs `dotfiles backup` at the interval defined in `~/.dotfiles.yml`.
3. **Restore** – On a new machine, after cloning the main dotfiles repo, run `dotfiles restore` to pull the latest backup.

## Enabling Backups

Add the following to `~/.dotfiles.yml`:

```yaml
backup:
  enabled: true
  remote: "git@github.com:yourusername/dotfiles-backup.git"
  schedule: "daily"
```

Then apply the configuration:

```bash
dotfiles apply
```

The `apply` command will:

- Initialize the backup repository if it does not exist.
- Install a cron entry (or systemd timer) that runs `dotfiles backup` according to the schedule.

## Manual Backup

```bash
dotfiles backup
```

This command:

- Commits any changes to the tracked dotfiles.
- Pushes the commit to the remote backup repository.

## Restoring From Backup

On a fresh machine:

```bash
dotfiles restore
```

The command will:

- Clone the backup repository into `~/.dotfiles_backup`.
- Symlink the backed‑up files into their proper locations.
- Optionally merge with any existing local configuration (you will be prompted).

## Troubleshooting

- **Authentication errors** – Ensure SSH keys are added to your GitHub account and the remote URL uses SSH.
- **Conflicts** – If a file has diverged locally, `dotfiles restore` will ask whether to keep the local version, overwrite, or create a merge conflict file (`.dotfiles.conflict`).

--- 

*For more details on component configuration, see the [Components](components.md) page.*
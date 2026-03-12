# Backup Script

This repository provides a simple Bash script (`backup.sh`) to create compressed backups of your home directory (or any other paths you configure) and automatically prune old backups based on a configurable rotation policy.

## Usage

```bash
./backup.sh
```

The script will:

1. Create a timestamped archive (`backup-YYYYMMDD-HHMMSS.tar.gz`) in the backup directory.
2. Log actions to `~/backup.log`.
3. Prune old archives according to the rotation policy defined in `dotfiles.yml`.

## Configuration

### Environment Variables

| Variable      | Default                     | Description                              |
|---------------|-----------------------------|------------------------------------------|
| `DOTFILES_DIR`| `$HOME/.dotfiles`           | Directory containing `dotfiles.yml`.    |
| `BACKUP_DIR`  | `$HOME/backups`             | Where backup archives are stored.        |
| `LOG_FILE`    | `$HOME/backup.log`          | Path to the log file.                    |

### Rotation Policy (`dotfiles.yml`)

Create (or edit) a `dotfiles.yml` file inside your `DOTFILES_DIR`. The script reads the following optional keys:

```yaml
keep_daily: 7      # Keep the most recent 7 daily backups
keep_weekly: 4     # Keep the most recent 4 weekly backups (≈ 4 × 7 days)
keep_monthly: 12   # Keep the most recent 12 monthly backups (≈ 12 × 30 days)
```

- **Daily** – Retains the newest *N* backups (each backup is considered a “daily” snapshot).
- **Weekly** – Retains backups up to *N* weeks old (approximated as 7 days per week).
- **Monthly** – Retains backups up to *N* months old (approximated as 30 days per month).

If a key is omitted or set to `0`, that part of the policy is ignored. When all values are `0` or the file is missing, the script will **not** prune any backups.

#### Example

```yaml
keep_daily: 5
keep_weekly: 2
keep_monthly: 6
```

With the above configuration:

- The 5 most recent backups are always kept.
- Backups up to 14 days old are kept (2 weeks).
- Backups up to 180 days old are kept (6 months).

The script calculates the maximum age among the three settings and removes any archive older than that threshold, logging each deletion.

## Logging

All actions, including creation of new archives and removal of old ones, are appended to the log file (`$HOME/backup.log` by default) with timestamps.

## License

MIT © Your Name
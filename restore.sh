#!/usr/bin/env bash
# Restore script with dry‑run support

set -euo pipefail

# Global dry‑run flag (0 = off, 1 = on)
DRY_RUN=0

# ----------------------------------------------------------------------
# Helper functions
# ----------------------------------------------------------------------
print_usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
  -n, --dry-run        Show actions without executing them.
  -h, --help           Display this help message.
  ...                  (other options remain unchanged)
EOF
}

# Parse command‑line arguments early to capture dry‑run flag
while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      print_usage
      exit 0
      ;;
    *) # pass through other arguments for later processing
      break
      ;;
  esac
done

# ----------------------------------------------------------------------
# Command wrappers – they either execute the real command or echo it
# ----------------------------------------------------------------------
exec_cmd() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[dry-run] $*"
  else
    "$@"
  fi
}

# Override common filesystem commands with wrappers
cp()   { exec_cmd command cp   "$@"; }
mv()   { exec_cmd command mv   "$@"; }
ln()   { exec_cmd command ln   "$@"; }
rm()   { exec_cmd command rm   "$@"; }

# ----------------------------------------------------------------------
# Rest of the original restore logic (unchanged except that it now
# uses the overridden cp/mv/ln/rm functions)
# ----------------------------------------------------------------------
# Example placeholder – replace with the actual restore implementation
# -------------------------------------------------
# The original script likely contains many calls such as:
#   cp -r backup dest
#   mv old new
#   ln -s target link
#   rm -f file
# Those calls will now automatically respect the DRY_RUN flag because
# we have overridden the commands above.
# -------------------------------------------------

# If the original script defines its own functions named cp/mv/ln/rm,
# rename them before this block to avoid clashes.

# End of restore.sh
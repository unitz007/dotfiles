#!/usr/bin/env bash
set -euo pipefail

# ── Platform guard ──────────────────────────────────────────────────────────
if [[ "$(uname)" != "Darwin" ]]; then
  echo "Error: This script is intended for macOS only (detected: $(uname))." >&2
  exit 1
fi

# ── Helper ──────────────────────────────────────────────────────────────────
apply_defaults() {
  local description="$1"
  shift
  echo "→ Setting: ${description}"
  defaults write "$@"
}

# ── Keyboard & Trackpad ────────────────────────────────────────────────────
apply_defaults "Short delay until key repeat" -g InitialKeyRepeat -int 15
apply_defaults "Fast key repeat rate" -g KeyRepeat -int 2
apply_defaults "Disable press-and-hold for key repeat" -g ApplePressAndHoldEnabled -bool false

# ── Dock ────────────────────────────────────────────────────────────────────
apply_defaults "Auto-hide Dock" com.apple.dock autohide -bool true
apply_defaults "Remove auto-hide delay" com.apple.dock autohide-delay -float 0
apply_defaults "Faster Dock show animation" com.apple.dock autohide-time-modifier -float 0.5
apply_defaults "Disable recent apps in Dock" com.apple.dock show-recents -bool false

# Clear default Dock icons (destructive — removes all pinned apps).
# Uncomment the next line to enable:
# apply_defaults "Clear default Dock icons" com.apple.dock persistent-apps -array

killall Dock || true

# ── Finder ──────────────────────────────────────────────────────────────────
apply_defaults "Show hidden files in Finder" com.apple.finder AppleShowAllFiles -bool true
apply_defaults "Show all file extensions in Finder" com.apple.finder AppleShowAllExtensions -bool true
apply_defaults "Show path bar in Finder" com.apple.finder ShowPathbar -bool true
apply_defaults "Show status bar in Finder" com.apple.finder ShowStatusBar -bool true
apply_defaults "Show full POSIX path in Finder title" com.apple.finder _FXShowPosixPathInTitle -bool true
apply_defaults "Disable extension change warning in Finder" com.apple.finder FXEnableExtensionChangeWarning -bool false
apply_defaults "Hide icons on Desktop" com.apple.finder CreateDesktop -bool false

killall Finder || true

# ── Screenshots ─────────────────────────────────────────────────────────────
mkdir -p $SCREENSHOT_DIR
apply_defaults "Set screenshot save location to $SCREENSHOT_DIR" com.apple.screencapture location -string "$SCREENSHOT_DIR"
apply_defaults "Set screenshot format to PNG" com.apple.screencapture type -string "png"

killall SystemUIServer || true

# ── Network Volumes (.DS_Store) ────────────────────────────────────────────
apply_defaults "Disable .DS_Store creation on network volumes" com.apple.desktopservices DSDontWriteNetworkStores -bool true

# ── Miscellaneous ───────────────────────────────────────────────────────────
apply_defaults "Disable window animations" -g NSAutomaticWindowAnimationsEnabled -bool false
apply_defaults "Displays have separate Spaces" com.apple.spaces spans-displays -bool false
apply_defaults "Expand save panel by default" NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
apply_defaults "Expand open panel by default" NSGlobalDomain NSNavPanelExpandedStateForOpenMode -bool true
apply_defaults "Quit printer app when jobs complete" com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# ── Summary ─────────────────────────────────────────────────────────────────
echo ""
echo "✅ macOS defaults applied successfully."
echo "⚠️  Some changes require logging out and back in (or restarting) to take full effect."
echo "   At minimum, restart Dock and Finder (already done)."

exit 0
#!/usr/bin/env bash
#
# macOS System Defaults
#
# Applies sensible macOS system defaults for a comfortable development
# environment. Covers dock behavior, keyboard/trackpad settings, Finder
# preferences, screenshot location, and other commonly adjusted settings.
#
# Usage:
#   ./macos/defaults.sh
#   bash macos/defaults.sh
#
# This script is idempotent and safe to re-run. All `defaults write`
# commands are inherently idempotent — writing the same value again is
# a no-op and produces no error.
#
# Note: Some changes require logging out/in or restarting the affected
# application to take effect.

# Guard clause — ensure we're running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
  echo "Error: This script must be run on macOS." >&2
  exit 1
fi

# Helper function: set a macOS default and print what changed
# Usage: set_default <domain> <key> <value> [description]
set_default() {
  local domain="$1"
  local key="$2"
  local value="$3"
  local description="${4:-Setting $domain $key to $value}"
  echo "→ $description"
  defaults write "$domain" "$key" "$value"
}

# ── Dock ──────────────────────────────────────────────────────────────────────

echo ""
echo "Dock"

set_default com.apple.dock autohide -bool true "Enable dock auto-hide"
set_default com.apple.dock autohide-delay -float 0 "Remove dock auto-hide delay"
set_default com.apple.dock autohide-time-modifier -float 0.5 "Speed up dock show/hide animation"
set_default com.apple.dock tilesize -int 48 "Set dock icon size"
set_default com.apple.dock show-recents -bool false "Disable recent apps in dock"

killall Dock 2>/dev/null

# ── Keyboard & Input ─────────────────────────────────────────────────────────

echo ""
echo "Keyboard & Input"

set_default NSGlobalDomain KeyRepeat -int 2 "Set key repeat rate to fast"
set_default NSGlobalDomain InitialKeyRepeat -int 15 "Set initial key repeat delay to short"
set_default NSGlobalDomain AppleKeyboardUIMode -int 3 "Enable full keyboard access (Tab in dialogs)"
set_default NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false "Disable auto-correct"

# ── Trackpad ──────────────────────────────────────────────────────────────────

echo ""
echo "Trackpad"

set_default com.apple.AppleMultitouchTrackpad Clicking -bool true "Enable tap to click"
set_default com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true "Enable tap to click (Bluetooth)"
set_default NSGlobalDomain com.apple.mouse.tapBehavior -int 1 "Enable tap to click for current user"

# ── Finder ────────────────────────────────────────────────────────────────────

echo ""
echo "Finder"

set_default com.apple.finder ShowStatusBar -bool true "Show Finder status bar"
set_default com.apple.finder ShowPathbar -bool true "Show Finder path bar"
set_default com.apple.finder FXDefaultSearchScope -string "SCcf" "Set default Finder search to current folder"
set_default com.apple.finder AppleShowAllFiles -bool true "Show hidden files in Finder"
set_default com.apple.finder FXEnableExtensionChangeWarning -bool false "Disable file extension change warning"

killall Finder 2>/dev/null

# ── Screenshots ───────────────────────────────────────────────────────────────

echo ""
echo "Screenshots"

set_default com.apple.screencapture location -string "${HOME}/Desktop" "Set screenshot save location to Desktop"
set_default com.apple.screencapture type -string "png" "Set screenshot format to PNG"

# ── Misc / UI ─────────────────────────────────────────────────────────────────

echo ""
echo "Misc / UI"

set_default NSGlobalDomain NSWindowResizeTime -float 0.001 "Speed up window resize animations"
set_default com.apple.menuextra.battery ShowPercent -string "YES" "Show battery percentage in menu bar"
set_default com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates -int 1 "Enable automatic macOS updates"
set_default com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true "Prevent Time Machine from prompting for new disks"

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
echo "macOS defaults applied. Some changes require a restart or logout/login to take effect."

#!/bin/bash

set -euo pipefail

PLIST_NAME="com.cursorsniper.app.plist"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
PLIST_PATH="$LAUNCH_AGENTS_DIR/$PLIST_NAME"
INSTALL_DIR="$HOME/Library/Application Support/cursor-sniper"

echo "Removing Cursor Sniper from startup..."

UID_DOMAIN="gui/$(id -u)"

if [ -f "$PLIST_PATH" ]; then
  echo "Unloading launch agent..."
  launchctl bootout "$UID_DOMAIN" "$PLIST_PATH" >/dev/null 2>&1 || true
  rm -f "$PLIST_PATH"
else
  echo "No LaunchAgent plist found at $PLIST_PATH"
fi

if [ -d "$INSTALL_DIR" ]; then
  echo "Removing installed binary at $INSTALL_DIR"
  rm -f "$INSTALL_DIR/cursor-sniper" || true
  rmdir "$INSTALL_DIR" 2>/dev/null || true
fi

echo "✅ Removed. You can still run it manually with: swift run cursor-sniper"
echo "Logs (if any) are at: $HOME/Library/Logs/cursor-sniper*.log"
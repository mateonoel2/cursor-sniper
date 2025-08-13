#!/bin/bash

set -euo pipefail

echo "Setting up Cursor Sniper to run on startup..."

PLIST_NAME="com.cursorsniper.app.plist"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
INSTALL_DIR="$HOME/Library/Application Support/cursor-sniper"
STDOUT_LOG="$HOME/Library/Logs/cursor-sniper.log"
STDERR_LOG="$HOME/Library/Logs/cursor-sniper-error.log"

mkdir -p "$LAUNCH_AGENTS_DIR"
mkdir -p "$INSTALL_DIR"
mkdir -p "$(dirname "$STDOUT_LOG")"

echo "Building release binary..."
BIN_DIR=$(swift build -c release --show-bin-path)
BIN_PATH="$BIN_DIR/cursor-sniper"

if [ ! -f "$BIN_PATH" ]; then
    echo "Build did not produce expected binary at: $BIN_PATH"
    exit 1
fi

echo "Installing binary to: $INSTALL_DIR"
cp -f "$BIN_PATH" "$INSTALL_DIR/cursor-sniper"
chmod +x "$INSTALL_DIR/cursor-sniper"

PLIST_PATH="$LAUNCH_AGENTS_DIR/$PLIST_NAME"

cat > "$PLIST_PATH" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.cursorsniper.app</string>
    <key>ProgramArguments</key>
    <array>
        <string>$INSTALL_DIR/cursor-sniper</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>$STDOUT_LOG</string>
    <key>StandardErrorPath</key>
    <string>$STDERR_LOG</string>
    <key>WorkingDirectory</key>
    <string>$INSTALL_DIR</string>
    <key>LimitLoadToSessionType</key>
    <string>Aqua</string>
    <key>ProcessType</key>
    <string>Interactive</string>
</dict>
</plist>
EOF

echo "(Re)loading launch agent..."
UID_DOMAIN="gui/$(id -u)"
launchctl bootout "$UID_DOMAIN" "$PLIST_PATH" >/dev/null 2>&1 || true
launchctl bootstrap "$UID_DOMAIN" "$PLIST_PATH"
launchctl enable "$UID_DOMAIN/com.cursorsniper.app"
launchctl kickstart -k "$UID_DOMAIN/com.cursorsniper.app"

echo "✅ Installed. Logs: $STDOUT_LOG, $STDERR_LOG"
echo "You can inspect with: launchctl print $UID_DOMAIN/com.cursorsniper.app"
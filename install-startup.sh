#!/bin/bash

# Get the current directory (where the cursor-sniper project is located)
PROJECT_DIR="$(pwd)"
EXECUTABLE_PATH="$PROJECT_DIR/.build/debug/cursor-sniper"
PLIST_NAME="com.cursorsniper.app.plist"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"

echo "Setting up Cursor Sniper to run on startup..."

# Build the project first
echo "Building the project..."
swift build

if [ $? -ne 0 ]; then
    echo "Build failed! Please fix any build errors first."
    exit 1
fi

# Create LaunchAgents directory if it doesn't exist
mkdir -p "$LAUNCH_AGENTS_DIR"

# Create the plist file
cat > "$LAUNCH_AGENTS_DIR/$PLIST_NAME" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.cursorsniper.app</string>
    <key>ProgramArguments</key>
    <array>
        <string>$EXECUTABLE_PATH</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>$HOME/Library/Logs/cursor-sniper.log</string>
    <key>StandardErrorPath</key>
    <string>$HOME/Library/Logs/cursor-sniper-error.log</string>
    <key>WorkingDirectory</key>
    <string>$PROJECT_DIR</string>
</dict>
</plist>
EOF

# Load the launch agent
echo "Loading launch agent..."
launchctl load "$LAUNCH_AGENTS_DIR/$PLIST_NAME"

if [ $? -eq 0 ]; then
    echo "✅ Cursor Sniper has been successfully set up to run on startup!"
    echo ""
    echo "📍 Configuration file: $LAUNCH_AGENTS_DIR/$PLIST_NAME"
    echo "📍 Logs will be written to: $HOME/Library/Logs/cursor-sniper.log"
    echo "📍 Error logs: $HOME/Library/Logs/cursor-sniper-error.log"
    echo ""
    echo "The app should start automatically now and on every boot."
    echo "You can check if it's running with: ps aux | grep cursor-sniper"
else
    echo "❌ Failed to load launch agent. Please check for errors."
    exit 1
fi 
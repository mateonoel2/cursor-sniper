#!/bin/bash

PLIST_NAME="com.cursorsniper.app.plist"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
PLIST_PATH="$LAUNCH_AGENTS_DIR/$PLIST_NAME"

echo "Removing Cursor Sniper from startup..."

# Check if the plist file exists
if [ ! -f "$PLIST_PATH" ]; then
    echo "❌ Cursor Sniper startup service not found."
    echo "The file $PLIST_PATH does not exist."
    exit 1
fi

# Unload the launch agent
echo "Unloading launch agent..."
launchctl unload "$PLIST_PATH"

# Remove the plist file
echo "Removing configuration file..."
rm "$PLIST_PATH"

if [ $? -eq 0 ]; then
    echo "✅ Cursor Sniper has been successfully removed from startup!"
    echo ""
    echo "The app will no longer start automatically on boot."
    echo "You can still run it manually with: swift run cursor-sniper"
    echo ""
    echo "Log files (if any) are still available at:"
    echo "📍 $HOME/Library/Logs/cursor-sniper.log"
    echo "📍 $HOME/Library/Logs/cursor-sniper-error.log"
else
    echo "❌ Failed to remove startup service. Please check for errors."
    exit 1
fi 
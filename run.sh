#!/bin/bash

echo "Starting Cursor Sniper..."

# Build first
swift build

if [ $? -eq 0 ]; then
    echo "Build successful! Starting application..."
    echo ""
    echo "Press Cmd+Ctrl+1 to move cursor to center of first display"
    echo "Press Cmd+Ctrl+2 to move cursor to center of second display"
    echo "Press Ctrl+C to quit"
    echo ""
    
    # Run the application
    swift run cursor-sniper
else
    echo "Build failed!"
    exit 1
fi 
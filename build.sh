#!/bin/bash

echo "Building Cursor Sniper..."

# Build the Swift package
swift build

if [ $? -eq 0 ]; then
    echo "Build successful!"
    echo "You can run the application with: swift run cursor-sniper"
    echo "Or run the built executable: ./.build/debug/cursor-sniper"
else
    echo "Build failed!"
    exit 1
fi 
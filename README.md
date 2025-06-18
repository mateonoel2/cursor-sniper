# Cursor Sniper

A macOS application that allows you to quickly jump your cursor to the center of any display using global hotkeys.

## Features

- **Cmd+Ctrl+1**: Move cursor to center of first display
- **Cmd+Ctrl+2**: Move cursor to center of second display
- Automatically detects all connected displays
- Works system-wide (global hotkeys)

## Requirements

- macOS 10.15 or later
- Xcode Command Line Tools (for Swift compiler)

## Installation

1. Make sure you have Xcode Command Line Tools installed:
   ```bash
   xcode-select --install
   ```

2. Make the build script executable:
   ```bash
   chmod +x build.sh
   ```

3. Build the application:
   ```bash
   ./build.sh
   ```

## Usage

1. Run the application:
   ```bash
   swift run cursor-sniper
   ```
   
   Or run the built executable:
   ```bash
   ./.build/debug/cursor-sniper
   ```

2. The application will start and register the global hotkeys. You'll see confirmation messages.

3. Use the hotkeys:
   - Press **Cmd+Ctrl+1** to move cursor to center of first display
   - Press **Cmd+Ctrl+2** to move cursor to center of second display

4. To quit, press **Ctrl+C** in the terminal where the application is running.

## Permissions

When you first run the application, macOS may ask for accessibility permissions. You'll need to:

1. Go to **System Preferences** → **Security & Privacy** → **Privacy** → **Accessibility**
2. Click the lock icon and enter your password
3. Add your terminal application (Terminal.app or iTerm2) to the list
4. Enable the checkbox next to it

This is required for the application to register global hotkeys and control the cursor position.

## Extending the Application

The code is structured to make it easy to add more hotkeys. To add a new hotkey:

1. Add a new hotkey reference and ID in the `CursorSniper` class
2. Register the new hotkey in `setupHotKeys()`
3. Handle the new hotkey in `handleHotKeyEvent()`
4. Implement the desired functionality

## Running on Startup

To have Cursor Sniper start automatically when you log in:

### Install Startup Service
```bash
./install-startup.sh
```

This will:
- Build the application
- Create a macOS Launch Agent
- Start the service immediately
- Set it to run automatically on every boot

### Remove Startup Service
```bash
./uninstall-startup.sh
```

### Check Service Status
```bash
# Check if the process is running
ps aux | grep cursor-sniper

# Check launch agent status
launchctl list | grep cursorsniper
```

### View Logs
```bash
# View application logs
tail -f ~/Library/Logs/cursor-sniper.log

# View error logs
tail -f ~/Library/Logs/cursor-sniper-error.log
```

## Troubleshooting

- **Hotkeys not working**: Make sure you've granted accessibility permissions
- **Display not found**: The application automatically detects displays. If you have fewer than 2 displays, Cmd+Ctrl+2 will show a message
- **Build errors**: Make sure you have the latest Xcode Command Line Tools installed
- **Service not starting**: Check the error logs at `~/Library/Logs/cursor-sniper-error.log`
- **Service running multiple times**: Run `./uninstall-startup.sh` then `./install-startup.sh` to reset

## Technical Details

- Written in Swift using Cocoa and Carbon frameworks
- Uses `RegisterEventHotKey` for global hotkey registration
- Uses `CGWarpMouseCursorPosition` for cursor movement
- Uses `CGGetActiveDisplayList` for display detection 
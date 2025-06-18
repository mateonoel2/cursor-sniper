import Cocoa
import Carbon
import CoreGraphics

class CursorSniper {
    private var hotKeyRef1: EventHotKeyRef?
    private var hotKeyRef2: EventHotKeyRef?
    private let hotKeySignature: OSType = fourCharCodeFrom("cspr")
    private let hotKeyID1: UInt32 = 1
    private let hotKeyID2: UInt32 = 2
    
    init() {
        setupHotKeys()
    }
    
    private func setupHotKeys() {
        var hotKeyID1 = EventHotKeyID(signature: hotKeySignature, id: hotKeyID1)
        let status1 = RegisterEventHotKey(
            UInt32(kVK_ANSI_1),
            UInt32(cmdKey | controlKey),
            hotKeyID1,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef1
        )
        
        if status1 != noErr {
            print("Failed to register hotkey Cmd+Ctrl+1: \(status1)")
        } else {
            print("Successfully registered hotkey: Cmd+Ctrl+1")
        }
        
        var hotKeyID2 = EventHotKeyID(signature: hotKeySignature, id: hotKeyID2)
        let status2 = RegisterEventHotKey(
            UInt32(kVK_ANSI_2),
            UInt32(cmdKey | controlKey),
            hotKeyID2,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef2
        )
        
        if status2 != noErr {
            print("Failed to register hotkey Cmd+Ctrl+2: \(status2)")
        } else {
            print("Successfully registered hotkey: Cmd+Ctrl+2")
        }
        
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(kEventHotKeyPressed))
        var handlerRef: EventHandlerRef?
        
        InstallEventHandler(
            GetApplicationEventTarget(),
            { (nextHandler, theEvent, userData) -> OSStatus in
                return CursorSniper.handleHotKeyEvent(nextHandler: nextHandler, theEvent: theEvent, userData: userData)
            },
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            &handlerRef
        )
    }
    
    private static func handleHotKeyEvent(nextHandler: EventHandlerCallRef?, theEvent: EventRef?, userData: UnsafeMutableRawPointer?) -> OSStatus {
        guard let theEvent = theEvent else { return OSStatus(eventNotHandledErr) }
        
        var hotKeyID = EventHotKeyID()
        let status = GetEventParameter(
            theEvent,
            OSType(kEventParamDirectObject),
            OSType(typeEventHotKeyID),
            nil,
            MemoryLayout<EventHotKeyID>.size,
            nil,
            &hotKeyID
        )
        
        if status == noErr {
            let cursorSniper = Unmanaged<CursorSniper>.fromOpaque(userData!).takeUnretainedValue()
            
            switch hotKeyID.id {
            case 1:
                cursorSniper.moveCursorToDisplay(displayIndex: 0)
            case 2:
                cursorSniper.moveCursorToDisplay(displayIndex: 1)
            default:
                break
            }
        }
        
        return noErr
    }
    
    private func moveCursorToDisplay(displayIndex: Int) {
        let displays = getDisplays()
        
        guard displayIndex < displays.count else {
            print("Display \(displayIndex + 1) not found. Available displays: \(displays.count)")
            return
        }
        
        let display = displays[displayIndex]
        let centerX = display.origin.x + display.size.width / 2
        let centerY = display.origin.y + display.size.height / 2
        
        CGWarpMouseCursorPosition(CGPoint(x: centerX, y: centerY))
        
        print("Moved cursor to center of display \(displayIndex + 1) at (\(Int(centerX)), \(Int(centerY)))")
    }
    
    private func getDisplays() -> [CGRect] {
        var displays: [CGRect] = []
        
        let maxDisplays: UInt32 = 32
        var activeDisplays = [CGDirectDisplayID](repeating: 0, count: Int(maxDisplays))
        var displayCount: UInt32 = 0
        
        let result = CGGetActiveDisplayList(maxDisplays, &activeDisplays, &displayCount)
        
        if result == .success {
            for i in 0..<Int(displayCount) {
                let displayID = activeDisplays[i]
                let bounds = CGDisplayBounds(displayID)
                displays.append(bounds)
            }
        }
        
        // Sort displays by x position (left to right)
        displays.sort { $0.origin.x < $1.origin.x }
        
        return displays
    }
    
    deinit {
        if let hotKeyRef1 = hotKeyRef1 {
            UnregisterEventHotKey(hotKeyRef1)
        }
        if let hotKeyRef2 = hotKeyRef2 {
            UnregisterEventHotKey(hotKeyRef2)
        }
    }
}

func fourCharCodeFrom(_ string: String) -> FourCharCode {
    assert(string.count == 4)
    var result: FourCharCode = 0
    for char in string.utf16 {
        result = (result << 8) + FourCharCode(char)
    }
    return result
}

print("Cursor Sniper starting...")
print("Press Cmd+Ctrl+1 to move cursor to center of first display")
print("Press Cmd+Ctrl+2 to move cursor to center of second display")
print("Press Ctrl+C to quit")

let cursorSniper = CursorSniper()

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
app.run() 
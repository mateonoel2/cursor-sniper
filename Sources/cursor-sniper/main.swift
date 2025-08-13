import AppKit
import Carbon
import CoreGraphics
import ApplicationServices

class CursorSniper {
    private struct HotKeyBinding {
        let id: UInt32
        let keyCode: UInt32
        let modifiers: UInt32
        let displayIndex: Int
    }

    private var hotKeyRefsById: [UInt32: EventHotKeyRef] = [:]
    private let hotKeySignature: OSType = fourCharCodeFrom("cspr")
    private let bindings: [HotKeyBinding] = [
        .init(id: 1, keyCode: UInt32(kVK_ANSI_1), modifiers: UInt32(cmdKey | controlKey), displayIndex: 0),
        .init(id: 2, keyCode: UInt32(kVK_ANSI_2), modifiers: UInt32(cmdKey | controlKey), displayIndex: 1)
    ]
    private var displayIndexById: [UInt32: Int] = [:]
    
    init() {
        setupHotKeys()
    }
    
    private func setupHotKeys() {
        for binding in bindings {
            var ref: EventHotKeyRef?
            let status = RegisterEventHotKey(
                binding.keyCode,
                binding.modifiers,
                EventHotKeyID(signature: hotKeySignature, id: binding.id),
                GetApplicationEventTarget(),
                0,
                &ref
            )
            if status != noErr {
                print("Failed to register hotkey id \(binding.id): \(status)")
                continue
            }
            if let ref {
                hotKeyRefsById[binding.id] = ref
                displayIndexById[binding.id] = binding.displayIndex
            }
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
        
        guard status == noErr, let userData = userData else { return noErr }
        let cursorSniper = Unmanaged<CursorSniper>.fromOpaque(userData).takeUnretainedValue()
        if let displayIndex = cursorSniper.displayIndexById[hotKeyID.id] {
            cursorSniper.moveCursorToDisplay(displayIndex: displayIndex)
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
        
        displays.sort { $0.origin.x < $1.origin.x }
        
        return displays
    }
    
    deinit {
        for ref in hotKeyRefsById.values {
            UnregisterEventHotKey(ref)
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

func ensureAccessibilityPermissions() -> Bool {
    let env = ProcessInfo.processInfo.environment
    let launchedByLaunchd = env["LAUNCH_JOB_LABEL"] != nil
    let promptKey = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
    let options = [promptKey: !launchedByLaunchd] as CFDictionary
    let trusted = AXIsProcessTrustedWithOptions(options)
    if !trusted {
        let path = CommandLine.arguments.first ?? "cursor-sniper"
        print("Accessibility permission is not granted. Enable it in System Settings → Privacy & Security → Accessibility for: \(path)")
    }
    return trusted
}

_ = ensureAccessibilityPermissions()

let cursorSniper = CursorSniper()

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
app.run() 
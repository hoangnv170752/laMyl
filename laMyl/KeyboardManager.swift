//
//  KeyboardManager.swift
//  laMyl
//
//  Captures system-wide keyboard events using CGEvent
//

import Cocoa
import Combine

class KeyboardManager: ObservableObject {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private weak var audioEngine: AudioEngine?

    @Published var isListening: Bool = false
    @Published var hasAccessibilityPermission: Bool = false
    @Published var keyCount: Int = 0

    // Special key codes
    private let spaceKeyCode: CGKeyCode = 49
    private let enterKeyCode: CGKeyCode = 36
    private let returnKeyCode: CGKeyCode = 76
    private let backspaceKeyCode: CGKeyCode = 51
    private let tabKeyCode: CGKeyCode = 48

    init(audioEngine: AudioEngine) {
        self.audioEngine = audioEngine
        checkAccessibilityPermission()
        print("[KeyboardManager] Init - hasPermission: \(hasAccessibilityPermission)")
    }

    // MARK: - Accessibility Permission

    func checkAccessibilityPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false] as CFDictionary
        hasAccessibilityPermission = AXIsProcessTrustedWithOptions(options)
        print("[KeyboardManager] Check permission: \(hasAccessibilityPermission)")
    }

    func requestAccessibilityPermission() {
        // Show system prompt
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        let trusted = AXIsProcessTrustedWithOptions(options)

        if !trusted {
            // Open System Settings directly to Accessibility
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                NSWorkspace.shared.open(url)
            }
        }

        // Poll for permission grant
        startPermissionPolling()
    }

    private var permissionTimer: Timer?

    private func startPermissionPolling() {
        permissionTimer?.invalidate()
        permissionTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            self?.checkAccessibilityPermission()
            if self?.hasAccessibilityPermission == true {
                timer.invalidate()
                self?.permissionTimer = nil
                self?.startListening()
                print("[KeyboardManager] Permission granted, started listening")
            }
        }
    }

    // MARK: - Event Listening

    func startListening() {
        guard hasAccessibilityPermission else {
            print("[KeyboardManager] No accessibility permission")
            requestAccessibilityPermission()
            return
        }

        // Create event tap for keyDown events
        let eventMask = (1 << CGEventType.keyDown.rawValue)

        // Store self reference for callback
        let refcon = Unmanaged.passUnretained(self).toOpaque()

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly, // Important: listen only, don't modify
            eventsOfInterest: CGEventMask(eventMask),
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                guard let refcon = refcon else {
                    return Unmanaged.passUnretained(event)
                }

                let manager = Unmanaged<KeyboardManager>.fromOpaque(refcon).takeUnretainedValue()
                manager.handleKeyEvent(event)

                return Unmanaged.passUnretained(event)
            },
            userInfo: refcon
        ) else {
            print("[KeyboardManager] Failed to create event tap")
            return
        }

        eventTap = tap

        // Create run loop source
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)

        // Add to run loop
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)

        // Enable the tap
        CGEvent.tapEnable(tap: tap, enable: true)

        isListening = true
        print("[KeyboardManager] Started listening to keyboard events")
    }

    func stopListening() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }

        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
        }

        eventTap = nil
        runLoopSource = nil
        isListening = false

        print("[KeyboardManager] Stopped listening")
    }

    // MARK: - Event Handling

    private func handleKeyEvent(_ event: CGEvent) {
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)

        // Increment key count on main thread
        DispatchQueue.main.async { [weak self] in
            self?.keyCount += 1
        }

        // Play sound immediately
        playSound(forKeyCode: CGKeyCode(keyCode))
    }

    private func playSound(forKeyCode keyCode: CGKeyCode) {
        switch keyCode {
        case spaceKeyCode:
            audioEngine?.playSpaceSound()
        case enterKeyCode, returnKeyCode:
            audioEngine?.playEnterSound()
        case backspaceKeyCode, tabKeyCode:
            audioEngine?.playKeySound()
        default:
            // Regular key
            audioEngine?.playKeySound()
        }
    }
}

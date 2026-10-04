//
//  AppDelegate.swift
//  laMyl
//
//  Menu Bar App Delegate
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var keyboardManager: KeyboardManager?
    private var audioEngine: AudioEngine?
    private var eventMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize audio engine
        audioEngine = AudioEngine()

        // Initialize keyboard manager
        keyboardManager = KeyboardManager(audioEngine: audioEngine!)

        // Setup menu bar
        setupMenuBar()

        // Check and request accessibility permission
        if keyboardManager?.hasAccessibilityPermission == true {
            keyboardManager?.startListening()
        } else {
            // Show permission dialog
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.keyboardManager?.requestAccessibilityPermission()
            }
        }

        // Monitor for clicks outside popover to close it
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            if self?.popover.isShown == true {
                self?.popover.performClose(nil)
            }
        }
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "keyboard", accessibilityDescription: "laMyl")
            button.action = #selector(togglePopover)
            button.target = self
        }

        popover = NSPopover()
        popover.contentSize = NSSize(width: 320, height: 480)
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = NSHostingController(
            rootView: MenuBarView(
                audioEngine: audioEngine!,
                keyboardManager: keyboardManager!
            )
        )
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
        keyboardManager?.stopListening()
        audioEngine?.stop()
    }
}

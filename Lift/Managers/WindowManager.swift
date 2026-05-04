//
//  WindowManager.swift
//  Lift
//

import SwiftUI
import AppKit
import SwiftData

// Borderless panel that can still become key and resign properly
private final class KeyablePanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

final class WindowManager: NSObject, ObservableObject, NSWindowDelegate {

    private let defaultSize = NSSize(width: 860, height: 560)
    private var panel: NSPanel?
    private let container: ModelContainer

    init(container: ModelContainer) {
        self.container = container
        super.init()
        createWindowIfNeeded()
    }

    private func createWindowIfNeeded() {
        guard panel == nil else { return }

        let rootView = MainTabView()
            .modelContainer(container)

        let hosting = NSHostingController(rootView: rootView)

        let panel = KeyablePanel(
            contentRect: NSRect(origin: .zero, size: defaultSize),
            styleMask: [.borderless, .fullSizeContentView, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        panel.contentViewController = hosting
        panel.setContentSize(defaultSize)
        panel.minSize = defaultSize
        panel.maxSize = defaultSize
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.isMovableByWindowBackground = true
        panel.becomesKeyOnlyIfNeeded = false
        panel.hidesOnDeactivate = false
        panel.backgroundColor = .clear
        panel.isOpaque = false

        // Rounded corners since .titled no longer provides them
        panel.contentView?.wantsLayer = true
        panel.contentView?.layer?.cornerRadius = 12
        panel.contentView?.layer?.masksToBounds = true

        panel.delegate = self
        self.panel = panel
    }

    func toggle() {
        createWindowIfNeeded()
        guard let panel else { return }

        if panel.isVisible {
            panel.orderOut(nil)
        } else {
            panel.setContentSize(defaultSize)
            panel.center()
            NSApp.activate(ignoringOtherApps: true)
            panel.makeKeyAndOrderFront(nil)
        }
    }

    // MARK: - NSWindowDelegate

    func windowDidResignKey(_ notification: Notification) {
        panel?.orderOut(nil)
        NSApp.setActivationPolicy(.accessory)
    }
}

//
//  WindowManager.swift
//  Lift
//

import SwiftUI
import AppKit
import SwiftData

final class WindowManager: NSObject, ObservableObject, NSWindowDelegate {

    private let defaultSize = NSSize(width: 1100, height: 760)
    private let minimumSize = NSSize(width: 900, height: 620)
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

        let panel = NSPanel(
            contentRect: NSRect(origin: .zero, size: defaultSize),
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        panel.contentViewController = hosting
        panel.setContentSize(defaultSize)
        panel.minSize = minimumSize
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isMovableByWindowBackground = true
        panel.becomesKeyOnlyIfNeeded = false
        panel.hidesOnDeactivate = false  // Prevent auto-hide fighting with our toggle
        panel.delegate = self

        self.panel = panel
    }

    func toggle() {
        createWindowIfNeeded()
        guard let panel else { return }

        if panel.isVisible {
            panel.orderOut(nil)
        } else {
            if panel.frame.width < minimumSize.width || panel.frame.height < minimumSize.height {
                panel.setContentSize(defaultSize)
            }
            panel.center()
            // Activate first, then show — order matters
            NSApp.activate(ignoringOtherApps: true)
            panel.makeKeyAndOrderFront(nil)
        }
    }

    // MARK: - NSWindowDelegate

    // When user clicks outside or another app takes focus, deactivate cleanly
    func windowDidResignKey(_ notification: Notification) {
        panel?.orderOut(nil)
        NSApp.setActivationPolicy(.accessory)
    }
}
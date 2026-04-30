//
//  WindowManager.swift
//  Task Manager
//
//  Created by Randall Alquicer on 5/1/26.
//


import SwiftUI
import AppKit
import SwiftData

final class WindowManager: ObservableObject {

    private let defaultSize = NSSize(width: 1100, height: 760)
    private let minimumSize = NSSize(width: 900, height: 620)
    private var panel: NSPanel?
    private let container: ModelContainer

    init(container: ModelContainer) {
        self.container = container
        createWindowIfNeeded()
    }

    private func createWindowIfNeeded() {
        guard panel == nil else { return }

        let rootView = ContentView()
            .modelContainer(container)

        let hosting = NSHostingController(rootView: rootView)

        let panel = NSPanel(
            contentRect: NSRect(origin: .zero, size: defaultSize),
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
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
            NSApp.activate(ignoringOtherApps: true)
            panel.center()
            panel.orderFrontRegardless()
            panel.makeKey()
        }
    }
}

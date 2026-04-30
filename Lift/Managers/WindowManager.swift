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

    private var panel: NSPanel?

    func toggle(modelContainer: ModelContainer) {
        if let panel, panel.isVisible {
            panel.orderOut(nil)
            return
        }

        let rootView = ContentView()
            .modelContainer(modelContainer)
            .frame(width: 1000, height: 700)

        let hosting = NSHostingController(rootView: rootView)

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 1000, height: 700),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        panel.contentViewController = hosting
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.center()
        panel.makeKeyAndOrderFront(nil)

        self.panel = panel
    }
}

//
//  StatusBarController.swift
//  Task Manager
//
//  Created by Randall Alquicer on 5/1/26.
//


import AppKit
import SwiftData

final class StatusBarController: NSObject {

    private var statusItem: NSStatusItem!
    private let windowManager: WindowManager
    private let menu = NSMenu()

    init(windowManager: WindowManager) {
        self.windowManager = windowManager
        super.init()
        setup()
    }

    private func setup() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "checklist", accessibilityDescription: "Tasks")
            button.action = #selector(handleStatusItemClick(_:))
            button.target = self
            button.sendAction(on: [.leftMouseUp])
        }

        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        menu.items.forEach { $0.target = self }
    }

    @objc private func handleStatusItemClick(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else {
            windowManager.toggle()
            return
        }

        let isOptionClick = event.modifierFlags.contains(.option)
        let isControlClick = event.modifierFlags.contains(.control)
        if isOptionClick || isControlClick {
            menu.popUp(
                positioning: nil,
                at: NSPoint(x: 0, y: sender.bounds.height + 4),
                in: sender
            )
        } else {
            windowManager.toggle()
        }
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}

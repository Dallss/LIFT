//
//  StatusBarController.swift
//  Task Manager
//
//  Created by Randall Alquicer on 5/1/26.
//

import AppKit
import SwiftData

final class StatusBarController: NSObject {

    // MARK: - Properties

    private var statusItem: NSStatusItem?
    private let windowManager: WindowManager
    private lazy var menu: NSMenu = makeMenu()

    // MARK: - Init

    init(windowManager: WindowManager) {
        self.windowManager = windowManager
        super.init()
        setup()
    }

    deinit {
        if let item = statusItem {
            NSStatusBar.system.removeStatusItem(item)
        }
    }

    // MARK: - Setup

    private func setup() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = item.button {
            button.image = NSImage(
                systemSymbolName: "checklist",
                accessibilityDescription: "Tasks"
            )
            button.action = #selector(handleStatusItemClick(_:))
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        statusItem = item
    }

    private func makeMenu() -> NSMenu {
        let menu = NSMenu()
        let quitItem = NSMenuItem(
            title: "Quit Task Manager",
            action: #selector(quit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)
        return menu
    }

    // MARK: - Actions

    @objc private func handleStatusItemClick(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else {
            activateAndToggle()
            return
        }

        switch event.type {
        case .rightMouseUp:
            showMenu(from: sender)

        case .leftMouseUp:
            let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            if modifiers.contains(.option) || modifiers.contains(.control) {
                showMenu(from: sender)
            } else {
                activateAndToggle()
            }

        default:
            activateAndToggle()
        }
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }

    // MARK: - Private Helpers

    private func activateAndToggle() {
        NSApp.activate(ignoringOtherApps: true)
        windowManager.toggle()
    }

    private func showMenu(from button: NSStatusBarButton) {
        // Disable the button action temporarily so the menu doesn't re-trigger
        statusItem?.menu = menu
        button.performClick(nil)
        statusItem?.menu = nil
    }
}
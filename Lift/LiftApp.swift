//
//  LiftApp.swift
//  Lift
//

import SwiftUI
import SwiftData
import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }
}

@main
struct LiftApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    private let windowManager: WindowManager
    private let statusBar: StatusBarController

    init() {
        let schema = Schema([TaskItem.self, TaskTag.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        let container = try! ModelContainer(for: schema, configurations: [config])
        let windowManager = WindowManager(container: container)
        self.windowManager = windowManager
        self.statusBar = StatusBarController(windowManager: windowManager)
    }

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

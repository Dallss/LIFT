//
//  Task_ManagerApp.swift
//  Task Manager
//
//  Created by Randall Alquicer on 4/12/26.
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
struct Task_ManagerApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    private let modelContainer: ModelContainer
    private let windowManager: WindowManager
    private let statusBar: StatusBarController

    init() {

        let schema = Schema([TaskItem.self, TaskTag.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        let container = try! ModelContainer(for: schema, configurations: [config])

        self.modelContainer = container
        self.windowManager = WindowManager(container: container)
        self.statusBar = StatusBarController(windowManager: windowManager)
    }

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

//
//  Task_ManagerApp.swift
//  Task Manager
//
//  Created by Randall Alquicer on 4/12/26.
//
import SwiftData
import SwiftUI
import AppKit

@main
struct Task_ManagerApp: App {

    @StateObject private var windowManager = WindowManager()

    private let sharedModelContainer: ModelContainer = {
        let schema = Schema([TaskItem.self, TaskTag.self])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {

        MenuBarExtra("Tasks", systemImage: "checklist") {
            MenuBarView(modelContainer: sharedModelContainer)
                .environmentObject(windowManager)
        }
        .menuBarExtraStyle(.window)
    }
}

//
//  Task_ManagerApp.swift
//  Task Manager
//
//  Created by Randall Alquicer on 4/12/26.
//

import SwiftData
import SwiftUI

@main
struct Task_ManagerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([TaskItem.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
        .defaultSize(width: 1000, height: 700)
        .defaultPosition(.center)
    }
}

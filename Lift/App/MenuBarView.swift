//
//  MenuBarView.swift
//  Task Manager
//
//  Created by Randall Alquicer on 5/1/26.
//

import SwiftUI
import SwiftData
import AppKit

struct MenuBarView: View {

    @EnvironmentObject var windowManager: WindowManager
    let modelContainer: ModelContainer 

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            Button("Open Tasks") {
                windowManager.toggle(modelContainer: modelContainer)
            }

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding(10)
    }
}

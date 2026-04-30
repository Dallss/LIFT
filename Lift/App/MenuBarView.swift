//
//  MenuBarView.swift
//  Task Manager
//
//  Created by Randall Alquicer on 5/1/26.
//

import SwiftUI
import AppKit

struct MenuBarView: View {

    @EnvironmentObject var windowManager: WindowManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            Button("Open Tasks") {
                windowManager.toggle()
            }

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding(10)
    }
}

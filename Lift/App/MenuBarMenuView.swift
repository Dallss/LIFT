//
//  MenuBarMenuView.swift
//  Task Manager
//
//  Created by Randall Alquicer on 5/1/26.
//


import SwiftUI

struct MenuBarMenuView: View {

    let onQuit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            Button("Quit Task Manager") {
                onQuit()
            }

        }
        .padding(8)
    }
}

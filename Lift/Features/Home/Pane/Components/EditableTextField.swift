//
//  EditableTextField.swift
//  Task Manager
//
//  Created by Randall Alquicer on 4/30/26.
//

import SwiftUI

enum EditableTextStyle {
    case title
    case details
}

struct EditableTextField: View {
    @Binding var text: String?

    var style: EditableTextStyle
    var strikethrough: Bool

    @State private var isEditing = false
    @State private var buffer: String = ""

    @FocusState private var focused: Bool

    var body: some View {
        Group {
            if isEditing {
                TextField(placeholder, text: $buffer)
                    .textFieldStyle(.plain)
                    .font(font)
                    .focused($focused)
                    .onSubmit { commit() }
            } else {
                Text(displayText)
                    .font(font)
                    .foregroundStyle(foreground)
                    .strikethrough(strikethrough, color: .secondary)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { enterEdit() }
    }

    // MARK: - Display

    private var displayText: String {
        text?.isEmpty == false ? text! : placeholder
    }

    private var placeholder: String {
        switch style {
        case .title: return "Title"
        case .details: return "Details"
        }
    }

    private var font: Font {
        switch style {
        case .title: return .body
        case .details: return .caption
        }
    }

    private var foreground: Color {
        switch style {
        case .title: return .primary
        case .details: return .secondary
        }
    }

    // MARK: - Editing

    private func enterEdit() {
        buffer = text ?? ""
        isEditing = true

        DispatchQueue.main.async {
            focused = true
        }
    }

    private func commit() {
        let cleaned = buffer.trimmingCharacters(in: .whitespacesAndNewlines)
        text = cleaned.isEmpty ? nil : cleaned
        isEditing = false
        focused = false
    }
}

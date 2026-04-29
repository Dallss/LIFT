//
//  NewTaskView.swift
//  Task Manager
//
//  Created by Randall Alquicer on 4/30/26.
//

import SwiftUI
import SwiftData

struct NewTaskView: View {
    @Binding var title: String
    @Binding var hasDueDate: Bool
    @Binding var dueDate: Date
    @Binding var selectedTagIDs: Set<PersistentIdentifier>

    let tags: [TaskTag]

    let onAddTask: () -> Void
    let onCancel: () -> Void
    let onToggleTag: (TaskTag) -> Void

    @State private var newTagName: String = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                    .textFieldStyle(.roundedBorder)

                Toggle("Due Date", isOn: $hasDueDate)

                if hasDueDate {
                    DatePicker(
                        "Due",
                        selection: $dueDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }

                Text("Tags")
                    .font(.headline)

                if tags.isEmpty {
                    Text("No tags yet. Add one below.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(tags, id: \.persistentModelID) { tag in
                        Button {
                            onToggleTag(tag)
                        } label: {
                            HStack {
                                Text(tag.name)
                                Spacer()
                                if selectedTagIDs.contains(tag.persistentModelID) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color.accentColor)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }

                HStack {
                    TextField("New Tag", text: $newTagName)

                    Button("Add") {
                        let trimmed = newTagName.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        newTagName = ""
                    }
                    .disabled(newTagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .formStyle(.grouped)
            .navigationTitle("New Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add", action: onAddTask)
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .frame(minWidth: 320, minHeight: 200)
    }
}

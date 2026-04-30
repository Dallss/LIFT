//
//  TaskRowView.swift
//  Task Manager
//
//  Created by Randall Alquicer on 4/30/26.
//

import SwiftUI

struct TaskRowView: View {
    @Bindable var task: TaskItem
    let allTags: [TaskTag]

    @Environment(\.modelContext) private var modelContext

    @State private var isPresentingNewTagSheet = false
    @State private var newTagName = ""

    // MARK: - Inline edit state
    @State private var isEditing = false
    @State private var editedTitle = ""

    let showDueDate: Bool
    let showDueTime: Bool

    init(
        task: TaskItem,
        allTags: [TaskTag],
        showDueDate: Bool = false,
        showDueTime: Bool = false
    ) {
        self.task = task
        self.allTags = allTags
        self.showDueDate = showDueDate
        self.showDueTime = showDueTime
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {

            Toggle("Completed", isOn: $task.isCompleted)
                .toggleStyle(.checkbox)
                .labelsHidden()

            VStack(alignment: .leading, spacing: 2) {
    
                EditableTextField(
                    text: Binding(
                        get: { task.title },
                        set: { task.title = $0 ?? "" }
                    ),
                    style: .title,
                    strikethrough: task.isCompleted
                )

                EditableTextField(
                    text: $task.details,
                    style: .details,
                    strikethrough: false
                )
                
                if !task.tags.isEmpty {
                    Text(task.tags.map(\.name).sorted().joined(separator: " • "))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 0)

            // MARK: - Due date
            if let due = task.deadline {

                let isOverdue = !task.isCompleted && due < Date()

                VStack(alignment: .trailing, spacing: 2) {

                    if showDueDate {
                        Text(due.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundStyle(isOverdue ? .red : .secondary)
                    }

                    if showDueTime {
                        Text(due.formatted(date: .omitted, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(isOverdue ? .red : .secondary)
                    }
                }
            }

            // MARK: - Menu
            Menu {

                Button {
                    startEditing()
                } label: {
                    Label(isEditing ? "Done Editing" : "Rename", systemImage: "pencil")
                }

                Button {
                    // move deadline
                } label: {
                    Label("Move Deadline", systemImage: "calendar")
                }

                Menu("Tags", systemImage: "tag") {

                    if allTags.isEmpty {
                        Text("No tags available")
                    } else {
                        ForEach(allTags) { tag in
                            Button {
                                toggle(tag)
                            } label: {
                                Label(tag.name,
                                      systemImage: has(tag) ? "checkmark" : "circle")
                            }
                        }
                    }

                    Divider()

                    Button {
                        isPresentingNewTagSheet = true
                    } label: {
                        Label("Add New Tag", systemImage: "plus")
                    }

                    if !task.tags.isEmpty {
                        Divider()
                        Button(role: .destructive) {
                            task.tags.removeAll()
                        } label: {
                            Label("Remove All Tags", systemImage: "tag.slash")
                        }
                    }
                }

            } label: {
                Image(systemName: "ellipsis")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .fixedSize()
        }
        .padding(.vertical, 2)
        .contentShape(Rectangle())
        .onTapGesture {
            if !isEditing {
                startEditing()
            }
        }
        .accessibilityElement(children: .combine)
        .sheet(isPresented: $isPresentingNewTagSheet) {
            newTagSheet
        }
    }

    // MARK: - Editing logic

    private func startEditing() {
        editedTitle = task.title
        isEditing = true
    }

    private func finishEditing() {
        task.title = editedTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        isEditing = false
    }

    // MARK: - Tag helpers

    private func has(_ tag: TaskTag) -> Bool {
        task.tags.contains { $0.persistentModelID == tag.persistentModelID }
    }

    private func toggle(_ tag: TaskTag) {
        if let index = task.tags.firstIndex(where: { $0.persistentModelID == tag.persistentModelID }) {
            task.tags.remove(at: index)
        } else {
            task.tags.append(tag)
        }
    }

    // MARK: - New tag sheet

    private var newTagSheet: some View {
        NavigationStack {
            Form {
                TextField("Tag Name", text: $newTagName)
            }
            .formStyle(.grouped)
            .navigationTitle("New Tag")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        newTagName = ""
                        isPresentingNewTagSheet = false
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addTagFromMenu()
                    }
                    .disabled(newTagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .frame(minWidth: 320, minHeight: 180)
    }

    private func addTagFromMenu() {
        do {
            if let tag = try TaskTagStore.createCustomTagIfNeeded(
                name: newTagName,
                in: modelContext
            ) {
                if !has(tag) {
                    task.tags.append(tag)
                }
            }
        } catch {
            // ignore failure
        }

        newTagName = ""
        isPresentingNewTagSheet = false
    }
}

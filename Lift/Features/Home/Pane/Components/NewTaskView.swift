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
            ScrollView {
                VStack(spacing: 24) {

                    // Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        TextField("What needs to be done?", text: $title)
                            .font(.title3)
                    }

                    // Due Date
                    HStack(spacing: 12) {
//                       Toggle("Due Date", isOn: $hasDueDate.animation(.easeInOut))


                        VStack(spacing: 8) {
                            DatePicker(
                                "Date",
                                selection: $dueDate,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.compact)

                            DatePicker(
                                "Time",
                                selection: $dueDate,
                                displayedComponents: .hourAndMinute
                            )
                            .datePickerStyle(.compact)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.08))
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    // Tags
                    WrappingHStack(spacing: 8) {
                        ForEach(tags, id: \.persistentModelID) { tag in
                            TagChip(
                                name: tag.name,
                                isSelected: selectedTagIDs.contains(tag.persistentModelID)
                            ) {
                                onToggleTag(tag)
                            }
                        }
                    }
                }
                .padding(20)
            }
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

// MARK: - Tag Chip

struct TagChip: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(name)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.accentColor.opacity(0.2) : Color.gray.opacity(0.1))
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Simple Flow Layout

struct FlowLayout<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        // Simple vertical stack fallback (cleaner than Form list look)
        VStack(alignment: .leading, spacing: 8) {
            content()
        }
    }
}

@MainActor
private func seedPreviewData(_ context: ModelContext) {

    let work = TaskTag(name: "Work")
    let personal = TaskTag(name: "Personal")
    let urgent = TaskTag(name: "Urgent")

    context.insert(work)
    context.insert(personal)
    context.insert(urgent)

    let today = Calendar.current.startOfDay(for: Date())
    let now = Date()

    let tasks: [TaskItem] = [
        TaskItem(title: "Finish SwiftUI layout", deadline: now.addingTimeInterval(3600)),
        TaskItem(title: "Reply to emails", deadline: today),
        TaskItem(title: "Gym workout", deadline: nil),
        TaskItem(title: "Review PRs", deadline: now.addingTimeInterval(7200))
    ]

    tasks[0].tags = [work, urgent]
    tasks[1].tags = [work]
    tasks[2].tags = [personal]
    tasks[3].tags = [work, personal]

    for task in tasks {
        context.insert(task)
    }

    try? context.save()
}

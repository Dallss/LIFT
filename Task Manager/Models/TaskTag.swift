import Foundation
import SwiftData

@Model
final class TaskTag {
    var name: String
    var createdAt: Date
    var isDefault: Bool
    @Relationship var tasks: [TaskItem]

    init(
        name: String,
        createdAt: Date = .now,
        isDefault: Bool = false,
        tasks: [TaskItem] = []
    ) {
        self.name = name
        self.createdAt = createdAt
        self.isDefault = isDefault
        self.tasks = tasks
    }
}

enum TaskTagDefaults {
    static let names = ["Work", "Personal", "Urgent", "Study", "Health", "Errands"]
}

enum TaskTagStore {
    static func ensureDefaults(in modelContext: ModelContext) throws {
        let fetch = FetchDescriptor<TaskTag>()
        let existingTags = try modelContext.fetch(fetch)
        let existingNames = Set(existingTags.map { normalized($0.name) })

        for defaultName in TaskTagDefaults.names where !existingNames.contains(normalized(defaultName)) {
            modelContext.insert(TaskTag(name: defaultName, isDefault: true))
        }
    }

    static func createCustomTagIfNeeded(name: String, in modelContext: ModelContext) throws -> TaskTag? {
        let displayName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedInput = normalized(displayName)
        guard !normalizedInput.isEmpty else { return nil }

        let existing = try modelContext.fetch(FetchDescriptor<TaskTag>())
        if let match = existing.first(where: { normalized($0.name) == normalizedInput }) {
            return match
        }

        let tag = TaskTag(name: displayName, isDefault: false)
        modelContext.insert(tag)
        return tag
    }

    private static func normalized(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}

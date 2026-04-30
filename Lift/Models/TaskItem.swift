import Foundation
import SwiftData

@Model
final class TaskItem {
    var title: String
    var details: String?
    var createdAt: Date
    var isCompleted: Bool
    var deadline: Date?
    @Relationship(inverse: \TaskTag.tasks) var tags: [TaskTag]

    init(
        title: String,
        details: String? = nil,
        createdAt: Date = .now,
        isCompleted: Bool = false,
        deadline: Date? = nil,
        tags: [TaskTag] = []
    ) {
        self.title = title
        self.createdAt = createdAt
        self.isCompleted = isCompleted
        self.deadline = deadline
        self.tags = tags
        self.details = details
    }
}

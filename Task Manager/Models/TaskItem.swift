import Foundation
import SwiftData

@Model
final class TaskItem {
    var title: String
    var createdAt: Date
    var isCompleted: Bool
    var deadline: Date?

    init(
        title: String,
        createdAt: Date = .now,
        isCompleted: Bool = false,
        deadline: Date? = nil
    ) {
        self.title = title
        self.createdAt = createdAt
        self.isCompleted = isCompleted
        self.deadline = deadline
    }
}

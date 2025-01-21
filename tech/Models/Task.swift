import Foundation

struct Task: Identifiable, Codable {
    var id = UUID()
    var title: String
    var isCompleted: Bool
    var dueDate: Date
    var notes: String?
} 
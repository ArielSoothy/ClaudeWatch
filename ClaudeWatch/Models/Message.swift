import Foundation

struct Message: Identifiable, Codable {
    let id: UUID
    var role: Role
    var content: String
    var timestamp: Date
    var quickReplies: [String]?

    enum Role: String, Codable {
        case user
        case assistant
    }

    init(
        id: UUID = UUID(),
        role: Role,
        content: String,
        timestamp: Date = Date(),
        quickReplies: [String]? = nil
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
        self.quickReplies = quickReplies
    }
}

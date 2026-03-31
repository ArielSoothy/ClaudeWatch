import Foundation

struct ApprovalRequest: Identifiable, Codable {
    let id: UUID
    var title: String
    var body: String
    var sender: String
    var status: Status
    var timestamp: Date
    var selectedReply: String?

    enum Status: String, Codable {
        case pending
        case approved
        case rejected
    }

    init(
        id: UUID = UUID(),
        title: String,
        body: String,
        sender: String,
        status: Status = .pending,
        timestamp: Date = Date(),
        selectedReply: String? = nil
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.sender = sender
        self.status = status
        self.timestamp = timestamp
        self.selectedReply = selectedReply
    }
}

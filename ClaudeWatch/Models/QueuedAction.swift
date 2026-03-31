import Foundation

struct QueuedAction: Identifiable, Codable {
    let id: UUID
    var actionType: ActionType
    var payload: Data
    var createdAt: Date
    var retryCount: Int

    enum ActionType: String, Codable {
        case sendMessage
        case approveRequest
        case rejectRequest
    }

    init(
        id: UUID = UUID(),
        actionType: ActionType,
        payload: Data,
        createdAt: Date = Date(),
        retryCount: Int = 0
    ) {
        self.id = id
        self.actionType = actionType
        self.payload = payload
        self.createdAt = createdAt
        self.retryCount = retryCount
    }
}

import Foundation

struct ApprovalRequest: Identifiable, Codable {
    let id: UUID
    var title: String
    var body: String
    var sender: String
    var requestType: RequestType
    var tool: String?
    var toolInput: String?
    var status: Status
    var timestamp: Date
    var selectedReply: String?

    enum RequestType: String, Codable {
        case approval
        case permission
    }

    enum Status: String, Codable {
        case pending
        case approved
        case rejected
    }

    var isPermission: Bool { requestType == .permission }

    init(
        id: UUID = UUID(),
        title: String,
        body: String,
        sender: String,
        requestType: RequestType = .approval,
        tool: String? = nil,
        toolInput: String? = nil,
        status: Status = .pending,
        timestamp: Date = Date(),
        selectedReply: String? = nil
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.sender = sender
        self.requestType = requestType
        self.tool = tool
        self.toolInput = toolInput
        self.status = status
        self.timestamp = timestamp
        self.selectedReply = selectedReply
    }

    // Backward-compatible decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        body = try container.decode(String.self, forKey: .body)
        sender = try container.decode(String.self, forKey: .sender)
        requestType = try container.decodeIfPresent(RequestType.self, forKey: .requestType) ?? .approval
        tool = try container.decodeIfPresent(String.self, forKey: .tool)
        toolInput = try container.decodeIfPresent(String.self, forKey: .toolInput)
        status = try container.decode(Status.self, forKey: .status)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        selectedReply = try container.decodeIfPresent(String.self, forKey: .selectedReply)
    }
}

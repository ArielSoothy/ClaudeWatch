import Foundation

actor RelayService {
    private let baseURL: URL
    private let secret: String

    init(
        baseURL: String = "https://claudewatch-relay.vercel.app",
        secret: String = ""
    ) {
        self.baseURL = URL(string: baseURL)!
        self.secret = secret
    }

    // MARK: - Approvals

    struct ApprovalsResponse: Codable {
        let approvals: [RemoteApproval]
        let count: Int
    }

    struct RemoteApproval: Codable {
        let id: String
        let title: String
        let body: String
        let sender: String
        let status: String
        let reply: String?
        let createdAt: String
        let updatedAt: String?
    }

    func fetchApprovals(status: String? = nil) async throws -> [RemoteApproval] {
        var urlString = "\(baseURL)/api/approvals"
        if let status { urlString += "?status=\(status)" }

        guard let url = URL(string: urlString) else { throw RelayError.invalidURL }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(secret)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 10

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw RelayError.requestFailed
        }

        let decoded = try JSONDecoder().decode(ApprovalsResponse.self, from: data)
        return decoded.approvals
    }

    func respondToApproval(id: String, status: String, reply: String?) async throws {
        guard let url = URL(string: "\(baseURL)/api/approvals?id=\(id)") else {
            throw RelayError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(secret)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10

        var body: [String: String] = ["status": status]
        if let reply { body["reply"] = reply }
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw RelayError.requestFailed
        }
    }

    // MARK: - Messages (Chat via Claude Code sub)

    struct ChatResponse: Codable {
        let id: String
        let question: String
        let answer: String?
        let quickReplies: [String]?
        let status: String
    }

    /// Send a question to the relay — Claude Code (running on Mac) will answer it
    func sendQuestion(_ question: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/api/messages") else {
            throw RelayError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(secret)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10
        request.httpBody = try JSONSerialization.data(withJSONObject: ["question": question])

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 201 else {
            throw RelayError.requestFailed
        }

        let decoded = try JSONDecoder().decode(ChatResponse.self, from: data)
        return decoded.id
    }

    /// Poll for an answer to a question
    func pollForAnswer(messageId: String) async throws -> ChatResponse? {
        guard let url = URL(string: "\(baseURL)/api/messages?id=\(messageId)") else {
            throw RelayError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(secret)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 10

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw RelayError.requestFailed
        }

        let decoded = try JSONDecoder().decode(ChatResponse.self, from: data)
        return decoded.status == "answered" ? decoded : nil
    }

    // MARK: - Errors

    enum RelayError: LocalizedError {
        case invalidURL
        case requestFailed

        var errorDescription: String? {
            switch self {
            case .invalidURL: return "Invalid relay URL"
            case .requestFailed: return "Relay request failed"
            }
        }
    }
}

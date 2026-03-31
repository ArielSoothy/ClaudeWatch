import Foundation

actor RelayService {
    private let baseURL: URL
    private let secret: String

    // Default to the deployed relay — configurable in Settings
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

    // MARK: - Errors

    enum RelayError: LocalizedError {
        case invalidURL
        case requestFailed
        case noSecret

        var errorDescription: String? {
            switch self {
            case .invalidURL: return "Invalid relay URL"
            case .requestFailed: return "Relay request failed"
            case .noSecret: return "No relay secret. Add one in Settings."
            }
        }
    }
}

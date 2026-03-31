import SwiftUI

@MainActor
final class ApprovalsViewModel: ObservableObject {
    @Published var requests: [ApprovalRequest] = []
    @Published var isLoading = false
    @Published var isConnected = false
    @Published var errorMessage: String?

    private var relayService: RelayService?
    private var pollTimer: Timer?

    var pendingRequests: [ApprovalRequest] {
        requests.filter { $0.status == .pending }
    }

    var completedRequests: [ApprovalRequest] {
        requests.filter { $0.status != .pending }
    }

    init() {
        loadLocal()
        connectToRelay()
    }

    // MARK: - Relay Connection

    func connectToRelay() {
        // Use saved secret, or fall back to built-in default
        let secret = RelaySettings.loadSecret() ?? "840606e72d1ccdb07c930afc79225877"
        guard !secret.isEmpty else {
            if requests.isEmpty { loadSampleData() }
            return
        }

        let url = RelaySettings.loadURL() ?? "https://claudewatch-relay.vercel.app"
        relayService = RelayService(baseURL: url, secret: secret)
        isConnected = true
        startPolling()
    }

    func disconnectRelay() {
        pollTimer?.invalidate()
        pollTimer = nil
        relayService = nil
        isConnected = false
    }

    private func startPolling() {
        // Poll every 30 seconds
        pollTimer?.invalidate()
        pollTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task { await self?.fetchFromRelay() }
        }
        // Also fetch immediately
        Task { await fetchFromRelay() }
    }

    func fetchFromRelay() async {
        guard let relay = relayService else { return }
        do {
            let remote = try await relay.fetchApprovals()
            // Merge remote approvals with local state
            for approval in remote {
                if !requests.contains(where: { $0.id.uuidString == approval.id }) {
                    if let uuid = UUID(uuidString: approval.id) {
                        let status: ApprovalRequest.Status = switch approval.status {
                            case "approved": .approved
                            case "rejected": .rejected
                            default: .pending
                        }
                        let req = ApprovalRequest(
                            id: uuid,
                            title: approval.title,
                            body: approval.body,
                            sender: approval.sender,
                            status: status,
                            timestamp: ISO8601DateFormatter().date(from: approval.createdAt) ?? Date(),
                            selectedReply: approval.reply
                        )
                        requests.insert(req, at: 0)
                    }
                }
            }
            errorMessage = nil
            saveLocal()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Actions

    func approve(_ request: ApprovalRequest, reply: String? = nil) {
        guard let index = requests.firstIndex(where: { $0.id == request.id }) else { return }
        requests[index].status = .approved
        requests[index].selectedReply = reply
        HapticService.success()
        saveLocal()

        // Send to relay if connected
        if let relay = relayService {
            Task {
                try? await relay.respondToApproval(
                    id: request.id.uuidString,
                    status: "approved",
                    reply: reply
                )
            }
        }
    }

    func reject(_ request: ApprovalRequest, reply: String? = nil) {
        guard let index = requests.firstIndex(where: { $0.id == request.id }) else { return }
        requests[index].status = .rejected
        requests[index].selectedReply = reply
        HapticService.failure()
        saveLocal()

        if let relay = relayService {
            Task {
                try? await relay.respondToApproval(
                    id: request.id.uuidString,
                    status: "rejected",
                    reply: reply
                )
            }
        }
    }

    func addRequest(_ request: ApprovalRequest) {
        requests.insert(request, at: 0)
        saveLocal()
    }

    func clearCompleted() {
        requests.removeAll { $0.status != .pending }
        HapticService.click()
        saveLocal()
    }

    // MARK: - Local Persistence

    private static let storageKey = "claude_watch_approvals"

    private func saveLocal() {
        if let data = try? JSONEncoder().encode(requests) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }

    private func loadLocal() {
        guard let data = UserDefaults.standard.data(forKey: Self.storageKey),
              let loaded = try? JSONDecoder().decode([ApprovalRequest].self, from: data)
        else { return }
        requests = loaded
    }

    private func loadSampleData() {
        requests = [
            ApprovalRequest(
                title: "Deploy v2.1 to production",
                body: "All tests passing. 3 files changed.",
                sender: "CI/CD Pipeline"
            ),
            ApprovalRequest(
                title: "Add user to admin group",
                body: "Request from Sarah to add dev@company.com.",
                sender: "Access Manager"
            ),
            ApprovalRequest(
                title: "Merge PR #847",
                body: "Feature: dark mode. 2 approvals, no conflicts.",
                sender: "GitHub"
            )
        ]
        saveLocal()
    }
}

// MARK: - Relay Settings (stored alongside API key)

enum RelaySettings {
    private static let secretKey = "claude_watch_relay_secret"
    private static let urlKey = "claude_watch_relay_url"

    static func saveSecret(_ secret: String) {
        UserDefaults.standard.set(secret, forKey: secretKey)
    }

    static func loadSecret() -> String? {
        UserDefaults.standard.string(forKey: secretKey)
    }

    static func saveURL(_ url: String) {
        UserDefaults.standard.set(url, forKey: urlKey)
    }

    static func loadURL() -> String? {
        UserDefaults.standard.string(forKey: urlKey)
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: secretKey)
        UserDefaults.standard.removeObject(forKey: urlKey)
    }
}

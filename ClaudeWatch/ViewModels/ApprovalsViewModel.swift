import SwiftUI

@Observable
@MainActor
final class ApprovalsViewModel {
    var requests: [ApprovalRequest] = []
    var isLoading = false

    var pendingRequests: [ApprovalRequest] {
        requests.filter { $0.status == .pending }
    }

    var completedRequests: [ApprovalRequest] {
        requests.filter { $0.status != .pending }
    }

    init() {
        loadSampleData()
    }

    func approve(_ request: ApprovalRequest, reply: String? = nil) {
        guard let index = requests.firstIndex(where: { $0.id == request.id }) else { return }
        requests[index].status = .approved
        requests[index].selectedReply = reply
        HapticService.success()
        save()
    }

    func reject(_ request: ApprovalRequest, reply: String? = nil) {
        guard let index = requests.firstIndex(where: { $0.id == request.id }) else { return }
        requests[index].status = .rejected
        requests[index].selectedReply = reply
        HapticService.failure()
        save()
    }

    func addRequest(_ request: ApprovalRequest) {
        requests.insert(request, at: 0)
        save()
    }

    func clearCompleted() {
        requests.removeAll { $0.status != .pending }
        HapticService.click()
        save()
    }

    // MARK: - Persistence

    private static let storageKey = "claude_watch_approvals"

    private func save() {
        if let data = try? JSONEncoder().encode(requests) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: Self.storageKey),
              let loaded = try? JSONDecoder().decode([ApprovalRequest].self, from: data)
        else { return }
        requests = loaded
    }

    private func loadSampleData() {
        load()
        if requests.isEmpty {
            requests = [
                ApprovalRequest(
                    title: "Deploy v2.1 to production",
                    body: "All tests passing. 3 files changed. Ready for release.",
                    sender: "CI/CD Pipeline"
                ),
                ApprovalRequest(
                    title: "Add user to admin group",
                    body: "Request from Sarah to add dev@company.com to admin.",
                    sender: "Access Manager"
                ),
                ApprovalRequest(
                    title: "Merge PR #847",
                    body: "Feature: Add dark mode support. 2 approvals, no conflicts.",
                    sender: "GitHub"
                )
            ]
            save()
        }
    }
}

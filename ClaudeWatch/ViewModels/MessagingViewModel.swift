import SwiftUI

@MainActor
final class MessagingViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var quickReplies: [String] = [
        "Summarize this",
        "What should I do?",
        "Explain briefly",
        "Yes, proceed",
        "No, cancel"
    ]

    private var relayService: RelayService?

    init() {
        connectToRelay()
    }

    private func connectToRelay() {
        let secret = RelaySettings.loadSecret() ?? "840606e72d1ccdb07c930afc79225877"
        let url = RelaySettings.loadURL() ?? "https://claudewatch-relay.vercel.app"
        relayService = RelayService(baseURL: url, secret: secret)
    }

    func sendMessage(_ text: String) {
        let userMessage = Message(role: .user, content: text)
        messages.append(userMessage)
        errorMessage = nil
        isLoading = true
        HapticService.click()

        Task {
            do {
                guard let relay = relayService else {
                    throw NSError(domain: "ClaudeWatch", code: 1, userInfo: [NSLocalizedDescriptionKey: "No relay connection"])
                }

                // Send question to relay
                let messageId = try await relay.sendQuestion(text)

                // Poll for answer (Claude Code on your Mac answers via subscription)
                var answer: RelayService.ChatResponse?
                for _ in 0..<30 { // 30 attempts × 2s = 60s timeout
                    try await Task.sleep(nanoseconds: 2_000_000_000)
                    answer = try await relay.pollForAnswer(messageId: messageId)
                    if answer != nil { break }
                }

                if let answer, let answerText = answer.answer {
                    let response = Message(
                        role: .assistant,
                        content: answerText,
                        quickReplies: answer.quickReplies
                    )
                    messages.append(response)
                    if let replies = answer.quickReplies, !replies.isEmpty {
                        quickReplies = replies
                    }
                    HapticService.success()
                } else {
                    errorMessage = "No response yet. Is watch-responder running?"
                    HapticService.failure()
                }
            } catch {
                errorMessage = error.localizedDescription
                HapticService.failure()
            }
            isLoading = false
        }
    }

    func sendQuickReply(_ reply: String) {
        sendMessage(reply)
    }

    func clearConversation() {
        messages.removeAll()
        quickReplies = [
            "Summarize this",
            "What should I do?",
            "Explain briefly",
            "Yes, proceed",
            "No, cancel"
        ]
        HapticService.click()
    }
}

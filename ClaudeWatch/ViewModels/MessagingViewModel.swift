import SwiftUI

@Observable
@MainActor
final class MessagingViewModel {
    var messages: [Message] = []
    var isLoading = false
    var errorMessage: String?
    var quickReplies: [String] = [
        "Summarize this",
        "What should I do?",
        "Explain briefly",
        "Yes, proceed",
        "No, cancel"
    ]

    private let apiService = ClaudeAPIService()

    func sendMessage(_ text: String) {
        let userMessage = Message(role: .user, content: text)
        messages.append(userMessage)
        errorMessage = nil
        isLoading = true
        HapticService.click()

        Task {
            do {
                let response = try await apiService.sendMessage(text, context: messages)
                messages.append(response)
                if let replies = response.quickReplies, !replies.isEmpty {
                    quickReplies = replies
                }
                HapticService.success()
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

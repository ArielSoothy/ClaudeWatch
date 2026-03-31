import Foundation

actor ClaudeAPIService {
    private let baseURL = URL(string: "https://api.anthropic.com/v1/messages")!
    private let model = "claude-sonnet-4-20250514"
    private let maxTokens = 256
    private let apiVersion = "2023-06-01"

    private let systemPrompt = """
    You are a concise watch assistant. Keep responses under 50 words.
    After your response, provide exactly 3-5 quick reply suggestions the user might send next.
    Format your response as JSON:
    {"response": "your brief answer", "quickReplies": ["Reply 1", "Reply 2", "Reply 3"]}
    Always respond with valid JSON only.
    """

    struct APIResponse: Codable {
        let response: String
        let quickReplies: [String]
    }

    func sendMessage(_ text: String, context: [Message] = []) async throws -> Message {
        guard let apiKey = KeychainService.loadAPIKey(), !apiKey.isEmpty else {
            throw APIError.noAPIKey
        }

        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue(apiVersion, forHTTPHeaderField: "anthropic-version")
        request.timeoutInterval = 30

        var messages: [[String: String]] = context.suffix(6).map { msg in
            ["role": msg.role.rawValue, "content": msg.content]
        }
        messages.append(["role": "user", "content": text])

        let body: [String: Any] = [
            "model": model,
            "max_tokens": maxTokens,
            "system": systemPrompt,
            "messages": messages
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard httpResponse.statusCode == 200 else {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown"
            throw APIError.httpError(httpResponse.statusCode, errorBody)
        }

        // Parse Anthropic response
        let anthropicResponse = try JSONDecoder().decode(AnthropicResponse.self, from: data)
        guard let textContent = anthropicResponse.content.first?.text else {
            throw APIError.emptyResponse
        }

        // Parse our structured JSON from Claude's response
        if let jsonData = textContent.data(using: .utf8),
           let parsed = try? JSONDecoder().decode(APIResponse.self, from: jsonData) {
            return Message(
                role: .assistant,
                content: parsed.response,
                quickReplies: parsed.quickReplies
            )
        }

        // Fallback: use raw text if JSON parsing fails
        return Message(role: .assistant, content: textContent)
    }

    // MARK: - Anthropic API Response Types

    private struct AnthropicResponse: Codable {
        let content: [ContentBlock]
    }

    private struct ContentBlock: Codable {
        let type: String
        let text: String?
    }

    // MARK: - Errors

    enum APIError: LocalizedError {
        case noAPIKey
        case invalidResponse
        case httpError(Int, String)
        case emptyResponse

        var errorDescription: String? {
            switch self {
            case .noAPIKey:
                return "No API key. Add one in Settings."
            case .invalidResponse:
                return "Invalid response from server."
            case .httpError(let code, _):
                return "API error (\(code))"
            case .emptyResponse:
                return "Empty response from Claude."
            }
        }
    }
}

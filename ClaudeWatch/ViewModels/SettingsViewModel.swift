import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var apiKey: String = ""
    @Published var relaySecret: String = ""
    @Published var relayURL: String = "https://claudewatch-relay.vercel.app"
    @Published var settings: AppSettings = .load()
    @Published var hasAPIKey: Bool = false
    @Published var hasRelay: Bool = false

    init() {
        if let key = KeychainService.loadAPIKey() {
            apiKey = key
            hasAPIKey = true
        }
        if let secret = RelaySettings.loadSecret() {
            relaySecret = secret
            hasRelay = true
        }
        if let url = RelaySettings.loadURL() {
            relayURL = url
        }
    }

    // MARK: - API Key

    func saveAPIKey() {
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        do {
            try KeychainService.saveAPIKey(apiKey.trimmingCharacters(in: .whitespacesAndNewlines))
            hasAPIKey = true
            HapticService.success()
        } catch {
            HapticService.failure()
        }
    }

    func deleteAPIKey() {
        KeychainService.deleteAPIKey()
        apiKey = ""
        hasAPIKey = false
        HapticService.click()
    }

    // MARK: - Relay

    func saveRelay() {
        let secret = relaySecret.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !secret.isEmpty else { return }
        RelaySettings.saveSecret(secret)
        RelaySettings.saveURL(relayURL.trimmingCharacters(in: .whitespacesAndNewlines))
        hasRelay = true
        HapticService.success()
    }

    func deleteRelay() {
        RelaySettings.clear()
        relaySecret = ""
        relayURL = "https://claudewatch-relay.vercel.app"
        hasRelay = false
        HapticService.click()
    }

    // MARK: - Settings

    func updateHapticIntensity(_ intensity: AppSettings.HapticIntensity) {
        settings.hapticIntensity = intensity
        settings.save()
        HapticService.click()
    }

    func toggleNotifications() {
        settings.notificationsEnabled.toggle()
        settings.save()
        HapticService.click()
    }
}

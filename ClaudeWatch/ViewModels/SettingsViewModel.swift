import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var apiKey: String = ""
    @Published var settings: AppSettings = .load()
    @Published var hasAPIKey: Bool = false
    @Published var showingSaveConfirmation = false

    init() {
        if let key = KeychainService.loadAPIKey() {
            apiKey = key
            hasAPIKey = true
        }
    }

    func saveAPIKey() {
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        do {
            try KeychainService.saveAPIKey(apiKey.trimmingCharacters(in: .whitespacesAndNewlines))
            hasAPIKey = true
            showingSaveConfirmation = true
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

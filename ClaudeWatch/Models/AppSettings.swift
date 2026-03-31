import Foundation

struct AppSettings: Codable {
    var hapticIntensity: HapticIntensity
    var notificationsEnabled: Bool

    enum HapticIntensity: String, Codable, CaseIterable {
        case off = "Off"
        case light = "Light"
        case medium = "Medium"
        case strong = "Strong"
    }

    init(
        hapticIntensity: HapticIntensity = .medium,
        notificationsEnabled: Bool = true
    ) {
        self.hapticIntensity = hapticIntensity
        self.notificationsEnabled = notificationsEnabled
    }

    // MARK: - Persistence

    private static let storageKey = "claude_watch_settings"

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }

    static func load() -> AppSettings {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let settings = try? JSONDecoder().decode(AppSettings.self, from: data)
        else {
            return AppSettings()
        }
        return settings
    }
}

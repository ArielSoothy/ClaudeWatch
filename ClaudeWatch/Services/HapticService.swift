import WatchKit

enum HapticService {
    static func play(_ type: WKHapticType, intensity: AppSettings.HapticIntensity = .medium) {
        guard intensity != .off else { return }
        WKInterfaceDevice.current().play(type)
    }

    static func success() {
        play(.success)
    }

    static func failure() {
        play(.failure)
    }

    static func click() {
        play(.click)
    }

    static func notification() {
        play(.notification)
    }
}

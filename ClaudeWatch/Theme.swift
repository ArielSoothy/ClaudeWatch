import SwiftUI

enum Theme {
    // MARK: - Colors
    static let background = Color(red: 0.10, green: 0.10, blue: 0.18)       // #1A1A2E
    static let surface = Color(red: 0.15, green: 0.15, blue: 0.23)          // #262638
    static let surfaceLight = Color(red: 0.20, green: 0.20, blue: 0.28)     // #333348
    static let accent = Color(red: 0.83, green: 0.65, blue: 0.45)           // #D4A574
    static let accentLight = Color(red: 0.90, green: 0.75, blue: 0.58)      // #E6BF94
    static let approve = Color(red: 0.30, green: 0.78, blue: 0.55)          // #4DC78C
    static let reject = Color(red: 0.92, green: 0.35, blue: 0.35)           // #EB5959
    static let textPrimary = Color.white
    static let textSecondary = Color(white: 0.65)
    static let textTertiary = Color(white: 0.45)

    // MARK: - Spacing
    static let spacingXS: CGFloat = 4
    static let spacingSM: CGFloat = 8
    static let spacingMD: CGFloat = 12
    static let spacingLG: CGFloat = 16
    static let spacingXL: CGFloat = 24

    // MARK: - Corner Radius
    static let radiusSM: CGFloat = 8
    static let radiusMD: CGFloat = 12
    static let radiusLG: CGFloat = 16
    static let radiusFull: CGFloat = 100

    // MARK: - Button
    static let buttonMinHeight: CGFloat = 44
}

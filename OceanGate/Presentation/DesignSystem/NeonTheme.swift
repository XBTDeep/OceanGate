import SwiftUI

enum NeonTheme {
    static let ink = Color(red: 0.03, green: 0.035, blue: 0.055)
    static let glass = Color.white.opacity(0.09)
    static let glassStrong = Color.white.opacity(0.16)
    static let line = Color.white.opacity(0.18)
    static let mint = Color(red: 0.27, green: 1.0, blue: 0.73)
    static let coral = Color(red: 1.0, green: 0.34, blue: 0.45)
    static let citrus = Color(red: 1.0, green: 0.82, blue: 0.25)
    static let cobalt = Color(red: 0.18, green: 0.47, blue: 1.0)
    static let violet = Color(red: 0.58, green: 0.35, blue: 1.0)

    static let spectrum = [mint, cobalt, violet, coral, citrus]
}


import SwiftUI

// MARK: - Font Style

enum ThemeFontStyle: String, Hashable {
    case sansSerif, rounded, monospaced, serif

    var design: Font.Design {
        switch self {
        case .sansSerif:  return .default
        case .rounded:    return .rounded
        case .monospaced: return .monospaced
        case .serif:      return .serif
        }
    }
}

// MARK: - Haptic Style

enum HapticStyle: Hashable {
    case none, soft, medium, rigid
}

// MARK: - Theme

struct TimerTheme: Identifiable, Hashable {
    let id: String
    let name: String
    let isPremium: Bool

    // Visuals
    let backgroundColors: [Color]
    let primaryTextColor: Color
    let labelColor: Color
    let accentColor: Color

    // Breathing animation (breathingDuration == 0 means no animation)
    let breathingColors: [Color]?
    let breathingDuration: Double

    // Typography
    let fontStyle: ThemeFontStyle
    let fontWeight: Font.Weight

    // Behavior
    let pulseOnTick: Bool
    let hapticStyle: HapticStyle

    var background: LinearGradient {
        LinearGradient(
            colors: backgroundColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var breathingGradient: LinearGradient? {
        guard let colors = breathingColors else { return nil }
        return LinearGradient(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    func timerFont(size: CGFloat) -> Font {
        .system(size: size, weight: fontWeight, design: fontStyle.design)
    }
}

// MARK: - Library

enum ThemeLibrary {
    static let all: [TimerTheme] = FreeThemes.all + PremiumThemes.all

    static func theme(for id: String) -> TimerTheme {
        all.first { $0.id == id } ?? FreeThemes.minimal
    }
}

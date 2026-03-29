import SwiftUI

enum PremiumThemes {
    static let neonCircuit = TimerTheme(
        id: "neon_circuit",
        name: "Neon Circuit",
        isPremium: true,
        backgroundColors: [
            Color(red: 0.03, green: 0.03, blue: 0.08),
            Color(red: 0.05, green: 0.02, blue: 0.12)
        ],
        primaryTextColor: Color(red: 0.0, green: 1.0, blue: 0.85),
        labelColor: Color(red: 0.75, green: 0.0, blue: 1.0),
        accentColor: Color(red: 1.0, green: 0.0, blue: 0.6),
        fontStyle: .monospaced,
        fontWeight: .medium,
        pulseOnTick: true
    )

    static let warmHearth = TimerTheme(
        id: "warm_hearth",
        name: "Warm Hearth",
        isPremium: true,
        backgroundColors: [
            Color(red: 0.22, green: 0.09, blue: 0.04),
            Color(red: 0.38, green: 0.14, blue: 0.04)
        ],
        primaryTextColor: Color(red: 1.0, green: 0.85, blue: 0.62),
        labelColor: Color(red: 0.78, green: 0.52, blue: 0.30),
        accentColor: Color(red: 1.0, green: 0.52, blue: 0.12),
        fontStyle: .rounded,
        fontWeight: .regular,
        pulseOnTick: false
    )

    static let cosmos = TimerTheme(
        id: "cosmos",
        name: "Cosmos",
        isPremium: true,
        backgroundColors: [
            Color(red: 0.04, green: 0.02, blue: 0.14),
            Color(red: 0.09, green: 0.04, blue: 0.24)
        ],
        primaryTextColor: Color(white: 0.94),
        labelColor: Color(red: 0.68, green: 0.58, blue: 0.88),
        accentColor: Color(red: 0.58, green: 0.38, blue: 1.0),
        fontStyle: .sansSerif,
        fontWeight: .ultraLight,
        pulseOnTick: true
    )

    static let all: [TimerTheme] = [neonCircuit, warmHearth, cosmos]
}

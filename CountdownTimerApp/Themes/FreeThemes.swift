import SwiftUI

enum FreeThemes {
    static let minimal = TimerTheme(
        id: "minimal",
        name: "Minimal",
        isPremium: false,
        backgroundColors: [Color(white: 0.97), Color(white: 0.93)],
        primaryTextColor: Color(white: 0.1),
        labelColor: Color(white: 0.45),
        accentColor: Color(white: 0.05),
        fontStyle: .sansSerif,
        fontWeight: .thin,
        pulseOnTick: false
    )

    static let midnight = TimerTheme(
        id: "midnight",
        name: "Midnight",
        isPremium: false,
        backgroundColors: [
            Color(red: 0.05, green: 0.05, blue: 0.16),
            Color(red: 0.02, green: 0.02, blue: 0.08)
        ],
        primaryTextColor: .white,
        labelColor: Color(white: 0.55),
        accentColor: Color(red: 0.38, green: 0.58, blue: 1.0),
        fontStyle: .monospaced,
        fontWeight: .light,
        pulseOnTick: true
    )

    static let paper = TimerTheme(
        id: "paper",
        name: "Paper",
        isPremium: false,
        backgroundColors: [
            Color(red: 0.96, green: 0.93, blue: 0.87),
            Color(red: 0.90, green: 0.86, blue: 0.79)
        ],
        primaryTextColor: Color(red: 0.18, green: 0.13, blue: 0.08),
        labelColor: Color(red: 0.42, green: 0.33, blue: 0.22),
        accentColor: Color(red: 0.52, green: 0.28, blue: 0.08),
        fontStyle: .serif,
        fontWeight: .regular,
        pulseOnTick: false
    )

    static let all: [TimerTheme] = [minimal, midnight, paper]
}

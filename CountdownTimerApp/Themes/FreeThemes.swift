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
        breathingColors: nil,
        breathingDuration: 0,
        interactiveColors: nil,
        fontStyle: .sansSerif,
        fontWeight: .thin,
        pulseOnTick: false,
        hapticStyle: .none
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
        breathingColors: [
            Color(red: 0.10, green: 0.10, blue: 0.28),
            Color(red: 0.06, green: 0.06, blue: 0.18)
        ],
        breathingDuration: 10,
        interactiveColors: [
            Color(red: 0.15, green: 0.25, blue: 0.6),
            Color(red: 0.05, green: 0.1, blue: 0.3)
        ],
        fontStyle: .monospaced,
        fontWeight: .light,
        pulseOnTick: true,
        hapticStyle: .rigid
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
        breathingColors: [
            Color(red: 0.98, green: 0.96, blue: 0.92),
            Color(red: 0.94, green: 0.91, blue: 0.85)
        ],
        breathingDuration: 14,
        interactiveColors: nil,
        fontStyle: .serif,
        fontWeight: .regular,
        pulseOnTick: false,
        hapticStyle: .soft
    )

    static let bubblegum = TimerTheme(
        id: "bubblegum",
        name: "Bubblegum",
        isPremium: false,
        backgroundColors: [
            Color(red: 1.0, green: 0.75, blue: 0.85),
            Color(red: 1.0, green: 0.85, blue: 0.95)
        ],
        primaryTextColor: Color(red: 0.8, green: 0.2, blue: 0.5),
        labelColor: Color(red: 0.9, green: 0.4, blue: 0.6),
        accentColor: Color(red: 1.0, green: 0.4, blue: 0.65),
        breathingColors: [
            Color(red: 1.0, green: 0.7, blue: 0.8),
            Color(red: 1.0, green: 0.8, blue: 0.9)
        ],
        breathingDuration: 8,
        interactiveColors: [
            Color(red: 1.0, green: 0.5, blue: 0.7),
            Color(red: 0.9, green: 0.3, blue: 0.6)
        ],
        fontStyle: .bubbly,
        fontWeight: .heavy,
        pulseOnTick: true,
        hapticStyle: .medium
    )

    static let all: [TimerTheme] = [minimal, midnight, paper, bubblegum]
}

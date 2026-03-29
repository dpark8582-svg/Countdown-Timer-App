# Countdown Timer App — Session Summary

## Project Overview

A customizable iOS countdown timer app for the App Store. The core differentiator
is a curated library of visual themes that users can choose from. Free themes are
included; premium theme packs are unlocked via In-App Purchase (StoreKit 2, not
yet implemented).

**Branch:** `claude/ios-timer-themes-planning-qsxk1`
**Repo:** `dpark8582-svg/countdown-timer-app`

---

## Tech Stack

| Layer | Choice |
|---|---|
| Language | Swift 6 |
| UI | SwiftUI |
| Persistence | SwiftData |
| Payments | StoreKit 2 (planned, not yet built) |
| Notifications | UserNotifications |
| Minimum target | iOS 17.0 |

---

## Project Structure

```
CountdownTimerApp/
├── App/
│   └── CountdownTimerApp.swift       @main entry, SwiftData container
├── Models/
│   ├── SavedTimer.swift              @Model: label, durationSeconds, themeID
│   └── TimerTheme.swift              TimerTheme struct + ThemeLibrary lookup
├── Themes/
│   ├── FreeThemes.swift              Minimal, Midnight, Paper
│   └── PremiumThemes.swift           Neon Circuit, Warm Hearth, Cosmos (locked)
├── ViewModels/
│   └── TimerRunViewModel.swift       @Observable @MainActor countdown engine
├── Services/
│   └── NotificationService.swift     UNNotification schedule/cancel
└── Views/
    ├── HomeView.swift                Timer list + empty state
    ├── NewTimerView.swift            Wheel duration picker + theme selection
    ├── TimerRunView.swift            Circular progress ring + controls
    └── ThemePickerView.swift         Horizontal scroll of theme cards
```

---

## Theme System

Every theme is a pure Swift value type (`TimerTheme` struct) — no external
asset dependencies for the current themes. Fields:

```swift
struct TimerTheme: Identifiable, Hashable {
    let id: String
    let name: String
    let isPremium: Bool
    let backgroundColors: [Color]   // drives LinearGradient
    let primaryTextColor: Color
    let labelColor: Color
    let accentColor: Color
    let fontStyle: ThemeFontStyle   // sansSerif / rounded / monospaced / serif
    let fontWeight: Font.Weight
    let pulseOnTick: Bool
}
```

### Included Themes

| Theme | Tier | Style |
|---|---|---|
| Minimal | Free | Light, thin sans-serif, no pulse |
| Midnight | Free | Dark navy, monospaced, blue accent, pulse |
| Paper | Free | Warm cream, serif, brown accent |
| Neon Circuit | Premium (locked) | Near-black, cyan/magenta, pulse |
| Warm Hearth | Premium (locked) | Dark amber, rounded, orange accent |
| Cosmos | Premium (locked) | Deep purple, ultra-light, pulse |

Adding a new theme = adding one `TimerTheme` value to `FreeThemes.swift` or
`PremiumThemes.swift`. No view code changes needed.

---

## App Flow

```
HomeView
  ├── tap +  →  NewTimerView (sheet)
  │               └── wheel picker (h/m/s) + label + ThemePickerView
  │                   └── Save → inserts SavedTimer into SwiftData
  └── tap row  →  TimerRunView (sheet)
                   ├── play/pause toggles timer + schedules UNNotification
                   ├── reset restores full duration
                   └── completion overlay when time reaches zero
```

---

## Timer Engine

`TimerRunViewModel` (`@Observable @MainActor`):

- `Timer.publish(every: 1, on: .main, in: .common)` drives ticks
- **Background handling:** `handleBackground()` records timestamp and pauses;
  `handleForeground()` computes elapsed time, deducts it, then restarts
- **Notifications:** `UNTimeIntervalNotificationTrigger` fires the completion
  alert even if the app is killed — no `BGTaskScheduler` needed
- **No sounds** (intentionally omitted for this build)

---

## Bugs Fixed During Session

### 1. Missing `@MainActor` (Swift 6 concurrency)
`TimerRunViewModel` was not marked `@MainActor`. In Swift 6 strict concurrency
mode this is a compile error — the compiler cannot statically verify that
`Timer.publish` callbacks and all property mutations occur on the main actor.

**Fix:** Added `@MainActor` to the class declaration.

### 2. Completion overlay transition never animated
The overlay used `.transition()` but there was no animation driver, so it
appeared/disappeared instantly.

**Fix:** Added `.animation(.spring(response: 0.45, dampingFraction: 0.78), value: viewModel.isFinished)`
on the outer `ZStack`.

---

## Animations & Polish Added

| What | Detail |
|---|---|
| Timer view entrance | Content slides up with spring on `.onAppear` |
| Button press feedback | `SpringButtonStyle` scales to 0.88 on press |
| Completion overlay | Springs in/out driven by `isFinished` |
| Empty ↔ list transition | Spring scale+opacity on `timers.isEmpty` |
| Row deletion | Wrapped in `withAnimation(.spring)` |
| Timer digits | `contentTransition(.numericText(countsDown: true))` |
| NewTimer sheet | `.presentationDragIndicator(.visible)` + `.presentationCornerRadius(24)` |
| TimerRun sheet | `.presentationDragIndicator(.hidden)` — full-screen feel |

---

## Xcode Setup (Mac)

### One-time project creation

1. Xcode → **File > New > Project** → iOS → App
2. Settings: Interface = **SwiftUI**, Storage = **SwiftData**
3. Delete the generated `ContentView.swift` and `Item.swift`
4. Drag the `CountdownTimerApp/` folder into the project navigator
   - Uncheck "Copy items if needed" to keep it linked to the repo
5. Target → General → **Minimum Deployments: iOS 17.0**
6. Build & Run (`⌘R`) or use the canvas

### Canvas previews

Each view has `#Preview` macros. Open any view file and press
`⌘ + Option + Return` to open the canvas, then `⌘ + Option + P` to resume.

| File | Available Previews |
|---|---|
| `HomeView` | "Empty", "With Timers" (3 sample timers) |
| `NewTimerView` | New timer form |
| `ThemePickerView` | Horizontal theme card row |
| `TimerRunView` | "Minimal — Running", "Midnight — Running", "Paper" |

---

## Commercial / Copyright Notes

- **No external assets** in the current build — all themes use system colors,
  system fonts (`Font.Weight`, `Font.Design`), and SF Symbols
- SF Symbols are fine inside app UI; **cannot** be used in the app icon or
  marketing materials
- Sounds intentionally omitted; if added later use CC0 or commissioned originals
- Keep a `LICENSES.md` for any future third-party assets
- Premium theme names (Neon Circuit, Warm Hearth, Cosmos) are descriptive and
  generic — no trademark conflict

---

## What's Not Built Yet

- StoreKit 2 integration (premium theme unlocking)
- App icon + launch screen
- WidgetKit lock screen widget
- Haptics (CoreHaptics)
- Settings screen
- Edit / rename existing timers

# Countdown Timer App — Project Plan

## Overview

A customizable iOS countdown timer differentiated by a curated library of
visual themes. Available on the App Store with both free and premium tiers.

---

## Part 1: Themes — Commercial Safety & Copyright Strategy

### The Core Risk Areas

| Asset Type | Risk | Safe Approach |
|---|---|---|
| Color palettes | None — colors are not copyrightable | Create freely |
| Typography | Font files are licensed; the look/feel is not | Use licensed fonts only |
| Icons & symbols | Copyrightable if copied | Use SF Symbols or original work |
| Sounds | Copyrightable | License or create originals |
| Background imagery | Copyrightable | Use CC0 or original artwork |
| "Look and feel" of another app | Trade dress claim risk | Design distinctly |

### Safe Asset Sources

**Fonts**
- SF Pro / SF Rounded — built into iOS, free for App Store apps per Apple's
  license (no redistribution outside Apple platforms)
- Google Fonts with the SIL Open Font License (OFL) — free for commercial use,
  can be embedded in apps. Examples: Inter, Nunito, Space Grotesk, Outfit.
- fonts.adobe.com — paid subscription, covers commercial app embedding.
- Do NOT embed fonts from sites like DaFont without confirming the license says
  "Commercial Use Allowed" explicitly.

**Icons**
- SF Symbols 5 (Apple) — free for use in apps targeting Apple platforms.
  Restriction: cannot use SF Symbols in logos, app icons, or outside Apple
  platforms. Using them inside the UI is fine.
- Phosphor Icons, Lucide — MIT licensed, fully commercial safe.
- Custom-drawn icons (SVG/PDF) — own the copyright outright.

**Background Textures & Imagery**
- unsplash.com — Unsplash License permits commercial use in apps. Cannot
  resell the images themselves or create a competing stock photo product.
- pexels.com — Same terms as Unsplash.
- CC0 sources: openverse.org, pixabay.com (verify CC0 filter is applied).
- Better long-term: commission an illustrator or use procedurally generated
  backgrounds (SwiftUI gradients, particle effects, shaders) — you own these
  outright.

**Sounds**
- freesound.org — filter by CC0 license. Download WAV, trim, include in bundle.
- zapsplat.com — free tier with attribution; paid tier ($19/yr) removes
  attribution requirement and is commercial safe.
- Best option: hire a sound designer for 5–10 original tones (~$50–$200 on
  Fiverr or Upwork). You own them outright, no attribution, no future
  license changes.

**Animations**
- Lottie animations: lottiefiles.com has free animations. Check each file's
  license individually — many are Creative Commons Attribution or CC0.
- SwiftUI animations you write yourself: owned by you.

### Recommended Theme Production Workflow

1. Define each theme as a pure data struct in Swift (no external assets at all
   for MVP): color palette + font choice + animation style.
2. For Phase 2, add background textures/illustrations — commission originals or
   use CC0 sources, document the source & license in a `LICENSES.md` file.
3. Keep a `ThemeLicenses.swift` or `LICENSES.md` that records, for every
   third-party asset: source URL, license type, date downloaded, and any
   attribution string required.
4. Do not use assets from Pinterest, Dribbble screenshots, or AI image
   generators that trained on copyrighted data without a clear commercial
   license (Midjourney's paid plan allows commercial use; DALL-E via OpenAI
   API allows commercial use as of their current ToS).

### Theme Categories (original, no trademark risk)

- **Minimal** — white/off-white, clean sans-serif, subtle fade animations
- **Midnight** — deep navy/black, monospaced font, soft glow pulse
- **Warm Hearth** — amber/terracotta palette, rounded serif, gentle flicker
- **Neon Circuit** — dark bg + vivid cyan/magenta, monospace, scanline effect
- **Forest** — muted greens/browns, nature-texture background (CC0 or original)
- **Paper** — cream + ink tones, slightly rough texture, no animation
- **Cosmos** — deep purple + star particle system (SwiftUI Canvas)
- **Retro LCD** — green-on-black segment display style, beep sound

Names like these are descriptive and generic — no trademark conflict.
Avoid naming themes after specific brands, copyrighted characters, or
distinctive product names.

---

## Part 2: iOS App — Architecture & Build Plan

### Tech Stack

| Layer | Technology | Reason |
|---|---|---|
| Language | Swift 6 | Current, safe concurrency |
| UI | SwiftUI | Theme system maps cleanly to SwiftUI modifiers |
| Minimum target | iOS 17 | Observation framework, `@Observable`, `SwiftData` |
| Persistence | SwiftData | Simple, native, no third-party dependency |
| Payments | StoreKit 2 | Modern async API, simpler receipt validation |
| Notifications | UserNotifications | Timer completion alerts |
| Audio | AVFoundation | Sound playback on timer end |

### Project Structure

```
CountdownTimerApp/
├── CountdownTimerApp.swift          # @main entry point
├── Models/
│   ├── CountdownTimer.swift         # SwiftData model (label, duration, themeID)
│   └── TimerTheme.swift             # Theme value type + ThemeLibrary
├── ViewModels/
│   ├── TimerRunViewModel.swift      # @Observable, drives active countdown
│   └── StoreViewModel.swift         # @Observable, StoreKit product loading
├── Views/
│   ├── HomeView.swift               # Timer list + "New Timer" button
│   ├── TimerRunView.swift           # Full-screen countdown display
│   ├── ThemePickerView.swift        # Horizontal scroll of theme cards
│   ├── StoreView.swift              # Unlock premium theme packs
│   └── SettingsView.swift           # Notifications, sounds, etc.
├── Services/
│   ├── NotificationService.swift    # Schedule/cancel UNNotifications
│   └── AudioService.swift           # Play completion sound
├── Themes/                          # One file per theme pack
│   ├── FreeThemes.swift
│   └── PremiumThemes.swift
└── Resources/
    ├── Assets.xcassets
    └── Sounds/
```

### Theme System Design

```swift
// The core protocol — every theme conforms to this
struct TimerTheme: Identifiable, Hashable {
    let id: String
    let name: String
    let isPremium: Bool

    // Colors
    let background: AnyShapeStyle       // gradient or solid
    let primaryText: Color
    let accentColor: Color

    // Typography
    let timerFont: Font

    // Behavior
    let pulseOnTick: Bool
    let completionSoundName: String?    // filename in bundle, or nil for default
}
```

Every view that renders the timer takes a `TimerTheme` and applies it via
SwiftUI modifiers — no conditional logic scattered through views.

### Data Model

```swift
@Model
class SavedTimer {
    var label: String
    var durationSeconds: Int
    var themeID: String
    var createdAt: Date
}
```

### Monetization (StoreKit 2)

- **Free tier**: 3 themes included at launch (e.g., Minimal, Midnight, Paper)
- **Premium packs** (non-consumable In-App Purchase, ~$1.99 each):
  - Nature Pack (Forest, Warm Hearth)
  - Retro Pack (Neon Circuit, Retro LCD)
  - Cosmos Pack
- **Bundle** (~$3.99): all premium packs
- No subscription needed — a one-time purchase model is simpler and has better
  conversion for a utility app.

Lock premium themes with a `@AppStorage("unlockedThemePacks")` set updated
after successful StoreKit transaction verification. For production, verify
transactions server-side or use StoreKit 2's built-in `Transaction.verify()`.

### Timer Engine

Use `Timer.publish(every: 1, on: .main, in: .common)` combined with
scene-phase observation (`@Environment(\.scenePhase)`) to handle
backgrounding:

- On background: record `backgroundedAt = Date()`
- On foreground: compute elapsed = `Date() - backgroundedAt`, deduct from
  remaining time
- Schedule a `UNTimeIntervalNotificationRequest` when the timer starts so the
  completion fires even if the app is killed

Do NOT use a background task for a simple countdown — `UNNotifications` handle
this entirely without needing `BGTaskScheduler`.

### Build Phases

**Phase 1 — Core (MVP)**
- [ ] Xcode project setup, SwiftData stack
- [ ] Timer run engine (foreground + background re-entry)
- [ ] 3 free themes wired to the UI
- [ ] UNNotification on completion
- [ ] Basic HomeView + TimerRunView

**Phase 2 — Theme System**
- [ ] ThemePickerView with preview cards
- [ ] Premium theme pack assets (sounds, backgrounds)
- [ ] StoreKit 2 integration
- [ ] ThemeLicenses.md documenting all third-party assets

**Phase 3 — Polish**
- [ ] App icon + launch screen
- [ ] Haptics (CoreHaptics) on tick and completion
- [ ] Widget (WidgetKit) showing active countdown on Lock Screen
- [ ] Accessibility: Dynamic Type, VoiceOver labels on timer display

**Phase 4 — Release**
- [ ] App Store screenshots (one per theme pack — great marketing)
- [ ] Privacy policy (required if using any analytics)
- [ ] TestFlight beta
- [ ] App Review submission

### App Store Metadata Notes

- Category: Utilities
- Keywords: countdown timer, timer, custom themes, aesthetic timer, study timer
- The theme variety is a natural differentiator for screenshots — show the
  same timer in 4 different themes on the App Store page.

---

## Legal Checklist Before Submission

- [ ] All font licenses confirmed and documented
- [ ] All sound licenses confirmed and documented
- [ ] All background image/texture licenses confirmed and documented
- [ ] No SF Symbols used in app icon or marketing materials
- [ ] Privacy policy published at a URL (required by Apple)
- [ ] No analytics or tracking without ATT prompt (if using any)
- [ ] StoreKit transactions verified before unlocking content
- [ ] App does not claim features it doesn't have

import SwiftUI
import SwiftData

@main
struct CountdownTimerApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(for: SavedTimer.self)
    }
}

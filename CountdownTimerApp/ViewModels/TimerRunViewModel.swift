import SwiftUI
import Combine
import Observation

@Observable
@MainActor
final class TimerRunViewModel {
    private(set) var remainingSeconds: Int
    private(set) var isRunning = false
    private(set) var isFinished = false

    private let totalSeconds: Int
    private var cancellable: AnyCancellable?
    private var backgroundedAt: Date?

    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return Double(remainingSeconds) / Double(totalSeconds)
    }

    var formattedTime: String {
        let h = remainingSeconds / 3600
        let m = (remainingSeconds % 3600) / 60
        let s = remainingSeconds % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%02d:%02d", m, s)
    }

    init(durationSeconds: Int) {
        self.totalSeconds = durationSeconds
        self.remainingSeconds = durationSeconds
    }

    func start() {
        guard !isRunning, remainingSeconds > 0 else { return }
        isRunning = true
        cancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick() }
    }

    func pause() {
        isRunning = false
        cancellable = nil
    }

    func reset() {
        pause()
        isFinished = false
        remainingSeconds = totalSeconds
    }

    // Call when app moves to background
    func handleBackground() {
        guard isRunning else { return }
        backgroundedAt = Date()
        pause()
    }

    // Call when app returns to foreground
    func handleForeground() {
        guard let backgroundedAt else { return }
        let elapsed = Int(Date().timeIntervalSince(backgroundedAt))
        self.backgroundedAt = nil
        remainingSeconds = max(0, remainingSeconds - elapsed)
        if remainingSeconds == 0 {
            finish()
        } else {
            start()
        }
    }

    private func tick() {
        guard remainingSeconds > 0 else { finish(); return }
        remainingSeconds -= 1
        if remainingSeconds == 0 { finish() }
    }

    private func finish() {
        pause()
        isFinished = true
    }
}

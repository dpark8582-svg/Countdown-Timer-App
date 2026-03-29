import SwiftUI

struct TimerRunView: View {
    let savedTimer: SavedTimer

    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel: TimerRunViewModel
    @State private var pulse = false
    @State private var appeared = false

    private var theme: TimerTheme {
        ThemeLibrary.theme(for: savedTimer.themeID)
    }

    init(savedTimer: SavedTimer) {
        self.savedTimer = savedTimer
        _viewModel = State(wrappedValue: TimerRunViewModel(durationSeconds: savedTimer.durationSeconds))
    }

    var body: some View {
        ZStack {
            // Background
            theme.background
                .ignoresSafeArea()

            // Main content
            VStack(spacing: 48) {
                labelView
                progressRingWithTime
                controlsRow
            }
            .padding(.horizontal, 32)
            .offset(y: appeared ? 0 : 30)
            .opacity(appeared ? 1 : 0)

            // Completion overlay — spring-animated in/out
            if viewModel.isFinished {
                completionOverlay
                    .transition(.opacity.combined(with: .scale(scale: 0.94)))
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.78), value: viewModel.isFinished)
        .onChange(of: viewModel.remainingSeconds) { _, _ in triggerPulse() }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .background: viewModel.handleBackground()
            case .active:     viewModel.handleForeground()
            default:          break
            }
        }
        .task { await NotificationService.requestAuthorization() }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.82).delay(0.05)) {
                appeared = true
            }
        }
    }

    // MARK: - Sub-views

    private var labelView: some View {
        Text(savedTimer.label)
            .font(.system(.title3, design: theme.fontStyle.design, weight: .regular))
            .foregroundStyle(theme.labelColor)
    }

    private var progressRingWithTime: some View {
        ZStack {
            CircularProgressView(
                progress: viewModel.progress,
                trackColor: theme.primaryTextColor.opacity(0.12),
                progressColor: theme.accentColor
            )
            .frame(width: 260, height: 260)

            Text(viewModel.formattedTime)
                .font(theme.timerFont(size: 64))
                .foregroundStyle(theme.primaryTextColor)
                .scaleEffect(pulse ? 1.04 : 1.0)
                .contentTransition(.numericText(countsDown: true))
                .animation(.default, value: viewModel.formattedTime)
        }
    }

    private var controlsRow: some View {
        HStack(spacing: 52) {
            CircleButton(systemImage: "arrow.counterclockwise", color: theme.labelColor, size: 24) {
                viewModel.reset()
                NotificationService.cancelCompletion()
            }

            CircleButton(
                systemImage: viewModel.isRunning ? "pause.fill" : "play.fill",
                color: theme.accentColor,
                size: 36,
                filled: true
            ) {
                toggleTimer()
            }
            .disabled(viewModel.isFinished)

            CircleButton(systemImage: "xmark", color: theme.labelColor, size: 24) {
                NotificationService.cancelCompletion()
                dismiss()
            }
        }
    }

    // MARK: - Completion overlay

    private var completionOverlay: some View {
        ZStack {
            theme.background
                .opacity(0.9)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 90))
                    .foregroundStyle(theme.accentColor)

                Text("Done!")
                    .font(theme.timerFont(size: 40))
                    .foregroundStyle(theme.primaryTextColor)

                Button("Close") { dismiss() }
                    .font(.system(.body, design: theme.fontStyle.design, weight: .medium))
                    .foregroundStyle(theme.accentColor)
                    .padding(.top, 8)
            }
        }
    }

    // MARK: - Helpers

    private func toggleTimer() {
        if viewModel.isRunning {
            viewModel.pause()
            NotificationService.cancelCompletion()
        } else {
            viewModel.start()
            NotificationService.scheduleCompletion(
                timerLabel: savedTimer.label,
                inSeconds: viewModel.remainingSeconds
            )
        }
    }

    private func triggerPulse() {
        guard theme.pulseOnTick, viewModel.isRunning else { return }
        withAnimation(.easeIn(duration: 0.08))  { pulse = true }
        withAnimation(.easeOut(duration: 0.12).delay(0.08)) { pulse = false }
    }
}

// MARK: - Circular Progress

private struct CircularProgressView: View {
    let progress: Double
    let trackColor: Color
    let progressColor: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(trackColor, lineWidth: 5)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(progressColor, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)
        }
    }
}

// MARK: - Circle Button

private struct CircleButton: View {
    let systemImage: String
    let color: Color
    let size: CGFloat
    var filled: Bool = false
    let action: () -> Void

    @State private var pressed = false

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: size, weight: .medium))
                .foregroundStyle(filled ? .white : color)
                .frame(width: size * 2.2, height: size * 2.2)
                .background(filled ? color : color.opacity(0.12), in: Circle())
        }
        .buttonStyle(SpringButtonStyle())
    }
}

// MARK: - Spring Button Style

private struct SpringButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

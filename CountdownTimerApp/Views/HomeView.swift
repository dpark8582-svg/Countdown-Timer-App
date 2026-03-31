import SwiftUI

struct HomeView: View {
    @AppStorage("selectedThemeID") private var selectedThemeID = FreeThemes.minimal.id
    @AppStorage("savedDurationSeconds") private var savedDurationSeconds = 300

    @State private var viewModel: TimerRunViewModel
    @State private var showingTimeSetter = false
    @State private var showingThemePicker = false
    @State private var pulse = false

    @Environment(\.scenePhase) private var scenePhase

    init() {
        let saved = UserDefaults.standard.integer(forKey: "savedDurationSeconds")
        _viewModel = State(wrappedValue: TimerRunViewModel(durationSeconds: saved > 0 ? saved : 300))
    }

    private var theme: TimerTheme {
        ThemeLibrary.theme(for: selectedThemeID)
    }

    var body: some View {
        ZStack {

            // ── Full-screen background ──────────────────────────────────
            theme.background
                .ignoresSafeArea()

            // ── Timer content ───────────────────────────────────────────
            VStack(spacing: 0) {
                Spacer()

                // Tap the time to set a new duration (only when stopped)
                Button {
                    guard !viewModel.isRunning else { return }
                    showingTimeSetter = true
                } label: {
                    Text(viewModel.formattedTime)
                        .font(theme.timerFont(size: 92))
                        .foregroundStyle(theme.primaryTextColor)
                        .scaleEffect(pulse ? 1.03 : 1.0)
                        .contentTransition(.numericText(countsDown: true))
                        .animation(.default, value: viewModel.formattedTime)
                }
                .buttonStyle(.plain)

                Spacer().frame(height: 72)

                // Controls
                HStack(spacing: 56) {

                    // Reset
                    Button {
                        viewModel.reset()
                        NotificationService.cancelCompletion()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundStyle(theme.labelColor)
                            .frame(width: 56, height: 56)
                            .background(theme.labelColor.opacity(0.12), in: Circle())
                    }
                    .buttonStyle(SpringButtonStyle())

                    // Play / Pause
                    Button { toggleTimer() } label: {
                        Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundStyle(.white)
                            .frame(width: 76, height: 76)
                            .background(theme.accentColor, in: Circle())
                    }
                    .buttonStyle(SpringButtonStyle())
                    .disabled(viewModel.isFinished)
                }

                Spacer()
            }
            .padding(.horizontal, 40)

            // ── Completion overlay ──────────────────────────────────────
            if viewModel.isFinished {
                completionOverlay
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }

            // ── Floating palette button (top-right) ────────────────────
            VStack {
                HStack {
                    Spacer()
                    Button { showingThemePicker = true } label: {
                        Image(systemName: "paintpalette.fill")
                            .font(.system(size: 17))
                            .foregroundStyle(theme.labelColor)
                            .frame(width: 44, height: 44)
                            .background(theme.labelColor.opacity(0.12), in: Circle())
                    }
                    .buttonStyle(SpringButtonStyle())
                    .padding(.trailing, 24)
                    .padding(.top, 60)
                }
                Spacer()
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
        // Sheet — set duration
        .sheet(isPresented: $showingTimeSetter) {
            TimeSetterSheet(currentSeconds: savedDurationSeconds) { newSeconds in
                savedDurationSeconds = newSeconds
                viewModel = TimerRunViewModel(durationSeconds: newSeconds)
            }
            .presentationDetents([.height(300)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(28)
            .presentationBackground(.thinMaterial)
        }
        // Sheet — pick theme/background
        .sheet(isPresented: $showingThemePicker) {
            ThemePickerSheet(selectedThemeID: $selectedThemeID)
                .presentationDetents([.height(210)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
                .presentationBackground(.thinMaterial)
        }
    }

    // MARK: - Completion overlay

    private var completionOverlay: some View {
        ZStack {
            theme.background
                .opacity(0.92)
                .ignoresSafeArea()

            VStack(spacing: 28) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(theme.accentColor)

                Text("Done!")
                    .font(theme.timerFont(size: 48))
                    .foregroundStyle(theme.primaryTextColor)

                Button("Restart") { viewModel.reset() }
                    .font(.system(.body, design: theme.fontStyle.design, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 36)
                    .padding(.vertical, 14)
                    .background(theme.accentColor, in: Capsule())
                    .buttonStyle(SpringButtonStyle())
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
            NotificationService.scheduleCompletion(timerLabel: "Timer", inSeconds: viewModel.remainingSeconds)
        }
    }

    private func triggerPulse() {
        guard theme.pulseOnTick, viewModel.isRunning else { return }
        withAnimation(.easeIn(duration: 0.08))  { pulse = true }
        withAnimation(.easeOut(duration: 0.12).delay(0.08)) { pulse = false }
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

// MARK: - Previews

#Preview("Minimal") { HomeView() }
#Preview("Midnight") {
    HomeView()
        .onAppear { UserDefaults.standard.set("midnight", forKey: "selectedThemeID") }
}

import SwiftUI

struct HomeView: View {
    @AppStorage("selectedThemeID") private var selectedThemeID = FreeThemes.minimal.id
    @AppStorage("savedDurationSeconds") private var savedDurationSeconds = 300

    @State private var viewModel: TimerRunViewModel

    @State private var showingTimeSetter = false
    @State private var showingThemePicker = false

    // Vanishing UI
    @State private var controlsVisible = true
    @State private var vanishTask: Task<Void, Never>?

    // Breathing gradient
    @State private var breathingPhase = false

    // Visual pulse
    @State private var pulse = false

    // Touch interaction
    @State private var touchLocation: CGPoint? = nil
    @State private var isTouching = false

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

            // ── Base background ─────────────────────────────────────────
            theme.background
                .ignoresSafeArea()

            // ── Breathing overlay ───────────────────────────────────────
            if let breathingGradient = theme.breathingGradient {
                breathingGradient
                    .ignoresSafeArea()
                    .opacity(breathingPhase ? 0.65 : 0)
            }

            // ── Interactive Touch Overlay ───────────────────────────────
            if let interactiveColors = theme.interactiveColors, isTouching, let loc = touchLocation {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: interactiveColors + [interactiveColors.last?.opacity(0) ?? .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                    .frame(width: 400, height: 400)
                    .position(loc)
                    .allowsHitTesting(false)
                    .blendMode(.screen)
            }

            // ── Timer content ───────────────────────────────────────────
            VStack(spacing: 0) {
                Spacer()

                // Time display — tap to set when controls are visible & timer stopped
                Button {
                    guard !viewModel.isRunning else { return }
                    showingTimeSetter = true
                } label: {
                    Text(viewModel.formattedTime)
                        .font(theme.timerFont(size: 130))
                        .foregroundStyle(theme.primaryTextColor)
                        .scaleEffect(pulse ? 1.08 : 1.0)
                        .contentTransition(.numericText(countsDown: true))
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: viewModel.formattedTime)
                        .shadow(color: theme.primaryTextColor.opacity(0.3), radius: pulse ? 15 : 0, x: 0, y: 0)
                }
                .buttonStyle(.plain)
                .allowsHitTesting(controlsVisible)

                Spacer().frame(height: 72)

                // Controls — fade out when timer is running
                HStack(spacing: 56) {

                    // Reset
                    Button {
                        viewModel.reset()
                        NotificationService.cancelCompletion()
                        cancelVanish()
                        stopBreathing()
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
                .opacity(controlsVisible ? 1 : 0)
                .allowsHitTesting(controlsVisible)

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
            .opacity(controlsVisible ? 1 : 0)
            .allowsHitTesting(controlsVisible)
        }
        // Tap anywhere to restore vanished controls
        .onTapGesture {
            guard !controlsVisible else { return }
            withAnimation(.easeIn(duration: 0.3)) { controlsVisible = true }
            if viewModel.isRunning { scheduleVanish() }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    touchLocation = value.location
                    if !isTouching {
                        withAnimation(.easeOut(duration: 0.2)) { isTouching = true }
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeOut(duration: 0.5)) { 
                        isTouching = false 
                    }
                }
        )
        .animation(.spring(response: 0.45, dampingFraction: 0.78), value: viewModel.isFinished)
        .onChange(of: viewModel.remainingSeconds) { _, _ in triggerPulse() }
        .onChange(of: viewModel.isFinished) { _, isFinished in
            if isFinished {
                cancelVanish()
                stopBreathing()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .background: viewModel.handleBackground()
            case .active:     viewModel.handleForeground()
            default:          break
            }
        }
        .task { await NotificationService.requestAuthorization() }
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

    // MARK: - Timer control

    private func toggleTimer() {
        if viewModel.isRunning {
            viewModel.pause()
            NotificationService.cancelCompletion()
            cancelVanish()
            stopBreathing()
        } else {
            viewModel.start()
            NotificationService.scheduleCompletion(timerLabel: "Timer", inSeconds: viewModel.remainingSeconds)
            scheduleVanish()
            startBreathing()
        }
    }

    // MARK: - Vanishing UI

    private func scheduleVanish() {
        vanishTask?.cancel()
        vanishTask = Task {
            try? await Task.sleep(for: .seconds(4))
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.8)) { controlsVisible = false }
        }
    }

    private func cancelVanish() {
        vanishTask?.cancel()
        vanishTask = nil
        withAnimation(.easeIn(duration: 0.3)) { controlsVisible = true }
    }

    // MARK: - Breathing gradient

    private func startBreathing() {
        guard theme.breathingDuration > 0 else { return }
        withAnimation(.easeInOut(duration: theme.breathingDuration).repeatForever(autoreverses: true)) {
            breathingPhase = true
        }
    }

    private func stopBreathing() {
        withAnimation(.easeOut(duration: 1.5)) {
            breathingPhase = false
        }
    }

    // MARK: - Pulse + haptics

    private func triggerPulse() {
        guard viewModel.isRunning else { return }

        // Per-theme haptic on every tick
        HapticsService.tick(style: theme.hapticStyle)

        // Visual pulse for themes that opt in
        guard theme.pulseOnTick else { return }
        withAnimation(.easeIn(duration: 0.08))  { pulse = true }
        withAnimation(.easeOut(duration: 0.12).delay(0.08)) { pulse = false }
    }
}

// MARK: - Spring Button Style

private struct SpringButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.8 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

// MARK: - Previews

#Preview("Minimal") { HomeView() }
#Preview("Midnight") {
    HomeView()
        .onAppear { UserDefaults.standard.set("midnight", forKey: "selectedThemeID") }
}

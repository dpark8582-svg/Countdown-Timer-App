import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \SavedTimer.createdAt, order: .reverse) private var timers: [SavedTimer]
    @Environment(\.modelContext) private var modelContext

    @State private var showingNewTimer = false
    @State private var activeTimer: SavedTimer?

    var body: some View {
        NavigationStack {
            ZStack {
                if timers.isEmpty {
                    emptyState
                        .transition(.opacity.combined(with: .scale(scale: 0.96)))
                } else {
                    timerList
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: timers.isEmpty)
            .navigationTitle("Timers")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingNewTimer = true
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .sheet(isPresented: $showingNewTimer) {
            NewTimerView()
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(24)
        }
        .sheet(item: $activeTimer) { timer in
            TimerRunView(savedTimer: timer)
                .presentationDragIndicator(.hidden)
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "timer")
                .font(.system(size: 56, weight: .thin))
                .foregroundStyle(.secondary)
            Text("No Timers")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Tap + to create your first timer.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Timer list

    private var timerList: some View {
        List {
            ForEach(timers) { timer in
                TimerRowView(timer: timer)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            activeTimer = timer
                        }
                    }
            }
            .onDelete(perform: deleteTimers)
        }
        .listStyle(.insetGrouped)
    }

    private func deleteTimers(at offsets: IndexSet) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            for index in offsets {
                modelContext.delete(timers[index])
            }
        }
    }
}

// MARK: - Timer Row

private struct TimerRowView: View {
    let timer: SavedTimer

    private var theme: TimerTheme {
        ThemeLibrary.theme(for: timer.themeID)
    }

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(theme.background)
                .frame(width: 46, height: 46)
                .overlay {
                    Text(timer.label.prefix(1).uppercased())
                        .font(.system(.body, design: theme.fontStyle.design, weight: .semibold))
                        .foregroundStyle(theme.primaryTextColor)
                }

            VStack(alignment: .leading, spacing: 3) {
                Text(timer.label)
                    .font(.body)
                    .fontWeight(.medium)
                Text(timer.formattedDuration)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "play.circle.fill")
                .font(.system(size: 28))
                .foregroundStyle(theme.accentColor)
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Previews

#Preview("Empty") {
    HomeView()
        .modelContainer(for: SavedTimer.self, inMemory: true)
}

#Preview("With Timers") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SavedTimer.self, configurations: config)
    let samples: [(String, Int, String)] = [
        ("Focus Session", 1500, "midnight"),
        ("Coffee Break",   300, "paper"),
        ("Workout",       2700, "minimal"),
    ]
    for (label, duration, theme) in samples {
        container.mainContext.insert(SavedTimer(label: label, durationSeconds: duration, themeID: theme))
    }
    return HomeView().modelContainer(container)
}

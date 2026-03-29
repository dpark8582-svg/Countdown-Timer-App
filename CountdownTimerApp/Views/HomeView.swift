import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \SavedTimer.createdAt, order: .reverse) private var timers: [SavedTimer]
    @Environment(\.modelContext) private var modelContext

    @State private var showingNewTimer = false
    @State private var activeTimer: SavedTimer?

    var body: some View {
        NavigationStack {
            Group {
                if timers.isEmpty {
                    emptyState
                } else {
                    timerList
                }
            }
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
        }
        .sheet(item: $activeTimer) { timer in
            TimerRunView(savedTimer: timer)
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "timer")
                .font(.system(size: 60, weight: .thin))
                .foregroundStyle(.secondary)
            Text("No Timers")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Tap  +  to create your first timer.")
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
                    .onTapGesture { activeTimer = timer }
            }
            .onDelete(perform: deleteTimers)
        }
        .listStyle(.insetGrouped)
    }

    private func deleteTimers(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(timers[index])
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
            // Theme color swatch
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

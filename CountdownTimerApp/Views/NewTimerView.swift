import SwiftUI

// Replaces the old NewTimerView — this bottom sheet lets the user set a duration.

struct TimeSetterSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var hours: Int
    @State private var minutes: Int
    @State private var seconds: Int

    let onSet: (Int) -> Void

    init(currentSeconds: Int, onSet: @escaping (Int) -> Void) {
        _hours   = State(wrappedValue: currentSeconds / 3600)
        _minutes = State(wrappedValue: (currentSeconds % 3600) / 60)
        _seconds = State(wrappedValue: currentSeconds % 60)
        self.onSet = onSet
    }

    private var totalSeconds: Int { hours * 3600 + minutes * 60 + seconds }

    var body: some View {
        VStack(spacing: 12) {
            Text("Set Timer")
                .font(.headline)
                .padding(.top, 16)

            HStack(spacing: 0) {
                Picker("Hours", selection: $hours) {
                    ForEach(0..<24, id: \.self) { Text("\($0)h") }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
                .clipped()

                Picker("Minutes", selection: $minutes) {
                    ForEach(0..<60, id: \.self) { Text("\($0)m") }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
                .clipped()

                Picker("Seconds", selection: $seconds) {
                    ForEach(0..<60, id: \.self) { Text("\($0)s") }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
                .clipped()
            }
            .frame(height: 150)

            Button {
                onSet(totalSeconds)
                dismiss()
            } label: {
                Text("Set")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        totalSeconds > 0 ? Color.accentColor : Color.secondary.opacity(0.25),
                        in: RoundedRectangle(cornerRadius: 14)
                    )
                    .foregroundStyle(totalSeconds > 0 ? .white : .secondary)
            }
            .disabled(totalSeconds == 0)
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
    }
}

#Preview {
    TimeSetterSheet(currentSeconds: 300) { _ in }
}

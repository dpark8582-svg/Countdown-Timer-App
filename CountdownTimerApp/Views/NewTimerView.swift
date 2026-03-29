import SwiftUI
import SwiftData

struct NewTimerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var label = ""
    @State private var hours = 0
    @State private var minutes = 5
    @State private var seconds = 0
    @State private var selectedThemeID = FreeThemes.minimal.id

    private var totalSeconds: Int {
        hours * 3600 + minutes * 60 + seconds
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Label") {
                    TextField("e.g. Focus Session", text: $label)
                }

                Section("Duration") {
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
                    .frame(height: 130)
                }

                Section("Theme") {
                    ThemePickerView(selectedThemeID: $selectedThemeID)
                        .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                }
            }
            .navigationTitle("New Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(totalSeconds == 0)
                }
            }
        }
    }

    private func save() {
        let finalLabel = label.trimmingCharacters(in: .whitespaces)
        let timer = SavedTimer(
            label: finalLabel.isEmpty ? "Timer" : finalLabel,
            durationSeconds: totalSeconds,
            themeID: selectedThemeID
        )
        modelContext.insert(timer)
        dismiss()
    }
}

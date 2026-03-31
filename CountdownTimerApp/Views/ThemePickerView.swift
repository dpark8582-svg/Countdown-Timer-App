import SwiftUI

// MARK: - Theme Picker Sheet (bottom sheet shown from palette button)

struct ThemePickerSheet: View {
    @Binding var selectedThemeID: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Background")
                .font(.headline)
                .padding(.horizontal, 20)
                .padding(.top, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ThemeLibrary.all) { theme in
                        ThemeCardView(theme: theme, isSelected: selectedThemeID == theme.id)
                            .onTapGesture {
                                guard !theme.isPremium else { return }
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedThemeID = theme.id
                                }
                                dismiss()
                            }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            }
        }
    }
}

// MARK: - Theme Card

struct ThemeCardView: View {
    let theme: TimerTheme
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 6) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 14)
                    .fill(theme.background)
                    .frame(width: 80, height: 80)
                    .overlay {
                        Text("00:00")
                            .font(theme.timerFont(size: 17))
                            .foregroundStyle(theme.primaryTextColor)
                    }
                    .overlay {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(theme.accentColor, lineWidth: 2.5)
                        }
                    }

                if theme.isPremium {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(5)
                        .background(Color.black.opacity(0.55), in: Circle())
                        .offset(x: 6, y: -6)
                }
            }

            Text(theme.name)
                .font(.caption)
                .foregroundStyle(theme.isPremium ? .secondary : .primary)
        }
        .opacity(theme.isPremium ? 0.55 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - Preview

#Preview {
    struct Wrapper: View {
        @State private var selectedID = FreeThemes.minimal.id
        var body: some View { ThemePickerSheet(selectedThemeID: $selectedID) }
    }
    return Wrapper()
}

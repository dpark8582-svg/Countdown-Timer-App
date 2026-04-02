import UIKit

enum HapticsService {
    static func tick(style: HapticStyle) {
        switch style {
        case .none:   break
        case .soft:   UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        case .medium: UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .rigid:  UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        }
    }
}

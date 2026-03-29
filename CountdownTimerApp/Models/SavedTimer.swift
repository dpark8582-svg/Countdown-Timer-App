import Foundation
import SwiftData

@Model
class SavedTimer {
    var label: String
    var durationSeconds: Int
    var themeID: String
    var createdAt: Date

    init(label: String, durationSeconds: Int, themeID: String = "minimal") {
        self.label = label
        self.durationSeconds = durationSeconds
        self.themeID = themeID
        self.createdAt = Date()
    }

    var formattedDuration: String {
        let h = durationSeconds / 3600
        let m = (durationSeconds % 3600) / 60
        let s = durationSeconds % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%02d:%02d", m, s)
    }
}

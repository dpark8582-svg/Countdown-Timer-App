import UserNotifications

enum NotificationService {
    private static let completionID = "timer.completion"

    static func requestAuthorization() async {
        try? await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound])
    }

    static func scheduleCompletion(timerLabel: String, inSeconds seconds: Int) {
        guard seconds > 0 else { return }

        let content = UNMutableNotificationContent()
        content.title = "Timer Complete"
        content.body = "\(timerLabel) has finished."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(seconds),
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: completionID,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    static func cancelCompletion() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [completionID])
    }
}

import UserNotifications

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    private let center = UNUserNotificationCenter.current()

    func setup() {
        center.delegate = self
        let done = UNNotificationAction(identifier: "DONE", title: "Tamamla")
        let snooze = UNNotificationAction(identifier: "SNOOZE", title: "10 dəq sonra")
        center.setNotificationCategories([
            UNNotificationCategory(identifier: "REMINDER", actions: [done, snooze], intentIdentifiers: [])
        ])
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func schedule(_ r: Reminder) {
        let content = UNMutableNotificationContent()
        content.title = r.title
        content.body = r.category.rawValue
        content.sound = .default
        content.categoryIdentifier = "REMINDER"

        let parts: Set<Calendar.Component> = r.repeatDaily
            ? [.hour, .minute]
            : [.year, .month, .day, .hour, .minute]
        let comps = Calendar.current.dateComponents(parts, from: r.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: r.repeatDaily)
        center.add(UNNotificationRequest(identifier: r.id.uuidString, content: content, trigger: trigger))
    }

    func cancel(_ r: Reminder) {
        center.removePendingNotificationRequests(withIdentifiers: [r.id.uuidString])
    }

    // Tətbiq açıq olanda da bildiriş və səs çıxsın
    func userNotificationCenter(_ c: UNUserNotificationCenter, willPresent n: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }

    // "10 dəq sonra" düyməsi
    func userNotificationCenter(_ c: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        guard response.actionIdentifier == "SNOOZE" else { return }
        let req = response.notification.request
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 600, repeats: false)
        try? await c.add(UNNotificationRequest(identifier: req.identifier + "-snooze", content: req.content, trigger: trigger))
    }
}

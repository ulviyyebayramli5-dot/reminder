import SwiftUI
import SwiftData

@main
struct ReminderApp: App {
    init() { NotificationManager.shared.setup() }
    var body: some Scene {
        WindowGroup { ContentView() }
            .modelContainer(for: Reminder.self)
    }
}

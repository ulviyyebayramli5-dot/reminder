import SwiftUI
import SwiftData

enum Category: String, Codable, CaseIterable, Identifiable {
    case work = "İş", study = "Dərs", other = "Digər"
    var id: String { rawValue }
    var color: Color {
        switch self {
        case .work: .blue
        case .study: .green
        case .other: .orange
        }
    }
}

@Model
final class Reminder {
    var id = UUID()
    var title: String
    var date: Date
    var categoryRaw: String
    var repeatDaily: Bool
    var loudAlarm: Bool   // AlarmKit üçün (2-ci mərhələ)
    var isDone = false

    var category: Category { Category(rawValue: categoryRaw) ?? .other }

    init(title: String, date: Date, category: Category, repeatDaily: Bool, loudAlarm: Bool) {
        self.title = title
        self.date = date
        self.categoryRaw = category.rawValue
        self.repeatDaily = repeatDaily
        self.loudAlarm = loudAlarm
    }
}

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Reminder.date) private var reminders: [Reminder]
    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(reminders) { r in
                    HStack(spacing: 12) {
                        Button {
                            r.isDone.toggle()
                            r.isDone ? NotificationManager.shared.cancel(r) : NotificationManager.shared.schedule(r)
                        } label: {
                            Image(systemName: r.isDone ? "checkmark.circle.fill" : "circle")
                                .font(.title2)
                                .foregroundStyle(r.category.color)
                        }
                        .buttonStyle(.plain)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(r.title).strikethrough(r.isDone)
                            Text(r.date.formatted(date: .abbreviated, time: .shortened) + (r.repeatDaily ? " · hər gün" : ""))
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        if r.loudAlarm { Image(systemName: "bell.badge.fill").foregroundStyle(.blue) }
                    }
                }
                .onDelete { idx in
                    idx.map { reminders[$0] }.forEach {
                        NotificationManager.shared.cancel($0)
                        context.delete($0)
                    }
                }
            }
            .overlay { if reminders.isEmpty { ContentUnavailableView("Xatırlatma yoxdur", systemImage: "bell", description: Text("+ düyməsi ilə əlavə et")) } }
            .navigationTitle("Xatırlatmalar")
            .toolbar { Button { showAdd = true } label: { Image(systemName: "plus") } }
            .sheet(isPresented: $showAdd) { AddReminderView() }
        }
    }
}

struct AddReminderView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var date = Date().addingTimeInterval(3600)
    @State private var category = Category.work
    @State private var repeatDaily = false
    @State private var loudAlarm = false

    var body: some View {
        NavigationStack {
            Form {
                TextField("Nə xatırladım?", text: $title)
                DatePicker("Vaxt", selection: $date)
                Picker("Kateqoriya", selection: $category) {
                    ForEach(Category.allCases) { Text($0.rawValue).tag($0) }
                }.pickerStyle(.segmented)
                Toggle("Hər gün təkrarla", isOn: $repeatDaily)
                Toggle("Səs çalan siqnal", isOn: $loudAlarm)
            }
            .navigationTitle("Yeni xatırlatma")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Ləğv et") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Saxla") {
                        let r = Reminder(title: title, date: date, category: category,
                                         repeatDaily: repeatDaily, loudAlarm: loudAlarm)
                        context.insert(r)
                        NotificationManager.shared.schedule(r)
                        dismiss()
                    }.disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

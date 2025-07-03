import Foundation

struct Habit: Identifiable, Codable {
    var id = UUID()
    var name: String
    var icon: String
    var creationDate: Date
    var records: [Date]
    var reminderTime: Date?

    func isCompletedToday() -> Bool {
        let calendar = Calendar.current
        return records.contains { calendar.isDateInToday($0) }
    }
}

import Foundation
import Combine

class HabitViewModel: ObservableObject {
    @Published var habits: [Habit] {
        didSet {
            saveHabits()
        }
    }

    private let userDefaultsKey = "habits"

    init() {
       
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedHabits = try? JSONDecoder().decode([Habit].self, from: data) {
            self.habits = decodedHabits
        } else {
            self.habits = []
        }

        if habits.isEmpty {
            addDefaultHabits()
        }
    }


    private func loadHabits() -> [Habit] {

        if let data = UserDefaults.standard.data(forKey: userDefaultsKey) {
            if let decodedHabits = try? JSONDecoder().decode([Habit].self, from: data) {
                return decodedHabits
            }
        }
        return []
    }


    private func saveHabits() {
        if let encoded = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    private func addDefaultHabits() {
        let defaultHabits = [
            Habit(name: "Пить воду", icon: "drop.fill", creationDate: Date(), records: []),
            Habit(name: "Читать 20 мин", icon: "book.closed.fill", creationDate: Date(), records: []),
            Habit(name: "Медитация", icon: "star.fill", creationDate: Date(), records: [])
        ]
        self.habits.append(contentsOf: defaultHabits)
    }

    func addHabit(name: String, icon: String, reminderTime: Date?) {
        let newHabit = Habit(name: name, icon: icon, creationDate: Date(), records: [], reminderTime: reminderTime)
        habits.append(newHabit)
        if let reminderTime = reminderTime {
            NotificationManager.shared.scheduleNotification(for: newHabit, at: reminderTime)
        }
    }

    func deleteHabit(at offsets: IndexSet) {
        for index in offsets {
            let habit = habits[index]
            NotificationManager.shared.cancelNotification(for: habit)
        }
        habits.remove(atOffsets: offsets)
    }

    func toggleHabitCompletion(for habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            var updatedHabit = habits[index]
            let calendar = Calendar.current

            if updatedHabit.isCompletedToday() {
                updatedHabit.records.removeAll { calendar.isDateInToday($0) }
            } else {
                updatedHabit.records.append(Date())
            }
            habits[index] = updatedHabit
        }
    }
}

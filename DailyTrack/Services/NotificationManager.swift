import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    private init() {
        requestAuthorization()
    }

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification authorization granted.")
            } else if let error = error {
                print("Notification authorization denied: \(error.localizedDescription)")
            }
        }
    }

    func scheduleNotification(for habit: Habit, at time: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Не забудь про привычку!"
        content.body = "Время для: \(habit.name)"
        content.sound = .default

        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: habit.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification for \(habit.name): \(error.localizedDescription)")
            } else {
                print("Notification scheduled for \(habit.name) at \(time)")
            }
        }
    }

    func cancelNotification(for habit: Habit) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [habit.id.uuidString])
        print("Cancelled notification for \(habit.name)")
    }
}

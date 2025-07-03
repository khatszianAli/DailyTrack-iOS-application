import SwiftUI

struct AddHabitView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var habitViewModel: HabitViewModel

    @State private var habitName: String = ""
    @State private var selectedIcon: String = "questionmark.circle.fill"
    let availableIcons = ["questionmark.circle.fill", "drop.fill", "book.closed.fill", "star.fill", "dumbbell.fill", "figure.walk", "leaf.fill", "lightbulb.fill", "sun.max.fill"]
    @State private var enableReminder: Bool = false
    @State private var reminderTime: Date = Date()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("ДЕТАЛИ ПРИВЫЧКИ")) {
                    TextField("Название привычки", text: $habitName)

                    Picker("Иконка", selection: $selectedIcon) {
                        ForEach(availableIcons, id: \.self) { iconName in
                            Image(systemName: iconName)
                                .tag(iconName)
                        }
                    }
                }

                Section(header: Text("НАПОМИНАНИЯ")) {
                    Toggle("Включить напоминание", isOn: $enableReminder)
                    if enableReminder {
                        DatePicker(
                            "Время напоминания",
                            selection: $reminderTime,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.compact)
                    }
                }

                Button("Добавить привычку") {
                    if !habitName.isEmpty {
                        habitViewModel.addHabit(name: habitName, icon: selectedIcon, reminderTime: enableReminder ? reminderTime : nil)
                        dismiss()
                    }
                }
                .disabled(habitName.isEmpty)
            }
            .navigationTitle("Новая Привычка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
    }
}


struct AddHabitView_Previews: PreviewProvider {
    static var previews: some View {
        AddHabitView()
            .environmentObject(HabitViewModel())
    }
}

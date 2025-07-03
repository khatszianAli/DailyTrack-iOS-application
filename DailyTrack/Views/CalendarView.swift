import SwiftUI

struct CalendarDay: Identifiable {
    let id = UUID()
    let date: Date?
}

struct CalendarView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var habitViewModel: HabitViewModel

    @State private var currentMonth: Date = Date()
    @State private var selectedDate: Date? = nil
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button {
                        changeMonth(by: -1)
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                    }
                    Spacer()
                    Text(dateFormatter.string(from: currentMonth).capitalized)
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                    Button {
                        changeMonth(by: 1)
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.title2)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 10)


                HStack {
                    ForEach(getWeekdaySymbols(), id: \.self) { weekday in
                        Text(weekday)
                            .font(.caption)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                    ForEach(getDaysInMonth()){ calendarDay in
                        DayCell(date: calendarDay.date, currentMonth: $currentMonth, selectedDate: $selectedDate)
                            .environmentObject(habitViewModel)
                    }
                }
                .padding(.horizontal)
                if let selectedDate = selectedDate, calendar.isDate(selectedDate, equalTo: currentMonth, toGranularity: .month) {
                    Divider()
                        .padding(.vertical, 5)
                    VStack(alignment: .leading) {
                        Text("Привычки за \(formattedDate(selectedDate)):")
                            .font(.headline)
                            .padding(.bottom, 5)

                        let completedHabits = habitViewModel.habits.filter { habit in
                            habit.records.contains { recordDate in
                                calendar.isDate(recordDate, inSameDayAs: selectedDate)
                            }
                        }

                        if completedHabits.isEmpty {
                            Text("В этот день привычек не выполнено.")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(completedHabits) { habit in
                                HStack {
                                    Image(systemName: habit.icon)
                                        .font(.caption)
                                    Text(habit.name)
                                        .font(.subheadline)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }

                Spacer()
            }
            .navigationTitle("Календарь")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
    }


    private func changeMonth(by months: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: months, to: currentMonth) {
            currentMonth = newMonth
            if let selected = selectedDate, !calendar.isDate(selected, equalTo: newMonth, toGranularity: .month) {
                selectedDate = nil
            }
        }
    }

    private func getWeekdaySymbols() -> [String] {
        let weekdays = calendar.shortWeekdaySymbols
        let firstWeekdayIndex = calendar.firstWeekday - 1
        let reorderedWeekdays = Array(weekdays[firstWeekdayIndex..<weekdays.count] + weekdays[0..<firstWeekdayIndex])
        return reorderedWeekdays
    }

    private func getDaysInMonth() -> [CalendarDay] {
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else {
            return []
        }

        guard let rangeOfDays = calendar.range(of: .day, in: .month, for: startOfMonth) else {
            return []
        }

        var days: [CalendarDay] = []

        let weekdayOfFirstDay = calendar.component(.weekday, from: startOfMonth)
        let firstWeekday = calendar.firstWeekday
        let offset = (weekdayOfFirstDay - firstWeekday + 7) % 7
        for _ in 0..<offset {
            days.append(CalendarDay(date: nil))
        }

        for day in rangeOfDays {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(CalendarDay(date: date))
            }
        }
        return days
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}

struct DayCell: View {
    let date: Date?
    @Binding var currentMonth: Date
    @Binding var selectedDate: Date?
    @EnvironmentObject var habitViewModel: HabitViewModel

    private let calendar = Calendar.current

    var isToday: Bool {
        guard let date = date else { return false }
        return calendar.isDateInToday(date)
    }

    var isSelected: Bool {
        guard let date = date, let selectedDate = selectedDate else { return false }
        return calendar.isDate(date, inSameDayAs: selectedDate)
    }

    var isOutsideCurrentMonth: Bool {
        guard let date = date else { return false }
        return !calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
    }

    var hasCompletedHabit: Bool {
        guard let date = date else { return false }
        return habitViewModel.habits.contains { habit in
            habit.records.contains { recordDate in
                calendar.isDate(recordDate, inSameDayAs: date)
            }
        }
    }

    var body: some View {
        Button {
            if let date = date {
                selectedDate = date
            }
        } label: {
            VStack {
                Text(date != nil ? "\(calendar.component(.day, from: date!))" : "")
                    .font(.subheadline)
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundColor(date == nil || isOutsideCurrentMonth ? .clear : .primary)
                    .frame(maxWidth: .infinity)
                    .padding(5)
                    .background(
                        Group {
                            if isToday {
                                Circle().stroke(Color.accentColor, lineWidth: 2)
                            } else if isSelected {
                                Circle().fill(Color.blue.opacity(0.2))
                            } else if hasCompletedHabit {
                                Circle().fill(Color.green.opacity(0.2))                            }
                        }
                    )
                    .clipShape(Circle())
            }
            .opacity(date == nil ? 0 : 1)
        }
        .disabled(date == nil)
    }
}


struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
            .environmentObject(HabitViewModel())
    }
}

extension Calendar {
    func isDate(_ date1: Date, inSameDayAs date2: Date) -> Bool {
        return isDate(date1, equalTo: date2, toGranularity: .day)
    }
}

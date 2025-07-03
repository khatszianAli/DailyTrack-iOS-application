import SwiftUI

struct HabitListView: View {
    @EnvironmentObject var habitViewModel: HabitViewModel
    @State private var showingAddHabitSheet = false
    @State private var showingCalendarSheet = false

    var body: some View {
        NavigationView {
            List {
                ForEach(habitViewModel.habits) { habit in
                    HabitRow(habit: habit)
                        .onTapGesture {
                            habitViewModel.toggleHabitCompletion(for: habit)
                        }
                }
                .onDelete(perform: habitViewModel.deleteHabit)
            }
            .navigationTitle("Мои Привычки")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingCalendarSheet = true
                    } label: {
                        Image(systemName: "calendar")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddHabitSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAddHabitSheet) {
                AddHabitView()
                    .environmentObject(habitViewModel)
            }
            .sheet(isPresented: $showingCalendarSheet){
                CalendarView()
                    .environmentObject(habitViewModel)
            }
        }
    }
}

struct HabitRow: View {
    let habit: Habit

    var body: some View {
        HStack {
            if(habit.isCompletedToday()){
                Image(systemName: habit.icon)
                    .font(.title2)
                    .foregroundColor(.green)
                    .frame(width: 40, height: 40)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(8)
                
            }else{
                Image(systemName: habit.icon)
                    .font(.title2)
                    .foregroundColor(.accentColor)
                    .frame(width: 40, height: 40)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }

            VStack(alignment: .leading) {
                Text(habit.name)
                    .font(.headline)
                Text("Дней выполнено: \(habit.records.count)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: habit.isCompletedToday() ? "checkmark.circle.fill" : "circle")
                       .font(.title)
                       .foregroundColor(habit.isCompletedToday() ? .green : .blue)
                       .contentShape(Circle())
        }
        .padding(.vertical, 8)
    }
}


struct HabitListView_Previews: PreviewProvider {
    static var previews: some View {
        HabitListView()
            .environmentObject(HabitViewModel())
    }
}

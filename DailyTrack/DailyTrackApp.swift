//
//  DailyTrackApp.swift
//  DailyTrack
//
//  Created by new owner on 24/6/25.
//

import SwiftUI

@main
struct DailyTrackApp: App {
    @StateObject private var habitViewModel = HabitViewModel()
    
    var body: some Scene {
        WindowGroup {
            HabitListView()
               .environmentObject(habitViewModel)
               .onAppear {
                   NotificationManager.shared.requestAuthorization()
               }
        }
    }
}

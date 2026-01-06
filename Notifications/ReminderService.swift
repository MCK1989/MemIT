//
//  ReminderService.swift
//  MemIT
//
//  Created by MemIT on 04/01/2026.
//

import Foundation
import UserNotifications
import Combine

class ReminderService: ObservableObject {
    static let shared = ReminderService()
    
    @Published var remindersEnabled = false
    @Published var preferredStudyTime = Date()
    @Published var dailyGoal = 20
    
    private init() {
        loadSettings()
    }
    
    // MARK: - Notifications
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.remindersEnabled = granted
                if granted {
                    self.scheduleReminders()
                }
            }
        }
    }
    
    func scheduleReminders() {
        guard remindersEnabled else { return }
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "Time to Study!"
        content.body = "Your flashcards are waiting for review."
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: preferredStudyTime)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyStudyReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func disableReminders() {
        remindersEnabled = false
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        saveSettings()
    }
    
    // MARK: - Settings
    
    private func loadSettings() {
        remindersEnabled = UserDefaults.standard.bool(forKey: "remindersEnabled")
        dailyGoal = UserDefaults.standard.integer(forKey: "dailyGoal")
        
        if let timeData = UserDefaults.standard.data(forKey: "preferredStudyTime"),
           let time = try? JSONDecoder().decode(Date.self, from: timeData) {
            preferredStudyTime = time
        }
    }
    
    func saveSettings() {
        UserDefaults.standard.set(remindersEnabled, forKey: "remindersEnabled")
        UserDefaults.standard.set(dailyGoal, forKey: "dailyGoal")
        
        if let timeData = try? JSONEncoder().encode(preferredStudyTime) {
            UserDefaults.standard.set(timeData, forKey: "preferredStudyTime")
        }
    }
}

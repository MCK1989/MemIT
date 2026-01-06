//
//  SettingsView.swift
//  MemIT
//
//  Created by Marco Cortellazzi on 04/01/26.
//

import SwiftUI
import UserNotifications

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingPermissionAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                studySettingsSection
                
                languageSection
                
                notificationSection
                
                aboutSection
            }
            .navigationTitle(L(.settings, from: appState))
            .alert(L(.notificationsDisabled, from: appState), isPresented: $showingPermissionAlert) {
                Button(L(.openSettings, from: appState)) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button(L(.cancel, from: appState), role: .cancel) {
                    appState.settings.enableNotifications = false
                }
            } message: {
                Text(L(.notificationsDisabledDesc, from: appState))
            }
            .onChange(of: appState.settings.dailyNewCards) { _, _ in
                appState.settings.save()
            }
            .onChange(of: appState.settings.maxReviewCards) { _, _ in
                appState.settings.save()
            }
            .onChange(of: appState.settings.studyFromEnglish) { _, _ in
                appState.settings.save()
            }
            .onChange(of: appState.settings.enableNotifications) { _, newValue in
                handleNotificationToggle(enabled: newValue)
            }
            .onChange(of: appState.settings.studyReminder) { _, _ in
                appState.settings.save()
                if appState.settings.enableNotifications {
                    scheduleNotification()
                }
            }
        }
    }
    
    private var studySettingsSection: some View {
        Section(L(.studySettings, from: appState)) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.green)
                
                VStack(alignment: .leading, spacing: 2) {
                    LocalizedText(key: .dailyNewCards)
                        .font(.headline)
                    LocalizedText(key: .dailyNewCardsDesc)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Stepper(
                    value: $appState.settings.dailyNewCards,
                    in: 1...100,
                    step: 1
                ) {
                    Text("\(appState.settings.dailyNewCards)")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
            
            HStack {
                Image(systemName: "arrow.clockwise.circle.fill")
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 2) {
                    LocalizedText(key: .maxReviews)
                        .font(.headline)
                    LocalizedText(key: .maxReviewsDesc)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Stepper(
                    value: $appState.settings.maxReviewCards,
                    in: 10...500,
                    step: 5
                ) {
                    Text("\(appState.settings.maxReviewCards)")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
            
            HStack {
                Image(systemName: "globe")
                    .foregroundColor(appState.settings.studyFromEnglish ? .green : .blue)
                
                VStack(alignment: .leading, spacing: 2) {
                    LocalizedText(key: .studyFromEnglish)
                        .font(.headline)
                    LocalizedText(key: .startFromEnglish)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $appState.settings.studyFromEnglish)
            }
        }
    }
    
    private var languageSection: some View {
        Section(L(.language, from: appState)) {
            HStack {
                Image(systemName: "globe")
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 2) {
                    LocalizedText(key: .appLanguage)
                        .font(.headline)
                    LocalizedText(key: .changeInterfaceLanguage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Picker("", selection: $appState.localization.currentLanguage) {
                    ForEach(LocalizationManager.AppLanguage.allCases, id: \.self) { language in
                        HStack {
                            Text(language.flag)
                            Text(language.displayName)
                        }
                        .tag(language)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
        }
    }
    
    private var notificationSection: some View {
        Section(L(.notifications, from: appState)) {
            HStack {
                Image(systemName: "bell.fill")
                    .foregroundStyle(appState.settings.enableNotifications ? .orange : .secondary)
                
                VStack(alignment: .leading, spacing: 2) {
                    LocalizedText(key: .studyReminder)
                        .font(.headline)
                    LocalizedText(key: .studyReminderDesc)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $appState.settings.enableNotifications)
            }
            
            if appState.settings.enableNotifications {
                DatePicker(
                    L(.reminderTime, from: appState),
                    selection: $appState.settings.studyReminder,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.compact)
            }
        }
    }
    
    private var aboutSection: some View {
        Section(L(.about, from: appState)) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 2) {
                    LocalizedText(key: .version)
                        .font(.headline)
                    Text("1.0.0")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 2) {
                    LocalizedText(key: .srsAlgorithm)
                        .font(.headline)
                    LocalizedText(key: .srsDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Link(destination: URL(string: "https://github.com/marcocortellazzi/MemIT")!) {
                HStack {
                    Image(systemName: "link")
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        LocalizedText(key: .sourceCode)
                            .font(.headline)
                        LocalizedText(key: .viewOnGithub)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Notification Handling
    
    private func handleNotificationToggle(enabled: Bool) {
        if enabled {
            // Richiedi i permessi per le notifiche
            requestNotificationPermission()
        } else {
            // Disabilita le notifiche
            cancelNotifications()
            appState.settings.save()
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    // Permesso concesso, schedula la notifica
                    print("✅ Notification permission granted")
                    scheduleNotification()
                    appState.settings.save()
                } else {
                    // Permesso negato
                    print("❌ Notification permission denied")
                    appState.settings.enableNotifications = false
                    showingPermissionAlert = true
                }
                
                if let error = error {
                    print("❌ Error requesting permission: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func scheduleNotification() {
        // Rimuovi le notifiche esistenti
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        guard appState.settings.enableNotifications else { return }
        
        // Crea il contenuto della notifica
        let content = UNMutableNotificationContent()
        content.title = L(.studyReminderTitle, from: appState)
        content.body = L(.studyReminderBody, from: appState)
        content.sound = .default
        content.badge = 1
        
        // Estrai ora e minuti dalla data del reminder
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: appState.settings.studyReminder)
        
        // Crea il trigger che si ripete ogni giorno
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // Crea la richiesta
        let request = UNNotificationRequest(
            identifier: "dailyStudyReminder",
            content: content,
            trigger: trigger
        )
        
        // Schedula la notifica
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling notification: \(error.localizedDescription)")
            } else {
                let hour = components.hour ?? 0
                let minute = components.minute ?? 0
                print("✅ Notification scheduled for \(String(format: "%02d:%02d", hour, minute))")
                
                // Verifica che sia stata effettivamente schedulata
                UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                    print("📋 Pending notifications: \(requests.count)")
                    for request in requests {
                        print("   - \(request.identifier)")
                    }
                }
            }
        }
    }
    
    private func cancelNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🔕 Notifications cancelled")
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}

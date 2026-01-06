//
//  MemITApp.swift
//  MemIT
//
//  Created by Marco Cortellazzi on 04/01/26.
//

import SwiftUI
import UserNotifications

// Delegate per gestire le notifiche quando l'app è in foreground
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Mostra la notifica anche quando l'app è in foreground
        print("🔔 Notification received in foreground")
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Gestisci il tap sulla notifica
        print("📱 User tapped notification")
        completionHandler()
    }
}

@main
struct MemITApp: App {
    @StateObject private var appState = AppState()
    
    // Il delegate deve persistere per tutta la vita dell'app
    // Usa @UIApplicationDelegateAdaptor o mantienilo come variabile statica
    private static let notificationDelegate = NotificationDelegate()
    
    init() {
        // Imposta il delegate per le notifiche
        UNUserNotificationCenter.current().delegate = Self.notificationDelegate
        print("📱 MemIT App initialized, notification delegate set")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .task {
                    // Verifica e sincronizza lo stato delle notifiche all'avvio
                    await checkAndSyncNotificationStatus()
                }
        }
    }
    
    private func checkAndSyncNotificationStatus() async {
        // Ottieni lo stato attuale dei permessi
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        let authStatus = settings.authorizationStatus
        
        print("📋 Notification authorization status: \(authStatus.rawValue)")
        print("   - 0 = notDetermined (mai chiesto)")
        print("   - 1 = denied (negato dall'utente)")
        print("   - 2 = authorized (permesso concesso)")
        print("   - 3 = provisional")
        print("   - 4 = ephemeral")
        
        // Se è il primo avvio (permessi mai richiesti), chiedi i permessi
        if authStatus == .notDetermined {
            print("🔔 First launch detected, requesting notification permission...")
            await requestInitialNotificationPermission()
            return // Ritorna subito dopo aver richiesto i permessi
        }
        
        // Sincronizza lo stato delle notifiche con i permessi del sistema
        await MainActor.run {
            // Se i permessi sono concessi e le notifiche sono abilitate, schedula
            if (authStatus == .authorized || authStatus == .provisional) && appState.settings.enableNotifications {
                print("✅ Notifications authorized and enabled, ensuring notification is scheduled")
                scheduleInitialNotification()
            }
            // Se i permessi sono negati ma il toggle è attivo, disattivalo
            else if authStatus == .denied && appState.settings.enableNotifications {
                print("⚠️ Notifications denied but toggle is on, disabling...")
                appState.settings.enableNotifications = false
                appState.settings.save()
            }
        }
        
        // Controlla le notifiche pending
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        print("📋 Pending notifications: \(requests.count)")
        for request in requests {
            if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                print("   - \(request.identifier): \(trigger.dateComponents)")
            } else if let trigger = request.trigger as? UNTimeIntervalNotificationTrigger {
                print("   - \(request.identifier): in \(trigger.timeInterval) seconds")
            } else {
                print("   - \(request.identifier)")
            }
        }
    }
    
    private func requestInitialNotificationPermission() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            
            await MainActor.run {
                if granted {
                    print("✅ Notification permission granted on first launch")
                    appState.settings.enableNotifications = true
                    appState.settings.save()
                    
                    // Schedula subito la notifica giornaliera
                    scheduleInitialNotification()
                } else {
                    print("❌ Notification permission denied on first launch")
                    appState.settings.enableNotifications = false
                    appState.settings.save()
                }
            }
        } catch {
            print("❌ Error requesting notification permission: \(error.localizedDescription)")
        }
    }
    
    private func scheduleInitialNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Time to Study!"
        content.body = "Your flashcards are waiting for review."
        content.sound = .default
        content.badge = 1
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: appState.settings.studyReminder)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: "dailyStudyReminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling initial notification: \(error.localizedDescription)")
            } else {
                let hour = components.hour ?? 9
                let minute = components.minute ?? 0
                print("✅ Initial notification scheduled for \(String(format: "%02d:%02d", hour, minute))")
            }
        }
    }
}

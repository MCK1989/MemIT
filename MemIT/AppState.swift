//
//  AppState.swift
//  MemIT
//
//  Created by Marco Cortellazzi on 04/01/26.
//

import SwiftUI
import Combine

@MainActor
class AppState: ObservableObject {
    @Published var selectedDeckId: UUID?
    @Published var decks: [Deck] = []
    @Published var settings = StudySettings()
    @Published var localization = LocalizationManager()
    @Published var globalStats = GlobalStats()
    
    init() {
        // Carica le impostazioni salvate
        settings = StudySettings.load()
        globalStats = GlobalStats.load()
        loadDecks()
        
        // Osserva quando l'app torna in foreground per verificare il cambio giorno
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.checkAndResetDailyStats()
            }
        }
    }
    
    private func loadDecks() {
        // Carica i mazzi dai file CSV nella cartella Resources/Italian Decks
        decks = loadDecksFromBundle()
        
        // Se non ci sono mazzi caricati, mostra un messaggio
        if decks.isEmpty {
            print("⚠️ No decks loaded from bundle")
        } else {
            print("✅ Loaded \(decks.count) decks from bundle")
        }
    }
    
    /// Carica i mazzi CSV dal bundle dell'app
    private func loadDecksFromBundle() -> [Deck] {
        var loadedDecks: [Deck] = []
        
        // Lista dei file CSV da caricare (formato: nome file -> nome mazzo)
        let csvFiles: [(fileName: String, deckName: String)] = [
            ("Italian - Level A1", "Italian - Level A1"),
            ("Italian - Level A2", "Italian - Level A2"),
            ("Italian - Level B1", "Italian - Level B1"),
            ("Italian - Level B2", "Italian - Level B2")
        ]
        
        for (fileName, deckName) in csvFiles {
            // Cerca il file nel bundle (alla radice, senza subdirectory)
            guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: "csv") else {
                print("⚠️ CSV file not found: \(fileName).csv")
                continue
            }
            
            do {
                // Importa il mazzo usando CSVImporter
                let deck = try CSVImporter.createDeck(from: fileURL, named: deckName)
                loadedDecks.append(deck)
                print("✅ Loaded deck: \(deckName) with \(deck.cards.count) cards")
            } catch {
                print("❌ Error loading \(fileName).csv: \(error.localizedDescription)")
            }
        }
        
        return loadedDecks
    }
    
    func selectDeck(_ deck: Deck) {
        selectedDeckId = deck.id
    }
    
    var selectedDeck: Deck? {
        decks.first { $0.id == selectedDeckId }
    }
    
    /// Restituisce il saluto appropriato in base all'ora del giorno
    func greetingKey() -> LocalizationKey {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<12:
            return .goodMorning
        case 12..<18:
            return .goodAfternoon
        default:
            return .goodEvening
        }
    }
    
    /// Aggiorna le statistiche globali dopo una sessione di studio
    func updateGlobalStats(with sessionStats: StudyStats) {
        print("📊 Updating global stats with session: \(sessionStats.totalStudied) cards")
        globalStats.addSession(sessionStats)
        print("📊 Global stats now: \(globalStats.totalCardsStudied) total cards")
    }
    
    /// Verifica e resetta le statistiche giornaliere se è un nuovo giorno
    private func checkAndResetDailyStats() {
        if !Calendar.current.isDateInToday(globalStats.todayDate) {
            globalStats.resetDailyStats()
            globalStats.save()
            print("🔄 New day detected, daily stats reset")
        }
    }
}

struct StudySettings: Codable {
    var dailyNewCards: Int = 20
    var maxReviewCards: Int = 80
    var enableNotifications: Bool = true  // Attivo di default, i permessi vengono richiesti al primo avvio
    var studyFromEnglish: Bool = false
    var studyReminder: Date = {
        let now = Date()
        return Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: now) ?? now
    }()
    
    // MARK: - Persistence
    
    private static let userDefaultsKey = "StudySettings"
    
    /// Load settings from UserDefaults
    static func load() -> StudySettings {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let settings = try? JSONDecoder().decode(StudySettings.self, from: data) else {
            print("⚠️ Failed to load settings, using defaults")
            return StudySettings()
        }
        print("✅ Settings loaded: dailyNewCards = \(settings.dailyNewCards)")
        return settings
    }
    
    /// Save settings to UserDefaults
    func save() {
        guard let data = try? JSONEncoder().encode(self) else {
            print("❌ Failed to encode settings")
            return
        }
        UserDefaults.standard.set(data, forKey: Self.userDefaultsKey)
        print("💾 Settings saved: dailyNewCards = \(dailyNewCards)")
    }
}

// MARK: - Global Statistics

struct GlobalStats: Codable {
    var totalCardsStudied: Int = 0
    var totalNewCardsStudied: Int = 0
    var totalReviewCardsStudied: Int = 0
    var totalAgainCount: Int = 0
    var totalHardCount: Int = 0
    var totalGoodCount: Int = 0
    var totalEasyCount: Int = 0
    var studySessions: Int = 0
    var lastStudyDate: Date?
    var totalStudyTimeMinutes: Int = 0
    
    // Statistiche giornaliere (reset ogni giorno)
    var todayDate: Date = Date()
    var todayCardsStudied: Int = 0
    var todayNewCards: Int = 0
    var todayReviews: Int = 0
    
    var accuracy: Double {
        let total = totalAgainCount + totalHardCount + totalGoodCount + totalEasyCount
        return total > 0 ? Double(totalGoodCount + totalEasyCount) / Double(total) : 0.0
    }
    
    var todayAccuracy: Double {
        let totalToday = todayCardsStudied
        return totalToday > 0 ? Double(todayCardsStudied) / Double(totalToday) : 0.0
    }
    
    // MARK: - Persistence
    
    private static let userDefaultsKey = "GlobalStats"
    
    /// Load stats from UserDefaults
    static func load() -> GlobalStats {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              var stats = try? JSONDecoder().decode(GlobalStats.self, from: data) else {
            print("⚠️ Failed to load global stats, using defaults")
            return GlobalStats()
        }
        
        // Controlla se è un nuovo giorno
        if !Calendar.current.isDateInToday(stats.todayDate) {
            stats.resetDailyStats()
        }
        
        print("✅ Global stats loaded: \(stats.totalCardsStudied) total cards")
        return stats
    }
    
    /// Save stats to UserDefaults
    mutating func save() {
        // Aggiorna la data odierna
        todayDate = Date()
        
        guard let data = try? JSONEncoder().encode(self) else {
            print("❌ Failed to encode global stats")
            return
        }
        UserDefaults.standard.set(data, forKey: Self.userDefaultsKey)
        print("💾 Global stats saved: \(totalCardsStudied) total cards")
    }
    
    /// Aggiungi una sessione di studio
    mutating func addSession(_ sessionStats: StudyStats) {
        // Aggiorna statistiche globali
        totalCardsStudied += sessionStats.totalStudied
        totalNewCardsStudied += sessionStats.newCardsStudied
        totalReviewCardsStudied += sessionStats.reviewCardsStudied
        totalAgainCount += sessionStats.againCount
        totalHardCount += sessionStats.hardCount
        totalGoodCount += sessionStats.goodCount
        totalEasyCount += sessionStats.easyCount
        studySessions += 1
        lastStudyDate = Date()
        
        // Aggiorna statistiche giornaliere
        if Calendar.current.isDateInToday(todayDate) {
            todayCardsStudied += sessionStats.totalStudied
            todayNewCards += sessionStats.newCardsStudied
            todayReviews += sessionStats.reviewCardsStudied
        } else {
            // Nuovo giorno, reset
            resetDailyStats()
            todayCardsStudied = sessionStats.totalStudied
            todayNewCards = sessionStats.newCardsStudied
            todayReviews = sessionStats.reviewCardsStudied
        }
        
        // Salva
        save()
    }
    
    /// Reset delle statistiche giornaliere
    mutating func resetDailyStats() {
        todayDate = Date()
        todayCardsStudied = 0
        todayNewCards = 0
        todayReviews = 0
        print("🔄 Daily stats reset")
    }
}



//
//  StudyViewModel.swift
//  MemIT
//
//  Created by Marco Cortellazzi on 04/01/26.
//

import SwiftUI
import Combine

@MainActor
class StudyViewModel: ObservableObject {
    @Published var currentCard: Card?
    @Published var showBack = false
    @Published var studyQueue: [Card] = []
    @Published var todayStats = StudyStats()
    @Published var isSessionActive = false
    @Published var totalCardsInSession = 0
    
    private var appState: AppState
    private var studiedCardIds: Set<UUID> = [] // Traccia le carte già studiate in questa sessione
    private var statsSaved = false // Flag per evitare di salvare due volte
    
    init(appState: AppState) {
        self.appState = appState
    }
    
    /// Update the AppState reference (workaround for @EnvironmentObject in SwiftUI)
    func updateAppState(_ newAppState: AppState) {
        self.appState = newAppState
    }
    
    func startSession() {
        guard let selectedDeck = appState.selectedDeck else { return }
        
        // Reset del flag quando inizia una nuova sessione
        statsSaved = false
        
        // Prepara la coda di studio
        prepareStudyQueue(for: selectedDeck)
        
        // Se non ci sono carte disponibili, non avviare la sessione
        if studyQueue.isEmpty {
            isSessionActive = false
            currentCard = nil
            return
        }
        
        // Carica la prima carta
        loadNextCard()
        
        isSessionActive = true
    }
    
    func endSession() {
        // Salva le statistiche della sessione nello stato globale
        saveStatsIfNeeded()
        
        isSessionActive = false
        currentCard = nil
        showBack = false
        studyQueue.removeAll()
        totalCardsInSession = 0
        studiedCardIds.removeAll() // Reset delle carte studiate
        
        // Reset delle statistiche della sessione
        todayStats = StudyStats()
        statsSaved = false // Reset del flag
    }
    
    /// Salva le statistiche solo se non sono già state salvate
    func saveStatsIfNeeded() {
        guard !statsSaved && todayStats.totalStudied > 0 else { return }
        
        appState.updateGlobalStats(with: todayStats)
        statsSaved = true
        print("💾 Stats saved: \(todayStats.totalStudied) cards")
    }
    
    func flipCard() {
        withAnimation(.easeInOut(duration: 0.18)) {
            showBack.toggle()
        }
    }
    
    func rateCard(_ rating: Rating) {
        guard let card = currentCard else { return }
        
        // Aggiungi la carta alla lista delle carte studiate
        studiedCardIds.insert(card.id)
        
        // Applica l'algoritmo SRS
        applyRating(to: card, rating: rating)
        
        // Aggiorna le statistiche
        updateStats(for: rating)
        
        // Prepara per la prossima carta
        showBack = false
        loadNextCard()
    }
    
    private func prepareStudyQueue(for deck: Deck) {
        var queue: [Card] = []
        
        let maxTotal = appState.settings.maxReviewCards      // Limite totale (es. 80)
        let maxNew = appState.settings.dailyNewCards         // Limite nuove carte (es. 20)
        
        // 1. Priorità alle carte dovute (escluse le nuove, limitate a maxTotal)
        let dueCards = deck.dueCards()
            .filter { !studiedCardIds.contains($0.id) && !$0.srs.isNew }
            .shuffled()
        let dueCardsToAdd = Array(dueCards.prefix(maxTotal))
        queue.append(contentsOf: dueCardsToAdd)
        
        // 2. Calcola spazio rimanente per carte nuove
        let remainingTotal = maxTotal - queue.count
        let allowedNew = min(maxNew, remainingTotal)
        
        if allowedNew > 0 {
            let newCards = deck.newCards
                .filter { !studiedCardIds.contains($0.id) }
                .shuffled()
            let newCardsToAdd = Array(newCards.prefix(allowedNew))
            queue.append(contentsOf: newCardsToAdd)
        }
        
        // 3. Mescola la coda finale (mix di carte dovute e nuove)
        studyQueue = queue.shuffled()
        
        // Salva il numero totale di carte nella sessione
        totalCardsInSession = studyQueue.count
    }
    
    private func loadNextCard() {
        if studyQueue.isEmpty {
            // Sessione completata - salva le statistiche prima di terminare
            saveStatsIfNeeded()
            currentCard = nil
            isSessionActive = false
        } else {
            currentCard = studyQueue.removeFirst()
        }
    }
    
    private func applyRating(to card: Card, rating: Rating) {
        // TODO: Implementare l'algoritmo SRS completo
        // Per ora, semplice demo
        var updatedCard = card
        
        switch rating {
        case .again:
            updatedCard.srs.dueDate = Calendar.current.date(byAdding: .minute, value: 1, to: Date()) ?? Date()
            updatedCard.srs.lapses += 1
        case .hard:
            updatedCard.srs.dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        case .good:
            updatedCard.srs.dueDate = Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()
            updatedCard.srs.repetitions += 1
        case .easy:
            updatedCard.srs.dueDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
            updatedCard.srs.repetitions += 1
        }
        
        updatedCard.touch()
        
        // Aggiorna la carta nel deck
        if let deckIndex = appState.decks.firstIndex(where: { $0.id == appState.selectedDeckId }) {
            appState.decks[deckIndex].updateCard(updatedCard)
        }
    }
    
    private func updateStats(for rating: Rating) {
        if currentCard?.srs.isNew == true {
            todayStats.newCardsStudied += 1
        } else {
            todayStats.reviewCardsStudied += 1
        }
        
        switch rating {
        case .again:
            todayStats.againCount += 1
        case .hard:
            todayStats.hardCount += 1
        case .good:
            todayStats.goodCount += 1
        case .easy:
            todayStats.easyCount += 1
        }
    }
}

struct StudyStats {
    var newCardsStudied: Int = 0
    var reviewCardsStudied: Int = 0
    var againCount: Int = 0
    var hardCount: Int = 0
    var goodCount: Int = 0
    var easyCount: Int = 0
    
    var totalStudied: Int {
        return newCardsStudied + reviewCardsStudied
    }
    
    var accuracy: Double {
        let total = againCount + hardCount + goodCount + easyCount
        return total > 0 ? Double(goodCount + easyCount) / Double(total) : 0.0
    }
}

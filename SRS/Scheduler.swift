//
//  Scheduler.swift
//  MemIT
//
//  Created by MemIT on 04/01/2026.
//

import Foundation

struct Scheduler {
    
    // MARK: - Core SRS Functions
    
    /// Select next cards for study session
    func nextCards(from deck: Deck, at date: Date = Date(), limit: Int = 20) -> [Card] {
        let dueCards = deck.dueCards(at: date)
            .sorted { $0.srs.dueDate < $1.srs.dueDate }
        
        let newCards = deck.newCards.shuffled()
        
        let dueCount = min(dueCards.count, limit)
        let newCount = min(newCards.count, limit - dueCount)
        
        var selectedCards: [Card] = []
        selectedCards.append(contentsOf: Array(dueCards.prefix(dueCount)))
        selectedCards.append(contentsOf: Array(newCards.prefix(newCount)))
        
        return selectedCards.shuffled()
    }
    
    /// Apply SM-2 algorithm and return updated card
    func apply(rating: Rating, to card: Card, at date: Date = Date()) -> Card {
        var updatedCard = card
        updatedCard.touch()
        
        let quality = rating.sm2Quality
        var srs = card.srs
        
        // SM-2 Algorithm Implementation
        if quality >= 3 {
            // Correct response
            if srs.repetitions == 0 {
                srs.intervalDays = 1
            } else if srs.repetitions == 1 {
                srs.intervalDays = 6
            } else {
                srs.intervalDays = Int(Double(srs.intervalDays) * srs.easeFactor)
            }
            srs.repetitions += 1
        } else {
            // Incorrect response
            srs.repetitions = 0
            srs.intervalDays = 1
            srs.lapses += 1
        }
        
        // Update ease factor
        let q = Double(quality)
        srs.easeFactor = srs.easeFactor + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
        
        // Minimum ease factor constraint
        if srs.easeFactor < 1.3 {
            srs.easeFactor = 1.3
        }
        
        // Calculate next due date
        if let nextDate = Calendar.current.date(byAdding: .day, value: srs.intervalDays, to: date) {
            srs.dueDate = nextDate
        }
        
        updatedCard.srs = srs
        return updatedCard
    }
}

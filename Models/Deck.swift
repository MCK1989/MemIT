//
//  Deck.swift
//  MemIT
//
//  Created by MemIT on 04/01/2026.
//

import Foundation

struct Deck: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var description: String
    var cards: [Card]
    var createdAt: Date
    var updatedAt: Date
    var color: String // Hex color code
    var isArchived: Bool

    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        cards: [Card] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        color: String = "#007AFF",
        isArchived: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.cards = cards
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.color = color
        self.isArchived = isArchived
    }
    
    // MARK: - CRUD Operations
    
    mutating func addCard(_ card: Card) {
        cards.append(card)
        touch()
    }
    
    mutating func removeCard(withId id: UUID) {
        cards.removeAll { $0.id == id }
        touch()
    }
    
    mutating func updateCard(_ updatedCard: Card) {
        if let index = cards.firstIndex(where: { $0.id == updatedCard.id }) {
            cards[index] = updatedCard
            touch()
        }
    }
    
    // MARK: - Simple Filters
    
    var activeCards: [Card] {
        return cards.filter { !$0.isArchived }
    }
    
    func dueCards(at date: Date = Date()) -> [Card] {
        return activeCards.filter { $0.srs.isDue(at: date) }
    }
    
    var newCards: [Card] {
        return activeCards.filter { $0.srs.isNew }
    }
    
    // MARK: - Simple Stats
    
    var totalCount: Int {
        return activeCards.count
    }
    
    func dueCount(at date: Date = Date()) -> Int {
        return dueCards(at: date).count
    }
    
    var newCount: Int {
        return newCards.count
    }
    
    // MARK: - Helper
    
    mutating func touch() {
        updatedAt = Date()
    }
}

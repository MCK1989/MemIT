//
//  Store.swift
//  MemIT
//
//  Created by MemIT on 04/01/2026.
//

import Foundation

protocol Store {
    func load() async throws -> [Deck]
    func save(_ decks: [Deck]) async throws
}

class MemoryStore: Store {
    private var decks: [Deck] = []
    
    func load() async throws -> [Deck] {
        return decks
    }
    
    func save(_ decks: [Deck]) async throws {
        self.decks = decks
    }
}

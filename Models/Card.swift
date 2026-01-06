//
//  Card.swift
//  MemIT
//
//  Created by MemIT on 04/01/2026.
//

import Foundation

struct Card: Identifiable, Codable, Equatable {
    let id: UUID
    var front: String
    var back: String
    var createdAt: Date
    var updatedAt: Date
    var srs: SRSState
    var isArchived: Bool
    
    init(front: String, back: String) {
        self.id = UUID()
        self.front = front
        self.back = back
        self.createdAt = Date()
        self.updatedAt = Date()
        self.srs = SRSState()
        self.isArchived = false
    }
    
    // MARK: - Validation & Helpers
    
    var isValid: Bool {
        return !front.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !back.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var normalizedFront: String {
        return front.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var normalizedBack: String {
        return back.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    mutating func touch() {
        updatedAt = Date()
    }
}

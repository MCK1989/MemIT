//
//  SRSState.swift
//  MemIT
//
//  Created by MemIT on 04/01/2026.
//

import Foundation

struct SRSState: Codable, Equatable {
    var dueDate: Date
    var easeFactor: Double
    var intervalDays: Int
    var repetitions: Int
    var lapses: Int
    
    init() {
        self.dueDate = Date()
        self.easeFactor = 2.5
        self.intervalDays = 1
        self.repetitions = 0
        self.lapses = 0
    }
    
    func isDue(at date: Date = Date()) -> Bool {
        return dueDate <= date
    }
    
    var isNew: Bool {
        return repetitions == 0
    }
    
    var isDue: Bool {
        return isDue(at: Date()) && !isNew
    }
    
    var nextReview: Date? {
        return isNew ? nil : dueDate
    }
}

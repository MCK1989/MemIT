//
//  Rating.swift
//  MemIT
//
//  Created by MemIT on 04/01/2026.
//

import Foundation

enum Rating: Int, CaseIterable {
    case again = 1
    case hard = 2  
    case good = 3
    case easy = 4
    
    var title: String {
        switch self {
        case .again: return "Again"
        case .hard: return "Hard" 
        case .good: return "Good"
        case .easy: return "Easy"
        }
    }
    
    var description: String {
        switch self {
        case .again: return "I didn't remember"
        case .hard: return "I barely remembered"
        case .good: return "I remembered with effort"
        case .easy: return "I remembered easily"
        }
    }
    
    // Mapping to SM-2 quality score (0-5)
    var sm2Quality: Int {
        switch self {
        case .again: return 1
        case .hard: return 2
        case .good: return 3
        case .easy: return 4
        }
    }
}

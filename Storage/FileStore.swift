//
//  FileStore.swift
//  MemIT
//
//  Created by MemIT on 04/01/2026.
//

import Foundation

class FileStore: Store {
    private let documentsDirectory: URL
    private let filename = "memit_decks.json"
    
    init() {
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private var fileURL: URL {
        return documentsDirectory.appendingPathComponent(filename)
    }
    
    func load() async throws -> [Deck] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }
        
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode([Deck].self, from: data)
    }
    
    func save(_ decks: [Deck]) async throws {
        let data = try JSONEncoder().encode(decks)
        try data.write(to: fileURL)
    }
}

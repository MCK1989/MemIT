//
//  CSVImporter.swift
//  MemIT
//
//  Created by Marco Cortellazzi on 05/01/26.
//

import Foundation

/// Service responsible for importing decks from CSV files
struct CSVImporter {
    
    // MARK: - Configuration
    
    static let maxFieldLength = 500
    static let maxRowCount = 10000
    
    // MARK: - Error Types
    
    enum ImportError: Error {
        case fileNotFound
        case invalidFormat
        case encodingError
        case parsingError(String)
        case fieldTooLong(field: String, line: Int, length: Int)
        case tooManyRows(count: Int)
    }
    
    // MARK: - Public API
    
    /// Creates a complete Deck from a CSV file
    /// - Parameters:
    ///   - url: The URL of the CSV file
    ///   - name: The name for the new deck
    /// - Returns: A Deck with all cards from the CSV file
    static func createDeck(from url: URL, named name: String) throws -> Deck {
        let cards = try importCards(from: url)
        
        return Deck(
            id: UUID(),
            name: name,
            description: "",
            cards: cards,
            createdAt: Date()
        )
    }
    
    /// Imports cards from a CSV file
    /// - Parameter url: The URL of the CSV file
    /// - Returns: An array of Card objects
    /// - Throws: ImportError if the file cannot be read or parsed
    static func importCards(from url: URL) throws -> [Card] {
        // Verify file exists
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw ImportError.fileNotFound
        }
        
        // Read file content
        let content: String
        do {
            content = try String(contentsOf: url, encoding: .utf8)
        } catch {
            throw ImportError.encodingError
        }
        
        // Parse CSV content
        let rows = try parseCSV(content)
        
        // Convert to Card objects
        return rows.map { row in
            Card(front: row.front, back: row.back)
        }
    }
    
    // MARK: - Private Parsing Logic
    
    private struct CSVRow {
        let front: String
        let back: String
        let lineNumber: Int
    }
    
    private static func parseCSV(_ content: String) throws -> [CSVRow] {
        guard !content.isEmpty else {
            throw ImportError.parsingError("Empty file")
        }
        
        var lines = content.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        guard !lines.isEmpty else {
            throw ImportError.parsingError("No valid lines found")
        }
        
        // Check if first line is a header (contains "front" or "back")
        let firstLine = lines[0].lowercased()
        let hasHeader = firstLine.contains("front") || firstLine.contains("back") || 
                       firstLine.contains("fronte") || firstLine.contains("retro")
        
        if hasHeader {
            lines.removeFirst()
        }
        
        // Check row count limit
        if lines.count > maxRowCount {
            throw ImportError.tooManyRows(count: lines.count)
        }
        
        var rows: [CSVRow] = []
        
        for (index, line) in lines.enumerated() {
            let lineNumber = index + (hasHeader ? 2 : 1)
            
            // Try to split by semicolon first, then comma
            var components: [String]
            if line.contains(";") {
                components = line.components(separatedBy: ";")
            } else if line.contains(",") {
                components = parseCSVLine(line)
            } else {
                throw ImportError.parsingError("Line \(lineNumber): No valid separator found (use ; or ,)")
            }
            
            // Validate format
            guard components.count >= 2 else {
                throw ImportError.invalidFormat
            }
            
            let front = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let back = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Validate fields are not empty
            guard !front.isEmpty && !back.isEmpty else {
                throw ImportError.parsingError("Line \(lineNumber): Empty fields found")
            }
            
            // Validate field length
            if front.count > maxFieldLength {
                throw ImportError.fieldTooLong(field: "front", line: lineNumber, length: front.count)
            }
            if back.count > maxFieldLength {
                throw ImportError.fieldTooLong(field: "back", line: lineNumber, length: back.count)
            }
            
            rows.append(CSVRow(front: front, back: back, lineNumber: lineNumber))
        }
        
        guard !rows.isEmpty else {
            throw ImportError.parsingError("No valid cards found")
        }
        
        return rows
    }
    
    /// Parse a CSV line respecting quoted fields
    private static func parseCSVLine(_ line: String) -> [String] {
        var fields: [String] = []
        var currentField = ""
        var insideQuotes = false
        
        for char in line {
            switch char {
            case "\"":
                insideQuotes.toggle()
            case ",":
                if insideQuotes {
                    currentField.append(char)
                } else {
                    fields.append(currentField)
                    currentField = ""
                }
            default:
                currentField.append(char)
            }
        }
        
        // Add the last field
        fields.append(currentField)
        
        return fields
    }
}

//
//  CSVExporter.swift
//  MemIT
//
//  Created by Marco Cortellazzi on 05/01/26.
//

import Foundation
import UniformTypeIdentifiers

/// Service responsible for exporting decks to CSV files
struct CSVExporter {
    
    // MARK: - Configuration
    
    enum ExportFormat {
        case semicolon  // front;back
        case comma      // front,back
        
        var separator: String {
            switch self {
            case .semicolon: return ";"
            case .comma: return ","
            }
        }
    }
    
    // MARK: - Error Types
    
    enum ExportError: Error, LocalizedError {
        case emptyDeck
        case encodingError
        case fileCreationFailed
        
        var errorDescription: String? {
            switch self {
            case .emptyDeck:
                return "Cannot export empty deck"
            case .encodingError:
                return "Failed to encode CSV content"
            case .fileCreationFailed:
                return "Failed to create export file"
            }
        }
    }
    
    // MARK: - Public API
    
    /// Export a deck to CSV format
    /// - Parameters:
    ///   - deck: The deck to export
    ///   - format: The CSV separator format (semicolon or comma)
    ///   - includeHeader: Whether to include a header row
    /// - Returns: CSV content as String
    static func exportDeck(
        _ deck: Deck,
        format: ExportFormat = .semicolon,
        includeHeader: Bool = true
    ) throws -> String {
        
        guard !deck.cards.isEmpty else {
            throw ExportError.emptyDeck
        }
        
        var csvContent = ""
        
        // Add header if requested
        if includeHeader {
            csvContent += "front\(format.separator)back\n"
        }
        
        // Add each card
        for card in deck.activeCards {
            let front = escapeCSVField(card.front, separator: format.separator)
            let back = escapeCSVField(card.back, separator: format.separator)
            csvContent += "\(front)\(format.separator)\(back)\n"
        }
        
        return csvContent
    }
    
    /// Export deck and return as Data for sharing
    /// - Parameters:
    ///   - deck: The deck to export
    ///   - format: The CSV separator format
    ///   - includeHeader: Whether to include a header row
    /// - Returns: CSV data ready for file export
    static func exportDeckAsData(
        _ deck: Deck,
        format: ExportFormat = .semicolon,
        includeHeader: Bool = true
    ) throws -> Data {
        
        let csvString = try exportDeck(deck, format: format, includeHeader: includeHeader)
        
        guard let data = csvString.data(using: .utf8) else {
            throw ExportError.encodingError
        }
        
        return data
    }
    
    /// Generate a filename for the exported deck
    /// - Parameter deck: The deck to export
    /// - Returns: A safe filename with .csv extension
    static func generateFilename(for deck: Deck) -> String {
        let sanitized = deck.name
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: "\\", with: "-")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        
        return "\(sanitized)_\(dateString).csv"
    }
    
    // MARK: - Private Helpers
    
    /// Escape a CSV field if it contains special characters
    private static func escapeCSVField(_ field: String, separator: String) -> String {
        // Check if field needs escaping
        let needsEscaping = field.contains(separator) || 
                           field.contains("\"") || 
                           field.contains("\n") ||
                           field.contains("\r")
        
        if needsEscaping {
            // Escape quotes by doubling them and wrap in quotes
            let escaped = field.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\""
        }
        
        return field
    }
}

// MARK: - SwiftUI Integration

import SwiftUI

/// A document type for CSV file export
struct CSVDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.commaSeparatedText] }
    
    var content: String
    
    init(content: String) {
        self.content = content
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents,
           let string = String(data: data, encoding: .utf8) {
            content = string
        } else {
            content = ""
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let data = content.data(using: .utf8) else {
            throw CSVExporter.ExportError.encodingError
        }
        return FileWrapper(regularFileWithContents: data)
    }
}

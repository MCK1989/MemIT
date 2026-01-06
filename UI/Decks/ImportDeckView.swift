//
//  ImportDeckView.swift
//  MemIT
//
//  Created by Marco Cortellazzi on 04/01/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct ImportDeckView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @State private var showingFilePicker = false
    @State private var importedDeck: Deck?
    @State private var errorMessage: String?
    @State private var isImporting = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let deck = importedDeck {
                    importPreview(deck: deck)
                } else {
                    importPrompt
                }
            }
            .padding()
            .navigationTitle(L(.importDeck, from:appState))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(L(.cancel, from:appState)) {
                        dismiss()
                    }
                }
                
                if importedDeck != nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(L(.importButton, from:appState)) {
                            finalizeImport()
                        }
                        .fontWeight(.semibold)
                    }
                }
            }
        }
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.commaSeparatedText, .plainText],
            allowsMultipleSelection: false
        ) { result in
            handleFileImport(result)
        }
    }
    
    private var importPrompt: some View {
        VStack(spacing: 24) {
            Image(systemName: "square.and.arrow.down")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            VStack(spacing: 12) {
                LocalizedText(key: .importCSVDeck)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                LocalizedText(key: .csvFormatDescription)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(L(.selectCSVFile, from: appState)) {
                showingFilePicker = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Esempio di formato
            VStack(alignment: .leading, spacing: 8) {
                Text(L(.expectedFormat, from:appState))
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("front;back")
                        .foregroundColor(.secondary)
                    Text("ciao;hello")
                    Text("grazie;thank you")
                    Text("per favore;please")
                }
                .font(.system(.caption, design: .monospaced))
                .padding()
                .background(.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
    
    private func importPreview(deck: Deck) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(L(.importSuccess, from: appState))
                        .font(.headline)
                    Text("\(deck.cards.count) " + L(.cardsFound, from: appState))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            TextField(L(.deckName, from:appState), text: Binding(
                get: { deck.name },
                set: { newName in
                    importedDeck = Deck(
                        id: deck.id,
                        name: newName,
                        description: deck.description,
                        cards: deck.cards,
                        createdAt: deck.createdAt
                    )
                }
            ))
            .textFieldStyle(.roundedBorder)
            
            Text(L(.cardPreview, from:appState))
                .font(.headline)
            
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(Array(deck.cards.prefix(10).enumerated()), id: \.element.id) { index, card in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(card.front)
                                    .font(.body)
                                Text(card.back)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    if deck.cards.count > 10 {
                        Text(L(.andOtherCards, from:appState) + " \(deck.cards.count - 10) " + L(.cards, from:appState))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
            }
            .frame(maxHeight: 300)
        }
    }
    
    private func handleFileImport(_ result: Result<[URL], Error>) {
        isImporting = true
        errorMessage = nil
        
        Task {
            do {
                guard let fileURL = try result.get().first else {
                    throw CSVImporter.ImportError.fileAccessDenied
                }
                
                // Access the file with security scope
                guard fileURL.startAccessingSecurityScopedResource() else {
                    throw CSVImporter.ImportError.fileAccessDenied
                }
                
                defer {
                    fileURL.stopAccessingSecurityScopedResource()
                }
                
                // Use CSVImporter to create the deck
                let deckName = fileURL.deletingPathExtension().lastPathComponent
                var deck = try CSVImporter.createDeck(from: fileURL, named: deckName)
                
                // Add localized description
                deck.description = L(.importedFromCSV, from: appState)
                
                await MainActor.run {
                    self.importedDeck = deck
                    self.isImporting = false
                }
                
            } catch {
                await MainActor.run {
                    self.errorMessage = self.localizeError(error)
                    self.isImporting = false
                }
            }
        }
    }
    
    private func finalizeImport() {
        guard let deck = importedDeck else { return }
        appState.decks.append(deck)
        dismiss()
    }
    
    private func localizeError(_ error: Error) -> String {
        // Handle CSVImporter errors
        if let csvError = error as? CSVImporter.ImportError {
            // Use the built-in errorDescription for fieldTooLong
            if case .fieldTooLong = csvError {
                return csvError.errorDescription ?? "Field too long"
            }
            
            switch csvError {
            case .fileNotFound, .fileAccessDenied:
                return L(.cannotAccessFile, from: appState)
            case .invalidFormat:
                return L(.useCorrectFormat, from: appState)
            case .encodingError:
                return L(.encodingError, from: appState)
            case .parsingError(let message):
                return L(.importError, from: appState) + ": " + message
            case .tooManyRows:
                return L(.tooManyRowsError, from: appState)
            default:
                return csvError.errorDescription ?? "Unknown error"
            }
        }
        
        return error.localizedDescription
    }
}

#Preview {
    ImportDeckView()
        .environmentObject(AppState())
}

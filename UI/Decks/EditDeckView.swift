//
//  EditDeckView.swift
//  MemIT
//
//  Created by Marco Cortellazzi on 04/01/26.
//

import SwiftUI

struct EditDeckView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    let deck: Deck
    @State private var deckName: String
    @State private var deckDescription: String
    
    init(deck: Deck) {
        self.deck = deck
        _deckName = State(initialValue: deck.name)
        _deckDescription = State(initialValue: deck.description)
    }
    
    private var isValid: Bool {
        !deckName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form(content: {
                Section(header: Text(L(.deckInformation, from: appState))) {
                    TextField(L(.deckName, from: appState), text: $deckName)
                    TextField(L(.deckOptionalDescritpion, from: appState), text: $deckDescription, axis: .vertical)
                        .lineLimit(3...6)
                }
            })
            .navigationTitle(L(.editDeck, from: appState))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(L(.cancel, from: appState)) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L(.saveButton, from: appState)) {
                        saveDeck()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValid)
                }
            }
        }
    }
    
    private func saveDeck() {
        if let deckIndex = appState.decks.firstIndex(where: { $0.id == deck.id }) {
            appState.decks[deckIndex].name = deckName.trimmingCharacters(in: .whitespacesAndNewlines)
            appState.decks[deckIndex].description = deckDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        dismiss()
    }
}

#Preview {
    EditDeckView(deck: PreviewData.sampleDecks[0])
        .environmentObject(AppState())
}

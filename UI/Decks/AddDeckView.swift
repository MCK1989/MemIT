//
//  AddDeckView.swift
//  MemIT
//
//  Created by Marco Cortellazzi on 04/01/26.
//

import SwiftUI

struct AddDeckView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @State private var deckName = ""
    @State private var deckDescription = ""
    
    private var isValid: Bool {
        !deckName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(L(.deckInformation, from:appState)) {
                    TextField(L(.deckName, from:appState), text: $deckName)
                    TextField(L(.deckOptionalDescritpion, from:appState), text: $deckDescription, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section {
                    Text(L(.deckMessage, from:appState))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle(L(.newDeck, from:appState))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(L(.cancel, from:appState)) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L(.create, from:appState)) {
                        createDeck()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValid)
                }
            }
        }
    }
    
    private func createDeck() {
        let newDeck = Deck(
            name: deckName.trimmingCharacters(in: .whitespacesAndNewlines),
            description: deckDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            cards: []
        )
        
        appState.decks.append(newDeck)
        dismiss()
    }
}

#Preview {
    AddDeckView()
        .environmentObject(AppState())
}

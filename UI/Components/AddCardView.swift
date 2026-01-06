//
//  AddCardView.swift
//  MemIT
//
//  Created by Marco Cortellazzi on 04/01/26.
//

import SwiftUI

struct AddCardView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    let deck: Deck
    @State private var front = ""
    @State private var back = ""
    
    private var isValid: Bool {
        !front.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !back.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(L(.cardFront, from: appState)) {
                    TextField(L(.questionOrTerm, from: appState), text: $front, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                Section(L(.cardBack, from: appState)) {
                    TextField(L(.answerOrDefinition, from: appState), text: $back, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                Section {
                    Text("\(L(.cardWillBeAdded, from: appState)) '\(deck.name)'")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle(L(.newCardTitle, from: appState))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(L(.cancel, from: appState)) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L(.add, from: appState)) {
                        addCard()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValid)
                }
            }
        }
    }
    
    private func addCard() {
        let newCard = Card(
            front: front.trimmingCharacters(in: .whitespacesAndNewlines),
            back: back.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        // Trova il deck nell'appState e aggiorna le sue carte
        if let deckIndex = appState.decks.firstIndex(where: { $0.id == deck.id }) {
            appState.decks[deckIndex].cards.append(newCard)
        }
        
        dismiss()
    }
}

#Preview {
    AddCardView(deck: PreviewData.sampleDecks[0])
        .environmentObject(AppState())
}

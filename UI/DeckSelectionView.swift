//
//  DeckSelectionView.swift
//  MemIT
//
//  Created by Marco Cortellazzi on 04/01/26.
//

import SwiftUI

struct DeckSelectionView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section(L(.selectDeckForStudy, from: appState)) {
                    ForEach(appState.decks) { deck in
                        DeckSelectionRow(
                            deck: deck, 
                            isSelected: appState.selectedDeckId == deck.id
                        ) {
                            appState.selectDeck(deck)
                            dismiss()
                        }
                    }
                }
                
                if appState.decks.isEmpty {
                    Section {
                        VStack(spacing: 12) {
                            Image(systemName: "rectangle.stack")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            
                            LocalizedText(key: .noDecksAvailable)
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            LocalizedText(key: .createOrImportDeck)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            NavigationLink("Gestisci Mazzi") {
                                DecksListView()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                }
            }
            .navigationTitle(L(.chooseDeck, from: appState))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L(.close, from: appState)) {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DeckSelectionRow: View {
    let deck: Deck
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Icona del mazzo
                Image(systemName: "rectangle.stack.fill")
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .blue)
                    .frame(width: 40, height: 40)
                    .background(isSelected ? .blue : .blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(deck.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 16) {
                        Label("\(deck.cards.count)", systemImage: "rectangle.on.rectangle")
                        
                        if deck.cards.filter({ $0.srs.isNew }).count > 0 {
                            Label("\(deck.cards.filter { $0.srs.isNew }.count)", systemImage: "plus.circle")
                                .foregroundColor(.green)
                        }
                        
                        if deck.cards.filter({ $0.srs.isDue }).count > 0 {
                            Label("\(deck.cards.filter { $0.srs.isDue }.count)", systemImage: "clock")
                                .foregroundColor(.orange)
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationStack {
        DeckSelectionView()
            .environmentObject(AppState())
    }
}

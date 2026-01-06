//
//  DecksListView.swift
//  MemIT
//
//  Created by Marco Cortellazzi on 04/01/26.
//

import SwiftUI

struct DecksListView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingImportSheet = false
    @State private var showingAddDeckSheet = false
    
    var body: some View {
        NavigationStack {
            Group {
                if appState.decks.isEmpty {
                    emptyState
                } else {
                    decksList
                }
            }
            .navigationTitle(L(.decks, from: appState))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showingAddDeckSheet = true
                        } label: {
                            Label(L(.createNewDeck, from: appState), systemImage: "plus")
                        }
                        
                        Button {
                            showingImportSheet = true
                        } label: {
                            Label(L(.importFromCSV, from: appState), systemImage: "square.and.arrow.down")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingImportSheet) {
            ImportDeckView()
        }
        .sheet(isPresented: $showingAddDeckSheet) {
            AddDeckView()
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "rectangle.stack")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                LocalizedText(key: .noDeck)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                LocalizedText(key: .createFirstDeck)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 12) {
                Button(L(.createNewDeck, from: appState)) {
                    showingAddDeckSheet = true
                }
                .buttonStyle(.borderedProminent)
                
                Button(L(.importFromCSV, from: appState)) {
                    showingImportSheet = true
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }
    
    private var decksList: some View {
        List {
            ForEach(appState.decks) { deck in
                DeckRowView(deck: deck)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
            .onDelete(perform: deleteDeck)
        }
        .listStyle(.plain)
    }
    
    private func deleteDeck(offsets: IndexSet) {
        for index in offsets {
            let deckId = appState.decks[index].id
            // Se il deck cancellato è quello selezionato, deselezionalo
            if appState.selectedDeckId == deckId {
                appState.selectedDeckId = nil
            }
        }
        appState.decks.remove(atOffsets: offsets)
    }
}

struct DeckRowView: View {
    @EnvironmentObject var appState: AppState
    let deck: Deck
    
    private var isSelected: Bool {
        appState.selectedDeckId == deck.id
    }
    
    var body: some View {
        NavigationLink {
            DeckDetailView(deck: deck)
        } label: {
            HStack(spacing: 12) {
                // Deck icon and selection indicator
                ZStack {
                    Circle()
                        .fill(isSelected ? .blue : .secondary.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: isSelected ? "checkmark" : "rectangle.stack.fill")
                        .font(.headline)
                        .foregroundStyle(isSelected ? .white : .secondary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(deck.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if isSelected {
                            Text(L(.active, from: appState))
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.blue)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                        
                        Spacer()
                    }
                    
                    HStack {
                        Label("\(deck.cards.count) " + L(.cards, from: appState), systemImage: "rectangle.stack")
                        
                        if !deck.description.isEmpty {
                            Label(L(.withDescription, from:appState), systemImage: "text.alignleft")
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
        }
        .contextMenu {
            Button(isSelected ? L(.deselect, from: appState) : L(.selectForStudy, from: appState)) {
                if isSelected {
                    appState.selectedDeckId = nil
                } else {
                    appState.selectDeck(deck)
                }
            }
            
            Button("Modifica", systemImage: "pencil") {
                // TODO: Implement edit
            }
            
            Divider()
            
            Button("Elimina", systemImage: "trash", role: .destructive) {
                // TODO: Implement delete with confirmation
            }
        }
    }
}

#Preview {
    DecksListView()
        .environmentObject(AppState())
}

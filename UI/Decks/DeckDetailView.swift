//
//  DeckDetailView.swift
//  MemIT
//
//  Created by Marco Cortellazzi on 04/01/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct DeckDetailView: View {
    @EnvironmentObject var appState: AppState
    let deck: Deck
    @State private var showingAddCardSheet = false
    @State private var showingEditDeckSheet = false
    @State private var showingExportSheet = false
    @State private var exportDocument: CSVDocument?
    @State private var exportError: String?
    @State private var showingExportError = false
    @State private var searchText = ""
    
    private var filteredCards: [Card] {
        if searchText.isEmpty {
            return deck.cards
        } else {
            return deck.cards.filter { card in
                card.front.localizedCaseInsensitiveContains(searchText) ||
                card.back.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                deckInfoSection
                
                statsSection
                
                cardsSection
            }
            .searchable(text: $searchText, prompt: L(.search, from: appState))
            .navigationTitle(deck.name)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(L(.add, from: appState), systemImage: "plus") {
                            showingAddCardSheet = true
                        }
                        
                        Button(L(.edit, from: appState), systemImage: "pencil") {
                            showingEditDeckSheet = true
                        }
                        
                        Divider()
                        
                        Button(L(.exportCSV, from: appState), systemImage: "square.and.arrow.up") {
                            exportDeck()
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddCardSheet) {
            AddCardView(deck: deck)
        }
        .sheet(isPresented: $showingEditDeckSheet) {
            EditDeckView(deck: deck)
        }
        .fileExporter(
            isPresented: $showingExportSheet,
            document: exportDocument,
            contentType: .commaSeparatedText,
            defaultFilename: CSVExporter.generateFilename(for: deck)
        ) { result in
            handleExportResult(result)
        }
        .alert(L(.exportError, from: appState), isPresented: $showingExportError) {
            Button("OK", role: .cancel) { }
        } message: {
            if let error = exportError {
                Text(error)
            }
        }
    }
    
    // MARK: - Export Methods
    
    private func exportDeck() {
        do {
            let csvContent = try CSVExporter.exportDeck(deck, format: .semicolon, includeHeader: true)
            exportDocument = CSVDocument(content: csvContent)
            showingExportSheet = true
        } catch {
            exportError = error.localizedDescription
            showingExportError = true
        }
    }
    
    private func handleExportResult(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            print("✅ Deck exported successfully to: \(url)")
        case .failure(let error):
            exportError = error.localizedDescription
            showingExportError = true
        }
    }
    
    private var deckInfoSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "rectangle.stack.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(deck.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("\(deck.cards.count) \(L(.cards, from: appState))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                let isSelected = appState.selectedDeckId == deck.id
                Button(isSelected ? L(.deselect, from: appState) : L(.useForStudy, from: appState)) {
                    if isSelected {
                        appState.selectedDeckId = nil
                    } else {
                        appState.selectDeck(deck)
                    }
                }
                .buttonStyle(.bordered)
                .foregroundColor(isSelected ? .red : .blue)
            }
            .padding(.vertical, 8)
        }
    }
    
    private var statsSection: some View {
        Section(L(.statistics, from: appState)) {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatItem(
                    title: L(.newCard, from: appState),
                    count: deck.cards.filter { $0.srs.isNew }.count,
                    color: .blue
                )
                
                StatItem(
                    title: L(.toReview, from: appState),
                    count: deck.cards.filter { $0.srs.isDue }.count,
                    color: .orange
                )
                
                StatItem(
                    title: L(.cardOK, from: appState),
                    count: deck.cards.filter { !$0.srs.isNew && !$0.srs.isDue }.count,
                    color: .green
                )
            }
            .padding(.vertical, 8)
        }
    }
    
    private var cardsSection: some View {
        Section(L(.cards, from: appState) + " (\(filteredCards.count))") {
            if filteredCards.isEmpty {
                if searchText.isEmpty {
                    LocalizedText(key: .noCardsInDeck)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    Text("\(L(.noCardsFound, from: appState)) '\(searchText)'")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
            } else {
                ForEach(filteredCards) { card in
                    CardRowView(card: card)
                }
                .onDelete { indexSet in
                    // TODO: Implement delete functionality
                }
            }
        }
    }
}

struct StatItem: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text("\(count)")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct CardRowView: View {
    let card: Card
    @State private var showingCardDetail = false
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Button {
            showingCardDetail = true
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(card.front)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .lineLimit(2)
                        
                        Text(card.back)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    statusBadge
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingCardDetail) {
            CardDetailView(card: card)
        }
    }
    
    private var statusBadge: some View {
        Group {
            if card.srs.isNew {
                Text(L(.newCard, from: appState))
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            } else if card.srs.isDue {
                Text(L(.toReview, from: appState))
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.orange)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            } else {
                Text(L(.cardOK, from: appState))
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.green)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
        }
    }
}

#Preview {
    DeckDetailView(deck: PreviewData.sampleDecks[0])
        .environmentObject(AppState())
}

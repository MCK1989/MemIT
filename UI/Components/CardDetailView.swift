//
//  CardDetailView.swift
//  MemIT
//
//  Created by Marco Cortellazzi on 04/01/26.
//

import SwiftUI

struct CardDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    let card: Card
    @State private var showingEditSheet = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Card preview
                VStack(spacing: 16) {
                    cardSide(title: L(.front, from: appState), content: card.front, color: .blue)
                    cardSide(title: L(.back, from: appState), content: card.back, color: .green)
                }
                
                // Card stats
                cardStats
                
                Spacer()
            }
            .padding()
            .navigationTitle(L(.cardDetailTitle, from: appState))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(L(.close, from: appState)) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L(.edit, from: appState)) {
                        showingEditSheet = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditCardView(card: card)
        }
    }
    
    private func cardSide(title: String, content: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(color)
                Spacer()
            }
            
            Text(content)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var cardStats: some View {
        VStack(alignment: .leading, spacing: 12) {
            LocalizedText(key: .statistics)
                .font(.headline)
            
            VStack(spacing: 8) {
                HStack {
                    Text(L(.status, from: appState))
                    Spacer()
                    Text(card.srs.isNew ? L(.newCard, from: appState) : (card.srs.isDue ? L(.toReview, from: appState) : L(.cardOK, from: appState)))
                        .foregroundStyle(card.srs.isNew ? .blue : (card.srs.isDue ? .orange : .green))
                }
                
                if let nextReview = card.srs.nextReview {
                    HStack {
                        Text(L(.nextReview, from: appState))
                        Spacer()
                        Text(nextReview, style: .date)
                    }
                }
                
                HStack {
                    Text(L(.createdOn, from: appState))
                    Spacer()
                    Text(card.createdAt, style: .date)
                        .foregroundColor(.secondary)
                }
                
                if card.updatedAt != card.createdAt {
                    HStack {
                        Text(L(.lastModified, from: appState))
                        Spacer()
                        Text(card.updatedAt, style: .relative)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .font(.subheadline)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct EditCardView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    let card: Card
    @State private var front: String
    @State private var back: String
    
    init(card: Card) {
        self.card = card
        _front = State(initialValue: card.front)
        _back = State(initialValue: card.back)
    }
    
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
            }
            .navigationTitle(L(.editCardTitle, from: appState))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(L(.cancel, from: appState)) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L(.save, from: appState)) {
                        saveCard()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValid)
                }
            }
        }
    }
    
    private func saveCard() {
        // TODO: Implementare il salvataggio della carta modificata
        // Questo richiederà di passare una reference al deck o all'appState
        dismiss()
    }
}

#Preview {
    CardDetailView(card: PreviewData.sampleCards[0])
}

//
//  HomeView.swift
//  MemIT
//
//  Created by Marco Cortellazzi on 04/01/26.
//

import SwiftUI
import Combine

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    welcomeSection
                    
                    dailyStatsSection
                    
                    selectedDeckSection
                    
                    quickActionsSection
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .navigationTitle("MemIT")
            .onAppear {
                // Forza il refresh dell'interfaccia quando appare la view
                // Questo assicura che i conteggi siano aggiornati
                objectWillChange.send()
            }
        }
    }
    
    // ObservableObject per forzare il refresh
    private var objectWillChange: ObservableObjectPublisher {
        appState.objectWillChange
    }
    
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                LocalizedText(key: appState.greetingKey())
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            
            LocalizedText(key: .readyToStudy)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var dailyStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            LocalizedText(key: .todayStats)
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                // Carte nuove studiate oggi / Limite giornaliero
                StatCard(
                    title: L(.newCards, from: appState),
                    value: "\(appState.globalStats.todayNewCards)/\(appState.settings.dailyNewCards)",
                    icon: "plus.circle.fill",
                    color: .green
                )
                
                // Totale carte studiate oggi / Limite giornaliero
                StatCard(
                    title: L(.totalToStudy, from: appState),
                    value: "\(appState.globalStats.todayCardsStudied)/\(appState.settings.maxReviewCards)",
                    icon: "book.circle.fill",
                    color: .blue
                )
            }
        }
    }
    
    private var selectedDeckSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            LocalizedText(key: .currentDeck)
                .font(.headline)
            
            NavigationLink {
                DeckSelectionView()
            } label: {
                if let selectedDeck = appState.selectedDeck {
                    DeckInfoCard(deck: selectedDeck, showChevron: true)
                } else {
                    EmptyDeckCard(showChevron: true)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            LocalizedText(key: .quickActions)
                .font(.headline)
            
            VStack(spacing: 12) {
                NavigationLink {
                    if appState.selectedDeck != nil {
                        StudyView()
                    } else {
                        SelectDeckPromptView()
                    }
                } label: {
                    ActionButton(
                        title: L(.startStudying, from: appState),
                        subtitle: appState.selectedDeck?.name ?? L(.noDeckSelected, from: appState),
                        icon: "play.fill",
                        color: .blue,
                        isEnabled: appState.selectedDeck != nil
                    )
                }
                .disabled(appState.selectedDeck == nil)
                
                NavigationLink {
                    DecksListView()
                } label: {
                    ActionButton(
                        title: L(.manageDeck, from: appState),
                        subtitle: "\(appState.decks.count) \(L(.decksAvailable, from: appState))",
                        icon: "rectangle.stack.fill",
                        color: .orange
                    )
                }
                
                NavigationLink {
                    StatsView()
                } label: {
                    ActionButton(
                        title: "Statistics",
                        subtitle: "View your progress",
                        icon: "chart.bar.fill",
                        color: .purple
                    )
                }
            }
        }
    }
}

struct DeckInfoCard: View {
    let deck: Deck
    var showChevron: Bool = false
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "rectangle.stack.fill")
                .font(.title2)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(deck.name)
                    .font(.headline)
                Text("\(deck.cards.count) \(L(.cards, from: appState))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct EmptyDeckCard: View {
    var showChevron: Bool = false
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "rectangle.stack")
                .font(.title2)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 4) {
                LocalizedText(key: .noDeckSelected)
                    .font(.headline)
                    .foregroundColor(.secondary)
                LocalizedText(key: .tapToSelect)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct ActionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    var isEnabled: Bool = true
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isEnabled ? color : .secondary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(isEnabled ? .primary : .secondary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState())
}

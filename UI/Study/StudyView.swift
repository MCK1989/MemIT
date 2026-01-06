//
//  StudyView.swift
//  MemIT
//
//  Created by Marco Cortellazzi on 04/01/26.
//

import SwiftUI

struct StudyView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel: StudyViewModel
    @State private var studyFromEnglish = false
    
    init() {
        // Initialize with a temporary AppState - will be replaced in onAppear
        _viewModel = StateObject(wrappedValue: StudyViewModel(appState: AppState()))
    }

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isSessionActive, let card = viewModel.currentCard {
                activeSessionView(card: card)
            } else {
                emptyOrCompletedView
            }
        }
        .padding()
        .navigationTitle(L(.study, from: appState))
        .onAppear {
            // Update ViewModel with correct AppState
            if !viewModel.isSessionActive {
                initializeViewModel()
                studyFromEnglish = appState.settings.studyFromEnglish
                viewModel.startSession()
            }
        }
        .onDisappear {
            // Salva le statistiche quando l'utente esce dalla vista
            viewModel.saveStatsIfNeeded()
        }
    }
    
    private func initializeViewModel() {
        // Workaround: manually inject the correct AppState
        // A better approach would be to pass it via init parameter
        viewModel.updateAppState(appState)
    }
    
    private func activeSessionView(card: Card) -> some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 20)
            
            header
            
            Spacer()
            
            VStack(spacing: 20) {
                cardView(card: card)
                    .id(card.id) // Force re-render on card change
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                
                VStack(spacing: 16) {
                    if viewModel.showBack {
                        ratingButtons
                    } else {
                        flipPrompt
                    }
                }
                .frame(height: 280)
                .animation(.easeInOut(duration: 0.3), value: viewModel.showBack)
            }
            
            Spacer()
        }
    }
    
    private var emptyOrCompletedView: some View {
        VStack(spacing: 20) {
            if hasCardsAvailable {
                // Sessione completata con successo
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text("Session completed!")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Great job! You've reviewed all cards.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 12) {
                    Button("Start New Session") {
                        initializeViewModel()
                        studyFromEnglish = appState.settings.studyFromEnglish
                        viewModel.startSession()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    NavigationLink(destination: StatsView(sessionStats: viewModel.todayStats)) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                            Text("View Session Stats")
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.top)
            } else {
                // Nessuna carta disponibile
                Image(systemName: "tray")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
                
                Text("No cards to study")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("You've completed all reviews for today! Come back later or add new cards.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                if viewModel.todayStats.totalStudied > 0 {
                    NavigationLink(destination: StatsView(sessionStats: viewModel.todayStats)) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                            Text("View Session Stats")
                        }
                    }
                    .buttonStyle(.bordered)
                    .padding(.top)
                }
            }
        }
        .padding()
    }
    
    private var hasCardsAvailable: Bool {
        guard let deck = appState.selectedDeck else { return false }
        let dueCardsCount = deck.dueCount()
        let availableNewCards = max(0, appState.settings.dailyNewCards - viewModel.todayStats.newCardsStudied)
        let newCardsCount = min(deck.newCount, availableNewCards)
        return (dueCardsCount + newCardsCount) > 0
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                if let deck = appState.selectedDeck {
                    Text(deck.name)
                        .font(.headline)
                    Text("\(L(.session, from: appState)) - \(viewModel.totalCardsInSession - viewModel.studyQueue.count) \(L(.of, from: appState).lowercased()) \(viewModel.totalCardsInSession) \(L(.cards, from: appState))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    LocalizedText(key: .session)
                        .font(.headline)
                }
            }
            
            Spacer()
            
            // Stats indicator
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(viewModel.todayStats.totalStudied)")
                    .font(.title3)
                    .fontWeight(.bold)
                Text("studied")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }

    private func cardView(card: Card) -> some View {
        Button {
            viewModel.flipCard()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.thinMaterial)
                    .frame(height: 300)
                    .shadow(radius: 2)

                VStack(spacing: 12) {
                    HStack {
                        Spacer()
                        Text(determineCardSide())
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(viewModel.showBack ? .green : .blue)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                    
                    Spacer()

                    Text(getCardContent(card: card))
                        .font(.title2)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .id("\(card.id)-\(viewModel.showBack)") // Force re-render on flip
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.95).combined(with: .opacity),
                            removal: .scale(scale: 1.05).combined(with: .opacity)
                        ))
                    
                    Spacer()
                }
                .padding()
            }
        }
        .buttonStyle(.plain)
    }
    
    private func determineCardSide() -> String {
        if studyFromEnglish {
            return viewModel.showBack ? L(.italian, from: appState) : L(.english, from: appState)
        } else {
            return viewModel.showBack ? L(.back, from: appState) : L(.front, from: appState)
        }
    }
    
    private func getCardContent(card: Card) -> String {
        if studyFromEnglish {
            return viewModel.showBack ? card.front : card.back
        } else {
            return viewModel.showBack ? card.back : card.front
        }
    }
    
    private var flipPrompt: some View {
        VStack(spacing: 12) {
            Image(systemName: "hand.tap")
                .font(.title2)
                .foregroundColor(.secondary)
            
            LocalizedText(key: .tapToSeeAnswer)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }

    private var ratingButtons: some View {
        VStack(spacing: 16) {
            LocalizedText(key: .howWasIt)
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    rateButton(.again, color: .red)
                    rateButton(.hard, color: .orange)
                }
                
                HStack(spacing: 12) {
                    rateButton(.good, color: .green)
                    rateButton(.easy, color: .blue)
                }
            }
        }
    }

    private func rateButton(_ rating: Rating, color: Color) -> some View {
        Button {
            withAnimation {
                viewModel.rateCard(rating)
            }
        } label: {
            VStack(spacing: 6) {
                Text(L(rating.localizationKey, from: appState))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
                
                Text(localizedDescription(for: rating))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(.thinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func localizedDescription(for rating: Rating) -> String {
        switch rating {
        case .again: return L(.dontKnow, from: appState)
        case .hard: return L(.hardToRemember, from: appState)
        case .good: return L(.rememberedWell, from: appState)
        case .easy: return L(.tooEasy, from: appState)
        }
    }
}

#Preview {
    NavigationStack {
        StudyView()
            .environmentObject(AppState())
    }
}


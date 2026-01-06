import SwiftUI

struct StudyView: View {
    @EnvironmentObject var appState: AppState
    @State private var card = PreviewData.sampleCard
    @State private var showBack = false
    @State pri    pri    private func rate(_ rating: Rating) {
        // Per ora: demo UI. Dopo colleghiamo Scheduler.apply(...)
        showBack = false

        // Incrementa il contatore e passa alla carta successiva
        currentCardIndex = (currentCardIndex + 1) % studyCards.count
        if !studyCards.isEmpty {
            card = studyCards[currentCardIndex]
        }
    }nc rate(_ rating: Rating) {
        // Per ora: demo UI. Dopo colleghiamo Scheduler.apply(...)
        showBack = false

        // Incrementa il contatore e passa alla carta successiva
        currentCardIndex = (currentCardIndex + 1) % studyCards.count
        card = studyCards[currentCardIndex]
    }r currentCardIndex = 0
    @State private var studyFromEnglish = false // Nuova opzione
    
    private var studyCards: [Card] {
        appState.selectedDeck?.cards ?? PreviewData.sampleCards
    }

    var body: some View {
        VStack(spacing: 0) { // Rimosso spacing per controllo preciso
            header
            
            Spacer()
            
            // Container con altezza fissa per la carta e i controlli
            VStack(spacing: 20) {
                cardView
                
                // Area fissa per i controlli (280pt di altezza)
                VStack(spacing: 16) {
                    if showBack {
                        ratingButtons
                    } else {
                        flipPrompt
                    }
                }
                .frame(height: 280) // Altezza fissa per evitare spostamenti
                .animation(.easeInOut(duration: 0.3), value: showBack)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Studio")
        .onAppear {
            // Carica le impostazioni di studio
            studyFromEnglish = appState.settings.studyFromEnglish
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                if let deck = appState.selectedDeck {
                    Text(deck.name)
                        .font(.headline)
                    Text("\(L(.cardNumber, from: appState)) \(currentCardIndex + 1) \(L(.of, from: appState)) \(studyCards.count)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    LocalizedText(key: .session)
                        .font(.headline)
                    LocalizedText(key: .tapToFlip)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
    }

    private var cardView: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.6)) { 
                showBack.toggle() 
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.thinMaterial)
                    .frame(height: 300) // Altezza fissa
                    .shadow(radius: 2)

                VStack(spacing: 12) {
                    // Indicatore lato
                    HStack {
                        Spacer()
                        Text(determineCardSide())
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(showBack ? .green : .blue)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                    
                    Spacer()

                    Text(getCardContent())
                        .font(.title2)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Spacer()
                }
                .padding()
            }
            .rotation3DEffect(
                .degrees(showBack ? 180 : 0),
                axis: (x: 0, y: 1, z: 0)
            )
            .scaleEffect(showBack ? CGSize(width: -1, height: 1) : CGSize(width: 1, height: 1))
        }
        .buttonStyle(.plain)
    }
    
    private func determineCardSide() -> String {
        if studyFromEnglish {
            return showBack ? "ITALIANO" : "INGLESE"
        } else {
            return showBack ? "RETRO" : "FRONTE"
        }
    }
    
    private func getCardContent() -> String {
        if studyFromEnglish {
            return showBack ? card.front : card.back
        } else {
            return showBack ? card.back : card.front
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
            LocalizedText(key: .howHardWasCard)
                .font(.headline)
                .multilineTextAlignment(.center)

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
            rate(rating)
        } label: {
            VStack(spacing: 6) {
                Text(rating.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                Text(localizedDescription(for: rating))
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(color.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func localizedDescription(for rating: Rating) -> String {
        switch rating {
        case .again: return "Non la sapevo"
        case .hard: return "Difficile da ricordare"
        case .good: return "L'ho ricordata bene"
        case .easy: return "Troppo facile!"
        }
    }

    private func rate(_ rating: Rating) {
        // Per ora: demo UI. Dopo colleghiamo Scheduler.apply(...)
        showBack = false

        // Finta “carta successiva”
        card = PreviewData.nextCard(after: card, rating: rating)
    }
}

#Preview {
    NavigationStack {
        StudyView()
            .environmentObject(AppState())
    }
}

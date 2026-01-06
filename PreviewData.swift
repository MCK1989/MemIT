//
//  PreviewData.swift
//  MemIT
//
//  Created by Marco Cortellazzi on 04/01/26.
//

import Foundation

enum PreviewData {
    // MARK: - Sample Cards
    static let sampleCards: [Card] = [
        Card(front: "Ciao", back: "Hello"),
        Card(front: "Grazie", back: "Thank you"),
        Card(front: "Per favore", back: "Please"),
        Card(front: "Scusa", back: "Sorry"),
        Card(front: "Bene", back: "Good"),
        Card(front: "Male", back: "Bad"),
        Card(front: "Sì", back: "Yes"),
        Card(front: "No", back: "No"),
        Card(front: "Forse", back: "Maybe"),
        Card(front: "Sempre", back: "Always"),
        Card(front: "Mai", back: "Never"),
        Card(front: "Oggi", back: "Today"),
        Card(front: "Ieri", back: "Yesterday"),
        Card(front: "Domani", back: "Tomorrow"),
        Card(front: "Casa", back: "House"),
        Card(front: "Macchina", back: "Car"),
        Card(front: "Libro", back: "Book"),
        Card(front: "Telefono", back: "Phone"),
        Card(front: "Computer", back: "Computer"),
        Card(front: "Acqua", back: "Water")
    ]
    
    static var sampleCard: Card { sampleCards[0] }
    
    static func nextCard(after current: Card, rating: Rating) -> Card {
        // Demo: gira in loop
        guard let idx = sampleCards.firstIndex(of: current) else { return sampleCards[0] }
        let next = sampleCards[(idx + 1) % sampleCards.count]
        return next
    }
    
    // MARK: - Sample Decks
    static let sampleDecks: [Deck] = [
        Deck(
            name: "Italiano - Inglese Base",
            description: "Parole di base per iniziare a imparare l'inglese",
            cards: Array(sampleCards[0...9])
        ),
        Deck(
            name: "Vocabolario Casa",
            description: "Parole utili per descrivere la casa e gli oggetti domestici",
            cards: Array(sampleCards[10...14])
        ),
        Deck(
            name: "Tecnologia",
            description: "Termini tecnologici di uso comune",
            cards: Array(sampleCards[15...19])
        ),
        Deck(
            name: "Mazzo Vuoto",
            description: "Un mazzo senza carte per testare l'interfaccia",
            cards: []
        )
    ]
    
    // MARK: - Sample German Deck (for CSV import simulation)
    static let germanA1Cards: [Card] = [
        Card(front: "der Hund", back: "il cane"),
        Card(front: "die Katze", back: "il gatto"),
        Card(front: "das Haus", back: "la casa"),
        Card(front: "der Mann", back: "l'uomo"),
        Card(front: "die Frau", back: "la donna"),
        Card(front: "das Kind", back: "il bambino"),
        Card(front: "ich bin", back: "io sono"),
        Card(front: "du bist", back: "tu sei"),
        Card(front: "er/sie ist", back: "lui/lei è"),
        Card(front: "wir sind", back: "noi siamo"),
        Card(front: "ihr seid", back: "voi siete"),
        Card(front: "sie sind", back: "loro sono"),
        Card(front: "haben", back: "avere"),
        Card(front: "sein", back: "essere"),
        Card(front: "gehen", back: "andare"),
        Card(front: "kommen", back: "venire"),
        Card(front: "machen", back: "fare"),
        Card(front: "sagen", back: "dire"),
        Card(front: "sehen", back: "vedere"),
        Card(front: "wissen", back: "sapere")
    ]
    
    static let germanA1Deck = Deck(
        name: "Tedesco A1 - Unistrapg",
        description: "Vocabolario di base tedesco per principianti",
        cards: germanA1Cards
    )
}

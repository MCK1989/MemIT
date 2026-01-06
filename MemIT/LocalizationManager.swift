//
//  LocalizationManager.swift
//  MemIT
//
//  Created by Marco Cortellazzi on 04/01/26.
//

import SwiftUI
import Foundation
import Combine

class LocalizationManager: ObservableObject {
    @Published var currentLanguage: AppLanguage = .italian
    
    enum AppLanguage: String, CaseIterable {
        case italian = "it"
        case english = "en"
        
        var displayName: String {
            switch self {
            case .italian: return "Italiano"
            case .english: return "English"
            }
        }
        
        var flag: String {
            switch self {
            case .italian: return "🇮🇹"
            case .english: return "🇬🇧"
            }
        }
    }
    
    init() {
        // Imposta prima la lingua del sistema
        currentLanguage = getSystemLanguageWithFallback()
        // Poi carica quella salvata (se esiste) che sovrascrive quella del sistema
        loadSavedLanguage()
    }
    
    func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
        saveLanguage()
    }
    
    private func loadSavedLanguage() {
        // Se l'utente ha già scelto una lingua manualmente, usala
        if let savedLang = UserDefaults.standard.string(forKey: "AppLanguage"),
           let language = AppLanguage(rawValue: savedLang) {
            currentLanguage = language
            print("📱 Loaded saved language: \(language.displayName)")
        } else {
            // Altrimenti usa quella del sistema (già impostata in init)
            print("📱 Using system language: \(currentLanguage.displayName)")
        }
    }
    
    private func getSystemLanguageWithFallback() -> AppLanguage {
        // Prova prima con preferredLanguages che è più affidabile
        let preferredLanguage = Locale.preferredLanguages.first ?? "en"
        let languageCode = String(preferredLanguage.prefix(2)) // Prendi solo i primi 2 caratteri (es: "it" da "it-IT")
        
        print("📱 System preferred language: \(preferredLanguage) -> code: \(languageCode)")
        
        switch languageCode {
        case "it":
            return .italian
        case "en":
            return .english
        default:
            print("⚠️ Language \(languageCode) not supported, falling back to English")
            return .english // Fallback su inglese per tutte le altre lingue
        }
    }
    
    private func saveLanguage() {
        UserDefaults.standard.set(currentLanguage.rawValue, forKey: "AppLanguage")
    }
}

// MARK: - Testi localizzati
extension LocalizationManager {
    func text(_ key: LocalizationKey) -> String {
        switch currentLanguage {
        case .italian:
            return key.italian
        case .english:
            return key.english
        }
    }
}

enum LocalizationKey {
    // Navigation
    case home, decks, study, settings
    
    // Home Screen
    case goodMorning, goodAfternoon, goodEvening, readyToStudy, todayStats, newCards, reviews, totalToStudy, currentDeck, noDeckSelected, tapToSelect, quickActions, startStudying, manageDeck, decksAvailable
    case goToDecksToSelect, cards
    
    // Study Screen
    case session, tapToFlip, howWasIt, front, back, italian, english, again, hard, good, easy
    case dontKnow, hardToRemember, rememberedWell, tooEasy, cardNumber, tapToSeeAnswer
    case howHardWasCard, of
    
    // Settings Screen
    case studySettings, dailyNewCards, dailyNewCardsDesc, maxReviews, maxReviewsDesc, studyFromEnglish, startFromEnglish, notifications, studyReminder, studyReminderDesc, language, selectLanguage, appLanguage, changeInterfaceLanguage, reminderTime, about, version, srsAlgorithm, srsDescription, sourceCode, viewOnGithub
    case notificationsDisabled, notificationsDisabledDesc, openSettings, studyReminderTitle, studyReminderBody
    
    // Import & Deck Management
    case importDeck, selectCSVFile, fileFormat, importSuccess, cardsFound, deckName, preview, importButton, cancel
    case importCSVDeck, csvFormatDescription, csvExample, andOtherCards
    case noDeck, createFirstDeck, createNewDeck, importFromCSV
    case active, deselect, selectForStudy, useForStudy
    case noCardsInDeck, noCardsFound, newCard, toReview, cardOK, withDescription
    case cannotAccessFile, fileIsEmpty, importError, importedFromCSV, expectedFormat, cardPreview, emptyFieldsAtLine
    case invalidFormatAtLine, useCorrectFormat
    case fieldTooLongError, tooManyRowsError, encodingError
    
    // Add/Edit Cards
    case cardFront, cardBack, questionOrTerm, answerOrDefinition, cardWillBeAdded
    case afterCreatingDeck, statistics, status, nextReview, createdOn, lastModified
    case saveButton, editDeck, newCardTitle, cardDetailTitle, close, editCardTitle, save
    
    // Add/Edit Decks
    case deckInformation, deckOptionalDescritpion, deckMessage, newDeck, create
    
    // Deck Selection
    case chooseDeck, selectDeckForStudy, noDecksAvailable, createOrImportDeck
    
    // Common actions
    case add, edit, search
    
    // Export
    case exportCSV, exportDeck, exportSuccess, exportError
    
    var italian: String {
        switch self {
        // Navigation
        case .home: return "Home"
        case .decks: return "Mazzi"
        case .study: return "Studio"
        case .settings: return "Impostazioni"
            
        // Home Screen
        case .goodMorning: return "Buongiorno!"
        case .goodAfternoon: return "Buon pomeriggio!"
        case .goodEvening: return "Buonasera!"
        case .readyToStudy: return "Pronti per una nuova sessione di studio?"
        case .todayStats: return "Statistiche di oggi"
        case .newCards: return "Nuove carte"
        case .reviews: return "Ripassi"
        case .totalToStudy: return "Totale da studiare"
        case .currentDeck: return "Mazzo corrente"
        case .noDeckSelected: return "Nessun mazzo selezionato"
        case .tapToSelect: return "Tocca per selezionarne uno"
        case .quickActions: return "Azioni rapide"
        case .startStudying: return "Inizia a studiare"
        case .manageDeck: return "Gestisci mazzi"
        case .decksAvailable: return "mazzi disponibili"
        case .goToDecksToSelect: return "Vai nella sezione Mazzi per selezionare un mazzo da studiare"
        case .cards: return "carte"
            
        // Study Screen
        case .session: return "Sessione"
        case .tapToFlip: return "Tocca la carta per girarla"
        case .howWasIt: return "Come è andata?"
        case .front: return "FRONTE"
        case .back: return "RETRO"
        case .italian: return "ITALIANO"
        case .english: return "INGLESE"
        case .again: return "Di nuovo"
        case .hard: return "Difficile"
        case .good: return "Bene"
        case .easy: return "Facile"
        case .dontKnow: return "Non la sapevo"
        case .hardToRemember: return "Difficile da ricordare"
        case .rememberedWell: return "L'ho ricordata bene"
        case .tooEasy: return "Troppo facile!"
        case .cardNumber: return "Carta"
        case .tapToSeeAnswer: return "Tocca la carta per vedere la risposta"
        case .howHardWasCard: return "Quanto è stata facile questa carta?"
        case .of: return "di"
            
        // Settings Screen
        case .studySettings: return "Impostazioni Studio"
        case .dailyNewCards: return "Nuove carte al giorno"
        case .dailyNewCardsDesc: return "Numero massimo di nuove carte da studiare ogni giorno"
        case .maxReviews: return "Carte totali da studiare"
        case .maxReviewsDesc: return "Numero massimo di carte da studiare ogni giorno"
        case .studyFromEnglish: return "Studia a partire dall'inglese"
        case .startFromEnglish: return "Inizia dal lato inglese delle carte"
        case .notifications: return "Notifiche"
        case .studyReminder: return "Promemoria studio"
        case .studyReminderDesc: return "Ricevi notifiche per ricordarti di studiare"
        case .language: return "Lingua"
        case .selectLanguage: return "Seleziona lingua dell'app"
        case .appLanguage: return "Lingua dell'app"
        case .changeInterfaceLanguage: return "Cambia la lingua dell'interfaccia"
        case .reminderTime: return "Orario promemoria"
        case .about: return "Informazioni"
        case .version: return "Versione"
        case .srsAlgorithm: return "Algoritmo SRS"
        case .srsDescription: return "Sistema di ripetizione dilazionata per ottimizzare l'apprendimento"
        case .sourceCode: return "Codice sorgente"
        case .viewOnGithub: return "Visualizza il progetto su GitHub"
        case .notificationsDisabled: return "Notifiche Disabilitate"
        case .notificationsDisabledDesc: return "Per ricevere promemoria, abilita le notifiche nelle Impostazioni di sistema"
        case .openSettings: return "Apri Impostazioni"
        case .studyReminderTitle: return "Ora di studiare!"
        case .studyReminderBody: return "Le tue flashcard ti stanno aspettando per il ripasso."
            
        // Import & Deck Management
        case .importDeck: return "Importa Mazzo"
        case .selectCSVFile: return "Seleziona file CSV"
        case .fileFormat: return "Formato file CSV:"
        case .importSuccess: return "File importato con successo!"
        case .cardsFound: return "carte trovate"
        case .deckName: return "Nome del mazzo"
        case .preview: return "Anteprima carte:"
        case .importButton: return "Importa"
        case .cancel: return "Annulla"
        case .importCSVDeck: return "Importa un mazzo CSV"
        case .csvFormatDescription: return "Seleziona un file CSV con il formato:\nfront ;back\n(o)front,back\n(L'header viene saltato automaticamente)"
        case .csvExample: return "Esempio formato CSV"
        case .andOtherCards: return "... e altre"
        case .noDeck: return "Nessun mazzo"
        case .createFirstDeck: return "Crea il tuo primo mazzo o importane uno da un file CSV"
        case .createNewDeck: return "Crea nuovo mazzo"
        case .importFromCSV: return "Importa da CSV"
        case .active: return "ATTIVO"
        case .deselect: return "Deseleziona"
        case .selectForStudy: return "Seleziona per studio"
        case .useForStudy: return "Usa per studio"
        case .noCardsInDeck: return "Nessuna carta in questo mazzo"
        case .noCardsFound: return "Nessuna carta trovata per"
        case .newCard: return "NUOVO"
        case .toReview: return "DA RIVEDERE"
        case .cardOK: return "OK"
        case .cannotAccessFile: return "Non è possibile accedere al file selezionato"
        case .fileIsEmpty: return "Il file selezionato è vuoto"
        case .importError: return "Errore durante l'importazione:"
        case .importedFromCSV: return "Importato da file CSV"
        case .expectedFormat: return "Formato atteso"
        case .cardPreview: return "Anteprima carte:"
        case .saveButton: return "Salva"
        case .editDeck: return "Modifica mazzo"
        case .emptyFieldsAtLine: return "Campi vuoti presenti nella riga:"
        case .invalidFormatAtLine: return "Formato non valido alla riga"
        case .useCorrectFormat: return "Usa il formato corretto: fronte;retro o fronte,retro"
        case .fieldTooLongError: return "Uno o più campi superano la lunghezza massima consentita"
        case .tooManyRowsError: return "Il file contiene troppe righe"
        case .encodingError: return "Errore di codifica del file"
        case .withDescription: return "Con descrizione"
            
        // Add/Edit Cards
        case .cardFront: return "Fronte della carta"
        case .cardBack: return "Retro della carta"
        case .questionOrTerm: return "Domanda o termine"
        case .answerOrDefinition: return "Risposta o definizione"
        case .cardWillBeAdded: return "La carta verrà aggiunta al mazzo"
        case .afterCreatingDeck: return "Dopo aver creato il mazzo, potrai aggiungere le carte dalla vista dettaglio."
        case .statistics: return "Statistiche"
        case .status: return "Stato:"
        case .nextReview: return "Prossima revisione:"
        case .createdOn: return "Creata il:"
        case .lastModified: return "Ultima modifica:"
        case .newCardTitle: return "Nuova Carta"
        case .cardDetailTitle: return "Dettaglio Carta"
        case .close: return "Chiudi"
        case .editCardTitle: return "Modifica Carta"
        case .save: return "Salva"
            
        // Add/Edit Decks
        case .deckInformation: return "Informazioni Mazzo"
        case .deckOptionalDescritpion: return "Descrizione (opzionale)"
        case .deckMessage: return "Dopo aver creato il mazzo, potrai aggiungere le carte dalla vista dettaglio."
        case .newDeck: return "Nuovo Mazzo"
        case .create: return "Crea"
            
        // Deck Selection
        case .chooseDeck: return "Scegli un mazzo"
        case .selectDeckForStudy: return "Seleziona un mazzo da studiare"
        case .noDecksAvailable: return "Nessun mazzo disponibile"
        case .createOrImportDeck: return "Crea o importa un mazzo per iniziare a studiare"
            
        // Common actions
        case .add: return "Aggiungi"
        case .edit: return "Modifica"
        case .search: return "Cerca carte..."
            
        // Export
        case .exportCSV: return "Esporta CSV"
        case .exportDeck: return "Esporta mazzo"
        case .exportSuccess: return "Mazzo esportato con successo!"
        case .exportError: return "Errore durante l'esportazione"
        }
    }
    
    var english: String {
        switch self {
        // Navigation
        case .home: return "Home"
        case .decks: return "Decks"
        case .study: return "Study"
        case .settings: return "Settings"
            
        // Home Screen
        case .goodMorning: return "Good morning!"
        case .goodAfternoon: return "Good afternoon!"
        case .goodEvening: return "Good evening!"
        case .readyToStudy: return "Ready for a new study session?"
        case .todayStats: return "Today's Stats"
        case .newCards: return "New cards"
        case .reviews: return "Reviews"
        case .totalToStudy: return "Total to study"
        case .currentDeck: return "Current deck"
        case .noDeckSelected: return "No deck selected"
        case .tapToSelect: return "Tap to select one"
        case .quickActions: return "Quick actions"
        case .startStudying: return "Start studying"
        case .manageDeck: return "Manage decks"
        case .decksAvailable: return "decks available"
        case .goToDecksToSelect: return "Go to the Decks section to select a deck to study"
        case .cards: return "cards"
            
        // Study Screen
        case .session: return "Session"
        case .tapToFlip: return "Tap the card to flip it"
        case .howWasIt: return "How was it?"
        case .front: return "FRONT"
        case .back: return "BACK"
        case .italian: return "ITALIAN"
        case .english: return "ENGLISH"
        case .again: return "Again"
        case .hard: return "Hard"
        case .good: return "Good"
        case .easy: return "Easy"
        case .dontKnow: return "Didn't know it"
        case .hardToRemember: return "Hard to remember"
        case .rememberedWell: return "Remembered it well"
        case .tooEasy: return "Too easy!"
        case .cardNumber: return "Card"
        case .tapToSeeAnswer: return "Tap the card to see the answer"
        case .howHardWasCard: return "How hard was this card?"
        case .of: return "of"
            
        // Settings Screen
        case .studySettings: return "Study Settings"
        case .dailyNewCards: return "Daily new cards"
        case .dailyNewCardsDesc: return "Maximum number of new cards to study each day"
        case .maxReviews: return "Total cards to study"
        case .maxReviewsDesc: return "Maximum number of cards to study each day"
        case .studyFromEnglish: return "Study from English"
        case .startFromEnglish: return "Start from English side"
        case .notifications: return "Notifications"
        case .studyReminder: return "Study reminder"
        case .studyReminderDesc: return "Receive notifications to remind you to study"
        case .language: return "Language"
        case .selectLanguage: return "Select app language"
        case .appLanguage: return "App language"
        case .changeInterfaceLanguage: return "Change Interface language"
        case .reminderTime: return "Reminder time"
        case .about: return "About"
        case .version: return "Version"
        case .srsAlgorithm: return "SRS Algorithm"
        case .srsDescription: return "Spaced repetition system to optimize learning"
        case .sourceCode: return "Source code"
        case .viewOnGithub: return "View project on GitHub"
        case .notificationsDisabled: return "Notifications Disabled"
        case .notificationsDisabledDesc: return "To receive reminders, enable notifications in System Settings"
        case .openSettings: return "Open Settings"
        case .studyReminderTitle: return "Time to Study!"
        case .studyReminderBody: return "Your flashcards are waiting for review."
            
        // Import & Deck Management
        case .importDeck: return "Import Deck"
        case .selectCSVFile: return "Select CSV file"
        case .fileFormat: return "CSV file format:"
        case .importSuccess: return "File imported successfully!"
        case .cardsFound: return "cards found"
        case .deckName: return "Deck name"
        case .preview: return "Cards preview:"
        case .importButton: return "Import"
        case .cancel: return "Cancel"
        case .importCSVDeck: return "Import a CSV deck"
        case .csvFormatDescription: return "Select a CSV file with the format:\nfront;back or front,back\n(Headers are automatically skipped)"
        case .csvExample: return "CSV format example"
        case .andOtherCards: return "... and other"
        case .noDeck: return "No deck"
        case .createFirstDeck: return "Create your first deck or import one from a CSV file"
        case .createNewDeck: return "Create new deck"
        case .importFromCSV: return "Import from CSV"
        case .active: return "ACTIVE"
        case .deselect: return "Deselect"
        case .selectForStudy: return "Select for study"
        case .useForStudy: return "Use for study"
        case .noCardsInDeck: return "No cards in this deck"
        case .noCardsFound: return "No cards found for"
        case .newCard: return "NEW"
        case .toReview: return "TO REVIEW"
        case .cardOK: return "OK"
        case .cannotAccessFile: return "Cannot access the selected file"
        case .fileIsEmpty: return "The selected file is empty"
        case .importError: return "Import error:"
        case .importedFromCSV: return "Imported from CSV file"
        case .expectedFormat: return "Expected format"
        case .cardPreview: return "Cards preview:"
        case .saveButton: return "Save"
        case .editDeck: return "Edit Deck"
        case .emptyFieldsAtLine: return "Empty field at line:"
        case .invalidFormatAtLine: return "Invalid format at line"
        case .useCorrectFormat: return "Use the correct format: front;back or front,back"
        case .fieldTooLongError: return "One or more fields exceed the maximum allowed length"
        case .tooManyRowsError: return "The file contains too many rows"
        case .encodingError: return "File encoding error"
        case .withDescription: return "With description"
            
        // Add/Edit Cards
        case .cardFront: return "Card front"
        case .cardBack: return "Card back"
        case .questionOrTerm: return "Question or term"
        case .answerOrDefinition: return "Answer or definition"
        case .cardWillBeAdded: return "The card will be added to deck"
        case .afterCreatingDeck: return "After creating the deck, you can add cards from the detail view."
        case .statistics: return "Statistics"
        case .status: return "Status:"
        case .nextReview: return "Next review:"
        case .createdOn: return "Created on:"
        case .lastModified: return "Last modified:"
        case .newCardTitle: return "New Card"
        case .cardDetailTitle: return "Card Details"
        case .close: return "Close"
        case .editCardTitle: return "Edit Card"
        case .save: return "Save"
            
        // Add/Edit Decks
        case .deckInformation: return "Deck Information"
        case .deckOptionalDescritpion: return "Description (optional)"
        case .deckMessage: return "After creating the deck, you can add cards from the detail view."
        case .newDeck: return "New Deck"
        case .create: return "Create"
            
        // Deck Selection
        case .chooseDeck: return "Choose a Deck"
        case .selectDeckForStudy: return "Select a deck to study"
        case .noDecksAvailable: return "No decks available"
        case .createOrImportDeck: return "Create or import a deck to start studying"
            
        // Common actions
        case .add: return "Add"
        case .edit: return "Edit"
        case .search: return "Search cards..."
            
        // Export
        case .exportCSV: return "Export CSV"
        case .exportDeck: return "Export deck"
        case .exportSuccess: return "Deck exported successfully!"
        case .exportError: return "Export error"
        }
    }
}

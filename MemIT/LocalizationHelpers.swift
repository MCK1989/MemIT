//
//  LocalizationHelpers.swift
//  MemIT
//
//  Created by Marco Cortellazzi on 04/01/26.
//

import SwiftUI

// MARK: - View Extension per localizzazione facile
extension View {
    func localized(_ key: LocalizationKey, using localization: LocalizationManager) -> some View {
        Text(localization.text(key))
    }
}

// MARK: - Funzione globale per localizzazione
@MainActor
func L(_ key: LocalizationKey, from appState: AppState) -> String {
    return appState.localization.text(key)
}

// MARK: - Custom Text View localizzato
struct LocalizedText: View {
    let key: LocalizationKey
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Text(appState.localization.text(key))
    }
}

// MARK: - Language Picker Component
struct LanguagePicker: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack {
            Image(systemName: "globe")
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 2) {
                LocalizedText(key: .language)
                    .font(.headline)
                LocalizedText(key: .selectLanguage)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Picker("Language", selection: $appState.localization.currentLanguage) {
                ForEach(LocalizationManager.AppLanguage.allCases, id: \.self) { language in
                    HStack {
                        Text(language.flag)
                        Text(language.displayName)
                    }
                    .tag(language)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }
}

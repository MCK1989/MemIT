//
//  ContentView.swift
//  MemIT
//
//  Created by Marco Cortellazzi on 04/01/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab - Dashboard
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    LocalizedText(key: .home)
                }
                .tag(0)
            
            // Decks Tab
            DecksListView()
                .tabItem {
                    Image(systemName: "rectangle.stack.fill")
                    LocalizedText(key: .decks)
                }
                .tag(1)
            
            // Study Tab
            NavigationStack {
                if appState.selectedDeck != nil {
                    StudyView()
                        .environmentObject(appState)
                } else {
                    SelectDeckPromptView()
                }
            }
            .tabItem {
                Image(systemName: "brain.head.profile")
                LocalizedText(key: .study)
            }
            .tag(2)
            
            // Settings Tab
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    LocalizedText(key: .settings)
                }
                .tag(3)
        }
        .onAppear {
            // Auto-select first deck if none selected
            if appState.selectedDeckId == nil && !appState.decks.isEmpty {
                appState.selectDeck(appState.decks.first!)
            }
        }
    }
}

struct SelectDeckPromptView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "rectangle.stack")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                LocalizedText(key: .noDeckSelected)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                LocalizedText(key: .goToDecksToSelect)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .navigationTitle("Studio")
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}

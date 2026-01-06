//
//  StatsView.swift
//  MemIT
//
//  Created by Marco Cortellazzi on 05/01/26.
//

import SwiftUI
import Charts

struct StatsView: View {
    @EnvironmentObject var appState: AppState
    let sessionStats: StudyStats?
    
    init(sessionStats: StudyStats? = nil) {
        self.sessionStats = sessionStats
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if let stats = sessionStats {
                    sessionStatsSection(stats: stats)
                } else {
                    globalStatsSection
                }
            }
            .padding()
        }
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: - Session Stats
    
    private func sessionStatsSection(stats: StudyStats) -> some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                
                Text("Session Statistics")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Review your performance")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical)
            
            // Total cards studied
            StatCard(
                title: "Cards Studied",
                value: "\(stats.totalStudied)",
                icon: "brain.head.profile",
                color: .blue,
                style: .expanded
            )
            
            // Accuracy
            StatCard(
                title: "Accuracy",
                value: String(format: "%.0f%%", stats.accuracy * 100),
                icon: "target",
                color: stats.accuracy > 0.7 ? .green : .orange,
                style: .expanded
            )
            
            // Performance breakdown
            performanceBreakdown(stats: stats)
            
            // Card types breakdown
            cardTypesBreakdown(stats: stats)
        }
    }
    
    // MARK: - Global Stats
    
    private var globalStatsSection: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                
                Text("Global Statistics")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Your overall progress")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical)
            
            // Global statistics overview
            globalStatsOverview
            
            // Deck stats
            if let selectedDeck = appState.selectedDeck {
                deckStatsSection(deck: selectedDeck)
                
                // Card distribution chart
                cardDistributionChart(deck: selectedDeck)
                
                // Ease factor chart
                easeFactorChart(deck: selectedDeck)
                
                // Upcoming reviews chart
                upcomingReviewsChart(deck: selectedDeck)
                
                // Mastery level chart
                masteryLevelChart(deck: selectedDeck)
            } else {
                // No deck selected message
                VStack(spacing: 12) {
                    Image(systemName: "rectangle.stack")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    
                    Text("No deck selected")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Select a deck to view detailed statistics")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    // MARK: - Performance Breakdown
    
    private func performanceBreakdown(stats: StudyStats) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Performance Breakdown")
                .font(.headline)
            
            if #available(iOS 16.0, *) {
                Chart {
                    BarMark(
                        x: .value("Count", stats.againCount),
                        y: .value("Rating", "Again")
                    )
                    .foregroundStyle(.red)
                    
                    BarMark(
                        x: .value("Count", stats.hardCount),
                        y: .value("Rating", "Hard")
                    )
                    .foregroundStyle(.orange)
                    
                    BarMark(
                        x: .value("Count", stats.goodCount),
                        y: .value("Rating", "Good")
                    )
                    .foregroundStyle(.green)
                    
                    BarMark(
                        x: .value("Count", stats.easyCount),
                        y: .value("Rating", "Easy")
                    )
                    .foregroundStyle(.blue)
                }
                .frame(height: 200)
            } else {
                // Fallback for iOS 15
                VStack(spacing: 8) {
                    ratingRow(label: "Again", count: stats.againCount, color: .red, total: stats.totalStudied)
                    ratingRow(label: "Hard", count: stats.hardCount, color: .orange, total: stats.totalStudied)
                    ratingRow(label: "Good", count: stats.goodCount, color: .green, total: stats.totalStudied)
                    ratingRow(label: "Easy", count: stats.easyCount, color: .blue, total: stats.totalStudied)
                }
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func ratingRow(label: String, count: Int, color: Color, total: Int) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(color)
                .frame(width: 60, alignment: .leading)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: total > 0 ? geometry.size.width * CGFloat(count) / CGFloat(total) : 0)
                }
            }
            .frame(height: 20)
            
            Text("\(count)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(width: 30, alignment: .trailing)
        }
    }
    
    // MARK: - Card Types Breakdown
    
    private func cardTypesBreakdown(stats: StudyStats) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Card Types")
                .font(.headline)
            
            HStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text("\(stats.newCardsStudied)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("New")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.green.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack(spacing: 8) {
                    Text("\(stats.reviewCardsStudied)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("Review")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Deck Stats
    
    private func deckStatsSection(deck: Deck) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(deck.name)
                .font(.headline)
            
            HStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text("\(deck.totalCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Total")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                VStack(spacing: 8) {
                    Text("\(deck.newCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("New")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                VStack(spacing: 8) {
                    Text("\(deck.dueCount())")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    Text("Due")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Charts
    
    /// Card distribution by status
    private func cardDistributionChart(deck: Deck) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Card Distribution")
                .font(.headline)
            
            if #available(iOS 16.0, *) {
                let activeCards = deck.activeCards
                let newCards = activeCards.filter { $0.srs.isNew }.count
                let dueCards = activeCards.filter { $0.srs.isDue }.count
                let learningCards = activeCards.filter { !$0.srs.isNew && !$0.srs.isDue }.count
                
                Chart {
                    SectorMark(
                        angle: .value("Count", newCards),
                        innerRadius: .ratio(0.5),
                        angularInset: 1.5
                    )
                    .foregroundStyle(.green)
                    .annotation(position: .overlay) {
                        if newCards > 0 {
                            Text("\(newCards)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                    
                    SectorMark(
                        angle: .value("Count", dueCards),
                        innerRadius: .ratio(0.5),
                        angularInset: 1.5
                    )
                    .foregroundStyle(.orange)
                    .annotation(position: .overlay) {
                        if dueCards > 0 {
                            Text("\(dueCards)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                    
                    SectorMark(
                        angle: .value("Count", learningCards),
                        innerRadius: .ratio(0.5),
                        angularInset: 1.5
                    )
                    .foregroundStyle(.blue)
                    .annotation(position: .overlay) {
                        if learningCards > 0 {
                            Text("\(learningCards)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                }
                .frame(height: 200)
                
                // Legend
                HStack(spacing: 20) {
                    legendItem(color: .green, label: "New", count: newCards)
                    legendItem(color: .orange, label: "Due", count: dueCards)
                    legendItem(color: .blue, label: "Learning", count: learningCards)
                }
                .padding(.top, 8)
            } else {
                // Fallback for iOS 15
                Text("Chart requires iOS 16+")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    /// Ease factor distribution
    private func easeFactorChart(deck: Deck) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ease Factor Distribution")
                .font(.headline)
            
            if #available(iOS 16.0, *) {
                let activeCards = deck.activeCards.filter { !$0.srs.isNew }
                
                if activeCards.isEmpty {
                    Text("No data available yet. Start studying to see statistics!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                } else {
                    let avgEaseFactor = activeCards.map { $0.srs.easeFactor }.reduce(0, +) / Double(activeCards.count)
                    
                    // Group cards by ease factor ranges
                    let difficult = activeCards.filter { $0.srs.easeFactor < 2.0 }.count
                    let normal = activeCards.filter { $0.srs.easeFactor >= 2.0 && $0.srs.easeFactor < 2.5 }.count
                    let easy = activeCards.filter { $0.srs.easeFactor >= 2.5 }.count
                    
                    Chart {
                        BarMark(
                            x: .value("Count", difficult),
                            y: .value("Difficulty", "Difficult\n(<2.0)")
                        )
                        .foregroundStyle(.red)
                        
                        BarMark(
                            x: .value("Count", normal),
                            y: .value("Difficulty", "Normal\n(2.0-2.5)")
                        )
                        .foregroundStyle(.orange)
                        
                        BarMark(
                            x: .value("Count", easy),
                            y: .value("Difficulty", "Easy\n(≥2.5)")
                        )
                        .foregroundStyle(.green)
                    }
                    .frame(height: 150)
                    
                    Text("Average Ease Factor: \(String(format: "%.2f", avgEaseFactor))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            } else {
                Text("Chart requires iOS 16+")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    /// Upcoming reviews in the next 7 days
    private func upcomingReviewsChart(deck: Deck) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upcoming Reviews (Next 7 Days)")
                .font(.headline)
            
            if #available(iOS 16.0, *) {
                let activeCards = deck.activeCards.filter { !$0.srs.isNew }
                
                if activeCards.isEmpty {
                    Text("No reviews scheduled yet")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                } else {
                    let dailyReviews = calculateDailyReviews(for: activeCards)
                    
                    Chart(dailyReviews, id: \.day) { item in
                        BarMark(
                            x: .value("Day", item.day),
                            y: .value("Reviews", item.count)
                        )
                        .foregroundStyle(.blue)
                        .annotation(position: .top) {
                            if item.count > 0 {
                                Text("\(item.count)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .frame(height: 180)
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                }
            } else {
                Text("Chart requires iOS 16+")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    /// Mastery level based on repetitions
    private func masteryLevelChart(deck: Deck) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mastery Levels")
                .font(.headline)
            
            if #available(iOS 16.0, *) {
                let activeCards = deck.activeCards
                
                // Group by mastery level
                let beginner = activeCards.filter { $0.srs.repetitions == 0 }.count  // New
                let learning = activeCards.filter { $0.srs.repetitions > 0 && $0.srs.repetitions < 3 }.count
                let intermediate = activeCards.filter { $0.srs.repetitions >= 3 && $0.srs.repetitions < 6 }.count
                let advanced = activeCards.filter { $0.srs.repetitions >= 6 && $0.srs.repetitions < 10 }.count
                let mastered = activeCards.filter { $0.srs.repetitions >= 10 }.count
                
                Chart {
                    BarMark(
                        x: .value("Count", beginner),
                        y: .value("Level", "Beginner")
                    )
                    .foregroundStyle(.gray)
                    
                    BarMark(
                        x: .value("Count", learning),
                        y: .value("Level", "Learning")
                    )
                    .foregroundStyle(.orange)
                    
                    BarMark(
                        x: .value("Count", intermediate),
                        y: .value("Level", "Intermediate")
                    )
                    .foregroundStyle(.yellow)
                    
                    BarMark(
                        x: .value("Count", advanced),
                        y: .value("Level", "Advanced")
                    )
                    .foregroundStyle(.blue)
                    
                    BarMark(
                        x: .value("Count", mastered),
                        y: .value("Level", "Mastered")
                    )
                    .foregroundStyle(.green)
                }
                .frame(height: 200)
                
                Text("Mastered cards: \(mastered) of \(activeCards.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            } else {
                Text("Chart requires iOS 16+")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Helper Views
    
    private var globalStatsOverview: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("All Time Statistics")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                // Total cards studied
                VStack(spacing: 8) {
                    Text("\(appState.globalStats.totalCardsStudied)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("Total Cards")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Study sessions
                VStack(spacing: 8) {
                    Text("\(appState.globalStats.studySessions)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                    Text("Sessions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.purple.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // New cards
                VStack(spacing: 8) {
                    Text("\(appState.globalStats.totalNewCardsStudied)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("New Cards")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.green.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Reviews
                VStack(spacing: 8) {
                    Text("\(appState.globalStats.totalReviewCardsStudied)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    Text("Reviews")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.orange.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // Accuracy
            if appState.globalStats.totalCardsStudied > 0 {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Overall Accuracy")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(Int(appState.globalStats.accuracy * 100))%")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                    
                    // Rating breakdown
                    HStack(spacing: 16) {
                        VStack(spacing: 4) {
                            Text("\(appState.globalStats.totalAgainCount)")
                                .font(.caption)
                                .fontWeight(.semibold)
                            Circle()
                                .fill(.red)
                                .frame(width: 8, height: 8)
                        }
                        
                        VStack(spacing: 4) {
                            Text("\(appState.globalStats.totalHardCount)")
                                .font(.caption)
                                .fontWeight(.semibold)
                            Circle()
                                .fill(.orange)
                                .frame(width: 8, height: 8)
                        }
                        
                        VStack(spacing: 4) {
                            Text("\(appState.globalStats.totalGoodCount)")
                                .font(.caption)
                                .fontWeight(.semibold)
                            Circle()
                                .fill(.green)
                                .frame(width: 8, height: 8)
                        }
                        
                        VStack(spacing: 4) {
                            Text("\(appState.globalStats.totalEasyCount)")
                                .font(.caption)
                                .fontWeight(.semibold)
                            Circle()
                                .fill(.blue)
                                .frame(width: 8, height: 8)
                        }
                    }
                }
                .padding()
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // Last study date
            if let lastStudy = appState.globalStats.lastStudyDate {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.secondary)
                    Text("Last study session:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(lastStudy, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fontWeight(.semibold)
                    Text("ago")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Helper Views
    
    private func legendItem(color: Color, label: String, count: Int) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(count)")
                    .font(.caption2)
                    .fontWeight(.semibold)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func calculateDailyReviews(for activeCards: [Card]) -> [(day: String, count: Int)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var dailyReviews: [(day: String, count: Int)] = []
        
        for dayOffset in 0..<7 {
            let date = calendar.date(byAdding: .day, value: dayOffset, to: today)!
            let nextDate = calendar.date(byAdding: .day, value: 1, to: date)!
            
            let count = activeCards.filter { card in
                card.srs.dueDate >= date && card.srs.dueDate < nextDate
            }.count
            
            let dayName: String
            if dayOffset == 0 {
                dayName = "Today"
            } else if dayOffset == 1 {
                dayName = "Tomorrow"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "EEE"
                dayName = formatter.string(from: date)
            }
            
            dailyReviews.append((day: dayName, count: count))
        }
        
        return dailyReviews
    }
}

#Preview {
    NavigationStack {
        StatsView(sessionStats: StudyStats(
            newCardsStudied: 5,
            reviewCardsStudied: 3,
            againCount: 1,
            hardCount: 2,
            goodCount: 4,
            easyCount: 1
        ))
        .environmentObject(AppState())
    }
}

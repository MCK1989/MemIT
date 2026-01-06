//
//  StatCard.swift
//  MemIT
//
//  Created by Marco Cortellazzi on 05/01/26.
//

import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var style: StatCardStyle = .compact
    
    enum StatCardStyle {
        case compact  // For grid layout in HomeView
        case expanded // For detailed stats in StatsView
    }
    
    var body: some View {
        HStack(spacing: style == .expanded ? 16 : 12) {
            Image(systemName: icon)
                .font(style == .expanded ? .system(size: 40) : .title2)
                .foregroundColor(color)
                .frame(width: style == .expanded ? 60 : nil)
            
            VStack(alignment: .leading, spacing: style == .expanded ? 4 : 2) {
                if style == .expanded {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(value)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(color)
                } else {
                    Text(value)
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
        }
        .padding()
        .frame(height: style == .compact ? 80 : nil)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview("Compact Style") {
    VStack {
        StatCard(
            title: "New Cards",
            value: "0/20",
            icon: "plus.circle.fill",
            color: .green,
            style: .compact
        )
    }
    .padding()
}

#Preview("Expanded Style") {
    VStack {
        StatCard(
            title: "Cards Studied",
            value: "25",
            icon: "brain.head.profile",
            color: .blue,
            style: .expanded
        )
    }
    .padding()
}

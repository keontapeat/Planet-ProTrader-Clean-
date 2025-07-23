//
//  PerformanceRow.swift
//  Planet ProTrader - Performance Components
//
//  Reusable performance display components
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

struct PerformanceRow: View {
    let period: String
    let value: String
    let percentage: String
    let isPositive: Bool
    
    var body: some View {
        HStack {
            Text(period)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("\(isPositive ? "+" : "")\(percentage)")
                    .font(.caption)
                    .foregroundColor(isPositive ? .green : .red)
            }
        }
    }
}

// Placeholder views for missing components
struct BotDetailsView: View {
    let bot: TradingBot
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("🤖 \(bot.name)")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Bot details coming soon")
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .navigationTitle("Bot Details")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct UltraPremiumCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(DesignSystem.Spacing.lg)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .stroke(DesignSystem.goldGradient, lineWidth: 2)
            )
            .shadow(color: DesignSystem.primaryGold.opacity(0.4), radius: 16, x: 0, y: 8)
    }
}

#Preview {
    VStack(spacing: 16) {
        PerformanceRow(
            period: "Today",
            value: "$245.75",
            percentage: "2.8%",
            isPositive: true
        )
        
        PerformanceRow(
            period: "This Week",
            value: "$-45.30",
            percentage: "-1.2%",
            isPositive: false
        )
    }
    .padding()
}
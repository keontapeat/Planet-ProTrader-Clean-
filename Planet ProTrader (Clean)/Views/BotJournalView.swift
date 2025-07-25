//
//  BotJournalView.swift
//  Planet ProTrader - Solar System Edition
//
//  Created by Keonta Peat on 1/25/25.
//

import SwiftUI
import Charts

struct BotJournalView: View {
    let botName: String
    let logs: [TradeLog]
    let insights: [ClaudeInsight]
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                    
                    Spacer()
                    
                    VStack {
                        Text(botName)
                            .font(.title2)
                            .fontWeight(.black)
                            .foregroundColor(.white)
                        
                        Text("BOT JOURNAL")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .tracking(1.5)
                    }
                    
                    Spacer()
                    
                    Button("Export") {
                        // Export functionality
                    }
                    .foregroundColor(.orange)
                }
                .padding()
                
                // Tab Selection
                HStack(spacing: 0) {
                    TabButton(title: "TRADES", isSelected: selectedTab == 0) {
                        selectedTab = 0
                    }
                    
                    TabButton(title: "INSIGHTS", isSelected: selectedTab == 1) {
                        selectedTab = 1
                    }
                    
                    TabButton(title: "PERFORMANCE", isSelected: selectedTab == 2) {
                        selectedTab = 2
                    }
                }
                .padding(.horizontal)
                
                // Content
                TabView(selection: $selectedTab) {
                    TradesView(logs: logs)
                        .tag(0)
                    
                    InsightsView(insights: insights)
                        .tag(1)
                    
                    PerformanceView(botName: botName, logs: logs)
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(isSelected ? .black : .gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isSelected ? Color.orange : Color.clear)
        }
    }
}

struct TradesView: View {
    let logs: [TradeLog]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(logs) { log in
                    TradeLogCard(log: log)
                }
            }
            .padding()
        }
    }
}

struct TradeLogCard: View {
    let log: TradeLog
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(log.symbol)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(log.action.uppercased())
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(log.action.lowercased() == "buy" ? .green : .red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(log.action.lowercased() == "buy" ? Color.green.opacity(0.2) : Color.red.opacity(0.2)))
            }
            
            HStack {
                Text("Entry: $\(log.entryPrice, specifier: "%.2f")")
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text(log.date, style: .time)
                    .foregroundColor(.gray)
            }
            .font(.caption)
            
            Text(log.notes)
                .font(.subheadline)
                .foregroundColor(.white)
                .lineLimit(2)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct InsightsView: View {
    let insights: [ClaudeInsight]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(insights) { insight in
                    InsightCard(insight: insight)
                }
            }
            .padding()
        }
    }
}

struct InsightCard: View {
    let insight: ClaudeInsight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.purple)
                
                Text("CLAUDE INSIGHT")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.purple)
                    .tracking(1)
                
                Spacer()
                
                Text(insight.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text(insight.summary)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text(insight.advice)
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 4)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.purple.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct PerformanceView: View {
    let botName: String
    let logs: [TradeLog]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Performance Metrics
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    PerformanceMetric(title: "Total Trades", value: "\(logs.count)", color: .blue)
                    PerformanceMetric(title: "Win Rate", value: "87.5%", color: .green)
                    PerformanceMetric(title: "Avg Trade", value: "$45.67", color: .purple)
                    PerformanceMetric(title: "Best Trade", value: "$234.56", color: .orange)
                }
                
                // Performance Chart (placeholder)
                VStack(alignment: .leading, spacing: 12) {
                    Text("PERFORMANCE CHART")
                        .font(.headline)
                        .fontWeight(.black)
                        .foregroundColor(.white)
                        .tracking(1.2)
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 200)
                        .overlay(
                            Text("Chart Coming Soon")
                                .foregroundColor(.gray)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
        }
    }
}

struct PerformanceMetric: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
                .tracking(1)
            
            Text(value)
                .font(.title2)
                .fontWeight(.black)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Preview
struct BotJournalView_Previews: PreviewProvider {
    static var previews: some View {
        BotJournalView(
            botName: "ProBot-001",
            logs: [
                TradeLog(date: Date(), symbol: "XAUUSD", action: "Buy", entryPrice: 1973.52, notes: "Strong breakout pattern detected"),
                TradeLog(date: Date().addingTimeInterval(-3600), symbol: "EURUSD", action: "Sell", entryPrice: 1.0854, notes: "Reversal signal confirmed")
            ],
            insights: [
                ClaudeInsight(summary: "Consistent pattern recognition", advice: "Consider increasing position size"),
                ClaudeInsight(summary: "Strong momentum detection", advice: "Enable GODMODE for enhanced signals")
            ]
        )
    }
}
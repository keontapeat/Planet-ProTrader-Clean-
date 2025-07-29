//
//  BotJournalView.swift
//  Planet ProTrader - Bot Journal
//
//  Trading Bot Journal and Insights
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

struct BotJournalView: View {
    let botName: String
    let logs: [TradeLog]
    let insights: [ClaudeInsight]
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            VStack {
                // Tab Selector
                Picker("View", selection: $selectedTab) {
                    Text("Trade Logs").tag(0)
                    Text("AI Insights").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Content
                TabView(selection: $selectedTab) {
                    // Trade Logs
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(logs) { log in
                                TradeLogCard(log: log)
                            }
                        }
                        .padding()
                    }
                    .tag(0)
                    
                    // AI Insights
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(insights) { insight in
                                InsightCard(insight: insight)
                            }
                        }
                        .padding()
                    }
                    .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .background(DesignSystem.AnimatedStarField().ignoresSafeArea())
            .navigationTitle(botName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(DesignSystem.primaryGold)
                }
            }
        }
    }
}

struct TradeLogCard: View {
    let log: TradeLog
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(log.symbol)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(log.action)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(log.action == "BUY" ? .green : .red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background((log.action == "BUY" ? Color.green : Color.red).opacity(0.2), in: Capsule())
            }
            
            Text(log.notes)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(log.date, style: .time)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct InsightCard: View {
    let insight: ClaudeInsight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AI Analysis")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(DesignSystem.primaryGold)
            
            Text(insight.summary)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text(insight.advice)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(DesignSystem.primaryGold.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    BotJournalView(
        botName: "Gold-Bot-001",
        logs: [
            TradeLog(date: Date(), symbol: "XAUUSD", action: "BUY", entryPrice: 2350.0, notes: "Strong bullish signal detected"),
            TradeLog(date: Date(), symbol: "XAUUSD", action: "SELL", entryPrice: 2375.0, notes: "Profit target reached")
        ],
        insights: [
            ClaudeInsight(summary: "Bot performance excellent", advice: "Continue current strategy"),
            ClaudeInsight(summary: "Market conditions favorable", advice: "Consider increasing position size")
        ]
    )
}
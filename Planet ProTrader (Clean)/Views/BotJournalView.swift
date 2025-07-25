//
//  BotJournalView.swift
//  Planet ProTrader (Clean)
//
//  Created by Keonta  on 7/25/25.
//


// BotJournalView.swift - Claude AI Trade Logs + Insights

import SwiftUI

struct BotJournalView: View {
    let botName: String
    let logs: [TradeLog]
    let insights: [ClaudeInsight]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Bot Header
                    Text("📘 \(botName) Journal")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    // Trade Logs
                    VStack(alignment: .leading, spacing: 12) {
                        Text("🧾 Trade Logs")
                            .font(.title2.bold())
                            .foregroundColor(.white.opacity(0.9))

                        ForEach(logs) { log in
                            VStack(alignment: .leading, spacing: 8) {
                                Text("📅 \(log.date.formatted(date: .abbreviated, time: .shortened))")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.5))
                                Text("🪙 Symbol: \(log.symbol) | \(log.action) @ \(log.entryPrice, specifier: "%.2f")")
                                    .font(.body.bold())
                                    .foregroundColor(.white)
                                Text("🧠 Notes: \(log.notes)")
                                    .font(.callout)
                                    .foregroundColor(.white.opacity(0.7))
                                Divider().background(.white.opacity(0.1))
                            }
                            .padding(.bottom, 8)
                        }
                    }

                    // Claude AI Insights
                    VStack(alignment: .leading, spacing: 12) {
                        Text("🧠 Claude AI Insights")
                            .font(.title2.bold())
                            .foregroundColor(.white.opacity(0.9))

                        ForEach(insights) { insight in
                            VStack(alignment: .leading, spacing: 6) {
                                Text("• \(insight.summary)")
                                    .font(.callout)
                                    .foregroundColor(.white)
                                Text(insight.advice)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .padding(12)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Bot Journal")
            .background(
                LinearGradient(
                    colors: [Color.black, Color(red: 0.05, green: 0.05, blue: 0.1)],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()
            )
        }
    }
}

// MARK: - Models

struct TradeLog: Identifiable {
    let id = UUID()
    let date: Date
    let symbol: String
    let action: String // "Buy" or "Sell"
    let entryPrice: Double
    let notes: String
}

struct ClaudeInsight: Identifiable {
    let id = UUID()
    let summary: String
    let advice: String
}

// MARK: - Preview

#Preview {
    BotJournalView(
        botName: "ProTrader_3281",
        logs: [
            TradeLog(date: Date(), symbol: "XAUUSD", action: "Buy", entryPrice: 1973.52, notes: "Detected strong breakout pattern on M15."),
            TradeLog(date: Date().addingTimeInterval(-3600), symbol: "XAUUSD", action: "Sell", entryPrice: 1980.00, notes: "Reversal on RSI divergence.")
        ],
        insights: [
            ClaudeInsight(summary: "Consistent reversal detection", advice: "Consider increasing lot size on RSI-confirmed trades."),
            ClaudeInsight(summary: "Strong breakout momentum", advice: "Enable GODMODE logic when confidence > 90%.")
        ]
    )
    .preferredColorScheme(.dark)
}

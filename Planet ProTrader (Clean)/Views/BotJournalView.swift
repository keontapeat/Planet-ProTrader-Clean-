//
//  BotJournalView.swift
//  Planet ProTrader - Bot Journal Interface
//
//  Professional bot monitoring and logging interface
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

struct BotJournalView: View {
    let botName: String
    let logs: [TradeLog]
    let insights: [ClaudeInsight]
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 48))
                            .foregroundColor(.cyan)
                        
                        Text(botName)
                            .font(.title.bold())
                            .foregroundStyle(.white)
                        
                        Text("AI-Powered Trading Journal")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }
                    
                    // Recent Logs Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("📊 Recent Activity")
                                .font(.headline.bold())
                                .foregroundStyle(.white)
                            
                            Spacer()
                            
                            Text("\(logs.count) entries")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                        
                        LazyVStack(spacing: 12) {
                            ForEach(logs.prefix(10)) { log in
                                HStack(alignment: .top, spacing: 12) {
                                    VStack(spacing: 4) {
                                        Text(log.date, style: .time)
                                            .font(.caption2)
                                            .foregroundStyle(.gray)
                                        
                                        Circle()
                                            .fill(log.action == "BUY" ? .green : log.action == "SELL" ? .red : .blue)
                                            .frame(width: 8, height: 8)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(log.symbol)
                                                .font(.subheadline.bold())
                                                .foregroundStyle(.white)
                                            
                                            if log.action != "INFO" {
                                                Text(log.action)
                                                    .font(.caption.bold())
                                                    .foregroundStyle(log.action == "BUY" ? .green : .red)
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(
                                                        Capsule()
                                                            .fill((log.action == "BUY" ? Color.green : Color.red).opacity(0.2))
                                                    )
                                            }
                                            
                                            Spacer()
                                        }
                                        
                                        Text(log.notes)
                                            .font(.caption)
                                            .foregroundStyle(.gray)
                                            .lineLimit(2)
                                        
                                        if log.entryPrice > 0 {
                                            Text("Entry: $\(String(format: "%.2f", log.entryPrice))")
                                                .font(.caption2)
                                                .foregroundStyle(.blue)
                                        }
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.ultraThinMaterial)
                                )
                            }
                        }
                    }
                    
                    // AI Insights Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("🧠 AI Insights")
                                .font(.headline.bold())
                                .foregroundStyle(.white)
                            
                            Spacer()
                            
                            Text("\(insights.count) insights")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                        
                        LazyVStack(spacing: 12) {
                            ForEach(insights.prefix(5)) { insight in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(insight.summary)
                                        .font(.subheadline.bold())
                                        .foregroundStyle(.white)
                                    
                                    Text(insight.advice)
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                        .lineLimit(3)
                                    
                                    HStack {
                                        Spacer()
                                        
                                        Text(insight.timestamp, style: .relative)
                                            .font(.caption2)
                                            .foregroundStyle(.blue)
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(.cyan.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color.black)
            .navigationTitle("Bot Journal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(.blue)
                }
            }
        }
    }
}

#Preview {
    BotJournalView(
        botName: "Golden Eagle AI",
        logs: [
            TradeLog(
                date: Date(),
                symbol: "XAUUSD",
                action: "BUY",
                entryPrice: 2374.50,
                notes: "Strong bullish momentum detected"
            ),
            TradeLog(
                date: Date().addingTimeInterval(-300),
                symbol: "XAUUSD",
                action: "SELL",
                entryPrice: 2380.25,
                notes: "Profit target reached"
            ),
            TradeLog(
                date: Date().addingTimeInterval(-600),
                symbol: "XAUUSD",
                action: "INFO",
                entryPrice: 0.0,
                notes: "🤖 AI optimization active"
            )
        ],
        insights: [
            ClaudeInsight(
                summary: "Market Analysis: Strong upward trend detected",
                advice: "Consider increasing position size for favorable conditions"
            ),
            ClaudeInsight(
                summary: "Risk Assessment: Low volatility environment",
                advice: "Maintain current risk parameters for optimal performance"
            )
        ]
    )
    .preferredColorScheme(.dark)
}
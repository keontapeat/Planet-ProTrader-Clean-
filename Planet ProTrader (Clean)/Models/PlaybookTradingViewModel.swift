//
//  PlaybookTradingViewModel.swift
//  Planet ProTrader (Clean)
//
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI
import Foundation

// MARK: - Mock Trading View Model for Playbook

@MainActor
class TradingViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var totalTrades = 0
    @Published var winningTrades = 0
    @Published var losingTrades = 0
    @Published var totalProfit: Double = 0
    @Published var flipBot: TradingBot?
    @Published var isFlipModeActive = false
    
    // Mock data for playbook
    @Published var recentTrades: [PlaybookTrade] = []
    
    init() {
        loadMockData()
    }
    
    // MARK: - Flip Challenge Methods
    func setFlipBot(_ bot: TradingBot) {
        flipBot = bot
        print("🤖 Selected flip bot: \(bot.name)")
    }
    
    func startFlipMode() {
        isFlipModeActive = true
        print("🚀 Flip mode activated with bot: \(flipBot?.name ?? "No bot")")
        
        // Start the flip challenge logic here
        if let bot = flipBot {
            print("💰 Starting flip challenge with \(bot.name)")
            print("🎯 Win Rate: \(bot.displayWinRate)")
            print("⚡ Risk Level: \(bot.riskLevel.rawValue)")
        }
    }
    
    func stopFlipMode() {
        isFlipModeActive = false
        flipBot = nil
        print("🛑 Flip mode deactivated")
    }
    
    var winRate: Double {
        guard totalTrades > 0 else { return 0 }
        return Double(winningTrades) / Double(totalTrades)
    }
    
    var formattedWinRate: String {
        return String(format: "%.1f%%", winRate * 100)
    }
    
    var formattedTotalProfit: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: totalProfit)) ?? "$0"
    }
    
    private func loadMockData() {
        // Create sample trades data
        recentTrades = [
            PlaybookTrade(
                symbol: "EURUSD",
                direction: .buy,
                entryPrice: 1.0850,
                exitPrice: 1.0920,
                stopLoss: 1.0800,
                takeProfit: 1.0950,
                lotSize: 1.0,
                pnl: 700.0,
                rMultiple: 1.4,
                result: .win,
                grade: .elite,
                setupDescription: "Perfect bullish breakout with volume confirmation",
                emotionalState: "Calm and focused",
                emotionalRating: 5
            ),
            PlaybookTrade(
                symbol: "GBPUSD",
                direction: .sell,
                entryPrice: 1.2650,
                exitPrice: 1.2580,
                stopLoss: 1.2700,
                takeProfit: 1.2550,
                lotSize: 0.5,
                pnl: 350.0,
                rMultiple: 1.4,
                result: .win,
                grade: .good,
                setupDescription: "Clean bearish rejection at resistance",
                emotionalState: "Confident",
                emotionalRating: 4
            ),
            PlaybookTrade(
                symbol: "USDJPY",
                direction: .buy,
                entryPrice: 148.20,
                exitPrice: 147.80,
                stopLoss: 147.70,
                takeProfit: 149.00,
                lotSize: 1.0,
                pnl: -400.0,
                rMultiple: -0.8,
                result: .loss,
                grade: .average,
                setupDescription: "Failed breakout, stopped out quickly",
                emotionalState: "Slightly frustrated but controlled",
                emotionalRating: 3
            ),
            PlaybookTrade(
                symbol: "GOLD",
                direction: .buy,
                entryPrice: 2025.50,
                exitPrice: 2045.80,
                stopLoss: 2015.00,
                takeProfit: 2055.00,
                lotSize: 0.1,
                pnl: 203.0,
                rMultiple: 1.9,
                result: .win,
                grade: .elite,
                setupDescription: "Perfect golden ratio retracement entry",
                emotionalState: "Zen-like calm",
                emotionalRating: 5
            ),
            PlaybookTrade(
                symbol: "BTCUSD",
                direction: .sell,
                entryPrice: 43500.0,
                exitPrice: 42800.0,
                stopLoss: 44000.0,
                takeProfit: 42000.0,
                lotSize: 0.01,
                pnl: 70.0,
                rMultiple: 1.4,
                result: .win,
                grade: .good,
                setupDescription: "Crypto rejection at key resistance",
                emotionalState: "Focused and patient",
                emotionalRating: 4
            ),
            PlaybookTrade(
                symbol: "AUDUSD",
                direction: .buy,
                entryPrice: 0.6750,
                exitPrice: nil,
                stopLoss: 0.6700,
                takeProfit: 0.6850,
                lotSize: 1.0,
                pnl: 0.0,
                rMultiple: 0.0,
                result: .running,
                grade: .good,
                setupDescription: "Strong bullish momentum breakout",
                emotionalState: "Confident and patient",
                emotionalRating: 4
            )
        ]
        
        totalTrades = recentTrades.count
        winningTrades = recentTrades.filter { $0.result == .win }.count
        losingTrades = recentTrades.filter { $0.result == .loss }.count
        totalProfit = recentTrades.reduce(0) { $0 + $1.pnl }
    }
    
    // MARK: - Additional Computed Properties
    
    var averageRMultiple: Double {
        let completedTrades = recentTrades.filter { $0.result != .running }
        guard !completedTrades.isEmpty else { return 0 }
        return completedTrades.reduce(0) { $0 + $1.rMultiple } / Double(completedTrades.count)
    }
    
    var formattedAverageR: String {
        let sign = averageRMultiple >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", averageRMultiple))R"
    }
    
    var profitFactor: Double {
        let winningTrades = recentTrades.filter { $0.result == .win }
        let losingTrades = recentTrades.filter { $0.result == .loss }
        
        let grossProfit = winningTrades.reduce(0) { $0 + $1.pnl }
        let grossLoss = abs(losingTrades.reduce(0) { $0 + $1.pnl })
        
        return grossLoss > 0 ? grossProfit / grossLoss : (grossProfit > 0 ? Double.infinity : 0)
    }
    
    var formattedProfitFactor: String {
        if profitFactor == Double.infinity {
            return "∞"
        }
        return String(format: "%.2f", profitFactor)
    }
    
    var eliteTradesCount: Int {
        return recentTrades.filter { $0.grade == .elite }.count
    }
    
    var averageEmotionalRating: Double {
        guard !recentTrades.isEmpty else { return 0 }
        return recentTrades.reduce(0) { $0 + Double($1.emotionalRating) } / Double(recentTrades.count)
    }
    
    var psychologyGrade: String {
        switch averageEmotionalRating {
        case 4.5...: return "🧘‍♂️ Zen Master"
        case 4.0..<4.5: return "😌 Well Controlled"
        case 3.5..<4.0: return "🙂 Good Control"
        case 3.0..<3.5: return "😐 Average Control"
        case 2.5..<3.0: return "😬 Needs Work"
        default: return "😤 High Stress"
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        Text("📊 Trading Dashboard")
            .font(DesignSystem.Typography.largeTitle)
            .goldText()
        
        VStack(spacing: 16) {
            Text("Mock Trading Data Loaded")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(.secondary)
            
            let viewModel = TradingViewModel()
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Total Trades")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(.secondary)
                    Text("\(viewModel.totalTrades)")
                        .font(DesignSystem.Typography.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Win Rate")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(.secondary)
                    Text(viewModel.formattedWinRate)
                        .font(DesignSystem.Typography.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Total P&L")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(.secondary)
                    Text(viewModel.formattedTotalProfit)
                        .font(DesignSystem.Typography.title2)
                        .fontWeight(.bold)
                        .profitLossText(viewModel.totalProfit >= 0)
                }
            }
            .solarCard()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Performance Metrics")
                    .font(DesignSystem.Typography.headline)
                    .goldText()
                
                HStack {
                    Text("Avg R-Multiple: \(viewModel.formattedAverageR)")
                    Spacer()
                    Text("Profit Factor: \(viewModel.formattedProfitFactor)")
                }
                .font(DesignSystem.Typography.body)
                .foregroundColor(.secondary)
                
                HStack {
                    Text("Elite Trades: \(viewModel.eliteTradesCount)")
                    Spacer()
                    Text(viewModel.psychologyGrade)
                }
                .font(DesignSystem.Typography.body)
                .foregroundColor(.secondary)
            }
            .solarCard()
        }
    }
    .padding()
    .background(.ultraThinMaterial)
}
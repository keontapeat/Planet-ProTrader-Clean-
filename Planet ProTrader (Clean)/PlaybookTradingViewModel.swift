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
    
    // Mock data for playbook
    @Published var recentTrades: [PlaybookTrade] = []
    
    init() {
        loadMockData()
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
        // Use the existing sample trades from PlaybookTrade
        recentTrades = PlaybookTrade.sampleTrades
        
        totalTrades = recentTrades.count
        winningTrades = recentTrades.filter { $0.isWinner }.count
        losingTrades = recentTrades.filter { !$0.isWinner }.count
        totalProfit = recentTrades.reduce(0) { $0 + $1.pnl }
    }
}

#Preview {
    VStack {
        Text("📊 Trading View Model")
            .font(DesignSystem.Typography.largeTitle)
            .goldText()
        
        Text("Mock data loaded for Playbook")
            .foregroundColor(.secondary)
    }
    .padding()
}
//
//  TradingStatsView.swift
//  Planet ProTrader - Enhanced Trading Statistics
//
//  Real-time Account Statistics
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

struct TradingStatsView: View {
    @StateObject private var priceManager = PriceStreamManager.shared
    @EnvironmentObject var tradingManager: TradingManager
    
    var body: some View {
        HStack(spacing: 4) {
            // Balance - Real-time
            TradeLockerStatCard(
                title: "Balance",
                value: tradingManager.formattedBalance,
                color: .blue
            )
            
            // Equity - Dynamic calculation
            TradeLockerStatCard(
                title: "Equity",
                value: tradingManager.formattedEquity,
                color: tradingManager.isEquityPositive ? .green : .red
            )
            
            // P&L - Live updates
            TradeLockerStatCard(
                title: "P&L",
                value: tradingManager.formattedPnL,
                color: tradingManager.isPnLPositive ? .green : .red
            )
            
            // Margin - Dynamic
            TradeLockerStatCard(
                title: "Margin",
                value: tradingManager.formattedMarginLevel,
                color: marginColor
            )
        }
    }
    
    private var marginColor: Color {
        let marginLevel = tradingManager.marginLevel
        if marginLevel < 50 { return .red }
        if marginLevel < 100 { return .orange }
        return .green
    }
}

#Preview {
    TradingStatsView()
        .environmentObject(TradingManager.shared)
        .preferredColorScheme(.dark)
}
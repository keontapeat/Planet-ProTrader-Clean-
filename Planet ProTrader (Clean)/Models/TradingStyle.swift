//
//  TradingStyle.swift
//  Planet ProTrader (Clean)
//
//  Trading style classifications for bots
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI
import Foundation

enum TradingStyle: String, CaseIterable, Codable {
    case scalping = "Scalping"
    case dayTrading = "Day Trading"
    case swingTrading = "Swing Trading"
    case positionTrading = "Position Trading"
    case algorithmic = "Algorithmic"
    case highFrequency = "High Frequency"
    case arbitrage = "Arbitrage"
    case momentum = "Momentum"
    case meanReversion = "Mean Reversion"
    case breakout = "Breakout"
    case contrarian = "Contrarian"
    case gridTrading = "Grid Trading"
    case newsTrading = "News Trading"
    case socialTrading = "Social Trading"
    
    var displayName: String {
        return rawValue
    }
    
    var color: Color {
        switch self {
        case .scalping: return .red
        case .dayTrading: return .orange
        case .swingTrading: return .blue
        case .positionTrading: return .green
        case .algorithmic: return .purple
        case .highFrequency: return .pink
        case .arbitrage: return .cyan
        case .momentum: return .yellow
        case .meanReversion: return .indigo
        case .breakout: return .mint
        case .contrarian: return .brown
        case .gridTrading: return .gray
        case .newsTrading: return .teal
        case .socialTrading: return .secondary
        }
    }
    
    var icon: String {
        switch self {
        case .scalping: return "timer"
        case .dayTrading: return "sun.max"
        case .swingTrading: return "arrow.up.arrow.down"
        case .positionTrading: return "chart.line.uptrend.xyaxis"
        case .algorithmic: return "cpu"
        case .highFrequency: return "bolt"
        case .arbitrage: return "arrow.triangle.2.circlepath"
        case .momentum: return "arrow.up.right"
        case .meanReversion: return "arrow.clockwise"
        case .breakout: return "arrow.up.circle"
        case .contrarian: return "arrow.turn.up.left"
        case .gridTrading: return "grid"
        case .newsTrading: return "newspaper"
        case .socialTrading: return "person.2"
        }
    }
    
    var description: String {
        switch self {
        case .scalping: return "Quick trades for small profits"
        case .dayTrading: return "Trades within market hours"
        case .swingTrading: return "Holds positions for days/weeks"
        case .positionTrading: return "Long-term strategic positions"
        case .algorithmic: return "Automated rule-based trading"
        case .highFrequency: return "Ultra-fast automated trading"
        case .arbitrage: return "Exploits price differences"
        case .momentum: return "Follows trending movements"
        case .meanReversion: return "Trades against extremes"
        case .breakout: return "Trades price breakouts"
        case .contrarian: return "Trades against crowd sentiment"
        case .gridTrading: return "Automated buy/sell grids"
        case .newsTrading: return "Trades on news events"
        case .socialTrading: return "Follows social signals"
        }
    }
    
    var riskLevel: RiskLevel {
        switch self {
        case .scalping, .highFrequency, .newsTrading: return .high
        case .dayTrading, .momentum, .breakout, .arbitrage: return .medium
        case .swingTrading, .algorithmic, .gridTrading: return .mediumLow
        case .positionTrading, .meanReversion, .contrarian, .socialTrading: return .low
        }
    }
    
    var timeFrame: String {
        switch self {
        case .scalping, .highFrequency: return "Seconds to Minutes"
        case .dayTrading, .newsTrading: return "Minutes to Hours"
        case .swingTrading, .momentum, .breakout: return "Days to Weeks"
        case .positionTrading, .meanReversion: return "Weeks to Months"
        case .algorithmic, .arbitrage, .contrarian: return "Variable"
        case .gridTrading, .socialTrading: return "Hours to Days"
        }
    }
}

enum RiskLevel: String, CaseIterable, Codable {
    case low = "Low"
    case mediumLow = "Medium-Low"
    case medium = "Medium"
    case high = "High"
    
    var color: Color {
        switch self {
        case .low: return .green
        case .mediumLow: return .yellow
        case .medium: return .orange
        case .high: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .low: return "shield.fill"
        case .mediumLow: return "shield.lefthalf.filled"
        case .medium: return "exclamationmark.shield.fill"
        case .high: return "flame.fill"
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("🎯 Trading Styles")
            .font(.title)
            .fontWeight(.bold)
        
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(TradingStyle.allCases, id: \.self) { style in
                    VStack(spacing: 8) {
                        Image(systemName: style.icon)
                            .font(.title2)
                            .foregroundColor(style.color)
                        
                        Text(style.displayName)
                            .font(.caption)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text(style.description)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                        
                        HStack {
                            Image(systemName: style.riskLevel.icon)
                                .font(.caption2)
                                .foregroundColor(style.riskLevel.color)
                            
                            Text(style.riskLevel.rawValue)
                                .font(.caption2)
                                .foregroundColor(style.riskLevel.color)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .frame(height: 120)
                }
            }
            .padding()
        }
    }
}
//
//  CoreTypes.swift
//  Planet ProTrader - Clean Foundation
//
//  Single Source of Truth for All Types
//  Created by AI Assistant on 1/25/25.
//

import Foundation
import SwiftUI

// MARK: - Core Trading Types
enum TradeDirection: String, CaseIterable, Codable {
    case buy = "BUY"
    case sell = "SELL"
    
    var color: Color {
        switch self {
        case .buy: return DesignSystem.tradingGreen
        case .sell: return DesignSystem.tradingRed
        }
    }
    
    var icon: String {
        switch self {
        case .buy: return "arrow.up.circle.fill"
        case .sell: return "arrow.down.circle.fill"
        }
    }
}

enum TradeStatus: String, CaseIterable, Codable {
    case open = "Open"
    case closed = "Closed"
    case pending = "Pending"
    case cancelled = "Cancelled"
    
    var color: Color {
        switch self {
        case .open: return .blue
        case .closed: return .gray
        case .pending: return .orange
        case .cancelled: return .red
        }
    }
}

enum RiskLevel: String, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .red
        }
    }
}

enum BotStatus: String, CaseIterable, Codable {
    case active = "Active"
    case inactive = "Inactive"
    case training = "Training"
    case error = "Error"
    
    var color: Color {
        switch self {
        case .active: return .green
        case .inactive: return .gray
        case .training: return .blue
        case .error: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .active: return "play.circle.fill"
        case .inactive: return "pause.circle.fill"
        case .training: return "brain.head.profile"
        case .error: return "exclamationmark.triangle.fill"
        }
    }
}

// MARK: - Trading Bot Model
struct TradingBot: Identifiable, Codable, Hashable {
    let id = UUID()
    let name: String
    let description: String
    let winRate: Double
    let profitability: Double
    let riskLevel: RiskLevel
    let status: BotStatus
    let icon: String
    let totalTrades: Int
    let successfulTrades: Int
    let averageReturn: Double
    let maxDrawdown: Double
    let createdAt: Date
    
    var isActive: Bool { status == .active }
    var profitColor: Color { profitability >= 0 ? .green : .red }
    
    var displayWinRate: String {
        String(format: "%.1f%%", winRate)
    }
    
    var displayProfitability: String {
        let sign = profitability >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", profitability))%"
    }
    
    // MARK: - Sample Bots
    static let sampleBots: [TradingBot] = [
        TradingBot(
            name: "Golden Eagle",
            description: "Advanced gold trading AI with 94% accuracy",
            winRate: 94.2,
            profitability: 342.5,
            riskLevel: .medium,
            status: .active,
            icon: "crown.fill",
            totalTrades: 1250,
            successfulTrades: 1178,
            averageReturn: 2.8,
            maxDrawdown: 8.5,
            createdAt: Date().addingTimeInterval(-86400 * 30)
        ),
        TradingBot(
            name: "Silver Hawk",
            description: "Precision scalping bot for quick profits",
            winRate: 87.8,
            profitability: 156.3,
            riskLevel: .low,
            status: .active,
            icon: "bolt.fill",
            totalTrades: 2850,
            successfulTrades: 2503,
            averageReturn: 1.2,
            maxDrawdown: 4.2,
            createdAt: Date().addingTimeInterval(-86400 * 15)
        ),
        TradingBot(
            name: "Bronze Scout",
            description: "Conservative long-term trading strategy",
            winRate: 72.5,
            profitability: 89.4,
            riskLevel: .low,
            status: .inactive,
            icon: "shield.fill",
            totalTrades: 650,
            successfulTrades: 471,
            averageReturn: 3.5,
            maxDrawdown: 12.1,
            createdAt: Date().addingTimeInterval(-86400 * 60)
        )
    ]
}

// MARK: - Trading Account
struct TradingAccount: Identifiable, Codable {
    let id = UUID()
    let name: String
    let broker: String
    let accountNumber: String
    var balance: Double
    var equity: Double
    var margin: Double
    var freeMargin: Double
    let isLive: Bool
    let currency: String
    let lastUpdate: Date
    
    var profitLoss: Double { equity - balance }
    var marginLevel: Double { margin > 0 ? (equity / margin) * 100 : 0 }
    
    var formattedBalance: String {
        String(format: "%.2f %@", balance, currency)
    }
    
    var formattedProfitLoss: String {
        let sign = profitLoss >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", profitLoss)) \(currency)"
    }
    
    var statusColor: Color {
        if marginLevel < 100 { return .red }
        else if marginLevel < 200 { return .orange }
        else { return .green }
    }
}

// MARK: - Trading Signal
struct TradingSignal: Identifiable, Codable {
    let id = UUID()
    let symbol: String
    let direction: TradeDirection
    let entryPrice: Double
    let stopLoss: Double
    let takeProfit: Double
    let confidence: Double
    let timeframe: String
    let timestamp: Date
    let source: String
    
    var riskRewardRatio: Double {
        let risk = abs(entryPrice - stopLoss)
        let reward = abs(takeProfit - entryPrice)
        return risk > 0 ? reward / risk : 0
    }
    
    var formattedEntryPrice: String {
        String(format: "$%.2f", entryPrice)
    }
    
    var formattedStopLoss: String {
        String(format: "$%.2f", stopLoss)
    }
    
    var formattedTakeProfit: String {
        String(format: "$%.2f", takeProfit)
    }
    
    var confidenceColor: Color {
        if confidence >= 0.8 { return .green }
        else if confidence >= 0.6 { return .orange }
        else { return .red }
    }
}

// MARK: - Market Data
struct MarketData: Identifiable, Codable {
    let id = UUID()
    let symbol: String
    let currentPrice: Double
    let change: Double
    let changePercent: Double
    let volume: Double
    let timestamp: Date
    
    var isPositive: Bool { change >= 0 }
    
    var formattedPrice: String {
        String(format: "$%.2f", currentPrice)
    }
    
    var formattedChange: String {
        let sign = change >= 0 ? "+" : ""
        return "\(sign)$\(String(format: "%.2f", change))"
    }
    
    var formattedChangePercent: String {
        let sign = changePercent >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", changePercent))%"
    }
}

// MARK: - Sample Data
struct SampleData {
    static let goldPrice = MarketData(
        symbol: "XAUUSD",
        currentPrice: 2374.85,
        change: 12.45,
        changePercent: 0.52,
        volume: 125_000,
        timestamp: Date()
    )
    
    static let demoAccount = TradingAccount(
        name: "Demo Account",
        broker: "MT5 Demo",
        accountNumber: "123456789",
        balance: 10_000.00,
        equity: 10_425.50,
        margin: 234.50,
        freeMargin: 10_191.00,
        isLive: false,
        currency: "USD",
        lastUpdate: Date()
    )
    
    static let liveAccount = TradingAccount(
        name: "Live Account", 
        broker: "Coinexx",
        accountNumber: "987654321",
        balance: 5_000.00,
        equity: 5_287.30,
        margin: 125.80,
        freeMargin: 5_161.50,
        isLive: true,
        currency: "USD",
        lastUpdate: Date()
    )
    
    static let sampleSignal = TradingSignal(
        symbol: "XAUUSD",
        direction: .buy,
        entryPrice: 2374.50,
        stopLoss: 2364.00,
        takeProfit: 2395.00,
        confidence: 0.87,
        timeframe: "15M",
        timestamp: Date(),
        source: "Golden Eagle AI"
    )
}
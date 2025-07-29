//
//  TradingModels.swift
//  Planet ProTrader - Missing Trading Models
//
//  Complete trading data models for dashboard functionality
//  Created by AI Assistant on 1/25/25.
//

import Foundation
import SwiftUI

// MARK: - Trading Stats Model
class TradingStats: ObservableObject, Codable {
    @Published var dailyPnL: Double = 0.0
    @Published var totalPnL: Double = 0.0
    @Published var totalTrades: Int = 0
    @Published var winningTrades: Int = 0
    @Published var winRate: Double = 0.0
    @Published var hasEverTraded: Bool = false
    @Published var recentTrades: [TradeActivity] = []
    @Published var lastTradingDay: Date?
    
    private static let userDefaultsKey = "TradingStats"
    
    enum CodingKeys: String, CodingKey {
        case dailyPnL, totalPnL, totalTrades, winningTrades, winRate, hasEverTraded, recentTrades, lastTradingDay
    }
    
    init() {
        checkNewTradingDay()
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        dailyPnL = try container.decode(Double.self, forKey: .dailyPnL)
        totalPnL = try container.decode(Double.self, forKey: .totalPnL)
        totalTrades = try container.decode(Int.self, forKey: .totalTrades)
        winningTrades = try container.decode(Int.self, forKey: .winningTrades)
        winRate = try container.decode(Double.self, forKey: .winRate)
        hasEverTraded = try container.decode(Bool.self, forKey: .hasEverTraded)
        recentTrades = try container.decode([TradeActivity].self, forKey: .recentTrades)
        lastTradingDay = try container.decodeIfPresent(Date.self, forKey: .lastTradingDay)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(dailyPnL, forKey: .dailyPnL)
        try container.encode(totalPnL, forKey: .totalPnL)
        try container.encode(totalTrades, forKey: .totalTrades)
        try container.encode(winningTrades, forKey: .winningTrades)
        try container.encode(winRate, forKey: .winRate)
        try container.encode(hasEverTraded, forKey: .hasEverTraded)
        try container.encode(recentTrades, forKey: .recentTrades)
        try container.encode(lastTradingDay, forKey: .lastTradingDay)
    }
    
    static func load() -> TradingStats {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let stats = try? JSONDecoder().decode(TradingStats.self, from: data) {
            return stats
        }
        return TradingStats()
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: Self.userDefaultsKey)
        }
    }
    
    func checkNewTradingDay() {
        let calendar = Calendar.current
        let today = Date()
        
        if let lastDay = lastTradingDay,
           !calendar.isDate(lastDay, inSameDayAs: today) {
            // New trading day - reset daily stats
            dailyPnL = 0.0
            lastTradingDay = today
            save()
        } else if lastTradingDay == nil {
            lastTradingDay = today
        }
    }
    
    func addTrade(_ trade: TradeActivity) {
        checkNewTradingDay()
        
        recentTrades.insert(trade, at: 0)
        if recentTrades.count > 50 {
            recentTrades.removeLast()
        }
        
        dailyPnL += trade.profit
        totalPnL += trade.profit
        totalTrades += 1
        
        if trade.profit > 0 {
            winningTrades += 1
        }
        
        if totalTrades > 0 {
            winRate = (Double(winningTrades) / Double(totalTrades)) * 100
        }
        
        hasEverTraded = true
        save()
    }
    
    func reset() {
        dailyPnL = 0.0
        totalPnL = 0.0
        totalTrades = 0
        winningTrades = 0
        winRate = 0.0
        hasEverTraded = false
        recentTrades.removeAll()
        lastTradingDay = nil
        save()
    }
    
    var formattedDailyPnL: String {
        let sign = dailyPnL >= 0 ? "+" : ""
        return "\(sign)$\(String(format: "%.2f", dailyPnL))"
    }
    
    var formattedTotalPnL: String {
        let sign = totalPnL >= 0 ? "+" : ""
        return "\(sign)$\(String(format: "%.2f", totalPnL))"
    }
    
    var formattedWinRate: String {
        return "\(String(format: "%.1f", winRate))%"
    }
    
    var dailyPnLColor: Color {
        if !hasEverTraded { return .gray }
        return dailyPnL >= 0 ? .green : .red
    }
    
    var totalPnLColor: Color {
        if !hasEverTraded { return .gray }
        return totalPnL >= 0 ? .green : .red
    }
}

// MARK: - Trade Activity Model
struct TradeActivity: Identifiable, Codable, Hashable {
    let id: UUID
    let botName: String
    let symbol: String
    let action: String
    let price: Double
    let profit: Double
    let timestamp: Date
    
    init(id: UUID = UUID(), botName: String, symbol: String, action: String, price: Double, profit: Double, timestamp: Date = Date()) {
        self.id = id
        self.botName = botName
        self.symbol = symbol
        self.action = action
        self.price = price
        self.profit = profit
        self.timestamp = timestamp
    }
    
    var formattedPrice: String {
        String(format: "$%.2f", price)
    }
    
    var formattedProfit: String {
        let sign = profit >= 0 ? "+" : ""
        return "\(sign)$\(String(format: "%.2f", profit))"
    }
    
    var profitColor: Color {
        profit >= 0 ? .green : .red
    }
    
    var actionColor: Color {
        action.uppercased() == "BUY" ? .green : .red
    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
    
    // Sample data for previews
    static let sampleTrades: [TradeActivity] = [
        TradeActivity(
            botName: "Golden Eagle AI",
            symbol: "XAUUSD",
            action: "BUY",
            price: 2374.50,
            profit: 125.75,
            timestamp: Date().addingTimeInterval(-300)
        ),
        TradeActivity(
            botName: "Silver Hawk",
            symbol: "EURUSD",
            action: "SELL",
            price: 1.0856,
            profit: -45.20,
            timestamp: Date().addingTimeInterval(-600)
        ),
        TradeActivity(
            botName: "Bronze Scout",
            symbol: "GBPUSD",
            action: "BUY",
            price: 1.2745,
            profit: 78.90,
            timestamp: Date().addingTimeInterval(-900)
        ),
        TradeActivity(
            botName: "Platinum Elite",
            symbol: "USDJPY",
            action: "SELL",
            price: 148.25,
            profit: 156.30,
            timestamp: Date().addingTimeInterval(-1200)
        ),
        TradeActivity(
            botName: "Diamond Master",
            symbol: "AUDUSD",
            action: "BUY",
            price: 0.6745,
            profit: -32.45,
            timestamp: Date().addingTimeInterval(-1500)
        )
    ]
}

// MARK: - Additional Trading Models

struct TradingPair: Identifiable, Codable, Hashable {
    let id = UUID()
    let symbol: String
    let name: String
    let currentPrice: Double
    let change: Double
    let changePercent: Double
    let volume: Double
    let isActive: Bool
    
    var formattedPrice: String {
        if symbol.contains("JPY") {
            return String(format: "%.3f", currentPrice)
        } else if symbol.contains("XAU") {
            return String(format: "$%.2f", currentPrice)
        } else {
            return String(format: "%.5f", currentPrice)
        }
    }
    
    var formattedChange: String {
        let sign = change >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", change))"
    }
    
    var formattedChangePercent: String {
        let sign = changePercent >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", changePercent))%"
    }
    
    var changeColor: Color {
        change >= 0 ? .green : .red
    }
    
    static let samplePairs: [TradingPair] = [
        TradingPair(symbol: "XAUUSD", name: "Gold", currentPrice: 2374.85, change: 12.45, changePercent: 0.52, volume: 125000, isActive: true),
        TradingPair(symbol: "EURUSD", name: "Euro", currentPrice: 1.0856, change: -0.0012, changePercent: -0.11, volume: 89000, isActive: true),
        TradingPair(symbol: "GBPUSD", name: "Pound", currentPrice: 1.2745, change: 0.0034, changePercent: 0.27, volume: 67000, isActive: true),
        TradingPair(symbol: "USDJPY", name: "Yen", currentPrice: 148.25, change: -0.85, changePercent: -0.57, volume: 112000, isActive: true),
        TradingPair(symbol: "AUDUSD", name: "Aussie", currentPrice: 0.6745, change: 0.0023, changePercent: 0.34, volume: 45000, isActive: false)
    ]
}

struct TradingSession: Identifiable, Codable {
    let id = UUID()
    let name: String
    let startTime: Date
    let endTime: Date
    let totalTrades: Int
    let totalPnL: Double
    let winRate: Double
    let bestTrade: Double
    let worstTrade: Double
    
    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }
    
    var formattedDuration: String {
        let hours = Int(duration / 3600)
        let minutes = Int((duration.truncatingRemainder(dividingBy: 3600)) / 60)
        return "\(hours)h \(minutes)m"
    }
    
    var formattedPnL: String {
        let sign = totalPnL >= 0 ? "+" : ""
        return "\(sign)$\(String(format: "%.2f", totalPnL))"
    }
    
    var sessionGrade: String {
        if winRate >= 90 && totalPnL > 200 { return "A+" }
        else if winRate >= 80 && totalPnL > 100 { return "A" }
        else if winRate >= 70 && totalPnL > 50 { return "B+" }
        else if winRate >= 60 && totalPnL > 0 { return "B" }
        else if winRate >= 50 { return "C" }
        else { return "D" }
    }
    
    var gradeColor: Color {
        switch sessionGrade {
        case "A+", "A": return .green
        case "B+", "B": return .blue
        case "C": return .orange
        default: return .red
        }
    }
}

// MARK: - Portfolio Performance Model
struct PortfolioPerformance: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let totalValue: Double
    let dailyChange: Double
    let trades: Int
    let winRate: Double
    
    var formattedValue: String {
        String(format: "$%.2f", totalValue)
    }
    
    var formattedChange: String {
        let sign = dailyChange >= 0 ? "+" : ""
        return "\(sign)$\(String(format: "%.2f", dailyChange))"
    }
    
    var changePercent: Double {
        let previousValue = totalValue - dailyChange
        return previousValue > 0 ? (dailyChange / previousValue) * 100 : 0
    }
    
    var formattedChangePercent: String {
        let sign = changePercent >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", changePercent))%"
    }
    
    var performanceColor: Color {
        dailyChange >= 0 ? .green : .red
    }
}

// MARK: - Risk Metrics Model
struct RiskMetrics: Identifiable, Codable, Equatable, Hashable {
    let id = UUID()
    let maxDrawdown: Double
    let currentDrawdown: Double
    let sharpeRatio: Double
    let sortinoRatio: Double
    let volatility: Double
    let valueAtRisk: Double
    let riskLevel: RiskLevel
    
    var formattedMaxDrawdown: String {
        String(format: "%.2f%%", maxDrawdown * 100)
    }
    
    var formattedCurrentDrawdown: String {
        String(format: "%.2f%%", currentDrawdown * 100)
    }
    
    var formattedSharpe: String {
        String(format: "%.2f", sharpeRatio)
    }
    
    var formattedSortino: String {
        String(format: "%.2f", sortinoRatio)
    }
    
    var formattedVolatility: String {
        String(format: "%.2f%%", volatility * 100)
    }
    
    var formattedVaR: String {
        String(format: "$%.2f", valueAtRisk)
    }
    
    var riskScore: Double {
        // Calculate composite risk score (0-100, lower is better)
        let drawdownScore = min(100, currentDrawdown * 100)
        let volatilityScore = min(100, volatility * 50)
        let sharpeScore = max(0, 50 - (sharpeRatio * 10))
        
        return (drawdownScore + volatilityScore + sharpeScore) / 3
    }
    
    var riskGrade: String {
        switch riskScore {
        case 0..<20: return "Excellent"
        case 20..<40: return "Good"
        case 40..<60: return "Moderate"
        case 60..<80: return "High"
        default: return "Critical"
        }
    }
    
    var gradeColor: Color {
        switch riskGrade {
        case "Excellent": return .green
        case "Good": return .blue
        case "Moderate": return .orange
        case "High": return .red
        default: return .purple
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("📊 Trading Models")
            .font(.title.bold())
            .foregroundStyle(.white)
        
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Daily P&L:")
                Spacer()
                Text(TradingStats().formattedDailyPnL)
                    .foregroundColor(.green)
            }
            
            HStack {
                Text("Win Rate:")
                Spacer()
                Text("87.5%")
                    .foregroundColor(.blue)
            }
            
            HStack {
                Text("Total Trades:")
                Spacer()
                Text("245")
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
        
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent Trades")
                .font(.headline)
                .foregroundStyle(.white)
            
            ForEach(TradeActivity.sampleTrades.prefix(3)) { trade in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(trade.symbol)
                            .font(.subheadline.bold())
                            .foregroundStyle(.white)
                        Text(trade.botName)
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(trade.action)
                            .font(.caption.bold())
                            .foregroundColor(trade.actionColor)
                        Text(trade.formattedProfit)
                            .font(.subheadline.bold())
                            .foregroundColor(trade.profitColor)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
    .padding()
    .background(Color.black)
    .preferredColorScheme(.dark)
}
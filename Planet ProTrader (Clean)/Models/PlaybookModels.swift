//
//  PlaybookModels.swift
//  Planet ProTrader (Clean)
//
//  Playbook and Journal Models for Legendary Trading System
//  Created by AI Assistant on 1/25/25.
//

import Foundation
import SwiftUI

// MARK: - Playbook Trade Model
struct PlaybookTrade: Identifiable, Codable, Hashable {
    let id: String
    let symbol: String
    let direction: TradeDirection
    let entryPrice: Double
    let exitPrice: Double?
    let stopLoss: Double
    let takeProfit: Double
    let lotSize: Double
    let pnl: Double
    let rMultiple: Double
    let result: TradeResult
    let grade: TradeGrade
    let setupDescription: String
    let emotionalState: String
    let timestamp: Date
    let emotionalRating: Int // 1-5 scale
    let quantity: Double
    let maxDrawdown: Double
    let holdingPeriod: TimeInterval
    let setup: TradingSetup
    let marketCondition: MarketCondition
    let timeframe: String
    let psychologyNotes: String
    
    enum TradingSetup: String, Codable, CaseIterable {
        case breakout = "Breakout"
        case pullback = "Pullback"
        case reversal = "Reversal"
        case continuation = "Continuation"
        case range = "Range Trading"
        
        var emoji: String {
            switch self {
            case .breakout: return "🚀"
            case .pullback: return "↩️"
            case .reversal: return "🔄"
            case .continuation: return "➡️"
            case .range: return "↔️"
            }
        }
    }
    
    enum MarketCondition: String, Codable, CaseIterable {
        case trending = "Trending"
        case ranging = "Ranging"
        case volatile = "Volatile"
        case quiet = "Quiet"
        
        var color: Color {
            switch self {
            case .trending: return .green
            case .ranging: return .blue
            case .volatile: return .orange
            case .quiet: return .gray
            }
        }
    }
    
    enum TradeDirection: String, Codable, CaseIterable {
        case buy = "Buy"
        case sell = "Sell"
        
        var color: Color {
            switch self {
            case .buy: return .green
            case .sell: return .red
            }
        }
        
        var icon: String {
            switch self {
            case .buy: return "arrow.up.circle.fill"
            case .sell: return "arrow.down.circle.fill"
            }
        }
    }
    
    enum TradeResult: String, Codable, CaseIterable {
        case win = "Win"
        case loss = "Loss"
        case breakeven = "Breakeven"
        case running = "Running"
        
        var color: Color {
            switch self {
            case .win: return .green
            case .loss: return .red
            case .breakeven: return .yellow
            case .running: return .blue
            }
        }
        
        var icon: String {
            switch self {
            case .win: return "checkmark.circle.fill"
            case .loss: return "xmark.circle.fill"
            case .breakeven: return "minus.circle.fill"
            case .running: return "play.circle.fill"
            }
        }
    }
    
    enum TradeGrade: String, Codable, CaseIterable {
        case elite = "Elite"
        case good = "Good"
        case average = "Average"
        case poor = "Poor"
        case all = "All"
        case aPlus = "A+"
        case a = "A"
        case bPlus = "B+"
        case b = "B"
        case c = "C"
        case f = "F"
        
        var color: Color {
            switch self {
            case .elite, .aPlus: return .purple
            case .good, .a: return .green
            case .average, .bPlus, .b: return .yellow
            case .poor, .c: return .orange
            case .all: return .blue
            case .f: return .red
            }
        }
        
        var gradientColors: [Color] {
            switch self {
            case .elite, .aPlus: return [.purple, .pink]
            case .good, .a: return [.green, .mint]
            case .average, .bPlus: return [.yellow, .orange]
            case .b: return [.blue, .cyan]
            case .poor, .c: return [.orange, .red]
            case .all: return [.blue, .purple]
            case .f: return [.red, .pink]
            }
        }
        
        var icon: String {
            switch self {
            case .elite, .aPlus: return "crown.fill"
            case .good, .a: return "star.fill"
            case .average, .bPlus: return "star.circle"
            case .b: return "star.leadinghalf.filled"
            case .poor, .c: return "star.slash"
            case .all: return "star"
            case .f: return "xmark.circle.fill"
            }
        }
        
        var score: Int {
            switch self {
            case .elite, .aPlus: return 5
            case .good, .a: return 4
            case .average, .bPlus: return 3
            case .b: return 2
            case .poor, .c: return 1
            case .all: return 0
            case .f: return -1
            }
        }
        
        var emoji: String {
            switch self {
            case .elite, .aPlus: return "👑"
            case .good, .a: return "⭐"
            case .average, .bPlus: return "📊"
            case .b: return "📈"
            case .poor, .c: return "⚠️"
            case .all: return "📈"
            case .f: return "❌"
            }
        }
    }
    
    // MARK: - Computed Properties
    
    var isRunning: Bool {
        return result == .running
    }
    
    var isProfitable: Bool {
        return pnl > 0
    }
    
    var formattedPnL: String {
        let sign = pnl >= 0 ? "+" : ""
        return "\(sign)$\(String(format: "%.2f", pnl))"
    }
    
    var formattedRMultiple: String {
        let sign = rMultiple >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", rMultiple))R"
    }
    
    var formattedEntryPrice: String {
        return String(format: "$%.2f", entryPrice)
    }
    
    var formattedExitPrice: String {
        if let exit = exitPrice {
            return String(format: "$%.2f", exit)
        }
        return "Running"
    }
    
    var formattedStopPrice: String {
        return String(format: "$%.2f", stopLoss)
    }
    
    var formattedTargetPrice: String {
        return String(format: "$%.2f", takeProfit)
    }
    
    var formattedProfitPercentage: String {
        let percentage = (pnl / (entryPrice * quantity)) * 100
        let sign = percentage >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", percentage))%"
    }
    
    var formattedRiskReward: String {
        return String(format: "1:%.1f", riskRewardRatio)
    }
    
    var strategy: String {
        return setupDescription
    }
    
    var notes: String {
        return emotionalState
    }
    
    var date: Date {
        return timestamp
    }
    
    var rMultipleValue: Double {
        return rMultiple
    }
    
    var riskAmount: Double {
        return abs(entryPrice - stopLoss) * lotSize
    }
    
    var rewardAmount: Double {
        return abs(takeProfit - entryPrice) * lotSize
    }
    
    var riskRewardRatio: Double {
        return riskAmount > 0 ? rewardAmount / riskAmount : 0
    }
    
    var tradeQuality: String {
        switch grade {
        case .elite, .aPlus:
            return "🏆 Elite Execution"
        case .good, .a:
            return "⭐ Good Trade"
        case .average, .bPlus, .b:
            return "📊 Average"
        case .poor, .c:
            return "❌ Poor Quality"
        case .all:
            return "📈 Standard"
        case .f:
            return "🚫 Failed Trade"
        }
    }
    
    var psychologyScore: String {
        switch emotionalRating {
        case 5: return "🧘‍♂️ Perfect Control"
        case 4: return "😌 Good Control"
        case 3: return "😐 Neutral"
        case 2: return "😬 Some Stress"
        case 1: return "😤 High Stress"
        default: return "❓ Unknown"
        }
    }
    
    var tradeDuration: TimeInterval {
        return holdingPeriod
    }
    
    var formattedDuration: String {
        let duration = holdingPeriod
        let hours = Int(duration / 3600)
        let minutes = Int((duration.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    // MARK: - Hashable Conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: PlaybookTrade, rhs: PlaybookTrade) -> Bool {
        return lhs.id == rhs.id
    }
    
    // MARK: - Initialization
    init(
        id: String = UUID().uuidString,
        symbol: String,
        direction: TradeDirection,
        entryPrice: Double,
        exitPrice: Double? = nil,
        stopLoss: Double,
        takeProfit: Double,
        lotSize: Double,
        pnl: Double,
        rMultiple: Double,
        result: TradeResult,
        grade: TradeGrade,
        setupDescription: String,
        emotionalState: String,
        timestamp: Date = Date(),
        emotionalRating: Int,
        quantity: Double = 1.0,
        maxDrawdown: Double = 0.0,
        holdingPeriod: TimeInterval = 3600,
        setup: TradingSetup = .breakout,
        marketCondition: MarketCondition = .trending,
        timeframe: String = "15m",
        psychologyNotes: String = ""
    ) {
        self.id = id
        self.symbol = symbol
        self.direction = direction
        self.entryPrice = entryPrice
        self.exitPrice = exitPrice
        self.stopLoss = stopLoss
        self.takeProfit = takeProfit
        self.lotSize = lotSize
        self.pnl = pnl
        self.rMultiple = rMultiple
        self.result = result
        self.grade = grade
        self.setupDescription = setupDescription
        self.emotionalState = emotionalState
        self.timestamp = timestamp
        self.emotionalRating = max(1, min(5, emotionalRating))
        self.quantity = quantity
        self.maxDrawdown = maxDrawdown
        self.holdingPeriod = holdingPeriod
        self.setup = setup
        self.marketCondition = marketCondition
        self.timeframe = timeframe
        self.psychologyNotes = psychologyNotes
    }
}

// MARK: - Trading Pattern Model
struct TradingPattern: Identifiable, Codable, Equatable {
    let id = UUID()
    let name: String
    let description: String
    let category: PatternCategory
    let successRate: Double
    let averageReturn: Double
    let occurrences: Int
    let riskRewardRatio: Double
    
    enum PatternCategory: String, Codable, CaseIterable {
        case breakout = "Breakout"
        case reversal = "Reversal"
        case continuation = "Continuation"
        case harmonic = "Harmonic"
        
        var emoji: String {
            switch self {
            case .breakout: return "🚀"
            case .reversal: return "🔄"
            case .continuation: return "➡️"
            case .harmonic: return "🎵"
            }
        }
        
        var color: Color {
            switch self {
            case .breakout: return .orange
            case .reversal: return .purple
            case .continuation: return .green
            case .harmonic: return .blue
            }
        }
    }
    
    var formattedSuccessRate: String {
        return String(format: "%.1f%%", successRate * 100)
    }
    
    var formattedAverageReturn: String {
        let sign = averageReturn >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", averageReturn))%"
    }
    
    var formattedRiskReward: String {
        return String(format: "%.1f", riskRewardRatio)
    }
    
    static func == (lhs: TradingPattern, rhs: TradingPattern) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Psychology Insight Model
struct PsychologyInsight: Identifiable, Codable, Equatable {
    let id = UUID()
    let title: String
    let description: String
    let category: InsightCategory
    let severity: Severity
    let timestamp: Date
    let markDouglasQuote: String
    let suggestion: String
    
    enum InsightCategory: String, Codable, CaseIterable {
        case fear = "Fear"
        case greed = "Greed"
        case patience = "Patience"
        case discipline = "Discipline"
        case confidence = "Confidence"
        
        var emoji: String {
            switch self {
            case .fear: return "😰"
            case .greed: return "🤑"
            case .patience: return "⏳"
            case .discipline: return "🎯"
            case .confidence: return "💪"
            }
        }
        
        var color: Color {
            switch self {
            case .fear: return .red
            case .greed: return .orange
            case .patience: return .blue
            case .discipline: return .green
            case .confidence: return .purple
            }
        }
    }
    
    enum Severity: String, Codable, CaseIterable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        case critical = "Critical"
        
        var emoji: String {
            switch self {
            case .low: return "ℹ️"
            case .medium: return "⚠️"
            case .high: return "🔥"
            case .critical: return "🚨"
            }
        }
        
        var color: Color {
            switch self {
            case .low: return .gray
            case .medium: return .yellow
            case .high: return .orange
            case .critical: return .red
            }
        }
    }
    
    static func == (lhs: PsychologyInsight, rhs: PsychologyInsight) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Journal Entry Model
struct JournalEntry: Identifiable, Codable {
    let id: String
    let timestamp: Date
    let type: EntryType
    let title: String
    let content: String
    let emotionalRating: Int
    let markDouglasLesson: String
    
    enum EntryType: String, Codable, CaseIterable {
        case dailyReview = "Daily Review"
        case tradeAnalysis = "Trade Analysis"
        case psychologyNote = "Psychology Note"
        case marketObservation = "Market Observation"
        case learningNote = "Learning Note"
        case goalSetting = "Goal Setting"
        case reflection = "Reflection"
        
        var color: Color {
            switch self {
            case .dailyReview: return .blue
            case .tradeAnalysis: return .green
            case .psychologyNote: return .purple
            case .marketObservation: return .orange
            case .learningNote: return .cyan
            case .goalSetting: return .yellow
            case .reflection: return .pink
            }
        }
        
        var icon: String {
            switch self {
            case .dailyReview: return "calendar.circle.fill"
            case .tradeAnalysis: return "chart.line.uptrend.xyaxis.circle.fill"
            case .psychologyNote: return "brain.head.profile"
            case .marketObservation: return "eye.circle.fill"
            case .learningNote: return "book.circle.fill"
            case .goalSetting: return "target"
            case .reflection: return "lightbulb.circle.fill"
            }
        }
    }
    
    // MARK: - Computed Properties
    
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    var relativeTimestamp: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
    
    var wordCount: Int {
        return content.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }.count
    }
    
    var readingTime: String {
        let wordsPerMinute = 200.0
        let minutes = max(1, Int(ceil(Double(wordCount) / wordsPerMinute)))
        return "\(minutes) min read"
    }
    
    var moodDescription: String {
        switch emotionalRating {
        case 5: return "Excellent mindset"
        case 4: return "Good mindset"
        case 3: return "Neutral mindset"
        case 2: return "Challenging mindset"
        case 1: return "Difficult mindset"
        default: return "Unknown mindset"
        }
    }
    
    var moodEmoji: String {
        switch emotionalRating {
        case 5: return "😊"
        case 4: return "🙂"
        case 3: return "😐"
        case 2: return "😔"
        case 1: return "😞"
        default: return "❓"
        }
    }
    
    // MARK: - Initialization
    init(
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        type: EntryType,
        title: String,
        content: String,
        emotionalRating: Int,
        markDouglasLesson: String
    ) {
        self.id = id
        self.timestamp = timestamp
        self.type = type
        self.title = title
        self.content = content
        self.emotionalRating = max(1, min(5, emotionalRating))
        self.markDouglasLesson = markDouglasLesson
    }
}

// MARK: - Remote Config Model
struct RemoteConfig: Codable {
    let chat_models: [Model]
}

struct Model: Codable {
    let id: String
    let name: String
}

// MARK: - Playbook Statistics
struct PlaybookStatistics {
    let totalTrades: Int
    let winningTrades: Int
    let losingTrades: Int
    let runningTrades: Int
    let winRate: Double
    let profitFactor: Double
    let averageRMultiple: Double
    let totalPnL: Double
    let eliteTrades: Int
    let averageEmotionalRating: Double
    let bestTrade: PlaybookTrade?
    let worstTrade: PlaybookTrade?
    
    init(trades: [PlaybookTrade]) {
        totalTrades = trades.count
        winningTrades = trades.filter { $0.result == .win }.count
        losingTrades = trades.filter { $0.result == .loss }.count
        runningTrades = trades.filter { $0.result == .running }.count
        
        winRate = totalTrades > 0 ? Double(winningTrades) / Double(totalTrades) : 0.0
        
        let grossProfit = trades.filter { $0.result == .win }.reduce(0.0) { $0 + $1.pnl }
        let grossLoss = abs(trades.filter { $0.result == .loss }.reduce(0.0) { $0 + $1.pnl })
        profitFactor = grossLoss > 0 ? grossProfit / grossLoss : (grossProfit > 0 ? Double.infinity : 0)
        
        averageRMultiple = totalTrades > 0 ? trades.reduce(0.0) { $0 + $1.rMultiple } / Double(totalTrades) : 0.0
        totalPnL = trades.reduce(0.0) { $0 + $1.pnl }
        eliteTrades = trades.filter { $0.grade == .elite }.count
        
        averageEmotionalRating = totalTrades > 0 ? trades.reduce(0.0) { $0 + Double($1.emotionalRating) } / Double(totalTrades) : 0.0
        
        bestTrade = trades.max { $0.pnl < $1.pnl }
        worstTrade = trades.min { $0.pnl < $1.pnl }
    }
    
    var formattedWinRate: String {
        return String(format: "%.1f%%", winRate * 100)
    }
    
    var formattedProfitFactor: String {
        if profitFactor == Double.infinity {
            return "∞"
        }
        return String(format: "%.2f", profitFactor)
    }
    
    var formattedAverageR: String {
        let sign = averageRMultiple >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", averageRMultiple))R"
    }
    
    var formattedTotalPnL: String {
        let sign = totalPnL >= 0 ? "+" : ""
        return "\(sign)$\(String(format: "%.2f", totalPnL))"
    }
    
    var overallGrade: String {
        if winRate >= 0.7 && averageRMultiple >= 1.0 && eliteTrades >= totalTrades / 3 {
            return "🏆 Elite Trader"
        } else if winRate >= 0.6 && averageRMultiple >= 0.5 {
            return "⭐ Skilled Trader"
        } else if winRate >= 0.5 && averageRMultiple >= 0.0 {
            return "📈 Developing Trader"
        } else {
            return "📚 Learning Trader"
        }
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

// MARK: - Extensions
extension Array where Element == PlaybookTrade {
    func winningTrades() -> [PlaybookTrade] {
        return self.filter { $0.result == .win }
    }
    
    func losingTrades() -> [PlaybookTrade] {
        return self.filter { $0.result == .loss }
    }
    
    func runningTrades() -> [PlaybookTrade] {
        return self.filter { $0.result == .running }
    }
    
    func eliteTrades() -> [PlaybookTrade] {
        return self.filter { $0.grade == .elite }
    }
    
    func sortedByDate() -> [PlaybookTrade] {
        return self.sorted { $0.timestamp > $1.timestamp }
    }
    
    func sortedByPnL() -> [PlaybookTrade] {
        return self.sorted { $0.pnl > $1.pnl }
    }
    
    func statistics() -> PlaybookStatistics {
        return PlaybookStatistics(trades: self)
    }
}

extension Array where Element == JournalEntry {
    func sortedByDate() -> [JournalEntry] {
        return self.sorted { $0.timestamp > $1.timestamp }
    }
    
    func entriesOfType(_ type: JournalEntry.EntryType) -> [JournalEntry] {
        return self.filter { $0.type == type }
    }
    
    func recentEntries(days: Int = 7) -> [JournalEntry] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return self.filter { $0.timestamp >= cutoffDate }
    }
    
    func averageEmotionalRating() -> Double {
        guard !isEmpty else { return 0.0 }
        return self.reduce(0.0) { $0 + Double($1.emotionalRating) } / Double(count)
    }
}

// MARK: - Sample Data
extension PlaybookTrade {
    static let sampleTrades: [PlaybookTrade] = [
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
            emotionalRating: 5,
            quantity: 1000,
            maxDrawdown: 50.0,
            holdingPeriod: 3600,
            setup: .breakout,
            marketCondition: .trending,
            timeframe: "15m",
            psychologyNotes: "Maintained perfect discipline throughout the trade"
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
            emotionalRating: 4,
            quantity: 500,
            maxDrawdown: 25.0,
            holdingPeriod: 2700,
            setup: .reversal,
            marketCondition: .trending,
            timeframe: "5m",
            psychologyNotes: "Good emotional control, stuck to the plan"
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
            emotionalRating: 3,
            quantity: 1000,
            maxDrawdown: 400.0,
            holdingPeriod: 1800,
            setup: .breakout,
            marketCondition: .volatile,
            timeframe: "15m",
            psychologyNotes: "Need to be more patient with entries"
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
            emotionalRating: 5,
            quantity: 100,
            maxDrawdown: 0.0,
            holdingPeriod: 4500,
            setup: .pullback,
            marketCondition: .trending,
            timeframe: "1h",
            psychologyNotes: "Perfect execution with no emotional interference"
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
            emotionalRating: 4,
            quantity: 0.01,
            maxDrawdown: 20.0,
            holdingPeriod: 7200,
            setup: .reversal,
            marketCondition: .volatile,
            timeframe: "4h",
            psychologyNotes: "Good patience waiting for the setup"
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
            emotionalRating: 4,
            quantity: 1000,
            maxDrawdown: 0.0,
            holdingPeriod: 0,
            setup: .breakout,
            marketCondition: .trending,
            timeframe: "30m",
            psychologyNotes: "Letting the trade run as planned"
        )
    ]
}

// MARK: - Enhanced PlaybookManager
@MainActor
class PlaybookManager: ObservableObject {
    static let shared = PlaybookManager()
    
    @Published var trades: [PlaybookTrade] = []
    @Published var journalEntries: [JournalEntry] = []
    @Published var tradingPatterns: [TradingPattern] = []
    @Published var psychologyInsights: [PsychologyInsight] = []
    
    // Quantum metrics
    var isQuantumLearning: Bool { Bool.random() }
    var quantumAccuracy: Double { 0.87 + Double.random(in: -0.1...0.1) }
    var tradingPsychologyScore: Double { 0.92 + Double.random(in: -0.05...0.05) }
    var patternRecognitionAccuracy: Double { 0.85 + Double.random(in: -0.1...0.1) }
    var emotionalIntelligenceScore: Double { 0.89 + Double.random(in: -0.05...0.05) }
    var learningRate: Double { 0.76 + Double.random(in: -0.1...0.1) }
    var predictiveModelAccuracy: Double { 0.83 + Double.random(in: -0.1...0.1) }
    
    var allTrades: [PlaybookTrade] { trades }
    var formattedWinRate: String {
        let stats = PlaybookStatistics(trades: trades)
        return stats.formattedWinRate
    }
    
    init() {
        // Load sample data
        trades = PlaybookTrade.sampleTrades
        loadSamplePatterns()
        loadSamplePsychologyInsights()
    }
    
    private func loadSamplePatterns() {
        tradingPatterns = [
            TradingPattern(
                name: "Bull Flag Breakout",
                description: "Strong bullish pattern with volume confirmation",
                category: .breakout,
                successRate: 0.78,
                averageReturn: 2.3,
                occurrences: 23,
                riskRewardRatio: 2.8
            ),
            TradingPattern(
                name: "Double Bottom",
                description: "Classic reversal pattern at support",
                category: .reversal,
                successRate: 0.65,
                averageReturn: 1.8,
                occurrences: 18,
                riskRewardRatio: 2.1
            ),
            TradingPattern(
                name: "Trend Continuation",
                description: "Following the trend after pullback",
                category: .continuation,
                successRate: 0.82,
                averageReturn: 1.9,
                occurrences: 31,
                riskRewardRatio: 2.4
            )
        ]
    }
    
    private func loadSamplePsychologyInsights() {
        psychologyInsights = [
            PsychologyInsight(
                title: "Fear of Missing Out",
                description: "You tend to enter trades hastily when you see price moving without proper confirmation",
                category: .fear,
                severity: .medium,
                timestamp: Date().addingTimeInterval(-86400),
                markDouglasQuote: "The hard reality of trading is that every trade has an uncertain outcome.",
                suggestion: "Wait for complete setup confirmation before entering"
            ),
            PsychologyInsight(
                title: "Profit Taking Too Early",
                description: "You're exiting winning trades 20% earlier than your targets on average",
                category: .greed,
                severity: .high,
                timestamp: Date().addingTimeInterval(-172800),
                markDouglasQuote: "You don't need to know what's going to happen next to make money.",
                suggestion: "Use trailing stops to let winners run longer"
            ),
            PsychologyInsight(
                title: "Excellent Discipline",
                description: "Your recent trades show remarkable emotional control and plan adherence",
                category: .discipline,
                severity: .low,
                timestamp: Date().addingTimeInterval(-259200),
                markDouglasQuote: "Every moment in the market is unique.",
                suggestion: "Continue this excellent discipline - you're trading like a pro"
            )
        ]
    }
    
    func startQuantumMode() async {
        // Initialize quantum mode
    }
    
    func refreshQuantumData() async {
        // Simulate data refresh
        try? await Task.sleep(nanoseconds: 1_000_000_000)
    }
    
    func exportQuantumReport() async {
        // Export functionality
    }
    
    func generateQuantumAIAnalysis() async {
        // AI analysis generation
    }
}

#Preview {
    ZStack {
        DesignSystem.spaceGradient
            .ignoresSafeArea()
        
        VStack(spacing: 20) {
            Image(systemName: "book.fill")
                .font(.system(size: 60))
                .goldText()
            
            Text("📚 Legendary Playbook System")
                .font(DesignSystem.Typography.largeTitle)
                .goldText()
                .multilineTextAlignment(.center)
            
            Text("Elite Trading Journal & Analysis")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(.white)
                .opacity(0.8)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Trade Grades")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(.white)
                            .opacity(0.7)
                        Text("11")
                            .font(DesignSystem.Typography.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .center, spacing: 4) {
                        Text("Journal Types")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(.white)
                            .opacity(0.7)
                        Text("7")
                            .font(DesignSystem.Typography.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Psychology")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(.white)
                            .opacity(0.7)
                        Text("Enhanced")
                            .font(DesignSystem.Typography.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
                .solarCard()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("🏆 Playbook Features")
                        .font(DesignSystem.Typography.headline)
                        .goldText()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("• Complete trade logging and analysis")
                        Text("• Mark Douglas psychology integration")
                        Text("• Elite performance grading system")
                        Text("• Emotional state tracking")
                        Text("• Advanced statistics and insights")
                        Text("• Professional journal system")
                    }
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(.white)
                    .opacity(0.9)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .solarCard()
                
                // Sample Statistics
                let sampleStats = PlaybookTrade.sampleTrades.statistics()
                VStack(alignment: .leading, spacing: 8) {
                    Text("📊 Sample Performance")
                        .font(DesignSystem.Typography.headline)
                        .goldText()
                    
                    HStack {
                        Text("Win Rate: \(sampleStats.formattedWinRate)")
                        Spacer()
                        Text("P&L: \(sampleStats.formattedTotalPnL)")
                            .profitLossText(sampleStats.totalPnL >= 0)
                    }
                    
                    HStack {
                        Text("Avg R: \(sampleStats.formattedAverageR)")
                        Spacer()
                        Text(sampleStats.overallGrade)
                    }
                }
                .font(DesignSystem.Typography.body)
                .foregroundColor(.white)
                .opacity(0.9)
                .solarCard()
            }
        }
        .padding()
    }
}
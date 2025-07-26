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
struct PlaybookTrade: Identifiable, Codable {
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
        
        var color: Color {
            switch self {
            case .elite: return .purple
            case .good: return .green
            case .average: return .yellow
            case .poor: return .red
            case .all: return .blue
            }
        }
        
        var icon: String {
            switch self {
            case .elite: return "crown.fill"
            case .good: return "star.fill"
            case .average: return "star.circle"
            case .poor: return "star.slash"
            case .all: return "star"
            }
        }
        
        var score: Int {
            switch self {
            case .elite: return 5
            case .good: return 4
            case .average: return 3
            case .poor: return 2
            case .all: return 1
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
        case .elite:
            return "🏆 Elite Execution"
        case .good:
            return "⭐ Good Trade"
        case .average:
            return "📊 Average"
        case .poor:
            return "❌ Poor Quality"
        case .all:
            return "📈 Standard"
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
        guard let exit = exitPrice else {
            return Date().timeIntervalSince(timestamp)
        }
        // For completed trades, estimate duration (would be stored in real app)
        return 3600 // 1 hour default
    }
    
    var formattedDuration: String {
        let duration = tradeDuration
        let hours = Int(duration / 3600)
        let minutes = Int((duration.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
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
        emotionalRating: Int
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
    }
}

// MARK: - Journal Entry Model
struct JournalEntry: Identifiable, Codable {
    let id: String
    let timestamp: Date
    let type: EntryType
    let title: String
    let content: String
    let emotionalRating: Int // 1-5 scale
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

#Preview {
    VStack(spacing: 20) {
        Image(systemName: "book.fill")
            .font(.system(size: 60))
            .foregroundColor(.blue)
        
        Text("Legendary Playbook System")
            .font(.largeTitle)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
        
        Text("Elite Trading Journal & Analysis")
            .font(.title3)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
        
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Trade Grades")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("5")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                }
                
                Spacer()
                
                VStack(alignment: .center, spacing: 4) {
                    Text("Journal Types")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("7")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Psychology")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Enhanced")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("📚 Playbook Features")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("• Complete trade logging and analysis")
                    Text("• Mark Douglas psychology integration")
                    Text("• Elite performance grading system")
                    Text("• Emotional state tracking")
                    Text("• Advanced statistics and insights")
                    Text("• Professional journal system")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
        }
    }
    .padding()
}
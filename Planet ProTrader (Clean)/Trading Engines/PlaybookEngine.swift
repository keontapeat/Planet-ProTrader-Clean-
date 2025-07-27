//
//  PlaybookEngine.swift
//  Planet ProTrader
//
//  Created by AI Assistant
//

import SwiftUI
import Foundation
import Combine

@MainActor
class LegendaryPlaybookEngine: ObservableObject {
    @Published var trades: [PlaybookTrade] = []
    @Published var journalEntries: [JournalEntry] = []
    @Published var isAutoLogging = true
    @Published var isLoading = false
    @Published var errorMessage: String?

    init() {
        loadSampleData()
    }

    // MARK: - Computed Statistics (Safe)

    var winRate: Double {
        guard !trades.isEmpty else { return 0.0 }
        let wins = trades.filter { $0.result == .win }.count
        return Double(wins) / Double(trades.count)
    }

    var profitFactor: Double {
        let grossProfit = trades.filter { $0.result == .win }.reduce(0) { $0 + $1.pnl }
        let grossLoss = abs(trades.filter { $0.result == .loss }.reduce(0) { $0 + $1.pnl })
        return grossLoss == 0 ? (grossProfit > 0 ? Double.infinity : 0) : grossProfit / grossLoss
    }

    var averageRMultiple: Double {
        guard !trades.isEmpty else { return 0.0 }
        return trades.reduce(0.0) { $0 + $1.rMultiple } / Double(trades.count)
    }

    var eliteTrades: Int {
        return trades.filter { $0.grade == .elite }.count
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

    var totalPnL: Double {
        return trades.reduce(0) { $0 + $1.pnl }
    }

    var formattedTotalPnL: String {
        let sign = totalPnL >= 0 ? "+" : ""
        return "\(sign)$\(String(format: "%.2f", totalPnL))"
    }

    // MARK: - Trade Management (Safe)

    func addTrade(_ trade: PlaybookTrade) {
        trades.append(trade)

        if isAutoLogging {
            generateJournalEntry(for: trade)
        }

        // Trigger haptic feedback for user confirmation
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }

    func updateTrade(_ trade: PlaybookTrade) {
        guard let index = trades.firstIndex(where: { $0.id == trade.id }) else { return }
        trades[index] = trade
    }

    func deleteTrade(_ trade: PlaybookTrade) {
        trades.removeAll { $0.id == trade.id }
        journalEntries.removeAll { $0.title.contains(trade.symbol) }
    }

    func addJournalEntry(_ entry: JournalEntry) {
        journalEntries.append(entry)
        
        // Sort entries by timestamp (most recent first)
        journalEntries.sort { $0.timestamp > $1.timestamp }
    }

    func updateJournalEntry(_ entry: JournalEntry) {
        guard let index = journalEntries.firstIndex(where: { $0.id == entry.id }) else { return }
        journalEntries[index] = entry
    }

    func deleteJournalEntry(_ entry: JournalEntry) {
        journalEntries.removeAll { $0.id == entry.id }
    }

    // MARK: - Journal Management

    private func generateJournalEntry(for trade: PlaybookTrade) {
        let entry = JournalEntry(
            id: UUID().uuidString,
            timestamp: trade.timestamp,
            type: .tradeAnalysis,
            title: "Auto-Generated: \(trade.symbol) Trade",
            content: generateAutoAnalysis(for: trade),
            emotionalRating: trade.emotionalRating,
            markDouglasLesson: generateMarkDouglasLesson(for: trade)
        )
        journalEntries.append(entry)
    }

    private func generateAutoAnalysis(for trade: PlaybookTrade) -> String {
        let outcome = trade.result == .win ? "successful" : "unsuccessful"
        let rMultipleValue = trade.rMultiple // Already Double, no conversion needed
        
        return """
        Trade Analysis - \(trade.symbol):

        Setup: \(trade.setupDescription)
        Entry: \(String(format: "%.2f", trade.entryPrice))
        Exit: \(trade.exitPrice.map { String(format: "%.2f", $0) } ?? "N/A")
        Result: \(outcome) (\(String(format: "%.1fR", rMultipleValue)))

        What went right: \(trade.result == .win ? "Proper execution of setup" : "Followed risk management rules")
        What could improve: \(generateImprovementSuggestion(for: trade))

        Emotional state: \(trade.emotionalState)
        Grade: \(trade.grade.rawValue)
        Psychology: \(trade.psychologyScore)

        Key Metrics:
        - P&L: \(trade.formattedPnL)
        - R-Multiple: \(trade.formattedRMultiple)
        - Risk/Reward: \(String(format: "%.2f:1", trade.riskRewardRatio))
        - Duration: \(trade.formattedDuration)
        """
    }

    private func generateMarkDouglasLesson(for trade: PlaybookTrade) -> String {
        let lessons = [
            "Every trade outcome is independent - this doesn't predict the next trade",
            "Focus on executing your process, not the outcome",
            "Maintain emotional equilibrium regardless of results",
            "Think in probabilities, not certainties",
            "Trust your edge and execute consistently",
            "The market doesn't owe you anything - accept what it gives",
            "Consistency comes from within, not from the markets",
            "Trade without emotional attachment to outcomes",
            "Your edge is only as good as your ability to execute it",
            "Losses are part of the business - embrace them as costs"
        ]
        // Safe random selection based on trade characteristics
        let index = abs(trade.symbol.hashValue + Int(trade.rMultiple * 100)) % lessons.count
        return lessons[index]
    }

    private func generateImprovementSuggestion(for trade: PlaybookTrade) -> String {
        switch trade.grade {
        case .elite, .aPlus:
            return "Perfect execution - maintain this standard and document what made this trade exceptional"
        case .good, .a:
            return "Good trade - consider minor timing improvements and position sizing optimization"
        case .average, .bPlus, .b:
            return "Consider better entry timing, tighter risk management, and enhanced market structure analysis"
        case .poor, .c:
            return "Review setup criteria, emotional state management, and risk parameters before next entry"
        case .all:
            return "Continue learning and developing skills through consistent practice and review"
        case .f:
            return "Significant improvement needed - focus on risk management and emotional control"
        }
    }

    // MARK: - Analytics and Insights

    func getTradesByTimeframe(days: Int = 30) -> [PlaybookTrade] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return trades.filter { $0.timestamp >= cutoffDate }
    }

    func getTopPerformingSetups(limit: Int = 5) -> [(String, Double, Int)] {
        let setupGroups = Dictionary(grouping: trades.filter { $0.result != .running }) { $0.setupDescription }
        
        return setupGroups.compactMap { (setup, trades) in
            let avgPnL = trades.reduce(0) { $0 + $1.pnl } / Double(trades.count)
            return (setup, avgPnL, trades.count)
        }
        .sorted { $0.1 > $1.1 }
        .prefix(limit)
        .map { $0 }
    }

    func getEmotionalTrends() -> (improving: Bool, averageRating: Double) {
        let recentTrades = getTradesByTimeframe(days: 7)
        let olderTrades = trades.filter { trade in
            let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            let twoWeeksAgo = Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date()
            return trade.timestamp >= twoWeeksAgo && trade.timestamp < weekAgo
        }
        
        let recentAvg = recentTrades.isEmpty ? 0 : recentTrades.reduce(0) { $0 + Double($1.emotionalRating) } / Double(recentTrades.count)
        let olderAvg = olderTrades.isEmpty ? 0 : olderTrades.reduce(0) { $0 + Double($1.emotionalRating) } / Double(olderTrades.count)
        
        return (improving: recentAvg > olderAvg, averageRating: recentAvg)
    }

    // MARK: - Data Loading

    private func loadSampleData() {
        isLoading = true

        // Simulate data loading delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.trades = PlaybookTrade.sampleTrades
            
            self.journalEntries = [
                JournalEntry(
                    id: UUID().uuidString,
                    timestamp: Date(),
                    type: .dailyReview,
                    title: "Daily Review - Excellent Progress",
                    content: """
                    Today I executed high-quality setups with excellent discipline. The Mark Douglas principles are becoming second nature:
                    
                    • Maintained emotional control throughout all trades
                    • Followed my trading plan without deviation
                    • Focused on process rather than outcomes
                    • Accepted losses as part of the business
                    
                    Key achievements:
                    - 3 out of 4 trades were profitable
                    - Average R-multiple of +1.2
                    - Perfect risk management execution
                    - No emotional trading mistakes
                    
                    Areas for continued focus:
                    - Entry timing refinement
                    - Market structure analysis depth
                    - Position sizing optimization
                    """,
                    emotionalRating: 5,
                    markDouglasLesson: "Consistency comes from within, not from the markets"
                ),
                JournalEntry(
                    id: UUID().uuidString,
                    timestamp: Date().addingTimeInterval(-3600),
                    type: .tradeAnalysis,
                    title: "EURUSD Elite Trade Execution",
                    content: """
                    Perfect execution on the London session setup:
                    
                    Setup Analysis:
                    • Clean institutional order flow at key level
                    • Volume confirmation on breakout
                    • Perfect risk/reward ratio of 2.8:1
                    • Entry at optimal price action confluence
                    
                    Execution Quality:
                    • Disciplined entry timing
                    • Proper position sizing
                    • No hesitation or second-guessing
                    • Clean exit at target level
                    
                    This trade represents the standard I'm working to maintain consistently.
                    """,
                    emotionalRating: 5,
                    markDouglasLesson: "Trust your edge and execute consistently"
                ),
                JournalEntry(
                    id: UUID().uuidString,
                    timestamp: Date().addingTimeInterval(-7200),
                    type: .psychologyNote,
                    title: "Learning from Loss - Emotional Control",
                    content: """
                    The USDJPY loss was handled exceptionally well:
                    
                    Psychological Wins:
                    • No revenge trading urges
                    • Accepted the loss immediately
                    • Stuck to predetermined risk levels
                    • Maintained confidence in the system
                    
                    Mark Douglas Principles Applied:
                    • Treated the loss as a business expense
                    • Maintained probabilistic thinking
                    • No emotional attachment to the outcome
                    • Focused on next opportunity
                    
                    This shows significant psychological growth and trading maturity.
                    """,
                    emotionalRating: 4,
                    markDouglasLesson: "Every trade outcome is independent - this doesn't predict the next trade"
                ),
                JournalEntry(
                    id: UUID().uuidString,
                    timestamp: Date().addingTimeInterval(-10800),
                    type: .marketObservation,
                    title: "Gold Market Structure Analysis",
                    content: """
                    Excellent day for gold trading with clear institutional flows:
                    
                    Market Observations:
                    • Strong buying pressure at 2025 support level
                    • Clean rejection at 2055 resistance
                    • Volume confirming directional moves
                    • Institutional order flow very clear
                    
                    Trading Opportunities:
                    • Multiple high-probability setups available
                    • Risk/reward ratios above 2:1 consistently
                    • Clear market structure for easy analysis
                    
                    Perfect conditions for systematic trading approach.
                    """,
                    emotionalRating: 4,
                    markDouglasLesson: "The market provides opportunities - our job is to recognize and execute them"
                )
            ]

            self.isLoading = false
        }
    }

    // MARK: - Export Functionality

    func exportTradesToCSV() -> String {
        let headers = "Date,Symbol,Direction,Entry,Exit,Stop Loss,Take Profit,Lot Size,P&L,R-Multiple,Result,Grade,Setup,Emotional State,Rating"
        
        let csvRows = trades.map { trade in
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            
            return [
                formatter.string(from: trade.timestamp),
                trade.symbol,
                trade.direction.rawValue,
                String(format: "%.2f", trade.entryPrice),
                trade.exitPrice.map { String(format: "%.2f", $0) } ?? "",
                String(format: "%.2f", trade.stopLoss),
                String(format: "%.2f", trade.takeProfit),
                String(format: "%.2f", trade.lotSize),
                String(format: "%.2f", trade.pnl),
                String(format: "%.2f", trade.rMultiple),
                trade.result.rawValue,
                trade.grade.rawValue,
                "\"" + trade.setupDescription + "\"",
                "\"" + trade.emotionalState + "\"",
                String(trade.emotionalRating)
            ].joined(separator: ",")
        }
        
        return ([headers] + csvRows).joined(separator: "\n")
    }

    func exportJournalToText() -> String {
        let sortedEntries = journalEntries.sorted { $0.timestamp > $1.timestamp }
        
        return sortedEntries.map { entry in
            let formatter = DateFormatter()
            formatter.dateStyle = .full
            formatter.timeStyle = .short
            
            return """
            =====================================
            \(entry.title)
            Date: \(formatter.string(from: entry.timestamp))
            Type: \(entry.type.rawValue)
            Emotional Rating: \(entry.emotionalRating)/5 \(entry.moodEmoji)
            
            \(entry.content)
            
            Mark Douglas Lesson:
            "\(entry.markDouglasLesson)"
            =====================================
            
            """
        }.joined(separator: "\n")
    }
}
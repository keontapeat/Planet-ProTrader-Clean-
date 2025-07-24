//
//  PlaybookModels.swift
//  Planet ProTrader (Clean)
//
//  🤯🔥 QUANTUM PLAYBOOK MODELS 🔥🤯
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI
import Foundation

// MARK: - 🚀 PLAYBOOK TRADE MODEL

struct PlaybookTrade: Identifiable, Codable, Equatable {
    let id = UUID()
    let symbol: String
    let strategy: String
    let entryPrice: Double
    let exitPrice: Double
    let quantity: Double
    let pnl: Double
    let grade: TradeGrade
    let date: Date
    let notes: String
    let screenshots: [String]
    let psychologyNotes: String
    let marketCondition: MarketCondition
    let timeframe: String
    let setup: TradingSetup
    let riskRewardRatio: Double
    let maxDrawdown: Double
    let holdingPeriod: TimeInterval
    
    enum TradeGrade: String, CaseIterable, Codable {
        case aPlus = "A+"
        case a = "A"
        case bPlus = "B+"
        case b = "B"
        case c = "C"
        case f = "F"
        
        var color: Color {
            switch self {
            case .aPlus: return DesignSystem.primaryGold
            case .a: return .green
            case .bPlus: return .blue
            case .b: return .orange
            case .c: return .yellow
            case .f: return .red
            }
        }
        
        var emoji: String {
            switch self {
            case .aPlus: return "👑"
            case .a: return "🔥"
            case .bPlus: return "💎"
            case .b: return "⚡"
            case .c: return "⚠️"
            case .f: return "💀"
            }
        }
        
        var gradientColors: [Color] {
            switch self {
            case .aPlus: return [DesignSystem.primaryGold, .yellow, .orange]
            case .a: return [.green, .mint, .cyan]
            case .bPlus: return [.blue, .cyan, .mint]
            case .b: return [.orange, .yellow, .red]
            case .c: return [.yellow, .orange, .red]
            case .f: return [.red, .pink, .purple]
            }
        }
    }
    
    enum MarketCondition: String, CaseIterable, Codable {
        case trending = "Trending"
        case ranging = "Ranging"
        case volatile = "Volatile"
        case breakout = "Breakout"
        case reversal = "Reversal"
        case consolidation = "Consolidation"
        
        var color: Color {
            switch self {
            case .trending: return .green
            case .ranging: return .blue
            case .volatile: return .red
            case .breakout: return DesignSystem.primaryGold
            case .reversal: return .purple
            case .consolidation: return .orange
            }
        }
        
        var emoji: String {
            switch self {
            case .trending: return "📈"
            case .ranging: return "↔️"
            case .volatile: return "⚡"
            case .breakout: return "🚀"
            case .reversal: return "🔄"
            case .consolidation: return "📊"
            }
        }
    }
    
    enum TradingSetup: String, CaseIterable, Codable {
        case breakoutPullback = "Breakout Pullback"
        case supportResistance = "Support/Resistance"
        case trendFollowing = "Trend Following"
        case meanReversion = "Mean Reversion"
        case momentum = "Momentum"
        case scalping = "Scalping"
        case swing = "Swing"
        case newsTrading = "News Trading"
        
        var color: Color {
            switch self {
            case .breakoutPullback: return DesignSystem.primaryGold
            case .supportResistance: return .blue
            case .trendFollowing: return .green
            case .meanReversion: return .purple
            case .momentum: return .orange
            case .scalping: return .red
            case .swing: return .cyan
            case .newsTrading: return .pink
            }
        }
        
        var emoji: String {
            switch self {
            case .breakoutPullback: return "🚀"
            case .supportResistance: return "⚡"
            case .trendFollowing: return "📈"
            case .meanReversion: return "🔄"
            case .momentum: return "⚡"
            case .scalping: return "⚡"
            case .swing: return "🎯"
            case .newsTrading: return "📰"
            }
        }
    }
    
    var formattedPnL: String {
        return String(format: "%+.2f", pnl)
    }
    
    var formattedEntryPrice: String {
        return String(format: "%.4f", entryPrice)
    }
    
    var formattedExitPrice: String {
        return String(format: "%.4f", exitPrice)
    }
    
    var formattedRiskReward: String {
        return String(format: "1:%.1f", riskRewardRatio)
    }
    
    var isWinner: Bool {
        return pnl > 0
    }
    
    var profitPercentage: Double {
        return (pnl / (entryPrice * quantity)) * 100
    }
    
    var formattedProfitPercentage: String {
        return String(format: "%+.2f%%", profitPercentage)
    }
    
    static var sampleTrades: [PlaybookTrade] {
        return [
            PlaybookTrade(
                symbol: "EURUSD",
                strategy: "Breakout Pullback + Mark Douglas Psychology",
                entryPrice: 1.0850,
                exitPrice: 1.0920,
                quantity: 100000,
                pnl: 700.00,
                grade: .aPlus,
                date: Date().addingTimeInterval(-86400 * 1),
                notes: "Perfect setup with strong psychological discipline. Followed the plan exactly as Mark Douglas teaches - no emotional interference.",
                screenshots: ["eurusd_setup1.png", "eurusd_exit1.png"],
                psychologyNotes: "Maintained complete emotional control. No FOMO, no fear. Executed with machine-like precision.",
                marketCondition: .breakout,
                timeframe: "15m",
                setup: .breakoutPullback,
                riskRewardRatio: 3.0,
                maxDrawdown: -50.00,
                holdingPeriod: 3600 * 4
            ),
            PlaybookTrade(
                symbol: "GBPJPY",
                strategy: "Support/Resistance + Momentum",
                entryPrice: 185.50,
                exitPrice: 184.20,
                quantity: 50000,
                pnl: -650.00,
                grade: .c,
                date: Date().addingTimeInterval(-86400 * 2),
                notes: "Entered too early, didn't wait for confirmation. Lesson: patience is key in trading.",
                screenshots: ["gbpjpy_fail1.png"],
                psychologyNotes: "Let emotions cloud judgment. Fear of missing out led to premature entry. Need to work on discipline.",
                marketCondition: .volatile,
                timeframe: "1h",
                setup: .supportResistance,
                riskRewardRatio: 2.0,
                maxDrawdown: -650.00,
                holdingPeriod: 3600 * 2
            ),
            PlaybookTrade(
                symbol: "XAUUSD",
                strategy: "Trend Following + Moving Averages",
                entryPrice: 2045.50,
                exitPrice: 2067.80,
                quantity: 10,
                pnl: 2230.00,
                grade: .a,
                date: Date().addingTimeInterval(-86400 * 3),
                notes: "Strong trend following setup. Gold broke key resistance and never looked back.",
                screenshots: ["gold_trend1.png", "gold_exit1.png"],
                psychologyNotes: "Great emotional control. Rode the trend with confidence, didn't exit too early.",
                marketCondition: .trending,
                timeframe: "4h",
                setup: .trendFollowing,
                riskRewardRatio: 4.5,
                maxDrawdown: -120.00,
                holdingPeriod: 3600 * 12
            ),
            PlaybookTrade(
                symbol: "BTCUSD",
                strategy: "Mean Reversion + RSI Divergence",
                entryPrice: 43500.00,
                exitPrice: 41200.00,
                quantity: 0.5,
                pnl: -1150.00,
                grade: .f,
                date: Date().addingTimeInterval(-86400 * 4),
                notes: "Terrible trade. Ignored risk management rules and held too long hoping for recovery.",
                screenshots: ["btc_disaster1.png"],
                psychologyNotes: "Complete emotional breakdown. Hope, fear, and greed all kicked in. Classic trading psychology failure.",
                marketCondition: .volatile,
                timeframe: "1d",
                setup: .meanReversion,
                riskRewardRatio: 1.5,
                maxDrawdown: -2300.00,
                holdingPeriod: 3600 * 48
            ),
            PlaybookTrade(
                symbol: "USDJPY",
                strategy: "News Trading + Economic Calendar",
                entryPrice: 149.80,
                exitPrice: 151.45,
                quantity: 100000,
                pnl: 1650.00,
                grade: .bPlus,
                date: Date().addingTimeInterval(-86400 * 5),
                notes: "NFP news trade. Quick execution, good timing. Could have held longer for bigger profit.",
                screenshots: ["usdjpy_news1.png"],
                psychologyNotes: "Good discipline with news trading. Quick in, quick out. No greed.",
                marketCondition: .breakout,
                timeframe: "5m",
                setup: .newsTrading,
                riskRewardRatio: 2.5,
                maxDrawdown: -180.00,
                holdingPeriod: 900
            ),
            PlaybookTrade(
                symbol: "SPY",
                strategy: "Scalping + Level 2 Order Flow",
                entryPrice: 485.20,
                exitPrice: 485.95,
                quantity: 200,
                pnl: 150.00,
                grade: .b,
                date: Date().addingTimeInterval(-86400 * 6),
                notes: "Quick scalp during market open. Small profit but consistent with strategy.",
                screenshots: ["spy_scalp1.png"],
                psychologyNotes: "Good emotional control for scalping. In and out quickly without hesitation.",
                marketCondition: .volatile,
                timeframe: "1m",
                setup: .scalping,
                riskRewardRatio: 1.5,
                maxDrawdown: -25.00,
                holdingPeriod: 180
            )
        ]
    }
    
    static func == (lhs: PlaybookTrade, rhs: PlaybookTrade) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - 🧠 PSYCHOLOGY INSIGHT MODEL

struct PsychologyInsight: Identifiable, Codable, Equatable {
    let id = UUID()
    let title: String
    let description: String
    let category: PsychologyCategory
    let severity: InsightSeverity
    let suggestion: String
    let markDouglasQuote: String
    let date: Date
    
    enum PsychologyCategory: String, CaseIterable, Codable {
        case fear = "Fear"
        case greed = "Greed"
        case hope = "Hope"
        case discipline = "Discipline"
        case patience = "Patience"
        case confidence = "Confidence"
        case focus = "Focus"
        case acceptance = "Acceptance"
        
        var color: Color {
            switch self {
            case .fear: return .red
            case .greed: return .orange
            case .hope: return .yellow
            case .discipline: return .blue
            case .patience: return .green
            case .confidence: return DesignSystem.primaryGold
            case .focus: return .purple
            case .acceptance: return .mint
            }
        }
        
        var emoji: String {
            switch self {
            case .fear: return "😰"
            case .greed: return "🤑"
            case .hope: return "🤞"
            case .discipline: return "💪"
            case .patience: return "⏰"
            case .confidence: return "💎"
            case .focus: return "🎯"
            case .acceptance: return "🧘"
            }
        }
    }
    
    enum InsightSeverity: String, CaseIterable, Codable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        case critical = "Critical"
        
        var color: Color {
            switch self {
            case .low: return .green
            case .medium: return .yellow
            case .high: return .orange
            case .critical: return .red
            }
        }
        
        var emoji: String {
            switch self {
            case .low: return "✅"
            case .medium: return "⚠️"
            case .high: return "🚨"
            case .critical: return "🔥"
            }
        }
    }
    
    static var sampleInsights: [PsychologyInsight] {
        return [
            PsychologyInsight(
                title: "Emotional Attachment to Losing Trades",
                description: "You held onto losing positions for 25% longer than your average, indicating difficulty accepting losses.",
                category: .acceptance,
                severity: .high,
                suggestion: "Practice the 'I am wrong' mindset. Accept that being wrong is part of trading and cut losses quickly.",
                markDouglasQuote: "The trader who can accept being wrong without emotional discomfort has a distinct advantage.",
                date: Date().addingTimeInterval(-3600 * 2)
            ),
            PsychologyInsight(
                title: "Fear-Based Position Sizing",
                description: "Your position sizes decreased by 40% after the recent losing streak, showing fear is affecting your risk management.",
                category: .fear,
                severity: .medium,
                suggestion: "Return to your predetermined position sizing rules. Fear should not dictate your risk management.",
                markDouglasQuote: "Trading is a probability game. You have to think in probabilities.",
                date: Date().addingTimeInterval(-3600 * 6)
            ),
            PsychologyInsight(
                title: "Excellent Discipline on Winners",
                description: "You've consistently taken profits at predetermined levels on your last 5 winning trades. This shows great discipline.",
                category: .discipline,
                severity: .low,
                suggestion: "Continue maintaining this level of discipline. Consider slightly scaling out positions to maximize profits while maintaining discipline.",
                markDouglasQuote: "Discipline is the ability to create a framework for your activities that ensures you don't act on every impulse.",
                date: Date().addingTimeInterval(-3600 * 12)
            )
        ]
    }
    
    static func == (lhs: PsychologyInsight, rhs: PsychologyInsight) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - 🔮 PATTERN RECOGNITION MODEL

struct TradingPattern: Identifiable, Codable, Equatable {
    let id = UUID()
    let name: String
    let description: String
    let successRate: Double
    let averageReturn: Double
    let occurrences: Int
    let category: PatternCategory
    let difficulty: PatternDifficulty
    let marketConditions: [PlaybookTrade.MarketCondition]
    let timeframes: [String]
    let keyLevels: [Double]
    let riskRewardRatio: Double
    
    enum PatternCategory: String, CaseIterable, Codable {
        case reversal = "Reversal"
        case continuation = "Continuation"
        case breakout = "Breakout"
        case consolidation = "Consolidation"
        case harmonic = "Harmonic"
        case candlestick = "Candlestick"
        
        var color: Color {
            switch self {
            case .reversal: return .red
            case .continuation: return .green
            case .breakout: return DesignSystem.primaryGold
            case .consolidation: return .blue
            case .harmonic: return .purple
            case .candlestick: return .orange
            }
        }
        
        var emoji: String {
            switch self {
            case .reversal: return "🔄"
            case .continuation: return "➡️"
            case .breakout: return "🚀"
            case .consolidation: return "📊"
            case .harmonic: return "🎵"
            case .candlestick: return "🕯️"
            }
        }
    }
    
    enum PatternDifficulty: String, CaseIterable, Codable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
        case expert = "Expert"
        
        var color: Color {
            switch self {
            case .beginner: return .green
            case .intermediate: return .blue
            case .advanced: return .orange
            case .expert: return .red
            }
        }
        
        var emoji: String {
            switch self {
            case .beginner: return "🌱"
            case .intermediate: return "📈"
            case .advanced: return "🎯"
            case .expert: return "🧠"
            }
        }
    }
    
    var formattedSuccessRate: String {
        return String(format: "%.1f%%", successRate * 100)
    }
    
    var formattedAverageReturn: String {
        return String(format: "%+.2f%%", averageReturn * 100)
    }
    
    var formattedRiskReward: String {
        return String(format: "1:%.1f", riskRewardRatio)
    }
    
    static var samplePatterns: [TradingPattern] {
        return [
            TradingPattern(
                name: "Breakout Pullback Elite",
                description: "High probability setup where price breaks key level, pulls back to test it as support/resistance, then continues in breakout direction.",
                successRate: 0.78,
                averageReturn: 0.045,
                occurrences: 23,
                category: .breakout,
                difficulty: .advanced,
                marketConditions: [.breakout, .trending],
                timeframes: ["15m", "1h", "4h"],
                keyLevels: [1.0850, 1.0920, 1.1000],
                riskRewardRatio: 3.2
            ),
            TradingPattern(
                name: "Double Bottom Reversal",
                description: "Classic reversal pattern showing two distinct lows at approximately the same level, indicating strong support.",
                successRate: 0.65,
                averageReturn: 0.032,
                occurrences: 15,
                category: .reversal,
                difficulty: .intermediate,
                marketConditions: [.reversal, .ranging],
                timeframes: ["1h", "4h", "1d"],
                keyLevels: [1.0780, 1.0785, 1.0950],
                riskRewardRatio: 2.8
            ),
            TradingPattern(
                name: "Hammer Candlestick at Support",
                description: "Hammer candle forming at key support level, indicating potential reversal from oversold conditions.",
                successRate: 0.72,
                averageReturn: 0.028,
                occurrences: 31,
                category: .candlestick,
                difficulty: .beginner,
                marketConditions: [.reversal, .volatile],
                timeframes: ["15m", "1h"],
                keyLevels: [1.0800, 1.0850],
                riskRewardRatio: 2.1
            )
        ]
    }
    
    static func == (lhs: TradingPattern, rhs: TradingPattern) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - 🚀 PLAYBOOK MANAGER

@MainActor
class PlaybookManager: ObservableObject {
    @Published var allTrades: [PlaybookTrade] = []
    @Published var psychologyInsights: [PsychologyInsight] = []
    @Published var tradingPatterns: [TradingPattern] = []
    @Published var isQuantumLearning = false
    @Published var quantumAccuracy: Double = 0.89
    @Published var learningRate: Double = 0.76
    @Published var predictiveModelAccuracy: Double = 0.82
    @Published var tradingPsychologyScore: Double = 0.73
    @Published var patternRecognitionAccuracy: Double = 0.85
    @Published var emotionalIntelligenceScore: Double = 0.68
    @Published var isLoading = false
    
    var formattedWinRate: String {
        let winningTrades = allTrades.filter { $0.isWinner }.count
        let totalTrades = allTrades.count
        let winRate = totalTrades > 0 ? Double(winningTrades) / Double(totalTrades) : 0.0
        return String(format: "%.1f%%", winRate * 100)
    }
    
    var totalPnL: Double {
        allTrades.reduce(0) { $0 + $1.pnl }
    }
    
    var formattedTotalPnL: String {
        return String(format: "%+.2f", totalPnL)
    }
    
    var averageWinSize: Double {
        let winningTrades = allTrades.filter { $0.isWinner }
        return winningTrades.isEmpty ? 0 : winningTrades.reduce(0) { $0 + $1.pnl } / Double(winningTrades.count)
    }
    
    var averageLossSize: Double {
        let losingTrades = allTrades.filter { !$0.isWinner }
        return losingTrades.isEmpty ? 0 : losingTrades.reduce(0) { $0 + $1.pnl } / Double(losingTrades.count)
    }
    
    init() {
        loadSampleData()
    }
    
    func startQuantumMode() async {
        isQuantumLearning = true
        
        // Simulate AI learning process
        for i in 0...100 {
            try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
            
            await MainActor.run {
                quantumAccuracy = min(0.95, quantumAccuracy + Double.random(in: 0...0.01))
                learningRate = min(0.90, learningRate + Double.random(in: 0...0.005))
                predictiveModelAccuracy = min(0.92, predictiveModelAccuracy + Double.random(in: 0...0.008))
            }
        }
        
        isQuantumLearning = false
    }
    
    func refreshQuantumData() async {
        isLoading = true
        
        // Simulate data refresh
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Update metrics with small random changes
        quantumAccuracy = max(0.75, min(0.95, quantumAccuracy + Double.random(in: -0.02...0.03)))
        tradingPsychologyScore = max(0.60, min(0.90, tradingPsychologyScore + Double.random(in: -0.05...0.08)))
        patternRecognitionAccuracy = max(0.70, min(0.95, patternRecognitionAccuracy + Double.random(in: -0.03...0.05)))
        emotionalIntelligenceScore = max(0.50, min(0.85, emotionalIntelligenceScore + Double.random(in: -0.04...0.07)))
        
        isLoading = false
    }
    
    func exportQuantumReport() async {
        // Simulate report generation
        isLoading = true
        try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
        isLoading = false
        
        // In real app, would generate and share PDF report
        print("🤯 Quantum Elite Report Generated!")
    }
    
    func generateQuantumAIAnalysis() async {
        // Simulate AI analysis generation
        isQuantumLearning = true
        try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
        
        // Generate new psychology insights
        let newInsight = PsychologyInsight(
            title: "AI-Generated Quantum Insight",
            description: "Your recent trading pattern shows improved emotional control and better risk management.",
            category: .discipline,
            severity: .low,
            suggestion: "Continue maintaining this level of discipline. Consider increasing position size gradually.",
            markDouglasQuote: "The hard reality of trading is that every trade has an uncertain outcome.",
            date: Date()
        )
        
        psychologyInsights.insert(newInsight, at: 0)
        isQuantumLearning = false
    }
    
    private func loadSampleData() {
        allTrades = PlaybookTrade.sampleTrades
        psychologyInsights = PsychologyInsight.sampleInsights
        tradingPatterns = TradingPattern.samplePatterns
    }
}

// MARK: - 🔥 PREVIEW

#Preview {
    VStack {
        Text("🤯 QUANTUM PLAYBOOK MODELS 🔥")
            .font(.title)
            .goldText()
        
        Text("Sample Trades: \(PlaybookTrade.sampleTrades.count)")
        Text("Psychology Insights: \(PsychologyInsight.sampleInsights.count)")
        Text("Trading Patterns: \(TradingPattern.samplePatterns.count)")
    }
    .padding()
}
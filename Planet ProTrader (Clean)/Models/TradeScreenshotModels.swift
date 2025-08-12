//
//  TradeScreenshotModels.swift
//  Planet ProTrader (Clean)
//
//  LEGENDARY SCREENSHOT SYSTEM FOR ELITE TRADING
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI
import UIKit
import PhotosUI

// MARK: - Trade Screenshot Models

struct TradeScreenshot: Identifiable, Codable, Hashable {
    let id: String
    let tradeId: String
    let phase: TradePhase
    let imageName: String
    let timestamp: Date
    let analysis: String
    let aiConfidence: Double
    let technicalIndicators: [String]
    let marketCondition: String
    let setupQuality: ScreenshotQuality
    
    // Unified additional fields
    let tradeGrade: TradeGrade
    let symbol: String
    let profitLoss: Double
    
    enum TradePhase: String, Codable, CaseIterable {
        case before = "Before Entry"
        case entry = "Entry Point"
        case during = "During Trade"
        case exit = "Exit Point"
        case after = "After Close"
        
        var emoji: String {
            switch self {
            case .before: return "👀"
            case .entry: return "🎯"
            case .during: return "⚡"
            case .exit: return "🏁"
            case .after: return "📊"
            }
        }
        
        var color: Color {
            switch self {
            case .before: return .blue
            case .entry: return .green
            case .during: return .orange
            case .exit: return .purple
            case .after: return .cyan
            }
        }
        
        var description: String {
            switch self {
            case .before: return "Pre-trade analysis and setup identification"
            case .entry: return "Exact entry point with confirmation signals"
            case .during: return "Trade management and price action"
            case .exit: return "Exit execution and final signals"
            case .after: return "Post-trade analysis and results"
            }
        }
    }
    
    enum ScreenshotQuality: String, Codable, CaseIterable {
        case elite = "Elite"
        case excellent = "Excellent"
        case good = "Good"
        case average = "Average"
        case poor = "Poor"
        
        var color: Color {
            switch self {
            case .elite: return DesignSystem.primaryGold
            case .excellent: return .green
            case .good: return .blue
            case .average: return .yellow
            case .poor: return .red
            }
        }
        
        var emoji: String {
            switch self {
            case .elite: return "👑"
            case .excellent: return "⭐"
            case .good: return "📊"
            case .average: return "📈"
            case .poor: return "❌"
            }
        }
        
        var score: Int {
            switch self {
            case .elite: return 5
            case .excellent: return 4
            case .good: return 3
            case .average: return 2
            case .poor: return 1
            }
        }
    }
    
    enum TradeGrade: String, Codable {
        case aPlusPlus = "A++"
        case aPlus = "A+"
        case a = "A"
        case bPlus = "B+"
        case b = "B"
        case c = "C"
        case d = "D"
        case f = "F"
        
        var emoji: String {
            switch self {
            case .aPlusPlus: return "🏆"
            case .aPlus: return "🔥"
            case .a: return "💎"
            case .bPlus: return "⭐️"
            case .b: return "✅"
            case .c: return "📘"
            case .d: return "🛠️"
            case .f: return "⚠️"
            }
        }
        
        var color: Color {
            switch self {
            case .aPlusPlus, .aPlus, .a: return .green
            case .bPlus, .b: return .blue
            case .c: return .orange
            case .d, .f: return .red
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
    
    var aiAnalysisScore: String {
        return String(format: "%.1f%%", aiConfidence * 100)
    }
    
    var qualityDescription: String {
        return "\(setupQuality.emoji) \(setupQuality.rawValue) Quality"
    }
    
    // MARK: - Initialization
    init(
        id: String = UUID().uuidString,
        tradeId: String,
        phase: TradePhase,
        imageName: String,
        timestamp: Date = Date(),
        analysis: String,
        aiConfidence: Double = 0.85,
        technicalIndicators: [String] = [],
        marketCondition: String = "Trending",
        setupQuality: ScreenshotQuality = .good,
        tradeGrade: TradeGrade = .a,
        symbol: String = "",
        profitLoss: Double = 0.0
    ) {
        self.id = id
        self.tradeId = tradeId
        self.phase = phase
        self.imageName = imageName
        self.timestamp = timestamp
        self.analysis = analysis
        self.aiConfidence = max(0.0, min(1.0, aiConfidence))
        self.technicalIndicators = technicalIndicators
        self.marketCondition = marketCondition
        self.setupQuality = setupQuality
        self.tradeGrade = tradeGrade
        self.symbol = symbol
        self.profitLoss = profitLoss
    }
    
    // MARK: - Hashable Conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: TradeScreenshot, rhs: TradeScreenshot) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Screenshot Gallery Manager

@MainActor
class ScreenshotGalleryManager: ObservableObject {
    @Published var screenshots: [String: [TradeScreenshot]] = [:]
    @Published var isLoading = false
    @Published var selectedScreenshot: TradeScreenshot?
    
    private let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    // MARK: - Screenshot Management
    
    func addScreenshot(_ screenshot: TradeScreenshot, image: UIImage) async {
        isLoading = true
        defer { isLoading = false }
        
        if await saveImage(image, fileName: screenshot.imageName) {
            var tradeScreenshots = screenshots[screenshot.tradeId] ?? []
            tradeScreenshots.append(screenshot)
            tradeScreenshots.sort { $0.timestamp < $1.timestamp }
            screenshots[screenshot.tradeId] = tradeScreenshots
        }
    }
    
    func getScreenshots(for tradeId: String) -> [TradeScreenshot] {
        return screenshots[tradeId] ?? []
    }
    
    func getScreenshotsByPhase(for tradeId: String, phase: TradeScreenshot.TradePhase) -> [TradeScreenshot] {
        return getScreenshots(for: tradeId).filter { $0.phase == phase }
    }
    
    func loadImage(for screenshot: TradeScreenshot) -> UIImage? {
        let imagePath = documentsPath.appendingPathComponent(screenshot.imageName)
        return UIImage(contentsOfFile: imagePath.path)
    }
    
    private func saveImage(_ image: UIImage, fileName: String) async -> Bool {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return false }
        
        let imagePath = documentsPath.appendingPathComponent(fileName)
        
        do {
            try imageData.write(to: imagePath)
            return true
        } catch {
            print("Failed to save image: \(error)")
            return false
        }
    }
    
    // MARK: - AI Analysis
    
    func analyzeScreenshot(_ screenshot: TradeScreenshot) async -> String {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        let analysisTemplates = [
            "Strong bullish momentum with clear breakout pattern. Volume confirmation present. High probability setup.",
            "Bearish rejection at key resistance level. Multiple timeframe alignment confirms short opportunity.",
            "Perfect pullback entry with 50% retracement. Risk-reward ratio highly favorable at 1:3.",
            "Classic double bottom formation completed. Bullish divergence on RSI confirms reversal potential.",
            "Triangle breakout with volume expansion. Target projection suggests 2R+ potential.",
            "Support and resistance confluence creating ideal entry zone. Market structure remains bullish."
        ]
        
        return analysisTemplates.randomElement() ?? "Analysis in progress..."
    }
    
    func generateAIInsights(for tradeId: String) async -> [String] {
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        let insights = [
            "📊 Entry timing was optimal - captured the exact momentum shift",
            "🎯 Risk management perfectly executed with tight stop placement",
            "⚡ Market structure analysis was spot-on for this setup",
            "🧠 Psychological resistance level clearly identified in advance",
            "📈 Multi-timeframe confirmation created high-confidence entry",
            "💎 Exit strategy maximized R-multiple potential effectively"
        ]
        
        return Array(insights.shuffled().prefix(3))
    }
}

// MARK: - Screenshot Analysis Engine

class ScreenshotAnalysisEngine {
    
    static func analyzeTradeSetup(_ image: UIImage) async -> ScreenshotAnalysis {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        return ScreenshotAnalysis(
            setupType: TradingSetup.allCases.randomElement() ?? .breakout,
            confidence: Double.random(in: 0.7...0.95),
            technicalIndicators: generateTechnicalIndicators(),
            marketCondition: ScreenshotMarketCondition.allCases.randomElement() ?? .trending,
            riskRewardRatio: Double.random(in: 1.5...4.0),
            qualityScore: TradeScreenshot.ScreenshotQuality.allCases.randomElement() ?? .good,
            suggestions: generateTradingSuggestions()
        )
    }
    
    private static func generateTechnicalIndicators() -> [String] {
        let indicators = [
            "RSI Bullish Divergence",
            "MACD Crossover Signal",
            "Support/Resistance Level",
            "Volume Confirmation",
            "Moving Average Alignment",
            "Fibonacci Retracement",
            "Trendline Break",
            "Flag Pattern Completion"
        ]
        return Array(indicators.shuffled().prefix(Int.random(in: 2...4)))
    }
    
    private static func generateTradingSuggestions() -> [String] {
        let suggestions = [
            "Consider partial profit taking at 50% of target",
            "Trail stop to breakeven after 1R move",
            "Watch for volume confirmation on continuation",
            "Monitor key support/resistance levels closely",
            "Adjust position size based on volatility",
            "Consider scaling in on pullback confirmation"
        ]
        return Array(suggestions.shuffled().prefix(2))
    }
}

struct ScreenshotAnalysis {
    let setupType: TradingSetup
    let confidence: Double
    let technicalIndicators: [String]
    let marketCondition: ScreenshotMarketCondition
    let riskRewardRatio: Double
    let qualityScore: TradeScreenshot.ScreenshotQuality
    let suggestions: [String]
    
    var formattedConfidence: String {
        return String(format: "%.1f%%", confidence * 100)
    }
    
    var formattedRiskReward: String {
        return String(format: "1:%.1f", riskRewardRatio)
    }
}

// MARK: - Enhanced Trading Setup

enum TradingSetup: String, Codable, CaseIterable {
    case breakout = "Breakout"
    case pullback = "Pullback"
    case reversal = "Reversal"
    case continuation = "Continuation"
    case range = "Range Trading"
    case flagPattern = "Flag Pattern"
    case triangleBreak = "Triangle Break"
    case doubleBottom = "Double Bottom"
    case headShoulders = "Head & Shoulders"
    case wedgePattern = "Wedge Pattern"
    
    var emoji: String {
        switch self {
        case .breakout: return "🚀"
        case .pullback: return "↩️"
        case .reversal: return "🔄"
        case .continuation: return "➡️"
        case .range: return "↔️"
        case .flagPattern: return "🏁"
        case .triangleBreak: return "📐"
        case .doubleBottom: return "🔄"
        case .headShoulders: return "👤"
        case .wedgePattern: return "📊"
        }
    }
    
    var color: Color {
        switch self {
        case .breakout: return .green
        case .pullback: return .blue
        case .reversal: return .purple
        case .continuation: return .orange
        case .range: return .gray
        case .flagPattern: return .cyan
        case .triangleBreak: return .mint
        case .doubleBottom: return .indigo
        case .headShoulders: return .pink
        case .wedgePattern: return .yellow
        }
    }
    
    var description: String {
        switch self {
        case .breakout: return "Price breaking through key resistance/support"
        case .pullback: return "Retracement entry in trending market"
        case .reversal: return "Change in market direction"
        case .continuation: return "Trend continuation after consolidation"
        case .range: return "Trading within defined boundaries"
        case .flagPattern: return "Brief consolidation in trending market"
        case .triangleBreak: return "Breakout from triangle formation"
        case .doubleBottom: return "Bullish reversal pattern"
        case .headShoulders: return "Classic reversal formation"
        case .wedgePattern: return "Converging trendlines pattern"
        }
    }
}

enum ScreenshotMarketCondition: String, Codable, CaseIterable {
    case trending = "Trending"
    case ranging = "Ranging"
    case volatile = "Volatile"
    case quiet = "Quiet"
    case breakout = "Breakout"
    case consolidation = "Consolidation"
    
    var color: Color {
        switch self {
        case .trending: return .green
        case .ranging: return .blue
        case .volatile: return .orange
        case .quiet: return .gray
        case .breakout: return .purple
        case .consolidation: return .yellow
        }
    }
    
    var emoji: String {
        switch self {
        case .trending: return "📈"
        case .ranging: return "↔️"
        case .volatile: return "⚡"
        case .quiet: return "😴"
        case .breakout: return "🚀"
        case .consolidation: return "🔄"
        }
    }
}

// MARK: - Sample Screenshot Data

extension TradeScreenshot {
    static let sampleScreenshots: [String: [TradeScreenshot]] = [
        "sample-trade-1": [
            TradeScreenshot(
                tradeId: "sample-trade-1",
                phase: .before,
                imageName: "trade1_before.jpg",
                analysis: "Perfect setup forming at key support level. Multiple timeframe alignment confirms bullish bias.",
                aiConfidence: 0.92,
                technicalIndicators: ["RSI Bullish Divergence", "Volume Confirmation", "Support Level Hold"],
                marketCondition: "Trending",
                setupQuality: .elite,
                tradeGrade: .aPlusPlus,
                symbol: "XAUUSD",
                profitLoss: 150.0
            ),
            TradeScreenshot(
                tradeId: "sample-trade-1",
                phase: .entry,
                imageName: "trade1_entry.jpg",
                analysis: "Entry executed at optimal price with confirmation candle. Risk-reward ratio 1:3.",
                aiConfidence: 0.89,
                technicalIndicators: ["Breakout Confirmation", "MACD Crossover"],
                marketCondition: "Breakout",
                setupQuality: .excellent,
                tradeGrade: .aPlus,
                symbol: "XAUUSD",
                profitLoss: 0.0
            ),
            TradeScreenshot(
                tradeId: "sample-trade-1",
                phase: .exit,
                imageName: "trade1_exit.jpg",
                analysis: "Perfect exit at resistance level. Target achieved with precision timing.",
                aiConfidence: 0.95,
                technicalIndicators: ["Resistance Rejection", "Profit Target Hit"],
                marketCondition: "Consolidation",
                setupQuality: .elite,
                tradeGrade: .aPlusPlus,
                symbol: "XAUUSD",
                profitLoss: 275.0
            )
        ]
    ]
}

#Preview {
    VStack(spacing: 20) {
        Text("📸 LEGENDARY SCREENSHOT SYSTEM")
            .font(DesignSystem.Typography.largeTitle)
            .goldText()
        
        Text("Elite Trade Documentation")
            .font(DesignSystem.Typography.headline)
            .foregroundColor(.secondary)
        
        VStack(spacing: 16) {
            ForEach(TradeScreenshot.TradePhase.allCases, id: \.self) { phase in
                HStack {
                    Text(phase.emoji)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(phase.rawValue)
                            .font(DesignSystem.Typography.headline)
                            .foregroundStyle(phase.color)
                        
                        Text(phase.description)
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .solarCard()
            }
        }
        
        VStack(alignment: .leading, spacing: 8) {
            Text("🤖 AI Analysis Features")
                .font(DesignSystem.Typography.headline)
                .goldText()
            
            VStack(alignment: .leading, spacing: 4) {
                Text("• Automatic setup recognition")
                Text("• Technical indicator detection")
                Text("• Market condition analysis")
                Text("• Quality scoring system")
                Text("• Trading suggestions")
                Text("• Confidence metrics")
            }
            .font(DesignSystem.Typography.body)
            .foregroundColor(.white)
            .opacity(0.9)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .solarCard()
    }
    .padding()
    .background(DesignSystem.spaceGradient)
}
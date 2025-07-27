//
//  FlipModels.swift
//  Planet ProTrader - Flip Challenge Models
//
//  Models for flip challenge functionality
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI
import Foundation

// MARK: - Flip Challenge Models

enum FlipPreset: String, CaseIterable, Identifiable, Codable {
    case tenK = "10K"
    case fiftyK = "50K"
    case hundredK = "100K"
    case custom = "Custom"
    
    var id: String { rawValue }
    
    var startingAmount: Double {
        switch self {
        case .tenK: return 10000
        case .fiftyK: return 50000
        case .hundredK: return 100000
        case .custom: return 0
        }
    }
    
    var targetAmount: Double {
        switch self {
        case .tenK: return 100000
        case .fiftyK: return 500000
        case .hundredK: return 1000000
        case .custom: return 0
        }
    }
    
    var displayName: String {
        switch self {
        case .tenK: return "$10K → $100K"
        case .fiftyK: return "$50K → $500K"
        case .hundredK: return "$100K → $1M"
        case .custom: return "Custom Amount"
        }
    }
    
    var color: Color {
        switch self {
        case .tenK: return .green
        case .fiftyK: return .orange
        case .hundredK: return .red
        case .custom: return .blue
        }
    }
}

enum FlipTimeframe: String, CaseIterable, Identifiable, Codable {
    case oneWeek = "1W"
    case twoWeeks = "2W"
    case oneMonth = "1M"
    case threeMonths = "3M"
    case sixMonths = "6M"
    case oneYear = "1Y"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .oneWeek: return "1 Week"
        case .twoWeeks: return "2 Weeks"
        case .oneMonth: return "1 Month"
        case .threeMonths: return "3 Months"
        case .sixMonths: return "6 Months"
        case .oneYear: return "1 Year"
        }
    }
    
    var difficulty: String {
        switch self {
        case .oneWeek: return "EXTREME"
        case .twoWeeks: return "VERY HARD"
        case .oneMonth: return "HARD"
        case .threeMonths: return "MODERATE"
        case .sixMonths: return "EASY"
        case .oneYear: return "BEGINNER"
        }
    }
    
    var color: Color {
        switch self {
        case .oneWeek: return .red
        case .twoWeeks: return .orange
        case .oneMonth: return .yellow
        case .threeMonths: return .blue
        case .sixMonths: return .green
        case .oneYear: return .mint
        }
    }
    
    var days: Int {
        switch self {
        case .oneWeek: return 7
        case .twoWeeks: return 14
        case .oneMonth: return 30
        case .threeMonths: return 90
        case .sixMonths: return 180
        case .oneYear: return 365
        }
    }
}

enum FlipStrategy: String, CaseIterable, Identifiable, Codable {
    case conservative = "Conservative"
    case balanced = "Balanced"
    case aggressive = "Aggressive"
    case goldOnly = "Gold Only"
    case forexOnly = "Forex Only"
    case scalping = "Scalping"
    case swingTrading = "Swing Trading"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .conservative: return "Low risk, steady growth"
        case .balanced: return "Balanced risk/reward ratio"
        case .aggressive: return "High risk, high reward"
        case .goldOnly: return "Trade gold pairs only"
        case .forexOnly: return "Trade forex pairs only"
        case .scalping: return "Quick in-and-out trades"
        case .swingTrading: return "Hold trades for days"
        }
    }
    
    var riskLevel: String {
        switch self {
        case .conservative: return "LOW"
        case .balanced: return "MEDIUM"
        case .aggressive: return "HIGH"
        case .goldOnly: return "MEDIUM"
        case .forexOnly: return "MEDIUM"
        case .scalping: return "HIGH"
        case .swingTrading: return "LOW"
        }
    }
    
    var color: Color {
        switch self {
        case .conservative: return .green
        case .balanced: return .blue
        case .aggressive: return .red
        case .goldOnly: return .yellow
        case .forexOnly: return .purple
        case .scalping: return .orange
        case .swingTrading: return .mint
        }
    }
    
    var expectedDailyReturn: Double {
        switch self {
        case .conservative: return 0.02 // 2%
        case .balanced: return 0.05 // 5%
        case .aggressive: return 0.10 // 10%
        case .goldOnly: return 0.04 // 4%
        case .forexOnly: return 0.03 // 3%
        case .scalping: return 0.08 // 8%
        case .swingTrading: return 0.03 // 3%
        }
    }
}

struct FlipChallenge: Identifiable, Codable {
    let id: UUID
    let name: String
    let startingAmount: Double
    let targetAmount: Double
    let timeframe: FlipTimeframe
    let strategy: FlipStrategy
    let startDate: Date
    let endDate: Date
    var currentAmount: Double
    var isActive: Bool
    var isCompleted: Bool
    var trades: [ChallengeFlipTrade]
    
    init(preset: FlipPreset, timeframe: FlipTimeframe, strategy: FlipStrategy, customStart: Double = 0, customTarget: Double = 0) {
        self.id = UUID()
        self.name = "\(preset.displayName) Challenge"
        self.startingAmount = preset == .custom ? customStart : preset.startingAmount
        self.targetAmount = preset == .custom ? customTarget : preset.targetAmount
        self.timeframe = timeframe
        self.strategy = strategy
        self.startDate = Date()
        self.endDate = Calendar.current.date(byAdding: .day, value: timeframe.days, to: Date()) ?? Date()
        self.currentAmount = self.startingAmount
        self.isActive = false
        self.isCompleted = false
        self.trades = []
    }
    
    var progress: Double {
        guard targetAmount > startingAmount else { return 0 }
        return min(1.0, (currentAmount - startingAmount) / (targetAmount - startingAmount))
    }
    
    var remainingDays: Int {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day], from: now, to: endDate)
        return max(0, components.day ?? 0)
    }
    
    var profitLoss: Double {
        return currentAmount - startingAmount
    }
    
    var profitLossPercentage: Double {
        guard startingAmount > 0 else { return 0 }
        return (profitLoss / startingAmount) * 100
    }
    
    var isWinning: Bool {
        return currentAmount >= targetAmount
    }
    
    var status: String {
        if isCompleted {
            return isWinning ? "WON" : "FAILED"
        } else if isActive {
            return "ACTIVE"
        } else {
            return "PENDING"
        }
    }
    
    var statusColor: Color {
        if isCompleted {
            return isWinning ? .green : .red
        } else if isActive {
            return .blue
        } else {
            return .gray
        }
    }
}

struct ChallengeFlipTrade: Identifiable, Codable {
    let id: UUID
    let symbol: String
    let direction: String // "BUY" or "SELL"
    let entryPrice: Double
    let exitPrice: Double?
    let lotSize: Double
    let profit: Double
    let timestamp: Date
    let exitTimestamp: Date?
    let isOpen: Bool
    
    init(symbol: String, direction: String, entryPrice: Double, lotSize: Double) {
        self.id = UUID()
        self.symbol = symbol
        self.direction = direction
        self.entryPrice = entryPrice
        self.exitPrice = nil
        self.lotSize = lotSize
        self.profit = 0
        self.timestamp = Date()
        self.exitTimestamp = nil
        self.isOpen = true
    }
    
    var profitColor: Color {
        return profit >= 0 ? .green : .red
    }
    
    var durationString: String {
        let endTime = exitTimestamp ?? Date()
        let duration = endTime.timeIntervalSince(timestamp)
        
        if duration < 60 {
            return "\(Int(duration))s"
        } else if duration < 3600 {
            return "\(Int(duration / 60))m"
        } else {
            return "\(Int(duration / 3600))h"
        }
    }
}

// MARK: - Flip Challenge Manager

class FlipChallengeManager: ObservableObject {
    static let shared = FlipChallengeManager()
    
    @Published var activeChallenges: [FlipChallenge] = []
    @Published var completedChallenges: [FlipChallenge] = []
    
    private init() {
        loadChallenges()
    }
    
    func createChallenge(preset: FlipPreset, timeframe: FlipTimeframe, strategy: FlipStrategy, customStart: Double = 0, customTarget: Double = 0) -> FlipChallenge {
        let challenge = FlipChallenge(preset: preset, timeframe: timeframe, strategy: strategy, customStart: customStart, customTarget: customTarget)
        activeChallenges.append(challenge)
        saveChallenges()
        return challenge
    }
    
    func startChallenge(_ challenge: FlipChallenge) {
        if let index = activeChallenges.firstIndex(where: { $0.id == challenge.id }) {
            activeChallenges[index].isActive = true
            saveChallenges()
        }
    }
    
    func stopChallenge(_ challenge: FlipChallenge) {
        if let index = activeChallenges.firstIndex(where: { $0.id == challenge.id }) {
            activeChallenges[index].isActive = false
            saveChallenges()
        }
    }
    
    func completeChallenge(_ challenge: FlipChallenge) {
        if let index = activeChallenges.firstIndex(where: { $0.id == challenge.id }) {
            var completed = activeChallenges.remove(at: index)
            completed.isCompleted = true
            completed.isActive = false
            completedChallenges.append(completed)
            saveChallenges()
        }
    }
    
    func updateChallengeBalance(_ challenge: FlipChallenge, newAmount: Double) {
        if let index = activeChallenges.firstIndex(where: { $0.id == challenge.id }) {
            activeChallenges[index].currentAmount = newAmount
            
            // Check if challenge is won
            if newAmount >= challenge.targetAmount {
                completeChallenge(challenge)
            }
            
            saveChallenges()
        }
    }
    
    func addTradeToChallenge(_ challenge: FlipChallenge, trade: ChallengeFlipTrade) {
        if let index = activeChallenges.firstIndex(where: { $0.id == challenge.id }) {
            activeChallenges[index].trades.append(trade)
            activeChallenges[index].currentAmount += trade.profit
            saveChallenges()
        }
    }
    
    private func saveChallenges() {
        if let data = try? JSONEncoder().encode(activeChallenges) {
            UserDefaults.standard.set(data, forKey: "ActiveFlipChallenges")
        }
        
        if let data = try? JSONEncoder().encode(completedChallenges) {
            UserDefaults.standard.set(data, forKey: "CompletedFlipChallenges")
        }
    }
    
    private func loadChallenges() {
        if let data = UserDefaults.standard.data(forKey: "ActiveFlipChallenges"),
           let challenges = try? JSONDecoder().decode([FlipChallenge].self, from: data) {
            activeChallenges = challenges
        }
        
        if let data = UserDefaults.standard.data(forKey: "CompletedFlipChallenges"),
           let challenges = try? JSONDecoder().decode([FlipChallenge].self, from: data) {
            completedChallenges = challenges
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("🎯 Flip Challenge Models")
            .font(DesignSystem.Typography.largeTitle)
            .goldText()
        
        VStack(spacing: 12) {
            HStack {
                Text("10K Challenge:")
                Spacer()
                Text(FlipPreset.tenK.displayName)
                    .fontWeight(.semibold)
                    .foregroundColor(FlipPreset.tenK.color)
            }
            
            HStack {
                Text("Timeframe:")
                Spacer()
                Text("\(FlipTimeframe.oneMonth.displayName) (\(FlipTimeframe.oneMonth.difficulty))")
                    .fontWeight(.semibold)
                    .foregroundColor(FlipTimeframe.oneMonth.color)
            }
            
            HStack {
                Text("Strategy:")
                Spacer()
                Text("\(FlipStrategy.aggressive.rawValue) (\(FlipStrategy.aggressive.riskLevel))")
                    .fontWeight(.semibold)
                    .foregroundColor(FlipStrategy.aggressive.color)
            }
        }
        .standardCard()
        
        Text("🚀 Complete flip challenge system • 📊 Progress tracking • 💰 Real profit/loss")
            .font(.caption)
            .foregroundColor(.secondary)
    }
    .padding()
}
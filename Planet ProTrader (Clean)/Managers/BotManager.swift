//
//  BotManager.swift
//  Planet ProTrader - AI Bot Management
//
//  Professional AI Trading Bot Manager
//  Created by AI Assistant on 1/25/25.
//

import Foundation
import Combine
import SwiftUI

class ProBotManager: ObservableObject {
    static let shared = ProBotManager()
    
    // MARK: - Published Properties
    @Published var isRunning: Bool = false
    @Published var currentStrategy: ProTradingStrategy = .conservative
    @Published var totalTrades: Int = 0
    @Published var successRate: Double = 0.0
    @Published var totalProfit: Double = 0.0
    @Published var activeBots: Int = 0
    
    // MARK: - Bot Status
    @Published var botStatus: ProBotStatus = .stopped
    @Published var lastSignal: ProTradingSignal?
    @Published var performance: ProBotPerformance = ProBotPerformance()
    
    private var updateTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupPerformanceTracking()
    }
    
    // MARK: - Bot Control
    func startBot() {
        isRunning = true
        botStatus = .running
        activeBots = 1
        startPerformanceUpdates()
    }
    
    func stopBot() {
        isRunning = false
        botStatus = .stopped
        activeBots = 0
        updateTimer?.invalidate()
    }
    
    func pauseBot() {
        isRunning = false
        botStatus = .paused
    }
    
    func resumeBot() {
        isRunning = true
        botStatus = .running
        startPerformanceUpdates()
    }
    
    // MARK: - Performance Tracking
    private func setupPerformanceTracking() {
        // Simulate some initial performance data
        performance = ProBotPerformance(
            totalTrades: 156,
            winningTrades: 89,
            losingTrades: 67,
            totalProfit: 1247.35,
            maxDrawdown: -125.40,
            averageWin: 24.67,
            averageLoss: -18.23,
            profitFactor: 1.35
        )
        
        updateStatistics()
    }
    
    private func startPerformanceUpdates() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.simulateTrading()
        }
    }
    
    private func simulateTrading() {
        guard isRunning else { return }
        
        // Simulate a trade every 5 seconds when running
        let isWin = Double.random(in: 0...1) < 0.57 // 57% win rate
        let profit = isWin ? Double.random(in: 15...45) : Double.random(in: -30...(-10))
        
        totalTrades += 1
        totalProfit += profit
        
        if isWin {
            performance.winningTrades += 1
        } else {
            performance.losingTrades += 1
        }
        
        performance.totalTrades = totalTrades
        performance.totalProfit = totalProfit
        
        updateStatistics()
        
        // Create a signal with correct parameters
        let basePrice = 2374.50
        let entryPrice = basePrice + Double.random(in: -2.0...2.0)
        let direction: ProSignalType = isWin ? .buy : .sell
        
        let stopLoss = direction == .buy ? entryPrice - 10.0 : entryPrice + 10.0
        let takeProfit = direction == .buy ? entryPrice + 20.0 : entryPrice - 20.0
        
        lastSignal = ProTradingSignal(
            symbol: "XAUUSD",
            direction: direction,
            entryPrice: entryPrice,
            stopLoss: stopLoss,
            takeProfit: takeProfit,
            confidence: Double.random(in: 0.6...0.95),
            timeframe: "15M",
            timestamp: Date(),
            source: "Pro Bot AI"
        )
    }
    
    private func updateStatistics() {
        let totalTrades = performance.winningTrades + performance.losingTrades
        successRate = totalTrades > 0 ? Double(performance.winningTrades) / Double(totalTrades) : 0.0
        self.totalTrades = totalTrades
    }
    
    func startBackgroundBotManagement() {
        print("🤖 Pro Bot background management started")
    }
    
    deinit {
        updateTimer?.invalidate()
    }
}

// MARK: - Supporting Types
enum ProTradingStrategy: String, CaseIterable {
    case conservative = "Conservative"
    case moderate = "Moderate"
    case aggressive = "Aggressive"
    case custom = "Custom"
    
    var description: String {
        switch self {
        case .conservative: return "Low risk, steady gains"
        case .moderate: return "Balanced risk/reward"
        case .aggressive: return "High risk, high reward"
        case .custom: return "User-defined parameters"
        }
    }
}

enum ProBotStatus: String {
    case stopped = "Stopped"
    case running = "Running"
    case paused = "Paused"
    case error = "Error"
    
    var color: Color {
        switch self {
        case .stopped: return .gray
        case .running: return .green
        case .paused: return .orange
        case .error: return .red
        }
    }
}

enum ProSignalType {
    case buy, sell, hold
    
    var displayName: String {
        switch self {
        case .buy: return "BUY"
        case .sell: return "SELL"
        case .hold: return "HOLD"
        }
    }
}

struct ProTradingSignal {
    let symbol: String
    let direction: ProSignalType
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
    
    var confidenceColor: Color {
        if confidence >= 0.8 { return .green }
        else if confidence >= 0.6 { return .orange }
        else { return .red }
    }
}

struct ProBotPerformance {
    var totalTrades: Int = 0
    var winningTrades: Int = 0
    var losingTrades: Int = 0
    var totalProfit: Double = 0.0
    var maxDrawdown: Double = 0.0
    var averageWin: Double = 0.0
    var averageLoss: Double = 0.0
    var profitFactor: Double = 0.0
    
    var winRate: Double {
        return totalTrades > 0 ? Double(winningTrades) / Double(totalTrades) : 0.0
    }
    
    var formattedWinRate: String {
        return String(format: "%.1f%%", winRate * 100)
    }
    
    var formattedProfit: String {
        let sign = totalProfit >= 0 ? "+" : ""
        return "\(sign)$\(String(format: "%.2f", totalProfit))"
    }
}
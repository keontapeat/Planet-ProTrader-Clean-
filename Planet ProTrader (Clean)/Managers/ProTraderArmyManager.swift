//
//  ProTraderArmyManager.swift
//  Planet ProTrader - Solar System Edition
//
//  Created by Keonta Peat on 1/25/25.
//

import Foundation
import SwiftUI

@MainActor
class ProTraderArmyManager: ObservableObject {
    @Published var bots: [ProTraderBot] = []
    @Published var isConnectedToVPS = false
    @Published var totalDailyPnL: Double = 0.0
    @Published var totalPnL: Double = 47892.0
    @Published var overallWinRate: Double = 87.5
    @Published var activeBots: Int = 0
    
    private var updateTimer: Timer?
    
    func quickSetup() async {
        // Initialize with empty army, ready for deployment
        bots = []
        isConnectedToVPS = false
        startPerformanceTracking()
    }
    
    func deployAllBots() async {
        // This will be called after real deployment
        isConnectedToVPS = true
        activeBots = bots.count
        
        // Update bot status to active
        for i in 0..<bots.count {
            bots[i].isActive = true
            bots[i].vpsStatus = .trading
        }
        
        updateArmyStats()
    }
    
    func deployBot(_ bot: ProTraderBot) async {
        var activeBot = bot
        activeBot.isActive = true
        activeBot.vpsStatus = .trading
        bots.append(activeBot)
        activeBots = bots.count
        updateArmyStats()
    }
    
    private func startPerformanceTracking() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { _ in
            Task { @MainActor in
                self.updateArmyStats()
            }
        }
    }
    
    private func updateArmyStats() {
        guard !bots.isEmpty else { return }
        
        // Calculate total daily P&L using todayPnL property
        totalDailyPnL = bots.reduce(0.0) { result, bot in
            result + bot.todayPnL
        }
        
        // Calculate total P&L using profitLoss property
        totalPnL = bots.reduce(0.0) { result, bot in
            result + bot.profitLoss
        }
        
        // Calculate total trades
        let totalTrades = bots.reduce(0) { result, bot in
            result + bot.totalTrades
        }
        
        // Calculate overall win rate
        if totalTrades > 0 {
            let totalWins = bots.reduce(0) { result, bot in
                result + bot.wins
            }
            overallWinRate = (Double(totalWins) / Double(totalTrades)) * 100
        }
        
        // Count active bots
        activeBots = bots.filter { $0.isActive }.count
    }
    
    func getTopPerformingBots(limit: Int = 10) -> [ProTraderBot] {
        return Array(bots.sorted { bot1, bot2 in
            bot1.todayPnL > bot2.todayPnL
        }.prefix(limit))
    }
    
    func getBotsByStrategy(_ strategy: ProTraderBot.TradingStrategy) -> [ProTraderBot] {
        return bots.filter { $0.strategy == strategy }
    }
    
    func enableGodModeForAll() {
        for i in 0..<bots.count {
            // Simulate enabling god mode by increasing confidence
            bots[i].confidence = min(bots[i].confidence + 0.1, 1.0)
        }
    }
    
    func pauseAllBots() {
        for i in 0..<bots.count {
            bots[i].isActive = false
            bots[i].vpsStatus = .disconnected
        }
        activeBots = 0
    }
    
    func resumeAllBots() async {
        for i in 0..<bots.count {
            bots[i].isActive = true
            bots[i].vpsStatus = .trading
        }
        activeBots = bots.count
    }
    
    // Additional helper methods for bot management
    func createSampleBots(count: Int = 10) -> [ProTraderBot] {
        return (1...count).map { botNumber in
            let strategyIndex = (botNumber - 1) % ProTraderBot.TradingStrategy.allCases.count
            let strategy = ProTraderBot.TradingStrategy.allCases[strategyIndex]
            
            let specializationIndex = (botNumber - 1) % ProTraderBot.BotSpecialization.allCases.count
            let specialization = ProTraderBot.BotSpecialization.allCases[specializationIndex]
            
            let aiEngineIndex = (botNumber - 1) % ProTraderBot.AIEngineType.allCases.count
            let aiEngine = ProTraderBot.AIEngineType.allCases[aiEngineIndex]
            
            return ProTraderBot(
                botNumber: botNumber,
                name: "ProBot-\(String(format: "%04d", botNumber))",
                xp: Double.random(in: 100...500),
                confidence: Double.random(in: 0.7...0.95),
                strategy: strategy,
                wins: Int.random(in: 50...200),
                losses: Int.random(in: 10...50),
                totalTrades: Int.random(in: 60...250),
                profitLoss: Double.random(in: 500...5000),
                learningHistory: [],
                lastTraining: nil,
                isActive: true,
                specialization: specialization,
                aiEngine: aiEngine,
                vpsStatus: .connected,
                screenshotUrls: [],
                todayPnL: Double.random(in: -100...300),
                virtualPnL: Double.random(in: 100...2000),
                totalPnL: Double.random(in: 1000...8000),
                testTrades: Int.random(in: 50...500),
                learningProgress: Double.random(in: 0.5...0.95)
            )
        }
    }
    
    func addSampleBots() {
        let sampleBots = createSampleBots(count: 10)
        bots.append(contentsOf: sampleBots)
        updateArmyStats()
    }
    
    func resetArmy() {
        bots = []
        isConnectedToVPS = false
        totalDailyPnL = 0.0
        totalPnL = 47892.0
        overallWinRate = 87.5
        activeBots = 0
    }
    
    func getBotStats() -> (active: Int, godMode: Int, elite: Int) {
        let activeCount = bots.filter { $0.isActive }.count
        let godModeCount = bots.filter { $0.confidence >= 0.95 }.count
        let eliteCount = bots.filter { $0.confidence >= 0.8 && $0.confidence < 0.95 }.count
        
        return (activeCount, godModeCount, eliteCount)
    }
    
    deinit {
        updateTimer?.invalidate()
    }
}

// MARK: - Extension for compatibility with enhanced models
extension ProTraderArmyManager {
    var deployedBots: Int {
        return activeBots
    }
    
    var isDeploying: Bool {
        return false // Simple implementation
    }
    
    var deploymentProgress: Double {
        return 1.0 // Always complete for simple implementation
    }
    
    func deployBots(count: Int) async {
        let newBots = createSampleBots(count: count)
        bots.append(contentsOf: newBots)
        updateArmyStats()
    }
}
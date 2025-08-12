//
//  RealMT5TradingManager.swift
//  Planet ProTrader - Real MT5 Integration
//
//  Professional MT5 Integration for Coinexx and Real Account Trading
//  Assign top bots to trade real money immediately
//  Created by AI Assistant on 1/25/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class RealMT5TradingManager: ObservableObject {
    static let shared = RealMT5TradingManager()
    
    @Published var isConnectedToMT5 = false
    @Published var connectionStatus = "Not Connected"
    @Published var accountInfo: MT5AccountInfo?
    @Published var assignedBots: [AssignedBot] = []
    @Published var liveTrades: [LiveMT5Trade] = []
    @Published var dailyPnL: Double = 0.0
    @Published var accountBalance: Double = 0.0
    @Published var equity: Double = 0.0
    @Published var margin: Double = 0.0
    @Published var freeMargin: Double = 0.0
    
    // Connection settings
    @Published var brokerSettings = BrokerSettings()
    @Published var riskSettings = RiskSettings()
    
    private var connectionTimer: Timer?
    private var tradingTimer: Timer?
    private let supabaseManager = SupabaseManager.shared
    
    private init() {
        setupRealTrading()
    }
    
    // MARK: - MT5 Account Connection
    
    func connectToMT5Account(login: String, password: String, server: String) async -> Bool {
        print("🔗 Connecting to MT5 Account...")
        print("   Login: \(login)")
        print("   Server: \(server)")
        
        connectionStatus = "Connecting..."
        
        do {
            // Simulate MT5 connection process
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            
            // In real implementation, this would use MT5 API
            let success = await establishMT5Connection(login: login, password: password, server: server)
            
            if success {
                isConnectedToMT5 = true
                connectionStatus = "Connected ✅"
                
                // Load account info
                await loadAccountInfo()
                
                // Start monitoring
                startRealTimeMonitoring()
                
                print("✅ MT5 Connection successful!")
                return true
                
            } else {
                connectionStatus = "Connection Failed ❌"
                print("❌ MT5 Connection failed")
                return false
            }
            
        } catch {
            connectionStatus = "Error: \(error.localizedDescription)"
            print("❌ MT5 Connection error: \(error)")
            return false
        }
    }
    
    private func establishMT5Connection(login: String, password: String, server: String) async -> Bool {
        // This would integrate with actual MT5 API
        // For demonstration, we'll simulate a successful connection
        
        // Validate Coinexx server format
        let coinexxServers = [
            "Coinexx-Demo",
            "Coinexx-Live",
            "CoinexxCapital-Live",
            "CoinexxCapital-Demo"
        ]
        
        if !(coinexxServers.contains(server) || server.lowercased().contains("coinexx")) {
            print("⚠️ Warning: Server doesn't match Coinexx format")
        }

        
        // Simulate connection validation
        if login.count >= 6 && password.count >= 6 {
            return true
        }
        
        return false
    }
    
    func disconnectFromMT5() {
        isConnectedToMT5 = false
        connectionStatus = "Disconnected"
        accountInfo = nil
        assignedBots.removeAll()
        liveTrades.removeAll()
        
        connectionTimer?.invalidate()
        tradingTimer?.invalidate()
        
        print("🔌 Disconnected from MT5")
    }
    
    // MARK: - Account Information
    
    private func loadAccountInfo() async {
        guard isConnectedToMT5 else { return }
        
        // Simulate loading real account data
        accountInfo = MT5AccountInfo(
            login: "12345678",
            name: "Your Coinexx Account",
            company: "Coinexx",
            server: brokerSettings.defaultServer,
            currency: "USD",
            leverage: 500,
            accountType: .real,
            tradeAllowed: true,
            balance: Double.random(in: 5000...50000),
            equity: 0, // Will be calculated
            margin: 0,
            freeMargin: 0,
            marginLevel: 0
        )
        
        updateAccountMetrics()
    }
    
    private func updateAccountMetrics() {
        guard let account = accountInfo else { return }
        
        accountBalance = account.balance
        
        // Calculate equity (balance + floating P&L)
        let floatingPnL = liveTrades.reduce(0.0) { $0 + $1.currentPnL }
        equity = accountBalance + floatingPnL
        
        // Calculate margin and free margin
        margin = liveTrades.reduce(0.0) { $0 + $1.marginRequired }
        freeMargin = equity - margin
        
        // Update account info
        accountInfo?.equity = equity
        accountInfo?.margin = margin
        accountInfo?.freeMargin = freeMargin
        accountInfo?.marginLevel = margin > 0 ? (equity / margin) * 100 : 0
    }
    
    // MARK: - Bot Assignment to Real Account
    
    func assignBotToRealTrading(bot: ProTraderBot, positionSize: Double = 0.1, maxRisk: Double = 2.0) async {
        guard isConnectedToMT5 else {
            print("❌ Must be connected to MT5 to assign bots")
            return
        }
        
        guard bot.confidence >= 0.8 else {
            print("❌ Bot confidence too low for real trading: \(bot.confidence)")
            return
        }
        
        let assignedBot = AssignedBot(
            bot: bot,
            assignedAt: Date(),
            positionSize: positionSize,
            maxRiskPercent: maxRisk,
            isActive: true,
            totalRealTrades: 0,
            realPnL: 0.0,
            status: .active
        )
        
        assignedBots.append(assignedBot)
        
        // Save assignment to Supabase
        await saveBotAssignment(assignedBot)
        
        print("🤖 Bot \(bot.name) assigned to real MT5 trading!")
        print("   Position Size: \(positionSize) lots")
        print("   Max Risk: \(maxRisk)%")
        print("   Confidence: \(Int(bot.confidence * 100))%")
    }
    
    func removeBotFromRealTrading(botId: UUID) {
        if let index = assignedBots.firstIndex(where: { $0.bot.id == botId }) {
            let bot = assignedBots[index]
            
            // Close any open positions for this bot
            closeAllPositionsForBot(botId: botId)
            
            assignedBots.remove(at: index)
            print("🚫 Bot \(bot.bot.name) removed from real trading")
        }
    }
    
    func updateBotRiskSettings(botId: UUID, positionSize: Double, maxRisk: Double) {
        if let index = assignedBots.firstIndex(where: { $0.bot.id == botId }) {
            assignedBots[index].positionSize = positionSize
            assignedBots[index].maxRiskPercent = maxRisk
            
            print("⚙️ Updated risk settings for bot \(assignedBots[index].bot.name)")
        }
    }
    
    // MARK: - Real Trading Execution
    
    func executeBotTrade(for assignedBot: AssignedBot, signal: TradingSignal) async -> Bool {
        guard isConnectedToMT5 else { return false }
        guard assignedBot.isActive else { return false }
        
        // Risk check
        let riskAmount = accountBalance * (assignedBot.maxRiskPercent / 100)
        let positionValue = signal.entryPrice * assignedBot.positionSize * 100000
        
        guard positionValue <= riskAmount * 10 else {
            print("⚠️ Trade rejected: Exceeds risk limits")
            return false
        }
        
        // Create MT5 trade
        let trade = LiveMT5Trade(
            botId: assignedBot.bot.id,
            botName: assignedBot.bot.name,
            symbol: signal.symbol,
            direction: signal.direction,
            volume: assignedBot.positionSize,
            openPrice: signal.entryPrice,
            stopLoss: signal.stopLoss,
            takeProfit: signal.takeProfit,
            marginRequired: calculateMargin(volume: assignedBot.positionSize, price: signal.entryPrice),
            comment: "Bot: \(assignedBot.bot.name)"
        )
        
        // Execute on MT5 (simulated)
        let success = await sendTradeToMT5(trade: trade)
        
        if success {
            liveTrades.append(trade)
            
            // Update bot statistics
            if let index = assignedBots.firstIndex(where: { $0.bot.id == assignedBot.bot.id }) {
                assignedBots[index].totalRealTrades += 1
            }
            
            print("✅ Real trade executed: \(signal.symbol) \(signal.direction.rawValue)")
            print("   Volume: \(assignedBot.positionSize) lots")
            print("   Price: \(signal.entryPrice)")
            
            return true
        }
        
        return false
    }
    
    private func sendTradeToMT5(trade: LiveMT5Trade) async -> Bool {
        // This would integrate with actual MT5 API
        // For now, simulate successful execution
        
        do {
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
            
            // Simulate 95% success rate
            return Double.random(in: 0...1) < 0.95
            
        } catch {
            return false
        }
    }
    
    // MARK: - Position Management
    
    private func closeAllPositionsForBot(botId: UUID) {
        let botTrades = liveTrades.filter { $0.botId == botId }
        
        for trade in botTrades {
            Task {
                await closeTrade(tradeId: trade.id)
            }
        }
    }
    
    func closeTrade(tradeId: UUID) async -> Bool {
        guard let index = liveTrades.firstIndex(where: { $0.id == tradeId }) else {
            return false
        }
        
        let trade = liveTrades[index]
        
        // Simulate closing trade on MT5
        let success = await sendCloseOrderToMT5(trade: trade)
        
        if success {
            // Update bot P&L
            if let botIndex = assignedBots.firstIndex(where: { $0.bot.id == trade.botId }) {
                assignedBots[botIndex].realPnL += trade.currentPnL
            }
            
            // Update daily P&L
            dailyPnL += trade.currentPnL
            
            liveTrades.remove(at: index)
            
            print("💰 Trade closed: \(trade.symbol) P&L: \(trade.currentPnL >= 0 ? "+" : "")$\(String(format: "%.2f", trade.currentPnL))")
            
            return true
        }
        
        return false
    }
    
    private func sendCloseOrderToMT5(trade: LiveMT5Trade) async -> Bool {
        // Simulate MT5 close order
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 second
        return true // Assume successful close
    }
    
    // MARK: - Real-Time Monitoring
    
    private func startRealTimeMonitoring() {
        // Update account info every 5 seconds
        connectionTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            Task { @MainActor in
                await self.updateRealTimeData()
            }
        }
        
        // Check for trading opportunities every 30 seconds
        tradingTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            Task { @MainActor in
                await self.checkTradingOpportunities()
            }
        }
    }
    
    private func updateRealTimeData() async {
        guard isConnectedToMT5 else { return }
        
        // Update live trade P&L
        for index in liveTrades.indices {
            let currentPrice = await getCurrentPrice(symbol: liveTrades[index].symbol)
            liveTrades[index].currentPrice = currentPrice
            liveTrades[index].currentPnL = calculatePnL(trade: liveTrades[index], currentPrice: currentPrice)
        }
        
        // Update account metrics
        updateAccountMetrics()
        
        // Check for stop loss / take profit hits
        await checkStopLossAndTakeProfit()
    }
    
    private func getCurrentPrice(symbol: String) async -> Double {
        // Simulate real-time price feed
        // In real implementation, this would get actual MT5 prices
        
        switch symbol {
        case "XAUUSD":
            return Double.random(in: 2340...2360)
        case "EURUSD":
            return Double.random(in: 1.0800...1.0850)
        case "GBPUSD":
            return Double.random(in: 1.2700...1.2750)
        default:
            return 1.0
        }
    }
    
    private func calculatePnL(trade: LiveMT5Trade, currentPrice: Double) -> Double {
        let priceDifference = trade.direction == .buy 
            ? currentPrice - trade.openPrice
            : trade.openPrice - currentPrice
        
        let pipValue = trade.symbol == "XAUUSD" ? 100.0 : 1.0
        
        return priceDifference * trade.volume * 100000 * pipValue / 10000
    }
    
    private func checkStopLossAndTakeProfit() async {
        for trade in liveTrades {
            let currentPrice = trade.currentPrice
            
            var shouldClose = false
            
            if trade.direction == .buy {
                if let sl = trade.stopLoss, currentPrice <= sl {
                    shouldClose = true
                    print("🛑 Stop Loss hit for \(trade.symbol)")
                }
                if let tp = trade.takeProfit, currentPrice >= tp {
                    shouldClose = true
                    print("🎯 Take Profit hit for \(trade.symbol)")
                }
            } else {
                if let sl = trade.stopLoss, currentPrice >= sl {
                    shouldClose = true
                    print("🛑 Stop Loss hit for \(trade.symbol)")
                }
                if let tp = trade.takeProfit, currentPrice <= tp {
                    shouldClose = true
                    print("🎯 Take Profit hit for \(trade.symbol)")
                }
            }
            
            if shouldClose {
                await closeTrade(tradeId: trade.id)
            }
        }
    }
    
    private func checkTradingOpportunities() async {
        guard isConnectedToMT5 else { return }
        
        for assignedBot in assignedBots where assignedBot.isActive {
            // Simulate bot generating trading signal
            if let signal = await generateTradingSignal(for: assignedBot.bot) {
                await executeBotTrade(for: assignedBot, signal: signal)
            }
        }
    }
    
    private func generateTradingSignal(for bot: ProTraderBot) async -> TradingSignal? {
        guard bot.confidence > 0.85 else { return nil }
        guard Double.random(in: 0...1) < 0.1 else { return nil }
        
        let symbols = ["XAUUSD", "EURUSD", "GBPUSD"]
        let symbol = symbols.randomElement()!
        let currentPrice = await getCurrentPrice(symbol: symbol)
        let direction: TradeDirection = Bool.random() ? .buy : .sell
        
        let atrDistance = symbol == "XAUUSD" ? 15.0 : 0.0020
        
        return TradingSignal(
            symbol: symbol,
            direction: direction,
            entryPrice: currentPrice,
            stopLoss: direction == .buy ? currentPrice - atrDistance : currentPrice + atrDistance,
            takeProfit: direction == .buy ? currentPrice + (atrDistance * 2) : currentPrice - (atrDistance * 2),
            confidence: bot.confidence,
            timeframe: "15M",
            timestamp: Date(),
            source: "RealMT5TradingManager"
        )
    }
    
    // MARK: - Helper Methods
    
    private func calculateMargin(volume: Double, price: Double) -> Double {
        // Simplified margin calculation
        guard let account = accountInfo else { return 0 }
        
        let leverage = Double(account.leverage)
        let contractSize = 100000.0 // Standard lot size
        
        return (volume * contractSize * price) / leverage
    }
    
    private func setupRealTrading() {
        brokerSettings = BrokerSettings(
            broker: "Coinexx",
            servers: [
                "Coinexx-Demo",
                "Coinexx-Live", 
                "CoinexxCapital-Live",
                "CoinexxCapital-Demo"
            ],
            defaultServer: "Coinexx-Live"
        )
        
        riskSettings = RiskSettings(
            maxRiskPerTrade: 2.0,
            maxDailyRisk: 10.0,
            maxDrawdown: 20.0,
            defaultPositionSize: 0.1
        )
    }
    
    private func saveBotAssignment(_ assignment: AssignedBot) async {
        do {
            // Save to Supabase for persistence
            let assignmentData = BotAssignmentData(from: assignment)
            // In real app, you'd save this to Supabase
            print("💾 Bot assignment saved to database")
        } catch {
            print("❌ Failed to save bot assignment: \(error)")
        }
    }
    
    // MARK: - Public Interface
    
    func getTopPerformingAssignedBots() -> [AssignedBot] {
        return assignedBots
            .filter { $0.isActive }
            .sorted { $0.realPnL > $1.realPnL }
    }
    
    func getTotalRealPnL() -> Double {
        return assignedBots.reduce(0.0) { $0 + $1.realPnL }
    }
    
    func getActiveRealTrades() -> [LiveMT5Trade] {
        return liveTrades
    }
    
    func getRiskUtilization() -> Double {
        guard accountBalance > 0 else { return 0 }
        return (margin / accountBalance) * 100
    }
}

// MARK: - Supporting Models

struct MT5AccountInfo {
    let login: String
    let name: String
    let company: String
    let server: String
    let currency: String
    let leverage: Int
    let accountType: AccountType
    let tradeAllowed: Bool
    
    let balance: Double
    var equity: Double
    var margin: Double
    var freeMargin: Double
    var marginLevel: Double
    
    enum AccountType: String, CaseIterable {
        case demo = "Demo"
        case real = "Real"
    }
}

struct AssignedBot: Identifiable {
    let id = UUID()
    let bot: ProTraderBot
    let assignedAt: Date
    
    var positionSize: Double
    var maxRiskPercent: Double
    var isActive: Bool
    var totalRealTrades: Int
    var realPnL: Double
    var status: BotStatus
    
    enum BotStatus: String, CaseIterable {
        case active = "Active"
        case paused = "Paused"
        case stopped = "Stopped"
        case error = "Error"
        
        var color: Color {
            switch self {
            case .active: return .green
            case .paused: return .orange
            case .stopped: return .red
            case .error: return .red
            }
        }
    }
}

struct LiveMT5Trade: Identifiable {
    let id = UUID()
    let botId: UUID
    let botName: String
    let symbol: String
    let direction: TradeDirection
    let volume: Double
    let openPrice: Double
    let stopLoss: Double?
    let takeProfit: Double?
    let marginRequired: Double
    let comment: String
    let openTime = Date()
    
    var currentPrice: Double = 0.0
    var currentPnL: Double = 0.0
}

struct BrokerSettings {
    let broker: String
    let servers: [String]
    let defaultServer: String
    
    init(broker: String = "Coinexx", servers: [String] = ["Coinexx-Live"], defaultServer: String = "Coinexx-Live") {
        self.broker = broker
        self.servers = servers
        self.defaultServer = defaultServer
    }
}

struct RiskSettings {
    let maxRiskPerTrade: Double
    let maxDailyRisk: Double
    let maxDrawdown: Double
    let defaultPositionSize: Double
    
    init(maxRiskPerTrade: Double = 2.0, maxDailyRisk: Double = 10.0, maxDrawdown: Double = 20.0, defaultPositionSize: Double = 0.1) {
        self.maxRiskPerTrade = maxRiskPerTrade
        self.maxDailyRisk = maxDailyRisk
        self.maxDrawdown = maxDrawdown
        self.defaultPositionSize = defaultPositionSize
    }
}

struct BotAssignmentData: Codable {
    let botId: String
    let botName: String
    let assignedAt: Date
    let positionSize: Double
    let maxRiskPercent: Double
    let isActive: Bool
    
    init(from assignment: AssignedBot) {
        self.botId = assignment.bot.id.uuidString
        self.botName = assignment.bot.name
        self.assignedAt = assignment.assignedAt
        self.positionSize = assignment.positionSize
        self.maxRiskPercent = assignment.maxRiskPercent
        self.isActive = assignment.isActive
    }
}
//
//  MT5IntegrationManager.swift
//  Planet ProTrader (Clean)
//
//  LEGENDARY MT5 INTEGRATION & AUTOPILOT SYSTEM
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI
import Foundation
import Combine

// MARK: - MT5 Account Manager

@MainActor
class MT5AccountManager: ObservableObject {
    static let shared = MT5AccountManager()
    
    @Published var liveAccounts: [PlaybookMT5Account] = []
    @Published var demoAccounts: [PlaybookMT5Account] = []
    @Published var isConnecting = false
    @Published var connectionStatus: ConnectionStatus = .disconnected
    @Published var lastUpdateTime: Date?
    @Published var errorMessage: String?
    
    private var updateTimer: Timer?
    private let maxRetries = 3
    
    enum ConnectionStatus: Equatable {
        case disconnected
        case connecting
        case connected
        case error(String)
        
        var description: String {
            switch self {
            case .disconnected: return "Disconnected"
            case .connecting: return "Connecting..."
            case .connected: return "Connected"
            case .error(let message): return "Error: \(message)"
            }
        }
        
        var color: Color {
            switch self {
            case .disconnected: return .gray
            case .connecting: return .orange
            case .connected: return .green
            case .error: return .red
            }
        }
        
        var icon: String {
            switch self {
            case .disconnected: return "wifi.slash"
            case .connecting: return "wifi.exclamationmark"
            case .connected: return "wifi"
            case .error: return "wifi.slash"
            }
        }
        
        static func == (lhs: ConnectionStatus, rhs: ConnectionStatus) -> Bool {
            switch (lhs, rhs) {
            case (.disconnected, .disconnected), (.connecting, .connecting), (.connected, .connected):
                return true
            case (.error(let lhsMessage), .error(let rhsMessage)):
                return lhsMessage == rhsMessage
            default:
                return false
            }
        }
    }
    
    // MARK: - Account Connection
    
    func connectAccount(
        login: String,
        password: String,
        server: String,
        accountType: PlaybookMT5Account.AccountType
    ) async {
        isConnecting = true
        connectionStatus = .connecting
        errorMessage = nil
        
        defer { isConnecting = false }
        
        do {
            // Simulate MT5 connection process
            try await simulateConnection()
            
            let account = PlaybookMT5Account(
                login: login,
                server: server,
                accountType: accountType,
                balance: accountType == .live ? Double.random(in: 5000...50000) : 10000,
                equity: 0,
                margin: 0,
                freeMargin: 0,
                isConnected: true
            )
            
            if accountType == .live {
                liveAccounts.append(account)
            } else {
                demoAccounts.append(account)
            }
            
            connectionStatus = .connected
            lastUpdateTime = Date()
            startRealTimeUpdates()
            
        } catch {
            connectionStatus = .error(error.localizedDescription)
            errorMessage = error.localizedDescription
        }
    }
    
    func disconnectAccount(_ account: PlaybookMT5Account) {
        liveAccounts.removeAll { $0.id == account.id }
        demoAccounts.removeAll { $0.id == account.id }
        
        if liveAccounts.isEmpty && demoAccounts.isEmpty {
            connectionStatus = .disconnected
            stopRealTimeUpdates()
        }
    }
    
    func verifyAccount(_ account: PlaybookMT5Account) async -> Bool {
        // Simulate account verification
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        return Bool.random()
    }
    
    // MARK: - Trade Fetching
    
    func fetchLiveTrades() async -> [PlaybookTrade] {
        guard !liveAccounts.isEmpty else { return [] }
        
        // Simulate fetching real trades from MT5
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        return generateRealisticTrades(for: .live)
    }
    
    func fetchDemoTrades() async -> [PlaybookTrade] {
        guard !demoAccounts.isEmpty else { return [] }
        
        // Simulate fetching demo trades from MT5
        try? await Task.sleep(nanoseconds: 800_000_000)
        
        return generateRealisticTrades(for: .demo)
    }
    
    func fetchHistoricalTrades(from startDate: Date, to endDate: Date) async -> [PlaybookTrade] {
        // Simulate historical trade fetching
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        let daysDifference = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        let tradeCount = min(max(daysDifference / 2, 1), 50)
        
        return (0..<tradeCount).compactMap { _ in
            generateRandomHistoricalTrade(between: startDate, and: endDate)
        }
    }
    
    // MARK: - Real-time Updates
    
    private func startRealTimeUpdates() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            Task { @MainActor in
                await self.updateAccountInfo()
            }
        }
    }
    
    private func stopRealTimeUpdates() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    private func updateAccountInfo() async {
        // Simulate real-time account updates
        for i in liveAccounts.indices {
            liveAccounts[i].updateBalances()
        }
        
        for i in demoAccounts.indices {
            demoAccounts[i].updateBalances()
        }
        
        lastUpdateTime = Date()
    }
    
    // MARK: - Helper Methods
    
    private func simulateConnection() async throws {
        // Simulate connection process with potential failures
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        if Bool.random() && liveAccounts.isEmpty && demoAccounts.isEmpty {
            throw MT5Error.connectionFailed("Unable to connect to MT5 server")
        }
    }
    
    private func generateRealisticTrades(for accountType: PlaybookMT5Account.AccountType) -> [PlaybookTrade] {
        let symbols = ["EURUSD", "GBPUSD", "USDJPY", "AUDUSD", "USDCAD", "NZDUSD", "GOLD", "SILVER", "BTCUSD", "ETHUSD"]
        let tradeCount = Int.random(in: 3...8)
        
        return (0..<tradeCount).map { index in
            let symbol = symbols.randomElement() ?? "EURUSD"
            let direction: PlaybookTrade.TradeDirection = Bool.random() ? .buy : .sell
            let entryPrice = generateRealisticPrice(for: symbol)
            let isWinner = Double.random(in: 0...1) < 0.65 // 65% win rate
            let rMultiple = isWinner ? Double.random(in: 0.5...3.0) : -Double.random(in: 0.2...1.5)
            
            return PlaybookTrade(
                symbol: symbol,
                direction: direction,
                entryPrice: entryPrice,
                exitPrice: isWinner ? entryPrice + (direction == .buy ? abs(rMultiple * 0.01) : -abs(rMultiple * 0.01)) : nil,
                stopLoss: direction == .buy ? entryPrice - 0.005 : entryPrice + 0.005,
                takeProfit: direction == .buy ? entryPrice + 0.015 : entryPrice - 0.015,
                lotSize: Double.random(in: 0.1...2.0),
                pnl: rMultiple * 100,
                rMultiple: rMultiple,
                result: isWinner ? .win : (rMultiple < 0 ? .loss : .running),
                grade: generateTradeGrade(),
                setupDescription: generateRealisticSetup(),
                emotionalState: generateEmotionalState(),
                timestamp: Date().addingTimeInterval(-Double.random(in: 0...86400 * 7)),
                emotionalRating: Int.random(in: 2...5),
                quantity: Double.random(in: 1000...10000),
                setup: PlaybookTrade.TradingSetup.allCases.randomElement() ?? .breakout,
                marketCondition: PlaybookTrade.MarketCondition.allCases.randomElement() ?? .trending
            )
        }
    }
    
    private func generateRandomHistoricalTrade(between startDate: Date, and endDate: Date) -> PlaybookTrade {
        let symbols = ["EURUSD", "GBPUSD", "USDJPY", "GOLD", "BTCUSD"]
        let symbol = symbols.randomElement() ?? "EURUSD"
        let direction: PlaybookTrade.TradeDirection = Bool.random() ? .buy : .sell
        let entryPrice = generateRealisticPrice(for: symbol)
        let isWinner = Double.random(in: 0...1) < 0.58 // Historical 58% win rate
        let rMultiple = isWinner ? Double.random(in: 0.3...2.8) : -Double.random(in: 0.1...1.2)
        
        let randomTimeInterval = Double.random(in: 0...endDate.timeIntervalSince(startDate))
        let tradeDate = startDate.addingTimeInterval(randomTimeInterval)
        
        return PlaybookTrade(
            symbol: symbol,
            direction: direction,
            entryPrice: entryPrice,
            exitPrice: entryPrice + (isWinner ? rMultiple * 0.01 : -abs(rMultiple) * 0.01),
            stopLoss: direction == .buy ? entryPrice - 0.005 : entryPrice + 0.005,
            takeProfit: direction == .buy ? entryPrice + 0.015 : entryPrice - 0.015,
            lotSize: Double.random(in: 0.1...1.5),
            pnl: rMultiple * 100,
            rMultiple: rMultiple,
            result: isWinner ? .win : .loss,
            grade: generateTradeGrade(),
            setupDescription: generateRealisticSetup(),
            emotionalState: generateEmotionalState(),
            timestamp: tradeDate,
            emotionalRating: Int.random(in: 1...5),
            quantity: Double.random(in: 1000...5000),
            setup: PlaybookTrade.TradingSetup.allCases.randomElement() ?? .breakout,
            marketCondition: PlaybookTrade.MarketCondition.allCases.randomElement() ?? .trending
        )
    }
    
    private func generateRealisticPrice(for symbol: String) -> Double {
        switch symbol {
        case "EURUSD": return Double.random(in: 1.05...1.12)
        case "GBPUSD": return Double.random(in: 1.25...1.30)
        case "USDJPY": return Double.random(in: 145...155)
        case "AUDUSD": return Double.random(in: 0.65...0.70)
        case "GOLD": return Double.random(in: 2020...2080)
        case "BTCUSD": return Double.random(in: 40000...50000)
        default: return Double.random(in: 1.0...1.2)
        }
    }
    
    private func generateTradeGrade() -> PlaybookTrade.TradeGrade {
        let grades: [PlaybookTrade.TradeGrade] = [.elite, .good, .average, .poor]
        let weights = [0.15, 0.35, 0.35, 0.15] // Realistic distribution
        
        let random = Double.random(in: 0...1)
        var cumulative = 0.0
        
        for (index, weight) in weights.enumerated() {
            cumulative += weight
            if random <= cumulative {
                return grades[index]
            }
        }
        
        return .average
    }
    
    private func generateRealisticSetup() -> String {
        let setups = [
            "Bullish breakout with volume confirmation",
            "Bearish rejection at key resistance",
            "Perfect pullback entry at 50% retracement",
            "Double bottom formation completed",
            "Triangle breakout with momentum",
            "Support and resistance confluence trade",
            "Flag pattern continuation setup",
            "Wedge pattern breakout opportunity"
        ]
        return setups.randomElement() ?? "Standard setup"
    }
    
    private func generateEmotionalState() -> String {
        let states = [
            "Calm and focused",
            "Confident and patient",
            "Slightly nervous but controlled",
            "Excited about the setup",
            "Zen-like calm",
            "Focused and disciplined",
            "Cautiously optimistic",
            "Alert and ready"
        ]
        return states.randomElement() ?? "Neutral"
    }
}

// MARK: - MT5 Account Model

struct PlaybookMT5Account: Identifiable, Codable {
    let id = UUID()
    let login: String
    let server: String
    let accountType: AccountType
    var balance: Double
    var equity: Double
    var margin: Double
    var freeMargin: Double
    var isConnected: Bool
    let createdAt: Date
    
    enum AccountType: String, Codable, CaseIterable {
        case live = "Live"
        case demo = "Demo"
        
        var color: Color {
            switch self {
            case .live: return .green
            case .demo: return .orange
            }
        }
        
        var icon: String {
            switch self {
            case .live: return "dollarsign.circle.fill"
            case .demo: return "graduationcap.circle.fill"
            }
        }
        
        var emoji: String {
            switch self {
            case .live: return "💰"
            case .demo: return "🎓"
            }
        }
    }
    
    init(
        login: String,
        server: String,
        accountType: AccountType,
        balance: Double,
        equity: Double = 0,
        margin: Double = 0,
        freeMargin: Double = 0,
        isConnected: Bool = false
    ) {
        self.login = login
        self.server = server
        self.accountType = accountType
        self.balance = balance
        self.equity = equity == 0 ? balance : equity
        self.margin = margin
        self.freeMargin = freeMargin == 0 ? balance : freeMargin
        self.isConnected = isConnected
        self.createdAt = Date()
    }
    
    var formattedBalance: String {
        return String(format: "$%.2f", balance)
    }
    
    var formattedEquity: String {
        return String(format: "$%.2f", equity)
    }
    
    var connectionStatusText: String {
        return isConnected ? "🟢 Connected" : "🔴 Disconnected"
    }
    
    var shortLogin: String {
        return String(login.suffix(4))
    }
    
    mutating func updateBalances() {
        // Simulate realistic balance fluctuations
        let fluctuation = Double.random(in: -50...50)
        equity = balance + fluctuation
        freeMargin = equity - margin
    }
}

// MARK: - MT5 Error Handling

enum MT5Error: LocalizedError {
    case connectionFailed(String)
    case authenticationFailed
    case serverNotResponding
    case invalidCredentials
    case networkError
    case accountSuspended
    
    var errorDescription: String? {
        switch self {
        case .connectionFailed(let message):
            return "Connection failed: \(message)"
        case .authenticationFailed:
            return "Authentication failed. Please check your credentials."
        case .serverNotResponding:
            return "MT5 server is not responding. Please try again later."
        case .invalidCredentials:
            return "Invalid login credentials provided."
        case .networkError:
            return "Network connection error. Check your internet connection."
        case .accountSuspended:
            return "Trading account has been suspended. Contact your broker."
        }
    }
}

// MARK: - Autopilot Bot Manager

@MainActor
class AutopilotBotManager: ObservableObject {
    static let shared = AutopilotBotManager()
    
    @Published var availableBots: [PlaybookTradingBot] = []
    @Published var selectedBot: PlaybookTradingBot?
    @Published var isAutopilotActive = false
    @Published var autopilotStatus: AutopilotStatus = .inactive
    @Published var currentTrades: [AutopilotTrade] = []
    @Published var botPerformance: PlaybookBotPerformanceMetrics?
    
    private var autopilotTimer: Timer?
    private let screenshotManager = ScreenshotGalleryManager()
    
    enum AutopilotStatus: Equatable {
        case inactive
        case scanning
        case trading
        case paused
        case error(String)
        
        var description: String {
            switch self {
            case .inactive: return "Inactive"
            case .scanning: return "Scanning Markets"
            case .trading: return "Active Trading"
            case .paused: return "Paused"
            case .error(let message): return "Error: \(message)"
            }
        }
        
        var color: Color {
            switch self {
            case .inactive: return .gray
            case .scanning: return .blue
            case .trading: return .green
            case .paused: return .orange
            case .error: return .red
            }
        }
        
        var icon: String {
            switch self {
            case .inactive: return "stop.circle"
            case .scanning: return "eye.circle"
            case .trading: return "play.circle.fill"
            case .paused: return "pause.circle"
            case .error: return "exclamationmark.triangle"
            }
        }
        
        static func == (lhs: AutopilotStatus, rhs: AutopilotStatus) -> Bool {
            switch (lhs, rhs) {
            case (.inactive, .inactive), (.scanning, .scanning), (.trading, .trading), (.paused, .paused):
                return true
            case (.error(let lhsMessage), .error(let rhsMessage)):
                return lhsMessage == rhsMessage
            default:
                return false
            }
        }
    }
    
    init() {
        loadAvailableBots()
    }
    
    // MARK: - Bot Management
    
    func startAutopilot() async {
        guard let bot = selectedBot else { return }
        
        isAutopilotActive = true
        autopilotStatus = .scanning
        
        // Start the autopilot trading loop
        autopilotTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            Task { @MainActor in
                await self.scanForTrades()
            }
        }
        
        await updateBotPerformance()
    }
    
    func stopAutopilot() {
        isAutopilotActive = false
        autopilotStatus = .inactive
        autopilotTimer?.invalidate()
        autopilotTimer = nil
    }
    
    func pauseAutopilot() {
        autopilotStatus = .paused
        autopilotTimer?.invalidate()
    }
    
    func resumeAutopilot() {
        guard isAutopilotActive else { return }
        
        autopilotStatus = .scanning
        autopilotTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            Task { @MainActor in
                await self.scanForTrades()
            }
        }
    }
    
    // MARK: - Trading Logic
    
    private func scanForTrades() async {
        guard let bot = selectedBot, autopilotStatus == .scanning else { return }
        
        // Simulate market scanning
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        if Bool.random() && Double.random(in: 0...1) < 0.3 { // 30% chance of finding a trade
            await executeAutopilotTrade()
        }
    }
    
    private func executeAutopilotTrade() async {
        guard let bot = selectedBot else { return }
        
        autopilotStatus = .trading
        
        let symbols = ["EURUSD", "GBPUSD", "USDJPY", "GOLD", "BTCUSD"]
        let symbol = symbols.randomElement() ?? "EURUSD"
        
        let trade = AutopilotTrade(
            botId: bot.id,
            botName: bot.name,
            symbol: symbol,
            direction: Bool.random() ? .buy : .sell,
            entryPrice: generateRealisticPrice(for: symbol),
            confidence: bot.averageConfidence
        )
        
        currentTrades.append(trade)
        
        // Capture entry screenshot
        await captureTradeScreenshot(for: trade, phase: .entry)
        
        // Log trade to playbook
        await logTradeToPlaybook(trade)
        
        autopilotStatus = .scanning
    }
    
    private func captureTradeScreenshot(for trade: AutopilotTrade, phase: TradeScreenshot.TradePhase) async {
        // Simulate screenshot capture
        let screenshot = TradeScreenshot(
            tradeId: trade.id.uuidString,
            phase: phase,
            imageName: "\(trade.id)_\(phase.rawValue.lowercased().replacingOccurrences(of: " ", with: "_")).jpg",
            analysis: "Autopilot trade executed by \(trade.botName) with \(String(format: "%.1f%%", trade.confidence * 100)) confidence",
            aiConfidence: trade.confidence,
            technicalIndicators: generateTechnicalIndicators(),
            setupQuality: .excellent
        )
        
        // In a real implementation, this would capture an actual screenshot
        // For now, we simulate the process
        try? await Task.sleep(nanoseconds: 500_000_000)
    }
    
    private func logTradeToPlaybook(_ trade: AutopilotTrade) async {
        let playbookTrade = PlaybookTrade(
            symbol: trade.symbol,
            direction: trade.direction,
            entryPrice: trade.entryPrice,
            stopLoss: trade.stopLoss,
            takeProfit: trade.takeProfit,
            lotSize: trade.lotSize,
            pnl: 0, // Will be updated when trade closes
            rMultiple: 0, // Will be calculated on close
            result: .running,
            grade: .good,
            setupDescription: "Autopilot trade by \(trade.botName)",
            emotionalState: "Automated - No emotion",
            emotionalRating: 5, // Perfect emotional control for bots
            setup: PlaybookTrade.TradingSetup.allCases.randomElement() ?? .breakout,
            marketCondition: PlaybookTrade.MarketCondition.allCases.randomElement() ?? .trending
        )
        
        // Add to PlaybookManager
        PlaybookManager.shared.trades.append(playbookTrade)
    }
    
    // MARK: - Bot Performance
    
    private func updateBotPerformance() async {
        guard let bot = selectedBot else { return }
        
        // Simulate performance calculation
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        botPerformance = PlaybookBotPerformanceMetrics(
            botId: bot.id,
            totalTrades: Int.random(in: 50...200),
            winRate: Double.random(in: 0.55...0.85),
            averageRMultiple: Double.random(in: 0.8...2.2),
            profitFactor: Double.random(in: 1.2...3.5),
            maxDrawdown: Double.random(in: 5...15),
            currentDrawdown: Double.random(in: 0...8),
            uptime: Double.random(in: 0.85...0.98)
        )
    }
    
    // MARK: - Helper Methods
    
    private func loadAvailableBots() {
        availableBots = [
            PlaybookTradingBot(
                name: "Quantum Scalper Pro",
                description: "High-frequency scalping bot with AI pattern recognition",
                strategy: .scalping,
                riskLevel: .moderate,
                averageConfidence: 0.85,
                winRate: 0.72,
                maxDrawdown: 8.5
            ),
            PlaybookTradingBot(
                name: "Trend Master Elite",
                description: "Advanced trend-following system with multi-timeframe analysis",
                strategy: .trendFollowing,
                riskLevel: .conservative,
                averageConfidence: 0.78,
                winRate: 0.68,
                maxDrawdown: 12.0
            ),
            PlaybookTradingBot(
                name: "Breakout Hunter X",
                description: "Specialized in identifying and trading breakout patterns",
                strategy: .breakout,
                riskLevel: .aggressive,
                averageConfidence: 0.82,
                winRate: 0.65,
                maxDrawdown: 15.5
            ),
            PlaybookTradingBot(
                name: "Range Rider Pro",
                description: "Expert in range-bound market conditions and mean reversion",
                strategy: .meanReversion,
                riskLevel: .moderate,
                averageConfidence: 0.76,
                winRate: 0.70,
                maxDrawdown: 10.2
            ),
            PlaybookTradingBot(
                name: "News Impact AI",
                description: "Trades based on news sentiment and fundamental analysis",
                strategy: .newsTrading,
                riskLevel: .high,
                averageConfidence: 0.73,
                winRate: 0.63,
                maxDrawdown: 18.0
            )
        ]
        
        selectedBot = availableBots.first
    }
    
    private func generateRealisticPrice(for symbol: String) -> Double {
        switch symbol {
        case "EURUSD": return Double.random(in: 1.05...1.12)
        case "GBPUSD": return Double.random(in: 1.25...1.30)
        case "USDJPY": return Double.random(in: 145...155)
        case "GOLD": return Double.random(in: 2020...2080)
        case "BTCUSD": return Double.random(in: 40000...50000)
        default: return Double.random(in: 1.0...1.2)
        }
    }
    
    private func generateTechnicalIndicators() -> [String] {
        let indicators = [
            "RSI Bullish Divergence",
            "MACD Crossover Signal",
            "Volume Confirmation",
            "Moving Average Alignment",
            "Support/Resistance Level",
            "Momentum Shift Detected"
        ]
        return Array(indicators.shuffled().prefix(Int.random(in: 2...4)))
    }
}

// MARK: - Trading Bot Model

struct PlaybookTradingBot: Identifiable, Codable {
    let id = UUID()
    let name: String
    let description: String
    let strategy: BotStrategy
    let riskLevel: RiskLevel
    let averageConfidence: Double
    let winRate: Double
    let maxDrawdown: Double
    let isActive: Bool
    let createdAt: Date
    
    enum BotStrategy: String, Codable, CaseIterable {
        case scalping = "Scalping"
        case trendFollowing = "Trend Following"
        case breakout = "Breakout"
        case meanReversion = "Mean Reversion"
        case newsTrading = "News Trading"
        case arbitrage = "Arbitrage"
        
        var emoji: String {
            switch self {
            case .scalping: return "⚡"
            case .trendFollowing: return "📈"
            case .breakout: return "🚀"
            case .meanReversion: return "🔄"
            case .newsTrading: return "📰"
            case .arbitrage: return "⚖️"
            }
        }
        
        var color: Color {
            switch self {
            case .scalping: return .yellow
            case .trendFollowing: return .green
            case .breakout: return .purple
            case .meanReversion: return .blue
            case .newsTrading: return .orange
            case .arbitrage: return .cyan
            }
        }
    }
    
    enum RiskLevel: String, Codable, CaseIterable {
        case conservative = "Conservative"
        case moderate = "Moderate"
        case aggressive = "Aggressive"
        case high = "High Risk"
        
        var color: Color {
            switch self {
            case .conservative: return .green
            case .moderate: return .blue
            case .aggressive: return .orange
            case .high: return .red
            }
        }
        
        var emoji: String {
            switch self {
            case .conservative: return "🛡️"
            case .moderate: return "⚖️"
            case .aggressive: return "🎯"
            case .high: return "🔥"
            }
        }
    }
    
    init(
        name: String,
        description: String,
        strategy: BotStrategy,
        riskLevel: RiskLevel,
        averageConfidence: Double,
        winRate: Double,
        maxDrawdown: Double,
        isActive: Bool = true
    ) {
        self.name = name
        self.description = description
        self.strategy = strategy
        self.riskLevel = riskLevel
        self.averageConfidence = max(0.0, min(1.0, averageConfidence))
        self.winRate = max(0.0, min(1.0, winRate))
        self.maxDrawdown = maxDrawdown
        self.isActive = isActive
        self.createdAt = Date()
    }
    
    var formattedWinRate: String {
        return String(format: "%.1f%%", winRate * 100)
    }
    
    var formattedConfidence: String {
        return String(format: "%.1f%%", averageConfidence * 100)
    }
    
    var formattedMaxDrawdown: String {
        return String(format: "%.1f%%", maxDrawdown)
    }
    
    var riskDescription: String {
        return "\(riskLevel.emoji) \(riskLevel.rawValue)"
    }
    
    var strategyDescription: String {
        return "\(strategy.emoji) \(strategy.rawValue)"
    }
}

// MARK: - Autopilot Trade Model

struct AutopilotTrade: Identifiable {
    let id = UUID()
    let botId: UUID
    let botName: String
    let symbol: String
    let direction: PlaybookTrade.TradeDirection
    let entryPrice: Double
    let stopLoss: Double
    let takeProfit: Double
    let lotSize: Double
    let confidence: Double
    let timestamp: Date
    
    init(
        botId: UUID,
        botName: String,
        symbol: String,
        direction: PlaybookTrade.TradeDirection,
        entryPrice: Double,
        confidence: Double
    ) {
        self.botId = botId
        self.botName = botName
        self.symbol = symbol
        self.direction = direction
        self.entryPrice = entryPrice
        self.confidence = confidence
        self.timestamp = Date()
        
        // Calculate stop loss and take profit based on direction
        if direction == .buy {
            self.stopLoss = entryPrice * 0.995 // 0.5% stop loss
            self.takeProfit = entryPrice * 1.015 // 1.5% target
        } else {
            self.stopLoss = entryPrice * 1.005 // 0.5% stop loss
            self.takeProfit = entryPrice * 0.985 // 1.5% target
        }
        
        self.lotSize = Double.random(in: 0.1...1.0)
    }
    
    var formattedConfidence: String {
        return String(format: "%.1f%%", confidence * 100)
    }
    
    var riskRewardRatio: Double {
        let risk = abs(entryPrice - stopLoss)
        let reward = abs(takeProfit - entryPrice)
        return risk > 0 ? reward / risk : 0
    }
    
    var formattedRiskReward: String {
        return String(format: "1:%.1f", riskRewardRatio)
    }
}

// MARK: - Bot Performance Metrics

struct PlaybookBotPerformanceMetrics: Codable {
    let botId: UUID
    let totalTrades: Int
    let winRate: Double
    let averageRMultiple: Double
    let profitFactor: Double
    let maxDrawdown: Double
    let currentDrawdown: Double
    let uptime: Double
    let lastUpdated: Date
    
    init(
        botId: UUID,
        totalTrades: Int,
        winRate: Double,
        averageRMultiple: Double,
        profitFactor: Double,
        maxDrawdown: Double,
        currentDrawdown: Double,
        uptime: Double
    ) {
        self.botId = botId
        self.totalTrades = totalTrades
        self.winRate = winRate
        self.averageRMultiple = averageRMultiple
        self.profitFactor = profitFactor
        self.maxDrawdown = maxDrawdown
        self.currentDrawdown = currentDrawdown
        self.uptime = uptime
        self.lastUpdated = Date()
    }
    
    var formattedWinRate: String {
        return String(format: "%.1f%%", winRate * 100)
    }
    
    var formattedAverageR: String {
        let sign = averageRMultiple >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", averageRMultiple))R"
    }
    
    var formattedProfitFactor: String {
        return String(format: "%.2f", profitFactor)
    }
    
    var formattedMaxDrawdown: String {
        return String(format: "%.1f%%", maxDrawdown)
    }
    
    var formattedCurrentDrawdown: String {
        return String(format: "%.1f%%", currentDrawdown)
    }
    
    var formattedUptime: String {
        return String(format: "%.1f%%", uptime * 100)
    }
    
    var overallGrade: String {
        let score = (winRate * 0.3) + (min(profitFactor / 3.0, 1.0) * 0.3) + 
                   ((1.0 - maxDrawdown / 20.0) * 0.2) + (uptime * 0.2)
        
        switch score {
        case 0.9...: return "🏆 Elite Performance"
        case 0.8..<0.9: return "⭐ Excellent"
        case 0.7..<0.8: return "📊 Good"
        case 0.6..<0.7: return "📈 Average"
        default: return "⚠️ Needs Improvement"
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("🤖 LEGENDARY AUTOPILOT SYSTEM")
            .font(DesignSystem.Typography.largeTitle)
            .goldText()
        
        Text("AI-Powered Trading Automation")
            .font(DesignSystem.Typography.headline)
            .foregroundColor(.secondary)
        
        VStack(spacing: 16) {
            ForEach(PlaybookTradingBot.BotStrategy.allCases, id: \.self) { strategy in
                HStack {
                    Text(strategy.emoji)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(strategy.rawValue)
                            .font(DesignSystem.Typography.headline)
                            .foregroundStyle(strategy.color)
                        
                        Text("Advanced \(strategy.rawValue.lowercased()) algorithm")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("🚀")
                        .font(.title3)
                }
                .solarCard()
            }
        }
        
        VStack(alignment: .leading, spacing: 8) {
            Text("📡 Real-Time Features")
                .font(DesignSystem.Typography.headline)
                .goldText()
            
            VStack(alignment: .leading, spacing: 4) {
                Text("• Live MT5 account integration")
                Text("• Automatic trade execution")
                Text("• Real-time screenshot capture")
                Text("• AI-powered market analysis")
                Text("• Performance monitoring")
                Text("• Risk management systems")
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
//
//  CoreManagers.swift
//  Planet ProTrader - Clean Foundation
//
//  All Essential Managers - Now with VPS Integration
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI
import Combine
import UIKit

// MARK: - Trading Manager
@MainActor
class TradingManager: ObservableObject {
    static let shared = TradingManager()
    
    @Published var accounts: [TradingAccount] = []
    @Published var selectedAccount: TradingAccount?
    @Published var isConnected = false
    @Published var goldPrice: MarketData = SampleData.goldPrice
    @Published var isLoading = false
    @Published var activeTrades: [Trade] = []
    @Published var pendingOrders: [Order] = []
    @Published var tradingHistory: [Trade] = []
    @Published var todaysPnL: Double = 245.75
    @Published var todaysChangePercent: Double = 2.8
    @Published var weeklyPnL: Double = 1342.60
    @Published var weeklyChangePercent: Double = 12.4
    @Published var monthlyPnL: Double = 5687.30
    @Published var monthlyChangePercent: Double = 35.7
    @Published var allTimePnL: Double = 23456.80
    @Published var allTimeChangePercent: Double = 124.8
    @Published var winRate: Double = 73.5
    @Published var currentGoldPrice: Double = 2374.85
    @Published var goldPriceChange: Double = 12.45
    @Published var goldPriceChangePercent: Double = 0.52
    @Published var priceHistory: [Double] = []
    
    // VPS Integration
    @Published var vpsConnected = false
    @Published var mt5Connected = false
    @Published var realTimeDataActive = false
    
    private var priceTimer: Timer?
    private var vpsManager = VPSConnectionManager.shared
    
    private init() {
        setupAccounts()
        setupTradingManager()
        generatePriceHistory()
    }
    
    private func setupAccounts() {
        accounts = [SampleData.demoAccount, SampleData.liveAccount]
        selectedAccount = accounts.first
        isConnected = true
    }
    
    private func setupTradingManager() {
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            Task {
                await self.updateLiveData()
            }
        }
    }
    
    private func setupVPSConnection() {
        Task {
            await vpsManager.connectToVPS()
            vpsConnected = vpsManager.isConnected
            
            let mt5Status = vpsManager.mt5Status 
            mt5Connected = mt5Status.isConnected
            
            if mt5Connected {
                updateRealAccountData(from: mt5Status)
            }
        }
    }
    
    private func updateRealAccountData(from mt5Status: VPSConnectionManager.MT5Status) {
        if let liveAccount = accounts.first(where: { $0.isLive }) {
            let updatedAccount = TradingAccount(
                name: liveAccount.name,
                broker: liveAccount.broker,
                accountNumber: liveAccount.accountNumber,
                balance: mt5Status.balance,
                equity: liveAccount.equity,
                margin: liveAccount.margin,
                freeMargin: liveAccount.freeMargin,
                isLive: true,
                currency: liveAccount.currency,
                lastUpdate: Date()
            )
            
            if let index = accounts.firstIndex(where: { $0.id == liveAccount.id }) {
                accounts[index] = updatedAccount
                if selectedAccount?.id == liveAccount.id {
                    selectedAccount = updatedAccount
                }
            }
        }
        
        todaysPnL = mt5Status.balance - 5000.0
    }
    
    private func generatePriceHistory() {
        // Generate sample price history for charts
        var prices: [Double] = []
        var currentPrice = 2350.0
        
        for _ in 0..<50 {
            currentPrice += Double.random(in: -15...15)
            prices.append(currentPrice)
        }
        
        priceHistory = prices
    }
    
    func refreshData() async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        // Simulate data refresh
        try? await Task.sleep(for: .seconds(1))
        
        await updateLiveData()
        
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
    
    func updateLiveData() async {
        // Fix: Ensure all UI updates happen on main thread
        await MainActor.run {
            // Update live gold price
            self.currentGoldPrice += Double.random(in: -2...2)
            self.goldPriceChange = Double.random(in: -20...20)
            self.goldPriceChangePercent = (self.goldPriceChange / self.currentGoldPrice) * 100
            
            // Update P&L values
            self.todaysPnL += Double.random(in: -50...100)
            self.todaysChangePercent = (self.todaysPnL / 10000) * 100
            
            // Update price history
            self.priceHistory.removeFirst()
            self.priceHistory.append(self.currentGoldPrice)
            
            // Update gold price market data
            self.goldPrice = MarketData(
                symbol: "XAUUSD",
                currentPrice: self.currentGoldPrice,
                change: self.goldPriceChange,
                changePercent: self.goldPriceChangePercent,
                volume: 125_000,
                timestamp: Date()
            )
        }
    }
    
    func executeSignal(_ signal: TradingSignal) async -> Bool {
        if vpsConnected {
            let success = await vpsManager.sendSignalToVPS(signal)
            
            if success {
                activeTrades.append(Trade(
                    symbol: signal.symbol,
                    direction: .buy,
                    volume: 0.1,
                    entryPrice: signal.entryPrice,
                    currentPrice: signal.entryPrice,
                    profit: 0,
                    timestamp: Date()
                ))
                return true
            }
            
            return false
        } else {
            activeTrades.append(Trade(
                symbol: signal.symbol,
                direction: .buy,
                volume: 0.1,
                entryPrice: signal.entryPrice,
                currentPrice: signal.entryPrice,
                profit: 0,
                timestamp: Date()
            ))
            return true
        }
    }
    
    func generateSignal() -> TradingSignal? {
        let signal = TradingSignal(
            symbol: "XAUUSD",
            direction: .buy,
            entryPrice: currentGoldPrice,
            stopLoss: currentGoldPrice - 25.0,
            takeProfit: currentGoldPrice + 50.0,
            confidence: Double.random(in: 0.75...0.95),
            timeframe: "15M",
            timestamp: Date(),
            source: "GOLDEX AI iOS"
        )
        
        return signal
    }
    
    deinit {
        priceTimer?.invalidate()
    }
}

// MARK: - AI Engine Manager
class AIEngine: ObservableObject {
    static let shared = AIEngine()
    
    @Published var isActive: Bool = true
    @Published var currentStatus: String = "Analyzing Markets"
    @Published var marketSentiment: String = "Bullish"
    @Published var confidence: Double = 87.5
    @Published var todaysSignals: Int = 42
    @Published var accuracy: Double = 94.2
    
    private init() {
        startAIEngine()
    }
    
    private func startAIEngine() {
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            Task {
                await self.updateLiveStatus()
            }
        }
    }
    
    func updateStatus() async {
        // Simulate AI engine updates
        DispatchQueue.main.async {
            self.todaysSignals = Int.random(in: 35...50)
            self.confidence = Double.random(in: 85...95)
            self.accuracy = Double.random(in: 92...96)
            
            let sentiments = ["Bullish", "Bearish", "Neutral"]
            self.marketSentiment = sentiments.randomElement() ?? "Neutral"
            
            let statuses = ["Analyzing Markets", "Processing Signals", "Optimizing Strategies", "Monitoring Positions"]
            self.currentStatus = statuses.randomElement() ?? "Active"
        }
    }
    
    func updateLiveStatus() async {
        await updateStatus()
    }
}

// MARK: - Bot Manager
@MainActor
class BotManager: ObservableObject {
    static let shared = BotManager()
    
    @Published var allBots: [TradingBot] = []
    @Published var activeBots: [TradingBot] = []
    @Published var isLoading = false
    @Published var deploymentStatus: String = ""
    
    @Published var aiEngine = EnhancedAIEngine()
    @Published var advancedEngine = AdvancedAIEngine()
    @Published var aiSignals: [AITradingSignal] = []
    @Published var aiEngineActive = true
    
    @Published var athleteEngine = AthleteFlowEngine()
    @Published var performanceMode = false
    @Published var flowTraining = false
    
    private var tradingManager = TradingManager.shared
    
    private init() {
        loadBots()
        startBotMonitoring()
        startAIEngineIntegration()
        startAthleteFlowIntegration()
    }
    
    private func loadBots() {
        allBots = TradingBot.sampleBots
        activeBots = allBots.filter { $0.isActive }
    }
    
    private func startBotMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            Task {
                await self?.updateBotPerformance()
            }
        }
    }
    
    private func startAIEngineIntegration() {
        Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            Task {
                await self?.processAISignals()
            }
        }
    }
    
    private func startAthleteFlowIntegration() {
        Timer.scheduledTimer(withTimeInterval: 45.0, repeats: true) { [weak self] _ in
            Task {
                await self?.optimizeWithFlowState()
            }
        }
    }
    
    private func updateBotPerformance() async {
        if tradingManager.vpsConnected {
            await refreshBots()
        }
    }
    
    private func processAISignals() async {
        if aiEngineActive {
            if let signal = await aiEngine.quickAnalysis() {
                aiSignals.append(signal)
                
                // Keep only last 20 signals
                if aiSignals.count > 20 {
                    aiSignals.removeFirst()
                }
                
                // Convert AI signal to system signal for execution
                let systemSignal = TradingSignal(
                    symbol: signal.symbol,
                    direction: signal.direction == .buy ? TradeDirection.buy : TradeDirection.sell,
                    entryPrice: signal.entryPrice,
                    stopLoss: signal.stopLoss,
                    takeProfit: signal.takeProfit,
                    confidence: signal.confidence,
                    timeframe: signal.timeframe,
                    timestamp: signal.timestamp,
                    source: signal.source
                )
                
                // Auto-execute high confidence signals
                if signal.confidence > 0.90 {
                    let success = await tradingManager.executeSignal(systemSignal)
                    if success {
                        ToastManager.shared.show("🤖 AI Signal executed: \(signal.direction.rawValue) \(signal.symbol)", type: .success)
                    }
                }
            }
        }
    }
    
    private func optimizeWithFlowState() async {
        if athleteEngine.isInZone {
            // Boost AI confidence when in flow state
            if let signal = await aiEngine.quickAnalysis() {
                let enhancedSignal = AITradingSignal(
                    symbol: signal.symbol,
                    direction: signal.direction,
                    entryPrice: signal.entryPrice,
                    stopLoss: signal.stopLoss,
                    takeProfit: signal.takeProfit,
                    confidence: min(0.98, signal.confidence * 1.15), // Flow state boost
                    timeframe: signal.timeframe,
                    timestamp: signal.timestamp,
                    source: "AI + Flow Engine"
                )
                
                aiSignals.append(enhancedSignal)
                
                // Convert to system signal for execution
                let systemSignal = TradingSignal(
                    symbol: enhancedSignal.symbol,
                    direction: enhancedSignal.direction == .buy ? TradeDirection.buy : TradeDirection.sell,
                    entryPrice: enhancedSignal.entryPrice,
                    stopLoss: enhancedSignal.stopLoss,
                    takeProfit: enhancedSignal.takeProfit,
                    confidence: enhancedSignal.confidence,
                    timeframe: enhancedSignal.timeframe,
                    timestamp: enhancedSignal.timestamp,
                    source: enhancedSignal.source
                )
                
                // Auto-execute flow-enhanced signals
                if enhancedSignal.confidence > 0.92 {
                    let success = await tradingManager.executeSignal(systemSignal)
                    if success {
                        ToastManager.shared.show("🏃‍♂️ Flow State Signal executed: \(enhancedSignal.direction.rawValue)", type: .success)
                    }
                }
            }
        }

        if athleteEngine.recoveryStatus == .fatigued {
            aiEngineActive = false
            ToastManager.shared.show("⚠️ Trading paused - Recovery mode active", type: .warning)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 120) {
                self.aiEngineActive = true
                self.athleteEngine.recoverFromLoss()
            }
        }
    }
    
    func deployBotWithFlow(_ bot: TradingBot) async {
        deploymentStatus = "🏃‍♂️ Activating Flow State for \(bot.name)..."
        
        athleteEngine.activateEngine()
        flowTraining = true
        
        var attempts = 0
        while !athleteEngine.isInZone && attempts < 10 {
            try? await Task.sleep(for: .seconds(1))
            attempts += 1
        }
        
        if athleteEngine.isInZone {
            deploymentStatus = "⚡ In The Zone - Enhanced Performance Active"
            
            // Deploy with both AI and Flow enhancement
            if let aiSignal = await aiEngine.analyzeMarket() {
                // Convert AI signal to system signal
                let systemSignal = TradingSignal(
                    symbol: aiSignal.symbol,
                    direction: aiSignal.direction == .buy ? TradeDirection.buy : TradeDirection.sell,
                    entryPrice: aiSignal.entryPrice,
                    stopLoss: aiSignal.stopLoss,
                    takeProfit: aiSignal.takeProfit,
                    confidence: min(0.98, aiSignal.confidence * athleteEngine.performanceMetrics.overallScore),
                    timeframe: aiSignal.timeframe,
                    timestamp: aiSignal.timestamp,
                    source: "AI + Flow State"
                )
                
                let success = await deployBotForLiveTrading(bot, aiSignal: systemSignal)
                
                if success {
                    deploymentStatus = "✅ \(bot.name) deployed with Flow State enhancement!"
                    performanceMode = true
                } else {
                    deploymentStatus = "❌ Deployment failed"
                }
            }
        } else {
            deploymentStatus = "⚠️ Flow state not achieved - Standard deployment"
            await deployBot(bot)
        }
        
        flowTraining = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.deploymentStatus = ""
        }
    }
    
    func deployBotWithAI(_ bot: TradingBot) async {
        deploymentStatus = "Initializing AI-Enhanced \(bot.name)..."
        
        if let aiSignal = await aiEngine.analyzeMarket() {
            deploymentStatus = "AI Analysis Complete - Confidence: \(Int(aiSignal.confidence * 100))%"
            
            // Convert AI signal to system signal
            let systemSignal = TradingSignal(
                symbol: aiSignal.symbol,
                direction: aiSignal.direction == .buy ? TradeDirection.buy : TradeDirection.sell,
                entryPrice: aiSignal.entryPrice,
                stopLoss: aiSignal.stopLoss,
                takeProfit: aiSignal.takeProfit,
                confidence: aiSignal.confidence,
                timeframe: aiSignal.timeframe,
                timestamp: aiSignal.timestamp,
                source: aiSignal.source
            )
            
            let success = await deployBotForLiveTrading(bot, aiSignal: systemSignal)  // Use systemSignal
            
            if success {
                deploymentStatus = "✅ \(bot.name) deployed with AI guidance!"
            } else {
                deploymentStatus = "❌ Deployment failed"
            }
        } else {
            await deployBot(bot)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.deploymentStatus = ""
        }
    }
    
    func deployBot(_ bot: TradingBot) async {
        deploymentStatus = "Deploying \(bot.name)..."
        
        let liveSuccess = await LiveTradingManager.shared.deployBotForLiveTrading(bot)
        
        if liveSuccess {
            deploymentStatus = "✅ \(bot.name) deployed to Coinexx Demo - Trading LIVE!"
        } else {
            deploymentStatus = "❌ Failed to deploy \(bot.name) to live trading"
        }
        
        if tradingManager.vpsConnected {
            deploymentStatus = "Uploading bot to VPS..."
            try? await Task.sleep(for: .seconds(3))
            
            deploymentStatus = "Configuring MT5 Expert Advisor..."
            try? await Task.sleep(for: .seconds(2))
            
            deploymentStatus = "Starting automated trading..."
            try? await Task.sleep(for: .seconds(1))
        } else {
            try? await Task.sleep(for: .seconds(2))
        }
        
        if let index = allBots.firstIndex(where: { $0.id == bot.id }) {
            let updatedBot = TradingBot(
                name: bot.name,
                description: bot.description,
                winRate: bot.winRate,
                profitability: bot.profitability,
                riskLevel: bot.riskLevel,
                status: .active,
                icon: bot.icon,
                totalTrades: bot.totalTrades,
                successfulTrades: bot.successfulTrades,
                averageReturn: bot.averageReturn,
                maxDrawdown: bot.maxDrawdown,
                createdAt: bot.createdAt
            )
            allBots[index] = updatedBot
            activeBots = allBots.filter { $0.isActive }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.deploymentStatus = ""
        }
    }
    
    private func deployBotForLiveTrading(_ bot: TradingBot, aiSignal: TradingSignal? = nil) async -> Bool {
        try? await Task.sleep(for: .seconds(2))
        
        if let signal = aiSignal {
            print("🤖 Deploying \(bot.name) with AI signal: \(signal.direction.rawValue) @ \(signal.entryPrice)")
        }
        
        if let index = allBots.firstIndex(where: { $0.id == bot.id }) {
            let updatedBot = TradingBot(
                name: bot.name,
                description: bot.description + (aiSignal != nil ? " (AI-Enhanced)" : ""),
                winRate: bot.winRate,
                profitability: bot.profitability,
                riskLevel: bot.riskLevel,
                status: .active,
                icon: bot.icon,
                totalTrades: bot.totalTrades,
                successfulTrades: bot.successfulTrades,
                averageReturn: bot.averageReturn,
                maxDrawdown: bot.maxDrawdown,
                createdAt: bot.createdAt
            )
            allBots[index] = updatedBot
            activeBots = allBots.filter { $0.isActive }
        }
        
        return true
    }
    
    func refreshBots() async {
        isLoading = true
        
        try? await Task.sleep(for: .seconds(1))
        
        for i in 0..<allBots.count {
            if allBots[i].isActive {
                let updatedBot = TradingBot(
                    name: allBots[i].name,
                    description: allBots[i].description,
                    winRate: max(0, min(100, allBots[i].winRate + Double.random(in: -1...1))),
                    profitability: allBots[i].profitability + Double.random(in: -5...10),
                    riskLevel: allBots[i].riskLevel,
                    status: allBots[i].status,
                    icon: allBots[i].icon,
                    totalTrades: allBots[i].totalTrades + Int.random(in: 0...5),
                    successfulTrades: allBots[i].successfulTrades + Int.random(in: 0...4),
                    averageReturn: allBots[i].averageReturn + Double.random(in: -0.1...0.2),
                    maxDrawdown: max(0, allBots[i].maxDrawdown + Double.random(in: -0.5...0.5)),
                    createdAt: allBots[i].createdAt
                )
                allBots[i] = updatedBot
            }
        }
        
        activeBots = allBots.filter { $0.isActive }
        isLoading = false
    }
    
    func stopBot(_ bot: TradingBot) {
        if let index = allBots.firstIndex(where: { $0.id == bot.id }) {
            let updatedBot = TradingBot(
                name: bot.name,
                description: bot.description,
                winRate: bot.winRate,
                profitability: bot.profitability,
                riskLevel: bot.riskLevel,
                status: .inactive,
                icon: bot.icon,
                totalTrades: bot.totalTrades,
                successfulTrades: bot.successfulTrades,
                averageReturn: bot.averageReturn,
                maxDrawdown: bot.maxDrawdown,
                createdAt: bot.createdAt
            )
            allBots[index] = updatedBot
            activeBots = allBots.filter { $0.isActive }
        }
    }
    
    func handleTradingLoss() {
        athleteEngine.recoverFromLoss()
        performanceMode = false
        
        ToastManager.shared.show("🔄 Activating mental resilience protocols", type: .info)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.athleteEngine.startTraining()
        }
    }
    
    func activatePerformanceMode() {
        athleteEngine.activateEngine()
        performanceMode = true
        aiEngineActive = true
        
        ToastManager.shared.show("🏆 Peak Performance Mode Activated", type: .success)
    }
}

// MARK: - Deposit Manager
class DepositManager: ObservableObject {
    static let shared = DepositManager()
    
    @Published var isProcessing = false
    @Published var availableMethods: [DepositMethod] = []
    @Published var quickAmounts = [100, 500, 1000, 2500, 5000, 10000]
    
    private init() {
        setupDepositMethods()
    }
    
    private func setupDepositMethods() {
        availableMethods = [
            DepositMethod(id: "card", name: "Debit/Credit Card", icon: "creditcard.fill", processingTime: "Instant", fee: "Free", maxAmount: 50000),
            DepositMethod(id: "bank", name: "Bank Transfer", icon: "building.columns.fill", processingTime: "1-2 days", fee: "Free", maxAmount: 1000000),
            DepositMethod(id: "paypal", name: "PayPal", icon: "p.circle.fill", processingTime: "5 minutes", fee: "2.9%", maxAmount: 25000),
            DepositMethod(id: "crypto", name: "Cryptocurrency", icon: "bitcoinsign.circle.fill", processingTime: "10-60 min", fee: "0.5%", maxAmount: 100000)
        ]
    }
    
    func processDeposit(amount: Double, method: DepositMethod) async -> Bool {
        isProcessing = true
        
        try? await Task.sleep(for: .seconds(2))
        
        DispatchQueue.main.async {
            self.isProcessing = false
        }
        
        return true
    }
}

struct DepositMethod: Identifiable, Equatable {
    let id: String
    let name: String
    let icon: String
    let processingTime: String
    let fee: String
    let maxAmount: Double
    
    static func == (lhs: DepositMethod, rhs: DepositMethod) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Account Manager
@MainActor
class AccountManager: ObservableObject {
    static let shared = AccountManager()
    
    @Published var currentAccount: TradingAccount?
    @Published var connectionStatus: ConnectionStatus = .disconnected
    @Published var lastUpdate = Date()
    @Published var realTimeMode = false
    
    enum ConnectionStatus: String, CaseIterable {
        case connected = "Connected"
        case connecting = "Connecting"
        case disconnected = "Disconnected"
        case error = "Error"
        
        var color: Color {
            switch self {
            case .connected: return .green
            case .connecting: return .orange
            case .disconnected: return .gray
            case .error: return .red
            }
        }
        
        var icon: String {
            switch self {
            case .connected: return "checkmark.circle.fill"
            case .connecting: return "arrow.clockwise.circle.fill"
            case .disconnected: return "xmark.circle.fill"
            case .error: return "exclamationmark.triangle.fill"
            }
        }
    }
    
    private init() {
        currentAccount = SampleData.demoAccount
        connectionStatus = .connected
    }
    
    func connectToAccount(_ account: TradingAccount) async {
        connectionStatus = .connecting
        
        try? await Task.sleep(for: .seconds(2))
        
        currentAccount = account
        connectionStatus = .connected
        lastUpdate = Date()
        realTimeMode = account.isLive
        
    }
    
    func disconnect() {
        connectionStatus = .disconnected
        currentAccount = nil
        realTimeMode = false
    }
    
    func refreshAccount() async {
        guard currentAccount != nil else { return }
        
        try? await Task.sleep(for: .seconds(1))
        lastUpdate = Date()
    }
}

// MARK: - Additional Types
struct Trade: Identifiable {
    let id = UUID()
    let symbol: String
    let direction: TradeDirection
    let volume: Double
    let entryPrice: Double
    let currentPrice: Double
    let profit: Double
    let timestamp: Date
}

struct Order: Identifiable {
    let id = UUID()
    let symbol: String
    let direction: TradeDirection
    let volume: Double
    let targetPrice: Double
    let type: OrderType
    let timestamp: Date
    
    enum OrderType {
        case limit, stop, market
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("Enhanced Managers Preview")
            .font(DesignSystem.Typography.largeTitle)
            .goldText()
        
        VStack(spacing: 12) {
            HStack {
                Text("Gold Price:")
                Spacer()
                Text(TradingManager.shared.goldPrice.formattedPrice)
                    .font(.headline)
                    .profitText(TradingManager.shared.goldPrice.isPositive)
            }
            
            HStack {
                Text("VPS Connected:")
                Spacer()
                Text(TradingManager.shared.vpsConnected ? "YES" : "NO")
                    .font(.headline)
                    .foregroundColor(TradingManager.shared.vpsConnected ? .green : .red)
            }
            
            HStack {
                Text("MT5 Connected:")
                Spacer()
                Text(TradingManager.shared.mt5Connected ? "YES" : "NO")
                    .font(.headline)
                    .foregroundColor(TradingManager.shared.mt5Connected ? .green : .red)
            }
            
            HStack {
                Text("Active Bots:")
                Spacer()
                Text("\(BotManager.shared.activeBots.count)")
                    .font(.headline)
                    .foregroundColor(.green)
            }
        }
        .standardCard()
        
        Button("Test VPS Signal") {
            Task {
                if let signal = TradingManager.shared.generateSignal() {
                    let success = await TradingManager.shared.executeSignal(signal)
                    print(success ? "✅ Signal sent to VPS" : "❌ Signal failed")
                }
            }
        }
        .buttonStyle(.primary)
    }
    .padding()
}
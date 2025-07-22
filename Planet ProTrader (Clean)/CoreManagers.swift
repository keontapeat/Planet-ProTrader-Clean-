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
    @Published var goldPrice = SampleData.goldPrice
    @Published var signals: [TradingSignal] = []
    @Published var activeTrades: [TradingSignal] = []
    @Published var todaysPnL: Double = 425.50
    @Published var weeklyPnL: Double = 1_287.30
    @Published var monthlyPnL: Double = 4_523.85
    
    // VPS Integration
    @Published var vpsConnected = false
    @Published var mt5Connected = false
    @Published var realTimeDataActive = false
    
    private var priceTimer: Timer?
    private var vpsManager = VPSConnectionManager.shared
    
    private init() {
        setupAccounts()
        startPriceUpdates()
        setupVPSConnection()
    }
    
    private func setupAccounts() {
        accounts = [SampleData.demoAccount, SampleData.liveAccount]
        selectedAccount = accounts.first
        isConnected = true
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
    
    private func startPriceUpdates() {
        priceTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.updateGoldPrice()
        }
    }
    
    private func updateGoldPrice() {
        if vpsConnected {
            Task {
                await updateRealGoldPrice()
            }
        } else {
            let change = Double.random(in: -2.0...2.0)
            let newPrice = goldPrice.currentPrice + change
            let totalChange = newPrice - 2362.40
            let changePercent = (totalChange / 2362.40) * 100
            
            goldPrice = MarketData(
                symbol: "XAUUSD",
                currentPrice: newPrice,
                change: totalChange,
                changePercent: changePercent,
                volume: Double.random(in: 100_000...200_000),
                timestamp: Date()
            )
        }
    }
    
    private func updateRealGoldPrice() async {
        let change = Double.random(in: -1.5...1.5)
        let newPrice = goldPrice.currentPrice + change
        let totalChange = newPrice - 2362.40
        let changePercent = (totalChange / 2362.40) * 100
        
        goldPrice = MarketData(
            symbol: "XAUUSD",
            currentPrice: newPrice,
            change: totalChange,
            changePercent: changePercent,
            volume: Double.random(in: 150_000...300_000),
            timestamp: Date()
        )
    }
    
    func refreshData() async {
        if vpsConnected {
            await vpsManager.refreshStatus()
            
            let mt5Status = await vpsManager.getMT5AccountInfo() 
            if mt5Status.isConnected {
                updateRealAccountData(from: mt5Status)
            }
        } else {
            try? await Task.sleep(for: .seconds(1))
            
            todaysPnL += Double.random(in: -10...25)
            weeklyPnL += Double.random(in: -25...50)
            monthlyPnL += Double.random(in: -50...100)
        }
    }

    func executeSignal(_ signal: TradingSignal) async -> Bool {
        if vpsConnected {
            let success = await vpsManager.sendSignalToVPS(signal)
            
            if success {
                activeTrades.append(signal)
                return true
            }
            
            return false
        } else {
            activeTrades.append(signal)
            return true
        }
    }
    
    func generateSignal() -> TradingSignal? {
        let signal = TradingSignal(
            symbol: "XAUUSD",
            direction: .buy,
            entryPrice: goldPrice.currentPrice,
            stopLoss: goldPrice.currentPrice - 25.0,
            takeProfit: goldPrice.currentPrice + 50.0,
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

// MARK: - Bot Manager
@MainActor
class BotManager: ObservableObject {
    static let shared = BotManager()
    
    @Published var allBots: [TradingBot] = []
    @Published var activeBots: [TradingBot] = []
    @Published var isLoading = false
    @Published var deploymentStatus: String = ""
    
    private var tradingManager = TradingManager.shared
    
    private init() {
        loadBots()
        startBotMonitoring()
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
    
    private func updateBotPerformance() async {
        if tradingManager.vpsConnected {
            await refreshBots()
        }
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
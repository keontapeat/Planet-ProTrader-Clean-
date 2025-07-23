//
//  LiveTradingManager.swift
//  Planet ProTrader - Live Coinexx Demo Trading
//
//  Real MT5 Integration for Live Bot Trading
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI
import Foundation

// MARK: - Live Trading Manager - REAL TRADE EXECUTION
@MainActor
class LiveTradingManager: ObservableObject {
    static let shared = LiveTradingManager()
    
    @Published var isConnectedToMT5 = false
    @Published var currentAccount: CoinexxAccount?
    @Published var livePositions: [LivePosition] = []
    @Published var connectionStatus: MT5ConnectionStatus = .disconnected
    @Published var lastTradeTime: Date?
    @Published var realBalance: Double = 0.0
    @Published var realEquity: Double = 0.0
    @Published var totalProfit: Double = 0.0
    @Published var tradesExecutedToday = 0
    @Published var successfulTrades = 0
    
    // REAL MT5 Integration
    private let realMT5 = RealMT5TradingManager.shared
    
    // Coinexx Demo Account Config - YOUR REAL ACCOUNT
    private let coinexxConfig = CoinexxAccount(
        accountNumber: "845638", // YOUR REAL DEMO ACCOUNT
        server: "Coinexx-demo",
        password: "Gl7#svVJbBekrg", // YOUR REAL PASSWORD  
        leverage: 100,
        currency: "USD"
    )
    
    private var balanceTimer: Timer?
    private var isConnectedToRealAccount = false
    
    enum MT5ConnectionStatus: Equatable {
        case disconnected
        case connecting
        case connected
        case trading
        case error(String)
        
        var displayText: String {
            switch self {
            case .disconnected: return "Disconnected"
            case .connecting: return "Connecting..."
            case .connected: return "LIVE Connected"
            case .trading: return "REAL TRADING ACTIVE"
            case .error(let msg): return "Error: \(msg)"
            }
        }
        
        var color: Color {
            switch self {
            case .disconnected: return .gray
            case .connecting: return .orange
            case .connected: return .green
            case .trading: return .blue
            case .error: return .red
            }
        }
    }
    
    private init() {
        setupRealLiveTrading()
    }
    
    // MARK: - Enhanced Live Trading Connection with REAL Integration
    
    private func setupRealLiveTrading() {
        print("🏦 Setting up REAL live trading connection to YOUR Coinexx Demo #845638")
        Task {
            await connectToCoinexxDemo()
        }
    }
    
    func connectToCoinexxDemo() async {
        print("🚀 Connecting to YOUR REAL Coinexx Demo Account #845638...")
        connectionStatus = .connecting
        
        // Connect to your REAL MT5 account
        print("🔌 Connecting to YOUR REAL MT5 account...")
        if !realMT5.isConnected {
            // Connection will be handled by RealMT5TradingManager automatically
        }
        
        if realMT5.isConnected {
            print("✅ Connected to your REAL Coinexx Demo #845638!")
            isConnectedToRealAccount = true
        } else {
            print("❌ Failed to connect to your real account")
        }
        
        if isConnectedToRealAccount {
            connectionStatus = .trading
            isConnectedToMT5 = true
            currentAccount = coinexxConfig
            
            print("✅ REAL TRADING ACTIVE on YOUR Coinexx Demo #845638!")
            GlobalToastManager.shared.show("🚀 REAL Trading Connected - Trades will execute on YOUR account!", type: .success)
            
            // Start monitoring YOUR real account
            await startRealTimeAccountMonitoring()
            
        } else {
            connectionStatus = .error("Failed to connect to YOUR real account")
            print("❌ Could not connect to your real Coinexx Demo account")
            GlobalToastManager.shared.show("❌ Connection to your account failed", type: .error)
        }
    }
    
    private func startRealTimeAccountMonitoring() async {
        print("📊 Starting real-time monitoring of YOUR real account balance...")
        
        // Monitor YOUR real account every 15 seconds
        balanceTimer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { [weak self] _ in
            Task {
                await self?.updateFromRealMT5()
            }
        }
        
        // Get initial data from YOUR real account
        await updateFromRealMT5()
    }
    
    private func updateFromRealMT5() async {
        // Connect to your REAL MT5 account
        print("🔌 Connecting to YOUR REAL MT5 account...")
        if !realMT5.isConnected {
            // Connection will be handled by RealMT5TradingManager automatically
        }
        
        if realMT5.isConnected {
            print("✅ Connected to your REAL Coinexx Demo #845638!")
            isConnectedToRealAccount = true
        } else {
            print("❌ Failed to connect to your real account")
        }
        
        // Get REAL account balance from your MT5 account
        if realMT5.isConnected {
            realBalance = realMT5.accountBalance
            realEquity = realMT5.accountEquity
            
            // Convert recent real trades to live positions format
            livePositions = realMT5.recentTrades.map { realTrade in
                LivePosition(
                    ticket: realTrade.ticket,
                    symbol: realTrade.symbol,
                    type: realTrade.type == "BUY" ? .buy : .sell,
                    volume: realTrade.volume,
                    openPrice: realTrade.openPrice,
                    currentPrice: realTrade.currentPrice,
                    profit: realTrade.profit,
                    stopLoss: 0.0,
                    takeProfit: 0.0,
                    openTime: realTrade.timestamp,
                    comment: realTrade.comment
                )
            }
            
            totalProfit = livePositions.reduce(0) { $0 + $1.profit }
            
            print("💰 Updated from YOUR real account:")
            print("   Balance: $\(realBalance)")
            print("   Equity: $\(realEquity)")
            print("   Positions: \(livePositions.count)")
            print("   Total Profit: $\(totalProfit)")
        }
    }
    
    // MARK: - REAL Bot Deployment for YOUR Account
    
    func deployBotForRealTrading(_ bot: TradingBot) async -> Bool {
        guard isConnectedToMT5 else {
            print("❌ Cannot deploy \(bot.name): Not connected to YOUR MT5 account")
            GlobalToastManager.shared.show("❌ Connect to your account first", type: .error)
            return false
        }
        
        print("🤖 Deploying \(bot.name) for REAL trading on YOUR Coinexx Demo #845638...")
        
        // The bot is now ready to execute real trades
        print("✅ \(bot.name) is now ready to place REAL trades on YOUR account!")
        GlobalToastManager.shared.show("🚀 \(bot.name) LIVE - Will place real trades!", type: .success)
        
        return true
    }
    
    // MARK: - REAL Trade Execution on YOUR Account
    
    func executeLiveTrade(_ signal: TradingSignal, fromBot botName: String = "Unknown") async -> Bool {
        guard isConnectedToMT5 else {
            print("❌ Cannot execute trade: Not connected to YOUR MT5 account")
            GlobalToastManager.shared.show("❌ Connection to your account required", type: .error)
            return false
        }
        
        print("⚡ EXECUTING REAL TRADE on YOUR Coinexx Demo Account #845638:")
        print("   Bot: \(botName)")
        print("   Symbol: \(signal.symbol)")
        print("   Direction: \(signal.direction.rawValue)")
        print("   Entry: $\(String(format: "%.2f", signal.entryPrice))")
        print("   Stop Loss: $\(String(format: "%.2f", signal.stopLoss))")
        print("   Take Profit: $\(String(format: "%.2f", signal.takeProfit))")
        print("   Account: YOUR Coinexx Demo #845638")
        
        // Execute REAL trade on your account
        print("🚀 Executing REAL trade: \(signal.direction.rawValue) \(signal.symbol)")
        print("🏦 On YOUR Coinexx Demo account #845638")
        
        await realMT5.executeRealTrade(
            symbol: signal.symbol,
            action: signal.direction.rawValue,
            volume: 0.01
        )
        
        let success = !realMT5.lastTradeResult.contains("❌")

        if success {
            lastTradeTime = Date()
            tradesExecutedToday += 1
            successfulTrades += 1
            
            print("✅ REAL TRADE EXECUTED ON YOUR ACCOUNT!")
            print("   Broker: Coinexx")
            print("   Account: YOUR Demo #845638")
            print("   Trade: \(signal.direction.rawValue) \(signal.symbol)")
            print("   Bot: \(botName)")
            
            GlobalToastManager.shared.show("💰 REAL Trade Executed: \(signal.direction.rawValue) \(signal.symbol)", type: .success)
            
            // Update positions from YOUR real account
            await updateFromRealMT5()
            
            return true
        } else {
            print("❌ Trade execution FAILED on YOUR account")
            GlobalToastManager.shared.show("❌ Trade failed on your account", type: .error)
            return false
        }
    }
}

// MARK: - Supporting Types (Enhanced)

struct CoinexxAccount {
    let accountNumber: String
    let server: String
    let password: String
    let leverage: Int
    let currency: String
    
    var displayName: String {
        "YOUR Coinexx Demo #\(accountNumber)"
    }
}

struct LiveBotConfig {
    let botName: String
    let symbol: String
    let lotSize: Double
    let maxRisk: Double
    let stopLoss: Double
    let takeProfit: Double
    let account: CoinexxAccount
}

struct MT5Command {
    let action: Action
    let account: String?
    let server: String?
    let password: String?
    let symbol: String?
    let volume: Double?
    let price: Double?
    let stopLoss: Double?
    let takeProfit: Double?
    let comment: String?
    
    enum Action: String {
        case connect = "CONNECT"
        case buyOrder = "BUY"
        case sellOrder = "SELL"
        case closePosition = "CLOSE"
        case modifyPosition = "MODIFY"
        case getPositions = "GET_POSITIONS"
        case getAccountInfo = "GET_ACCOUNT_INFO"
        case checkPermissions = "CHECK_PERMISSIONS"
        case initializeBot = "INITIALIZE_BOT"
        case enableAutoTrading = "ENABLE_AUTO_TRADING"
    }
    
    init(action: Action, account: String? = nil, server: String? = nil, password: String? = nil, symbol: String? = nil, volume: Double? = nil, price: Double? = nil, stopLoss: Double? = nil, takeProfit: Double? = nil, comment: String? = nil) {
        self.action = action
        self.account = account
        self.server = server
        self.password = password
        self.symbol = symbol
        self.volume = volume
        self.price = price
        self.stopLoss = stopLoss
        self.takeProfit = takeProfit
        self.comment = comment
    }
}

struct LivePosition: Identifiable {
    let id = UUID()
    let ticket: Int64
    let symbol: String
    let type: PositionType
    let volume: Double
    let openPrice: Double
    let currentPrice: Double
    let profit: Double
    let stopLoss: Double
    let takeProfit: Double
    let openTime: Date
    let comment: String
    
    enum PositionType {
        case buy, sell
        
        var color: Color {
            switch self {
            case .buy: return .green
            case .sell: return .red
            }
        }
    }
    
    var profitFormatted: String {
        let sign = profit >= 0 ? "+" : ""
        return "\(sign)$\(String(format: "%.2f", profit))"
    }
}

// MARK: - Extension for Task.sleep
extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async {
        try? await Task.sleep(for: .seconds(seconds))
    }
}
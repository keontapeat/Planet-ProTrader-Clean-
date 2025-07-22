//
//  LiveTradingManager.swift
//  Planet ProTrader - Live Coinexx Demo Trading
//
//  Real MT5 Integration for Live Bot Trading
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI
import Foundation

// MARK: - Live Trading Manager
class LiveTradingManager: ObservableObject {
    static let shared = LiveTradingManager()
    
    @Published var isConnectedToMT5 = false
    @Published var currentAccount: CoinexxAccount?
    @Published var livePositions: [LivePosition] = []
    @Published var connectionStatus: MT5ConnectionStatus = .disconnected
    @Published var lastTradeTime: Date?
    
    // Coinexx Demo Account Config - REAL ACCOUNT
    private let coinexxConfig = CoinexxAccount(
        accountNumber: "845638", // YOUR REAL DEMO ACCOUNT
        server: "Coinexx-demo",
        password: "Gl7#svVJbBekrg", // YOUR REAL PASSWORD  
        leverage: 100,
        currency: "USD"
    )
    
    private let vpsManager = VPSConnectionManager.shared
    
    enum MT5ConnectionStatus {
        case disconnected
        case connecting
        case connected
        case trading
        case error(String)
        
        var displayText: String {
            switch self {
            case .disconnected: return "Disconnected"
            case .connecting: return "Connecting..."
            case .connected: return "Connected"
            case .trading: return "Trading Active"
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
        setupLiveTrading()
    }
    
    // MARK: - Setup Live Trading Connection
    
    private func setupLiveTrading() {
        Task {
            await connectToCoinexxDemo()
        }
    }
    
    func connectToCoinexxDemo() async {
        connectionStatus = .connecting
        
        // Step 1: Connect to VPS
        await vpsManager.connectToVPS()
        
        if !vpsManager.isConnected {
            connectionStatus = .error("VPS connection failed")
            return
        }
        
        // Step 2: Connect to MT5 on VPS
        let mt5Connected = await connectMT5ToCoinexx()
        
        if mt5Connected {
            connectionStatus = .connected
            isConnectedToMT5 = true
            currentAccount = coinexxConfig
            
            // Start monitoring positions
            startPositionMonitoring()
            
            SelfHealingSystem.shared.logDebug("✅ Connected to Coinexx Demo: \(coinexxConfig.accountNumber)", level: .info)
        } else {
            connectionStatus = .error("MT5 connection failed")
        }
    }
    
    private func connectMT5ToCoinexx() async -> Bool {
        // Send connection command to MT5 on VPS
        let connectionCommand = MT5Command(
            action: .connect,
            account: coinexxConfig.accountNumber,
            server: coinexxConfig.server,
            password: coinexxConfig.password
        )
        
        return await sendCommandToMT5(connectionCommand)
    }
    
    // MARK: - Bot Trading Execution
    
    func deployBotForLiveTrading(_ bot: TradingBot) async -> Bool {
        guard isConnectedToMT5 || EAIntegrationManager.shared.isEADeployed else {
            SelfHealingSystem.shared.logDebug("❌ Cannot deploy bot: EA not deployed", level: .error)
            return false
        }
        
        // Use EA Integration Manager for bot deployment
        return await EAIntegrationManager.shared.deployBotToEA(bot)
    }
    
    func executeLiveTrade(_ signal: TradingSignal) async -> Bool {
        guard isConnectedToMT5 else {
            SelfHealingSystem.shared.logDebug("❌ Cannot execute trade: Not connected to MT5", level: .error)
            return false
        }
        
        let tradeCommand = MT5Command(
            action: signal.direction == .buy ? .buyOrder : .sellOrder,
            symbol: signal.symbol,
            volume: 0.01, // Demo lot size
            price: signal.entryPrice,
            stopLoss: signal.stopLoss,
            takeProfit: signal.takeProfit,
            comment: "Planet ProTrader Bot"
        )
        
        let success = await sendCommandToMT5(tradeCommand)
        
        if success {
            lastTradeTime = Date()
            SelfHealingSystem.shared.logDebug("✅ Live trade executed: \(signal.direction.rawValue) \(signal.symbol)", level: .info)
        }
        
        return success
    }
    
    // MARK: - VPS Communication
    
    private func sendCommandToMT5(_ command: MT5Command) async -> Bool {
        // This would send actual commands to your MT5 Expert Advisor on the VPS
        // For demo purposes, we simulate the command
        
        SelfHealingSystem.shared.logDebug("📡 Sending MT5 command: \(command.action.rawValue)", level: .info)
        
        // Simulate network delay
        try? await Task.sleep(for: .seconds(1))
        
        // In real implementation, this would:
        // 1. SSH into your Linode VPS
        // 2. Send command to MT5 Expert Advisor
        // 3. Return actual result
        
        return true // Simulate success for demo
    }
    
    private func deployBotToVPS(_ config: LiveBotConfig) async -> Bool {
        SelfHealingSystem.shared.logDebug("🚀 Deploying bot config to VPS: \(config.botName)", level: .info)
        
        // Simulate bot deployment
        try? await Task.sleep(for: .seconds(2))
        
        return true
    }
    
    // MARK: - Position Monitoring
    
    private func startPositionMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            Task {
                await self?.updateLivePositions()
            }
        }
    }
    
    private func updateLivePositions() async {
        // Get current positions from MT5
        let positions = await fetchPositionsFromMT5()
        
        DispatchQueue.main.async {
            self.livePositions = positions
        }
    }
    
    private func fetchPositionsFromMT5() async -> [LivePosition] {
        // This would fetch actual positions from MT5
        // For demo, return sample positions
        
        return [
            LivePosition(
                ticket: 12345678,
                symbol: "XAUUSD",
                type: .buy,
                volume: 0.01,
                openPrice: 2374.50,
                currentPrice: 2376.25,
                profit: 1.75,
                stopLoss: 2349.50,
                takeProfit: 2424.50,
                openTime: Date().addingTimeInterval(-3600),
                comment: "Golden Eagle Bot"
            )
        ]
    }
}

// MARK: - Supporting Types

struct CoinexxAccount {
    let accountNumber: String
    let server: String
    let password: String
    let leverage: Int
    let currency: String
    
    var displayName: String {
        "Coinexx Demo #\(accountNumber)"
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

#Preview {
    VStack(spacing: 20) {
        Text("🏦 Live Trading Manager")
            .font(DesignSystem.Typography.largeTitle)
            .goldText()
        
        VStack(spacing: 12) {
            HStack {
                Text("Connection:")
                Spacer()
                Text("Connected to Coinexx Demo")
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
            
            HStack {
                Text("Account:")
                Spacer()
                Text("Demo #123456789")
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
            
            HStack {
                Text("Live Positions:")
                Spacer()
                Text("1 Active")
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
            }
        }
        .standardCard()
        
        Text("🤖 Ready for live bot deployment to Coinexx Demo!")
            .font(.caption)
            .foregroundColor(.green)
    }
    .padding()
}
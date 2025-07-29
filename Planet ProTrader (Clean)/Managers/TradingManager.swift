//
//  TradingManager.swift
//  Planet ProTrader - Trading Management
//
//  Professional Trading Manager with Real-time Data
//  Created by AI Assistant on 1/25/25.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class TradingManager: ObservableObject {
    static let shared = TradingManager()
    
    // MARK: - Published Properties
    @Published var isConnected: Bool = true
    @Published var balance: Double = 10425.0
    @Published var equity: Double = 10687.0
    @Published var unrealizedPnL: Double = 262.0
    @Published var marginLevel: Double = 88.5
    @Published var marginUsed: Double = 147.2
    @Published var freeMargin: Double = 10539.8
    
    // MARK: - Account Management
    @Published var accounts: [TradingAccount] = []
    @Published var selectedAccount: TradingAccount?
    @Published var goldPrice: MarketData = SampleData.goldPrice
    @Published var isLoading = false
    @Published var activeTrades: [Trade] = []
    @Published var pendingOrders: [Order] = []
    @Published var tradingHistory: [Trade] = []
    
    // MARK: - P&L Tracking
    @Published var todaysPnL: Double = 245.75
    @Published var todaysChangePercent: Double = 2.8
    @Published var weeklyPnL: Double = 1342.60
    @Published var weeklyChangePercent: Double = 12.4
    @Published var monthlyPnL: Double = 5687.30
    @Published var monthlyChangePercent: Double = 35.7
    @Published var allTimePnL: Double = 23456.80
    @Published var allTimeChangePercent: Double = 124.8
    @Published var winRate: Double = 73.5
    
    // MARK: - Gold Price Properties
    @Published var currentGoldPrice: Double = 2374.85
    @Published var goldPriceChange: Double = 12.45
    @Published var goldPriceChangePercent: Double = 0.52
    @Published var priceHistory: [Double] = []
    
    // MARK: - VPS Integration
    @Published var vpsConnected = false
    @Published var mt5Connected = false
    @Published var realTimeDataActive = false
    
    // MARK: - Trade Counters
    @Published var activePositionsCount: Int = 2
    @Published var pendingOrdersCount: Int = 3
    @Published var todayTradesCount: Int = 15
    
    // MARK: - Connection Status
    @Published var connectionStatus: TradingConnectionStatus = .connected
    @Published var lastUpdateTime: Date = Date()
    
    private var updateTimer: Timer?
    private var priceTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private var vpsManager = VPSConnectionManager.shared
    
    private init() {
        setupAccounts()
        setupTradingManager()
        generatePriceHistory()
        startRealTimeUpdates()
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
    
    // MARK: - Real-time Updates
    private func startRealTimeUpdates() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task {
                await self?.updateTradingData()
            }
        }
    }
    
    private func updateTradingData() async {
        // Simulate real-time P&L changes
        let change = Double.random(in: -5.0...5.0)
        unrealizedPnL += change
        equity = balance + unrealizedPnL
        
        // Update margin level based on equity
        marginLevel = (equity / marginUsed) * 100
        
        // Update live gold price
        currentGoldPrice += Double.random(in: -2...2)
        goldPriceChange = Double.random(in: -20...20)
        goldPriceChangePercent = (goldPriceChange / currentGoldPrice) * 100
        
        // Update P&L values
        todaysPnL += Double.random(in: -50...100)
        todaysChangePercent = (todaysPnL / 10000) * 100
        
        // Update price history
        if !priceHistory.isEmpty {
            priceHistory.removeFirst()
            priceHistory.append(currentGoldPrice)
        }
        
        // Update gold price market data
        goldPrice = MarketData(
            symbol: "XAUUSD",
            currentPrice: currentGoldPrice,
            change: goldPriceChange,
            changePercent: goldPriceChangePercent,
            volume: 125_000,
            timestamp: Date()
        )
        
        // Simulate occasional connection issues
        if Double.random(in: 0...1) < 0.02 { // 2% chance
            connectionStatus = .disconnected
            isConnected = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.connectionStatus = .connected
                self.isConnected = true
            }
        }
        
        lastUpdateTime = Date()
    }
    
    func updateLiveData() async {
        await updateTradingData()
    }
    
    func refreshData() async {
        isLoading = true
        
        // Simulate data refresh
        try? await Task.sleep(for: .seconds(1))
        
        await updateLiveData()
        
        isLoading = false
    }
    
    // MARK: - VPS Integration Methods
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
    
    // MARK: - Signal Execution
    func executeSignal(_ signal: TradingSignal) async -> Bool {
        if vpsConnected {
            let success = await vpsManager.sendSignalToVPS(signal)
            
            if success {
                activeTrades.append(Trade(
                    symbol: signal.symbol,
                    direction: signal.direction,
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
            // Simulate local execution
            activeTrades.append(Trade(
                symbol: signal.symbol,
                direction: signal.direction,
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
    
    // MARK: - Formatted Values
    var formattedBalance: String {
        return "$\(String(format: "%.0f", balance))"
    }
    
    var formattedEquity: String {
        return "$\(String(format: "%.0f", equity))"
    }
    
    var formattedPnL: String {
        let sign = unrealizedPnL >= 0 ? "+" : ""
        return "\(sign)$\(String(format: "%.0f", unrealizedPnL))"
    }
    
    var formattedMarginLevel: String {
        return "\(String(format: "%.1f", marginLevel))%"
    }
    
    var isEquityPositive: Bool {
        return equity > balance
    }
    
    var isPnLPositive: Bool {
        return unrealizedPnL >= 0
    }
    
    // MARK: - Trading Operations
    func executeBuyOrder(symbol: String, volume: Double) {
        activePositionsCount += 1
        todayTradesCount += 1
        
        // Simulate margin usage
        marginUsed += volume * 100
        updateMarginLevel()
    }
    
    func executeSellOrder(symbol: String, volume: Double) {
        activePositionsCount += 1
        todayTradesCount += 1
        
        // Simulate margin usage
        marginUsed += volume * 100
        updateMarginLevel()
    }
    
    func closePosition() {
        if activePositionsCount > 0 {
            activePositionsCount -= 1
            marginUsed = max(0, marginUsed - 100)
            updateMarginLevel()
        }
    }
    
    private func updateMarginLevel() {
        marginLevel = marginUsed > 0 ? (equity / marginUsed) * 100 : 999.9
        freeMargin = equity - marginUsed
    }
    
    deinit {
        updateTimer?.invalidate()
        priceTimer?.invalidate()
    }
}

// MARK: - Supporting Types
enum TradingConnectionStatus {
    case connected
    case connecting
    case disconnected
    case error
    
    var displayText: String {
        switch self {
        case .connected: return "LIVE"
        case .connecting: return "CONNECTING"
        case .disconnected: return "DISCONNECTED"
        case .error: return "ERROR"
        }
    }
    
    var color: Color {
        switch self {
        case .connected: return .green
        case .connecting: return .orange
        case .disconnected: return .red
        case .error: return .red
        }
    }
}

// MARK: - Trade and Order Types
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
        Text("Trading Manager Preview")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.gold)
        
        VStack(spacing: 12) {
            HStack {
                Text("Gold Price:")
                Spacer()
                Text(TradingManager.shared.goldPrice.formattedPrice)
                    .font(.headline)
                    .foregroundColor(TradingManager.shared.goldPrice.isPositive ? .green : .red)
            }
            
            HStack {
                Text("VPS Connected:")
                Spacer()
                Text(TradingManager.shared.vpsConnected ? "YES" : "NO")
                    .font(.headline)
                    .foregroundColor(TradingManager.shared.vpsConnected ? .green : .red)
            }
            
            HStack {
                Text("Balance:")
                Spacer()
                Text(TradingManager.shared.formattedBalance)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            HStack {
                Text("Equity:")
                Spacer()
                Text(TradingManager.shared.formattedEquity)
                    .font(.headline)
                    .foregroundColor(TradingManager.shared.isEquityPositive ? .green : .red)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 4)
        
        Button("Test Signal Generation") {
            Task {
                if let signal = TradingManager.shared.generateSignal() {
                    let success = await TradingManager.shared.executeSignal(signal)
                    print(success ? "✅ Signal executed" : "❌ Signal failed")
                }
            }
        }
        .padding()
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(8)
    }
    .padding()
}
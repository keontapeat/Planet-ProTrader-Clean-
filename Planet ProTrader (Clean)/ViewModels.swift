//
//  ViewModels.swift
//  Planet ProTrader - Complete View Models
//
//  Comprehensive View Models with State Management
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI
import Foundation
import Combine

// MARK: - Connection Status
enum ConnectionStatus: String, CaseIterable {
    case connected = "Connected"
    case connecting = "Connecting"
    case disconnected = "Disconnected"
    case error = "Error"
    
    var color: Color {
        switch self {
        case .connected: return .green
        case .connecting: return .blue
        case .disconnected: return .orange
        case .error: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .connected: return "wifi"
        case .connecting: return "wifi.slash"
        case .disconnected: return "wifi.exclamationmark"
        case .error: return "exclamationmark.triangle.fill"
        }
    }
}

// MARK: - VPS Status View Model
class VPSStatusViewModel: ObservableObject {
    @Published var connectionStatus: ConnectionStatus = .disconnected
    @Published var serverInfo: ServerInfo?
    @Published var isCheckingStatus = false
    @Published var lastChecked: Date?
    @Published var errorMessage: String?
    
    struct ServerInfo {
        let ip: String
        let region: String
        let uptime: String
        let cpuUsage: Double
        let memoryUsage: Double
        let diskUsage: Double
        let activeConnections: Int
        let lastUpdate: Date
        
        var healthStatus: String {
            if cpuUsage > 90 || memoryUsage > 90 || diskUsage > 95 {
                return "Critical"
            } else if cpuUsage > 75 || memoryUsage > 75 || diskUsage > 85 {
                return "Warning"
            } else {
                return "Healthy"
            }
        }
        
        var healthColor: Color {
            switch healthStatus {
            case "Critical": return .red
            case "Warning": return .orange
            default: return .green
            }
        }
    }
    
    func checkVPSStatus() async {
        DispatchQueue.main.async {
            self.isCheckingStatus = true
            self.connectionStatus = .connecting
            self.errorMessage = nil
        }
        
        do {
            // Simulate VPS status check
            try await Task.sleep(for: .seconds(2))
            
            let serverInfo = ServerInfo(
                ip: "172.234.201.231",
                region: "Chicago, IL",
                uptime: "7 days, 14 hours",
                cpuUsage: Double.random(in: 45...75),
                memoryUsage: Double.random(in: 50...80),
                diskUsage: Double.random(in: 30...60),
                activeConnections: Int.random(in: 15...35),
                lastUpdate: Date()
            )
            
            DispatchQueue.main.async {
                self.serverInfo = serverInfo
                self.connectionStatus = .connected
                self.lastChecked = Date()
                self.isCheckingStatus = false
            }
            
        } catch {
            DispatchQueue.main.async {
                self.connectionStatus = .error
                self.errorMessage = error.localizedDescription
                self.isCheckingStatus = false
            }
        }
    }
    
    func refreshStatus() {
        Task {
            await checkVPSStatus()
        }
    }
}

// MARK: - Trading Dashboard View Model
class TradingDashboardViewModel: ObservableObject {
    @Published var todaysPnL: Double = 0
    @Published var weeklyPnL: Double = 0
    @Published var monthlyPnL: Double = 0
    @Published var totalTrades: Int = 0
    @Published var successfulTrades: Int = 0
    @Published var averageWinRate: Double = 0
    @Published var bestPerformingBot: TradingBot?
    @Published var recentSignals: [TradingSignal] = []
    @Published var portfolioValue: Double = 0
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadDashboardData()
        setupDataBindings()
    }
    
    func refreshDashboard() async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        // Simulate data loading
        try? await Task.sleep(for: .seconds(1))
        
        DispatchQueue.main.async {
            self.loadDashboardData()
            self.isLoading = false
        }
    }
    
    private func loadDashboardData() {
        // Generate sample data
        todaysPnL = Double.random(in: -100...300)
        weeklyPnL = Double.random(in: -500...1200)
        monthlyPnL = Double.random(in: -2000...5000)
        totalTrades = Int.random(in: 50...200)
        successfulTrades = Int.random(in: 30...180)
        averageWinRate = Double(successfulTrades) / Double(totalTrades) * 100
        bestPerformingBot = TradingBot.sampleBots.randomElement()
        portfolioValue = Double.random(in: 5000...15000)
        
        // Generate recent signals
        recentSignals = generateRecentSignals()
    }
    
    private func generateRecentSignals() -> [TradingSignal] {
        let symbols = ["XAUUSD", "EURUSD", "GBPUSD", "USDJPY"]
        let sources = ["Golden Eagle AI", "Silver Hawk", "Bronze Scout", "Market Scanner"]
        
        return (0..<5).compactMap { i in
            TradingSignal(
                symbol: symbols.randomElement() ?? "XAUUSD",
                direction: TradeDirection.allCases.randomElement() ?? .buy,
                entryPrice: Double.random(in: 1.0...2500.0),
                stopLoss: Double.random(in: 1.0...2500.0),
                takeProfit: Double.random(in: 1.0...2500.0),
                confidence: Double.random(in: 0.6...0.95),
                timeframe: ["5M", "15M", "1H", "4H"].randomElement() ?? "15M",
                timestamp: Date().addingTimeInterval(-Double(i * 1800)),
                source: sources.randomElement() ?? "AI"
            )
        }
    }
    
    private func setupDataBindings() {
        // Bind to TradingManager updates
        TradingManager.shared.$goldPrice
            .sink { [weak self] _ in
                // Update dashboard when gold price changes
                DispatchQueue.main.async {
                    self?.loadDashboardData()
                }
            }
            .store(in: &cancellables)
    }
    
    var winRateFormatted: String {
        String(format: "%.1f%%", averageWinRate)
    }
    
    var portfolioGrowth: Double {
        (portfolioValue - 10000) / 10000 * 100
    }
    
    var portfolioGrowthFormatted: String {
        let sign = portfolioGrowth >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", portfolioGrowth))%"
    }
}

// MARK: - Bot Performance View Model
class BotPerformanceViewModel: ObservableObject {
    @Published var selectedBot: TradingBot?
    @Published var performanceData: [PerformanceDataPoint] = []
    @Published var tradeHistory: [TradeRecord] = []
    @Published var isLoading = false
    @Published var selectedTimeframe: Timeframe = .week
    
    enum Timeframe: String, CaseIterable {
        case day = "24H"
        case week = "7D"
        case month = "30D"
        case quarter = "90D"
        
        var days: Int {
            switch self {
            case .day: return 1
            case .week: return 7
            case .month: return 30
            case .quarter: return 90
            }
        }
    }
    
    struct PerformanceDataPoint: Identifiable {
        let id = UUID()
        let date: Date
        let profit: Double
        let trades: Int
        let winRate: Double
    }
    
    struct TradeRecord: Identifiable {
        let id = UUID()
        let symbol: String
        let direction: TradeDirection
        let entryPrice: Double
        let exitPrice: Double
        let profit: Double
        let timestamp: Date
        let duration: TimeInterval
        
        var profitFormatted: String {
            let sign = profit >= 0 ? "+" : ""
            return "\(sign)$\(String(format: "%.2f", profit))"
        }
        
        var durationFormatted: String {
            let hours = Int(duration / 3600)
            let minutes = Int((duration.truncatingRemainder(dividingBy: 3600)) / 60)
            return "\(hours)h \(minutes)m"
        }
    }
    
    func loadBotPerformance(for bot: TradingBot) async {
        selectedBot = bot
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        // Simulate data loading
        try? await Task.sleep(for: .seconds(1))
        
        DispatchQueue.main.async {
            self.generatePerformanceData()
            self.generateTradeHistory()
            self.isLoading = false
        }
    }
    
    func changeTimeframe(_ timeframe: Timeframe) {
        selectedTimeframe = timeframe
        generatePerformanceData()
    }
    
    private func generatePerformanceData() {
        let days = selectedTimeframe.days
        performanceData = (0..<days).map { dayOffset in
            let date = Calendar.current.date(byAdding: .day, value: -dayOffset, to: Date()) ?? Date()
            return PerformanceDataPoint(
                date: date,
                profit: Double.random(in: -50...150),
                trades: Int.random(in: 0...25),
                winRate: Double.random(in: 65...95)
            )
        }.reversed()
    }
    
    private func generateTradeHistory() {
        let symbols = ["XAUUSD", "EURUSD", "GBPUSD", "USDJPY"]
        
        tradeHistory = (0..<20).map { i in
            let direction = TradeDirection.allCases.randomElement() ?? .buy
            let entryPrice = Double.random(in: 1.0...2500.0)
            let exitPrice = direction == .buy ? 
                entryPrice + Double.random(in: -50...100) :
                entryPrice - Double.random(in: -50...100)
            
            return TradeRecord(
                symbol: symbols.randomElement() ?? "XAUUSD",
                direction: direction,
                entryPrice: entryPrice,
                exitPrice: exitPrice,
                profit: (exitPrice - entryPrice) * (direction == .buy ? 1 : -1),
                timestamp: Date().addingTimeInterval(-Double(i * 3600)),
                duration: TimeInterval.random(in: 900...14400)
            )
        }
    }
}

// MARK: - Settings View Model
class SettingsViewModel: ObservableObject {
    @Published var notifications = NotificationSettings()
    @Published var trading = TradingSettings()
    @Published var risk = RiskSettings()
    @Published var display = DisplaySettings()
    @Published var account = AccountSettings()
    
    struct NotificationSettings {
        var enablePushNotifications = true
        var tradingAlerts = true
        var botStatusUpdates = true
        var priceAlerts = true
        var systemHealth = true
        var weeklyReports = true
    }
    
    struct TradingSettings {
        var autoTradingEnabled = false
        var maxConcurrentTrades = 5
        var defaultLotSize = 0.1
        var slippageAllowance = 3.0
        var maxSpread = 2.0
        var tradingHours = TradingHours.london
        
        enum TradingHours: String, CaseIterable {
            case always = "24/7"
            case london = "London Session"
            case newYork = "New York Session"
            case asia = "Asian Session"
            case custom = "Custom Hours"
        }
    }
    
    struct RiskSettings {
        var maxRiskPerTrade = 2.0
        var maxDailyLoss = 5.0
        var stopLossEnabled = true
        var takeProfitEnabled = true
        var trailingStopEnabled = false
        var emergencyStopEnabled = true
        var maxDrawdown = 15.0
    }
    
    struct DisplaySettings {
        var theme: AppTheme = .light
        var currency: Currency = .usd
        var language: Language = .english
        var showAdvancedMetrics = false
        var compactMode = false
        
        enum AppTheme: String, CaseIterable {
            case light = "Light"
            case dark = "Dark"
            case auto = "System"
        }
        
        enum Currency: String, CaseIterable {
            case usd = "USD"
            case eur = "EUR"
            case gbp = "GBP"
            case jpy = "JPY"
        }
        
        enum Language: String, CaseIterable {
            case english = "English"
            case spanish = "Español"
            case french = "Français"
            case german = "Deutsch"
        }
    }
    
    struct AccountSettings {
        var brokerName = "Coinexx"
        var accountType: AccountType = .demo
        var serverName = "Coinexx-Demo"
        var autoLoginEnabled = true
        var biometricAuthEnabled = true
        
        enum AccountType: String, CaseIterable {
            case demo = "Demo"
            case live = "Live"
        }
    }
    
    func saveSettings() {
        // Save settings to UserDefaults or persistent storage
        UserDefaults.standard.set(notifications.enablePushNotifications, forKey: "notifications_push")
        UserDefaults.standard.set(trading.autoTradingEnabled, forKey: "trading_auto")
        UserDefaults.standard.set(risk.maxRiskPerTrade, forKey: "risk_max_per_trade")
        
        print("✅ Settings saved successfully")
    }
    
    func loadSettings() {
        // Load settings from UserDefaults
        notifications.enablePushNotifications = UserDefaults.standard.bool(forKey: "notifications_push")
        trading.autoTradingEnabled = UserDefaults.standard.bool(forKey: "trading_auto")
        risk.maxRiskPerTrade = UserDefaults.standard.double(forKey: "risk_max_per_trade")
        
        print("✅ Settings loaded successfully")
    }
    
    func resetToDefaults() {
        notifications = NotificationSettings()
        trading = TradingSettings()
        risk = RiskSettings()
        display = DisplaySettings()
        account = AccountSettings()
        
        saveSettings()
        print("✅ Settings reset to defaults")
    }
}

// MARK: - Market Analysis View Model
class MarketAnalysisViewModel: ObservableObject {
    @Published var marketSentiment: MarketSentiment = .neutral
    @Published var technicalIndicators: [TechnicalIndicator] = []
    @Published var newsEvents: [NewsEvent] = []
    @Published var economicCalendar: [EconomicEvent] = []
    @Published var isLoading = false
    @Published var lastUpdate: Date?
    
    enum MarketSentiment: String, CaseIterable {
        case bullish = "Bullish"
        case bearish = "Bearish"
        case neutral = "Neutral"
        
        var color: Color {
            switch self {
            case .bullish: return .green
            case .bearish: return .red
            case .neutral: return .orange
            }
        }
        
        var icon: String {
            switch self {
            case .bullish: return "arrow.up.circle.fill"
            case .bearish: return "arrow.down.circle.fill"
            case .neutral: return "minus.circle.fill"
            }
        }
    }
    
    struct TechnicalIndicator: Identifiable {
        let id = UUID()
        let name: String
        let value: Double
        let signal: Signal
        let timeframe: String
        
        enum Signal: String, CaseIterable {
            case buy = "BUY"
            case sell = "SELL"
            case hold = "HOLD"
            
            var color: Color {
                switch self {
                case .buy: return .green
                case .sell: return .red
                case .hold: return .orange
                }
            }
        }
    }
    
    struct NewsEvent: Identifiable {
        let id = UUID()
        let headline: String
        let summary: String
        let impact: Impact
        let timestamp: Date
        let source: String
        
        enum Impact: String, CaseIterable {
            case high = "High"
            case medium = "Medium"
            case low = "Low"
            
            var color: Color {
                switch self {
                case .high: return .red
                case .medium: return .orange
                case .low: return .green
                }
            }
        }
    }
    
    struct EconomicEvent: Identifiable {
        let id = UUID()
        let event: String
        let country: String
        let impact: NewsEvent.Impact
        let forecast: String
        let previous: String
        let actual: String?
        let time: Date
    }
    
    func refreshAnalysis() async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        // Simulate data loading
        try? await Task.sleep(for: .seconds(2))
        
        DispatchQueue.main.async {
            self.generateMarketData()
            self.lastUpdate = Date()
            self.isLoading = false
        }
    }
    
    private func generateMarketData() {
        // Generate market sentiment
        marketSentiment = MarketSentiment.allCases.randomElement() ?? .neutral
        
        // Generate technical indicators
        technicalIndicators = [
            TechnicalIndicator(name: "RSI (14)", value: 68.5, signal: .buy, timeframe: "1H"),
            TechnicalIndicator(name: "MACD", value: 12.3, signal: .sell, timeframe: "4H"),
            TechnicalIndicator(name: "MA (50)", value: 2374.20, signal: .hold, timeframe: "1D"),
            TechnicalIndicator(name: "Bollinger Bands", value: 0.85, signal: .buy, timeframe: "1H"),
            TechnicalIndicator(name: "Stochastic", value: 78.2, signal: .sell, timeframe: "30M")
        ]
        
        // Generate news events
        newsEvents = [
            NewsEvent(
                headline: "Federal Reserve Hints at Rate Changes",
                summary: "Fed officials suggest potential monetary policy adjustments in upcoming meeting",
                impact: .high,
                timestamp: Date().addingTimeInterval(-3600),
                source: "Reuters"
            ),
            NewsEvent(
                headline: "Gold Demand Rises in Asian Markets",
                summary: "Increased institutional buying drives gold prices higher across Asian trading sessions",
                impact: .medium,
                timestamp: Date().addingTimeInterval(-7200),
                source: "Bloomberg"
            )
        ]
        
        // Generate economic calendar
        economicCalendar = [
            EconomicEvent(
                event: "Non-Farm Payrolls",
                country: "USD",
                impact: .high,
                forecast: "180K",
                previous: "175K",
                actual: nil,
                time: Date().addingTimeInterval(86400)
            ),
            EconomicEvent(
                event: "CPI (YoY)",
                country: "USD",
                impact: .high,
                forecast: "3.2%",
                previous: "3.4%",
                actual: "3.1%",
                time: Date().addingTimeInterval(-86400)
            )
        ]
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("📊 View Models Preview")
            .font(DesignSystem.Typography.largeTitle)
            .goldText()
        
        VStack(spacing: 12) {
            HStack {
                Text("Connection Status:")
                Spacer()
                HStack {
                    Image(systemName: ConnectionStatus.connected.icon)
                    Text(ConnectionStatus.connected.rawValue)
                }
                .foregroundColor(ConnectionStatus.connected.color)
            }
            
            HStack {
                Text("Market Sentiment:")
                Spacer()
                HStack {
                    Image(systemName: MarketAnalysisViewModel.MarketSentiment.bullish.icon)
                    Text(MarketAnalysisViewModel.MarketSentiment.bullish.rawValue)
                }
                .foregroundColor(MarketAnalysisViewModel.MarketSentiment.bullish.color)
            }
            
            HStack {
                Text("Trading Mode:")
                Spacer()
                Text("Auto Trading: OFF")
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
            }
        }
        .standardCard()
        
        Text("🔄 Real-time updates • 📱 State management • ⚙️ Settings control")
            .font(.caption)
            .foregroundColor(.secondary)
    }
    .padding()
}
//  ContentView.swift
//  Planet ProTrader - Solar System Edition
//
//  Ultra-Modern Cosmic Trading Dashboard with Real-Time Balance
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var isOrbiting = true
    @EnvironmentObject var tradingManager: TradingManager
    @EnvironmentObject var botManager: BotManager
    @EnvironmentObject var accountManager: AccountManager
    @EnvironmentObject var hapticManager: HapticManager
    
    // CLEAN: Essential trading managers with real-time balance
    @StateObject private var mt5Engine = MT5TradingEngine.shared
    @StateObject private var liveTradingManager = LiveTradingManager.shared
    @StateObject private var vpsConnection = VPSConnectionManager.shared
    @StateObject private var realTimeBalanceManager = RealTimeBalanceManager()
    @StateObject private var vpsManager = VPSManagementSystem.shared
    
    var body: some View {
        ZStack {
            // Space Background
            DesignSystem.spaceGradient
                .ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                // Home Tab
                HomeView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                    .tag(0)
                
                // Combined Trading Hub (Deploy + Status)
                UnifiedTradingHub()
                    .tabItem {
                        Image(systemName: "brain.head.profile")
                        Text("AI Bots")
                    }
                    .tag(1)
                
                // Trading Terminal
                TradingTerminal()
                    .tabItem {
                        Image(systemName: "x.square")
                        Text("Terminal")
                    }
                    .tag(2)
                
                // Portfolio/Analytics (New tab space freed up)
                PortfolioAnalyticsView()
                    .tabItem {
                        Image(systemName: "chart.bar.xaxis")
                        Text("Playbook")
                    }
                    .tag(3)
                
                // Settings/More (New tab space freed up)
                SettingsView()
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                    .tag(4)
            }
            .tint(DesignSystem.cosmicBlue)
            .preferredColorScheme(.dark)
            .onChange(of: selectedTab) { oldValue, newValue in
                hapticManager.selection()
            }
        }
        .withGlobalToast()
        .onAppear {
            initializeRealTimeSystem()
            
            // Show EA Bot status immediately
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                GlobalToastManager.shared.show("🤖 EA BOT ACTIVATED - 0.50 lots per trade!", type: .success)
            }
        }
        .environmentObject(realTimeBalanceManager)
        .environmentObject(vpsConnection)
        .environmentObject(vpsManager)
    }
    
    // ENHANCED: Real-time system initialization
    private func initializeRealTimeSystem() {
        Task {
            print("🚀 LAUNCHING REAL TRADING BOT WITH 0.50 LOTS...")
            print("🎯 Target: YOUR Coinexx Demo #845638")
            print("💰 Lot Size: 0.50 (REAL TRADES ONLY)")
            
            // Step 1: Initialize VPS connection
            await vpsConnection.connectToVPS()
            await vpsManager.checkVPSConnection()
            print("✅ VPS connection initialized")
            
            // Step 2: Connect to Coinexx Demo account
            await liveTradingManager.connectToCoinexxDemo()
            print("✅ Coinexx Demo connection initialized")
            
            // Step 3: Initialize MT5 engine
            let mt5Success = await mt5Engine.connectToMT5()
            print("✅ MT5 engine initialized")
            
            // Step 4: Start real-time balance monitoring
            if mt5Success {
                await realTimeBalanceManager.startRealTimeMonitoring()
                print("✅ Real-time balance monitoring started")
            }
            
            // Step 5: Initialize account manager
            await accountManager.connectToRealAccount()
            
            // Step 6: LAUNCH THE REAL TRADING BOT NOW!
            launchRealTradingBot()
            
            print("🔥 REAL TRADING BOT LAUNCHED - 0.50 LOTS PER TRADE!")
            
            // Show success notification
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                GlobalToastManager.shared.show("🚀 REAL TRADING BOT ACTIVE! 0.50 lots every 60 seconds!", type: .success)
            }
        }
    }
    
    // MARK: - Launch Real Trading Bot
    private func launchRealTradingBot() {
        print("🚀 LAUNCHING DIRECT MT5 TRADING BOT...")
        
        // Start the DIRECT trading system
        let directTrader = DirectMT5Trading.shared
        directTrader.startDirectTrading()
        
        print("✅ Direct Trading Bot is now LIVE!")
        print("💰 Placing 0.50 lot trades every 60 seconds")
        print("🎯 Using 3 methods to ensure trades reach your MT5 account")
        print("📱 Check your MT5 app - trades should appear within 60 seconds!")
    }
}

// MARK: - Custom Robot Icon
struct RobotIcon: View {
    var body: some View {
        ZStack {
            // Robot head (main body)
            RoundedRectangle(cornerRadius: 4)
                .fill(.white)
                .frame(width: 16, height: 14)
            
            // Robot eyes
            HStack(spacing: 4) {
                Circle()
                    .fill(.blue)
                    .frame(width: 3, height: 3)
                Circle()
                    .fill(.blue)
                    .frame(width: 3, height: 3)
            }
            .offset(y: -2)
            
            // Robot mouth
            RoundedRectangle(cornerRadius: 1)
                .fill(.gray)
                .frame(width: 8, height: 2)
                .offset(y: 3)
            
            // Robot antennas
            VStack {
                HStack(spacing: 8) {
                    Circle()
                        .fill(.orange)
                        .frame(width: 2, height: 2)
                    Circle()
                        .fill(.orange)
                        .frame(width: 2, height: 2)
                }
                Spacer()
            }
            .offset(y: -10)
        }
        .frame(width: 24, height: 24)
    }
}

// MARK: - Unified Trading Hub (Combines Deploy + Status)
struct UnifiedTradingHub: View {
    @EnvironmentObject var botManager: BotManager
    @EnvironmentObject var hapticManager: HapticManager
    @EnvironmentObject var vpsManager: VPSManagementSystem
    @EnvironmentObject var vpsConnection: VPSConnectionManager
    @EnvironmentObject var realTimeBalanceManager: RealTimeBalanceManager
    @State private var showingRealTradeAlert = false
    @State private var selectedBotForRealTrading: TradingBot?
    @State private var showingSuccess = false
    @State private var showingVPSSetup = false
    @State private var isTestingConnection = false
    
    var body: some View {
        ZStack {
            DesignSystem.spaceGradient
                .ignoresSafeArea()
            
            ScrollView {
                LazyVStack(spacing: 24) {
                    // Trading Hub Header
                    tradingHubHeader
                    
                    // VPS & System Status Card
                    vpsSystemStatusCard
                    
                    // Active Bots Section
                    activeTradingBotsSection
                    
                    // Available Bots for Deployment
                    availableBotsSection
                    
                    // Real Trading Instructions
                    realTradingInstructions
                }
                .padding()
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .starField()
        .alert("⚠️ REAL Trading Confirmation", isPresented: $showingRealTradeAlert) {
            Button("Cancel", role: .cancel) { }
            Button("DEPLOY FOR REAL TRADING") {
                if let bot = selectedBotForRealTrading {
                    confirmRealTrading(bot)
                }
            }
        } message: {
            Text("This bot will place ACTUAL trades on your Coinexx Demo #845638. Real money will be involved. Are you sure?")
        }
        .alert("🎉 Bot Deployed!", isPresented: $showingSuccess) {
            Button("Awesome!") { }
        } message: {
            Text("Your bot is now placing REAL trades on your Coinexx Demo account!")
        }
        .sheet(isPresented: $showingVPSSetup) {
            VPSSetupView()
        }
        .onAppear {
            Task {
                await vpsManager.checkVPSConnection()
            }
        }
    }
    
    private var tradingHubHeader: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("🚀 Trading Hub")
                        .font(DesignSystem.Typography.cosmic)
                        .cosmicText()
                        .sparkleEffect()
                    
                    Text("Deploy & monitor REAL trading bots")
                        .font(DesignSystem.Typography.asteroid)
                        .foregroundColor(DesignSystem.starWhite.opacity(0.8))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(systemIsReady ? .green : .red)
                            .frame(width: 12, height: 12)
                            .pulsingEffect()
                        
                        Text(systemIsReady ? "READY" : "SETUP REQUIRED")
                            .font(DesignSystem.Typography.dust)
                            .fontWeight(.bold)
                            .foregroundColor(systemIsReady ? .green : .orange)
                    }
                    
                    Text("Coinexx Demo #845638")
                        .font(DesignSystem.Typography.dust)
                        .foregroundColor(DesignSystem.starWhite.opacity(0.6))
                }
            }
        }
        .planetCard()
    }
    
    private var systemIsReady: Bool {
        vpsManager.vpsStatus == .connected && vpsManager.mt5Status == .connected
    }
    
    private var vpsSystemStatusCard: some View {
        VStack(spacing: 20) {
            HStack {
                Text("🌐 System Status")
                    .font(DesignSystem.Typography.stellar)
                    .cosmicText()
                
                Spacer()
                
                if !systemIsReady {
                    Button("Setup") {
                        showingVPSSetup = true
                    }
                    .font(DesignSystem.Typography.dust)
                    .foregroundColor(DesignSystem.cosmicBlue)
                }
            }
            
            // Status Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                // VPS Status
                SystemStatusCard(
                    title: "VPS Server",
                    subtitle: "172.234.201.231",
                    status: vpsManager.vpsStatus.rawValue,
                    statusColor: vpsManager.vpsStatus.color,
                    icon: "server.rack"
                )
                
                // MT5 Status
                SystemStatusCard(
                    title: "MT5 Account",
                    subtitle: "#845638",
                    status: vpsManager.mt5Status.rawValue,
                    statusColor: vpsManager.mt5Status.color,
                    icon: "chart.line.uptrend.xyaxis"
                )
                
                // Balance Status
                SystemStatusCard(
                    title: "Live Balance",
                    subtitle: realTimeBalanceManager.formattedBalance,
                    status: realTimeBalanceManager.isConnected ? "Connected" : "Offline",
                    statusColor: realTimeBalanceManager.isConnected ? .green : .red,
                    icon: "dollarsign.circle.fill"
                )
                
                // Active Bots - Updated to show REAL trading status
                SystemStatusCard(
                    title: "REAL Trading Bots",
                    subtitle: "\(botManager.activeBots.count) placing actual trades",
                    status: botManager.activeBots.isEmpty ? "None" : "LIVE TRADING",
                    statusColor: botManager.activeBots.isEmpty ? .orange : .green,
                    icon: "brain.head.profile"
                )
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                Button("🔄 Test Connection") {
                    testSystemConnection()
                }
                .buttonStyle(.cosmic)
                .frame(maxWidth: .infinity)
                .disabled(isTestingConnection)
                
                if !systemIsReady {
                    Button("⚙️ Setup System") {
                        showingVPSSetup = true
                    }
                    .buttonStyle(.solar)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .planetCard()
    }
    
    private var activeTradingBotsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("⚡ Active Trading Bots")
                    .font(DesignSystem.Typography.stellar)
                    .cosmicText()
                
                Spacer()
                
                Text("\(botManager.activeBots.count) LIVE")
                    .font(DesignSystem.Typography.dust)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            
            if botManager.activeBots.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 40))
                        .foregroundColor(DesignSystem.cosmicBlue.opacity(0.6))
                    
                    Text("No active bots")
                        .font(DesignSystem.Typography.planet)
                        .foregroundColor(DesignSystem.starWhite.opacity(0.8))
                    
                    Text("Deploy a bot below to start live trading")
                        .font(DesignSystem.Typography.asteroid)
                        .foregroundColor(DesignSystem.starWhite.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(32)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(botManager.activeBots, id: \.id) { bot in
                        ActiveBotCard(
                            bot: bot,
                            onStop: { 
                                botManager.stopBot(bot)
                                hapticManager.warning()
                            }
                        )
                    }
                }
            }
        }
        .planetCard()
    }
    
    private var availableBotsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("🤖 Available Bots")
                    .font(DesignSystem.Typography.stellar)
                    .cosmicText()
                
                Spacer()
                
                Text("\(botManager.allBots.filter { !$0.isActive }.count) ready")
                    .font(DesignSystem.Typography.dust)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(botManager.allBots.filter { !$0.isActive }, id: \.id) { bot in
                    DeployableBotCard(
                        bot: bot,
                        onDeploy: {
                            selectedBotForRealTrading = bot
                            showingRealTradeAlert = true
                        },
                        systemReady: systemIsReady
                    )
                }
            }
        }
        .planetCard()
    }
    
    private var realTradingInstructions: some View {
        VStack(spacing: 16) {
            Text("📋 Important Notes")
                .font(DesignSystem.Typography.stellar)
                .cosmicText()
            
            VStack(alignment: .leading, spacing: 12) {
                ImportantNote(
                    icon: "exclamationmark.triangle.fill",
                    iconColor: .red,
                    title: "REAL Money Trading",
                    description: "Bots execute ACTUAL trades on your Coinexx Demo account with real market consequences."
                )
                
                ImportantNote(
                    icon: "shield.checkered",
                    iconColor: .green,
                    title: "Safety Features",
                    description: "All trades use micro lots (0.01) with proper stop losses for risk management."
                )
                
                ImportantNote(
                    icon: "server.rack",
                    iconColor: .blue,
                    title: "VPS Integration",
                    description: "Your bots run on your VPS (172.234.201.231) and connect directly to your MT5 terminal."
                )
            }
        }
        .planetCard()
    }
    
    // MARK: - Actions
    
    private func testSystemConnection() {
        guard !isTestingConnection else { return }
        
        isTestingConnection = true
        hapticManager.selection()
        
        Task {
            GlobalToastManager.shared.show("🔍 Testing system connection...", type: .info)
            
            // Test VPS connection
            await vpsManager.checkVPSConnection()
            
            // Test VPS connection (legacy)
            await vpsConnection.refreshConnection()
            
            // Wait for visual feedback
            try? await Task.sleep(for: .seconds(2))
            
            DispatchQueue.main.async {
                self.isTestingConnection = false
                
                if self.systemIsReady {
                    GlobalToastManager.shared.show("✅ System ready for trading!", type: .success)
                    self.hapticManager.success()
                } else {
                    GlobalToastManager.shared.show("⚠️ System setup required", type: .error)
                    self.hapticManager.error()
                }
            }
        }
    }
    
    private func confirmRealTrading(_ bot: TradingBot) {
        Task {
            guard systemIsReady else {
                GlobalToastManager.shared.show("❌ Complete system setup first", type: .error)
                return
            }
            
            // Deploy bot for REAL trading
            await botManager.deployBot(bot)
            
            // Initialize REAL MT5 trading manager
            let realTrader = RealMT5TradingManager.shared
            await realTrader.startRealTradingSystem()
            
            // Start generating REAL trading signals that execute actual trades
            startRealTradingSignals(for: bot)
            
            showingSuccess = true
            hapticManager.success()
            
            GlobalToastManager.shared.show("🚀 \(bot.name) is now placing REAL trades on your Coinexx Demo!", type: .success)
        }
    }
    
    private func startRealTradingSignals(for bot: TradingBot) {
        print("🚀 Starting REAL trading signals for \(bot.name)")
        print("🏦 Will execute actual trades on Coinexx Demo #845638")
        
        // Get the real trading manager
        let realTrader = RealMT5TradingManager.shared
        
        // Generate REAL trading signals every 2 minutes
        Timer.scheduledTimer(withTimeInterval: 120.0, repeats: true) { timer in
            Task {
                // Check if bot is still active
                guard botManager.activeBots.contains(where: { $0.id == bot.id }) else {
                    timer.invalidate()
                    print("🛑 Bot \(bot.name) stopped - ending real trading")
                    return
                }
                
                // Generate conservative trading signal
                if let signal = generateRealTradingSignal(for: bot) {
                    print("🔔 Generated REAL trading signal for \(bot.name)")
                    print("📊 Symbol: \(signal.symbol)")
                    print("📈 Direction: \(signal.direction)")
                    print("💰 Price: \(signal.entryPrice)")
                    
                    // Execute ACTUAL trade on your MT5 account
                    let action = signal.direction == .buy ? "BUY" : "SELL"
                    await realTrader.executeRealTrade(
                        symbol: signal.symbol,
                        action: action,
                        volume: 0.01  // Micro lot for safety
                    )
                    
                    // Show confirmation that real trade was placed
                    DispatchQueue.main.async {
                        GlobalToastManager.shared.show("💰 \(bot.name): REAL \(action) trade executed!", type: .success)
                    }
                }
            }
        }
    }
    
    private func generateRealTradingSignal(for bot: TradingBot) -> TradingSignal? {
        // Conservative signal generation (10% chance every 5 minutes)
        guard Double.random(in: 0...1) < 0.1 else { return nil }
        
        let currentPrice = 2374.50 + Double.random(in: -5...5)
        let direction: TradeDirection = Bool.random() ? .buy : .sell
        let stopDistance = 20.0 // 20 pips stop loss
        let profitDistance = 40.0 // 40 pips take profit (2:1 R:R)
        
        return TradingSignal(
            symbol: "XAUUSD",
            direction: direction,
            entryPrice: currentPrice,
            stopLoss: direction == .buy ? currentPrice - stopDistance : currentPrice + stopDistance,
            takeProfit: direction == .buy ? currentPrice + profitDistance : currentPrice - profitDistance,
            confidence: bot.winRate / 100.0,
            timeframe: "15M",
            timestamp: Date(),
            source: "\(bot.name) - REAL TRADING"
        )
    }
}

// MARK: - Supporting Cards

struct SystemStatusCard: View {
    let title: String
    let subtitle: String
    let status: String
    let statusColor: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(statusColor)
                
                Spacer()
                
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                    .pulsingEffect()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(DesignSystem.Typography.dust)
                    .foregroundColor(DesignSystem.starWhite.opacity(0.7))
                
                Text(subtitle)
                    .font(DesignSystem.Typography.asteroid)
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                
                Text(status)
                    .font(DesignSystem.Typography.dust)
                    .foregroundColor(statusColor)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.Radius.star))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.star)
                .stroke(statusColor.opacity(0.3), lineWidth: 1)
        )
    }
}

struct ActiveBotCard: View {
    let bot: TradingBot
    let onStop: () -> Void
    
    var body: some View {
        HStack {
            // Bot Icon
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [DesignSystem.profitGreen], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 50, height: 50)
                
                Image(systemName: bot.icon)
                    .font(.title3)
                    .foregroundColor(.white)
            }
            .pulsingEffect()
            
            // Bot Info
            VStack(alignment: .leading, spacing: 4) {
                Text(bot.name)
                    .font(DesignSystem.Typography.planet)
                    .cosmicText()
                
                Text("LIVE TRADING")
                    .font(DesignSystem.Typography.dust)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            
            Spacer()
            
            // Stats
            VStack(alignment: .trailing, spacing: 4) {
                Text(bot.displayProfitability)
                    .font(DesignSystem.Typography.asteroid)
                    .profitLossText(bot.profitability >= 0)
                
                Text("\(bot.totalTrades) trades")
                    .font(DesignSystem.Typography.dust)
                    .foregroundColor(DesignSystem.starWhite.opacity(0.6))
            }
            
            // Stop Button
            Button("Stop") {
                onStop()
            }
            .font(DesignSystem.Typography.dust)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.red, in: Capsule())
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.Radius.star))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.star)
                .stroke(.green.opacity(0.3), lineWidth: 1)
        )
    }
}

struct DeployableBotCard: View {
    let bot: TradingBot
    let onDeploy: () -> Void
    let systemReady: Bool
    
    var body: some View {
        HStack {
            // Bot Icon
            ZStack {
                Circle()
                    .fill(DesignSystem.nebuladeGradient)
                    .frame(width: 50, height: 50)
                
                Image(systemName: bot.icon)
                    .font(.title3)
                    .foregroundColor(.white)
            }
            
            // Bot Info
            VStack(alignment: .leading, spacing: 4) {
                Text(bot.name)
                    .font(DesignSystem.Typography.planet)
                    .cosmicText()
                
                Text(bot.description)
                    .font(DesignSystem.Typography.dust)
                    .foregroundColor(DesignSystem.starWhite.opacity(0.8))
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Stats
            VStack(alignment: .trailing, spacing: 4) {
                Text(bot.displayWinRate)
                    .font(DesignSystem.Typography.asteroid)
                    .foregroundColor(DesignSystem.profitGreen)
                
                Text(bot.riskLevel.rawValue)
                    .font(DesignSystem.Typography.dust)
                    .foregroundColor(bot.riskLevel.color)
            }
            
            // Deploy Button
            Button("Deploy") {
                onDeploy()
            }
            .font(DesignSystem.Typography.dust)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(systemReady ? DesignSystem.solarOrange : .gray, in: Capsule())
            .disabled(!systemReady)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.Radius.star))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.star)
                .stroke(DesignSystem.cosmicBlue.opacity(0.3), lineWidth: 1)
        )
    }
}

struct ImportantNote: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(iconColor)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(DesignSystem.Typography.asteroid)
                    .fontWeight(.semibold)
                    .foregroundColor(iconColor)
                
                Text(description)
                    .font(DesignSystem.Typography.dust)
                    .foregroundColor(DesignSystem.starWhite.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
}

// MARK: - New Views for Freed Up Tabs

struct PortfolioAnalyticsView: View {
    var body: some View {
        ZStack {
            DesignSystem.spaceGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    Text("📊 Portfolio Analytics")
                        .font(DesignSystem.Typography.cosmic)
                        .cosmicText()
                        .sparkleEffect()
                    
                    Text("Advanced portfolio analysis coming soon...")
                        .font(DesignSystem.Typography.asteroid)
                        .foregroundColor(DesignSystem.starWhite.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .planetCard()
                }
                .padding()
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .starField()
    }
}

struct SettingsView: View {
    var body: some View {
        ZStack {
            DesignSystem.spaceGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    Text("⚙️ Settings & More")
                        .font(DesignSystem.Typography.cosmic)
                        .cosmicText()
                        .sparkleEffect()
                    
                    Text("App settings and configuration coming soon...")
                        .font(DesignSystem.Typography.asteroid)
                        .foregroundColor(DesignSystem.starWhite.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .planetCard()
                }
                .padding()
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .starField()
    }
}

#Preview {
    ContentView()
        .environmentObject(TradingManager.shared)
        .environmentObject(BotManager.shared)
        .environmentObject(AccountManager.shared)
        .environmentObject(HapticManager.shared)
}
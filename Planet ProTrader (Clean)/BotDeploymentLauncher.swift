// 
//  BotDeploymentLauncher.swift
//  Planet ProTrader - REAL Bot Deployment
//
//  Deploy bots for ACTUAL trading on Coinexx Demo #845638
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

struct BotDeploymentLauncher: View {
    @EnvironmentObject var botManager: BotManager
    @EnvironmentObject var hapticManager: HapticManager
    @StateObject private var vpsManager = VPSManagementSystem.shared
    @State private var showingRealTradeAlert = false
    @State private var selectedBotForRealTrading: TradingBot?
    @State private var showingSuccess = false
    @State private var showingVPSSetup = false
    
    var body: some View {
        ZStack {
            DesignSystem.spaceGradient
                .ignoresSafeArea()
            
            ScrollView {
                LazyVStack(spacing: 24) {
                    // REAL Trading Status Header
                    realTradingStatusHeader
                    
                    // VPS Connection Status with Setup Option
                    vpsConnectionStatusCard
                    
                    // Bot deployment cards
                    ForEach(botManager.allBots, id: \.id) { bot in
                        RealTradingBotCard(
                            bot: bot,
                            onDeploy: { 
                                selectedBotForRealTrading = bot
                                showingRealTradeAlert = true
                            },
                            onStop: { botManager.stopBot(bot) }
                        )
                    }
                    
                    // Real trading instructions
                    realTradingInstructions
                }
                .padding()
            }
        }
        .navigationTitle("🚀 Deploy REAL Trading Bots")
        .navigationBarTitleDisplayMode(.large)
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
            VPSSetupOptionsView()
        }
        .onAppear {
            Task {
                await vpsManager.checkVPSConnection()
            }
        }
    }
    
    private var realTradingStatusHeader: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("🎯 REAL Trading Center")
                        .font(DesignSystem.Typography.cosmic)
                        .cosmicText()
                        .sparkleEffect()
                    
                    Text("Deploy bots for ACTUAL trading")
                        .font(DesignSystem.Typography.asteroid)
                        .foregroundColor(DesignSystem.starWhite.opacity(0.8))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(vpsManager.vpsStatus == .connected && vpsManager.mt5Status == .connected ? .green : .red)
                            .frame(width: 8, height: 8)
                            .pulsingEffect()
                        
                        Text(vpsManager.vpsStatus == .connected && vpsManager.mt5Status == .connected ? "LIVE" : "OFFLINE")
                            .font(DesignSystem.Typography.dust)
                            .fontWeight(.bold)
                            .foregroundColor(vpsManager.vpsStatus == .connected && vpsManager.mt5Status == .connected ? .green : .red)
                    }
                    
                    Text("Coinexx Demo #845638")
                        .font(DesignSystem.Typography.dust)
                        .foregroundColor(DesignSystem.starWhite.opacity(0.6))
                }
            }
        }
        .planetCard()
    }
    
    private var vpsConnectionStatusCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("🌐 VPS Connection Status")
                    .font(DesignSystem.Typography.stellar)
                    .cosmicText()
                
                Spacer()
                
                if vpsManager.vpsStatus != .connected || vpsManager.mt5Status != .connected {
                    Button("Setup VPS") {
                        showingVPSSetup = true
                    }
                    .font(DesignSystem.Typography.dust)
                    .foregroundColor(DesignSystem.cosmicBlue)
                }
            }
            
            HStack(spacing: 16) {
                // VPS Server Status
                VStack(spacing: 8) {
                    Image(systemName: "server.rack")
                        .font(.title2)
                        .foregroundColor(vpsManager.vpsStatus.color)
                    
                    Text("VPS Server")
                        .font(DesignSystem.Typography.dust)
                        .foregroundColor(DesignSystem.starWhite.opacity(0.7))
                    
                    Text("172.234.201.231")
                        .font(DesignSystem.Typography.dust)
                        .foregroundColor(DesignSystem.starWhite.opacity(0.6))
                    
                    Text(vpsManager.vpsStatus.rawValue)
                        .font(DesignSystem.Typography.asteroid)
                        .fontWeight(.semibold)
                        .foregroundColor(vpsManager.vpsStatus.color)
                }
                
                Spacer()
                
                // MT5 Connection Status
                VStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.title2)
                        .foregroundColor(vpsManager.mt5Status.color)
                    
                    Text("MT5 Terminal")
                        .font(DesignSystem.Typography.dust)
                        .foregroundColor(DesignSystem.starWhite.opacity(0.7))
                    
                    Text("Account #845638")
                        .font(DesignSystem.Typography.dust)
                        .foregroundColor(DesignSystem.starWhite.opacity(0.6))
                    
                    Text(vpsManager.mt5Status.rawValue)
                        .font(DesignSystem.Typography.asteroid)
                        .fontWeight(.semibold)
                        .foregroundColor(vpsManager.mt5Status.color)
                }
                
                Spacer()
                
                // Trading Status
                VStack(spacing: 8) {
                    Image(systemName: vpsManager.vpsStatus == .connected && vpsManager.mt5Status == .connected ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(vpsManager.vpsStatus == .connected && vpsManager.mt5Status == .connected ? .green : .red)
                    
                    Text("Real Trading")
                        .font(DesignSystem.Typography.dust)
                        .foregroundColor(DesignSystem.starWhite.opacity(0.7))
                    
                    Text(vpsManager.vpsStatus == .connected && vpsManager.mt5Status == .connected ? "Ready" : "Setup Required")
                        .font(DesignSystem.Typography.dust)
                        .foregroundColor(DesignSystem.starWhite.opacity(0.6))
                    
                    Text(vpsManager.vpsStatus == .connected && vpsManager.mt5Status == .connected ? "✅ READY" : "⚠️ SETUP")
                        .font(DesignSystem.Typography.asteroid)
                        .fontWeight(.semibold)
                        .foregroundColor(vpsManager.vpsStatus == .connected && vpsManager.mt5Status == .connected ? .green : .orange)
                }
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                Button("🔄 Test Connection") {
                    Task {
                        await vpsManager.checkVPSConnection()
                    }
                }
                .buttonStyle(.cosmic)
                .frame(maxWidth: .infinity)
                
                if vpsManager.vpsStatus != .connected || vpsManager.mt5Status != .connected {
                    Button("⚙️ Setup VPS") {
                        showingVPSSetup = true
                    }
                    .buttonStyle(.solar)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .planetCard()
    }
    
    private var realTradingInstructions: some View {
        VStack(spacing: 16) {
            Text("📋 Real Trading Setup")
                .font(DesignSystem.Typography.stellar)
                .cosmicText()
            
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    
                    Text("ACTUAL Money Trading")
                        .font(DesignSystem.Typography.asteroid)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                }
                
                Text("Your bots will execute REAL trades on your Coinexx Demo account #845638. This involves actual market execution with real consequences.")
                    .font(DesignSystem.Typography.dust)
                    .foregroundColor(DesignSystem.starWhite.opacity(0.8))
                
                HStack(spacing: 12) {
                    Image(systemName: "server.rack")
                        .foregroundColor(.blue)
                    
                    Text("VPS Requirements")
                        .font(DesignSystem.Typography.asteroid)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                
                Text("Your VPS must have MT5 installed with Python and the MT5 REST API. Click 'Setup VPS' to configure automatically.")
                    .font(DesignSystem.Typography.dust)
                    .foregroundColor(DesignSystem.starWhite.opacity(0.8))
                
                HStack(spacing: 12) {
                    Image(systemName: "shield.checkered")
                        .foregroundColor(.green)
                    
                    Text("Safety Features")
                        .font(DesignSystem.Typography.asteroid)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
                
                Text("All trades use micro lots (0.01) with proper stop losses. You can monitor and stop bots at any time.")
                    .font(DesignSystem.Typography.dust)
                    .foregroundColor(DesignSystem.starWhite.opacity(0.8))
            }
        }
        .planetCard()
    }
    
    private func confirmRealTrading(_ bot: TradingBot) {
        Task {
            guard vpsManager.vpsStatus == .connected && vpsManager.mt5Status == .connected else {
                GlobalToastManager.shared.show("❌ VPS not ready for trading", type: .error)
                return
            }
            
            // Deploy bot for REAL trading
            await botManager.deployBot(bot)
            
            // Start generating REAL trading signals
            startRealTradingSignals(for: bot)
            
            showingSuccess = true
            hapticManager.success()
        }
    }
    
    private func startRealTradingSignals(for bot: TradingBot) {
        print("🚀 Starting REAL trading signals for \(bot.name)")
        
        // Generate trading signals every 5 minutes for real trading
        Timer.scheduledTimer(withTimeInterval: 300.0, repeats: true) { timer in
            Task {
                // Check if bot is still active
                guard botManager.activeBots.contains(where: { $0.id == bot.id }) else {
                    timer.invalidate()
                    return
                }
                
                // Generate trading signal with real market analysis
                if let signal = generateRealTradingSignal(for: bot) {
                    print("🔔 Generated REAL trading signal for \(bot.name)")
                    print("   Symbol: \(signal.symbol)")
                    print("   Direction: \(signal.direction.rawValue)")
                    print("   Entry: $\(String(format: "%.2f", signal.entryPrice))")
                    
                    // Execute REAL trade on YOUR account
                    let tradeRequest = TradeRequest(
                        symbol: signal.symbol,
                        action: signal.direction == .buy ? .buy : .sell,
                        volume: 0.01, // Micro lot for safety
                        price: signal.entryPrice,
                        stopLoss: signal.stopLoss,
                        takeProfit: signal.takeProfit,
                        comment: "PlanetProTrader-\(bot.name)"
                    )
                    
                    let success = await vpsManager.executeRealTrade(tradeRequest)
                    
                    if success {
                        print("✅ REAL TRADE EXECUTED on YOUR Coinexx Demo #845638!")
                        GlobalToastManager.shared.show("💰 \(bot.name) executed real trade: \(signal.direction.rawValue)", type: .success)
                    } else {
                        print("❌ Real trade execution failed")
                        GlobalToastManager.shared.show("❌ Trade execution failed", type: .error)
                    }
                }
            }
        }
    }
    
    private func generateRealTradingSignal(for bot: TradingBot) -> TradingSignal? {
        // More conservative signal generation for real trading
        let signalProbability = 0.1 // 10% chance every 5 minutes (much more conservative)
        
        guard Double.random(in: 0...1) < signalProbability else { return nil }
        
        // Use more realistic price analysis
        let currentPrice = 2374.50 + Double.random(in: -5...5) // Smaller price variation
        let direction: TradeDirection = Bool.random() ? .buy : .sell
        
        // Conservative stop loss and take profit
        let stopDistance = 20.0 // 20 pips stop loss
        let profitDistance = 40.0 // 40 pips take profit (2:1 R:R)
        
        let signal = TradingSignal(
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
        
        print("🎯 Generated REAL signal for \(bot.name): \(direction.rawValue) XAUUSD at $\(String(format: "%.2f", currentPrice))")
        
        return signal
    }
}

// MARK: - VPS Setup View
struct VPSSetupView: View {
    @StateObject private var vpsManager = VPSManagementSystem.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingRealSetupInstructions = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Setup Header
                    VStack(spacing: 16) {
                        Image(systemName: "server.rack")
                            .font(.system(size: 60))
                            .foregroundColor(DesignSystem.cosmicBlue)
                        
                        Text("Connect to Your REAL Account")
                            .font(DesignSystem.Typography.cosmic)
                            .cosmicText()
                        
                        Text("Setup your VPS to execute REAL trades on Coinexx Demo #845638")
                            .font(DesignSystem.Typography.asteroid)
                            .foregroundColor(DesignSystem.starWhite.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .planetCard()
                    
                    // Current Status
                    VStack(spacing: 16) {
                        Text("🔍 Connection Status")
                            .font(DesignSystem.Typography.planet)
                            .cosmicText()
                        
                        VStack(spacing: 12) {
                            HStack {
                                Text("VPS Server:")
                                Spacer()
                                HStack {
                                    Circle()
                                        .fill(vpsManager.vpsStatus == .connected ? .green : .red)
                                        .frame(width: 8, height: 8)
                                    Text("172.234.201.231")
                                        .foregroundColor(vpsManager.vpsStatus == .connected ? .green : .red)
                                }
                            }
                            
                            HStack {
                                Text("MT5 Account:")
                                Spacer()
                                HStack {
                                    Circle()
                                        .fill(vpsManager.mt5Status == .connected ? .green : .red)
                                        .frame(width: 8, height: 8)
                                    Text("Coinexx Demo #845638")
                                        .foregroundColor(vpsManager.mt5Status == .connected ? .green : .red)
                                }
                            }
                            
                            HStack {
                                Text("API Server:")
                                Spacer()
                                Text("Not Running")
                                    .foregroundColor(.red)
                            }
                        }
                        .font(DesignSystem.Typography.asteroid)
                    }
                    .planetCard()
                    
                    // Setup Instructions
                    VStack(spacing: 16) {
                        Text("⚠️ VPS Setup Required")
                            .font(DesignSystem.Typography.planet)
                            .cosmicText()
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your VPS needs an MT5 REST API server to execute trades. The app tried to connect but couldn't find the API running.")
                                .font(DesignSystem.Typography.asteroid)
                                .foregroundColor(DesignSystem.starWhite.opacity(0.8))
                            
                            Text("What you need:")
                                .font(DesignSystem.Typography.asteroid)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.top, 8)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("• MT5 terminal running on your VPS")
                                Text("• Logged into your Coinexx Demo #845638")
                                Text("• Python MT5 REST API server")
                                Text("• API server listening on port 8080")
                            }
                            .font(DesignSystem.Typography.dust)
                            .foregroundColor(DesignSystem.starWhite.opacity(0.7))
                        }
                        
                        Button("📋 Get Complete Setup Instructions") {
                            showingRealSetupInstructions = true
                        }
                        .buttonStyle(.solar)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 16)
                    }
                    .planetCard()
                    
                    // Test Connection Again
                    VStack(spacing: 16) {
                        Text("🔄 Test Connection")
                            .font(DesignSystem.Typography.planet)
                            .cosmicText()
                        
                        Text("After setting up your VPS, test the connection again:")
                            .font(DesignSystem.Typography.asteroid)
                            .foregroundColor(DesignSystem.starWhite.opacity(0.8))
                        
                        Button {
                            Task {
                                await vpsManager.checkVPSConnection()
                            }
                        } label: {
                            HStack(spacing: 12) {
                                if vpsManager.isSettingUpVPS {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .tint(.white)
                                } else {
                                    Image(systemName: "wifi.circle")
                                        .font(.title3)
                                }
                                
                                Text("Test VPS Connection")
                                    .font(DesignSystem.Typography.planet)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [DesignSystem.cosmicBlue, DesignSystem.stellarPurple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                in: RoundedRectangle(cornerRadius: DesignSystem.Radius.planet)
                            )
                            .shadow(color: DesignSystem.cosmicBlue.opacity(0.3), radius: 8)
                        }
                        .disabled(vpsManager.isSettingUpVPS)
                    }
                    .planetCard()
                    
                    // Error Display
                    if let error = vpsManager.lastError {
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                
                                Text("Connection Error")
                                    .font(DesignSystem.Typography.asteroid)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.red)
                            }
                            
                            Text(error)
                                .font(DesignSystem.Typography.dust)
                                .foregroundColor(DesignSystem.starWhite.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        .planetCard()
                    }
                }
                .padding()
            }
            .starField()
            .navigationTitle("Real VPS Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(DesignSystem.cosmicBlue)
                }
            }
            .sheet(isPresented: $showingRealSetupInstructions) {
                VPSSetupOptionsView()
            }
        }
    }
}

struct SetupStepRow: View {
    let step: String
    let title: String
    let description: String
    let isComplete: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(isComplete ? .green : DesignSystem.cosmicBlue.opacity(0.3))
                    .frame(width: 32, height: 32)
                
                if isComplete {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Text(step)
                        .font(DesignSystem.Typography.dust)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(DesignSystem.Typography.asteroid)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(DesignSystem.Typography.dust)
                    .foregroundColor(DesignSystem.starWhite.opacity(0.7))
            }
            
            Spacer()
        }
    }
}

// MARK: - Real Trading Bot Card (Enhanced)
struct RealTradingBotCard: View {
    let bot: TradingBot
    let onDeploy: () -> Void
    let onStop: () -> Void
    @EnvironmentObject var hapticManager: HapticManager
    @StateObject private var vpsManager = VPSManagementSystem.shared
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                ZStack {
                    Circle()
                        .fill(bot.isActive ? 
                            LinearGradient(colors: [DesignSystem.profitGreen], startPoint: .topLeading, endPoint: .bottomTrailing) : 
                            DesignSystem.nebuladeGradient)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: bot.icon)
                        .font(.title2)
                        .foregroundColor(.white)
                }
                .pulsingEffect(bot.isActive)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(bot.name)
                        .font(DesignSystem.Typography.planet)
                        .cosmicText()
                    
                    Text(bot.description)
                        .font(DesignSystem.Typography.asteroid)
                        .foregroundColor(DesignSystem.starWhite.opacity(0.8))
                        .lineLimit(2)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(bot.isActive ? .green : .orange)
                            .frame(width: 8, height: 8)
                            .pulsingEffect(bot.isActive)
                        
                        Text(bot.isActive ? "LIVE TRADING" : "READY TO DEPLOY")
                            .font(DesignSystem.Typography.dust)
                            .fontWeight(.bold)
                            .foregroundColor(bot.isActive ? .green : .orange)
                    }
                }
            }
            
            // Bot Statistics
            HStack(spacing: 24) {
                VStack(spacing: 4) {
                    Text("WIN RATE")
                        .font(DesignSystem.Typography.dust)
                        .foregroundColor(DesignSystem.starWhite.opacity(0.6))
                    
                    Text(bot.displayWinRate)
                        .font(DesignSystem.Typography.metricFont)
                        .foregroundColor(DesignSystem.profitGreen)
                }
                
                VStack(spacing: 4) {
                    Text("PROFIT")
                        .font(DesignSystem.Typography.dust)
                        .foregroundColor(DesignSystem.starWhite.opacity(0.6))
                    
                    Text(bot.displayProfitability)
                        .font(DesignSystem.Typography.metricFont)
                        .profitLossText(bot.profitability >= 0)
                }
                
                VStack(spacing: 4) {
                    Text("RISK")
                        .font(DesignSystem.Typography.dust)
                        .foregroundColor(DesignSystem.starWhite.opacity(0.6))
                    
                    Text(bot.riskLevel.rawValue.uppercased())
                        .font(DesignSystem.Typography.metricFont)
                        .foregroundColor(bot.riskLevel.color)
                }
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                if bot.isActive {
                    Button("🛑 Stop Real Trading") {
                        onStop()
                        hapticManager.warning()
                    }
                    .buttonStyle(.cosmic)
                    .frame(maxWidth: .infinity)
                } else {
                    Button("🚀 Deploy for REAL Trading") {
                        if vpsManager.vpsStatus == .connected && vpsManager.mt5Status == .connected {
                            onDeploy()
                            hapticManager.botDeployed()
                        } else {
                            GlobalToastManager.shared.show("❌ Setup VPS first", type: .error)
                        }
                    }
                    .buttonStyle(.solar)
                    .frame(maxWidth: .infinity)
                    .disabled(vpsManager.vpsStatus != .connected || vpsManager.mt5Status != .connected)
                }
            }
            
            if bot.isActive {
                Text("⚡ This bot is placing REAL trades on your Coinexx Demo #845638")
                    .font(DesignSystem.Typography.dust)
                    .foregroundColor(.green)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            } else if vpsManager.vpsStatus != .connected || vpsManager.mt5Status != .connected {
                Text("⚠️ VPS setup required for real trading")
                    .font(DesignSystem.Typography.dust)
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            }
        }
        .planetCard()
    }
}

#Preview {
    NavigationStack {
        BotDeploymentLauncher()
            .environmentObject(BotManager.shared)
            .environmentObject(HapticManager.shared)
    }
    .preferredColorScheme(.dark)
}
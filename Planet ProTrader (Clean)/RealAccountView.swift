//
//  RealAccountView.swift
//  Planet ProTrader - Real Coinexx Account Connection
//
//  Connect to live Coinexx demo for real bot trading
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

struct RealAccountView: View {
    @StateObject private var liveManager = LiveTradingManager.shared
    @StateObject private var eaManager = EAIntegrationManager.shared
    @State private var showingConnectionDetails = false
    @State private var isConnecting = false
    @State private var connectionSuccess = false
    @State private var selectedBot: TradingBot?
    @State private var showingEADeployment = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // EA Deployment Status
                    eaDeploymentCard
                    
                    // Connection Status
                    if !eaManager.isEADeployed {
                        connectionStatusCard
                    }
                    
                    // Account Details (if EA is deployed or connected)
                    if connectionSuccess || eaManager.isEADeployed {
                        accountDetailsCard
                    }
                    
                    // Active Bots Display
                    if eaManager.isEADeployed && !eaManager.activeBots.isEmpty {
                        activeBotsSection
                    }
                    
                    // Available Bots for Deployment
                    if eaManager.isEADeployed {
                        botDeploymentSection
                    }
                    
                    // Main Action Button
                    mainActionButton
                }
                .padding()
            }
            .navigationTitle("Live Trading")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingEADeployment) {
                EADeploymentView()
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 40))
                    .foregroundColor(DesignSystem.primaryGold)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Coinexx Demo Trading")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Account #845638 • Fully Automated")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Live indicator
                HStack(spacing: 6) {
                    Circle()
                        .fill(.green)
                        .frame(width: 8, height: 8)
                        .pulseEffect(true)
                    
                    Text("LIVE")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
        }
        .premiumCard()
    }
    
    private var eaDeploymentCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("🤖 Expert Advisor Status")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(eaManager.eaStatus.displayText)
                        .font(.subheadline)
                        .foregroundColor(eaManager.eaStatus.color)
                }
                
                Spacer()
                
                if eaManager.eaStatus == .running {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Active Bots")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(eaManager.getActiveBotsCount())")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
            }
            
            if eaManager.deploymentProgress > 0 && eaManager.deploymentProgress < 1 {
                VStack(spacing: 8) {
                    ProgressView(value: eaManager.deploymentProgress)
                        .progressViewStyle(LinearProgressViewStyle(tint: DesignSystem.primaryGold))
                    
                    Text(eaManager.deploymentStage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if eaManager.isEADeployed {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Profit")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(String(format: "+$%.2f", eaManager.getTotalProfit()))
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Last Signal")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if let lastSignal = eaManager.lastEASignal {
                            Text(timeAgo(from: lastSignal))
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        } else {
                            Text("Waiting...")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
        }
        .standardCard()
    }
    
    private var connectionStatusCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Connection Status")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Circle()
                        .fill(liveManager.connectionStatus.color)
                        .frame(width: 12, height: 12)
                        .pulseEffect(liveManager.isConnectedToMT5)
                    
                    Text(liveManager.connectionStatus.displayText)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(liveManager.connectionStatus.color)
                }
            }
            
            if connectionSuccess {
                VStack(spacing: 8) {
                    HStack {
                        Text("Account ID:")
                        Spacer()
                        Text("845638")
                            .fontWeight(.bold)
                            .foregroundColor(DesignSystem.primaryGold)
                    }
                    
                    HStack {
                        Text("Server:")
                        Spacer()
                        Text("Coinexx-demo")
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Platform:")
                        Spacer()
                        Text("MetaTrader 5")
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Currency:")
                        Spacer()
                        Text("USD")
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .standardCard()
    }
    
    private var accountDetailsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📊 Live Account Stats")
                .font(.headline)
                .fontWeight(.bold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                AccountStatCard(title: "Balance", value: "$10,000.00", color: .blue)
                AccountStatCard(title: "Equity", value: "$10,000.00", color: .green)
                AccountStatCard(title: "Margin", value: "$0.00", color: .orange)
                AccountStatCard(title: "Free Margin", value: "$10,000.00", color: .purple)
            }
        }
        .standardCard()
    }
    
    private var activeBotsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🏃‍♂️ Active Trading Bots")
                .font(.headline)
                .fontWeight(.bold)
            
            LazyVStack(spacing: 12) {
                ForEach(eaManager.activeBots) { bot in
                    ActiveBotCard(bot: bot) {
                        stopBot(bot)
                    }
                }
            }
        }
        .standardCard()
    }
    
    private var botDeploymentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🤖 Deploy Trading Bots")
                .font(.headline)
                .fontWeight(.bold)
            
            LazyVStack(spacing: 12) {
                ForEach(TradingBot.sampleBots, id: \.id) { bot in
                    BotDeploymentCard(bot: bot) {
                        deployBot(bot)
                    }
                }
            }
        }
        .standardCard()
    }
    
    private var mainActionButton: some View {
        Button(action: {
            if !eaManager.isEADeployed {
                showingEADeployment = true
            } else {
                // EA is deployed, show success message
            }
        }) {
            HStack {
                if !eaManager.isEADeployed {
                    Image(systemName: "rocket.fill")
                        .font(.title3)
                    
                    Text("Deploy EA & Start Trading")
                        .font(.headline)
                        .fontWeight(.bold)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                    
                    Text("EA Running • Ready to Deploy Bots")
                        .font(.headline)
                        .fontWeight(.bold)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                eaManager.isEADeployed ? 
                LinearGradient(colors: [.green, .green.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing) : 
                DesignSystem.goldGradient,
                in: RoundedRectangle(cornerRadius: 12)
            )
        }
    }
    
    private var connectButton: some View {
        Button(action: {
            connectToCoinexx()
        }) {
            HStack {
                if isConnecting {
                    ProgressView()
                        .scaleEffect(0.8)
                        .foregroundColor(.white)
                } else {
                    Image(systemName: connectionSuccess ? "checkmark.circle.fill" : "link")
                        .font(.title3)
                }
                
                Text(connectionSuccess ? "Connected to Coinexx Demo" : "Connect to Coinexx Demo")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                connectionSuccess ? 
                LinearGradient(colors: [.green, .green.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing) : 
                DesignSystem.goldGradient,
                in: RoundedRectangle(cornerRadius: 12)
            )
        }
        .disabled(isConnecting || connectionSuccess)
    }
    
    private func connectToCoinexx() {
        isConnecting = true
        HapticManager.shared.impact()
        
        Task {
            // Simulate connection process
            try? await Task.sleep(for: .seconds(2))
            
            await liveManager.connectToCoinexxDemo()
            
            DispatchQueue.main.async {
                self.isConnecting = false
                self.connectionSuccess = self.liveManager.isConnectedToMT5
                
                if self.connectionSuccess {
                    HapticManager.shared.success()
                } else {
                    HapticManager.shared.error()
                }
            }
        }
    }
    
    private func deployBot(_ bot: TradingBot) {
        selectedBot = bot
        HapticManager.shared.impact()
        
        Task {
            let success = await liveManager.deployBotForLiveTrading(bot)
            
            DispatchQueue.main.async {
                if success {
                    HapticManager.shared.botDeployed()
                } else {
                    HapticManager.shared.error()
                }
            }
        }
    }
    
    private func stopBot(_ bot: ActiveBot) {
        Task {
            let success = await eaManager.stopBot(bot.id)
            if success {
                HapticManager.shared.impact()
            }
        }
    }
    
    private func timeAgo(from date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        if seconds < 60 { return "\(seconds)s ago" }
        let minutes = seconds / 60
        if minutes < 60 { return "\(minutes)m ago" }
        let hours = minutes / 60
        return "\(hours)h ago"
    }
}

struct AccountStatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

struct BotDeploymentCard: View {
    let bot: TradingBot
    let onDeploy: () -> Void
    
    var body: some View {
        HStack {
            // Bot Icon & Info
            HStack(spacing: 12) {
                Image(systemName: bot.icon)
                    .font(.title2)
                    .foregroundColor(DesignSystem.primaryGold)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(bot.name)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    HStack {
                        Text("Win Rate: \(bot.displayWinRate)")
                            .font(.caption)
                            .foregroundColor(.green)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text("Risk: \(bot.riskLevel.rawValue)")
                            .font(.caption)
                            .foregroundColor(bot.riskLevel.color)
                    }
                }
            }
            
            Spacer()
            
            // Deploy Button
            Button(action: onDeploy) {
                HStack(spacing: 6) {
                    Image(systemName: "play.circle.fill")
                    Text("Deploy")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(DesignSystem.goldGradient, in: Capsule())
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct ActiveBotCard: View {
    let bot: ActiveBot
    let onStop: () -> Void
    
    var body: some View {
        HStack {
            // Bot Status & Info
            HStack(spacing: 12) {
                Circle()
                    .fill(bot.status.color)
                    .frame(width: 12, height: 12)
                    .pulseEffect(bot.status == .active)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(bot.name)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    HStack {
                        Text("\(bot.tradesCount) trades")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(bot.profitFormatted)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(bot.profitColor)
                    }
                }
            }
            
            Spacer()
            
            // Stop Button
            if bot.status == .active {
                Button(action: onStop) {
                    HStack(spacing: 6) {
                        Image(systemName: "stop.circle.fill")
                        Text("Stop")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.red, in: Capsule())
                }
            } else {
                Text(bot.status == .stopped ? "STOPPED" : "ERROR")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(bot.status.color, in: Capsule())
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    RealAccountView()
}
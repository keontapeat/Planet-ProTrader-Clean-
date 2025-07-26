//
//  DeployBotsView.swift
//  Planet ProTrader
//
//  Advanced Bot Deployment & Management Interface
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

struct DeployBotsView: View {
    @StateObject private var botManager = PersistentBotManager.shared
    @StateObject private var supabase = SupabaseManager.shared
    @State private var showingBotSelector = false
    @State private var selectedBotForDetails: DeployedBot?
    @State private var animateStats = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Cosmic background
                DesignSystem.AnimatedStarField()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // System Status Header
                        systemStatusHeader
                        
                        // Overall Statistics
                        overallStatsSection
                        
                        // Deployed Bots List
                        deployedBotsSection
                        
                        // Quick Actions
                        quickActionsSection
                        
                        // Supabase Connection Status
                        supabaseStatusSection
                    }
                    .padding()
                }
            }
            .navigationTitle("🤖 Deployed Bots")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingBotSelector = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(DesignSystem.cosmicBlue)
                    }
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0)) {
                    animateStats = true
                }
            }
        }
        .sheet(isPresented: $showingBotSelector) {
            BotSelectorSheet()
        }
        .sheet(item: $selectedBotForDetails) { bot in
            BotDetailsSheet(bot: bot)
        }
    }
    
    // MARK: - System Status Header
    
    private var systemStatusHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Circle()
                    .fill(botManager.systemStatus.color)
                    .frame(width: 12, height: 12)
                    .scaleEffect(animateStats ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: animateStats)
                
                Text(botManager.systemStatus.rawValue)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                if botManager.isProcessing {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.white)
                }
            }
            
            // Advanced Engines Status
            let enginesReport = botManager.getAdvancedEnginesReport()
            HStack(spacing: 12) {
                HStack(spacing: 6) {
                    Text(enginesReport.overallRating.emoji)
                    Text(enginesReport.overallRating.rawValue)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(enginesReport.overallRating.color)
                        .tracking(1.2)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(enginesReport.overallRating.color.opacity(0.2))
                        .overlay(
                            Capsule()
                                .stroke(enginesReport.overallRating.color.opacity(0.5), lineWidth: 1)
                        )
                )
                
                Text(botManager.advancedEnginesStatus.statusMessage)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            // Real Trading Status
            if botManager.isRealTradingEnabled {
                HStack(spacing: 8) {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundColor(.green)
                    
                    Text("REAL TRADING ACTIVE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                        .tracking(1.2)
                    
                    Circle()
                        .fill(.green)
                        .frame(width: 6, height: 6)
                        .scaleEffect(animateStats ? 1.5 : 1.0)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: animateStats)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(.green.opacity(0.2))
                        .overlay(
                            Capsule()
                                .stroke(.green.opacity(0.5), lineWidth: 1)
                        )
                )
            }
            
            // Advanced Engines Detail
            if enginesReport.status.overallEngineHealth > 0 {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Advanced Engines Status:")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 6) {
                        EngineStatusItem(
                            name: "Timeframe Analysis",
                            isActive: enginesReport.timeframeAnalysisActive,
                            icon: "chart.line.uptrend.xyaxis"
                        )
                        
                        EngineStatusItem(
                            name: "Market Structure",
                            isActive: enginesReport.structureAnalysisActive,
                            icon: "building.columns"
                        )
                        
                        EngineStatusItem(
                            name: "AutoPilot Engine",
                            isActive: enginesReport.autopilotHealth > 80,
                            icon: "airplane.circle"
                        )
                        
                        EngineStatusItem(
                            name: "Strategy Rebuilder",
                            isActive: enginesReport.strategyRebuilderStatus.isActive,
                            icon: "hammer.circle"
                        )
                    }
                    
                    // Analysis Quality Indicator
                    HStack {
                        Text("Analysis Quality:")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.6))
                        
                        ProgressView(value: enginesReport.analysisQuality)
                            .progressViewStyle(LinearProgressViewStyle())
                            .frame(width: 60)
                            .tint(.cyan)
                        
                        Text("\(Int(enginesReport.analysisQuality * 100))%")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.cyan)
                    }
                    
                    // Nuclear Reset Counter
                    if enginesReport.nuclearResets > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "burst")
                                .foregroundColor(.purple)
                                .font(.caption2)
                            Text("Nuclear Resets: \(enginesReport.nuclearResets)")
                                .font(.caption2)
                                .foregroundColor(.purple)
                        }
                    }
                }
            }
            
            // Connected Trading Engines
            if !botManager.connectedTradingEngines.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Connected Trading Engines:")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                    
                    ForEach(botManager.connectedTradingEngines, id: \.self) { engine in
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption2)
                            
                            Text(engine)
                                .font(.caption2)
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            
            if !botManager.deployedBots.isEmpty {
                Text("\(botManager.deployedBots.count) bots actively learning and trading")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(botManager.systemStatus.color.opacity(0.5), lineWidth: 2)
                )
        )
    }
    
    // MARK: - Overall Statistics
    
    private var overallStatsSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            VStack(spacing: 8) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.title2)
                    .foregroundColor(botManager.totalProfitLoss >= 0 ? .green : .red)
                
                Text(botManager.totalProfitLoss >= 0 ? 
                    "+$\(String(format: "%.2f", botManager.totalProfitLoss))" : 
                    "-$\(String(format: "%.2f", abs(botManager.totalProfitLoss)))")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Total P&L")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke((botManager.totalProfitLoss >= 0 ? Color.green : Color.red).opacity(0.3), lineWidth: 1)
                    )
            )
            
            VStack(spacing: 8) {
                Image(systemName: "arrow.left.arrow.right.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text("\(botManager.totalTrades)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Total Trades")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
            )
            
            VStack(spacing: 8) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title2)
                    .foregroundColor(.purple)
                
                Text("\(String(format: "%.1f", botManager.overallWinRate))%")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Win Rate")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .opacity(animateStats ? 1.0 : 0.0)
        .animation(.easeInOut(duration: 1.0).delay(0.3), value: animateStats)
    }
    
    // MARK: - Deployed Bots Section
    
    private var deployedBotsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Active Bots")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                if !botManager.deployedBots.isEmpty {
                    Menu {
                        Button("Pause All", action: botManager.pauseAllBots)
                        Button("Resume All", action: botManager.resumeAllBots)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
            }
            
            if botManager.deployedBots.isEmpty {
                emptyStateView
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(botManager.deployedBots) { bot in
                        BotCard(bot: bot) {
                            selectedBotForDetails = bot
                        }
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "robot")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.5))
            
            Text("No Bots Deployed")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Deploy your first bot to start automated trading")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            
            Button("Deploy Bot") {
                showingBotSelector = true
            }
            .buttonStyle(.cosmic)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .opacity(0.3)
        )
    }
    
    // MARK: - Quick Actions
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                QuickActionCard(
                    title: "Deploy Bot",
                    icon: "plus.circle.fill",
                    color: .green
                ) {
                    showingBotSelector = true
                }
                
                QuickActionCard(
                    title: "Activate GODMODE",
                    icon: "bolt.circle.fill",
                    color: .purple
                ) {
                    botManager.activateGodmode()
                }
                
                QuickActionCard(
                    title: "Nuclear Reset",
                    icon: "burst.fill",
                    color: .red
                ) {
                    botManager.triggerNuclearReset()
                }
                
                QuickActionCard(
                    title: "Settings",
                    icon: "gearshape.fill",
                    color: .gray
                ) {
                    // TODO: Navigate to settings
                }
            }
        }
    }
    
    // MARK: - Supabase Status
    
    private var supabaseStatusSection: some View {
        HStack {
            Image(systemName: "icloud")
                .foregroundColor(supabase.isConnected ? .green : .red)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Database Connection")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Text(supabase.connectionStatus)
                    .font(.caption2)
                    .foregroundColor(supabase.isConnected ? .green : .red)
            }
            
            Spacer()
            
            if supabase.isConnected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                ProgressView()
                    .scaleEffect(0.6)
                    .tint(.orange)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .opacity(0.3)
        )
    }
}

// MARK: - Supporting Views

struct BotCard: View {
    let bot: DeployedBot
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(bot.name)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(bot.strategy)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 6) {
                            Text(bot.status.emoji)
                            Text(bot.status.rawValue.capitalized)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(bot.status.color)
                        }
                        
                        Text("Uptime: \(bot.uptime)")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                
                // Metrics
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("P&L")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.6))
                        Text(bot.formattedProfits)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(bot.totalProfits >= 0 ? .green : .red)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Trades")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.6))
                        Text("\(bot.tradesExecuted)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Win Rate")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.6))
                        Text("\(String(format: "%.1f", bot.winRate))%")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                    }
                    
                    Spacer()
                    
                    // Learning Progress
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Learning")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.6))
                        
                        HStack(spacing: 4) {
                            Text("\(Int(bot.learningProgress))%")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.cyan)
                            
                            ProgressView(value: bot.learningProgress, total: 100)
                                .progressViewStyle(LinearProgressViewStyle())
                                .frame(width: 40)
                                .tint(.cyan)
                        }
                    }
                }
                
                // Activity Indicator
                if bot.status == .trading || bot.status == .learning {
                    HStack {
                        Circle()
                            .fill(bot.status.color)
                            .frame(width: 6, height: 6)
                            .scaleEffect(1.0)
                            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: true)
                        
                        Text("Last activity: \(timeAgo(from: bot.lastActivity))")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.6))
                        
                        Spacer()
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(bot.status.color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
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

struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Bot Selector Sheet

struct BotSelectorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var botManager = PersistentBotManager.shared
    @StateObject private var botStore = BotStoreService.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(Array(botStore.allBots.prefix(10))) { marketplaceBot in
                        BotSelectionCard(bot: marketplaceBot) {
                            // Convert MarketplaceBotModel to ProTraderBot for deployment
                            let proTraderBot = convertToProTraderBot(from: marketplaceBot)
                            botManager.deployBot(proTraderBot)
                            dismiss()
                        }
                    }
                }
                .padding()
            }
            .background(DesignSystem.AnimatedStarField().ignoresSafeArea())
            .navigationTitle("Select Bot to Deploy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    // Helper function to convert MarketplaceBotModel to ProTraderBot
    private func convertToProTraderBot(from marketplaceBot: MarketplaceBotModel) -> ProTraderBot {
        // Convert marketplace bot to ProTrader bot format
        let strategy: ProTraderBot.TradingStrategy
        switch marketplaceBot.tradingStyle {
        case .scalping: strategy = .scalping
        case .dayTrading: strategy = .dayTrading
        case .swingTrading: strategy = .swingTrading
        case .arbitrage: strategy = .arbitrage
        case .newsTrading: strategy = .newsTrading
        case .algorithmic: strategy = .meanReversion
        }
        
        let specialization: ProTraderBot.BotSpecialization
        switch marketplaceBot.rarity {
        case .common, .uncommon: specialization = .technicalAnalyst
        case .rare: specialization = .goldExpert
        case .epic: specialization = .forexMaster
        case .legendary: specialization = .cryptoTrader
        case .mythic, .godTier: specialization = .algorithmicTrader
        }
        
        return ProTraderBot(
            botNumber: Int.random(in: 1000...9999),
            name: marketplaceBot.name,
            xp: Double.random(in: 100...500),
            confidence: marketplaceBot.stats.winRate / 100.0,
            strategy: strategy,
            wins: Int(Double(marketplaceBot.stats.totalTrades) * (marketplaceBot.stats.winRate / 100.0)),
            losses: Int(Double(marketplaceBot.stats.totalTrades) * (1.0 - marketplaceBot.stats.winRate / 100.0)),
            totalTrades: marketplaceBot.stats.totalTrades,
            profitLoss: marketplaceBot.stats.totalReturn * 100,
            learningHistory: [],
            lastTraining: nil,
            isActive: true,
            specialization: specialization,
            aiEngine: .neuralNetwork,
            vpsStatus: .connected,
            screenshotUrls: []
        )
    }
}

struct BotSelectionCard: View {
    let bot: MarketplaceBotModel
    let onDeploy: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Bot Avatar
            Circle()
                .fill(bot.rarity.color.opacity(0.3))
                .frame(width: 60, height: 60)
                .overlay(
                    Text("🤖")
                        .font(.title)
                )
            
            VStack(spacing: 4) {
                Text(bot.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(bot.tradingStyle.rawValue)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                HStack(spacing: 4) {
                    Text(bot.rarity.sparkleEffect)
                    Text(bot.rarity.rawValue)
                        .font(.caption2)
                        .foregroundColor(bot.rarity.color)
                }
            }
            
            VStack(spacing: 6) {
                HStack {
                    Text("Win Rate:")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                    Spacer()
                    Text("\(String(format: "%.1f", bot.stats.winRate))%")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                
                HStack {
                    Text("Price:")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                    Spacer()
                    Text(bot.formattedPrice)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(bot.price == 0 ? .green : .orange)
                }
            }
            
            Button("Deploy") {
                onDeploy()
            }
            .buttonStyle(.cosmic)
            .controlSize(.small)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(bot.rarity.color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Bot Details Sheet

struct BotDetailsSheet: View {
    let bot: DeployedBot
    @Environment(\.dismiss) private var dismiss
    @StateObject private var botManager = PersistentBotManager.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Bot Header
                    VStack(spacing: 16) {
                        Circle()
                            .fill(bot.status.color.opacity(0.3))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text(bot.status.emoji)
                                    .font(.largeTitle)
                            )
                        
                        Text(bot.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Deployed \(timeAgo(from: bot.deployedAt))")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    // Detailed Metrics
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        DetailMetricCard(title: "Total P&L", value: bot.formattedProfits, color: bot.totalProfits >= 0 ? .green : .red)
                        DetailMetricCard(title: "Win Rate", value: "\(String(format: "%.1f", bot.winRate))%", color: .purple)
                        DetailMetricCard(title: "Trades", value: "\(bot.tradesExecuted)", color: .blue)
                        DetailMetricCard(title: "Risk Level", value: bot.riskLevel.rawValue, color: bot.riskLevel.color)
                    }
                    
                    // Learning Progress
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Learning Progress")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        ProgressView(value: bot.learningProgress, total: 100)
                            .progressViewStyle(LinearProgressViewStyle())
                            .tint(.cyan)
                        
                        HStack {
                            Text("\(Int(bot.learningProgress))% Complete")
                                .font(.caption)
                                .foregroundColor(.cyan)
                            Spacer()
                            Text("Neural Network Training")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                    )
                    
                    // Actions
                    VStack(spacing: 12) {
                        if bot.status == .paused {
                            Button("Resume Bot") {
                                botManager.resumeBot(id: bot.id)
                            }
                            .buttonStyle(.cosmic)
                        } else {
                            Button("Pause Bot") {
                                botManager.pauseBot(id: bot.id)
                            }
                            .buttonStyle(.solar)
                        }
                        
                        Button("Remove Bot") {
                            botManager.removeBot(id: bot.id)
                            dismiss()
                        }
                        .foregroundColor(.red)
                    }
                }
                .padding()
            }
            .background(DesignSystem.AnimatedStarField().ignoresSafeArea())
            .navigationTitle("Bot Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct DetailMetricCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - Engine Status Item Component
struct EngineStatusItem: View {
    let name: String
    let isActive: Bool
    let icon: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(isActive ? .green : .gray)
                .font(.caption2)
            
            Text(name)
                .font(.caption2)
                .foregroundColor(isActive ? .green : .gray)
                .lineLimit(1)
        }
    }
}

#Preview {
    DeployBotsView()
}
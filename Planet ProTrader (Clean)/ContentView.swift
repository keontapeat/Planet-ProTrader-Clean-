//
//  ContentView.swift
//  Planet ProTrader - Clean Foundation
//
//  Professional Main Interface - Zero Errors
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var tradingManager: TradingManager
    @EnvironmentObject var botManager: BotManager
    @EnvironmentObject var accountManager: AccountManager
    @EnvironmentObject var hapticManager: HapticManager
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard Tab
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Label("Dashboard", systemImage: "house.fill")
            }
            .tag(0)
            
            // Trading Tab
            NavigationStack {
                TradingTerminal()
            }
            .tabItem {
                Label("Terminal", systemImage: "chart.line.uptrend.xyaxis")
            }
            .tag(1)
            
            // Bots Tab
            NavigationStack {
                BotsView()
            }
            .tabItem {
                Label("AI Bots", systemImage: "brain.head.profile")
            }
            .tag(2)
            
            // Portfolio Tab
            NavigationStack {
                PortfolioView()
            }
            .tabItem {
                Label("Portfolio", systemImage: "briefcase.fill")
            }
            .tag(3)
            
            // Settings Tab
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(4)
        }
        .tint(DesignSystem.primaryGold)
        .preferredColorScheme(.light)
        .onChange(of: selectedTab) { oldValue, newValue in
            hapticManager.selection()
        }
    }
}

// MARK: - Dashboard View
struct DashboardView: View {
    @EnvironmentObject var tradingManager: TradingManager
    @EnvironmentObject var botManager: BotManager
    @EnvironmentObject var accountManager: AccountManager
    @EnvironmentObject var hapticManager: HapticManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Welcome Header
                welcomeHeader
                
                // Account Summary
                accountSummaryCard
                
                // Live Gold Price
                goldPriceCard
                
                // Quick Stats
                quickStatsGrid
                
                // Active Bots
                activeBotsSection
                
                // Quick Actions
                quickActionsGrid
            }
            .padding()
        }
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.large)
        .refreshable {
            await refreshData()
        }
    }
    
    private var welcomeHeader: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome back!")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Planet ProTrader")
                        .font(.title2)
                        .fontWeight(.bold)
                        .goldText()
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(DesignSystem.goldGradient)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "crown.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                .pulseEffect()
            }
            
            HStack {
                Image(systemName: accountManager.connectionStatus.icon)
                    .foregroundColor(accountManager.connectionStatus.color)
                
                Text(accountManager.connectionStatus.rawValue)
                    .font(.caption)
                    .foregroundColor(accountManager.connectionStatus.color)
                
                Spacer()
                
                Text("Last updated: \(accountManager.lastUpdate, format: .dateTime.hour().minute())")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .premiumCard()
    }
    
    private var accountSummaryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("💼 Account Summary")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                if let account = accountManager.currentAccount {
                    Text(account.isLive ? "LIVE" : "DEMO")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(account.isLive ? .red : .blue, in: Capsule())
                }
            }
            
            if let account = accountManager.currentAccount {
                VStack(spacing: 12) {
                    HStack {
                        Text("Balance:")
                        Spacer()
                        Text(account.formattedBalance)
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    
                    HStack {
                        Text("Equity:")
                        Spacer()
                        Text(account.formattedProfitLoss)
                            .font(.headline)
                            .fontWeight(.bold)
                            .profitText(account.profitLoss >= 0)
                    }
                    
                    HStack {
                        Text("Today's P&L:")
                        Spacer()
                        Text("$\(String(format: "%.2f", tradingManager.todaysPnL))")
                            .font(.headline)
                            .fontWeight(.bold)
                            .profitText(tradingManager.todaysPnL >= 0)
                    }
                }
            }
        }
        .standardCard()
    }
    
    private var goldPriceCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("📈 XAU/USD")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(.green)
                        .frame(width: 8, height: 8)
                    
                    Text("LIVE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
            
            HStack(alignment: .bottom) {
                Text(tradingManager.goldPrice.formattedPrice)
                    .font(DesignSystem.Typography.priceFont)
                    .foregroundColor(.primary)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack {
                        Image(systemName: tradingManager.goldPrice.isPositive ? "arrow.up.right" : "arrow.down.right")
                            .font(.caption)
                            .profitText(tradingManager.goldPrice.isPositive)
                        
                        Text(tradingManager.goldPrice.formattedChange)
                            .font(.headline)
                            .fontWeight(.bold)
                            .profitText(tradingManager.goldPrice.isPositive)
                    }
                    
                    Text(tradingManager.goldPrice.formattedChangePercent)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .standardCard()
    }
    
    private var quickStatsGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            StatCard(
                title: "Weekly P&L",
                value: "$\(String(format: "%.2f", tradingManager.weeklyPnL))",
                icon: "calendar",
                color: tradingManager.weeklyPnL >= 0 ? .green : .red
            )
            
            StatCard(
                title: "Monthly P&L",
                value: "$\(String(format: "%.2f", tradingManager.monthlyPnL))",
                icon: "chart.bar.fill",
                color: tradingManager.monthlyPnL >= 0 ? .green : .red
            )
            
            StatCard(
                title: "Active Bots",
                value: "\(botManager.activeBots.count)",
                icon: "brain.head.profile",
                color: .blue
            )
            
            StatCard(
                title: "Total Trades",
                value: "\(botManager.activeBots.reduce(0) { $0 + $1.totalTrades })",
                icon: "arrow.triangle.swap",
                color: .purple
            )
        }
    }
    
    private var activeBotsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🤖 Active Bots")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                if botManager.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            
            if botManager.activeBots.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    
                    Text("No active bots")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Deploy a bot to start automated trading")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(botManager.activeBots.prefix(3), id: \.id) { bot in
                        BotSummaryRow(bot: bot)
                    }
                }
            }
        }
        .standardCard()
    }
    
    private var quickActionsGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            Text("Deploy Bot")
                .font(.caption)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            
            Text("New Trade")
                .font(.caption)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            
            Text("View Signals")
                .font(.caption)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            
            Text("Analytics")
                .font(.caption)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private func refreshData() async {
        await tradingManager.refreshData()
        await botManager.refreshBots()
        await accountManager.refreshAccount()
    }
}

// MARK: - Other Views (Placeholders)
struct BotsView: View {
    @EnvironmentObject var botManager: BotManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("🤖 AI Trading Bots")
                    .font(.title)
                    .fontWeight(.bold)
                    .goldText()
                
                LazyVStack(spacing: 16) {
                    ForEach(botManager.allBots, id: \.id) { bot in
                        BotCard(bot: bot)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("AI Bots")
        .refreshable {
            await botManager.refreshBots()
        }
    }
}

struct PortfolioView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("💼 Portfolio Analytics")
                .font(.title)
                .fontWeight(.bold)
                .goldText()
            
            Text("Portfolio management coming soon")
                .foregroundColor(.secondary)
        }
        .navigationTitle("Portfolio")
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("⚙️ Settings")
                        .font(.title)
                        .fontWeight(.bold)
                        .goldText()
                    
                    // LIVE TRADING - Top Priority
                    NavigationLink(destination: RealAccountView()) {
                        HStack {
                            Image(systemName: "building.columns.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("🏦 Live Trading Account")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Text("Connect Coinexx Demo & Deploy Bots")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text("CONNECT")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.green, in: Capsule())
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Text("App settings coming soon")
                        .foregroundColor(.secondary)
                }
                .padding()
            }
        }
        .navigationTitle("Settings")
    }
}

// MARK: - Helper Components
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct BotSummaryRow: View {
    let bot: TradingBot
    
    var body: some View {
        HStack {
            Image(systemName: bot.icon)
                .font(.title3)
                .foregroundColor(DesignSystem.primaryGold)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(bot.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("Win Rate: \(bot.displayWinRate)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(bot.displayProfitability)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .profitText(bot.profitability >= 0)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(bot.status.color)
                        .frame(width: 6, height: 6)
                    
                    Text(bot.status.rawValue)
                        .font(.caption2)
                        .foregroundColor(bot.status.color)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

struct BotCard: View {
    let bot: TradingBot
    @EnvironmentObject var botManager: BotManager
    @EnvironmentObject var hapticManager: HapticManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: bot.icon)
                    .font(.title2)
                    .foregroundColor(DesignSystem.primaryGold)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(bot.name)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(bot.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(bot.status.color)
                        .frame(width: 8, height: 8)
                    
                    Text(bot.status.rawValue)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(bot.status.color)
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Win Rate")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(bot.displayWinRate)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Profitability")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(bot.displayProfitability)
                        .font(.headline)
                        .fontWeight(.bold)
                        .profitText(bot.profitability >= 0)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Risk Level")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(bot.riskLevel.rawValue)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(bot.riskLevel.color)
                }
            }
            
            HStack {
                if bot.isActive {
                    Button("Stop Bot") {
                        botManager.stopBot(bot)
                        hapticManager.warning()
                    }
                    .buttonStyle(.primary)
                    .frame(maxWidth: .infinity)
                } else {
                    Button("Deploy Bot") {
                        Task {
                            await botManager.deployBot(bot)
                        }
                        hapticManager.botDeployed()
                    }
                    .buttonStyle(.primary)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .standardCard()
    }
}

#Preview {
    ContentView()
        .environmentObject(TradingManager.shared)
        .environmentObject(BotManager.shared)
        .environmentObject(AccountManager.shared)
        .environmentObject(HapticManager.shared)
}
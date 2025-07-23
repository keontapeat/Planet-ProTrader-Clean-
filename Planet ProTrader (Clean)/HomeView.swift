//
//  HomeView.swift
//  Planet ProTrader - Enhanced Home Experience
//
//  Your original HomeView with all features restored
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var tradingManager = TradingManager.shared
    @StateObject private var aiEngine = AIEngine.shared
    @StateObject private var botManager = BotManager.shared
    @State private var refreshTimer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome Header
                    welcomeHeader
                    
                    // Netflix-Style Bot Reel
                    botReelSection
                    
                    // Quick Stats Cards
                    quickStatsGrid
                    
                    // Real-Time Gold Price
                    goldPriceCard
                    
                    // AI Trading Status
                    aiTradingStatusCard
                    
                    // Recent Performance
                    recentPerformanceCard
                    
                    // Quick Actions
                    quickActionsGrid
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .navigationTitle("Planet ProTrader")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await refreshData()
            }
            .onReceive(refreshTimer) { _ in
                Task {
                    await refreshData()
                }
            }
        }
    }
    
    private var welcomeHeader: some View {
        UltraPremiumCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Welcome back!")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Elite Trader")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
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
                }
                
                HStack {
                    Text("AI Status:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 6) {
                        Circle()
                            .fill(aiEngine.isActive ? .green : .red)
                            .frame(width: 8, height: 8)
                        
                        Text(aiEngine.isActive ? "ACTIVE" : "INACTIVE")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(aiEngine.isActive ? .green : .red)
                    }
                }
            }
        }
    }
    
    private var botReelSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("🤖 Your Bot Army")
                    .font(.title2)
                    .fontWeight(.bold)
                    .goldText()
                
                Spacer()
                
                Text("\(botManager.allBots.count) Total Bots")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Netflix-style horizontal scrolling reel
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(botManager.allBots, id: \.id) { bot in
                        NetflixBotCard(bot: bot) {
                            // Deploy or view bot details
                            Task {
                                if bot.isActive {
                                    botManager.stopBot(bot)
                                } else {
                                    await botManager.deployBot(bot)
                                }
                            }
                        }
                    }
                    
                    // Add new bot card
                    AddNewBotCard {
                        // Navigate to bot store or creation
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var quickStatsGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            QuickStatCard(
                title: "Today's P&L",
                value: "$+\(tradingManager.todaysPnL.formatted(.number.precision(.fractionLength(2))))",
                change: "\(tradingManager.todaysChangePercent > 0 ? "+" : "")\(tradingManager.todaysChangePercent.formatted(.number.precision(.fractionLength(1))))%",
                color: tradingManager.todaysPnL >= 0 ? .green : .red,
                icon: "chart.line.uptrend.xyaxis"
            )
            
            QuickStatCard(
                title: "Win Rate",
                value: "\(tradingManager.winRate.formatted(.number.precision(.fractionLength(1))))%",
                change: "Last 7 days",
                color: tradingManager.winRate >= 70 ? .green : tradingManager.winRate >= 50 ? .orange : .red,
                icon: "target"
            )
            
            QuickStatCard(
                title: "Active Trades",
                value: "\(tradingManager.activeTrades.count)",
                change: "\(tradingManager.pendingOrders.count) pending",
                color: .blue,
                icon: "chart.bar.doc.horizontal"
            )
            
            QuickStatCard(
                title: "AI Signals",
                value: "\(aiEngine.todaysSignals)",
                change: "\(aiEngine.accuracy.formatted(.number.precision(.fractionLength(1))))% accuracy",
                color: .purple,
                icon: "brain.head.profile"
            )
        }
    }
    
    private var goldPriceCard: some View {
        UltraPremiumCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("XAU/USD")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
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
                    Text("$\(tradingManager.currentGoldPrice.formatted(.number.precision(.fractionLength(2))))")
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack {
                            Image(systemName: tradingManager.goldPriceChange >= 0 ? "arrow.up.right" : "arrow.down.right")
                                .font(.caption)
                                .foregroundColor(tradingManager.goldPriceChange >= 0 ? .green : .red)
                            
                            Text("\(tradingManager.goldPriceChange >= 0 ? "+" : "")\(tradingManager.goldPriceChange.formatted(.number.precision(.fractionLength(2))))")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(tradingManager.goldPriceChange >= 0 ? .green : .red)
                        }
                        
                        Text("\(tradingManager.goldPriceChangePercent >= 0 ? "+" : "")\(tradingManager.goldPriceChangePercent.formatted(.number.precision(.fractionLength(2))))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Mini chart placeholder
                Rectangle()
                    .fill(DesignSystem.primaryGold.opacity(0.1))
                    .frame(height: 60)
                    .cornerRadius(8)
                    .overlay(
                        Text("📈 Real-time chart coming soon")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    )
            }
        }
    }
    
    private var aiTradingStatusCard: some View {
        UltraPremiumCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "brain.head.profile.fill")
                        .font(.title2)
                        .foregroundColor(DesignSystem.primaryGold)
                    
                    Text("AI Trading Engine")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Toggle("", isOn: .constant(aiEngine.isActive))
                        .labelsHidden()
                        .scaleEffect(0.8)
                }
                
                VStack(spacing: 8) {
                    HStack {
                        Text("Status:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(aiEngine.currentStatus)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(aiEngine.isActive ? .green : .orange)
                    }
                    
                    HStack {
                        Text("Market Sentiment:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        HStack {
                            Circle()
                                .fill(aiEngine.marketSentiment == "Bullish" ? .green : 
                                     aiEngine.marketSentiment == "Bearish" ? .red : .orange)
                                .frame(width: 8, height: 8)
                            
                            Text(aiEngine.marketSentiment)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }
                    }
                    
                    HStack {
                        Text("Confidence:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(aiEngine.confidence.formatted(.number.precision(.fractionLength(0))))%")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
    
    private var recentPerformanceCard: some View {
        UltraPremiumCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Recent Performance")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                VStack(spacing: 12) {
                    PerformanceRow(
                        period: "Today",
                        value: "$\(tradingManager.todaysPnL.formatted(.number.precision(.fractionLength(2))))",
                        percentage: "\(tradingManager.todaysChangePercent.formatted(.number.precision(.fractionLength(1))))%",
                        isPositive: tradingManager.todaysPnL >= 0
                    )
                    
                    PerformanceRow(
                        period: "This Week",
                        value: "$\(tradingManager.weeklyPnL.formatted(.number.precision(.fractionLength(2))))",
                        percentage: "\(tradingManager.weeklyChangePercent.formatted(.number.precision(.fractionLength(1))))%",
                        isPositive: tradingManager.weeklyPnL >= 0
                    )
                    
                    PerformanceRow(
                        period: "This Month",
                        value: "$\(tradingManager.monthlyPnL.formatted(.number.precision(.fractionLength(2))))",
                        percentage: "\(tradingManager.monthlyChangePercent.formatted(.number.precision(.fractionLength(1))))%",
                        isPositive: tradingManager.monthlyPnL >= 0
                    )
                }
            }
        }
    }
    
    private var quickActionsGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            QuickActionButton(
                title: "New Trade",
                icon: "plus.circle.fill",
                color: .green
            ) {
                // Navigate to new trade
            }
            
            QuickActionButton(
                title: "Portfolio",
                icon: "chart.pie.fill",
                color: .blue
            ) {
                // Navigate to portfolio
            }
            
            QuickActionButton(
                title: "Signals",
                icon: "bell.fill",
                color: .orange
            ) {
                // Navigate to signals
            }
            
            QuickActionButton(
                title: "Settings",
                icon: "gear.circle.fill",
                color: .gray
            ) {
                // Navigate to settings
            }
        }
    }
    
    private func refreshData() async {
        await tradingManager.refreshData()
        await aiEngine.updateStatus()
    }
}

struct QuickStatCard: View {
    let title: String
    let value: String
    let change: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(change)
                    .font(.caption2)
                    .foregroundColor(color)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct QuickActionButton: View {
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
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Netflix-Style Bot Card
struct NetflixBotCard: View {
    let bot: TradingBot
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Bot Avatar with Status
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(DesignSystem.goldGradient)
                        .frame(width: 140, height: 180)
                    
                    VStack(spacing: 8) {
                        Image(systemName: bot.icon)
                            .font(.system(size: 36))
                            .foregroundColor(.white)
                        
                        Text(bot.name)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                        
                        // Performance badge
                        VStack(spacing: 2) {
                            Text(bot.displayWinRate)
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Win Rate")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.black.opacity(0.3), in: RoundedRectangle(cornerRadius: 8))
                    }
                    
                    // Status indicator
                    VStack {
                        HStack {
                            Spacer()
                            Circle()
                                .fill(bot.status.color)
                                .frame(width: 12, height: 12)
                                .pulseEffect(bot.status == .active)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Add New Bot Card
struct AddNewBotCard: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(DesignSystem.primaryGold.opacity(0.2))
                        .frame(width: 140, height: 180)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 36))
                        .foregroundColor(.white)
                    Text("Add New Bot")
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
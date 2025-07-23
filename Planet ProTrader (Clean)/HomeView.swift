//
//  HomeView.swift
//  Planet ProTrader - Solar System Edition
//
//  Home View with Solar System Dashboard
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

// MARK: - Home View (Solar system with bot integration)
struct HomeView: View {
    @EnvironmentObject var realTimeBalanceManager: RealTimeBalanceManager
    @EnvironmentObject var tradingManager: TradingManager
    @EnvironmentObject var botManager: BotManager
    @EnvironmentObject var accountManager: AccountManager
    @EnvironmentObject var vpsConnection: VPSConnectionManager
    @State private var isAnimating = true
    @State private var showingVPSSetup = false
    
    var body: some View {
        ZStack {
            // Space Background (Dark Theme)
            DesignSystem.spaceGradient
                .ignoresSafeArea()
            
            ScrollView {
                LazyVStack(spacing: 32) {
                    // Real-Time Balance Header (Enhanced with VPS status)
                    enhancedBalanceHeader
                    
                    // Solar System Dashboard
                    solarSystemView
                    
                    // Live Trading Stats
                    liveTradingStats
                    
                    // Active Bots with Real Performance
                    activeBotsList
                    
                    // Recent Activity
                    recentActivityView
                }
                .padding()
            }
        }
        .starField()
        .navigationTitle("")
        .navigationBarHidden(true)
        .preferredColorScheme(.dark)
        .onAppear {
            isAnimating = true
        }
        .sheet(isPresented: $showingVPSSetup) {
            VPSSetupOptionsView()
        }
    }
    
    // MARK: - Enhanced Balance Header with VPS Status
    private var enhancedBalanceHeader: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Mission Control")
                        .font(DesignSystem.Typography.asteroid)
                        .foregroundColor(DesignSystem.starWhite.opacity(0.7))
                    
                    Text("Planet ProTrader")
                        .font(DesignSystem.Typography.cosmic)
                        .cosmicText()
                        .sparkleEffect()
                }
                
                Spacer()
                
                // Live Status Indicator
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(vpsConnection.isConnected && vpsConnection.mt5Status.isConnected ? .green : .red)
                            .frame(width: 12, height: 12)
                            .pulsingEffect()
                        
                        Text(vpsConnection.isConnected && vpsConnection.mt5Status.isConnected ? "🟢 LIVE" : "🔴 OFFLINE")
                            .font(DesignSystem.Typography.dust)
                            .fontWeight(.bold)
                            .foregroundColor(vpsConnection.isConnected && vpsConnection.mt5Status.isConnected ? .green : .red)
                    }
                    
                    Text("Coinexx Demo #845638")
                        .font(DesignSystem.Typography.dust)
                        .foregroundColor(DesignSystem.starWhite.opacity(0.6))
                }
            }
            
            // Enhanced Balance Display
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Live Balance")
                        .font(DesignSystem.Typography.dust)
                        .foregroundColor(DesignSystem.starWhite.opacity(0.6))
                    
                    if vpsConnection.mt5Status.isConnected {
                        Text("$\(vpsConnection.mt5Status.balance.formatted(.number.precision(.fractionLength(2))))")
                            .font(DesignSystem.Typography.metricFont)
                            .fontWeight(.bold)
                            .cosmicText()
                            .sparkleEffect()
                    } else {
                        Text(realTimeBalanceManager.formattedBalance)
                            .font(DesignSystem.Typography.metricFont)
                            .fontWeight(.bold)
                            .cosmicText()
                            .sparkleEffect()
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Today's Change")
                        .font(DesignSystem.Typography.dust)
                        .foregroundColor(DesignSystem.starWhite.opacity(0.6))
                    
                    Text(realTimeBalanceManager.formattedTodaysChange)
                        .font(DesignSystem.Typography.asteroid)
                        .profitLossText(realTimeBalanceManager.todaysChange >= 0)
                }
            }
            
            // Last update time
            if realTimeBalanceManager.todaysChange != 0 {
                HStack {
                    Spacer()
                    Text("Last update: \(realTimeBalanceManager.lastUpdate, format: .dateTime.hour().minute().second())")
                        .font(DesignSystem.Typography.dust)
                        .foregroundColor(DesignSystem.starWhite.opacity(0.6))
                }
            }
        }
        .planetCard()
    }
    
    private var solarSystemView: some View {
        VStack(spacing: 24) {
            Text("Trading Solar System")
                .font(DesignSystem.Typography.stellar)
                .solarText()
            
            ZStack {
                // Orbital Rings
                ForEach(0..<4) { orbit in
                    Circle()
                        .stroke(
                            DesignSystem.cosmicBlue.opacity(0.2),
                            style: StrokeStyle(lineWidth: 1, dash: [5, 5])
                        )
                        .frame(width: CGFloat(120 + orbit * 60))
                        .rotationEffect(.degrees(isAnimating ? Double(orbit * 90) : 0))
                        .animation(
                            DesignSystem.Animation.orbit.speed(Double(orbit + 1) * 0.5),
                            value: isAnimating
                        )
                }
                
                // Central Sun (Account Balance)
                VStack(spacing: 4) {
                    if let account = accountManager.currentAccount {
                        Text(account.formattedBalance)
                            .font(DesignSystem.Typography.metricFont)
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }
                    
                    Text("BALANCE")
                        .font(DesignSystem.Typography.dust)
                        .foregroundColor(DesignSystem.starWhite.opacity(0.7))
                }
                .frame(width: 100, height: 100)
                .background(DesignSystem.solarGradient, in: Circle())
                .pulsingEffect(isAnimating)
                .shadow(color: DesignSystem.solarOrange.opacity(0.5), radius: 16)
                
                // Trading Planets
                ForEach(Array(accountManager.tradingPlanets.enumerated()), id: \.element.id) { index, planet in
                    let angle = Double(index) * 360.0 / Double(accountManager.tradingPlanets.count)
                    let radius: CGFloat = 140 + CGFloat(index % 3) * 30
                    
                    PlanetView(planet: planet, isSelected: false)
                        .offset(
                            x: cos(angle * .pi / 180 + (isAnimating ? .pi * 2 : 0)) * radius,
                            y: sin(angle * .pi / 180 + (isAnimating ? .pi * 2 : 0)) * radius
                        )
                        .animation(
                            DesignSystem.Animation.orbit.delay(Double(index) * 0.1),
                            value: isAnimating
                        )
                }
            }
            .frame(height: 400)
        }
        .planetCard()
    }
    
    private var liveTradingStats: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Live Trading Stats")
                        .font(DesignSystem.Typography.asteroid)
                        .foregroundColor(DesignSystem.starWhite.opacity(0.7))
                    
                    Text("Monitor your trading performance")
                        .font(DesignSystem.Typography.cosmic)
                        .cosmicText()
                }
                
                Spacer()
            }
            
            // Trading Stats
            HStack {
                VStack(spacing: 4) {
                    Text("Total P&L")
                        .font(DesignSystem.Typography.dust)
                        .foregroundColor(DesignSystem.starWhite.opacity(0.6))
                    
                    Text("23.45%")
                        .font(DesignSystem.Typography.metricFont)
                        .profitLossText(true)
                    
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text("Total Trades")
                        .font(DesignSystem.Typography.dust)
                        .foregroundColor(DesignSystem.starWhite.opacity(0.6))
                    
                    Text("127")
                        .font(DesignSystem.Typography.metricFont)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text("Win Rate")
                        .font(DesignSystem.Typography.dust)
                        .foregroundColor(DesignSystem.starWhite.opacity(0.6))
                    
                    Text("73.12%")
                        .font(DesignSystem.Typography.metricFont)
                        .profitLossText(true)
                }
            }
        }
        .planetCard()
    }
    
    private var activeBotsList: some View {
        VStack(spacing: 14) {
            Text("Active Trading Bots")
                .font(DesignSystem.Typography.asteroid)
                .cosmicText()
            
            ForEach(botManager.activeBots, id: \.id) { bot in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(bot.name)
                            .font(DesignSystem.Typography.metricFont)
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                        Text(bot.description)
                            .font(DesignSystem.Typography.dust)
                            .foregroundColor(DesignSystem.starWhite.opacity(0.6))
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    Circle()
                        .fill(bot.status.color)
                        .frame(width: 10, height: 10)
                    
                    Text(bot.displayProfitability)
                        .font(DesignSystem.Typography.asteroid)
                        .profitLossText(bot.profitability >= 0)
                }
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.05))
                .cornerRadius(8)
            }
        }
        .planetCard()
    }
    
    private var recentActivityView: some View {
        VStack(spacing: 24) {
            Text("Recent Activity")
                .font(DesignSystem.Typography.asteroid)
                .cosmicText()
            
            // Display recent activity list
            LazyVStack(alignment: .leading, spacing: 12) {
                ForEach(accountManager.recentActivity, id: \.id) { activity in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(activity.dateTime, format: .dateTime.hour().minute())
                            .font(DesignSystem.Typography.dust)
                            .foregroundColor(DesignSystem.starWhite.opacity(0.6))
                        
                        Text(activity.description)
                            .font(DesignSystem.Typography.metricFont)
                            .foregroundColor(.white)
                            .lineLimit(2)
                    }
                }
            }
        }
        .planetCard()
    }
}

// MARK: - Supporting Views

struct PlanetView: View {
    let planet: TradingPlanet
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(planet.gradient)
                .frame(width: isSelected ? 50 : 40, height: isSelected ? 50 : 40)
                .overlay(
                    Circle()
                        .stroke(DesignSystem.starWhite.opacity(isSelected ? 0.8 : 0.4), lineWidth: isSelected ? 2 : 1)
                )
                .shadow(color: planet.shadowColor, radius: isSelected ? 16 : 8)
            
            Text(planet.icon)
                .font(.system(size: isSelected ? 20 : 16))
        }
        .scaleEffect(isSelected ? 1.2 : 1.0)
        .animation(DesignSystem.Animation.hyperspace, value: isSelected)
    }
}

struct TradingPlanet: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let description: String
    let gradient: LinearGradient
    let shadowColor: Color
    let performance: String
    let riskLevel: String
    let riskColor: Color
    
    static let allPlanets = [
        TradingPlanet(
            name: "Gold Trader",
            icon: "🪐",
            description: "Premium gold trading algorithms",
            gradient: DesignSystem.solarGradient,
            shadowColor: DesignSystem.solarOrange,
            performance: "+24.7%",
            riskLevel: "Medium",
            riskColor: DesignSystem.solarOrange
        ),
        TradingPlanet(
            name: "Forex Explorer",
            icon: "🌍",
            description: "Multi-currency trading system",
            gradient: DesignSystem.planetEarthGradient,
            shadowColor: DesignSystem.planetGreen,
            performance: "+18.3%",
            riskLevel: "Low",
            riskColor: DesignSystem.profitGreen
        ),
        TradingPlanet(
            name: "Crypto Voyager",
            icon: "🌙",
            description: "Advanced cryptocurrency analysis",
            gradient: LinearGradient(colors: [DesignSystem.cosmicBlue, DesignSystem.stellarPurple], startPoint: .topLeading, endPoint: .bottomTrailing),
            shadowColor: DesignSystem.cosmicBlue,
            performance: "+31.2%",
            riskLevel: "High",
            riskColor: DesignSystem.lossRed
        ),
        TradingPlanet(
            name: "Scalp Hunter",
            icon: "☄️",
            description: "Lightning-fast scalping strategies",
            gradient: DesignSystem.nebuladeGradient,
            shadowColor: DesignSystem.nebulaPink,
            performance: "+12.8%",
            riskLevel: "Very High",
            riskColor: DesignSystem.lossRed
        ),
        TradingPlanet(
            name: "Swing Master",
            icon: "🛸",
            description: "Long-term swing trading bot",
            gradient: LinearGradient(colors: [DesignSystem.stellarPurple, DesignSystem.cosmicBlue], startPoint: .topLeading, endPoint: .bottomTrailing),
            shadowColor: DesignSystem.stellarPurple,
            performance: "+29.6%",
            riskLevel: "Medium",
            riskColor: DesignSystem.solarOrange
        )
    ]
}

#Preview {
    HomeView()
        .environmentObject(TradingManager.shared)
        .environmentObject(BotManager.shared)
        .environmentObject(AccountManager.shared)
        .environmentObject(HapticManager.shared)
        .environmentObject(RealTimeBalanceManager())
        .environmentObject(VPSConnectionManager.shared)
}
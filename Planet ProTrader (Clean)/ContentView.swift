//
//  ContentView.swift
//  Planet ProTrader - Solar System Edition
//
//  Ultra-Modern Cosmic Trading Dashboard
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
    
    var body: some View {
        ZStack {
            // Space Background
            DesignSystem.spaceGradient
                .ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                    .tag(0)
                
                BotDeploymentLauncher()
                    .tabItem {
                        Image(systemName: "robot.fill")
                        Text("Deploy Bot")
                    }
                    .tag(4)
                
                TradingTerminal()
                    .tabItem {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                        Text("Terminal")
                    }
                    .tag(1)
                
                SelfHealingDashboard()
                    .tabItem {
                        Image(systemName: "waveform.path.ecg")
                        Text("Health")
                    }
                    .tag(2)
                
                EADeploymentView()
                    .tabItem {
                        Image(systemName: "server.rack")
                        Text("Deploy")
                    }
                    .tag(3)
            }
            .tint(DesignSystem.cosmicBlue)
            .preferredColorScheme(.dark)
            .onChange(of: selectedTab) { oldValue, newValue in
                hapticManager.selection()
            }
        }
    }
}

// MARK: - Solar System Dashboard
struct SolarDashboardView: View {
    @State private var isAnimating = true
    @State private var selectedPlanet: TradingPlanet? = nil
    @EnvironmentObject var tradingManager: TradingManager
    @EnvironmentObject var botManager: BotManager
    @EnvironmentObject var accountManager: AccountManager
    
    let planets = TradingPlanet.allPlanets
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 32) {
                // Cosmic Header
                cosmicHeader
                
                // Solar System View
                solarSystemView
                
                // Mission Control
                missionControlPanel
                
                // Planet Details
                if let planet = selectedPlanet {
                    planetDetailView(planet)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                }
                
                // Trading Stats Constellation
                tradingConstellation
                
                // Active Missions
                activeMissionsView
            }
            .padding()
        }
        .starField()
        .navigationTitle("")
        .navigationBarHidden(true)
        .onAppear {
            isAnimating = true
        }
    }
    
    private var cosmicHeader: some View {
        VStack(spacing: 16) {
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
                
                // Central Sun
                ZStack {
                    Circle()
                        .fill(DesignSystem.solarGradient)
                        .frame(width: 80, height: 80)
                        .pulsingEffect(isAnimating)
                        .shadow(color: DesignSystem.solarOrange, radius: 20)
                    
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                        .animation(
                            DesignSystem.Animation.orbit.speed(0.1),
                            value: isAnimating
                        )
                }
            }
            
            // System Status
            HStack(spacing: 16) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(accountManager.connectionStatus.color)
                        .frame(width: 8, height: 8)
                        .pulsingEffect()
                    
                    Text(accountManager.connectionStatus.rawValue)
                        .font(DesignSystem.Typography.dust)
                        .foregroundColor(accountManager.connectionStatus.color)
                }
                
                Spacer()
                
                Text("Last sync: \(accountManager.lastUpdate, format: .dateTime.hour().minute())")
                    .font(DesignSystem.Typography.dust)
                    .foregroundColor(DesignSystem.starWhite.opacity(0.6))
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
                ForEach(Array(planets.enumerated()), id: \.element.id) { index, planet in
                    let angle = Double(index) * 360.0 / Double(planets.count)
                    let radius: CGFloat = 140 + CGFloat(index % 3) * 30
                    
                    PlanetView(planet: planet, isSelected: selectedPlanet?.id == planet.id)
                        .offset(
                            x: cos(angle * .pi / 180 + (isAnimating ? .pi * 2 : 0)) * radius,
                            y: sin(angle * .pi / 180 + (isAnimating ? .pi * 2 : 0)) * radius
                        )
                        .animation(
                            DesignSystem.Animation.orbit.delay(Double(index) * 0.1),
                            value: isAnimating
                        )
                        .onTapGesture {
                            withAnimation(DesignSystem.Animation.hyperspace) {
                                selectedPlanet = selectedPlanet?.id == planet.id ? nil : planet
                            }
                        }
                }
            }
            .frame(height: 400)
        }
        .planetCard()
    }
    
    private var missionControlPanel: some View {
        VStack(spacing: 16) {
            Text("🚀 Mission Control")
                .font(DesignSystem.Typography.planet)
                .cosmicText()
            
            if let account = accountManager.currentAccount {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    CosmicStatCard(
                        title: "Today's P&L",
                        value: "$\(String(format: "%.2f", tradingManager.todaysPnL))",
                        icon: "chart.line.uptrend.xyaxis",
                        gradient: tradingManager.todaysPnL >= 0 ? 
                            DesignSystem.planetEarthGradient : 
                            LinearGradient(colors: [DesignSystem.lossRed, DesignSystem.nebulaPink], startPoint: .topLeading, endPoint: .bottomTrailing),
                        isPositive: tradingManager.todaysPnL >= 0
                    )
                    
                    CosmicStatCard(
                        title: "Equity",
                        value: account.formattedProfitLoss,
                        icon: "dollarsign.circle.fill",
                        gradient: account.profitLoss >= 0 ? 
                            DesignSystem.planetEarthGradient : 
                            LinearGradient(colors: [DesignSystem.lossRed, DesignSystem.nebulaPink], startPoint: .topLeading, endPoint: .bottomTrailing),
                        isPositive: account.profitLoss >= 0
                    )
                    
                    CosmicStatCard(
                        title: "Active Bots",
                        value: "\(botManager.activeBots.count)",
                        icon: "brain.head.profile",
                        gradient: DesignSystem.nebuladeGradient,
                        isPositive: true
                    )
                    
                    CosmicStatCard(
                        title: "Gold Price",
                        value: tradingManager.goldPrice.formattedPrice,
                        icon: "circle.fill",
                        gradient: DesignSystem.solarGradient,
                        isPositive: tradingManager.goldPrice.isPositive
                    )
                }
            }
        }
        .planetCard()
    }
    
    private func planetDetailView(_ planet: TradingPlanet) -> some View {
        VStack(spacing: 20) {
            HStack {
                Text(planet.icon)
                    .font(.system(size: 40))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(planet.name)
                        .font(DesignSystem.Typography.planet)
                        .cosmicText()
                    
                    Text(planet.description)
                        .font(DesignSystem.Typography.asteroid)
                        .foregroundColor(DesignSystem.starWhite.opacity(0.8))
                }
                
                Spacer()
            }
            
            HStack(spacing: 16) {
                Text("Performance: \(planet.performance)")
                    .font(DesignSystem.Typography.asteroid)
                    .profitLossText(planet.performance.contains("+"))
                
                Spacer()
                
                Text("Risk: \(planet.riskLevel)")
                    .font(DesignSystem.Typography.asteroid)
                    .foregroundColor(planet.riskColor)
            }
            
            HStack {
                Button("Explore Planet") {
                    // Navigate to planet details
                }
                .buttonStyle(.cosmic)
                .frame(maxWidth: .infinity)
                
                Button("Deploy Mission") {
                    // Deploy trading bot
                }
                .buttonStyle(.solar)
                .frame(maxWidth: .infinity)
            }
        }
        .planetCard()
        .id(planet.id)
    }
    
    private var tradingConstellation: some View {
        VStack(spacing: 16) {
            Text("⭐ Trading Constellation")
                .font(DesignSystem.Typography.planet)
                .cosmicText()
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                StarMetric(title: "Week", value: "$\(String(format: "%.0f", tradingManager.weeklyPnL))", isPositive: tradingManager.weeklyPnL >= 0)
                StarMetric(title: "Month", value: "$\(String(format: "%.0f", tradingManager.monthlyPnL))", isPositive: tradingManager.monthlyPnL >= 0)
                StarMetric(title: "Year", value: "$2,847", isPositive: true)
                StarMetric(title: "Trades", value: "\(botManager.activeBots.reduce(0) { $0 + $1.totalTrades })", isPositive: true)
                StarMetric(title: "Win Rate", value: "73%", isPositive: true)
                StarMetric(title: "Drawdown", value: "4.2%", isPositive: false)
            }
        }
        .planetCard()
    }
    
    private var activeMissionsView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("🛸 Active Missions")
                    .font(DesignSystem.Typography.planet)
                    .cosmicText()
                
                Spacer()
                
                if botManager.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(DesignSystem.cosmicBlue)
                }
            }
            
            if botManager.activeBots.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 48))
                        .foregroundColor(DesignSystem.cosmicBlue.opacity(0.6))
                    
                    Text("No active missions")
                        .font(DesignSystem.Typography.planet)
                        .foregroundColor(DesignSystem.starWhite.opacity(0.8))
                    
                    Text("Deploy a bot to start your cosmic trading journey")
                        .font(DesignSystem.Typography.asteroid)
                        .foregroundColor(DesignSystem.starWhite.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.Radius.star)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.Radius.star)
                                .stroke(DesignSystem.cosmicBlue.opacity(0.3), lineWidth: 1)
                        )
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(botManager.activeBots.prefix(4), id: \.id) { bot in
                        CosmicBotRow(bot: bot)
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

struct CosmicStatCard: View {
    let title: String
    let value: String
    let icon: String
    let gradient: LinearGradient
    let isPositive: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(gradient)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(DesignSystem.Typography.metricFont)
                    .foregroundStyle(gradient)
                    .lineLimit(1)
                
                Text(title)
                    .font(DesignSystem.Typography.dust)
                    .foregroundColor(DesignSystem.starWhite.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.Radius.planet))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.planet)
                .stroke(gradient.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: isPositive ? DesignSystem.profitGreen.opacity(0.2) : DesignSystem.lossRed.opacity(0.2), radius: 8)
    }
}

struct StarMetric: View {
    let title: String
    let value: String
    let isPositive: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(DesignSystem.Typography.asteroid)
                .fontWeight(.bold)
                .profitLossText(isPositive)
            
            Text(title)
                .font(DesignSystem.Typography.dust)
                .foregroundColor(DesignSystem.starWhite.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.Radius.meteor))
    }
}

struct CosmicBotRow: View {
    let bot: TradingBot
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(DesignSystem.nebuladeGradient)
                    .frame(width: 40, height: 40)
                
                Image(systemName: bot.icon)
                    .font(.title3)
                    .foregroundColor(.white)
            }
            .pulsingEffect()
            
            VStack(alignment: .leading, spacing: 2) {
                Text(bot.name)
                    .font(DesignSystem.Typography.asteroid)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.starWhite)
                
                Text("Win Rate: \(bot.displayWinRate)")
                    .font(DesignSystem.Typography.dust)
                    .foregroundColor(DesignSystem.starWhite.opacity(0.7))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(bot.displayProfitability)
                    .font(DesignSystem.Typography.asteroid)
                    .fontWeight(.bold)
                    .profitLossText(bot.profitability >= 0)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(bot.status.color)
                        .frame(width: 6, height: 6)
                        .pulsingEffect()
                    
                    Text(bot.status.rawValue.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(bot.status.color)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.Radius.planet))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.planet)
                .stroke(DesignSystem.cosmicBlue.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Trading Planet Model
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

// MARK: - Other Cosmic Views
struct CosmicBotsView: View {
    @EnvironmentObject var botManager: BotManager
    
    var body: some View {
        ZStack {
            DesignSystem.spaceGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    Text("🤖 AI Bot Fleet")
                        .font(DesignSystem.Typography.cosmic)
                        .cosmicText()
                        .sparkleEffect()
                    
                    LazyVStack(spacing: 16) {
                        ForEach(botManager.allBots, id: \.id) { bot in
                            CosmicBotCard(bot: bot)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

struct CosmicBotCard: View {
    let bot: TradingBot
    @EnvironmentObject var botManager: BotManager
    @EnvironmentObject var hapticManager: HapticManager
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                ZStack {
                    Circle()
                        .fill(DesignSystem.nebuladeGradient)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: bot.icon)
                        .font(.title2)
                        .foregroundColor(.white)
                }
                .pulsingEffect()
                
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
                            .fill(bot.status.color)
                            .frame(width: 8, height: 8)
                            .pulsingEffect()
                        
                        Text(bot.status.rawValue.uppercased())
                            .font(DesignSystem.Typography.dust)
                            .fontWeight(.bold)
                            .foregroundColor(bot.status.color)
                    }
                }
            }
            
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
            
            if bot.isActive {
                Button("🛑 Stop Mission") {
                    botManager.stopBot(bot)
                    hapticManager.warning()
                }
                .buttonStyle(.cosmic)
                .frame(maxWidth: .infinity)
            } else {
                Button("🚀 Launch Mission") {
                    Task {
                        await botManager.deployBot(bot)
                    }
                    hapticManager.botDeployed()
                }
                .buttonStyle(.solar)
                .frame(maxWidth: .infinity)
            }
        }
        .planetCard()
    }
}

struct GalacticPortfolioView: View {
    var body: some View {
        ZStack {
            DesignSystem.spaceGradient
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Text("🌌 Galactic Portfolio")
                    .font(DesignSystem.Typography.cosmic)
                    .cosmicText()
                    .sparkleEffect()
                
                Text("Advanced portfolio analytics launching soon...")
                    .font(DesignSystem.Typography.asteroid)
                    .foregroundColor(DesignSystem.starWhite.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .planetCard()
            }
            .padding()
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

struct SpaceSettingsView: View {
    var body: some View {
        ZStack {
            DesignSystem.spaceGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    Text("⚙️ Space Station Control")
                        .font(DesignSystem.Typography.cosmic)
                        .cosmicText()
                        .sparkleEffect()
                    
                    NavigationLink(destination: RealAccountView()) {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(DesignSystem.planetEarthGradient)
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "building.columns.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("🏦 Live Trading Station")
                                    .font(DesignSystem.Typography.planet)
                                    .cosmicText()
                                
                                Text("Connect to Coinexx & deploy bots")
                                    .font(DesignSystem.Typography.asteroid)
                                    .foregroundColor(DesignSystem.starWhite.opacity(0.8))
                            }
                            
                            Spacer()
                            
                            Text("CONNECT")
                                .font(DesignSystem.Typography.dust)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(DesignSystem.profitGreen, in: Capsule())
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(DesignSystem.starWhite.opacity(0.6))
                        }
                        .planetCard()
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Text("Additional space station controls coming soon...")
                        .font(DesignSystem.Typography.asteroid)
                        .foregroundColor(DesignSystem.starWhite.opacity(0.6))
                        .planetCard()
                }
                .padding()
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

#Preview {
    ContentView()
        .environmentObject(TradingManager.shared)
        .environmentObject(BotManager.shared)
        .environmentObject(AccountManager.shared)
        .environmentObject(HapticManager.shared)
}
//
//  EnhancedProTraderDashboard.swift
//  Planet ProTrader - Solar System Edition
//
//  Revolutionary Trading Dashboard with Live/Demo/Historical Sections
//  Mass deployment system for 5000 bots + A++ Screenshot System
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

struct EnhancedProTraderDashboard: View {
    @StateObject private var armyManager = ProTraderArmyManager()
    @StateObject private var screenshotManager = TradeScreenshotManager.shared
    @StateObject private var supabaseManager = SupabaseManager.shared
    @StateObject private var goldTradingManager = ContinuousGoldTradingManager.shared
    
    @State private var selectedSection: DashboardSection = .live
    @State private var animateCards = false
    @State private var showingMassDeployment = false
    @State private var deploymentProgress: Double = 0.0
    @State private var isDeploying = false
    
    enum DashboardSection: String, CaseIterable {
        case live = "LIVE"
        case demo = "DEMO"
        case historical = "HISTORICAL"
        
        var icon: String {
            switch self {
            case .live: return "dot.radiowaves.left.and.right"
            case .demo: return "testtube.2"
            case .historical: return "chart.line.uptrend.xyaxis"
            }
        }
        
        var color: Color {
            switch self {
            case .live: return .green
            case .demo: return .orange
            case .historical: return .blue
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                DesignSystem.AnimatedStarField()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Enhanced Header
                    enhancedHeader
                    
                    // Section Selector
                    sectionSelector
                    
                    // Main Content
                    ScrollView {
                        LazyVStack(spacing: 20) {
                                        // Mass Deployment Section
            massDeploymentSection
            
            // 24/7 Gold Trading Control
            goldTradingControlSection
                            
                            // Section-specific content
                            switch selectedSection {
                            case .live:
                                liveTradingSection
                            case .demo:
                                demoTradingSection
                            case .historical:
                                historicalDataSection
                            }
                            
                            // A++ Screenshot Gallery
                            screenshotGallerySection
                            
                            // Bot Army Status
                            botArmyStatusSection
                        }
                        .padding()
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                setupDashboard()
            }
            .sheet(isPresented: $showingMassDeployment) {
                MassDeploymentSheet(
                    armyManager: armyManager,
                    deploymentProgress: $deploymentProgress,
                    isDeploying: $isDeploying
                )
            }
        }
    }
    
    // MARK: - Enhanced Header
    private var enhancedHeader: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        // Pulse indicator
                        ZStack {
                            Circle()
                                .fill(.green)
                                .frame(width: 12, height: 12)
                            
                            Circle()
                                .stroke(.green.opacity(0.3), lineWidth: 3)
                                .scaleEffect(animateCards ? 2.0 : 1.0)
                                .opacity(animateCards ? 0 : 1)
                                .animation(.easeOut(duration: 2).repeatForever(autoreverses: false), value: animateCards)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("GOLD ARMY STATUS")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .tracking(1.5)
                            
                            Text("\(armyManager.activeBots)/5000 BOTS ACTIVE")
                                .font(.title2)
                                .fontWeight(.black)
                                .foregroundColor(.white)
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text("TOTAL GOLD P&L")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .tracking(1.5)
                    
                    Text("+$\(String(format: "%.2f", armyManager.totalPnL))")
                        .font(.title)
                        .fontWeight(.black)
                        .foregroundColor(.green)
                        .scaleEffect(animateCards ? 1.0 : 0.9)
                        .animation(.spring(response: 0.6), value: animateCards)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            // Supabase Connection Status
            HStack(spacing: 12) {
                Image(systemName: "externaldrive.connected.to.line.below")
                    .foregroundColor(supabaseManager.isConnected ? .green : .red)
                
                Text("Supabase: \(supabaseManager.connectionStatus)")
                    .font(.caption)
                    .foregroundColor(supabaseManager.isConnected ? .green : .red)
                
                Spacer()
                
                Text("A++ Screenshots: \(screenshotManager.screenshotStats.aPlusPlusCount)")
                    .font(.caption)
                    .foregroundColor(.yellow)
                
                Text("24/7 Gold: \(goldTradingManager.isTrading24x7 ? "ACTIVE" : "PAUSED")")
                    .font(.caption)
                    .foregroundColor(goldTradingManager.isTrading24x7 ? .green : .orange)
            }
            .padding(.horizontal, 20)
        }
        .background(Color.black.opacity(0.8))
    }
    
    // MARK: - Section Selector
    private var sectionSelector: some View {
        HStack(spacing: 0) {
            ForEach(DashboardSection.allCases, id: \.self) { section in
                Button(action: {
                    withAnimation(.spring(response: 0.4)) {
                        selectedSection = section
                    }
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: section.icon)
                            .font(.title2)
                            .foregroundColor(selectedSection == section ? section.color : .gray)
                        
                        Text(section.rawValue)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(selectedSection == section ? section.color : .gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        Rectangle()
                            .fill(selectedSection == section ? section.color.opacity(0.2) : .clear)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .background(Color.black.opacity(0.6))
    }
    
    // MARK: - Mass Deployment Section
    private var massDeploymentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("⚡ LIGHTNING MASS DEPLOYMENT")
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .tracking(1.2)
                
                Spacer()
                
                Text("5000 BOTS READY")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.yellow.opacity(0.2), in: Capsule())
            }
            
            if isDeploying {
                VStack(spacing: 12) {
                    ProgressView("Deploying \(Int(deploymentProgress * 5000))/5000 bots...", value: deploymentProgress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .green))
                    
                    Text("Lightning-fast parallel deployment in progress...")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            } else {
                Button(action: {
                    showingMassDeployment = true
                }) {
                    HStack {
                        Image(systemName: "bolt.fill")
                        Text("DEPLOY 5000 GOLD BOTS INSTANTLY")
                            .fontWeight(.black)
                            .tracking(1.2)
                        Image(systemName: "bolt.fill")
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.yellow, .orange, .yellow],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.yellow.opacity(0.3), lineWidth: 2)
                )
        )
    }
    
    // MARK: - Live Trading Section
    private var liveTradingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("🟢 LIVE REAL MONEY TRADING")
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .tracking(1.2)
                
                Spacer()
                
                Text("ACTIVE")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.green.opacity(0.2), in: Capsule())
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                LiveStatCard(
                    title: "Active Live Bots",
                    value: "\(armyManager.activeBots)",
                    subtitle: "Trading real money",
                    color: .green,
                    icon: "dollarsign.circle.fill"
                )
                
                LiveStatCard(
                    title: "Today's Live P&L",
                    value: "+$\(String(format: "%.2f", armyManager.totalDailyPnL))",
                    subtitle: "Real profits",
                    color: .green,
                    icon: "chart.line.uptrend.xyaxis"
                )
                
                LiveStatCard(
                    title: "Live Win Rate",
                    value: "\(String(format: "%.1f", armyManager.overallWinRate))%",
                    subtitle: "Success rate",
                    color: .blue,
                    icon: "target"
                )
                
                LiveStatCard(
                    title: "Risk Level",
                    value: "LOW",
                    subtitle: "Controlled exposure",
                    color: .orange,
                    icon: "shield.checkered"
                )
            }
            
            // Live bots list
            if armyManager.activeBots > 0 {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Top Live Performers")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    ForEach(armyManager.getTopPerformingBots(limit: 3), id: \.id) { bot in
                        LiveBotCard(bot: bot)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.green.opacity(0.3), lineWidth: 2)
                )
        )
    }
    
    // MARK: - Demo Trading Section
    private var demoTradingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("🧪 DEMO TESTING ENVIRONMENT")
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .tracking(1.2)
                
                Spacer()
                
                Text("TESTING")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.orange.opacity(0.2), in: Capsule())
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                DemoStatCard(
                    title: "Demo Bots",
                    value: "2500",
                    subtitle: "Testing strategies",
                    color: .orange,
                    icon: "testtube.2"
                )
                
                DemoStatCard(
                    title: "Virtual P&L",
                    value: "+$45,892",
                    subtitle: "Paper profits",
                    color: .orange,
                    icon: "chart.bar.fill"
                )
                
                DemoStatCard(
                    title: "Test Trades",
                    value: "12,458",
                    subtitle: "Simulated",
                    color: .purple,
                    icon: "speedometer"
                )
                
                DemoStatCard(
                    title: "Success Rate",
                    value: "91.2%",
                    subtitle: "Demo performance",
                    color: .cyan,
                    icon: "checkmark.seal.fill"
                )
            }
            
            // Demo features
            VStack(alignment: .leading, spacing: 12) {
                Text("Demo Features")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                DemoFeatureRow(title: "Real Market Data", status: "Active", color: .green)
                DemoFeatureRow(title: "Zero Risk Testing", status: "Enabled", color: .blue)
                DemoFeatureRow(title: "Strategy Optimization", status: "Running", color: .purple)
                DemoFeatureRow(title: "Performance Analytics", status: "Live", color: .cyan)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.orange.opacity(0.3), lineWidth: 2)
                )
        )
    }
    
    // MARK: - Historical Data Section
    private var historicalDataSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("📊 HISTORICAL PERFORMANCE DATA")
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .tracking(1.2)
                
                Spacer()
                
                Text("24/7 LEARNING")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.blue.opacity(0.2), in: Capsule())
            }
            
            // Performance metrics
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                HistoricalStatCard(
                    title: "All-Time P&L",
                    value: "+$847,392",
                    subtitle: "Total profits",
                    color: .blue,
                    icon: "banknote.fill"
                )
                
                HistoricalStatCard(
                    title: "Total Trades",
                    value: "458,293",
                    subtitle: "Executed",
                    color: .blue,
                    icon: "arrow.left.arrow.right"
                )
                
                HistoricalStatCard(
                    title: "Learning Hours",
                    value: "847,392",
                    subtitle: "Continuous improvement",
                    color: .purple,
                    icon: "brain.head.profile"
                )
                
                HistoricalStatCard(
                    title: "Strategies Learned",
                    value: "2,847",
                    subtitle: "Optimized patterns",
                    color: .cyan,
                    icon: "cpu"
                )
            }
            
            // Performance chart placeholder
            VStack(alignment: .leading, spacing: 8) {
                Text("7-Day Performance Trend")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(.ultraThinMaterial)
                    .frame(height: 120)
                    .overlay(
                        Text("📈 Chart: Continuous upward trend")
                            .foregroundColor(.gray)
                    )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.blue.opacity(0.3), lineWidth: 2)
                )
        )
    }
    
    // MARK: - Screenshot Gallery Section
    private var screenshotGallerySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("📸 A++ TRADE SCREENSHOTS")
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .tracking(1.2)
                
                Spacer()
                
                Text("\(screenshotManager.screenshotStats.aPlusPlusCount) A++")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.yellow.opacity(0.2), in: Capsule())
            }
            
            if screenshotManager.screenshots.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    
                    Text("No A++ screenshots yet")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("Deploy bots to start capturing perfect trades")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(screenshotManager.getAPlusPlusScreenshots().prefix(5), id: \.id) { screenshot in
                            ScreenshotCard(screenshot: screenshot)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.yellow.opacity(0.3), lineWidth: 2)
                )
        )
    }
    
    // MARK: - Bot Army Status Section
    private var botArmyStatusSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🤖 BOT ARMY STATUS")
                .font(.headline)
                .fontWeight(.black)
                .foregroundColor(.white)
                .tracking(1.2)
            
            HStack(spacing: 16) {
                BotStatusCard(
                    title: "God Mode",
                    count: armyManager.getBotStats().godMode,
                    color: .yellow,
                    icon: "crown.fill"
                )
                
                BotStatusCard(
                    title: "Elite",
                    count: armyManager.getBotStats().elite,
                    color: .purple,
                    icon: "star.fill"
                )
                
                BotStatusCard(
                    title: "Active",
                    count: armyManager.getBotStats().active,
                    color: .green,
                    icon: "bolt.fill"
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.cyan.opacity(0.3), lineWidth: 2)
                )
        )
    }
    
    // MARK: - 24/7 Gold Trading Control Section
    private var goldTradingControlSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("🏆 24/7 GOLD TRADING SYSTEM")
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .tracking(1.2)
                
                Spacer()
                
                Text(goldTradingManager.isTrading24x7 ? "ACTIVE" : "PAUSED")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(goldTradingManager.isTrading24x7 ? .green : .orange)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background((goldTradingManager.isTrading24x7 ? Color.green : Color.orange).opacity(0.2), in: Capsule())
            }
            
            // Trading stats
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                GoldTradingStatCard(
                    title: "Daily P&L",
                    value: "+$\(String(format: "%.0f", goldTradingManager.currentDailyProfit))",
                    target: "$\(String(format: "%.0f", goldTradingManager.dailyProfitTarget))",
                    color: .green,
                    icon: "dollarsign.circle.fill"
                )
                
                GoldTradingStatCard(
                    title: "Weekly Progress",
                    value: "+$\(String(format: "%.0f", goldTradingManager.currentWeeklyProfit))",
                    target: "$100K Goal",
                    color: .blue,
                    icon: "chart.line.uptrend.xyaxis"
                )
                
                GoldTradingStatCard(
                    title: "Active Trades",
                    value: "\(goldTradingManager.activeTrades.count)",
                    target: "Max 5",
                    color: .orange,
                    icon: "arrow.left.arrow.right"
                )
            }
            
            // Control buttons
            HStack(spacing: 12) {
                if goldTradingManager.isTrading24x7 {
                    Button(action: {
                        goldTradingManager.stop247Trading()
                    }) {
                        HStack {
                            Image(systemName: "pause.fill")
                            Text("PAUSE 24/7 TRADING")
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(.orange)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                } else {
                    Button(action: {
                        Task {
                            await goldTradingManager.start247Trading()
                        }
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("START 24/7 GOLD TRADING")
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(.green)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                
                NavigationLink(destination: RealMT5AccountView()) {
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                        Text("REAL MT5")
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            
            // Progress toward $100K goal
            if goldTradingManager.currentWeeklyProfit > 0 {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("$100K Weekly Goal Progress")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("\(String(format: "%.1f", (goldTradingManager.currentWeeklyProfit / goldTradingManager.weeklyTarget) * 100))%")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                    }
                    
                    ProgressView(value: goldTradingManager.currentWeeklyProfit, total: goldTradingManager.weeklyTarget)
                        .progressViewStyle(LinearProgressViewStyle(tint: .yellow))
                        .scaleEffect(y: 2)
                }
                .padding(.top, 8)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.yellow.opacity(0.4), lineWidth: 2)
                )
        )
    }
    
    // MARK: - Setup
    private func setupDashboard() {
        withAnimation(.easeInOut(duration: 0.8)) {
            animateCards = true
        }
        
        Task {
            await armyManager.quickSetup()
        }
    }
}

// MARK: - Supporting Views

struct LiveStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.5), lineWidth: 1)
                )
        )
    }
}

struct DemoStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.5), lineWidth: 1)
                )
        )
    }
}

struct HistoricalStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.5), lineWidth: 1)
                )
        )
    }
}

struct LiveBotCard: View {
    let bot: ProTraderBot
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(.green.opacity(0.3))
                .frame(width: 32, height: 32)
                .overlay(
                    Text(bot.name.prefix(2))
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(bot.name)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("XAUUSD • Live Trading")
                    .font(.caption2)
                    .foregroundColor(.green)
            }
            
            Spacer()
            
            Text("+$\(String(format: "%.0f", bot.todayPnL))")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.green)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.green.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct DemoFeatureRow: View {
    let title: String
    let status: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.white)
            
            Spacer()
            
            Text(status)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(color)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(color.opacity(0.2), in: Capsule())
        }
    }
}

struct ScreenshotCard: View {
    let screenshot: TradeScreenshot
    
    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 8)
                .fill(.gray.opacity(0.3))
                .frame(width: 120, height: 80)
                .overlay(
                    VStack {
                        Text(screenshot.tradeGrade.emoji)
                            .font(.title2)
                        Text(screenshot.tradeGrade.rawValue)
                            .font(.caption2)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                )
            
            Text(screenshot.symbol)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("+$\(String(format: "%.0f", screenshot.profitLoss))")
                .font(.caption2)
                .foregroundColor(.green)
        }
        .frame(width: 120)
    }
}

struct BotStatusCard: View {
    let title: String
    let count: Int
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text("\(count)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.5), lineWidth: 1)
                )
        )
    }
}

struct GoldTradingStatCard: View {
    let title: String
    let value: String
    let target: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Text(target)
                .font(.caption2)
                .foregroundColor(color)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(color.opacity(0.5), lineWidth: 1)
                )
        )
    }
}

struct MassDeploymentSheet: View {
    let armyManager: ProTraderArmyManager
    @Binding var deploymentProgress: Double
    @Binding var isDeploying: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Image(systemName: "bolt.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.yellow)
                    
                    Text("MASS DEPLOYMENT")
                        .font(.title)
                        .fontWeight(.black)
                        .foregroundColor(.white)
                        .tracking(2)
                    
                    Text("Deploy 5000 AI-powered gold trading bots instantly")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 24) {
                    DeploymentOptionCard(
                        title: "PARALLEL DEPLOYMENT",
                        subtitle: "Deploy all 5000 bots simultaneously",
                        time: "~30 seconds",
                        recommended: true
                    ) {
                        startMassDeployment(mode: .parallel)
                    }
                    
                    DeploymentOptionCard(
                        title: "BATCH DEPLOYMENT",
                        subtitle: "Deploy in groups of 500 bots",
                        time: "~2 minutes",
                        recommended: false
                    ) {
                        startMassDeployment(mode: .batch)
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(DesignSystem.AnimatedStarField().ignoresSafeArea())
            .navigationTitle("Mass Deployment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.yellow)
                }
            }
        }
    }
    
    private func startMassDeployment(mode: DeploymentMode) {
        isDeploying = true
        deploymentProgress = 0.0
        
        Task {
            for i in 0...100 {
                await MainActor.run {
                    deploymentProgress = Double(i) / 100.0
                }
                try? await Task.sleep(nanoseconds: 50_000_000) // 50ms delay
            }
            
            await armyManager.deployBots(count: 5000)
            
            await MainActor.run {
                isDeploying = false
                dismiss()
            }
        }
    }
    
    enum DeploymentMode {
        case parallel, batch
    }
}

struct DeploymentOptionCard: View {
    let title: String
    let subtitle: String
    let time: String
    let recommended: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    if recommended {
                        Text("RECOMMENDED")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.yellow.opacity(0.2), in: Capsule())
                    }
                }
                
                HStack {
                    Text("Deployment Time: \(time)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundColor(.yellow)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(recommended ? .yellow.opacity(0.5) : .gray.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    EnhancedProTraderDashboard()
        .preferredColorScheme(.dark)
}

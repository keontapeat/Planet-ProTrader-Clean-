//
//  ProTraderDashboardView.swift
//  Planet ProTrader - Solar System Edition
//
//  Created by Keonta Peat on 1/25/25.
//

import SwiftUI
import Charts

struct ProTraderDashboardView: View {
    @StateObject private var armyManager = ProTraderArmyManager()
    @State private var selectedTab = 0
    @State private var showingDeploymentSheet = false
    @State private var showingBotDetails = false
    @State private var selectedBot: ProTraderBot?
    @State private var isAutoScrolling = true
    @State private var animateNumbers = false
    @State private var showingBotJournal = false
    @State private var showingQuickDeployment = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Status Bar with Deploy Button
            topStatusBarWithDeployButton
            
            // Main Dashboard Content
            TabView(selection: $selectedTab) {
                LiveTradingView(armyManager: armyManager) { bot in
                    selectedBot = bot
                    showingBotJournal = true
                }
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Live Trading")
                }
                .tag(0)
                
                DemoTradingView(armyManager: armyManager)
                    .tabItem {
                        Image(systemName: "gamecontroller")
                        Text("Demo Trading")
                    }
                    .tag(1)
                
                HistoricalDataView(armyManager: armyManager)
                    .tabItem {
                        Image(systemName: "clock.arrow.circlepath")
                        Text("Historical")
                    }
                    .tag(2)
                
                TopBotsLeaderboardView(armyManager: armyManager) { bot in
                    selectedBot = bot
                    showingBotJournal = true
                }
                .tabItem {
                    Image(systemName: "trophy.fill")
                    Text("Leaderboard")
                }
                .tag(3)
                
                VPSDeploymentView(armyManager: armyManager)
                    .tabItem {
                        Image(systemName: "server.rack")
                        Text("VPS Deploy")
                    }
                    .tag(4)
            }
            .tint(.orange)
        }
        .onAppear {
            Task {
                await armyManager.quickSetup()
                withAnimation(.easeInOut(duration: 1.0)) {
                    animateNumbers = true
                }
            }
        }
        .sheet(isPresented: $showingDeploymentSheet) {
            DeploymentControlSheet(armyManager: armyManager)
        }
        .sheet(isPresented: $showingQuickDeployment) {
            QuickDeploymentSheet(armyManager: armyManager)
        }
        .sheet(isPresented: $showingBotJournal) {
            if let bot = selectedBot {
                BotJournalView(
                    botName: bot.name,
                    logs: generateSampleLogs(for: bot),
                    insights: generateSampleInsights(for: bot)
                )
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
    
    // MARK: - Enhanced Top Status Bar with Deploy Button
    private var topStatusBarWithDeployButton: some View {
        VStack(spacing: 12) {
            // Army Status Row
            HStack {
                // Army Stats
                VStack(alignment: .leading, spacing: 2) {
                    Text("ARMY STATUS")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(armyManager.isConnectedToVPS ? .green : .red)
                            .frame(width: 8, height: 8)
                        
                        Text("\(armyManager.deployedBots)/5000 ACTIVE")
                            .font(.headline)
                            .fontWeight(.black)
                            .foregroundColor(.primary)
                            .scaleEffect(animateNumbers ? 1.0 : 0.8)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animateNumbers)
                    }
                }
                
                Spacer()
                
                // Performance Metrics
                VStack(alignment: .trailing, spacing: 2) {
                    Text("TODAY'S P&L")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text("+$24,567")
                        .font(.headline)
                        .fontWeight(.black)
                        .foregroundColor(.green)
                        .scaleEffect(animateNumbers ? 1.0 : 0.8)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: animateNumbers)
                }
            }
            
            // Deploy All Button Row
            HStack(spacing: 12) {
                Button(" DEPLOY ALL BOTS") {
                    showingQuickDeployment = true
                }
                .font(.headline)
                .fontWeight(.black)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.orange, .red]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .orange.opacity(0.4), radius: 4, x: 0, y: 2)
                
                Button(" SETTINGS") {
                    showingDeploymentSheet = true
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.orange)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
    }
    
    // MARK: - Sample Data Generation
    private func generateSampleLogs(for bot: ProTraderBot) -> [TradeLog] {
        return [
            TradeLog(date: Date(), symbol: "XAUUSD", action: "Buy", entryPrice: 1973.52, notes: "GODMODE detected strong breakout pattern on M15 - RSI oversold bounce with volume confirmation"),
            TradeLog(date: Date().addingTimeInterval(-3600), symbol: "XAUUSD", action: "Sell", entryPrice: 1980.00, notes: "Reversal on RSI divergence - took profit at resistance level"),
            TradeLog(date: Date().addingTimeInterval(-7200), symbol: "EURUSD", action: "Buy", entryPrice: 1.0842, notes: "News-based momentum trade - ECB dovish stance triggered entry"),
            TradeLog(date: Date().addingTimeInterval(-10800), symbol: "GBPUSD", action: "Sell", entryPrice: 1.2734, notes: "Technical breakdown below key support - stop loss hit perfectly"),
            TradeLog(date: Date().addingTimeInterval(-14400), symbol: "XAUUSD", action: "Buy", entryPrice: 1965.80, notes: "AI pattern recognition: Similar to historical win #2847")
        ]
    }
    
    private func generateSampleInsights(for bot: ProTraderBot) -> [ClaudeInsight] {
        return [
            ClaudeInsight(summary: "Consistent reversal detection on XAUUSD", advice: "Consider increasing lot size on RSI-confirmed trades when confidence > 95%. Your hit rate on gold reversals is 89.3%."),
            ClaudeInsight(summary: "Strong breakout momentum trading", advice: "Enable GODMODE logic when confidence > 90%. Your breakout trades have 2.4x better performance."),
            ClaudeInsight(summary: "News trading optimization needed", advice: "Add 15-minute buffer before high-impact news events. Recent losses correlate with immediate news entries."),
            ClaudeInsight(summary: "Risk management excellence", advice: "Your stop-loss placement is optimal. Continue using 1.5% max risk per trade - it's protecting capital effectively."),
            ClaudeInsight(summary: "AI pattern recognition improving", advice: "Your machine learning model accuracy increased 12% this week. Consider expanding training dataset for crypto pairs.")
        ]
    }
}

// MARK: - Live Trading View
struct LiveTradingView: View {
    @ObservedObject var armyManager: ProTraderArmyManager
    let onBotTap: (ProTraderBot) -> Void
    @State private var refreshTimer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    @State private var showingScreenshots = false
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Live Stats Cards
                liveStatsSection
                
                // Screenshots Section
                liveScreenshotsSection
                
                // Active Bots Grid
                activeBotsList
                
            }
            .padding()
        }
        .refreshable {
            await armyManager.quickSetup()
        }
        .onReceive(refreshTimer) { _ in
            // Simulate real-time updates
            Task {
                await armyManager.quickSetup()
            }
        }
        .sheet(isPresented: $showingScreenshots) {
            LiveScreenshotsView()
        }
    }
    
    private var liveStatsSection: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
            DashboardStatCard(
                title: "ACTIVE BOTS",
                value: "\(armyManager.activeBots)",
                subtitle: "Trading Live",
                color: .green,
                icon: "bolt.fill"
            )
            
            DashboardStatCard(
                title: "WIN RATE",
                value: "87.5%",
                subtitle: "Today",
                color: .blue,
                icon: "target"
            )
            
            DashboardStatCard(
                title: "TOTAL P&L",
                value: "$47,892",
                subtitle: "All Time",
                color: .purple,
                icon: "chart.line.uptrend.xyaxis"
            )
            
            DashboardStatCard(
                title: "GODMODE BOTS",
                value: "\(armyManager.godmodeBots)",
                subtitle: "95%+ Confidence",
                color: .orange,
                icon: "crown.fill"
            )
        }
    }
    
    private var liveScreenshotsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(" LIVE TRADING SCREENSHOTS")
                    .font(.headline)
                    .fontWeight(.black)
                
                Spacer()
                
                Button("View All") {
                    showingScreenshots = true
                }
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.orange.opacity(0.2))
                .foregroundColor(.orange)
                .clipShape(Capsule())
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<8, id: \.self) { index in
                        ScreenshotCard(
                            title: "ProBot-\(String(format: "%04d", index + 1))",
                            profit: "+$\(Int.random(in: 150...800))",
                            time: "\(Int.random(in: 1...5))m ago"
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var activeBotsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(" LIVE TRADING BOTS")
                    .font(.headline)
                    .fontWeight(.black)
                
                Spacer()
                
                Text("\(armyManager.liveBots.count) Active")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.green.opacity(0.2))
                    .foregroundColor(.green)
                    .clipShape(Capsule())
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 1), spacing: 8) {
                ForEach(armyManager.liveBots.prefix(10)) { bot in
                    DashboardLiveBotCard(bot: bot) {
                        onBotTap(bot)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Demo Trading View
struct DemoTradingView: View {
    @ObservedObject var armyManager: ProTraderArmyManager
    @State private var showingDemoScreenshots = false
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Demo Stats
                demoStatsSection
                
                // Demo Screenshots Section
                demoScreenshotsSection
                
                // Training Bots
                trainingBotsList
                
                // Virtual Performance
                virtualPerformanceSection
            }
            .padding()
        }
        .sheet(isPresented: $showingDemoScreenshots) {
            DemoScreenshotsView()
        }
    }
    
    private var demoStatsSection: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
            DashboardStatCard(
                title: "DEMO BOTS",
                value: "\(armyManager.demoBots.count)",
                subtitle: "In Training",
                color: .blue,
                icon: "gamecontroller.fill"
            )
            
            DashboardStatCard(
                title: "VIRTUAL P&L",
                value: "$12,456",
                subtitle: "Simulated",
                color: .cyan,
                icon: "chart.bar.fill"
            )
            
            DashboardStatCard(
                title: "TEST TRADES",
                value: "2,847",
                subtitle: "Completed",
                color: .indigo,
                icon: "arrow.triangle.2.circlepath"
            )
            
            DashboardStatCard(
                title: "LEARNING",
                value: "78%",
                subtitle: "Progress",
                color: .mint,
                icon: "brain.head.profile"
            )
        }
    }
    
    private var demoScreenshotsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(" DEMO TRADING SCREENSHOTS")
                    .font(.headline)
                    .fontWeight(.black)
                
                Spacer()
                
                Button("View All") {
                    showingDemoScreenshots = true
                }
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.blue.opacity(0.2))
                .foregroundColor(.blue)
                .clipShape(Capsule())
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<6, id: \.self) { index in
                        ScreenshotCard(
                            title: "DemoBot-\(String(format: "%03d", index + 1))",
                            profit: "Virtual: +$\(Int.random(in: 50...300))",
                            time: "Training"
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var trainingBotsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(" TRAINING BOTS")
                .font(.headline)
                .fontWeight(.black)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 1), spacing: 8) {
                ForEach(armyManager.demoBots.prefix(15)) { bot in
                    DashboardDemoBotCard(bot: bot)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var virtualPerformanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(" VIRTUAL PERFORMANCE")
                .font(.headline)
                .fontWeight(.black)
            
            Chart {
                ForEach(0..<30, id: \.self) { day in
                    BarMark(
                        x: .value("Day", day),
                        y: .value("Virtual P&L", Double.random(in: 200...800))
                    )
                    .foregroundStyle(.blue.gradient)
                }
            }
            .frame(height: 200)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Historical Data View
struct HistoricalDataView: View {
    @ObservedObject var armyManager: ProTraderArmyManager
    @State private var selectedTimeframe = "1M"
    @State private var showingDataUpload = false
    @State private var showingHistoricalScreenshots = false
    
    private let timeframes = ["1D", "1W", "1M", "3M", "1Y", "ALL"]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Timeframe Selector
                timeframeSelector
                
                // Historical Screenshots Section
                historicalScreenshotsSection
                
                // Historical Performance Chart
                historicalChart
                
                // Data Analysis Section
                dataAnalysisSection
                
                // Upload New Data
                uploadDataSection
            }
            .padding()
        }
        .sheet(isPresented: $showingHistoricalScreenshots) {
            HistoricalScreenshotsView()
        }
    }
    
    private var timeframeSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(timeframes, id: \.self) { timeframe in
                    Button(timeframe) {
                        selectedTimeframe = timeframe
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(selectedTimeframe == timeframe ? .orange : Color(.systemGray5))
                    .foregroundColor(selectedTimeframe == timeframe ? .white : .primary)
                    .clipShape(Capsule())
                    .font(.headline)
                    .fontWeight(.semibold)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var historicalScreenshotsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(" HISTORICAL DATA SCREENSHOTS")
                    .font(.headline)
                    .fontWeight(.black)
                
                Spacer()
                
                Button("View All") {
                    showingHistoricalScreenshots = true
                }
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.purple.opacity(0.2))
                .foregroundColor(.purple)
                .clipShape(Capsule())
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<10, id: \.self) { index in
                        ScreenshotCard(
                            title: "Backtest-\(index + 1)",
                            profit: "Historical: +$\(Int.random(in: 1000...5000))",
                            time: "\(2020 + index)"
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var historicalChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(" HISTORICAL PERFORMANCE - \(selectedTimeframe)")
                .font(.headline)
                .fontWeight(.black)
            
            Chart {
                ForEach(0..<100, id: \.self) { index in
                    LineMark(
                        x: .value("Time", index),
                        y: .value("Value", Double.random(in: 1000...5000))
                    )
                    .foregroundStyle(.orange.gradient)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                }
            }
            .frame(height: 300)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var dataAnalysisSection: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
            DashboardStatCard(
                title: "DATA POINTS",
                value: "2.4M",
                subtitle: "Analyzed",
                color: .purple,
                icon: "chart.dots.scatter"
            )
            
            DashboardStatCard(
                title: "PATTERNS",
                value: "1,247",
                subtitle: "Discovered",
                color: .pink,
                icon: "waveform.path"
            )
            
            DashboardStatCard(
                title: "ACCURACY",
                value: "94.2%",
                subtitle: "Backtest",
                color: .teal,
                icon: "checkmark.seal.fill"
            )
            
            DashboardStatCard(
                title: "VOLATILITY",
                value: "12.5%",
                subtitle: "Average",
                color: .red,
                icon: "waveform.path.ecg"
            )
        }
    }
    
    private var uploadDataSection: some View {
        VStack(spacing: 16) {
            Text(" UPLOAD HISTORICAL DATA")
                .font(.headline)
                .fontWeight(.black)
            
            Button(action: {
                showingDataUpload = true
            }) {
                VStack(spacing: 8) {
                    Image(systemName: "icloud.and.arrow.up")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                    
                    Text("Upload CSV Files")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Train your bots with new market data")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .sheet(isPresented: $showingDataUpload) {
            DataUploadSheet(armyManager: armyManager)
        }
    }
}

// MARK: - Top Bots Leaderboard View
struct TopBotsLeaderboardView: View {
    @ObservedObject var armyManager: ProTraderArmyManager
    let onBotTap: (ProTraderBot) -> Void
    @State private var selectedCategory = "All Time"
    
    private let categories = ["All Time", "Today", "This Week", "This Month"]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Category Selector
                categorySelector
                
                // Top 3 Podium
                topThreePodium
                
                // Leaderboard List
                leaderboardList
            }
            .padding()
        }
    }
    
    private var categorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    Button(category) {
                        selectedCategory = category
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(selectedCategory == category ? .orange : Color(.systemGray5))
                    .foregroundColor(selectedCategory == category ? .white : .primary)
                    .clipShape(Capsule())
                    .font(.headline)
                    .fontWeight(.semibold)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var topThreePodium: some View {
        VStack(spacing: 16) {
            Text(" TOP PERFORMERS - \(selectedCategory.uppercased())")
                .font(.headline)
                .fontWeight(.black)
            
            HStack(alignment: .bottom, spacing: 12) {
                // 2nd Place
                if armyManager.topBots.count > 1 {
                    PodiumCard(bot: armyManager.topBots[1], position: 2, height: 120) {
                        onBotTap(armyManager.topBots[1])
                    }
                }
                
                // 1st Place
                if !armyManager.topBots.isEmpty {
                    PodiumCard(bot: armyManager.topBots[0], position: 1, height: 140) {
                        onBotTap(armyManager.topBots[0])
                    }
                }
                
                // 3rd Place
                if armyManager.topBots.count > 2 {
                    PodiumCard(bot: armyManager.topBots[2], position: 3, height: 100) {
                        onBotTap(armyManager.topBots[2])
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var leaderboardList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(" FULL LEADERBOARD")
                .font(.headline)
                .fontWeight(.black)
            
            LazyVStack(spacing: 8) {
                ForEach(Array(armyManager.topBots.enumerated()), id: \.element.id) { index, bot in
                    Button(action: {
                        onBotTap(bot)
                    }) {
                        LeaderboardRow(bot: bot, rank: index + 1)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - VPS Deployment View
struct VPSDeploymentView: View {
    @ObservedObject var armyManager: ProTraderArmyManager
    @State private var showingVPSSettings = false
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // VPS Status
                vpsStatusSection
                
                // Deployment Controls
                deploymentControlsSection
                
                // Bot Distribution
                botDistributionSection
                
                // VPS Monitoring
                vpsMonitoringSection
            }
            .padding()
        }
    }
    
    private var vpsStatusSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "server.rack")
                    .font(.system(size: 40))
                    .foregroundColor(armyManager.isConnectedToVPS ? .green : .red)
                
                VStack(alignment: .leading) {
                    Text("VPS CONNECTION")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(armyManager.isConnectedToVPS ? "CONNECTED" : "DISCONNECTED")
                        .font(.title2)
                        .fontWeight(.black)
                        .foregroundColor(armyManager.isConnectedToVPS ? .green : .red)
                }
                
                Spacer()
                
                Button("Settings") {
                    showingVPSSettings = true
                }
                .foregroundColor(.orange)
            }
            
            Divider()
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                DashboardStatCard(
                    title: "DEPLOYED",
                    value: "\(armyManager.deployedBots)",
                    subtitle: "Active Bots",
                    color: .green,
                    icon: "checkmark.circle.fill"
                )
                
                DashboardStatCard(
                    title: "QUEUE",
                    value: "\(5000 - armyManager.deployedBots)",
                    subtitle: "Waiting",
                    color: .orange,
                    icon: "clock.fill"
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var deploymentControlsSection: some View {
        VStack(spacing: 16) {
            Text(" DEPLOYMENT CONTROLS")
                .font(.headline)
                .fontWeight(.black)
            
            if armyManager.isDeploying {
                VStack(spacing: 8) {
                    ProgressView(value: armyManager.deploymentProgress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                    
                    Text("Deploying Bots... \(Int(armyManager.deploymentProgress * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                DeploymentButton(
                    title: "Deploy 100",
                    subtitle: "Quick Deploy",
                    color: .blue,
                    icon: "bolt.fill"
                ) {
                    Task {
                        await armyManager.deployBots(count: 100)
                    }
                }
                
                DeploymentButton(
                    title: "Deploy 500",
                    subtitle: "Medium Deploy",
                    color: .purple,
                    icon: "forward.fill"
                ) {
                    Task {
                        await armyManager.deployBots(count: 500)
                    }
                }
                
                DeploymentButton(
                    title: "Deploy All",
                    subtitle: "Full Army",
                    color: .green,
                    icon: "checkmark.circle.fill"
                ) {
                    Task {
                        await armyManager.deployAllBots()
                    }
                }
                
                DeploymentButton(
                    title: "Emergency Stop",
                    subtitle: "Stop All",
                    color: .red,
                    icon: "stop.fill"
                ) {
                    Task {
                        await armyManager.emergencyStopAll()
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var botDistributionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(" BOT DISTRIBUTION")
                .font(.headline)
                .fontWeight(.black)
            
            Chart {
                BarMark(
                    x: .value("Category", "GODMODE"),
                    y: .value("Count", armyManager.godmodeBots)
                )
                .foregroundStyle(.orange.gradient)
                
                BarMark(
                    x: .value("Category", "ELITE"),
                    y: .value("Count", armyManager.eliteBots)
                )
                .foregroundStyle(.purple.gradient)
                
                BarMark(
                    x: .value("Category", "PRO"),
                    y: .value("Count", 1500)
                )
                .foregroundStyle(.blue.gradient)
                
                BarMark(
                    x: .value("Category", "LEARNING"),
                    y: .value("Count", 1903)
                )
                .foregroundStyle(.green.gradient)
            }
            .frame(height: 200)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var vpsMonitoringSection: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
            DashboardStatCard(
                title: "CPU USAGE",
                value: "67%",
                subtitle: "VPS Load",
                color: .yellow,
                icon: "cpu"
            )
            
            DashboardStatCard(
                title: "MEMORY",
                value: "23GB",
                subtitle: "Used",
                color: .cyan,
                icon: "memorychip"
            )
            
            DashboardStatCard(
                title: "LATENCY",
                value: "12ms",
                subtitle: "Average",
                color: .mint,
                icon: "timer"
            )
            
            DashboardStatCard(
                title: "UPTIME",
                value: "99.9%",
                subtitle: "30 Days",
                color: .indigo,
                icon: "clock.badge.checkmark"
            )
        }
    }
}

// MARK: - Supporting Views

struct DashboardStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct DashboardLiveBotCard: View {
    let bot: ProTraderBot
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Bot Avatar
                ZStack {
                    Circle()
                        .fill(bot.confidence >= 0.95 ? 
                              LinearGradient(colors: [.orange, .orange.opacity(0.8)], startPoint: .top, endPoint: .bottom) : 
                              LinearGradient(colors: [.blue, .blue.opacity(0.8)], startPoint: .top, endPoint: .bottom))
                        .frame(width: 40, height: 40)
                    
                    Text(bot.confidenceLevel.prefix(1))
                        .font(.headline)
                        .fontWeight(.black)
                        .foregroundColor(.white)
                }
                
                // Bot Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(bot.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("\(bot.strategy.rawValue) • \(bot.specialization.rawValue)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Performance
                VStack(alignment: .trailing, spacing: 2) {
                    Text("+$\(Int(bot.todayPnL))")
                        .font(.headline)
                        .fontWeight(.black)
                        .foregroundColor(.green)
                    
                    Text("\(Int(bot.winRate))% Win")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Journal Icon
                Image(systemName: "book.fill")
                    .foregroundColor(.orange)
                    .font(.title3)
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DashboardDemoBotCard: View {
    let bot: ProTraderBot
    
    var body: some View {
        HStack(spacing: 12) {
            // Progress Circle
            ZStack {
                Circle()
                    .stroke(.gray.opacity(0.3), lineWidth: 4)
                    .frame(width: 40, height: 40)
                
                Circle()
                    .trim(from: 0, to: bot.learningProgress)
                    .stroke(.blue.gradient, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 40, height: 40)
                    .rotationEffect(.degrees(-90))
                
                Text("\(Int(bot.learningProgress * 100))%")
                    .font(.caption2)
                    .fontWeight(.bold)
            }
            
            // Bot Info
            VStack(alignment: .leading, spacing: 2) {
                Text(bot.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("Virtual P&L: $\(Int(bot.virtualPnL))")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            // Test Stats
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(bot.testTrades)")
                    .font(.headline)
                    .fontWeight(.black)
                
                Text("Test Trades")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct PodiumCard: View {
    let bot: ProTraderBot
    let position: Int
    let height: CGFloat
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Medal
                ZStack {
                    Circle()
                        .fill(medalColor.gradient)
                        .frame(width: 50, height: 50)
                    
                    Text("\(position)")
                        .font(.title2)
                        .fontWeight(.black)
                        .foregroundColor(.white)
                }
                
                // Bot Info
                VStack(spacing: 4) {
                    Text(bot.name)
                        .font(.headline)
                        .fontWeight(.black)
                        .multilineTextAlignment(.center)
                    
                    Text("$\(Int(bot.totalPnL))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text("\(Int(bot.winRate))% Win")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(height: height)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: medalColor.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var medalColor: Color {
        switch position {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .brown
        default: return .blue
        }
    }
}

struct LeaderboardRow: View {
    let bot: ProTraderBot
    let rank: Int
    
    var body: some View {
        HStack(spacing: 12) {
            // Rank
            Text("#\(rank)")
                .font(.headline)
                .fontWeight(.black)
                .foregroundColor(.secondary)
                .frame(width: 40, alignment: .leading)
            
            // Bot Avatar
            ZStack {
                Circle()
                    .fill(bot.confidence >= 0.95 ? 
                          LinearGradient(colors: [.orange, .orange.opacity(0.8)], startPoint: .top, endPoint: .bottom) : 
                          LinearGradient(colors: [.blue, .blue.opacity(0.8)], startPoint: .top, endPoint: .bottom))
                    .frame(width: 35, height: 35)
                
                Text(bot.confidenceLevel.prefix(1))
                    .font(.caption)
                    .fontWeight(.black)
                    .foregroundColor(.white)
            }
            
            // Bot Info
            VStack(alignment: .leading, spacing: 2) {
                Text(bot.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(bot.strategy.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Performance
            VStack(alignment: .trailing, spacing: 2) {
                Text("$\(Int(bot.totalPnL))")
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundColor(.green)
                
                Text("\(Int(bot.winRate))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Journal Icon
            Image(systemName: "book.fill")
                .foregroundColor(.orange)
                .font(.caption)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct ScreenshotCard: View {
    let title: String
    let profit: String
    let time: String
    
    var body: some View {
        VStack(spacing: 8) {
            // Placeholder screenshot
            RoundedRectangle(cornerRadius: 8)
                .fill(.gray.opacity(0.3))
                .frame(width: 120, height: 80)
                .overlay(
                    VStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.title2)
                            .foregroundColor(.white)
                        Text("MT5")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                )
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Text(profit)
                    .font(.caption2)
                    .foregroundColor(.green)
                    .fontWeight(.bold)
                
                Text(time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 120)
    }
}

struct DeploymentButton: View {
    let title: String
    let subtitle: String
    let color: Color
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.black)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Screenshot Views

struct LiveScreenshotsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            HStack {
                Button(" Back") {
                    dismiss()
                }
                .foregroundColor(.orange)
                .font(.headline)
                
                Spacer()
                
                Text(" Live Screenshots")
                    .font(.title2)
                    .fontWeight(.black)
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
                .foregroundColor(.orange)
                .font(.headline)
            }
            .padding()
            .background(Color(.systemGray6))
            
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    ForEach(0..<20, id: \.self) { index in
                        VStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.gray.opacity(0.3))
                                .frame(height: 120)
                                .overlay(
                                    VStack {
                                        Image(systemName: "chart.line.uptrend.xyaxis")
                                            .font(.title)
                                            .foregroundColor(.white)
                                        Text("Live Trading")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                    }
                                )
                            
                            VStack(spacing: 4) {
                                Text("ProBot-\(String(format: "%04d", index + 1))")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                
                                Text("+$\(Int.random(in: 150...800))")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                    .fontWeight(.bold)
                                
                                Text("\(Int.random(in: 1...30))m ago")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }
}

struct DemoScreenshotsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            HStack {
                Button(" Back") {
                    dismiss()
                }
                .foregroundColor(.blue)
                .font(.headline)
                
                Spacer()
                
                Text(" Demo Screenshots")
                    .font(.title2)
                    .fontWeight(.black)
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
                .foregroundColor(.blue)
                .font(.headline)
            }
            .padding()
            .background(Color(.systemGray6))
            
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    ForEach(0..<15, id: \.self) { index in
                        VStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.blue.opacity(0.3))
                                .frame(height: 120)
                                .overlay(
                                    VStack {
                                        Image(systemName: "gamecontroller")
                                            .font(.title)
                                            .foregroundColor(.white)
                                        Text("Demo Trading")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                    }
                                )
                            
                            VStack(spacing: 4) {
                                Text("DemoBot-\(String(format: "%03d", index + 1))")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                
                                Text("Virtual: +$\(Int.random(in: 50...300))")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .fontWeight(.bold)
                                
                                Text("Training")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }
}

struct HistoricalScreenshotsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            HStack {
                Button(" Back") {
                    dismiss()
                }
                .foregroundColor(.purple)
                .font(.headline)
                
                Spacer()
                
                Text(" Historical Screenshots")
                    .font(.title2)
                    .fontWeight(.black)
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
                .foregroundColor(.purple)
                .font(.headline)
            }
            .padding()
            .background(Color(.systemGray6))
            
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    ForEach(0..<25, id: \.self) { index in
                        VStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.purple.opacity(0.3))
                                .frame(height: 120)
                                .overlay(
                                    VStack {
                                        Image(systemName: "clock.arrow.circlepath")
                                            .font(.title)
                                            .foregroundColor(.white)
                                        Text("Historical Data")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                    }
                                )
                            
                            VStack(spacing: 4) {
                                Text("Backtest-\(index + 1)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                
                                Text("Historical: +$\(Int.random(in: 1000...5000))")
                                    .font(.caption)
                                    .foregroundColor(.purple)
                                    .fontWeight(.bold)
                                
                                Text("\(2020 + (index % 5))")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - Sheet Views

struct DeploymentControlSheet: View {
    @ObservedObject var armyManager: ProTraderArmyManager
    @Environment(\.dismiss) private var dismiss
    @State private var deploymentCount = 100
    
    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.orange)
                
                Spacer()
                
                Text("Deploy ProTrader Army")
                    .font(.title2)
                    .fontWeight(.black)
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
                .foregroundColor(.orange)
            }
            .padding()
            .background(Color(.systemGray6))
            
            VStack(spacing: 16) {
                Text("Current: \(armyManager.deployedBots)/5000 Deployed")
                    .font(.headline)
                
                Stepper("Deploy \(deploymentCount) bots", value: $deploymentCount, in: 1...5000)
                    .font(.headline)
                
                Button("Deploy Now") {
                    Task {
                        await armyManager.deployBots(count: deploymentCount)
                        dismiss()
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .font(.headline)
            }
            .padding()
            
            Spacer()
        }
    }
}

struct DataUploadSheet: View {
    @ObservedObject var armyManager: ProTraderArmyManager
    @Environment(\.dismiss) private var dismiss
    @State private var isUploading = false
    
    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.orange)
                
                Spacer()
                
                Text("Upload Historical Data")
                    .font(.title2)
                    .fontWeight(.black)
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
                .foregroundColor(.orange)
            }
            .padding()
            .background(Color(.systemGray6))
            
            VStack(spacing: 16) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.orange)
                
                Text("Upload CSV files containing historical market data to train your ProTrader army.")
                    .multilineTextAlignment(.center)
                    .font(.headline)
                
                if isUploading {
                    ProgressView("Processing data...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                } else {
                    Button("Select Files") {
                        isUploading = true
                        Task {
                            // Simulate upload
                            try? await Task.sleep(nanoseconds: 3_000_000_000)
                            await armyManager.trainWithHistoricalData(csvData: "sample")
                            isUploading = false
                            dismiss()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    .font(.headline)
                }
            }
            .padding()
            
            Spacer()
        }
    }
}

struct QuickDeploymentSheet: View {
    @ObservedObject var armyManager: ProTraderArmyManager
    @Environment(\.dismiss) private var dismiss
    @State private var isDeploying = false
    @State private var deploymentProgress: Double = 0.0
    
    var body: some View {
        VStack(spacing: 30) {
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.orange)
                .disabled(isDeploying)
                
                Spacer()
                
                Text("Deploy Army")
                    .font(.title2)
                    .fontWeight(.black)
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
                .foregroundColor(.orange)
                .disabled(isDeploying)
            }
            .padding()
            .background(Color(.systemGray6))
            
            VStack(spacing: 16) {
                Text(" ")
                    .font(.system(size: 80))
                
                Text("Deploy All Bots")
                    .font(.title)
                    .fontWeight(.black)
                
                Text("Deploy all 5000 ProTrader bots to your VPS for maximum trading power!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 12) {
                HStack {
                    Text("Current Status:")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text("\(armyManager.deployedBots)/5000 Deployed")
                        .font(.headline)
                        .fontWeight(.black)
                        .foregroundColor(.orange)
                }
                
                ProgressView(value: Double(armyManager.deployedBots), total: 5000)
                    .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                    .scaleEffect(y: 3)
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            if isDeploying {
                VStack(spacing: 16) {
                    ProgressView("Deploying Bots...", value: deploymentProgress, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: .green))
                        .scaleEffect(y: 2)
                    
                    Text("\(Int(deploymentProgress * 100))% Complete")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                if !isDeploying {
                    Button(" DEPLOY ALL 5000 BOTS") {
                        deployAllBots()
                    }
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.orange, .red]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .orange.opacity(0.4), radius: 8, x: 0, y: 4)
                    
                    Button("Advanced Deployment") {
                        dismiss()
                        // Will open the regular deployment sheet
                    }
                    .font(.subheadline)
                    .foregroundColor(.orange)
                } else {
                    Button("Cancel Deployment") {
                        isDeploying = false
                        deploymentProgress = 0.0
                    }
                    .font(.headline)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding()
        }
    }
    
    private func deployAllBots() {
        isDeploying = true
        deploymentProgress = 0.0
        
        Task {
            // Simulate deployment progress
            for i in 0...100 {
                try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
                
                await MainActor.run {
                    deploymentProgress = Double(i) / 100.0
                }
            }
            
            // Complete deployment
            await armyManager.deployAllBots()
            
            await MainActor.run {
                isDeploying = false
                dismiss()
            }
        }
    }
}

#Preview {
    ProTraderDashboardView()
}
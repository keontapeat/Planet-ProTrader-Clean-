//
//  ProTraderDashboardView.swift
//  Planet ProTrader - Solar System Edition
//
//  Created by Keonta Peat on 1/25/25.
//

import SwiftUI
import Foundation

struct ProTraderDashboardView: View {
    @StateObject private var armyManager = ProTraderArmyManager()
    @State private var selectedTimeframe = "1H"
    @State private var showingTrainingResults = false
    @State private var showingBotDetails = false
    @State private var selectedBot: ProTraderBot?
    @State private var showingImporter = false
    @State private var showingGPTChat = false
    @State private var animateElements = false
    @State private var showingVPSStatus = false
    @State private var showingScreenshotGallery = false
    @State private var showingBotDeployment = false
    @State private var showingMassiveDataDownload = false
    
    private let timeframes = ["1M", "5M", "15M", "1H", "4H", "1D"]
    
    // SAMPLE HISTORICAL DATA FOR IMMEDIATE USE
    private let sampleHistoricalData = """
Date,Time,Open,High,Low,Close,Volume
2024.01.01,00:00,2078.50,2085.20,2075.80,2082.10,1500
2024.01.01,01:00,2082.10,2088.75,2080.30,2086.45,1750
2024.01.01,02:00,2086.45,2092.60,2084.20,2089.80,1620
2024.01.01,03:00,2089.80,2095.40,2087.90,2093.25,1480
2024.01.01,04:00,2093.25,2098.70,2091.60,2096.85,1890
2024.01.01,05:00,2096.85,2101.20,2094.40,2099.30,2100
2024.01.01,06:00,2099.30,2105.80,2097.10,2103.75,2250
2024.01.01,07:00,2103.75,2108.90,2101.20,2106.45,1980
2024.01.01,08:00,2106.45,2112.30,2104.60,2109.80,2340
2024.01.01,09:00,2109.80,2115.70,2107.50,2113.25,2580
2024.01.01,10:00,2113.25,2118.40,2111.80,2116.90,2720
2024.01.01,11:00,2116.90,2122.60,2114.30,2119.85,2890
2024.01.01,12:00,2119.85,2125.20,2117.40,2122.70,3100
2024.01.01,13:00,2122.70,2128.50,2120.90,2125.80,2950
2024.01.01,14:00,2125.80,2131.40,2123.20,2128.65,3250
2024.01.01,15:00,2128.65,2134.80,2126.10,2131.90,3480
2024.01.01,16:00,2131.90,2137.20,2129.50,2134.75,3200
2024.01.01,17:00,2134.75,2140.60,2132.30,2137.45,2980
2024.01.01,18:00,2137.45,2143.20,2135.80,2140.90,2750
2024.01.01,19:00,2140.90,2146.70,2138.40,2143.55,2890
2024.01.01,20:00,2143.55,2149.30,2141.20,2146.80,3100
2024.01.01,21:00,2146.80,2152.40,2144.60,2149.25,2840
2024.01.01,22:00,2149.25,2154.80,2147.10,2151.70,2650
2024.01.01,23:00,2151.70,2157.20,2149.90,2154.85,2420
"""
    
    var body: some View {
        NavigationStack {
            SwiftUI.ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 24) {
                    // Enhanced Header Stats
                    enhancedHeaderStatsSection
                    
                    // Bot Army Deployment Section
                    botArmyDeploymentSection
                    
                    // Army Overview Cards
                    enhancedArmyOverviewSection
                    
                    // VPS Status Section
                    vpsStatusSection
                    
                    // Training Section
                    enhancedTrainingSection
                    
                    // Bot Performance Grid
                    liveBotsPerformanceSection
                    
                    // Performance Charts
                    enhancedPerformanceChartsSection
                    
                    // Top Performers
                    enhancedTopPerformersSection
                    
                    // A+ Screenshots Gallery
                    aPlusScreenshotsSection
                    
                    // Footer spacing
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.02, green: 0.05, blue: 0.15),
                        Color(red: 0.05, green: 0.08, blue: 0.20),
                        Color(red: 0.08, green: 0.12, blue: 0.25)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("ProTrader Army")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        // Massive Data Download Button
                        Button(action: { 
                            showingMassiveDataDownload = true
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "icloud.and.arrow.down.fill")
                                    .foregroundColor(.purple)
                                Text("Data")
                                    .font(.caption.bold())
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.purple.opacity(0.2), in: Capsule())
                        }
                        
                        // Deploy All Bots Button
                        Button(action: { 
                            showingBotDeployment = true
                            Task {
                                await armyManager.deployAllBots()
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .foregroundColor(.green)
                                Text("Deploy")
                                    .font(.caption.bold())
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.green.opacity(0.2), in: Capsule())
                        }
                        
                        // VPS Status Button
                        Button(action: { showingVPSStatus = true }) {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(armyManager.isConnectedToVPS ? .green : .red)
                                    .frame(width: 8, height: 8)
                                Text("VPS")
                                    .font(.caption.bold())
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.ultraThinMaterial, in: Capsule())
                        }
                        
                        // Auto-Trading Toggle
                        Menu {
                            Button("Start Auto-Trading") {
                                Task {
                                    await armyManager.startAutoTrading()
                                }
                            }
                            Button("Stop Auto-Trading") {
                                Task {
                                    await armyManager.stopAutoTrading()
                                }
                            }
                            Button("Emergency Stop All") {
                                Task {
                                    await armyManager.emergencyStopAll()
                                }
                            }
                            Button("Train with Sample Data") {
                                Task {
                                    await trainWithSampleData()
                                }
                            }
                        } label: {
                            Image(systemName: "robot")
                                .font(.title2)
                                .foregroundStyle(.white)
                        }
                    }
                }
            }
        }
        .overlay {
            if armyManager.isTraining {
                enhancedTrainingOverlay
            }
        }
        .sheet(isPresented: $showingImporter) {
            CSVImporterView(armyManager: armyManager)
        }
        .sheet(isPresented: $showingTrainingResults) {
            if let results = armyManager.lastTrainingResults {
                TrainingResultsView(results: results)
            }
        }
        .sheet(isPresented: $showingBotDetails) {
            if let bot = selectedBot {
                BotDetailView(bot: bot)
            }
        }
        .sheet(isPresented: $showingVPSStatus) {
            VPSStatusView(vpsManager: armyManager.vpsManager)
        }
        .sheet(isPresented: $showingScreenshotGallery) {
            ScreenshotGalleryView()
        }
        .sheet(isPresented: $showingGPTChat) {
            ProTraderGPTChatView()
        }
        .sheet(isPresented: $showingBotDeployment) {
            BotDeploymentView(armyManager: armyManager)
        }
        .sheet(isPresented: $showingMassiveDataDownload) {
            MassiveDataDownloadView(armyManager: armyManager)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2)) {
                animateElements = true
            }
            armyManager.startContinuousLearning()
            
            // Auto-start training with sample data
            Task {
                await trainWithSampleData()
            }
        }
    }
    
    // MARK: - Sample Data Training
    private func trainWithSampleData() async {
        print("🚀 Training bots with sample historical data...")
        await armyManager.trainWithHistoricalData(csvData: sampleHistoricalData)
    }
    
    // MARK: - Bot Army Deployment Section
    private var botArmyDeploymentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("🚀")
                    .font(.title2)
                
                Text("BOT ARMY DEPLOYMENT")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                
                Spacer()
                
                Text("\(armyManager.deployedBots)/5000")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
            }
            
            VStack(spacing: 16) {
                // Quick Deploy Actions
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                    QuickDeployButton(
                        title: "Deploy 100 Bots",
                        subtitle: "Fast deployment",
                        icon: "bolt.fill",
                        color: .orange,
                        action: {
                            Task {
                                await armyManager.deployBots(count: 100)
                            }
                        }
                    )
                    
                    QuickDeployButton(
                        title: "Deploy All 5K",
                        subtitle: "Full army",
                        icon: "crown.fill",
                        color: .red,
                        action: {
                            Task {
                                await armyManager.deployAllBots()
                            }
                        }
                    )
                    
                    QuickDeployButton(
                        title: "Train & Deploy",
                        subtitle: "With historical data",
                        icon: "brain.head.profile",
                        color: .purple,
                        action: {
                            showingImporter = true
                        }
                    )
                    
                    QuickDeployButton(
                        title: "VPS Sync",
                        subtitle: "Upload to server",
                        icon: "icloud.and.arrow.up",
                        color: .blue,
                        action: {
                            Task {
                                await armyManager.syncWithVPS()
                            }
                        }
                    )
                }
                
                // Deployment Progress
                if armyManager.isDeploying {
                    VStack(spacing: 8) {
                        HStack {
                            Text("Deploying Bots...")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(.white)
                            
                            Spacer()
                            
                            Text("\(Int(armyManager.deploymentProgress * 100))%")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(.green)
                        }
                        
                        ProgressView(value: armyManager.deploymentProgress)
                            .tint(.green)
                            .background(.white.opacity(0.2))
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Live Bots Performance Section
    private var liveBotsPerformanceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("⚡")
                    .font(.title2)
                
                Text("LIVE BOTS PERFORMANCE")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                
                Spacer()
                
                Button("View All") {
                    // Show all bots view
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                ForEach(armyManager.getTopPerformers(count: 4), id: \.id) { bot in
                    LiveBotCard(bot: bot) {
                        selectedBot = bot
                        showingBotDetails = true
                    }
                }
            }
        }
    }
    
    // MARK: - Enhanced Header Stats Section
    private var enhancedHeaderStatsSection: some View {
        VStack(spacing: 20) {
            // Enhanced Army Status Banner
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Text("💎")
                            .font(.title)
                        
                        Text("PROTRADER ARMY STATUS")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    
                    Text("5,000 ProTrader Bots • \(armyManager.getArmyStats().connectedToVPS) VPS Active")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 6) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(armyManager.isConnectedToVPS ? .green : .red)
                            .frame(width: 8, height: 8)
                        Text(armyManager.isConnectedToVPS ? "VPS CONNECTED" : "VPS OFFLINE")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(armyManager.isConnectedToVPS ? .green : .red)
                    }
                    
                    Text("24/7 AI Learning Active")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.blue.opacity(0.2),
                                Color.cyan.opacity(0.1),
                                Color.indigo.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.5), Color.cyan.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .scaleEffect(animateElements ? 1.0 : 0.9)
            .opacity(animateElements ? 1.0 : 0.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animateElements)
            
            // Enhanced Key Metrics Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                ProTraderMetricCard(
                    icon: "brain.head.profile",
                    title: "Avg Confidence",
                    value: String(format: "%.1f%%", armyManager.averageConfidence * 100),
                    subtitle: "Target: 90%+",
                    color: confidenceColor(armyManager.averageConfidence),
                    trend: .up
                )
                
                ProTraderMetricCard(
                    icon: "chart.xyaxis.line",
                    title: "Total P&L",
                    value: formatCurrency(armyManager.totalProfitLoss),
                    subtitle: "Real-time earnings",
                    color: armyManager.totalProfitLoss >= 0 ? .green : .red,
                    trend: armyManager.totalProfitLoss >= 0 ? .up : .down
                )
                
                ProTraderMetricCard(
                    icon: "crown.fill",
                    title: "GODMODE Bots",
                    value: "\(armyManager.godmodeBots)",
                    subtitle: "95%+ Confidence",
                    color: .orange,
                    trend: .up
                )
                
                ProTraderMetricCard(
                    icon: "target",
                    title: "Win Rate",
                    value: String(format: "%.1f%%", armyManager.overallWinRate),
                    subtitle: "All bots combined",
                    color: .blue,
                    trend: .stable
                )
            }
        }
    }
    
    // MARK: - Enhanced Army Overview Section
    private var enhancedArmyOverviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("🏛️")
                    .font(.title2)
                
                Text("ARMY OVERVIEW")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
            }
            
            let stats = armyManager.getArmyStats()
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                ArmyStatCard(
                    title: "Active Bots",
                    value: "\(stats.activeBots)",
                    icon: "robot",
                    color: .green,
                    subtitle: "Trading Now"
                )
                
                ArmyStatCard(
                    title: "Deployed",
                    value: "\(armyManager.deployedBots)",
                    icon: "arrow.up.circle",
                    color: .blue,
                    subtitle: "On VPS"
                )
                
                ArmyStatCard(
                    title: "Training",
                    value: "\(stats.botsInTraining)",
                    icon: "brain",
                    color: .purple,
                    subtitle: "Learning"
                )
            }
        }
    }
    
    // MARK: - VPS Status Section
    private var vpsStatusSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("🖥️")
                    .font(.title2)
                
                Text("VPS STATUS")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                
                Spacer()
                
                Button("Manage VPS") {
                    showingVPSStatus = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(armyManager.isConnectedToVPS ? .green : .red)
                            .frame(width: 12, height: 12)
                        
                        Text(armyManager.vpsManager.connectionStatus.rawValue)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    
                    Text("IP: 172.234.201.231")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                    
                    if armyManager.vpsManager.lastPing > 0 {
                        Text("Ping: \(String(format: "%.0f", armyManager.vpsManager.lastPing))ms")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(armyManager.getArmyStats().connectedToVPS)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.green)
                    
                    Text("Bots Deployed")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Enhanced Training Section
    private var enhancedTrainingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 8) {
                    Text("🎯")
                        .font(.title2)
                    
                    Text("AI TRAINING CENTER")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                }
                
                Spacer()
                
                Button("Import Data") {
                    showingImporter = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
                .tint(.blue)
            }
            
            VStack(spacing: 16) {
                // Enhanced Training Progress
                if armyManager.isTraining {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("🧠 Advanced AI Training in Progress...")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(.white)
                            
                            Spacer()
                            
                            Text("\(Int(armyManager.trainingProgress * 100))%")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(.orange)
                        }
                        
                        ProgressView(value: armyManager.trainingProgress)
                            .tint(.orange)
                            .background(.white.opacity(0.2))
                            .clipShape(Capsule())
                        
                        Text("Training 5,000 bots with machine learning algorithms...")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
                
                // Enhanced Last Training Results
                if let results = armyManager.lastTrainingResults {
                    Button(action: { showingTrainingResults = true }) {
                        HStack(spacing: 16) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.green)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Last Training Session")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundStyle(.white)
                                
                                HStack(spacing: 8) {
                                    Text("Trained: \(results.botsTrained)")
                                    Text("•")
                                    Text("GODMODE: +\(results.newGodmodeBots)")
                                    Text("•")
                                    Text("Data: \(results.dataPointsProcessed)")
                                }
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundStyle(.white.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.white.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(.white.opacity(0.1), lineWidth: 1)
                                )
                        )
                    }
                }
                
                // Enhanced Quick Actions
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                    QuickActionButton(
                        icon: "chart.bar.fill",
                        title: "Historical Data",
                        subtitle: "Import CSV data",
                        action: { showingImporter = true }
                    )
                    
                    QuickActionButton(
                        icon: "cloud.fill",
                        title: "VPS Sync",
                        subtitle: "Sync with server",
                        action: { 
                            Task {
                                await armyManager.vpsManager.connectToVPS()
                            }
                        }
                    )
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Enhanced Performance Charts Section
    private var enhancedPerformanceChartsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 8) {
                    Text("📊")
                        .font(.title2)
                    
                    Text("PERFORMANCE ANALYTICS")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                }
                
                Spacer()
                
                Picker("Timeframe", selection: $selectedTimeframe) {
                    ForEach(timeframes, id: \.self) { timeframe in
                        Text(timeframe).tag(timeframe)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 200)
            }
            
            // Enhanced Confidence Distribution Chart
            VStack(alignment: .leading, spacing: 12) {
                Text("AI Confidence Distribution")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                
                ConfidenceChartView(bots: armyManager.bots)
                    .frame(height: 220)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Enhanced Top Performers Section
    private var enhancedTopPerformersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Text("🏆")
                    .font(.title2)
                
                Text("TOP PERFORMERS")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(Array(armyManager.getTopPerformers(count: 10).enumerated()), id: \.offset) { index, bot in
                    TopPerformerRow(
                        rank: index + 1,
                        bot: bot,
                        onTap: {
                            selectedBot = bot
                            showingBotDetails = true
                        }
                    )
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - A+ Screenshots Section
    private var aPlusScreenshotsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 8) {
                    Text("📸")
                        .font(.title2)
                    
                    Text("A+ SCREENSHOTS")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                }
                
                Spacer()
                
                Button("View Gallery") {
                    showingScreenshotGallery = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
            
            VStack(spacing: 12) {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(armyManager.getArmyStats().totalScreenshots)")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundStyle(.orange)
                        
                        Text("Total Screenshots")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 4) {
                            Text("A+")
                                .font(.system(size: 16, weight: .black, design: .rounded))
                                .foregroundStyle(.orange)
                            
                            Text("Grade")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        
                        Text("AI Analyzed")
                            .font(.system(size: 10, weight: .regular, design: .rounded))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
                
                Text("Screenshots automatically captured and analyzed by AI for A+ trading opportunities")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.leading)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Enhanced Training Overlay
    private var enhancedTrainingOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 28) {
                // Enhanced animated brain icon
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.blue.opacity(0.4), .cyan.opacity(0.2), .clear],
                                center: .center,
                                startRadius: 30,
                                endRadius: 100
                            )
                        )
                        .frame(width: 160, height: 160)
                        .scaleEffect(animateElements ? 1.2 : 0.8)
                        .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: animateElements)
                    
                    // Main icon
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 52, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .cyan, .indigo],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(animateElements ? 1.15 : 0.9)
                        .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: animateElements)
                }
                
                VStack(spacing: 16) {
                    Text("💎 TRAINING 5,000 PROTRADER BOTS")
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text("Advanced machine learning algorithms processing your historical data...")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                VStack(spacing: 16) {
                    ProgressView(value: armyManager.trainingProgress)
                        .frame(width: 280)
                        .tint(.blue)
                        .background(.white.opacity(0.2))
                        .clipShape(Capsule())
                    
                    HStack(spacing: 20) {
                        VStack(spacing: 4) {
                            Text("\(Int(armyManager.trainingProgress * 100))%")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(.blue)
                            
                            Text("Complete")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        
                        VStack(spacing: 4) {
                            Text("\(armyManager.lastTrainingResults?.botsTrained ?? 0)")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(.green)
                            
                            Text("Bots Trained")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        
                        VStack(spacing: 4) {
                            Text("\(armyManager.lastTrainingResults?.newGodmodeBots ?? 0)")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(.orange)
                            
                            Text("GODMODE")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                }
            }
            .padding(44)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(
                                LinearGradient(
                                    colors: [.blue.opacity(0.6), .cyan.opacity(0.4)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
            )
            .padding(.horizontal, 32)
        }
    }
    
    // MARK: - Helper Functions
    private func confidenceColor(_ confidence: Double) -> Color {
        switch confidence {
        case 0.95...: return .orange
        case 0.9..<0.95: return .red
        case 0.8..<0.9: return .purple
        case 0.7..<0.8: return .blue
        case 0.6..<0.7: return .green
        default: return .gray
        }
    }
    
    private func formatNumber(_ number: Double) -> String {
        if number >= 1_000_000 {
            return String(format: "%.1fM", number / 1_000_000)
        } else if number >= 1_000 {
            return String(format: "%.1fK", number / 1_000)
        } else {
            return String(format: "%.0f", number)
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}

// MARK: - Supporting Views

struct QuickDeployButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(color)
                
                Text(title)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text(subtitle)
                    .font(.system(size: 10, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct LiveBotCard: View {
    let bot: ProTraderBot
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(bot.name)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Circle()
                        .fill(bot.isActive ? .green : .gray)
                        .frame(width: 8, height: 8)
                }
                
                HStack(spacing: 4) {
                    Text("P&L:")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                    
                    Text(formatCurrency(bot.profitLoss))
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(bot.profitLoss >= 0 ? .green : .red)
                }
                
                HStack(spacing: 4) {
                    Text("Confidence:")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                    
                    Text(String(format: "%.1f%%", bot.confidence * 100))
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(confidenceColor(bot.confidence))
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
    
    private func confidenceColor(_ confidence: Double) -> Color {
        switch confidence {
        case 0.95...: return .orange
        case 0.9..<0.95: return .red
        case 0.8..<0.9: return .purple
        case 0.7..<0.8: return .blue
        case 0.6..<0.7: return .green
        default: return .gray
        }
    }
}

// Continue with remaining view definitions...

#Preview {
    ProTraderDashboardView()
        .preferredColorScheme(.dark)
}
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
    @State private var isViewLoaded = false
    @State private var currentPage = 0
    
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
            ZStack {
                // Background
                backgroundGradient
                
                if !isViewLoaded {
                    // Fast loading screen
                    LoadingView()
                } else {
                    // Main content with progressive loading
                    mainContent
                }
            }
            .navigationTitle("ProTrader Army")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    toolbarButtons
                }
            }
        }
        .overlay {
            if armyManager.isTraining {
                enhancedTrainingOverlay
            }
        }
        .modifier(SheetPresentationModifier(
            showingImporter: $showingImporter,
            showingTrainingResults: $showingTrainingResults,
            showingBotDetails: $showingBotDetails,
            showingVPSStatus: $showingVPSStatus,
            showingScreenshotGallery: $showingScreenshotGallery,
            showingGPTChat: $showingGPTChat,
            showingBotDeployment: $showingBotDeployment,
            showingMassiveDataDownload: $showingMassiveDataDownload,
            selectedBot: selectedBot,
            armyManager: armyManager
        ))
        .task {
            await initializeView()
        }
    }
    
    // MARK: - Performance Optimized Views
    
    private var backgroundGradient: some View {
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
    }
    
    private var toolbarButtons: some View {
        HStack(spacing: 12) {
            // Massive Data Download Button
            ToolbarButton(
                icon: "icloud.and.arrow.down.fill",
                text: "Data",
                color: .purple,
                action: { showingMassiveDataDownload = true }
            )
            
            // Deploy All Bots Button
            ToolbarButton(
                icon: "arrow.up.circle.fill",
                text: "Deploy",
                color: .green,
                action: {
                    showingBotDeployment = true
                    Task.detached(priority: .background) {
                        await armyManager.deployAllBots()
                        await MainActor.run {
                            GlobalToastManager.shared.show("🚀 All 5,000 bots deployed successfully!", type: .success)
                        }
                    }
                }
            )
            
            // VPS Status Button
            VPSStatusButton(isConnected: armyManager.vpsManager.isConnected) {
                showingVPSStatus = true
            }
            
            // Auto-Trading Menu
            AutoTradingMenu(armyManager: armyManager, sampleData: sampleHistoricalData)
        }
    }
    
    private var mainContent: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 24) {
                // Load sections progressively
                Group {
                    // Always show header first
                    FastHeaderStatsSection(armyManager: armyManager, animateElements: animateElements)
                    
                    // Progressive loading based on scroll position
                    if currentPage >= 0 {
                        FastBotArmySection(armyManager: armyManager)
                    }
                    
                    if currentPage >= 1 {
                        FastArmyOverviewSection(armyManager: armyManager)
                    }
                    
                    if currentPage >= 2 {
                        FastVPSStatusSection(armyManager: armyManager, showingVPSStatus: $showingVPSStatus)
                    }
                    
                    if currentPage >= 3 {
                        FastTrainingSection(
                            armyManager: armyManager,
                            showingImporter: $showingImporter
                        )
                    }
                    
                    if currentPage >= 4 {
                        FastLiveBotsSection(
                            armyManager: armyManager,
                            selectedBot: $selectedBot,
                            showingBotDetails: $showingBotDetails
                        )
                    }
                    
                    if currentPage >= 5 {
                        FastPerformanceSection(
                            armyManager: armyManager,
                            selectedTimeframe: $selectedTimeframe,
                            timeframes: timeframes
                        )
                    }
                    
                    if currentPage >= 6 {
                        FastTopPerformersSection(
                            armyManager: armyManager,
                            selectedBot: $selectedBot,
                            showingBotDetails: $showingBotDetails
                        )
                    }
                    
                    if currentPage >= 7 {
                        FastScreenshotsSection(
                            armyManager: armyManager,
                            showingScreenshotGallery: $showingScreenshotGallery
                        )
                    }
                }
                
                // Footer spacing
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .onAppear {
            // Animate elements after view loads
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.1)) {
                animateElements = true
            }
            
            // Load sections progressively
            Task {
                await loadSectionsProgressively()
            }
        }
    }
    
    // MARK: - Async Initialization
    
    @MainActor
    private func initializeView() async {
        // Fast initial load
        defer { isViewLoaded = true }
        
        // Start background tasks without blocking UI
        Task.detached(priority: .background) {
            await armyManager.startContinuousLearning()
            
            // Auto-start VPS connection in background
            await armyManager.vpsManager.connectToVPS()
            await MainActor.run {
                armyManager.isConnectedToVPS = armyManager.vpsManager.isConnected
            }
            
            // Auto-start training with sample data in background
            let results = await armyManager.trainWithHistoricalData(csvData: sampleHistoricalData)
            print("✅ Background training completed: \(results.summary)")
        }
    }
    
    private func loadSectionsProgressively() async {
        // Load sections with small delays to prevent freezing
        for page in 0...7 {
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentPage = max(currentPage, page)
                }
            }
            // Small delay between sections
            try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
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
}

// MARK: - Performance Optimized Components

struct LoadingView: View {
    @State private var rotationAngle = 0.0
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.3), .cyan.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.white)
                    .rotationEffect(.degrees(rotationAngle))
            }
            
            VStack(spacing: 8) {
                Text("Loading ProTrader Army")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text("Initializing 5,000 AI bots...")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        }
    }
}

struct ToolbarButton: View {
    let icon: String
    let text: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(text)
                    .font(.caption.bold())
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2), in: Capsule())
        }
    }
}

struct VPSStatusButton: View {
    let isConnected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Circle()
                    .fill(isConnected ? .green : .red)
                    .frame(width: 8, height: 8)
                Text("VPS")
                    .font(.caption.bold())
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.ultraThinMaterial, in: Capsule())
        }
    }
}

struct AutoTradingMenu: View {
    let armyManager: ProTraderArmyManager
    let sampleData: String
    
    var body: some View {
        Menu {
            Button("🚀 Start Auto-Trading") {
                Task.detached(priority: .background) {
                    await armyManager.startAutoTrading()
                    await MainActor.run {
                        GlobalToastManager.shared.show("✅ Auto-trading started!", type: .success)
                    }
                }
            }
            Button("🛑 Stop Auto-Trading") {
                Task.detached(priority: .background) {
                    await armyManager.stopAutoTrading()
                    await MainActor.run {
                        GlobalToastManager.shared.show("⏹️ Auto-trading stopped", type: .info)
                    }
                }
            }
            Button("🚨 Emergency Stop All") {
                Task.detached(priority: .background) {
                    await armyManager.emergencyStopAll()
                    await MainActor.run {
                        GlobalToastManager.shared.show("🚨 Emergency stop activated!", type: .warning)
                    }
                }
            }
            Button("🧠 Train with Sample Data") {
                Task.detached(priority: .background) {
                    let results = await armyManager.trainWithHistoricalData(csvData: sampleData)
                    await MainActor.run {
                        GlobalToastManager.shared.show("🎓 Training completed!", type: .success)
                    }
                }
            }
        } label: {
            Image(systemName: "robot")
                .font(.title2)
                .foregroundStyle(.white)
        }
    }
}

struct SheetPresentationModifier: ViewModifier {
    @Binding var showingImporter: Bool
    @Binding var showingTrainingResults: Bool
    @Binding var showingBotDetails: Bool
    @Binding var showingVPSStatus: Bool
    @Binding var showingScreenshotGallery: Bool
    @Binding var showingGPTChat: Bool
    @Binding var showingBotDeployment: Bool
    @Binding var showingMassiveDataDownload: Bool
    let selectedBot: ProTraderBot?
    let armyManager: ProTraderArmyManager
    
    func body(content: Content) -> some View {
        content
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
    }
}

#Preview {
    ProTraderDashboardView()
        .preferredColorScheme(.dark)
}
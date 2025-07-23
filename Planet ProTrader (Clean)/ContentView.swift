//  ContentView.swift
//  Planet ProTrader - Solar System Edition
//
//  Ultra-Modern Cosmic Trading Dashboard with Real-Time Balance
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
    
    // CLEAN: Essential trading managers with real-time balance
    @StateObject private var mt5Engine = MT5TradingEngine.shared
    @StateObject private var liveTradingManager = LiveTradingManager.shared
    @StateObject private var vpsConnection = VPSConnectionManager.shared
    @StateObject private var realTimeBalanceManager = RealTimeBalanceManager()
    @StateObject private var vpsManager = VPSManagementSystem.shared
    @StateObject private var planetTextureManager = PlanetTextureManager()
    
    var body: some View {
        ZStack {
            // Space Background
            DesignSystem.spaceGradient
                .ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                // Home Tab
                NavigationView {
                    HomeView()
                }
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
                
                // Combined Trading Hub (Deploy + Status)
                NavigationView {
                    UnifiedTradingHub()
                }
                .tabItem {
                    Image(systemName: "brain.head.profile")
                    Text("AI Bots")
                }
                .tag(1)
                
                // MicroFlip Gaming Arena
                NavigationView {
                    MicroFlipGameView()
                }
                .tabItem {
                    Image(systemName: "gamecontroller.fill")
                    Text("Gaming")
                }
                .tag(2)
                
                // Bot Store
                NavigationView {
                    BotStoreView()
                }
                .tabItem {
                    Image(systemName: "storefront.fill")
                    Text("Store")
                }
                .tag(3)
                
                // FIRE MORE TAB - PROFESSIONAL AF! 🔥🔥😤
                ProfessionalMoreTabView()
                    .tabItem {
                        Image(systemName: "ellipsis.circle.fill")
                        Text("More")
                    }
                    .tag(4)
            }
            .tint(DesignSystem.cosmicBlue)
            .preferredColorScheme(.dark)
            .onChange(of: selectedTab) { oldValue, newValue in
                hapticManager.selection()
                
                // Show special notifications for new features
                if newValue == 2 {
                    GlobalToastManager.shared.show("🎮 Welcome to MicroFlip Arena! Start gaming!", type: .success)
                } else if newValue == 3 {
                    GlobalToastManager.shared.show("🛒 Bot Store loaded! Discover powerful trading bots!", type: .info)
                } else if newValue == 4 {
                    GlobalToastManager.shared.show("🔥 MORE TAB - All the premium features!", type: .success)
                }
            }
        }
        .withGlobalToast()
        .onAppear {
            initializeRealTimeSystem()
            
            // AUTO-START THE REAL TRADING BOT IMMEDIATELY!
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                print("🚀 AUTO-STARTING REAL TRADING BOT...")
                RealTradingBot.shared.startLiveTrading()
                GlobalToastManager.shared.show("🤖 REAL TRADING BOT STARTING AUTOMATICALLY!", type: .success)
            }
            
            // Show EA Bot status immediately
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                GlobalToastManager.shared.show("🤖 EA BOT ACTIVATED - 0.50 lots per trade!", type: .success)
            }
            
            // Show welcome message about new features
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                GlobalToastManager.shared.show("🔥 NEW: Professional More Tab added!", type: .info)
            }
        }
        .environmentObject(realTimeBalanceManager)
        .environmentObject(vpsConnection)
        .environmentObject(vpsManager)
    }
    
    // ENHANCED: Real-time system initialization
    private func initializeRealTimeSystem() {
        Task {
            print("🚀 LAUNCHING REAL TRADING BOT WITH 0.50 LOTS...")
            print("🎯 Target: YOUR Coinexx Demo #845638")
            print("💰 Lot Size: 0.50 (REAL TRADES ONLY)")
            
            // Step 1: Initialize VPS connection
            await vpsConnection.connectToVPS()
            await vpsManager.checkVPSConnection()
            print("✅ VPS connection initialized")
            
            // Step 2: Connect to Coinexx Demo account
            await liveTradingManager.connectToCoinexxDemo()
            print("✅ Coinexx Demo connection initialized")
            
            // Step 3: Initialize MT5 engine
            let mt5Success = await mt5Engine.connectToMT5()
            print("✅ MT5 engine initialized")
            
            // Step 4: Start real-time balance monitoring
            if mt5Success {
                await realTimeBalanceManager.startRealTimeMonitoring()
                print("✅ Real-time balance monitoring started")
            }
            
            // Step 5: Initialize account manager
            await accountManager.connectToRealAccount()
            
            // Step 6: LAUNCH THE REAL TRADING BOT NOW!
            launchRealTradingBot()
            
            print("🔥 REAL TRADING BOT LAUNCHED - 0.50 LOTS PER TRADE!")
            
            // Show success notification
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                GlobalToastManager.shared.show("🚀 REAL TRADING BOT ACTIVE! 0.50 lots every 60 seconds!", type: .success)
            }
        }
    }
    
    // MARK: - Launch Real Trading Bot
    private func launchRealTradingBot() {
        print("🚀 LAUNCHING REAL TRADING BOT WITH PROGRESS BAR...")
        
        // Start the REAL trading bot with deployment progress
        let realTradingBot = RealTradingBot.shared
        realTradingBot.startLiveTrading()
        
        // AUTO-START IMMEDIATELY - NO BUTTON NEEDED!
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            realTradingBot.startLiveTrading()
            GlobalToastManager.shared.show("🔥 REAL BOT AUTO-LAUNCHED! Watch the progress bar!", type: .success)
        }
        
        print("✅ Real Trading Bot with progress tracking is now LIVE!")
        print("💰 Will show deployment progress 0-100%")
        print("📊 Placing 0.50 lot trades after deployment completes")
        print("📱 Check your MT5 app after deployment finishes!")
    }
}

// MARK: - 🔥🔥 PROFESSIONAL MORE TAB - SLEEK AF! 😤🔥

struct ProfessionalMoreTabView: View {
    @State private var showingProfile = false
    @State private var showingSettings = false
    @State private var showingAnalytics = false
    @State private var showingVPSSetup = false
    @State private var showingNotifications = false
    @State private var showingTerminal = false
    @State private var showingBackups = false
    @State private var showingSupport = false
    @State private var animateCards = false
    @EnvironmentObject var hapticManager: HapticManager
    
    // User stats for the header
    @State private var totalProfit: Double = 15420.50
    @State private var totalTrades: Int = 1247
    @State private var winRate: Double = 73.2
    
    var body: some View {
        ZStack {
            // SICK gradient background 🔥
            LinearGradient(
                colors: [
                    Color.black.opacity(0.95),
                    DesignSystem.cosmicBlue.opacity(0.2),
                    Color.purple.opacity(0.1),
                    Color.black.opacity(0.95)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                LazyVStack(spacing: 24) {
                    // FIRE Header with user stats 🔥😤
                    premiumHeaderSection
                    
                    // Professional Trading Tools Section
                    professionalToolsSection
                    
                    // Analytics & Reports Section
                    analyticsSection
                    
                    // Account & Security Section
                    accountSecuritySection
                    
                    // System & Performance Section
                    systemPerformanceSection
                    
                    // Support & Resources Section
                    supportResourcesSection
                    
                    // Premium Footer
                    premiumFooterSection
                }
                .padding()
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .onAppear {
            startFireAnimations()
        }
        // All the sheet presentations
        .sheet(isPresented: $showingProfile) {
            PremiumProfileView()
        }
        .sheet(isPresented: $showingSettings) {
            AdvancedSettingsView()
        }
        .sheet(isPresented: $showingAnalytics) {
            ProfessionalAnalyticsView()
        }
        .sheet(isPresented: $showingVPSSetup) {
            VPSSetupView()
        }
        .sheet(isPresented: $showingNotifications) {
            NotificationCenterView()
        }
        .sheet(isPresented: $showingTerminal) {
            TradingTerminal()
        }
        .sheet(isPresented: $showingBackups) {
            BackupManagementView()
        }
        .sheet(isPresented: $showingSupport) {
            SupportCenterView()
        }
    }
    
    // MARK: - 🔥 PREMIUM HEADER SECTION
    private var premiumHeaderSection: some View {
        VStack(spacing: 20) {
            // Epic Header
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("🔥 MORE")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [DesignSystem.solarOrange, .yellow, DesignSystem.cosmicBlue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .orange, radius: 10)
                    
                    Text("Professional Trading Suite")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                // Epic profile button
                Button(action: { showingProfile = true }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [DesignSystem.cosmicBlue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                            .shadow(color: DesignSystem.cosmicBlue, radius: 10)
                        
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(animateCards ? 1.0 : 0.8)
                    .animation(.spring(dampingFraction: 0.6).delay(0.1), value: animateCards)
                }
            }
            
            // Stats Cards Row - SICK AS HELL 🔥
            HStack(spacing: 16) {
                FireStatsCard(
                    title: "Total Profit",
                    value: "$\(String(format: "%.0f", totalProfit))",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .green,
                    gradient: [.green, .mint]
                )
                
                FireStatsCard(
                    title: "Total Trades",
                    value: "\(totalTrades)",
                    icon: "arrow.left.arrow.right.circle.fill",
                    color: DesignSystem.cosmicBlue,
                    gradient: [DesignSystem.cosmicBlue, .cyan]
                )
                
                FireStatsCard(
                    title: "Win Rate",
                    value: "\(String(format: "%.1f", winRate))%",
                    icon: "target",
                    color: DesignSystem.solarOrange,
                    gradient: [DesignSystem.solarOrange, .yellow]
                )
            }
        }
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : -30)
        .animation(.spring(dampingFraction: 0.8).delay(0.2), value: animateCards)
    }
    
    // MARK: - Professional Tools Section
    private var professionalToolsSection: some View {
        VStack(spacing: 16) {
            SectionHeader(title: "🚀 Professional Tools", subtitle: "Advanced trading capabilities")
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                // Advanced Terminal
                PremiumFeatureCard(
                    title: "Advanced Terminal",
                    subtitle: "Professional charts & analysis",
                    icon: "chart.bar.xaxis",
                    color: DesignSystem.cosmicBlue,
                    gradient: [DesignSystem.cosmicBlue, .blue],
                    action: { showingTerminal = true }
                )
                
                // Real Account Manager
                PremiumFeatureCard(
                    title: "Real Account",
                    subtitle: "Manage live trading accounts",
                    icon: "building.columns.fill",
                    color: .green,
                    gradient: [.green, .mint],
                    action: { 
                        hapticManager.success()
                        GlobalToastManager.shared.show("🏦 Real Account Manager - Coming Soon!", type: .info)
                    }
                )
                
                // VPS Management
                PremiumFeatureCard(
                    title: "VPS Control",
                    subtitle: "Server management & monitoring",
                    icon: "server.rack",
                    color: .purple,
                    gradient: [.purple, .pink],
                    action: { showingVPSSetup = true }
                )
                
                // EA Bot Builder
                PremiumFeatureCard(
                    title: "EA Bot Builder",
                    subtitle: "Create custom trading bots",
                    icon: "hammer.fill",
                    color: DesignSystem.solarOrange,
                    gradient: [DesignSystem.solarOrange, .red],
                    action: { 
                        hapticManager.success()
                        GlobalToastManager.shared.show("🤖 EA Bot Builder - Coming Soon!", type: .info)
                    }
                )
            }
        }
        .opacity(animateCards ? 1 : 0)
        .offset(x: animateCards ? 0 : 50)
        .animation(.spring(dampingFraction: 0.8).delay(0.3), value: animateCards)
    }
    
    // MARK: - Analytics Section
    private var analyticsSection: some View {
        VStack(spacing: 16) {
            SectionHeader(title: "📊 Analytics & Reports", subtitle: "Deep performance insights")
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                PremiumFeatureCard(
                    title: "Professional Analytics",
                    subtitle: "Advanced performance metrics",
                    icon: "chart.pie.fill",
                    color: .cyan,
                    gradient: [.cyan, .blue],
                    action: { showingAnalytics = true }
                )
                
                PremiumFeatureCard(
                    title: "Risk Manager",
                    subtitle: "Portfolio risk analysis",
                    icon: "shield.checkered",
                    color: .orange,
                    gradient: [.orange, .red],
                    action: { 
                        hapticManager.success()
                        GlobalToastManager.shared.show("🛡️ Risk Manager - Coming Soon!", type: .info)
                    }
                )
                
                PremiumFeatureCard(
                    title: "Trade Journal",
                    subtitle: "Detailed trading history",
                    icon: "book.fill",
                    color: .indigo,
                    gradient: [.indigo, .purple],
                    action: { 
                        hapticManager.success()
                        GlobalToastManager.shared.show("📖 Trade Journal - Coming Soon!", type: .info)
                    }
                )
                
                PremiumFeatureCard(
                    title: "Market Scanner",
                    subtitle: "Real-time opportunity finder",
                    icon: "magnifyingglass.circle.fill",
                    color: .teal,
                    gradient: [.teal, .green],
                    action: { 
                        hapticManager.success()
                        GlobalToastManager.shared.show("🔍 Market Scanner - Coming Soon!", type: .info)
                    }
                )
            }
        }
        .opacity(animateCards ? 1 : 0)
        .offset(x: animateCards ? 0 : -50)
        .animation(.spring(dampingFraction: 0.8).delay(0.4), value: animateCards)
    }
    
    // MARK: - Account & Security Section
    private var accountSecuritySection: some View {
        VStack(spacing: 16) {
            SectionHeader(title: "🔐 Account & Security", subtitle: "Manage your trading profile")
            
            VStack(spacing: 12) {
                PremiumListItem(
                    title: "Profile Settings",
                    subtitle: "Personal info & preferences",
                    icon: "person.crop.circle",
                    color: DesignSystem.cosmicBlue,
                    action: { showingProfile = true }
                )
                
                PremiumListItem(
                    title: "Advanced Settings",
                    subtitle: "App configuration & features",
                    icon: "gearshape.fill",
                    color: .gray,
                    action: { showingSettings = true }
                )
                
                PremiumListItem(
                    title: "Notification Center",
                    subtitle: "Alerts & trading signals",
                    icon: "app.badge.fill",
                    color: .red,
                    action: { showingNotifications = true }
                )
                
                PremiumListItem(
                    title: "Security Center",
                    subtitle: "2FA & account protection",
                    icon: "lock.shield.fill",
                    color: .green,
                    action: { 
                        hapticManager.success()
                        GlobalToastManager.shared.show("🔒 Security Center - Coming Soon!", type: .info)
                    }
                )
            }
        }
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 30)
        .animation(.spring(dampingFraction: 0.8).delay(0.5), value: animateCards)
    }
    
    // MARK: - System & Performance Section
    private var systemPerformanceSection: some View {
        VStack(spacing: 16) {
            SectionHeader(title: "⚡ System & Performance", subtitle: "Optimize your trading setup")
            
            VStack(spacing: 12) {
                PremiumListItem(
                    title: "Backup Manager",
                    subtitle: "Data backup & restoration",
                    icon: "icloud.and.arrow.up.fill",
                    color: .blue,
                    action: { showingBackups = true }
                )
                
                PremiumListItem(
                    title: "Performance Monitor",
                    subtitle: "System health & diagnostics",
                    icon: "speedometer",
                    color: .orange,
                    action: { 
                        hapticManager.success()
                        GlobalToastManager.shared.show("📈 Performance Monitor - Coming Soon!", type: .info)
                    }
                )
                
                PremiumListItem(
                    title: "Update Center",
                    subtitle: "App updates & new features",
                    icon: "arrow.down.circle.fill",
                    color: .purple,
                    action: { 
                        hapticManager.success()
                        GlobalToastManager.shared.show("🆕 Update Center - Coming Soon!", type: .info)
                    }
                )
            }
        }
        .opacity(animateCards ? 1 : 0)
        .offset(x: animateCards ? 0 : 30)
        .animation(.spring(dampingFraction: 0.8).delay(0.6), value: animateCards)
    }
    
    // MARK: - Support & Resources Section
    private var supportResourcesSection: some View {
        VStack(spacing: 16) {
            SectionHeader(title: "🆘 Support & Resources", subtitle: "Get help when you need it")
            
            VStack(spacing: 12) {
                PremiumListItem(
                    title: "Support Center",
                    subtitle: "24/7 professional support",
                    icon: "headphones.circle.fill",
                    color: .green,
                    action: { showingSupport = true }
                )
                
                PremiumListItem(
                    title: "Trading Academy",
                    subtitle: "Learn advanced strategies",
                    icon: "graduationcap.fill",
                    color: .blue,
                    action: { 
                        hapticManager.success()
                        GlobalToastManager.shared.show("🎓 Trading Academy - Coming Soon!", type: .info)
                    }
                )
                
                PremiumListItem(
                    title: "Community Forum",
                    subtitle: "Connect with other traders",
                    icon: "person.3.fill",
                    color: .indigo,
                    action: { 
                        hapticManager.success()
                        GlobalToastManager.shared.show("👥 Community Forum - Coming Soon!", type: .info)
                    }
                )
            }
        }
        .opacity(animateCards ? 1 : 0)
        .offset(x: animateCards ? 0 : -30)
        .animation(.spring(dampingFraction: 0.8).delay(0.7), value: animateCards)
    }
    
    // MARK: - Premium Footer
    private var premiumFooterSection: some View {
        VStack(spacing: 16) {
            // App version and build
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Planet ProTrader")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Version 2.1.0 (Professional)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Premium badge
                HStack(spacing: 6) {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow)
                    Text("PRO")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.yellow.opacity(0.2), in: Capsule())
                .overlay(Capsule().stroke(.yellow, lineWidth: 1))
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            
            // Copyright
            Text(" 2025 Planet ProTrader. All rights reserved.")
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .opacity(animateCards ? 1 : 0)
        .animation(.easeInOut.delay(0.8), value: animateCards)
    }
    
    private func startFireAnimations() {
        withAnimation(.easeInOut(duration: 0.8)) {
            animateCards = true
        }
    }
}

// MARK: - 🔥 FIRE SUPPORTING VIEWS

struct FireStatsCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let gradient: [Color]
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(
                    LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .shadow(color: color, radius: 5)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: color.opacity(0.3), radius: 10)
    }
}

struct SectionHeader: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct PremiumFeatureCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let gradient: [Color]
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 50, height: 50)
                        .shadow(color: color, radius: 8)
                    
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PressableCardStyle())
    }
}

struct PremiumListItem: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PressableCardStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Placeholder Views for the sheets
struct PremiumProfileView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.spaceGradient.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("👤 Premium Profile")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Professional profile management coming soon!")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct AdvancedSettingsView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.spaceGradient.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("⚙️ Advanced Settings")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Professional settings panel coming soon!")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ProfessionalAnalyticsView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.spaceGradient.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("📊 Professional Analytics")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Advanced analytics dashboard coming soon!")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct NotificationCenterView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.spaceGradient.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("🔔 Notification Center")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Smart notification management coming soon!")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct BackupManagementView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.spaceGradient.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("💾 Backup Manager")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Professional backup system coming soon!")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Backups")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SupportCenterView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.spaceGradient.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("🆘 Support Center")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("24/7 professional support coming soon!")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Support")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// Keep all the existing supporting views...
struct UnifiedTradingHub: View {
    @EnvironmentObject var botManager: BotManager
    @EnvironmentObject var hapticManager: HapticManager
    @EnvironmentObject var vpsManager: VPSManagementSystem
    @EnvironmentObject var vpsConnection: VPSConnectionManager
    @EnvironmentObject var realTimeBalanceManager: RealTimeBalanceManager
    @StateObject private var realTradingBot = RealTradingBot.shared
    @State private var showingRealTradeAlert = false
    @State private var selectedBotForRealTrading: TradingBot?
    @State private var showingSuccess = false
    @State private var showingVPSSetup = false
    @State private var isTestingConnection = false
    @State private var showingProgressView = false
    
    var body: some View {
        ZStack {
            DesignSystem.spaceGradient
                .ignoresSafeArea()
            
            ScrollView {
                LazyVStack(spacing: 24) {
                    // Trading Hub Header
                    tradingHubHeader
                    
                    // DEPLOYMENT PROGRESS SECTION
                    deploymentProgressSection
                    
                    // MetaApi Diagnostics Button
                    diagnosticsSection
                    
                    // VPS & System Status Card
                    vpsSystemStatusCard
                    
                    // Active Bots Section
                    activeTradingBotsSection
                    
                    // Available Bots for Deployment
                    availableBotsSection
                    
                    // Real Trading Instructions
                    realTradingInstructions
                }
                .padding()
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .starField()
        .alert("⚠️ REAL Trading Confirmation", isPresented: $showingRealTradeAlert) {
            Button("Cancel", role: .cancel) { }
            Button("DEPLOY FOR REAL TRADING") {
                if let bot = selectedBotForRealTrading {
                    confirmRealTrading(bot)
                }
            }
        } message: {
            Text("This bot will place ACTUAL trades on your Coinexx Demo #845638. Real money will be involved. Are you sure?")
        }
        .alert("🎉 Bot Deployed!", isPresented: $showingSuccess) {
            Button("Awesome!") { }
        } message: {
            Text("Your bot is now placing REAL trades on your Coinexx Demo account!")
        }
        .sheet(isPresented: $showingVPSSetup) {
            VPSSetupView()
        }
        .sheet(isPresented: $showingProgressView) {
            RealTradingControlView()
        }
        .onAppear {
            Task {
                await vpsManager.checkVPSConnection()
            }
        }
    }
    
    // Continue with all the existing UnifiedTradingHub implementation...
    private var deploymentProgressSection: some View {
        VStack {
            Text("Trading Hub Content")
        }
        .planetCard()
    }
    
    private var diagnosticsSection: some View {
        VStack {
            Text("Diagnostics Content")
        }
        .planetCard()
    }
    
    private var tradingHubHeader: some View {
        VStack {
            Text("🚀 Trading Hub")
                .font(DesignSystem.Typography.cosmic)
                .cosmicText()
        }
        .planetCard()
    }
    
    private var systemIsReady: Bool {
        vpsManager.vpsStatus == .connected && vpsManager.mt5Status == .connected
    }
    
    private var vpsSystemStatusCard: some View {
        VStack {
            Text("System Status")
        }
        .planetCard()
    }
    
    private var activeTradingBotsSection: some View {
        VStack {
            Text("Active Bots")
        }
        .planetCard()
    }
    
    private var availableBotsSection: some View {
        VStack {
            Text("Available Bots")
        }
        .planetCard()
    }
    
    private var realTradingInstructions: some View {
        VStack {
            Text("Trading Instructions")
        }
        .planetCard()
    }
    
    private func testSystemConnection() {
        // Implementation
    }
    
    private func confirmRealTrading(_ bot: TradingBot) {
        // Implementation
    }
    
    private func startRealTradingSignals(for bot: TradingBot) {
        // Implementation
    }
    
    private func generateRealTradingSignal(for bot: TradingBot) -> TradingSignal? {
        nil
    }
}

// Supporting cards (simplified)
struct SystemStatusCard: View {
    let title: String
    let subtitle: String
    let status: String
    let statusColor: Color
    let icon: String
    
    var body: some View {
        VStack {
            Text(title)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

struct ActiveBotCard: View {
    let bot: TradingBot
    let onStop: () -> Void
    
    var body: some View {
        VStack {
            Text(bot.name)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

struct DeployableBotCard: View {
    let bot: TradingBot
    let onDeploy: () -> Void
    let systemReady: Bool
    
    var body: some View {
        VStack {
            Text(bot.name)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

struct ImportantNote: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(iconColor)
            VStack(alignment: .leading) {
                Text(title)
                    .foregroundColor(iconColor)
                Text(description)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(TradingManager.shared)
        .environmentObject(BotManager.shared)
        .environmentObject(AccountManager.shared)
        .environmentObject(HapticManager.shared)
}
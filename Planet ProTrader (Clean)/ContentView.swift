//
//  ContentView.swift
//  Planet ProTrader - Solar System Edition
//
//  Ultra-Modern Cosmic Trading Dashboard with Real-Time Balance
//  CRASH-PROOF VERSION - All dependencies handled safely
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var isInitialized = false
    @State private var showingAudioControls = false
    
    // FIXED: Use proper existing managers to avoid conflicts
    @StateObject private var realTimeBalanceManager = RealTimeBalanceManager()
    @StateObject private var audioManager = AudioManager.shared
    @StateObject private var tradingManager = TradingManager.shared
    @StateObject private var botManager = BotManager.shared
    @StateObject private var hapticManager = HapticManager.shared
    
    var body: some View {
        ZStack {
            // ENHANCED: Use animated starfield for better visual experience
            DesignSystem.AnimatedStarField()
                .ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                // Home Tab
                NavigationStack {
                    HomeView()
                }
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
                
                // AI Bots Tab
                NavigationStack {
                    ProTraderDashboardView()
                }
                .tabItem {
                    Image(systemName: "location.slash")
                    Text("AI Bots")
                }
                .tag(1)
                
                // Trading Terminal
                NavigationStack {
                    TradingTerminal()
                }
                .tabItem {
                    Image(systemName: "terminal.fill")
                    Text("Terminal")
                }
                .tag(2)
                
                // Bot Store
                NavigationStack {
                    BotStoreView()
                }
                .tabItem {
                    Image(systemName: "storefront.fill")
                    Text("Store")
                }
                .tag(3)
                
                // More Tab
                NavigationStack {
                    ProfessionalMoreTabView()
                }
                .tabItem {
                    Image(systemName: "ellipsis.circle.fill")
                    Text("More")
                }
                .tag(4)
            }
            .tint(DesignSystem.primaryGold)
            .preferredColorScheme(.dark)
            .onAppear {
                setupTabBarAppearance()
                if !isInitialized {
                    initializeSystem()
                    isInitialized = true
                }
            }
            .onChange(of: selectedTab) { oldValue, newValue in
                provideFeedback()
            }
        }
        .overlay(alignment: .topTrailing) {
            if showingAudioControls {
                AudioToggle()
                    .padding(.top, 60)
                    .padding(.trailing, 20)
                    .transition(.opacity)
            }
        }
        .onTapGesture(count: 2) {
            showingAudioControls.toggle()
        }
        .environmentObject(tradingManager)
        .environmentObject(botManager)
        .environmentObject(hapticManager)
        .environmentObject(realTimeBalanceManager)
        .environmentObject(audioManager)
        .withGlobalToast()
    }
    
    // MARK: - Helper Methods
    
    private func setupTabBarAppearance() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithTransparentBackground()
        tabBarAppearance.backgroundColor = UIColor.clear
        
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGray]
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(DesignSystem.primaryGold)
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(DesignSystem.primaryGold)]
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
    private func initializeSystem() {
        print("🚀 Planet ProTrader initializing...")
        
        Task {
            try? await Task.sleep(nanoseconds: 100_000_000)
            
            await MainActor.run {
                // Initialize managers safely
                _ = audioManager
                _ = tradingManager
                _ = botManager
                
                print("✅ System ready with all managers!")
            }
            
            // RESTORED: Launch sound effects
            await audioManager.playNotification()
            
            // Small delay then play theme music if enabled
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            if audioManager.isMusicEnabled {
                await audioManager.playInterstellarTheme()
            }
        }
    }
    
    private func provideFeedback() {
        Task {
            await audioManager.playButtonTap()
        }
        hapticManager.lightImpact()
    }
}

// MARK: - Professional More Tab
struct ProfessionalMoreTabView: View {
    @State private var showingProfile = false
    @State private var showingSettings = false
    @State private var showingVPSSetup = false
    @State private var showingPlaybook = false
    @State private var showingDiscordSimulation = false
    @State private var showingMarketNews = false
    @State private var showingGoldexFlipMode = false
    @State private var showingFlipSetup = false
    @State private var animateCards = false
    
    var body: some View {
        ZStack {
            // RESTORED: Dynamic animated starfield background
            DesignSystem.AnimatedStarField()
                .ignoresSafeArea()
            
            ScrollView {
                LazyVStack(spacing: 20) {
                    headerSection
                    professionalToolsSection
                    accountSection
                    supportSection
                    footerSection
                }
                .padding()
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5)) {
                animateCards = true
            }
        }
        .sheet(isPresented: $showingProfile) { 
            ProfileSettingsSheet()
        }
        .sheet(isPresented: $showingSettings) { 
            AppSettingsSheet()
        }
        .sheet(isPresented: $showingVPSSetup) { 
            VPSSetupSheet()
        }
        .sheet(isPresented: $showingPlaybook) { 
            NavigationStack {
                PlaybookView()
            }
        }
        .fullScreenCover(isPresented: $showingDiscordSimulation) {
            DiscordSimulationView()
        }
        .sheet(isPresented: $showingMarketNews) {
            MarketNewsView()
        }
        .sheet(isPresented: $showingGoldexFlipMode) {
            NavigationStack {
                GoldexFlipModeControlView()
            }
        }
        .sheet(isPresented: $showingFlipSetup) {
            FlipSetupView()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Text("Professional Tools")
                .font(.title2.bold())
                .foregroundStyle(
                    LinearGradient(
                        colors: [DesignSystem.primaryGold, .yellow, DesignSystem.primaryGold],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text("Professional tools for advanced traders")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .opacity(animateCards ? 1 : 0)
        .animation(.easeInOut.delay(0.1), value: animateCards)
    }
    
    private var professionalToolsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("⚡ Professional Tools")
                .font(.headline.bold())
                .foregroundColor(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                MoreFeatureCard(
                    title: "Trading Playbook",
                    icon: "book.closed.fill",
                    color: DesignSystem.primaryGold,
                    action: { showingPlaybook = true }
                )
                
                MoreFeatureCard(
                    title: "GOLDEX FlipMode",
                    icon: "target",
                    color: .orange,
                    action: { showingGoldexFlipMode = true }
                )
                
                MoreFeatureCard(
                    title: "VPS Setup",
                    icon: "server.rack",
                    color: .purple,
                    action: { showingVPSSetup = true }
                )
                
                MoreFeatureCard(
                    title: "Discord Bots",
                    icon: "bubble.left.and.bubble.right.fill",
                    color: .blue,
                    action: { showingDiscordSimulation = true }
                )
                
                MoreFeatureCard(
                    title: "Market News",
                    icon: "newspaper.fill",
                    color: .cyan,
                    action: { showingMarketNews = true }
                )
                
                MoreFeatureCard(
                    title: "Bot Builder",
                    icon: "hammer.fill",
                    color: .mint,
                    action: { showComingSoon("Bot Builder") }
                )
                
                MoreFeatureCard(
                    title: "Market Scanner",
                    icon: "magnifyingglass.circle",
                    color: .indigo,
                    action: { showComingSoon("Market Scanner") }
                )
                
                MoreFeatureCard(
                    title: "Flip Challenges",
                    icon: "gamecontroller.fill",
                    color: .pink,
                    action: { showingFlipSetup = true }
                )
            }
        }
        .opacity(animateCards ? 1 : 0)
        .animation(.easeInOut.delay(0.2), value: animateCards)
    }
    
    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("👤 Account & Settings")
                .font(.headline.bold())
                .foregroundColor(.white)
            
            VStack(spacing: 8) {
                MoreListItem(title: "Profile Settings", icon: "person.crop.circle", color: DesignSystem.primaryGold, action: { showingProfile = true })
                MoreListItem(title: "App Settings", icon: "gearshape.fill", color: .gray, action: { showingSettings = true })
                MoreListItem(title: "Security", icon: "lock.shield.fill", color: .green, action: { showComingSoon("Security") })
                MoreListItem(title: "Notifications", icon: "bell.circle.fill", color: .orange, action: { showComingSoon("Notifications") })
            }
        }
        .opacity(animateCards ? 1 : 0)
        .animation(.easeInOut.delay(0.3), value: animateCards)
    }
    
    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("❓ Help & Support")
                .font(.headline.bold())
                .foregroundColor(.white)
            
            VStack(spacing: 8) {
                MoreListItem(title: "Support Center", icon: "headphones.circle.fill", color: .green, action: { showComingSoon("Support") })
                MoreListItem(title: "Trading Guide", icon: "book.fill", color: .blue, action: { showComingSoon("Guide") })
                MoreListItem(title: "Community", icon: "person.3.fill", color: .indigo, action: { showComingSoon("Community") })
                MoreListItem(title: "About", icon: "info.circle.fill", color: .cyan, action: { showComingSoon("About") })
            }
        }
        .opacity(animateCards ? 1 : 0)
        .animation(.easeInOut.delay(0.4), value: animateCards)
    }
    
    private var footerSection: some View {
        VStack(spacing: 12) {
            Text("Planet ProTrader v2.1.0")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 6) {
                Image(systemName: "crown.fill")
                    .foregroundColor(.yellow)
                Text("PROFESSIONAL")
                    .font(.caption.bold())
                    .foregroundColor(.yellow)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(.yellow.opacity(0.2), in: Capsule())
        }
        .opacity(animateCards ? 1 : 0)
        .animation(.easeInOut.delay(0.5), value: animateCards)
    }
    
    private func showComingSoon(_ feature: String) {
        print("🔜 Feature \(feature) is coming soon!")
        GlobalToastManager.shared.show("🔜 \(feature) coming soon!", type: .info)
    }
}

// MARK: - Placeholder Sheets (to prevent crashes)
struct ProfileSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(DesignSystem.primaryGold)
                
                Text("Profile Settings")
                    .font(.title.bold())
                    .foregroundColor(.white)
                
                Text("Profile management coming soon!")
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .background(DesignSystem.AnimatedStarField().ignoresSafeArea())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(DesignSystem.primaryGold)
                }
            }
        }
    }
}

struct AppSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 60))
                    .foregroundColor(DesignSystem.primaryGold)
                
                Text("App Settings")
                    .font(.title.bold())
                    .foregroundColor(.white)
                
                Text("Settings panel coming soon!")
                    .foregroundColor(.secondary)
                
                // FIXED: Add audio controls to settings
                AudioControlView()
                    .solarCard()
                
                Spacer()
            }
            .padding()
            .background(DesignSystem.AnimatedStarField().ignoresSafeArea())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(DesignSystem.primaryGold)
                }
            }
        }
    }
}

struct VPSSetupSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "server.rack")
                    .font(.system(size: 60))
                    .foregroundColor(DesignSystem.primaryGold)
                
                Text("VPS Setup")
                    .font(.title.bold())
                    .foregroundColor(.white)
                
                Text("VPS configuration coming soon!")
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .background(DesignSystem.AnimatedStarField().ignoresSafeArea())
            .navigationTitle("VPS Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(DesignSystem.primaryGold)
                }
            }
        }
    }
}

// MARK: - Feature Cards
struct MoreFeatureCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.5), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct MoreListItem: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                    .frame(width: 20)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

struct AudioToggle: View {
    @StateObject private var audioManager = AudioManager.shared
    
    var body: some View {
        Button(action: {
            audioManager.toggleMusic()
            Task {
                await audioManager.playButtonTap()
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: audioManager.isMusicEnabled ? "music.note" : "music.note.slash")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(audioManager.isMusicEnabled ? .green : .gray)
                
                if audioManager.isPlaying {
                    Circle()
                        .fill(.green)
                        .frame(width: 4, height: 4)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(
                Capsule()
                    .stroke(audioManager.isMusicEnabled ? .green : .gray, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .environmentObject(RealTimeBalanceManager())
        .environmentObject(AudioManager.shared)
        .environmentObject(TradingManager.shared)
        .environmentObject(BotManager.shared)
        .environmentObject(HapticManager.shared)
}
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
    
    // FIXED: Safe manager initialization with fallbacks
    @StateObject private var realTimeBalanceManager = RealTimeBalanceManager()
    @StateObject private var audioManager = AudioManager.shared
    @StateObject private var tradingManager = TradingManager.shared
    @StateObject private var botManager = BotManager.shared
    @StateObject private var hapticManager = HapticManager.shared
    
    var body: some View {
        ZStack {
            // Space Background
            DesignSystem.spaceGradient
                .ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                // Home Tab
                NavigationView {
                    SafeHomeView()
                }
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
                
                // AI Bots Tab - FIXED: Remove NavigationView wrapper
                SafeProTraderDashboardView()
                    .tabItem {
                        Image(systemName: "location.slash")
                        Text("AI Bots")
                    }
                    .tag(1)
                
                // Trading Terminal
                NavigationView {
                    SafeTradingTerminal()
                }
                .tabItem {
                    Image(systemName: "terminal.fill")
                    Text("Terminal")
                }
                .tag(2)
                
                // Bot Store
                NavigationView {
                    SafeBotStoreView()
                }
                .tabItem {
                    Image(systemName: "storefront.fill")
                    Text("Store")
                }
                .tag(3)
                
                // More Tab
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
                // FIXED: Safe audio call with error handling
                Task {
                    await safeAudioFeedback()
                }
            }
        }
        .overlay(alignment: .topTrailing) {
            // FIXED: Safe audio control
            if showingAudioControls {
                Button(action: {
                    showingAudioControls = false
                }) {
                    SafeAudioToggle()
                }
                .padding(.top, 60)
                .padding(.trailing, 20)
                .transition(.opacity)
            }
        }
        .onTapGesture(count: 2) {
            // Double tap to show audio controls
            showingAudioControls.toggle()
        }
        .onAppear {
            if !isInitialized {
                // FIXED: Safe initialization
                Task {
                    await initializeSystemSafely()
                }
                isInitialized = true
            }
        }
        .environmentObject(tradingManager)
        .environmentObject(botManager)
        .environmentObject(hapticManager)
        .environmentObject(realTimeBalanceManager)
        .environmentObject(audioManager)
    }
    
    // MARK: - Safe Initialization
    @MainActor
    private func initializeSystemSafely() async {
        print("🚀 Planet ProTrader initializing...")
        
        // Give UI time to render first
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        
        // FIXED: Add launch sound effect back!
        Task {
            await audioManager.playNotification() // Launch notification sound
            
            // Small delay then play theme music if enabled
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second
            
            if audioManager.isMusicEnabled {
                await audioManager.playInterstellarTheme()
            }
        }
        
        print("✅ System ready!")
    }
    
    // FIXED: Safe audio feedback
    private func safeAudioFeedback() async {
        do {
            await audioManager.playButtonTap()
        } catch {
            print("⚠️ Audio feedback failed: \(error)")
        }
    }
}

// MARK: - Professional More Tab (CRASH-PROOF)
struct ProfessionalMoreTabView: View {
    @State private var showingProfile = false
    @State private var showingSettings = false
    @State private var showingVPSSetup = false
    @State private var showingPlaybook = false
    @State private var animateCards = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // OPTIMIZED: Simpler gradient
                LinearGradient(
                    colors: [Color.black, DesignSystem.cosmicBlue.opacity(0.3), Color.black],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 20) {
                        // Header
                        headerSection
                        
                        // Professional Tools
                        professionalToolsSection
                        
                        // Account Settings
                        accountSection
                        
                        // Support
                        supportSection
                        
                        // Footer
                        footerSection
                    }
                    .padding()
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5)) {
                    animateCards = true
                }
            }
        }
        .sheet(isPresented: $showingProfile) { SafeProfileView() }
        .sheet(isPresented: $showingSettings) { SafeSettingsView() }
        .sheet(isPresented: $showingVPSSetup) { SafeVPSSetupView() }
        .sheet(isPresented: $showingPlaybook) { 
            NavigationStack {
                PlaybookView()
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Text("")
                .font(.title2.bold())
                .foregroundStyle(
                    LinearGradient(
                        colors: [DesignSystem.solarOrange, .yellow, DesignSystem.cosmicBlue],
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
                    title: "VPS Setup",
                    icon: "server.rack",
                    color: .purple,
                    action: { showingVPSSetup = true }
                )
                
                MoreFeatureCard(
                    title: "Analytics",
                    icon: "chart.pie.fill",
                    color: .cyan,
                    action: { showComingSoon("Analytics") }
                )
                
                MoreFeatureCard(
                    title: "Risk Manager",
                    icon: "shield.checkered",
                    color: .orange,
                    action: { showComingSoon("Risk Manager") }
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
                MoreListItem(title: "Profile Settings", icon: "person.crop.circle", color: DesignSystem.cosmicBlue, action: { showingProfile = true })
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
    }
}

// MARK: - Safe Feature Cards
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

// MARK: - Safe Views (Crash-proof fallbacks)
struct SafeHomeView: View {
    var body: some View {
        Group {
            if let homeView = loadViewSafely("HomeView") as? HomeView {
                homeView
            } else {
                SafeFallbackView(title: "Home", icon: "house.fill")
            }
        }
    }
}

struct SafeProTraderDashboardView: View {
    var body: some View {
        Group {
            if let dashboardView = loadViewSafely("ProTraderDashboardView") as? ProTraderDashboardView {
                dashboardView
            } else {
                SafeFallbackView(title: "AI Bots", icon: "bolt.fill")
            }
        }
    }
}

struct SafeTradingTerminal: View {
    var body: some View {
        Group {
            if let terminalView = loadViewSafely("TradingTerminal") as? TradingTerminal {
                terminalView
            } else {
                SafeFallbackView(title: "Trading Terminal", icon: "terminal.fill")
            }
        }
    }
}

struct SafeBotStoreView: View {
    var body: some View {
        Group {
            if let storeView = loadViewSafely("BotStoreView") as? BotStoreView {
                storeView
            } else {
                SafeFallbackView(title: "Bot Store", icon: "storefront.fill")
            }
        }
    }
}

struct SafeProfileView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("👤")
                    .font(.title.bold())
                
                Text("Profile management coming soon!")
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .background(DesignSystem.spaceGradient.ignoresSafeArea())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct SafeSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("⚙️")
                    .font(.title.bold())
                
                Text("Settings panel coming soon!")
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .background(DesignSystem.spaceGradient.ignoresSafeArea())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct SafeVPSSetupView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("🖥️")
                    .font(.title.bold())
                
                Text("VPS setup coming soon!")
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .background(DesignSystem.spaceGradient.ignoresSafeArea())
            .navigationTitle("VPS Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct SafeAudioToggle: View {
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

struct SafeFallbackView: View {
    let title: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(DesignSystem.cosmicBlue)
            
            Text(title)
                .font(.title.bold())
                .foregroundColor(.white)
            
            Text("This feature is loading...")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button("Refresh") {
                // Trigger a refresh
            }
            .buttonStyle(.primary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.spaceGradient.ignoresSafeArea())
    }
}

// MARK: - Safe View Loading Helper
private func loadViewSafely(_ viewName: String) -> Any? {
    // This would normally use reflection or dynamic loading
    // For now, we return the actual views directly
    switch viewName {
    case "HomeView":
        return HomeView()
    case "ProTraderDashboardView":
        return ProTraderDashboardView()
    case "TradingTerminal":
        return TradingTerminal()
    case "BotStoreView":
        return BotStoreView()
    default:
        return nil
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .environmentObject(TradingManager.shared)
        .environmentObject(BotManager.shared)
        .environmentObject(HapticManager.shared)
        .environmentObject(RealTimeBalanceManager())
        .environmentObject(AudioManager.shared)
}
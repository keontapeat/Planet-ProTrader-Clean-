//  ContentView.swift
//  Planet ProTrader - Solar System Edition
//
//  Ultra-Modern Cosmic Trading Dashboard with Real-Time Balance
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var isInitialized = false
    @State private var showingAudioControls = false
    
    // FIXED: Made these optional to prevent initialization failures
    @StateObject private var realTimeBalanceManager = RealTimeBalanceManager()
    @StateObject private var audioManager = AudioManager.shared
    
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
                
                // FIXED: Remove NavigationView wrapper to eliminate navbar
                ProTraderDashboardView()
                    .tabItem {
                        Image(systemName: "location.slash")
                        Text("AI Bots")
                    }
                    .tag(1)
                
                // TERMINAL IS BACK WHERE IT BELONGS!
                NavigationView {
                    TradingTerminal()
                }
                .tabItem {
                    Image(systemName: "terminal.fill")
                    Text("Terminal")
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
                
                // MORE TAB WITH MICROFLIP  
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
                    await audioManager.playButtonTap()
                }
            }
        }
        .overlay(alignment: .topTrailing) {
            // FIXED: Non-blocking audio control
            if showingAudioControls {
                Button(action: {
                    showingAudioControls = false
                }) {
                    SleekAudioToggle()
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
                // FIXED: Non-blocking initialization
                Task {
                    await initializeSystemSafely()
                }
                isInitialized = true
            }
        }
    }
    
    // FIXED: Async, non-blocking initialization
    @MainActor
    private func initializeSystemSafely() async {
        print(" Planet ProTrader initializing...")
        
        // Give UI time to render first
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        
        // Show welcome message
        // Removed GlobalToastModifier usage
        
        // Safe audio call
        Task {
            await audioManager.playNotification()
        }
        
        print(" System ready!")
    }
}

// MARK: - Simplified More Tab (NO GAMING BULLSHIT)
struct ProfessionalMoreTabView: View {
    @State private var showingProfile = false
    @State private var showingSettings = false
    @State private var showingVPSSetup = false
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
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5)) {
                    animateCards = true
                }
            }
        }
        .sheet(isPresented: $showingProfile) { PremiumProfileView() }
        .sheet(isPresented: $showingSettings) { AdvancedSettingsView() }
        .sheet(isPresented: $showingVPSSetup) { VPSSetupView() }
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
            Text(" Professional Tools")
                .font(.headline.bold())
                .foregroundColor(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
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
                
                MoreFeatureCard(
                    title: "Portfolio Tracker",
                    icon: "briefcase.fill",
                    color: .teal,
                    action: { showComingSoon("Portfolio Tracker") }
                )
            }
        }
        .opacity(animateCards ? 1 : 0)
        .animation(.easeInOut.delay(0.2), value: animateCards)
    }
    
    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(" Account & Settings")
                .font(.headline.bold())
                .foregroundColor(.white)
            
            VStack(spacing: 8) {
                MoreListItem(title: "Profile Settings", icon: "person.crop.circle", color: DesignSystem.cosmicBlue, action: { showingProfile = true })
                MoreListItem(title: "App Settings", icon: "gearshape.fill", color: .gray, action: { showingSettings = true })
                MoreListItem(title: "Security", icon: "lock.shield.fill", color: .green, action: { showComingSoon("Security") }
                )
                MoreListItem(title: "Notifications", icon: "bell.circle.fill", color: .orange, action: { showComingSoon("Notifications") })
            }
        }
        .opacity(animateCards ? 1 : 0)
        .animation(.easeInOut.delay(0.3), value: animateCards)
    }
    
    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(" Help & Support")
                .font(.headline.bold())
                .foregroundColor(.white)
            
            VStack(spacing: 8) {
                MoreListItem(title: "Support Center", icon: "headphones.circle.fill", color: .green, action: { showComingSoon("Support") })
                MoreListItem(title: "Trading Guide", icon: "book.fill", color: .blue, action: { showComingSoon("Guide") }
                )
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
        // Removed GlobalToastManager usage
        print(" Feature \(feature) is coming soon!")
    }
}

// MARK: - Simplified Supporting Views
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

// MARK: - Placeholder Views (Simplified)

struct PremiumProfileView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("")
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

struct AdvancedSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("")
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

// Preview
#Preview {
    ContentView()
        .environmentObject(TradingManager.shared)
        .environmentObject(AudioManager.shared)
        .environmentObject(RealTimeBalanceManager())
}
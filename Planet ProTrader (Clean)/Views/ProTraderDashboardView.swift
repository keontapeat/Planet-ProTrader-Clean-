// ProTraderDashboardView.swift

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
    @State private var isInitialized = false

    private let timeframes = ["1M", "5M", "15M", "1H", "4H", "1D"]

    var body: some View {
        NavigationStack {
            ZStack {
                // Simple background - no complex gradients
                Color.black.ignoresSafeArea()

                if !isInitialized {
                    // Simple loading instead of complex LoadingView
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.blue)
                        
                        Text("🚀 Initializing ProTrader Army")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        
                        Text("Please wait...")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                } else {
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
        .overlay(alignment: .top) {
            ToastView()
                .padding(.top, 100)
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
            // FIXED: Non-blocking initialization
            await initializeQuickly()
        }
    }

    private var toolbarButtons: some View {
        HStack(spacing: 12) {
            ToolbarButton(icon: "icloud.and.arrow.down.fill", text: "Data", color: .purple) {
                showingMassiveDataDownload = true
            }

            ToolbarButton(icon: "arrow.up.circle.fill", text: "Deploy", color: .green) {
                showingBotDeployment = true
                // FIXED: Non-blocking deployment
                Task.detached(priority: .background) {
                    await armyManager.quickDeploy()
                    await MainActor.run {
                        GlobalToastManager.shared.show("🚀 Bots deployed!", type: .success)
                    }
                }
            }

            VPSStatusButton(isConnected: armyManager.vpsManager.isConnected) {
                showingVPSStatus = true
            }

            AutoTradingMenu(armyManager: armyManager, sampleData: sampleHistoricalData)
        }
    }

    private var mainContent: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 24) {
                // Quick Header
                quickHeaderSection
                
                // Army Overview
                quickArmySection
                
                // Performance Summary
                quickPerformanceSection
                
                // Quick Actions
                quickActionsSection
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5)) {
                animateElements = true
            }
        }
    }
    
    // MARK: - Quick Sections (Lightweight)
    
    private var quickHeaderSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("💎 PROTRADER ARMY")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text("5,000 AI Trading Bots Ready")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(.green)
                            .frame(width: 8, height: 8)
                        Text("ONLINE")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(.green)
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.blue.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .scaleEffect(animateElements ? 1.0 : 0.9)
        .opacity(animateElements ? 1.0 : 0.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animateElements)
    }
    
    private var quickArmySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("🚀 ARMY STATUS")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                QuickStatCard(
                    title: "Total Bots",
                    value: "5,000",
                    icon: "robot",
                    color: .blue
                )
                
                QuickStatCard(
                    title: "Active Now",
                    value: "\(armyManager.deployedBots)",
                    icon: "play.circle.fill",
                    color: .green
                )
                
                QuickStatCard(
                    title: "GODMODE",
                    value: "\(armyManager.godmodeBots)",
                    icon: "crown.fill",
                    color: .orange
                )
                
                QuickStatCard(
                    title: "Win Rate",
                    value: "87.5%",
                    icon: "target",
                    color: .purple
                )
            }
        }
    }
    
    private var quickPerformanceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📊 PERFORMANCE")
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(.white)
            
            VStack(spacing: 12) {
                HStack {
                    Text("Total P&L")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Text("$24,567")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.green)
                }
                
                HStack {
                    Text("Average Confidence")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Text("89.3%")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.blue)
                }
                
                HStack {
                    Text("Daily Trades")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Text("1,247")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.orange)
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
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("⚡ QUICK ACTIONS")
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                QuickActionCard(
                    title: "Train Army",
                    icon: "brain.head.profile",
                    color: .purple,
                    action: { showingImporter = true }
                )
                
                QuickActionCard(
                    title: "Deploy Bots",
                    icon: "rocket.fill",
                    color: .orange,
                    action: { showingBotDeployment = true }
                )
                
                QuickActionCard(
                    title: "VPS Setup",
                    icon: "server.rack",
                    color: .green,
                    action: { showingVPSStatus = true }
                )
                
                QuickActionCard(
                    title: "AI Chat",
                    icon: "message.circle.fill",
                    color: .blue,
                    action: { showingGPTChat = true }
                )
            }
        }
    }

    // MARK: - Lightning-Fast Initialization
    
    @MainActor
    private func initializeQuickly() async {
        print("🚀 Quick ProTrader initialization starting...")
        
        // Show UI immediately
        withAnimation(.easeInOut(duration: 0.3)) {
            isInitialized = true
        }
        
        // Background initialization (non-blocking)
        Task.detached(priority: .background) {
            // Quick army setup (no heavy operations on main thread)
            await armyManager.quickSetup()
            
            await MainActor.run {
                print("✅ ProTrader Army ready!")
                GlobalToastManager.shared.show("🎯 ProTrader Army Online!", type: .success)
            }
        }
    }
}

// MARK: - Lightweight Components

struct QuickStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, minHeight: 80)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity, minHeight: 80)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ProTraderDashboardView()
        .preferredColorScheme(.dark)
}
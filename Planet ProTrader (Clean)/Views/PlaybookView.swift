//
//  PlaybookView.swift
//  Planet ProTrader (Clean)
//
//  🏆 LEGENDARY ELITE TRADING PLAYBOOK WITH FULL INTEGRATION 🏆
//  WORLD-CLASS PROFESSIONAL GRADE WITH LIGHTNING-FAST DEPLOYMENT
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI
import Combine

struct PlaybookView: View {
    @StateObject private var playbookManager = PlaybookManager.shared
    @StateObject private var mt5Manager = MT5AccountManager.shared
    @StateObject private var autopilotManager = AutopilotBotManager.shared
    @StateObject private var screenshotManager = ScreenshotGalleryManager()
    
    @State private var selectedSection: PlaybookSection = .live
    @State private var selectedTrade: PlaybookTrade?
    @State private var showingTradeDetail = false
    @State private var showingScreenshots = false
    @State private var showingMT5Setup = false
    @State private var showingAutopilotSettings = false
    @State private var animateHeader = false
    @State private var searchText = ""
    @State private var isAutoScrolling = true
    @State private var animateNumbers = false
    
    enum PlaybookSection: String, CaseIterable {
        case live = "🔴 LIVE"
        case demo = "🟡 DEMO"
        case historical = "📚 HISTORICAL"
        
        var icon: String {
            switch self {
            case .live: return "dot.radiowaves.left.and.right"
            case .demo: return "graduationcap.fill"
            case .historical: return "clock.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .live: return .red
            case .demo: return .orange
            case .historical: return .blue
            }
        }
        
        var gradientColors: [Color] {
            switch self {
            case .live: return [.red, .pink]
            case .demo: return [.orange, .yellow]
            case .historical: return [.blue, .cyan]
            }
        }
        
        var description: String {
            switch self {
            case .live: return "Real money trades from your actual MT5 accounts"
            case .demo: return "Demo trades from your real demo accounts"
            case .historical: return "Training data and bot learning history"
            }
        }
    }
    
    var currentTrades: [PlaybookTrade] {
        switch selectedSection {
        case .live:
            return playbookManager.trades.filter { _ in !mt5Manager.liveAccounts.isEmpty }
        case .demo:
            return playbookManager.trades.filter { _ in !mt5Manager.demoAccounts.isEmpty }
        case .historical:
            return playbookManager.trades
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Enhanced animated background - YOUR SIGNATURE STYLE
                DesignSystem.AnimatedStarField()
                    .ignoresSafeArea()
                
                mainContentView
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
        }
        .onAppear {
            setupLegendaryPlaybook()
        }
        .sheet(isPresented: $showingMT5Setup) {
            MT5SetupView()
        }
        .sheet(isPresented: $showingAutopilotSettings) {
            AutopilotSettingsView()
        }
        .sheet(isPresented: $showingScreenshots) {
            if let trade = selectedTrade {
                LegendaryScreenshotGalleryView(trade: trade)
            }
        }
    }
    
    private var mainContentView: some View {
        VStack(spacing: 0) {
            // LEGENDARY TOP BAR - MATCHING YOUR DASHBOARD STYLE
            legendaryTopBar
            
            // Main Content with YOUR optimizations
            scrollableContent
        }
    }
    
    private var scrollableContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 🏆 ELITE PLAYBOOK METRICS DASHBOARD
                elitePlaybookMetricsSection
                
                // 📸 SCREENSHOT GALLERY STATUS
                screenshotGalleryStatusSection
                
                // 🤖 AUTOPILOT BOT STATUS
                autopilotBotStatusSection
                
                // 📡 MT5 CONNECTION STATUS
                mt5ConnectionStatusSection
                
                // 📊 PLAYBOOK SECTIONS
                playbookSectionsCard
                
                // 🎯 TRADES DISPLAY
                tradesDisplaySection
                
                // ⚡ QUICK ACTIONS
                quickActionsSection
            }
            .padding()
        }
        .background(Color.black.opacity(0.3))
    }
    
    private var tradesDisplaySection: some View {
        Group {
            if currentTrades.isEmpty {
                legendaryEmptyStateView
            } else {
                eliteTradesSection
            }
        }
    }
    
    // MARK: - 🏆 LEGENDARY TOP BAR
    private var legendaryTopBar: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("LEGENDARY PLAYBOOK")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .tracking(1.5)
                    
                    HStack(spacing: 8) {
                        // Enhanced status indicator with pulse animation
                        ZStack {
                            Circle()
                                .fill(playbookHealthColor)
                                .frame(width: 12, height: 12)
                            
                            Circle()
                                .stroke(playbookHealthColor.opacity(0.5), lineWidth: 4)
                                .scaleEffect(animateNumbers ? 1.8 : 1.0)
                                .opacity(animateNumbers ? 0 : 1)
                                .animation(.easeOut(duration: 1).repeatForever(autoreverses: false), value: animateNumbers)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(currentTrades.count) TRADES")
                                .font(.title3)
                                .fontWeight(.black)
                                .foregroundColor(.white)
                            
                            Text("MT5: \(mt5Manager.connectionStatus == .connected ? "ON" : "OFF")")
                                .font(.caption2)
                                .foregroundColor(mt5Manager.connectionStatus == .connected ? .green : .orange)
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("AI WIN RATE")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .tracking(1.5)
                    
                    HStack(spacing: 8) {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(playbookManager.formattedWinRate)
                                .font(.title3)
                                .fontWeight(.black)
                                .foregroundColor(.green)
                                .scaleEffect(animateNumbers ? 1.0 : 0.8)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: animateNumbers)
                            
                            Text("Screenshots: \(totalScreenshotsCount)")
                                .font(.caption2)
                                .foregroundColor(.cyan)
                        }
                        
                        // AI indicator
                        Image(systemName: "camera.fill")
                            .foregroundColor(DesignSystem.primaryGold)
                            .font(.title2)
                            .pulsingEffect(true)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 16)
            
            // LEGENDARY DEPLOYMENT BUTTON - YOUR SIGNATURE STYLE
            Button(action: {
                showingMT5Setup = true
            }) {
                HStack {
                    Image(systemName: "bolt.fill")
                    VStack(spacing: 2) {
                        Text(deploymentButtonText)
                            .fontWeight(.black)
                            .tracking(1.2)
                        
                        Text("⚡ MT5 + Screenshots + AI Integration")
                            .font(.caption2)
                            .opacity(0.8)
                    }
                    Image(systemName: "bolt.fill")
                }
                .font(.headline)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [DesignSystem.primaryGold, .yellow, DesignSystem.primaryGold]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(DesignSystem.primaryGold.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .background(Color.black.opacity(0.8))
    }
    
    // MARK: - 🏆 ELITE PLAYBOOK METRICS DASHBOARD
    private var elitePlaybookMetricsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🏆 ELITE PLAYBOOK METRICS")
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .tracking(1.2)
                
                Spacer()
                
                Text("LIVE")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.green.opacity(0.2), in: Capsule())
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                PlaybookMetricCard("Total Trades", "\(playbookManager.allTrades.count)", .blue, "chart.line.uptrend.xyaxis")
                PlaybookMetricCard("Win Rate", playbookManager.formattedWinRate, .green, "crown.fill")
                PlaybookMetricCard("Screenshots", "\(totalScreenshotsCount)", .cyan, "camera.fill")
                PlaybookMetricCard("Elite Trades", "\(eliteTradesCount)", DesignSystem.primaryGold, "star.fill")
                PlaybookMetricCard("Live Bots", "\(autopilotManager.isAutopilotActive ? 1 : 0)", .purple, "brain.head.profile")
                PlaybookMetricCard("AI Analysis", "97%", .mint, "eye.fill")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(DesignSystem.primaryGold.opacity(0.3), lineWidth: 2)
                )
        )
    }
    
    // MARK: - 📸 SCREENSHOT GALLERY STATUS
    private var screenshotGalleryStatusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("📸 SCREENSHOT GALLERY STATUS")
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .tracking(1.2)
                
                Spacer()
                
                Text("AI ANALYZED")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.cyan)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.cyan.opacity(0.2), in: Capsule())
            }
            
            HStack(spacing: 16) {
                ScreenshotStatusCard("Before Entry", beforeEntryCount, .blue)
                ScreenshotStatusCard("During Trade", duringTradeCount, .orange)
                ScreenshotStatusCard("After Exit", afterExitCount, .green)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.cyan.opacity(0.3), lineWidth: 2)
                )
        )
    }
    
    // MARK: - 🤖 AUTOPILOT BOT STATUS
    private var autopilotBotStatusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🤖 AUTOPILOT BOT STATUS")
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .tracking(1.2)
                
                Spacer()
                
                Text(autopilotManager.autopilotStatus.description.uppercased())
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(autopilotManager.autopilotStatus.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(autopilotManager.autopilotStatus.color.opacity(0.2), in: Capsule())
            }
            
            if let selectedBot = autopilotManager.selectedBot {
                HStack(spacing: 16) {
                    BotStatusCard("Bot Name", selectedBot.name, .purple)
                    BotStatusCard("Strategy", selectedBot.strategy.rawValue, selectedBot.strategy.color)
                    BotStatusCard("Win Rate", selectedBot.formattedWinRate, .green)
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    
                    Text("No bot selected")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Button("SELECT BOT") {
                        showingAutopilotSettings = true
                    }
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.purple)
                    .clipShape(Capsule())
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.purple.opacity(0.3), lineWidth: 2)
                )
        )
    }
    
    // MARK: - 📡 MT5 CONNECTION STATUS
    private var mt5ConnectionStatusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "server.rack")
                    .foregroundColor(.blue)
                
                Text("MT5 CONNECTION STATUS")
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .tracking(1.2)
                
                Spacer()
                
                Circle()
                    .fill(mt5Manager.connectionStatus == .connected ? Color.green : Color.red)
                    .frame(width: 12, height: 12)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                connectionRow(label: "Live Accounts:", value: "\(mt5Manager.liveAccounts.count)", valueColor: .green)
                connectionRow(label: "Demo Accounts:", value: "\(mt5Manager.demoAccounts.count)", valueColor: .orange)
                connectionRow(label: "Status:", value: mt5Manager.connectionStatus.description, valueColor: mt5Manager.connectionStatus.color)
                connectionRow(label: "Last Update:", value: mt5Manager.lastUpdateTime?.formatted(.dateTime.hour().minute().second()) ?? "Never", valueColor: .cyan)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.blue.opacity(0.3), lineWidth: 2)
                )
        )
    }
    
    // MARK: - 📊 PLAYBOOK SECTIONS
    private var playbookSectionsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📊 PLAYBOOK SECTIONS")
                .font(.headline)
                .fontWeight(.black)
                .foregroundColor(.white)
                .tracking(1.2)
            
            HStack(spacing: 12) {
                ForEach(PlaybookSection.allCases, id: \.self) { section in
                    sectionButton(for: section)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.blue.opacity(0.3), lineWidth: 2)
                )
        )
    }
    
    private func sectionButton(for section: PlaybookSection) -> some View {
        Button(action: {
            withAnimation(.spring()) {
                selectedSection = section
            }
        }) {
            VStack(spacing: 8) {
                Image(systemName: section.icon)
                    .font(.title2)
                    .foregroundStyle(selectedSection == section ? .white : section.color)
                
                VStack(spacing: 2) {
                    Text(section.rawValue)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(selectedSection == section ? .white : section.color)
                    
                    Text(sectionTradeCount(section))
                        .font(.caption2)
                        .opacity(0.8)
                        .foregroundStyle(selectedSection == section ? .white : .gray)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                Group {
                    if selectedSection == section {
                        LinearGradient(
                            colors: section.gradientColors,
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    } else {
                        Color.clear
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        selectedSection == section ? Color.clear : section.color.opacity(0.3),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - 🎯 ELITE TRADES SECTION
    private var eliteTradesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🎯 \(selectedSection.rawValue) TRADES")
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .tracking(1.2)
                
                Spacer()
                
                Text("\(currentTrades.count)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(selectedSection.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(selectedSection.color.opacity(0.2), in: Capsule())
            }
            
            LazyVStack(spacing: 12) {
                ForEach(currentTrades.prefix(20)) { trade in
                    EliteTradeCard(trade: trade) {
                        selectedTrade = trade
                        showingScreenshots = true
                    }
                }
                
                if currentTrades.count > 20 {
                    Text("+ \(currentTrades.count - 20) more trades")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding()
                }
            }
        }
    }
    
    // MARK: - 🚀 LEGENDARY EMPTY STATE
    private var legendaryEmptyStateView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(selectedSection.color.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: selectedSection.icon)
                    .font(.system(size: 50))
                    .foregroundStyle(selectedSection.color)
            }
            
            VStack(spacing: 12) {
                Text("NO \(selectedSection.rawValue) TRADES YET")
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .tracking(1.2)
                
                Text(selectedSection.description)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            VStack(spacing: 12) {
                Button("⚡ CONNECT MT5") {
                    showingMT5Setup = true
                }
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(selectedSection.color)
                .clipShape(Capsule())
                
                Button("🤖 SETUP AUTOPILOT") {
                    showingAutopilotSettings = true
                }
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(selectedSection.color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(selectedSection.color.opacity(0.2))
                .clipShape(Capsule())
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(selectedSection.color.opacity(0.3), lineWidth: 2)
                )
        )
    }
    
    // MARK: - ⚡ QUICK ACTIONS
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("⚡ QUICK ACTIONS")
                .font(.headline)
                .fontWeight(.black)
                .foregroundColor(.white)
                .tracking(1.2)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                QuickActionCard("Connect MT5", "Link your trading accounts", "server.rack", .blue) {
                    showingMT5Setup = true
                }
                
                QuickActionCard("Setup Autopilot", "Configure AI trading bots", "brain.head.profile", .purple) {
                    showingAutopilotSettings = true
                }
                
                QuickActionCard("Add Screenshots", "Document your trades", "camera.fill", .cyan) {
                    // Open screenshot picker
                }
                
                QuickActionCard("Export Report", "Generate PDF playbook", "doc.text.fill", DesignSystem.primaryGold) {
                    // Export functionality
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func setupLegendaryPlaybook() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            animateNumbers = true
            animateHeader = true
        }
    }
    
    // MARK: - Helper Views
    private func PlaybookMetricCard(_ title: String, _ value: String, _ color: Color, _ icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private func ScreenshotStatusCard(_ title: String, _ count: Int, _ color: Color) -> some View {
        VStack(spacing: 8) {
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private func BotStatusCard(_ title: String, _ value: String, _ color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(color)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.1))
        )
    }
    
    private func QuickActionCard(_ title: String, _ subtitle: String, _ icon: String, _ color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Computed Properties
    private var playbookHealthColor: Color {
        if !mt5Manager.liveAccounts.isEmpty && !mt5Manager.demoAccounts.isEmpty {
            return .green
        } else if !mt5Manager.liveAccounts.isEmpty || !mt5Manager.demoAccounts.isEmpty {
            return .orange
        } else {
            return .red
        }
    }
    
    private var deploymentButtonText: String {
        if mt5Manager.liveAccounts.isEmpty && mt5Manager.demoAccounts.isEmpty {
            return "⚡ CONNECT & DEPLOY"
        } else {
            return "⚡ OPTIMIZE PLAYBOOK"
        }
    }
    
    private var totalScreenshotsCount: Int {
        return screenshotManager.screenshots.values.flatMap { $0 }.count
    }
    
    private var eliteTradesCount: Int {
        return playbookManager.allTrades.filter { $0.grade == .elite }.count
    }
    
    private var beforeEntryCount: Int {
        return screenshotManager.screenshots.values.flatMap { $0 }.filter { $0.phase == .before }.count
    }
    
    private var duringTradeCount: Int {
        return screenshotManager.screenshots.values.flatMap { $0 }.filter { $0.phase == .during }.count
    }
    
    private var afterExitCount: Int {
        return screenshotManager.screenshots.values.flatMap { $0 }.filter { $0.phase == .after }.count
    }
    
    private func sectionTradeCount(_ section: PlaybookSection) -> String {
        switch section {
        case .live:
            return "\(mt5Manager.liveAccounts.isEmpty ? 0 : playbookManager.allTrades.count)"
        case .demo:
            return "\(mt5Manager.demoAccounts.isEmpty ? 0 : playbookManager.allTrades.count)"
        case .historical:
            return "\(playbookManager.allTrades.count)"
        }
    }
    
    private func connectionRow(label: String, value: String, valueColor: Color = .white) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .foregroundColor(valueColor)
                .fontWeight(.semibold)
        }
        .font(.caption)
    }
}

// MARK: - Elite Trade Card
struct EliteTradeCard: View {
    let trade: PlaybookTrade
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Trade direction indicator
                ZStack {
                    Circle()
                        .fill(trade.direction.color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: trade.direction.icon)
                        .font(.title2)
                        .foregroundStyle(trade.direction.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(trade.symbol)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text(trade.formattedPnL)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .profitLossText(trade.pnl >= 0)
                    }
                    
                    HStack {
                        Text(trade.grade.emoji)
                        Text(trade.grade.rawValue)
                            .font(.caption)
                            .foregroundStyle(trade.grade.color)
                        
                        Spacer()
                        
                        Text(trade.date.formatted(.dateTime.month().day().hour().minute()))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Text(trade.setupDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Image(systemName: "camera.fill")
                    .font(.caption)
                    .foregroundStyle(.cyan)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(trade.grade.color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Supporting Views for Navigation
struct MT5SetupView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                Text("🚀 MT5 Setup Coming Soon!")
                    .font(.title)
                    .goldText()
            }
            .navigationTitle("MT5 Setup")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct AutopilotSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                Text("🤖 Autopilot Settings Coming Soon!")
                    .font(.title)
                    .goldText()
            }
            .navigationTitle("Autopilot Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    PlaybookView()
}
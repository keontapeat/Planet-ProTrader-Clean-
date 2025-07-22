//
//  ViewMigrationHelper.swift
//  Planet ProTrader - Easy View Migration & Restoration
//
//  Quickly restore and migrate previous views
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

struct ViewMigrationHelper {
    
    // MARK: - Quick View Templates
    
    /// Template for creating a new trading view
    static func createTradingView() -> String {
        return """
        struct NewTradingView: View {
            @EnvironmentObject var tradingManager: TradingManager
            @EnvironmentObject var hapticManager: HapticManager
            @State private var isLoading = false
            
            var body: some View {
                NavigationStack {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Header
                            Text("Trading View")
                                .font(DesignSystem.Typography.largeTitle)
                                .goldText()
                            
                            // Gold Price Card
                            VStack(alignment: .leading, spacing: 12) {
                                Text("📈 XAU/USD")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                
                                HStack {
                                    Text(tradingManager.goldPrice.formattedPrice)
                                        .font(DesignSystem.Typography.priceFont)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Text(tradingManager.goldPrice.formattedChange)
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .profitText(tradingManager.goldPrice.isPositive)
                                }
                            }
                            .standardCard()
                            
                            // Quick Actions
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                                ActionButton(title: "Buy", icon: "arrow.up.circle.fill", color: .green) {
                                    hapticManager.impact()
                                }
                                
                                ActionButton(title: "Sell", icon: "arrow.down.circle.fill", color: .red) {
                                    hapticManager.impact()
                                }
                            }
                        }
                        .padding()
                    }
                    .navigationTitle("Trading")
                    .refreshable {
                        await tradingManager.refreshData()
                    }
                }
            }
        }
        
        #Preview {
            NewTradingView()
                .environmentObject(TradingManager.shared)
                .environmentObject(HapticManager.shared)
        }
        """
    }
    
    /// Template for creating a bot management view
    static func createBotView() -> String {
        return """
        struct NewBotView: View {
            @EnvironmentObject var botManager: BotManager
            @EnvironmentObject var hapticManager: HapticManager
            @State private var selectedBot: TradingBot?
            
            var body: some View {
                NavigationStack {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            // Header
                            VStack(spacing: 12) {
                                Text("🤖 AI Trading Bots")
                                    .font(DesignSystem.Typography.largeTitle)
                                    .goldText()
                                
                                Text("Deploy and manage intelligent trading bots")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .standardCard()
                            
                            // Bots List
                            ForEach(botManager.allBots, id: \\.id) { bot in
                                BotCard(bot: bot)
                            }
                        }
                        .padding()
                    }
                    .navigationTitle("AI Bots")
                    .refreshable {
                        await botManager.refreshBots()
                    }
                }
            }
        }
        
        #Preview {
            NewBotView()
                .environmentObject(BotManager.shared)
                .environmentObject(HapticManager.shared)
        }
        """
    }
    
    /// Template for creating a settings view
    static func createSettingsView() -> String {
        return """
        struct NewSettingsView: View {
            @StateObject private var settingsViewModel = SettingsViewModel()
            
            var body: some View {
                NavigationStack {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Header
                            VStack(spacing: 12) {
                                Text("⚙️ Settings")
                                    .font(DesignSystem.Typography.largeTitle)
                                    .goldText()
                                
                                Text("Configure your trading preferences")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .standardCard()
                            
                            // Settings Sections
                            VStack(spacing: 16) {
                                SettingsSection(title: "Trading") {
                                    SettingsRow(title: "Auto Trading", value: "Disabled")
                                    SettingsRow(title: "Risk Level", value: "Medium")
                                    SettingsRow(title: "Max Daily Loss", value: "5%")
                                }
                                
                                SettingsSection(title: "Notifications") {
                                    SettingsRow(title: "Push Notifications", value: "Enabled")
                                    SettingsRow(title: "Trading Alerts", value: "Enabled")
                                    SettingsRow(title: "Price Alerts", value: "Enabled")
                                }
                                
                                SettingsSection(title: "Account") {
                                    SettingsRow(title: "Broker", value: "Coinexx")
                                    SettingsRow(title: "Account Type", value: "Demo")
                                    SettingsRow(title: "Server", value: "Coinexx-Demo")
                                }
                            }
                        }
                        .padding()
                    }
                    .navigationTitle("Settings")
                }
            }
        }
        
        struct SettingsSection<Content: View>: View {
            let title: String
            let content: Content
            
            init(title: String, @ViewBuilder content: () -> Content) {
                self.title = title
                self.content = content()
            }
            
            var body: some View {
                VStack(alignment: .leading, spacing: 12) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    content
                }
                .standardCard()
            }
        }
        
        struct SettingsRow: View {
            let title: String
            let value: String
            
            var body: some View {
                HStack {
                    Text(title)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text(value)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 2)
            }
        }
        
        #Preview {
            NewSettingsView()
        }
        """
    }
    
    /// Template for creating a dashboard view
    static func createDashboardView() -> String {
        return """
        struct NewDashboardView: View {
            @EnvironmentObject var tradingManager: TradingManager
            @EnvironmentObject var botManager: BotManager
            @EnvironmentObject var accountManager: AccountManager
            @StateObject private var dashboardViewModel = TradingDashboardViewModel()
            
            var body: some View {
                NavigationStack {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Welcome Header
                            welcomeHeader
                            
                            // Account Summary
                            accountSummaryCard
                            
                            // Performance Metrics
                            performanceGrid
                            
                            // Recent Activity
                            recentActivitySection
                        }
                        .padding()
                    }
                    .navigationTitle("Dashboard")
                    .refreshable {
                        await dashboardViewModel.refreshDashboard()
                    }
                }
            }
            
            private var welcomeHeader: some View {
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Welcome back!")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text("Planet ProTrader")
                                .font(.title)
                                .fontWeight(.bold)
                                .goldText()
                        }
                        
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .fill(DesignSystem.goldGradient)
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: "crown.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        .pulseEffect()
                    }
                }
                .premiumCard()
            }
            
            private var accountSummaryCard: some View {
                VStack(alignment: .leading, spacing: 16) {
                    Text("💼 Account Summary")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    if let account = accountManager.currentAccount {
                        VStack(spacing: 12) {
                            HStack {
                                Text("Balance:")
                                Spacer()
                                Text(account.formattedBalance)
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                            
                            HStack {
                                Text("Equity:")
                                Spacer()
                                Text(account.formattedProfitLoss)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .profitText(account.profitLoss >= 0)
                            }
                        }
                    }
                }
                .standardCard()
            }
            
            private var performanceGrid: some View {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    StatCard(
                        title: "Today's P&L",
                        value: "\\(String(format: "%.2f", dashboardViewModel.todaysPnL))",
                        icon: "chart.line.uptrend.xyaxis",
                        color: dashboardViewModel.todaysPnL >= 0 ? .green : .red
                    )
                    
                    StatCard(
                        title: "Active Bots",
                        value: "\\(botManager.activeBots.count)",
                        icon: "brain.head.profile",
                        color: .blue
                    )
                    
                    StatCard(
                        title: "Win Rate",
                        value: dashboardViewModel.winRateFormatted,
                        icon: "target",
                        color: .green
                    )
                    
                    StatCard(
                        title: "Portfolio",
                        value: "\\(String(format: "%.0f", dashboardViewModel.portfolioValue))",
                        icon: "briefcase.fill",
                        color: .purple
                    )
                }
            }
            
            private var recentActivitySection: some View {
                VStack(alignment: .leading, spacing: 12) {
                    Text("📊 Recent Activity")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    VStack(spacing: 8) {
                        ForEach(dashboardViewModel.recentSignals.prefix(3), id: \\.id) { signal in
                            HStack {
                                Image(systemName: signal.direction.icon)
                                    .foregroundColor(signal.direction.color)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(signal.symbol)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    Text(signal.source)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Text(signal.formattedEntryPrice)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .standardCard()
            }
        }
        
        #Preview {
            NewDashboardView()
                .environmentObject(TradingManager.shared)
                .environmentObject(BotManager.shared)
                .environmentObject(AccountManager.shared)
        }
        """
    }
    
    // MARK: - Migration Instructions
    static let migrationInstructions = """
    🔄 VIEW MIGRATION HELPER
    
    This helper makes it super easy to restore or create new views for your Planet ProTrader app.
    
    HOW TO USE:
    
    1. **Create New Trading View:**
       - Copy ViewMigrationHelper.createTradingView()
       - Paste into a new .swift file
       - Customize as needed
    
    2. **Create New Bot View:**
       - Copy ViewMigrationHelper.createBotView()
       - Paste into a new .swift file
       - Modify for your bot requirements
    
    3. **Create New Settings View:**
       - Copy ViewMigrationHelper.createSettingsView()
       - Paste into a new .swift file
       - Add your specific settings
    
    4. **Create New Dashboard:**
       - Copy ViewMigrationHelper.createDashboardView()
       - Paste into a new .swift file
       - Customize metrics and layout
    
    QUICK RESTORE:
    If you need to quickly restore a view you had before:
    1. Use the appropriate template above
    2. Replace the content with your previous view code
    3. Update environment objects as needed
    4. Add to ContentView navigation
    
    INTEGRATION:
    - All templates use DesignSystem for consistency
    - Environment objects are pre-configured
    - Preview code included for Xcode canvas
    - Standard error handling patterns included
    
    CUSTOMIZATION TIPS:
    - Change colors using DesignSystem.primaryGold, etc.
    - Use .standardCard() and .premiumCard() for consistent styling
    - Add haptic feedback with hapticManager.impact()
    - Use .goldText() for premium styling
    """
}

#Preview {
    VStack(alignment: .leading, spacing: 16) {
        Text("🔄 View Migration Helper")
            .font(DesignSystem.Typography.largeTitle)
            .goldText()
        
        Text("Quick templates to restore and create views")
            .font(.subheadline)
            .foregroundColor(.secondary)
        
        Text("This helper contains templates for:")
            .font(.headline)
            .fontWeight(.bold)
        
        VStack(alignment: .leading, spacing: 8) {
            Text("• Trading Views")
            Text("• Bot Management Views")
            Text("• Settings Views") 
            Text("• Dashboard Views")
            Text("• Complete migration instructions")
        }
        .font(.subheadline)
        .foregroundColor(.secondary)
        
        Text("Copy the template code and paste into new files!")
            .font(.caption)
            .foregroundColor(.green)
            .fontWeight(.semibold)
    }
    .standardCard()
    .padding()
}
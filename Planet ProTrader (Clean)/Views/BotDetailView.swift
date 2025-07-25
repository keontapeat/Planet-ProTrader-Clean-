// BotDetailView.swift - Comprehensive Bot Analysis & Management

import SwiftUI

struct MyBotDetailView: View {
    let bot: ProTraderBot
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: DetailTab = .overview
    @State private var showingScreenshots = false
    @State private var showingTradeHistory = false
    
    enum DetailTab: String, CaseIterable {
        case overview = "Overview"
        case trades = "Trades"
        case screenshots = "Screenshots"
        case analysis = "Analysis"
        case settings = "Settings"
        
        var icon: String {
            switch self {
            case .overview: return "chart.bar.fill"
            case .trades: return "list.bullet.rectangle"
            case .screenshots: return "camera.fill"
            case .analysis: return "brain.head.profile"
            case .settings: return "gearshape.fill"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Bot Header
                    botHeader
                    
                    // Tab Navigation
                    tabNavigation
                    
                    // Content
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            switch selectedTab {
                            case .overview:
                                overviewContent
                            case .trades:
                                tradesContent
                            case .screenshots:
                                screenshotsContent
                            case .analysis:
                                analysisContent
                            case .settings:
                                settingsContent
                            }
                            
                            Spacer(minLength: 100)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
    
    // MARK: - Bot Header
    
    private var botHeader: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text(bot.name)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 8) {
                        statusBadge
                        confidenceBadge
                    }
                }
                
                Spacer()
                
                Button("Deploy") {
                    // Deploy bot action
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.green, in: Capsule())
            }
            
            // Performance Metrics
            HStack(spacing: 30) {
                metricView("P&L", "+$\(String(format: "%.0f", bot.profitLoss))", .green)
                metricView("Win Rate", "\(String(format: "%.1f", bot.winRate))%", .blue)
                metricView("Trades", "\(bot.totalTrades)", .orange)
                metricView("Confidence", "\(Int(bot.confidence * 100))%", .purple)
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
        .padding(.horizontal, 16)
    }
    
    private var statusBadge: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(bot.isActive ? .green : .red)
                .frame(width: 6, height: 6)
            Text(bot.isActive ? "ACTIVE" : "OFFLINE")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(bot.isActive ? .green : .red)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.white.opacity(0.1), in: Capsule())
    }
    
    private var confidenceBadge: some View {
        Text("⚡ \(bot.confidenceLevel)")
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(.yellow)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.yellow.opacity(0.2), in: Capsule())
    }
    
    private func metricView(_ title: String, _ value: String, _ color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
    }
    
    // MARK: - Tab Navigation
    
    private var tabNavigation: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(DetailTab.allCases, id: \.self) { tab in
                    tabButton(tab)
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 16)
    }
    
    private func tabButton(_ tab: DetailTab) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedTab = tab
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: tab.icon)
                    .font(.system(size: 12, weight: .semibold))
                Text(tab.rawValue)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(selectedTab == tab ? .black : .white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(selectedTab == tab ? .white : .clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.white.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Content Sections
    
    private var overviewContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Bot Statistics
            VStack(alignment: .leading, spacing: 16) {
                Text("📊 BOT STATISTICS")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    statCard("Total Trades", "\(bot.totalTrades)", .blue)
                    statCard("Win Rate", "\(String(format: "%.1f", bot.winRate))%", .green)
                    statCard("Wins", "\(bot.wins)", .green)
                    statCard("Losses", "\(bot.losses)", .red)
                    statCard("Grade", bot.performanceGrade, .yellow)
                    statCard("XP Level", "\(Int(bot.xp))", .orange)
                }
            }
            
            // Recent Performance
            VStack(alignment: .leading, spacing: 16) {
                Text("📈 PERFORMANCE METRICS")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                VStack(spacing: 12) {
                    performanceRow("Total P&L", bot.profitLoss, .green)
                    performanceRow("Confidence", bot.confidence * 100, .blue)
                    performanceRow("XP Points", bot.xp, .purple)
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
            
            // Strategy Info
            VStack(alignment: .leading, spacing: 16) {
                Text("🧠 STRATEGY ANALYSIS")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 12) {
                    strategyRow("Primary Strategy", bot.strategy.rawValue)
                    strategyRow("Specialization", bot.specialization.rawValue)
                    strategyRow("AI Engine", bot.aiEngine.rawValue)
                    strategyRow("VPS Status", bot.vpsStatus.rawValue)
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
    }
    
    private var tradesContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("💹 TRADE HISTORY")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("Export") {
                    // Export trades
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.blue)
            }
            
            // Trade Summary
            HStack(spacing: 20) {
                tradeSummaryCard("Winning Trades", "\(bot.wins)", .green)
                tradeSummaryCard("Losing Trades", "\(bot.losses)", .red)
                tradeSummaryCard("Total Trades", "\(bot.totalTrades)", .blue)
            }
            
            // Sample Trades List (since we don't have actual trade data)
            VStack(alignment: .leading, spacing: 12) {
                Text("Recent Trades (Sample)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                ForEach(0..<10, id: \.self) { index in
                    sampleTradeRow(index: index)
                }
            }
        }
    }
    
    private var screenshotsContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("📸 TRADE SCREENSHOTS")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("View All") {
                    showingScreenshots = true
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.blue)
            }
            
            // Screenshots Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ForEach(0..<6, id: \.self) { index in
                    screenshotCard(index: index)
                }
            }
            
            // Screenshot Stats
            VStack(alignment: .leading, spacing: 12) {
                Text("📊 SCREENSHOT STATISTICS")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                HStack(spacing: 20) {
                    screenshotStat("Total Screenshots", "\(bot.screenshotUrls.count + 47)")
                    screenshotStat("This Week", "12")
                    screenshotStat("Best Trades", "8")
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
    
    private var analysisContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("🧠 AI ANALYSIS")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            // AI Insights
            VStack(alignment: .leading, spacing: 16) {
                Text("Key Insights")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                ForEach(sampleInsights, id: \.self) { insight in
                    insightRow(insight)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.purple.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.purple.opacity(0.3), lineWidth: 1)
                    )
            )
            
            // Learning History
            VStack(alignment: .leading, spacing: 16) {
                Text("📚 LEARNING HISTORY")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                if bot.learningHistory.isEmpty {
                    Text("No learning sessions recorded yet")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(16)
                } else {
                    ForEach(bot.learningHistory.indices, id: \.self) { index in
                        learningSessionRow(bot.learningHistory[index])
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.blue.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.blue.opacity(0.3), lineWidth: 1)
                    )
            )
            
            // Performance Prediction
            VStack(alignment: .leading, spacing: 16) {
                Text("🔮 PERFORMANCE PREDICTION")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                predictionCard("Next Week", "+$\(Int(bot.profitLoss * 0.1))", bot.confidence)
                predictionCard("Next Month", "+$\(Int(bot.profitLoss * 0.4))", bot.confidence * 0.9)
            }
        }
    }
    
    private var settingsContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("⚙️ BOT SETTINGS")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            // Control Settings
            VStack(alignment: .leading, spacing: 16) {
                settingRow("Auto Trading", bot.isActive) {
                    // Toggle auto trading
                }
                settingRow("VPS Connected", bot.vpsStatus == .connected) {
                    // Toggle VPS connection
                }
                settingRow("Screenshot Mode", !bot.screenshotUrls.isEmpty) {
                    // Toggle screenshots
                }
                settingRow("Learning Mode", !bot.learningHistory.isEmpty) {
                    // Toggle learning
                }
            }
            
            // Bot Information
            VStack(alignment: .leading, spacing: 16) {
                Text("🤖 BOT INFORMATION")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 12) {
                    infoRow("Bot Number", "#\(bot.botNumber)")
                    infoRow("Created", bot.lastTraining?.formatted(date: .abbreviated, time: .shortened) ?? "Unknown")
                    infoRow("Last Training", bot.lastTraining?.formatted(date: .abbreviated, time: .shortened) ?? "Never")
                    infoRow("Confidence Level", bot.confidenceLevel)
                    infoRow("Performance Grade", bot.performanceGrade)
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
            
            // Danger Zone
            VStack(alignment: .leading, spacing: 16) {
                Text("⚠️ DANGER ZONE")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.red)
                
                Button("Reset Bot Statistics") {
                    // Reset stats
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.red)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.red.opacity(0.5), lineWidth: 1)
                )
                
                Button("Delete Bot") {
                    // Delete bot
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.red, in: RoundedRectangle(cornerRadius: 8))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.red.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.red.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Helper Views and Data
    
    private var sampleInsights: [String] {
        [
            "Strong performance in trending markets",
            "Excellent risk management during volatility",
            "High accuracy in entry point predictions",
            "Successfully adapts to market conditions",
            "Optimal position sizing for maximum returns"
        ]
    }
    
    private func statCard(_ title: String, _ value: String, _ color: Color) -> some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, minHeight: 60)
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
    
    private func performanceRow(_ title: String, _ value: Double, _ color: Color) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text(title == "Total P&L" ? 
                 (value >= 0 ? "+$\(String(format: "%.0f", value))" : "-$\(String(format: "%.0f", abs(value)))") :
                 String(format: "%.1f", value))
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(value >= 0 ? .green : .red)
        }
    }
    
    private func strategyRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
        }
    }
    
    private func tradeSummaryCard(_ title: String, _ value: String, _ color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, minHeight: 50)
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private func sampleTradeRow(index: Int) -> some View {
        let pairs = ["EURUSD", "GBPJPY", "XAUUSD", "USDJPY", "GBPUSD"]
        let types = ["BUY", "SELL"]
        let pnls = [127.50, -45.20, 234.80, 89.40, -67.10, 156.70, 78.30, -123.90, 199.20, 56.80]
        let times = ["2m ago", "5m ago", "12m ago", "18m ago", "25m ago", "31m ago", "42m ago", "1h ago", "1.5h ago", "2h ago"]
        
        let pair = pairs[index % pairs.count]
        let type = types[index % types.count]
        let pnl = pnls[index % pnls.count]
        let timeAgo = times[index % times.count]
        
        return HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(pair)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                Text(type)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(type == "BUY" ? .green : .red)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(pnl >= 0 ? "+$\(String(format: "%.2f", pnl))" : "-$\(String(format: "%.2f", abs(pnl)))")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(pnl >= 0 ? .green : .red)
                Text(timeAgo)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private func screenshotCard(index: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Screenshot placeholder
            Rectangle()
                .fill(.white.opacity(0.1))
                .frame(height: 120)
                .overlay(
                    VStack {
                        Image(systemName: "camera.fill")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.5))
                        Text("Screenshot")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                    }
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Trade #\(index + 1)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                Text("\(index + 1)h ago")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private func screenshotStat(_ title: String, _ value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.blue)
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
    
    private func insightRow(_ insight: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 14))
                .foregroundColor(.yellow)
            
            Text(insight)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
    private func learningSessionRow(_ session: LearningSession) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Session \(session.timestamp.formatted(date: .abbreviated, time: .shortened))")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("+\(String(format: "%.0f", session.xpGained)) XP")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.green)
            }
            
            Text("Data Points: \(session.dataPoints) • Patterns: \(session.patternsDiscovered.count)")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private func predictionCard(_ period: String, _ value: String, _ confidence: Double) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(period)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.green)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Confidence")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                Text("\(Int(confidence * 100))%")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.blue)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private func settingRow(_ title: String, _ isEnabled: Bool, action: @escaping () -> Void) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: action) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(isEnabled ? .green : .white.opacity(0.3))
                    .frame(width: 50, height: 30)
                    .overlay(
                        Circle()
                            .fill(.white)
                            .frame(width: 26, height: 26)
                            .offset(x: isEnabled ? 10 : -10)
                    )
            }
        }
        .padding(.vertical, 8)
    }
    
    private func infoRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    MyBotDetailView(
        bot: ProTraderBot(
            botNumber: 1,
            name: "ProBot-0001",
            xp: 450.0,
            confidence: 0.89,
            strategy: .scalping,
            wins: 127,
            losses: 23,
            totalTrades: 150,
            profitLoss: 2847.50,
            learningHistory: [],
            lastTraining: Date(),
            isActive: true,
            specialization: .goldExpert,
            aiEngine: .neuralNetwork,
            vpsStatus: .connected,
            screenshotUrls: []
        )
    )
    .preferredColorScheme(.dark)
}
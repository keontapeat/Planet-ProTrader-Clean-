//
//  FastDashboardSections.swift
//  Planet ProTrader (Clean)
//
//  Performance-optimized dashboard sections using Apple's best practices
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI
import Foundation

// MARK: - Fast Header Stats Section

struct FastHeaderStatsSection: View {
    @ObservedObject var armyManager: ProTraderArmyManager
    let animateElements: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // Enhanced Army Status Banner
            armyStatusBanner
            
            // Enhanced Key Metrics Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                Group {
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
    }
    
    private var armyStatusBanner: some View {
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
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}

// MARK: - Fast Bot Army Section

struct FastBotArmySection: View {
    @ObservedObject var armyManager: ProTraderArmyManager
    
    var body: some View {
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
                            Task.detached(priority: .background) {
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
                            Task.detached(priority: .background) {
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
                            // Will be handled by parent view
                        }
                    )
                    
                    QuickDeployButton(
                        title: "VPS Sync",
                        subtitle: "Upload to server",
                        icon: "icloud.and.arrow.up",
                        color: .blue,
                        action: {
                            Task.detached(priority: .background) {
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
}

// MARK: - Fast Army Overview Section

struct FastArmyOverviewSection: View {
    @ObservedObject var armyManager: ProTraderArmyManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("🏛️")
                    .font(.title2)
                
                Text("ARMY OVERVIEW")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                let stats = armyManager.getArmyStats()
                
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
}

// MARK: - Fast VPS Status Section

struct FastVPSStatusSection: View {
    @ObservedObject var armyManager: ProTraderArmyManager
    @Binding var showingVPSStatus: Bool
    
    var body: some View {
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
}

// MARK: - Fast Training Section

struct FastTrainingSection: View {
    @ObservedObject var armyManager: ProTraderArmyManager
    @Binding var showingImporter: Bool
    
    var body: some View {
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
                    VStack(spacing: 8) {
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
                            Task.detached(priority: .background) {
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
}

// MARK: - Fast Live Bots Section

struct FastLiveBotsSection: View {
    @ObservedObject var armyManager: ProTraderArmyManager
    @Binding var selectedBot: ProTraderBot?
    @Binding var showingBotDetails: Bool
    
    var body: some View {
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
                // Only show top 4 performers to avoid performance issues
                ForEach(Array(armyManager.getTopPerformers(count: 4).enumerated()), id: \.offset) { _, bot in
                    LiveBotCard(bot: bot) {
                        selectedBot = bot
                        showingBotDetails = true
                    }
                }
            }
        }
    }
}

// MARK: - Fast Performance Section

struct FastPerformanceSection: View {
    @ObservedObject var armyManager: ProTraderArmyManager
    @Binding var selectedTimeframe: String
    let timeframes: [String]
    
    var body: some View {
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
                
                // Use a simplified chart view for better performance
                FastConfidenceChartView(bots: Array(armyManager.bots.prefix(100))) // Limit to 100 bots
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
}

// MARK: - Fast Top Performers Section

struct FastTopPerformersSection: View {
    @ObservedObject var armyManager: ProTraderArmyManager
    @Binding var selectedBot: ProTraderBot?
    @Binding var showingBotDetails: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Text("🏆")
                    .font(.title2)
                
                Text("TOP PERFORMERS")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
            }
            
            LazyVStack(spacing: 12) {
                // Limit to top 5 for performance
                ForEach(Array(armyManager.getTopPerformers(count: 5).enumerated()), id: \.offset) { index, bot in
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
}

// MARK: - Fast Screenshots Section

struct FastScreenshotsSection: View {
    @ObservedObject var armyManager: ProTraderArmyManager
    @Binding var showingScreenshotGallery: Bool
    
    var body: some View {
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
}

// MARK: - Performance Optimized Chart

struct FastConfidenceChartView: View {
    let bots: [ProTraderBot]
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            // Simple bar chart instead of complex chart
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(confidenceBuckets, id: \.range) { bucket in
                    VStack(spacing: 4) {
                        Rectangle()
                            .fill(bucket.color)
                            .frame(width: (width - 40) / 7, height: CGFloat(bucket.count) / CGFloat(maxCount) * (height - 40))
                        
                        Text(bucket.label)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
    
    private var confidenceBuckets: [(range: String, count: Int, color: Color, label: String)] {
        let ranges = [
            (0.0..<0.3, "0-30%", Color.red),
            (0.3..<0.5, "30-50%", Color.orange),
            (0.5..<0.6, "50-60%", Color.yellow),
            (0.6..<0.7, "60-70%", Color.green),
            (0.7..<0.8, "70-80%", Color.blue),
            (0.8..<0.9, "80-90%", Color.purple),
            (0.9...1.0, "90%+", Color.pink)
        ]
        
        return ranges.map { range, label, color in
            let count = bots.filter { range.contains($0.confidence) }.count
            return (range: label, count: count, color: color, label: label)
        }
    }
    
    private var maxCount: Int {
        confidenceBuckets.map(\.count).max() ?? 1
    }
}

#Preview {
    VStack {
        FastHeaderStatsSection(armyManager: ProTraderArmyManager(), animateElements: true)
        FastBotArmySection(armyManager: ProTraderArmyManager())
    }
    .background(Color.black)
    .preferredColorScheme(.dark)
}
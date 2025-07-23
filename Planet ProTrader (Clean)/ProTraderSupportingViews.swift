//
//  ProTraderSupportingViews.swift
//  Planet ProTrader - Solar System Edition
//
//  Created by Keonta Peat on 1/25/25.
//

import SwiftUI

// MARK: - Metric Cards and UI Components

struct ProTraderMetricCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let trend: TrendDirection
    
    enum TrendDirection {
        case up, down, stable
        
        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .stable: return "minus"
            }
        }
        
        var color: Color {
            switch self {
            case .up: return .green
            case .down: return .red
            case .stable: return .orange
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(color)
                
                Spacer()
                
                Image(systemName: trend.icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(trend.color)
            }
            
            Text(value)
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundStyle(.white)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white)
                
                Text(subtitle)
                    .font(.system(size: 10, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }
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

struct ArmyStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(color)
            
            Text(value)
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundStyle(.white)
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
                
                Text(subtitle)
                    .font(.system(size: 8, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
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

struct QuickActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.blue)
                    .frame(width: 28)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 10, weight: .regular, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                }
                
                Spacer()
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
        .buttonStyle(.plain)
    }
}

struct TopPerformerRow: View {
    let rank: Int
    let bot: ProTraderBot
    let onTap: () -> Void
    
    var rankColor: Color {
        switch rank {
        case 1: return .orange
        case 2: return .gray
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2)
        default: return .blue
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Enhanced Rank with medal
                ZStack {
                    Circle()
                        .fill(rankColor.opacity(0.2))
                        .frame(width: 36, height: 36)
                    
                    if rank <= 3 {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(rankColor)
                    } else {
                        Text("\(rank)")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(rankColor)
                    }
                }
                
                // Enhanced Bot info
                VStack(alignment: .leading, spacing: 4) {
                    Text(bot.name)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    HStack(spacing: 8) {
                        Text(bot.strategy.rawValue)
                            .font(.system(size: 10, weight: .regular, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                        
                        Text("•")
                            .foregroundStyle(.white.opacity(0.3))
                        
                        Text(bot.aiEngine.rawValue)
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(.blue.opacity(0.8))
                    }
                }
                
                Spacer()
                
                // Enhanced Performance indicators
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(bot.performanceGrade)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(bot.performanceGrade == "A+" ? .orange : .white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(bot.performanceGrade == "A+" ? .orange.opacity(0.2) : .white.opacity(0.1))
                            )
                        
                        Circle()
                            .fill(confidenceColor(bot.confidence))
                            .frame(width: 8, height: 8)
                    }
                    
                    Text(String(format: "%.1f%%", bot.confidence * 100))
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
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
}

struct ConfidenceChartView: View {
    let bots: [ProTraderBot]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
                
                VStack(spacing: 12) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(.blue.opacity(0.6))
                    
                    Text("Advanced Confidence Distribution")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                    
                    // Simple confidence breakdown
                    HStack(spacing: 16) {
                        let stats = calculateConfidenceStats()
                        
                        VStack(spacing: 2) {
                            Text("\(stats.godmode)")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(.orange)
                            Text("GODMODE")
                                .font(.system(size: 8, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        
                        VStack(spacing: 2) {
                            Text("\(stats.elite)")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(.purple)
                            Text("ELITE")
                                .font(.system(size: 8, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        
                        VStack(spacing: 2) {
                            Text("\(stats.learning)")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(.blue)
                            Text("LEARNING")
                                .font(.system(size: 8, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }
                }
            }
        }
    }
    
    private func calculateConfidenceStats() -> (godmode: Int, elite: Int, learning: Int) {
        let godmode = bots.filter { $0.confidence >= 0.95 }.count
        let elite = bots.filter { $0.confidence >= 0.8 && $0.confidence < 0.95 }.count
        let learning = bots.filter { $0.confidence < 0.8 }.count
        
        return (godmode, elite, learning)
    }
}

// MARK: - Modal Views

struct BotDeploymentView: View {
    let armyManager: ProTraderArmyManager
    @Environment(\.dismiss) private var dismiss
    @State private var deploymentCount = 100
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("🚀 Deploy ProTrader Bots")
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .foregroundStyle(.white)
                
                Text("Choose how many bots to deploy to your VPS")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 16) {
                    Text("Deployment Count: \(deploymentCount)")
                        .font(.headline)
                        .foregroundStyle(.white)
                    
                    Slider(value: Binding(
                        get: { Double(deploymentCount) },
                        set: { deploymentCount = Int($0) }
                    ), in: 1...5000, step: 1)
                    .tint(.blue)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.white.opacity(0.1))
                )
                
                VStack(spacing: 12) {
                    Button("Deploy \(deploymentCount) Bots") {
                        Task {
                            await armyManager.deployBots(count: deploymentCount)
                            dismiss()
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .cornerRadius(12)
                    
                    Button("Deploy All 5,000 Bots") {
                        Task {
                            await armyManager.deployAllBots()
                            dismiss()
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.orange)
                    .cornerRadius(12)
                }
                
                Spacer()
            }
            .padding()
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Bot Deployment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

struct MassiveDataDownloadView: View {
    let armyManager: ProTraderArmyManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("📊 Massive Data Download")
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .foregroundStyle(.white)
                
                Text("Download historical data to supercharge your bot army")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                Button("Start Download & Training") {
                    Task {
                        // Simulate massive data download and training
                        await armyManager.trainWithHistoricalData(csvData: sampleLargeDataset)
                        dismiss()
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.purple)
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Data Download")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.blue)
                }
            }
        }
    }
    
    private let sampleLargeDataset = """
Date,Time,Open,High,Low,Close,Volume
2023.01.01,00:00,1800.50,1810.20,1795.80,1805.10,2500
2023.01.01,01:00,1805.10,1815.75,1800.30,1812.45,2750
2023.01.01,02:00,1812.45,1820.60,1808.20,1817.80,2620
2023.01.01,03:00,1817.80,1825.40,1815.90,1823.25,2480
2023.01.01,04:00,1823.25,1830.70,1820.60,1828.85,2890
"""
}

struct CSVImporterView: View {
    let armyManager: ProTraderArmyManager
    @Environment(\.dismiss) private var dismiss
    @State private var csvContent = ""
    @State private var isImporting = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("💎 ProTrader Data Import")
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .foregroundStyle(.white)
                
                Text("Import historical data to train your 5,000 ProTrader bot army")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                TextEditor(text: $csvContent)
                    .frame(height: 300)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                
                Button("Train Army with Data") {
                    importData()
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
                .disabled(csvContent.isEmpty || isImporting)
                
                if isImporting {
                    ProgressView("Training army...")
                        .tint(.blue)
                }
                
                Spacer()
            }
            .padding()
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Data Import")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.blue)
                }
            }
        }
    }
    
    private func importData() {
        isImporting = true
        Task {
            _ = await armyManager.trainWithHistoricalData(csvData: csvContent)
            await MainActor.run {
                isImporting = false
                dismiss()
            }
        }
    }
}

struct TrainingResultsView: View {
    let results: TrainingResults
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Text("🎉 ProTrader Training Complete!")
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .foregroundStyle(.white)
                    
                    VStack(spacing: 16) {
                        ResultCard(title: "Bots Trained", value: "\(results.botsTrained)", color: .blue)
                        ResultCard(title: "GODMODE Upgrades", value: "\(results.newGodmodeBots)", color: .orange)
                        ResultCard(title: "Total XP Gained", value: String(format: "%.0f", results.totalXPGained), color: .green)
                        ResultCard(title: "Elite Bots", value: "\(results.newEliteBots)", color: .purple)
                    }
                    
                    Text(results.summary)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                .padding()
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Training Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

struct ResultCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(color)
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct BotDetailView: View {
    let bot: ProTraderBot
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text(bot.name)
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .foregroundStyle(.white)
                    
                    HStack {
                        Text(bot.confidenceLevel)
                            .font(.headline)
                            .foregroundStyle(.blue)
                        Spacer()
                        Text("XP: \(Int(bot.xp))")
                            .font(.subheadline)
                            .foregroundStyle(.blue)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        DetailRow(title: "Strategy", value: bot.strategy.rawValue)
                        DetailRow(title: "AI Engine", value: bot.aiEngine.rawValue)
                        DetailRow(title: "Win Rate", value: String(format: "%.1f%%", bot.winRate))
                        DetailRow(title: "P&L", value: String(format: "$%.2f", bot.profitLoss))
                        DetailRow(title: "Grade", value: bot.performanceGrade)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    Spacer()
                }
                .padding()
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Bot Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.white.opacity(0.7))
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
        }
    }
}

struct VPSStatusRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.white.opacity(0.7))
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
        }
    }
}

struct VPSStatusView: View {
    let vpsManager: SimpleVPSManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("🖥️ VPS Status")
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .foregroundStyle(.white)
                
                VStack(alignment: .leading, spacing: 12) {
                    VPSStatusRow(title: "Connection", value: vpsManager.connectionStatus.rawValue)
                    VPSStatusRow(title: "Active Bots", value: "\(vpsManager.activeBots.count)")
                    VPSStatusRow(title: "Last Ping", value: "\(Int(vpsManager.lastPing))ms")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("VPS Status")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

struct StatusRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.white.opacity(0.7))
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
        }
    }
}

struct ScreenshotGalleryView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("📸 A+ Screenshots")
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .foregroundStyle(.white)
                
                Text("Gallery coming soon...")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
                
                Spacer()
            }
            .padding()
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Screenshots")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

struct ProTraderGPTChatView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("🤖 ProTrader AI Chat")
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .foregroundStyle(.white)
                
                Text("AI Chat interface coming soon...")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
                
                Spacer()
            }
            .padding()
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("AI Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

#Preview {
    ProTraderMetricCard(
        icon: "brain.head.profile",
        title: "Avg Confidence",
        value: "87.5%",
        subtitle: "Target: 90%+",
        color: .blue,
        trend: .up
    )
    .preferredColorScheme(.dark)
}
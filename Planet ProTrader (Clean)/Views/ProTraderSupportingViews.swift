//
//  ProTraderSupportingViews.swift
//  Planet ProTrader - Solar System Edition
//
//  Created by Keonta Peat on 1/25/25.
//

import SwiftUI
import Foundation

// MARK: - ProTrader Metric Card
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
            case .stable: return .gray
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(color)
                
                Spacer()
                
                Image(systemName: trend.icon)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(trend.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
                
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

// MARK: - Army Stat Card
struct ArmyStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(color)
            
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            Text(title)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.8))
            
            Text(subtitle)
                .font(.system(size: 8, weight: .regular, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
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
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.blue)
                
                Text(title)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text(subtitle)
                    .font(.system(size: 10, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
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
        .buttonStyle(.plain)
    }
}

// MARK: - Top Performer Row
struct TopPerformerRow: View {
    let rank: Int
    let bot: ProTraderBot
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Rank
                ZStack {
                    Circle()
                        .fill(rankColor)
                        .frame(width: 32, height: 32)
                    
                    Text("\(rank)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                
                // Bot Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(bot.name)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        
                        Spacer()
                        
                        Text(bot.confidenceLevel)
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(confidenceColor(bot.confidence))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(confidenceColor(bot.confidence).opacity(0.2), in: Capsule())
                    }
                    
                    HStack {
                        Text("Confidence: \(String(format: "%.1f%%", bot.confidence * 100))")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.7))
                        
                        Spacer()
                        
                        Text("P&L: \(formatCurrency(bot.profitLoss))")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(bot.profitLoss >= 0 ? .green : .red)
                    }
                }
                
                // Status indicator
                Circle()
                    .fill(bot.isActive ? .green : .gray)
                    .frame(width: 8, height: 8)
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
        .buttonStyle(.plain)
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return .orange
        case 2: return .gray
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2)
        default: return .blue
        }
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

// MARK: - Confidence Chart View
struct ConfidenceChartView: View {
    let bots: [ProTraderBot]
    
    private var confidenceData: [(String, Int, Color)] {
        let godmode = bots.filter { $0.confidence >= 0.95 }.count
        let godlike = bots.filter { $0.confidence >= 0.9 && $0.confidence < 0.95 }.count
        let elite = bots.filter { $0.confidence >= 0.8 && $0.confidence < 0.9 }.count
        let pro = bots.filter { $0.confidence >= 0.7 && $0.confidence < 0.8 }.count
        let advanced = bots.filter { $0.confidence >= 0.6 && $0.confidence < 0.7 }.count
        let learning = bots.filter { $0.confidence < 0.6 }.count
        
        return [
            ("GODMODE", godmode, .orange),
            ("GODLIKE", godlike, .red),
            ("ELITE", elite, .purple),
            ("PRO", pro, .blue),
            ("ADVANCED", advanced, .green),
            ("LEARNING", learning, .gray)
        ]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Chart bars
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(confidenceData, id: \.0) { category, count, color in
                    VStack(spacing: 8) {
                        // Bar
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [color, color.opacity(0.6)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: CGFloat(count) / CGFloat(bots.count) * 120 + 20)
                        
                        // Category label
                        VStack(spacing: 2) {
                            Text("\(count)")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            
                            Text(category)
                                .font(.system(size: 8, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                    }
                }
            }
            
            // Legend
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                ForEach(confidenceData, id: \.0) { category, count, color in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(color)
                            .frame(width: 8, height: 8)
                        
                        Text(category)
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.8))
                        
                        Spacer()
                        
                        Text("\(count)")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                }
            }
        }
    }
}

// MARK: - CSV Importer View
struct CSVImporterView: View {
    let armyManager: ProTraderArmyManager
    @Environment(\.dismiss) private var dismiss
    @State private var csvText = ""
    @State private var isImporting = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Import Historical Data")
                        .font(.title2.bold())
                    
                    Text("Paste your CSV data below to train the ProTrader Army:")
                        .font(.body)
                        .foregroundStyle(.secondary)
                    
                    TextEditor(text: $csvText)
                        .font(.system(.caption, design: .monospaced))
                        .padding(12)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .frame(minHeight: 200)
                }
                
                Button(action: importData) {
                    HStack {
                        if isImporting {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "brain.head.profile")
                        }
                        
                        Text(isImporting ? "Training Bots..." : "Train Army")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(csvText.isEmpty || isImporting)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Data Import")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func importData() {
        isImporting = true
        
        Task {
            let results = await armyManager.trainWithHistoricalData(csvData: csvText)
            
            await MainActor.run {
                isImporting = false
                GlobalToastManager.shared.show("🎓 Training completed! \(results.newGodmodeBots) new GODMODE bots!", type: .success)
                dismiss()
            }
        }
    }
}

// MARK: - Training Results View
struct TrainingResultsView: View {
    let results: TrainingResults
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Success Header
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.green)
                    
                    Text("Training Complete!")
                        .font(.title.bold())
                    
                    Text("Your ProTrader Army has been successfully trained")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Results Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    ResultCard(title: "Bots Trained", value: "\(results.botsTrained)", color: .blue)
                    ResultCard(title: "Data Points", value: "\(results.dataPointsProcessed)", color: .green)
                    ResultCard(title: "New GODMODE", value: "\(results.newGodmodeBots)", color: .orange)
                    ResultCard(title: "New ELITE", value: "\(results.newEliteBots)", color: .purple)
                }
                
                Spacer()
                
                Button("Continue") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding()
            .navigationTitle("Training Results")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ResultCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title.bold())
                .foregroundStyle(color)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Bot Detail View
struct BotDetailView: View {
    let bot: ProTraderBot
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Bot Header
                    VStack(alignment: .leading, spacing: 12) {
                        Text(bot.name)
                            .font(.title.bold())
                        
                        HStack {
                            Text(bot.confidenceLevel)
                                .font(.headline)
                                .foregroundColor(confidenceColor(bot.confidence))
                            
                            Spacer()
                            
                            Circle()
                                .fill(bot.isActive ? .green : .gray)
                                .frame(width: 12, height: 12)
                        }
                    }
                    
                    // Bot Stats
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        StatCard(title: "Confidence", value: String(format: "%.1f%%", bot.confidence * 100))
                        StatCard(title: "Win Rate", value: String(format: "%.1f%%", bot.winRate))
                        StatCard(title: "P&L", value: formatCurrency(bot.profitLoss))
                        StatCard(title: "Total Trades", value: "\(bot.totalTrades)")
                        StatCard(title: "Strategy", value: bot.strategy.rawValue)
                        StatCard(title: "Specialization", value: bot.specialization.rawValue)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Bot Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
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

struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2.bold())
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - VPS Status View
struct VPSStatusView: View {
    let vpsManager: SimpleVPSManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Connection Status
                VStack(spacing: 16) {
                    Image(systemName: vpsManager.isConnected ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(vpsManager.isConnected ? .green : .red)
                    
                    Text(vpsManager.connectionStatus.rawValue)
                        .font(.title.bold())
                    
                    if vpsManager.isConnected {
                        Text("VPS is online and ready")
                            .foregroundStyle(.secondary)
                    }
                }
                
                // VPS Info
                VStack(alignment: .leading, spacing: 12) {
                    InfoRow(label: "Server IP", value: "172.234.201.231")
                    InfoRow(label: "Status", value: vpsManager.connectionStatus.rawValue)
                    if vpsManager.lastPing > 0 {
                        InfoRow(label: "Ping", value: "\(String(format: "%.0f", vpsManager.lastPing))ms")
                    }
                    InfoRow(label: "Active Bots", value: "\(vpsManager.activeBots.count)")
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                if !vpsManager.isConnected {
                    Button("Connect to VPS") {
                        Task {
                            await vpsManager.connectToVPS()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("VPS Status")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Placeholder Views
struct ScreenshotGalleryView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("🚧 Coming Soon")
                    .font(.title)
                Text("Screenshot gallery feature in development")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Screenshots")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct ProTraderGPTChatView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("🤖 AI Assistant")
                    .font(.title)
                Text("ProTrader GPT chat coming soon")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("ProTrader GPT")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct BotDeploymentView: View {
    let armyManager: ProTraderArmyManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("🚀 Bot Deployment")
                    .font(.title.bold())
                
                if armyManager.isDeploying {
                    VStack(spacing: 16) {
                        ProgressView(value: armyManager.deploymentProgress)
                        Text("Deploying bots: \(Int(armyManager.deploymentProgress * 100))%")
                    }
                } else {
                    Text("✅ Deployment Complete!")
                        .font(.headline)
                        .foregroundStyle(.green)
                    
                    Text("\(armyManager.deployedBots) bots deployed to VPS")
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Deployment")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct MassiveDataDownloadView: View {
    let armyManager: ProTraderArmyManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("📊 Data Download")
                    .font(.title)
                Text("Massive data download feature coming soon")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Data Download")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
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
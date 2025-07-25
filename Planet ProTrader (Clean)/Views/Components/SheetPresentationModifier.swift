//
//  SheetPresentationModifier.swift
//  Planet ProTrader (Clean)
//
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

struct SheetPresentationModifier: ViewModifier {
    @Binding var showingImporter: Bool
    @Binding var showingTrainingResults: Bool
    @Binding var showingBotDetails: Bool
    @Binding var showingVPSStatus: Bool
    @Binding var showingScreenshotGallery: Bool
    @Binding var showingGPTChat: Bool
    @Binding var showingBotDeployment: Bool
    @Binding var showingMassiveDataDownload: Bool
    var selectedBot: RealTimeProTraderBot?
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showingImporter) {
                CSVImporterView()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingTrainingResults) {
                TrainingResultsView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingBotDetails) {
                if let bot = selectedBot {
                    BotDetailsView(bot: bot)
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                } else {
                    Text("No bot selected")
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black)
                }
            }
            .sheet(isPresented: $showingVPSStatus) {
                VPSStatusView()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingScreenshotGallery) {
                ScreenshotGalleryView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingGPTChat) {
                GPTChatView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingBotDeployment) {
                BotDeploymentView()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingMassiveDataDownload) {
                MassiveDataDownloadView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
    }
}

// MARK: - Supporting Sheet Views

struct CSVImporterView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isImporting = false
    @State private var importProgress = 0.0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                headerSection
                importOptionsSection
                if isImporting {
                    progressSection
                }
                Spacer()
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .navigationTitle("Data Import")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(.blue)
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 48))
                .foregroundStyle(.blue)
            
            Text("Import Trading Data")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            Text("Upload CSV files with historical trading data to train your ProTrader Army")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
    }
    
    private var importOptionsSection: some View {
        VStack(spacing: 16) {
            Button {
                startImport()
            } label: {
                HStack {
                    Image(systemName: "icloud.and.arrow.down.fill")
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Import Sample Data")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                        
                        Text("Use built-in historical market data")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .opacity(0.7)
                    }
                    
                    Spacer()
                }
                .foregroundStyle(.white)
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.blue.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.blue.opacity(0.5), lineWidth: 1)
                        )
                )
            }
            .disabled(isImporting)
            
            Button {
                startImport()
            } label: {
                HStack {
                    Image(systemName: "folder.fill")
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Choose CSV File")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                        
                        Text("Select your custom trading data")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .opacity(0.7)
                    }
                    
                    Spacer()
                }
                .foregroundStyle(.white)
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.white.opacity(0.1), lineWidth: 1)
                        )
                )
            }
            .disabled(isImporting)
        }
    }
    
    private var progressSection: some View {
        VStack(spacing: 12) {
            Text("Processing Data...")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
            
            ProgressView(value: importProgress)
                .tint(.blue)
                .background(.white.opacity(0.2))
                .clipShape(Capsule())
            
            Text("\(Int(importProgress * 100))% Complete")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.05))
        )
    }
    
    private func startImport() {
        isImporting = true
        importProgress = 0.0
        
        Task {
            for i in 0...100 {
                await MainActor.run {
                    importProgress = Double(i) / 100.0
                }
                try? await Task.sleep(nanoseconds: 50_000_000)
            }
            
            await MainActor.run {
                isImporting = false
                dismiss()
            }
        }
    }
}

struct TrainingResultsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var mockResults = MockTrainingResults()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    VStack(spacing: 16) {
                        Text("🎯 Training Complete!")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        
                        Text(mockResults.summary)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        ResultCard(
                            title: "Bots Trained",
                            value: "\(mockResults.botsTrained)",
                            icon: "brain.head.profile",
                            color: .blue
                        )
                        
                        ResultCard(
                            title: "New GODMODE",
                            value: "\(mockResults.newGodmodeBots)",
                            icon: "crown.fill",
                            color: .orange
                        )
                        
                        ResultCard(
                            title: "Data Points",
                            value: "\(mockResults.dataPointsProcessed)",
                            icon: "chart.bar.fill",
                            color: .green
                        )
                        
                        ResultCard(
                            title: "XP Gained",
                            value: String(format: "%.0f", mockResults.totalXPGained),
                            icon: "star.fill",
                            color: .purple
                        )
                    }
                }
                .padding(24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .navigationTitle("Training Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(.blue)
                }
            }
        }
    }
}

struct MockTrainingResults {
    let botsTrained = 5000
    let newGodmodeBots = 347
    let dataPointsProcessed = 125000
    let totalXPGained: Double = 1250000
    
    var summary: String {
        return """
        Training Complete!
        • Bots Trained: \(botsTrained)
        • Data Points: \(dataPointsProcessed)
        • XP Gained: \(String(format: "%.0f", totalXPGained))
        • New GODMODE: \(newGodmodeBots)
        """
    }
}

struct ResultCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct BotDetailsView: View {
    let bot: RealTimeProTraderBot
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    botHeaderSection
                    botStatsGrid
                    additionalInfoSection
                }
                .padding(24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .navigationTitle("Bot Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(.blue)
                }
            }
        }
    }
    
    private var botHeaderSection: some View {
        VStack(spacing: 12) {
            Text("🤖")
                .font(.system(size: 48))
            
            Text(bot.name)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            HStack(spacing: 8) {
                Text(bot.strategy)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
                
                Text("•")
                    .foregroundStyle(.white.opacity(0.5))
                
                Text(bot.status.uppercased())
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(bot.status == "active" ? .green : .orange)
            }
        }
    }
    
    private var botStatsGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            StatCard(
                title: "Win Rate",
                value: String(format: "%.1f%%", bot.winRate),
                color: bot.winRate >= 70 ? .green : bot.winRate >= 50 ? .orange : .red
            )
            
            StatCard(
                title: "Daily P&L",
                value: formatCurrency(bot.dailyPnL),
                color: bot.dailyPnL >= 0 ? .green : .red
            )
            
            StatCard(
                title: "Total P&L",
                value: formatCurrency(bot.totalPnL),
                color: bot.totalPnL >= 0 ? .green : .red
            )
            
            StatCard(
                title: "Trades",
                value: "\(bot.tradesCount)",
                color: .blue
            )
            
            StatCard(
                title: "Pair",
                value: bot.currentPair,
                color: .purple
            )
            
            StatCard(
                title: "GODMODE",
                value: bot.isGodModeEnabled ? "ON" : "OFF",
                color: bot.isGodModeEnabled ? .orange : .gray
            )
        }
    }
    
    private var additionalInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bot Configuration")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            VStack(spacing: 8) {
                InfoRow(label: "Strategy", value: bot.strategy)
                InfoRow(label: "VPS Connection", value: bot.vpsConnection)
                InfoRow(label: "Last Heartbeat", value: formatDate(bot.lastHeartbeat))
                InfoRow(label: "Trade Logs", value: "\(bot.tradeLogs.count)")
                InfoRow(label: "Insights", value: "\(bot.insights.count)")
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
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            
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

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
        }
    }
}

// MARK: - VPS Status View (Broken into components)

struct VPSStatusView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vpsManager = VPSConnectionManager.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                vpsStatusHeader
                vpsInfoSection
                
                if !vpsManager.isConnected {
                    connectButton
                }
                
                Spacer()
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .navigationTitle("VPS Status")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(.blue)
                }
            }
        }
    }
    
    private var vpsStatusHeader: some View {
        VStack(spacing: 16) {
            Image(systemName: vpsManager.isConnected ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(vpsManager.isConnected ? .green : .red)
            
            Text(vpsManager.connectionStatus.rawValue)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            Text(vpsManager.isConnected ? "VPS is online and ready" : "VPS connection offline")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))
        }
    }
    
    private var vpsInfoSection: some View {
        VStack(spacing: 16) {
            InfoRow(label: "Server IP", value: "172.234.201.231")
            InfoRow(label: "Status", value: vpsManager.connectionStatus.rawValue)
            InfoRow(label: "Latency", value: "\(vpsManager.latency)ms")
            InfoRow(label: "CPU Usage", value: String(format: "%.1f%%", vpsManager.cpuUsage))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private var connectButton: some View {
        Button("Connect to VPS") {
            Task {
                await vpsManager.connectToVPS()
            }
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }
}

struct ScreenshotGalleryView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "photo.stack.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)
                
                Text("🚧 Coming Soon")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text("Screenshot gallery feature in development")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .navigationTitle("Screenshots")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(.blue)
                }
            }
        }
    }
}

struct GPTChatView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 60))
                    .foregroundStyle(.purple)
                
                Text("🤖 AI Assistant")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text("ProTrader GPT chat coming soon")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .navigationTitle("AI Assistant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(.blue)
                }
            }
        }
    }
}

struct BotDeploymentView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isDeploying = false
    @State private var deploymentProgress: Double = 0.0
    @State private var deployedBots = 2450
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                deploymentHeader
                
                if isDeploying {
                    deploymentProgressSection
                } else {
                    deploymentCompleteSection
                }
                
                Spacer()
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .navigationTitle("Deployment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(.blue)
                }
            }
        }
    }
    
    private var deploymentHeader: some View {
        VStack(spacing: 16) {
            Image(systemName: "rocket.fill")
                .font(.system(size: 60))
                .foregroundStyle(.orange)
            
            Text("🚀 Bot Deployment")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
    }
    
    private var deploymentProgressSection: some View {
        VStack(spacing: 16) {
            Text("Deploying bots to VPS...")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
            
            ProgressView(value: deploymentProgress)
                .tint(.orange)
                .background(.white.opacity(0.2))
                .clipShape(Capsule())
            
            Text("\(Int(deploymentProgress * 100))% Complete")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.orange)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.05))
        )
    }
    
    private var deploymentCompleteSection: some View {
        VStack(spacing: 16) {
            Text("✅ Deployment Complete!")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.green)
            
            Text("\(deployedBots) bots deployed to VPS")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))
            
            Button("Deploy More Bots") {
                startDeployment()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }
    
    private func startDeployment() {
        isDeploying = true
        deploymentProgress = 0.0
        
        Task {
            for i in 0...100 {
                await MainActor.run {
                    deploymentProgress = Double(i) / 100.0
                }
                try? await Task.sleep(nanoseconds: 50_000_000)
            }
            
            await MainActor.run {
                isDeploying = false
                deployedBots += 100
            }
        }
    }
}

struct MassiveDataDownloadView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "icloud.and.arrow.down.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)
                
                Text("📊 Data Download")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text("Massive data download feature coming soon")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .navigationTitle("Data Download")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(.blue)
                }
            }
        }
    }
}

#Preview {
    VStack {
        Text("Sheet Presentation Modifier")
            .font(.title)
            .foregroundStyle(.white)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.black)
    .preferredColorScheme(.dark)
}
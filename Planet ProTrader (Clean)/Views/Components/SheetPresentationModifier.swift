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
    var selectedBot: ProTraderBot?
    @ObservedObject var armyManager: ProTraderArmyManager
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showingImporter) {
                CSVImporterView(armyManager: armyManager)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingTrainingResults) {
                TrainingResultsView(armyManager: armyManager)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingBotDetails) {
                if let bot = selectedBot {
                    BotDetailsView(bot: bot, armyManager: armyManager)
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
                VPSStatusView(armyManager: armyManager)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingScreenshotGallery) {
                ScreenshotGalleryView(armyManager: armyManager)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingGPTChat) {
                GPTChatView(armyManager: armyManager)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingBotDeployment) {
                BotDeploymentView(armyManager: armyManager)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingMassiveDataDownload) {
                MassiveDataDownloadView(armyManager: armyManager)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
    }
}

// MARK: - Supporting Sheet Views

struct CSVImporterView: View {
    @ObservedObject var armyManager: ProTraderArmyManager
    @Environment(\.dismiss) private var dismiss
    @State private var isImporting = false
    @State private var importProgress = 0.0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
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
                
                // Import Options
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
                        // File picker would go here
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
                
                // Progress
                if isImporting {
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
    
    private func startImport() {
        isImporting = true
        importProgress = 0.0
        
        Task {
            // Actually use the sample historical data for training
            let results = await armyManager.trainWithHistoricalData(csvData: sampleHistoricalData)
            
            await MainActor.run {
                isImporting = false
                GlobalToastManager.shared.show("🎯 Training completed! \(results.newGodmodeBots) new GODMODE bots created!", type: .success)
                dismiss()
            }
        }
    }
}

struct TrainingResultsView: View {
    @ObservedObject var armyManager: ProTraderArmyManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    if let results = armyManager.lastTrainingResults {
                        // Training Summary
                        VStack(spacing: 16) {
                            Text("🎯 Training Complete!")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            
                            Text(results.summary)
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        
                        // Results Grid
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                            ResultCard(
                                title: "Bots Trained",
                                value: "\(results.botsTrained)",
                                icon: "brain.head.profile",
                                color: .blue
                            )
                            
                            ResultCard(
                                title: "New GODMODE",
                                value: "\(results.newGodmodeBots)",
                                icon: "crown.fill",
                                color: .orange
                            )
                            
                            ResultCard(
                                title: "Data Points",
                                value: "\(results.dataPointsProcessed)",
                                icon: "chart.bar.fill",
                                color: .green
                            )
                            
                            ResultCard(
                                title: "XP Gained",
                                value: String(format: "%.0f", results.totalXPGained),
                                icon: "star.fill",
                                color: .purple
                            )
                        }
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 48))
                                .foregroundStyle(.white.opacity(0.5))
                            
                            Text("No training results available")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(0.7))
                            
                            Text("Train your ProTrader Army to see results here")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        .padding(40)
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
    let bot: ProTraderBot
    @ObservedObject var armyManager: ProTraderArmyManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Bot Header
                    VStack(spacing: 12) {
                        Text("🤖")
                            .font(.system(size: 48))
                        
                        Text(bot.name)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        
                        HStack(spacing: 8) {
                            Text("Bot #\(bot.botNumber)")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(0.7))
                            
                            Text("•")
                                .foregroundStyle(.white.opacity(0.5))
                            
                            Text(bot.confidenceLevel)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(confidenceColor(bot.confidence))
                        }
                    }
                    
                    // Bot Stats
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        StatCard(
                            title: "Confidence",
                            value: String(format: "%.1f%%", bot.confidence * 100),
                            color: confidenceColor(bot.confidence)
                        )
                        
                        StatCard(
                            title: "P&L",
                            value: formatCurrency(bot.profitLoss),
                            color: bot.profitLoss >= 0 ? .green : .red
                        )
                        
                        StatCard(
                            title: "Win Rate",
                            value: String(format: "%.1f%%", bot.winRate),
                            color: bot.winRate >= 70 ? .green : bot.winRate >= 50 ? .orange : .red
                        )
                        
                        StatCard(
                            title: "Status",
                            value: bot.isActive ? "ACTIVE" : "IDLE",
                            color: bot.isActive ? .green : .orange
                        )
                        
                        StatCard(
                            title: "Strategy",
                            value: bot.strategy.rawValue,
                            color: .blue
                        )
                        
                        StatCard(
                            title: "Grade",
                            value: bot.performanceGrade,
                            color: gradeColor(bot.performanceGrade)
                        )
                    }
                    
                    // Additional Info
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Bot Configuration")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        
                        VStack(spacing: 8) {
                            InfoRow(label: "Specialization", value: bot.specialization.rawValue)
                            InfoRow(label: "AI Engine", value: bot.aiEngine.rawValue)
                            InfoRow(label: "VPS Status", value: bot.vpsStatus.rawValue)
                            InfoRow(label: "Total Trades", value: "\(bot.totalTrades)")
                            InfoRow(label: "XP Points", value: String(format: "%.0f", bot.xp))
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
    
    private func gradeColor(_ grade: String) -> Color {
        switch grade {
        case "A+", "A": return .orange
        case "B+", "B": return .green
        case "C+", "C": return .blue
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

struct AInfoRow: View {
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

// Placeholder views for other sheets
struct VPSStatusView: View {
    @ObservedObject var armyManager: ProTraderArmyManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // VPS Status Header
                VStack(spacing: 16) {
                    Image(systemName: armyManager.vpsManager.isConnected ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(armyManager.vpsManager.isConnected ? .green : .red)
                    
                    Text(armyManager.vpsManager.connectionStatus.rawValue)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text(armyManager.vpsManager.isConnected ? "VPS is online and ready" : "VPS connection offline")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                }
                
                // VPS Info
                VStack(spacing: 16) {
                    InfoRow(label: "Server IP", value: "172.234.201.231")
                    InfoRow(label: "Status", value: armyManager.vpsManager.connectionStatus.rawValue)
                    InfoRow(label: "Deployed Bots", value: "\(armyManager.deployedBots)")
                    
                    if armyManager.vpsManager.lastPing > 0 {
                        InfoRow(label: "Ping", value: "\(String(format: "%.0f", armyManager.vpsManager.lastPing))ms")
                    }
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
                
                if !armyManager.vpsManager.isConnected {
                    Button("Connect to VPS") {
                        Task {
                            await armyManager.vpsManager.connectToVPS()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
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
}

struct ScreenshotGalleryView: View {
    @ObservedObject var armyManager: ProTraderArmyManager
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
    @ObservedObject var armyManager: ProTraderArmyManager
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
    @ObservedObject var armyManager: ProTraderArmyManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Deployment Header
                VStack(spacing: 16) {
                    Image(systemName: "rocket.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.orange)
                    
                    Text("🚀 Bot Deployment")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                
                // Deployment Status
                if armyManager.isDeploying {
                    VStack(spacing: 16) {
                        Text("Deploying bots to VPS...")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundStyle(.white)
                        
                        ProgressView(value: armyManager.deploymentProgress)
                            .tint(.orange)
                            .background(.white.opacity(0.2))
                            .clipShape(Capsule())
                        
                        Text("\(Int(armyManager.deploymentProgress * 100))% Complete")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.orange)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.white.opacity(0.05))
                    )
                } else {
                    VStack(spacing: 16) {
                        Text("✅ Deployment Complete!")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.green)
                        
                        Text("\(armyManager.deployedBots) bots deployed to VPS")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.7))
                    }
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
}

struct MassiveDataDownloadView: View {
    @ObservedObject var armyManager: ProTraderArmyManager
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

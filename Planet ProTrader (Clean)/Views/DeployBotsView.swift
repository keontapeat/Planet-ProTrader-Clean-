//
//  DeployBotsView.swift
//  Planet ProTrader - Bot Deployment Interface
//
//  Mass bot deployment and management interface
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

// Simple bot struct for background trading
struct SimpleGoldBot {
    let id: UUID
    let name: String
    let status: String
    let currentPair: String
    let strategy: String
    let dailyPnL: Double
    let totalPnL: Double
    let winRate: Double
    let tradesCount: Int
    let isGodModeEnabled: Bool
    let vpsConnection: String
}

struct DeployBotsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isDeploying = false
    @State private var deploymentProgress: Double = 0.0
    @State private var selectedBotCount = 100
    @State private var deploymentMode: DeploymentMode = .standard
    @State private var deployedCount = 0
    
    enum DeploymentMode: String, CaseIterable {
        case standard = "Standard"
        case parallel = "Parallel"
        case ultraFast = "Ultra Fast"
        case gpuAccelerated = "GPU Accelerated"
        
        var icon: String {
            switch self {
            case .standard: return "play.circle"
            case .parallel: return "bolt.circle"
            case .ultraFast: return "flame.circle"
            case .gpuAccelerated: return "cpu"
            }
        }
        
        var color: Color {
            switch self {
            case .standard: return .blue
            case .parallel: return .green
            case .ultraFast: return .orange
            case .gpuAccelerated: return .purple
            }
        }
        
        var description: String {
            switch self {
            case .standard: return "Deploy bots one by one"
            case .parallel: return "Deploy multiple bots simultaneously"
            case .ultraFast: return "Maximum speed deployment"
            case .gpuAccelerated: return "Use GPU acceleration for deployment"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Deployment Configuration
                    if !isDeploying {
                        configurationSection
                    }
                    
                    // Progress Section
                    if isDeploying {
                        progressSection
                    } else {
                        deploymentButton
                    }
                    
                    // Stats Section
                    statsSection
                }
                .padding()
            }
            .background(Color.black)
            .navigationTitle("Deploy ProTrader Army")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.red)
                }
                
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
        VStack(spacing: 16) {
            Image(systemName: "crown.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
            
            Text("🥇 Gold Army Deployment")
                .font(.title.bold())
                .foregroundStyle(.white)
            
            Text("Deploy AI-powered GOLD trading specialists to dominate XAUUSD markets")
                .font(.subheadline)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
        }
    }
    
    private var configurationSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            botCountSelectionSection
            deploymentModeSelectionSection
        }
    }
    
    private var botCountSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Number of Bots")
                .font(.headline.bold())
                .foregroundStyle(.white)
            
            HStack {
                Text("\(selectedBotCount)")
                    .font(.title2.bold())
                    .foregroundStyle(.orange)
                
                Spacer()
                
                Stepper("", value: $selectedBotCount, in: 1...5000, step: 10)
                    .labelsHidden()
            }
            
            Slider(value: Binding(
                get: { Double(selectedBotCount) },
                set: { selectedBotCount = Int($0) }
            ), in: 1...5000, step: 10)
            .tint(.orange)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var deploymentModeSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Deployment Mode")
                .font(.headline.bold())
                .foregroundStyle(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(DeploymentMode.allCases, id: \.self) { mode in
                    deploymentModeButton(for: mode)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
    
    private func deploymentModeButton(for mode: DeploymentMode) -> some View {
        Button {
            deploymentMode = mode
        } label: {
            VStack(spacing: 8) {
                Image(systemName: mode.icon)
                    .font(.title2)
                    .foregroundColor(mode.color)
                
                Text(mode.rawValue)
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                
                Text(mode.description)
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, minHeight: 100)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(deploymentMode == mode ? 
                          AnyShapeStyle(mode.color.opacity(0.2)) : 
                          AnyShapeStyle(.ultraThinMaterial))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(deploymentMode == mode ? mode.color : .clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    private var progressSection: some View {
        VStack(spacing: 16) {
            Text("Deploying Bots...")
                .font(.title2.bold())
                .foregroundStyle(.white)
            
            Text("\(deployedCount) / \(selectedBotCount) bots deployed")
                .font(.subheadline)
                .foregroundStyle(.gray)
            
            ProgressView(value: deploymentProgress)
                .tint(.orange)
                .background(.white.opacity(0.2))
                .clipShape(Capsule())
                .scaleEffect(y: 3)
            
            Text("\(Int(deploymentProgress * 100))% Complete")
                .font(.headline.bold())
                .foregroundStyle(.orange)
            
            HStack(spacing: 20) {
                VStack {
                    Text("Speed")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    Text("\(deploymentMode.rawValue)")
                        .font(.caption.bold())
                        .foregroundStyle(deploymentMode.color)
                }
                
                VStack {
                    Text("ETA")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    Text("2:34")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                }
                
                VStack {
                    Text("Success Rate")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    Text("98.5%")
                        .font(.caption.bold())
                        .foregroundStyle(.green)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var deploymentButton: some View {
        Button {
            print("🔥 DEPLOY BUTTON HIT!") // Debug
            startDeployment()
        } label: {
            HStack {
                Image(systemName: deploymentMode.icon)
                Text("Deploy \(selectedBotCount) Gold Bots INSTANTLY")
                Image(systemName: deploymentMode.icon)
            }
            .font(.headline.bold())
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [.yellow, .orange, .yellow],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .disabled(isDeploying)
    }
    
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🥇 Gold Army Statistics")
                .font(.headline.bold())
                .foregroundStyle(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                DeploymentStatCard(title: "Gold Bots", value: "2,450", color: .yellow)
                DeploymentStatCard(title: "Gold Win Rate", value: "98.7%", color: .green)
                DeploymentStatCard(title: "Gold Speed", value: "12ms", color: .orange)
                DeploymentStatCard(title: "Active Gold", value: "2,389", color: .yellow)
                DeploymentStatCard(title: "Gold Failed", value: "32", color: .red)
                DeploymentStatCard(title: "Gold Pending", value: "29", color: .cyan)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
    
    private func startDeployment() {
        print("🚀 INSTANT DEPLOYMENT STARTING!")
        
        isDeploying = true
        deploymentProgress = 0.0
        deployedCount = 0
        
        // Instant feedback
        DispatchQueue.main.async {
            self.deploymentProgress = 0.5
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Create all bots instantly
            let allBots = (0..<self.selectedBotCount).map { index in
                self.createInstantGoldBot(index: index)
            }
            
            // Update UI instantly
            self.deploymentProgress = 1.0
            self.deployedCount = self.selectedBotCount
            self.isDeploying = false
            
            // Start background trading
            self.startInstantBackgroundTrading(bots: allBots)
            
            // Show success
            GlobalToastManager.shared.show("🥇 \(self.selectedBotCount) Gold Bots deployed and trading!", type: .success)
            
            print("🎉 INSTANT deployment completed: \(allBots.count) gold bots")
            
            // Auto dismiss
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.dismiss()
            }
        }
    }
    
    // Create instant gold bot - Return simple struct instead
    private func createInstantGoldBot(index: Int) -> SimpleGoldBot {
        return SimpleGoldBot(
            id: UUID(),
            name: "Gold-AI-\(String(format: "%04d", index + 1))",
            status: "active",
            currentPair: "XAUUSD", // 🥇 ONLY GOLD
            strategy: "AI-GoldSpecialist",
            dailyPnL: Double.random(in: 50...200),
            totalPnL: Double.random(in: 500...5000),
            winRate: Double.random(in: 85...99),
            tradesCount: Int.random(in: 50...200),
            isGodModeEnabled: true,
            vpsConnection: "Gold-VPS-Active"
        )
    }
    
    // Start instant background trading
    private func startInstantBackgroundTrading(bots: [SimpleGoldBot]) {
        Task.detached(priority: .background) {
            print("🥇 Starting background gold trading for \(bots.count) bots")
            
            // Background trading loop
            while true {
                // Simulate gold trading
                let activeTraders = bots.shuffled().prefix(50)
                for bot in activeTraders {
                    let goldProfit = Double.random(in: -20...100)
                    print("🥇 \(bot.name): XAUUSD profit: $\(String(format: "%.2f", goldProfit))")
                }
                
                // Wait 5 seconds before next trading cycle
                try? await Task.sleep(nanoseconds: 5_000_000_000)
            }
        }
    }
}

struct DeploymentStatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline.bold())
                .foregroundStyle(color)
            
            Text(title)
                .font(.caption2)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 60)
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    DeployBotsView()
        .preferredColorScheme(.dark)
}
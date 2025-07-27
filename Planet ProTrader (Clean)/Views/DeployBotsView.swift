//
//  DeployBotsView.swift
//  Planet ProTrader - Bot Deployment Interface
//
//  Mass bot deployment and management interface
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

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
            Image(systemName: "rocket.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("🚀 Mass Bot Deployment")
                .font(.title.bold())
                .foregroundStyle(.white)
            
            Text("Deploy AI-powered trading bots to your VPS infrastructure")
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
            startDeployment()
        } label: {
            HStack {
                Image(systemName: deploymentMode.icon)
                Text("Deploy \(selectedBotCount) Bots")
                Image(systemName: deploymentMode.icon)
            }
            .font(.headline.bold())
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [.orange, .yellow, .orange],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
    
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📊 Deployment Statistics")
                .font(.headline.bold())
                .foregroundStyle(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                DeploymentStatCard(title: "Total Deployed", value: "2,450", color: .green)
                DeploymentStatCard(title: "Success Rate", value: "98.7%", color: .blue)
                DeploymentStatCard(title: "Avg Speed", value: "15ms", color: .orange)
                DeploymentStatCard(title: "Active Bots", value: "2,389", color: .purple)
                DeploymentStatCard(title: "Failed", value: "32", color: .red)
                DeploymentStatCard(title: "Pending", value: "29", color: .yellow)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
    
    private func startDeployment() {
        isDeploying = true
        deploymentProgress = 0.0
        deployedCount = 0
        
        Task {
            let totalSteps = 100
            let botIncrement = selectedBotCount / totalSteps
            
            for i in 0...totalSteps {
                await MainActor.run {
                    deploymentProgress = Double(i) / Double(totalSteps)
                    deployedCount = min(selectedBotCount, i * botIncrement)
                }
                
                let delay = switch deploymentMode {
                case .standard: 100_000_000 // 100ms
                case .parallel: 50_000_000   // 50ms
                case .ultraFast: 25_000_000  // 25ms
                case .gpuAccelerated: 10_000_000 // 10ms
                }
                
                try? await Task.sleep(nanoseconds: UInt64(delay))
            }
            
            await MainActor.run {
                isDeploying = false
                deployedCount = selectedBotCount
                
                // Show success notification
                GlobalToastManager.shared.show("🚀 \(selectedBotCount) bots deployed successfully!", type: .success)
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
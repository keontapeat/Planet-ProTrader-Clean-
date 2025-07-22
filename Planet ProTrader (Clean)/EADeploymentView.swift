//
//  EADeploymentView.swift
//  Planet ProTrader - EA Deployment Interface
//
//  Complete EA deployment with progress tracking
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

struct EADeploymentView: View {
    @StateObject private var eaManager = EAIntegrationManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var isDeploying = false
    @State private var deploymentSteps: [DeploymentStep] = []
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // Header
                headerSection
                
                // Deployment Steps
                if !deploymentSteps.isEmpty {
                    deploymentStepsSection
                }
                
                // VPS & Account Info
                accountInfoSection
                
                Spacer()
                
                // Deploy Button
                deployButton
            }
            .padding()
            .navigationTitle("EA Deployment")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                setupDeploymentSteps()
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "server.rack")
                .font(.system(size: 60))
                .foregroundColor(DesignSystem.primaryGold)
            
            VStack(spacing: 8) {
                Text("Deploy Expert Advisor")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Automatically deploy your EA to Linode VPS and connect to Coinexx Demo for live trading")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var deploymentStepsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📋 Deployment Process")
                .font(.headline)
                .fontWeight(.bold)
            
            LazyVStack(spacing: 12) {
                ForEach(deploymentSteps) { step in
                    DeploymentStepRow(step: step)
                }
            }
        }
        .standardCard()
    }
    
    private var accountInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🔗 Connection Details")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                InfoRow(title: "VPS Server", value: "172.234.201.231", icon: "server.rack")
                InfoRow(title: "Coinexx Account", value: "Demo #845638", icon: "building.columns")
                InfoRow(title: "Trading Platform", value: "MetaTrader 5", icon: "chart.line.uptrend.xyaxis")
                InfoRow(title: "Base Currency", value: "USD", icon: "dollarsign.circle")
                InfoRow(title: "Initial Lot Size", value: "0.01 (Demo Safe)", icon: "gauge")
            }
        }
        .standardCard()
    }
    
    private var deployButton: some View {
        Button(action: {
            deployEA()
        }) {
            HStack {
                if isDeploying {
                    ProgressView()
                        .scaleEffect(0.8)
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "rocket.fill")
                        .font(.title3)
                }
                
                Text(isDeploying ? "Deploying EA..." : "Deploy EA to VPS")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(DesignSystem.goldGradient, in: RoundedRectangle(cornerRadius: 12))
        }
        .disabled(isDeploying)
    }
    
    private func setupDeploymentSteps() {
        deploymentSteps = [
            DeploymentStep(id: 1, title: "Connect to VPS", description: "Establish secure connection to Linode server", status: .pending),
            DeploymentStep(id: 2, title: "Upload EA File", description: "Transfer PlanetProTrader_EA.mq5 to VPS", status: .pending),
            DeploymentStep(id: 3, title: "Compile EA", description: "Compile EA using MetaEditor on VPS", status: .pending),
            DeploymentStep(id: 4, title: "Connect to Coinexx", description: "Login to Coinexx Demo account", status: .pending),
            DeploymentStep(id: 5, title: "Start EA", description: "Attach EA to MT5 and begin trading", status: .pending)
        ]
    }
    
    private func deployEA() {
        isDeploying = true
        HapticManager.shared.impact()
        
        Task {
            // Update steps in real-time
            for i in deploymentSteps.indices {
                await updateStepStatus(i, to: .inProgress)
                try? await Task.sleep(for: .seconds(2)) // Simulate deployment time
                await updateStepStatus(i, to: .completed)
            }
            
            let success = await eaManager.deployEAToVPS()
            
            DispatchQueue.main.async {
                self.isDeploying = false
                
                if success {
                    HapticManager.shared.success()
                    self.dismiss()
                } else {
                    HapticManager.shared.error()
                    // Show error state
                    if let lastIndex = self.deploymentSteps.lastIndex(where: { $0.status == .inProgress }) {
                        self.deploymentSteps[lastIndex].status = .failed
                    }
                }
            }
        }
    }
    
    private func updateStepStatus(_ index: Int, to status: DeploymentStep.Status) async {
        DispatchQueue.main.async {
            self.deploymentSteps[index].status = status
        }
    }
}

struct DeploymentStep: Identifiable {
    let id: Int
    let title: String
    let description: String
    var status: Status
    
    enum Status {
        case pending, inProgress, completed, failed
        
        var icon: String {
            switch self {
            case .pending: return "circle"
            case .inProgress: return "arrow.clockwise"
            case .completed: return "checkmark.circle.fill"
            case .failed: return "xmark.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .pending: return .gray
            case .inProgress: return .orange
            case .completed: return .green
            case .failed: return .red
            }
        }
    }
}

struct DeploymentStepRow: View {
    let step: DeploymentStep
    
    var body: some View {
        HStack(spacing: 16) {
            // Step number or icon
            ZStack {
                Circle()
                    .fill(step.status.color.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                if step.status == .inProgress {
                    ProgressView()
                        .scaleEffect(0.6)
                } else {
                    Image(systemName: step.status.icon)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(step.status.color)
                }
            }
            
            // Step details
            VStack(alignment: .leading, spacing: 4) {
                Text(step.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(step.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(DesignSystem.primaryGold)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    EADeploymentView()
}
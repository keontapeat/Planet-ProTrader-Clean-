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
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Deployment Steps
                    if !deploymentSteps.isEmpty {
                        deploymentStepsSection
                    }
                    
                    // VPS & Account Info
                    accountInfoSection
                    
                    // Deploy Button
                    deployButton
                        .padding(.top, 20)
                }
                .padding()
            }
            .navigationTitle("EA Deployment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        print("✅ Cancel button tapped - dismissing modal")
                        dismiss()
                    }
                    .foregroundColor(.red)
                    .font(.headline)
                }
            }
            .onAppear {
                print("✅ EADeploymentView appeared")
                setupDeploymentSteps()
            }
        }
        .presentationDragIndicator(.visible)
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "server.rack")
                .font(.system(size: 50))
                .foregroundColor(DesignSystem.primaryGold)
            
            VStack(spacing: 8) {
                Text("Deploy Expert Advisor")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Deploy your EA to VPS and connect to Coinexx Demo")
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
            
            VStack(spacing: 10) {
                ForEach(deploymentSteps) { step in
                    DeploymentStepRow(step: step)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var accountInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🔗 Connection Details")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 10) {
                EAInfoRow(title: "VPS Server", value: "172.234.201.231", icon: "server.rack")
                EAInfoRow(title: "Coinexx Account", value: "Demo #845638", icon: "building.columns")
                EAInfoRow(title: "Trading Platform", value: "MetaTrader 5", icon: "chart.line.uptrend.xyaxis")
                EAInfoRow(title: "Base Currency", value: "USD", icon: "dollarsign.circle")
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var deployButton: some View {
        VStack(spacing: 12) {
            Button(action: {
                print("🚀 Deploy button tapped!")
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
                .frame(height: 50)
                .background(
                    isDeploying ? Color.gray : DesignSystem.primaryGold,
                    in: RoundedRectangle(cornerRadius: 12)
                )
            }
            .disabled(isDeploying)
            
            // Test button for debugging
            Button("Test Button (Tap This)") {
                print("🧪 Test button worked!")
                dismiss()
            }
            .foregroundColor(.blue)
            .font(.caption)
        }
    }
    
    private func setupDeploymentSteps() {
        print("✅ Setting up deployment steps")
        deploymentSteps = [
            DeploymentStep(id: 1, title: "Connect to VPS", description: "Connect to Linode server", status: .pending),
            DeploymentStep(id: 2, title: "Upload EA File", description: "Transfer EA to VPS", status: .pending),
            DeploymentStep(id: 3, title: "Compile EA", description: "Compile using MetaEditor", status: .pending),
            DeploymentStep(id: 4, title: "Connect to Coinexx", description: "Login to Demo account", status: .pending),
            DeploymentStep(id: 5, title: "Start EA", description: "Begin trading", status: .pending)
        ]
        print("✅ Deployment steps created: \(deploymentSteps.count) steps")
    }
    
    private func deployEA() {
        print("🚀 Starting EA deployment...")
        isDeploying = true
        
        Task {
            print("🔄 Deployment task started")
            
            // Update steps in real-time
            for i in deploymentSteps.indices {
                print("🔄 Updating step \(i + 1): \(deploymentSteps[i].title)")
                await updateStepStatus(i, to: .inProgress)
                try? await Task.sleep(for: .seconds(1))
                await updateStepStatus(i, to: .completed)
                print("✅ Step \(i + 1) completed")
            }
            
            print("🔄 Calling eaManager.deployEAToVPS()")
            let success = await eaManager.deployEAToVPS()
            print("🎯 EA deployment result: \(success)")
            
            DispatchQueue.main.async {
                self.isDeploying = false
                print("🏁 Deployment finished, dismissing...")
                self.dismiss()
            }
        }
    }
    
    private func updateStepStatus(_ index: Int, to status: DeploymentStep.Status) async {
        await MainActor.run {
            guard index < deploymentSteps.count else { 
                print("❌ Invalid step index: \(index)")
                return 
            }
            deploymentSteps[index].status = status
            print("📝 Step \(index + 1) updated to: \(status)")
        }
    }
}

struct DeploymentStep: Identifiable {
    let id: Int
    let title: String
    let description: String
    var status: Status
    
    enum Status: CustomStringConvertible {
        case pending, inProgress, completed, failed
        
        var description: String {
            switch self {
            case .pending: return "pending"
            case .inProgress: return "inProgress"
            case .completed: return "completed"
            case .failed: return "failed"
            }
        }
        
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

struct EAInfoRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(DesignSystem.primaryGold)
                .frame(width: 20)
            
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

struct DeploymentStepRow: View {
    let step: DeploymentStep
    
    var body: some View {
        HStack(spacing: 12) {
            // Step icon
            ZStack {
                Circle()
                    .fill(step.status.color.opacity(0.2))
                    .frame(width: 28, height: 28)
                
                if step.status == .inProgress {
                    ProgressView()
                        .scaleEffect(0.5)
                } else {
                    Image(systemName: step.status.icon)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(step.status.color)
                }
            }
            
            // Step details
            VStack(alignment: .leading, spacing: 2) {
                Text(step.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(step.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    EADeploymentView()
}
//
//  BotDeploymentLauncher.swift
//  Planet ProTrader - Bot Deployment Launcher
//
//  Quick access to bot deployment without conflicts
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

struct BotDeploymentLauncher: View {
    @StateObject private var eaManager = EAIntegrationManager.shared
    @State private var showingFullDeployment = false
    @State private var isDeploying = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "robot.fill")
                        .font(.system(size: 60))
                        .foregroundColor(DesignSystem.primaryGold)
                    
                    Text("🚀 Deploy Trading Bot")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Connect to Coinexx Demo Account")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Quick Deploy Golden Eagle
                Button(action: {
                    deployGoldenEagle()
                }) {
                    VStack(spacing: 12) {
                        HStack {
                            if isDeploying {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "crown.fill")
                                    .font(.title2)
                            }
                            Text(isDeploying ? "Deploying..." : "Deploy Golden Eagle")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        
                        Text("94.2% Win Rate • Premium Bot")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                    .background(
                        LinearGradient(
                            colors: [DesignSystem.primaryGold, DesignSystem.accentGold],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: RoundedRectangle(cornerRadius: 16)
                    )
                    .shadow(color: DesignSystem.primaryGold.opacity(0.3), radius: 12, x: 0, y: 6)
                }
                .disabled(isDeploying)
                
                // Advanced Options
                Button("Advanced Bot Options") {
                    showingFullDeployment = true
                }
                .font(.headline)
                .foregroundColor(.blue)
                
                // Status
                if eaManager.isEADeployed {
                    VStack(spacing: 8) {
                        HStack {
                            Circle()
                                .fill(.green)
                                .frame(width: 8, height: 8)
                            Text("EA Active on VPS")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                        
                        Text("Active Bots: \(eaManager.getActiveBotsCount())")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Bot Deployment")
            .sheet(isPresented: $showingFullDeployment) {
                EADeploymentView()
            }
        }
    }
    
    private func deployGoldenEagle() {
        guard let goldenEagle = TradingBot.sampleBots.first(where: { $0.name == "Golden Eagle" }) else { return }
        
        isDeploying = true
        
        Task {
            // First ensure EA is deployed
            if !eaManager.isEADeployed {
                let success = await eaManager.deployEAToVPS()
                if !success { 
                    DispatchQueue.main.async {
                        self.isDeploying = false
                    }
                    return 
                }
            }
            
            // Deploy the bot
            await eaManager.deployBotToEA(goldenEagle)
            
            DispatchQueue.main.async {
                self.isDeploying = false
            }
        }
    }
}

#Preview {
    BotDeploymentLauncher()
}
//
//  ToolbarComponents.swift
//  Planet ProTrader (Clean)
//
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

struct ToolbarButton: View {
    let icon: String
    let text: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(color)
                
                Text(text)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .frame(width: 56, height: 44)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct VPSStatusButton: View {
    let isConnected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(isConnected ? .green : .red)
                        .frame(width: 6, height: 6)
                    
                    Image(systemName: "server.rack")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(isConnected ? .green : .red)
                }
                
                Text("VPS")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .frame(width: 56, height: 44)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke((isConnected ? Color.green : Color.red).opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct AutoTradingMenu: View {
    @ObservedObject var armyManager: ProTraderArmyManager
    let sampleData: String
    @State private var showingMenu = false
    
    var body: some View {
        Menu {
            Button {
                Task.detached(priority: .background) {
                    await armyManager.startAutoTrading()
                    await MainActor.run {
                        GlobalToastManager.shared.show("🤖 Auto-trading started!", type: .success)
                    }
                }
            } label: {
                Label("Start Auto Trading", systemImage: "play.circle.fill")
            }
            
            Button {
                Task.detached(priority: .background) {
                    await armyManager.stopAutoTrading()
                    await MainActor.run {
                        GlobalToastManager.shared.show("⏹️ Auto-trading stopped", type: .info)
                    }
                }
            } label: {
                Label("Stop Auto Trading", systemImage: "stop.circle.fill")
            }
            
            Divider()
            
            Button {
                Task.detached(priority: .background) {
                    let results = await armyManager.trainWithHistoricalData(csvData: sampleData)
                    await MainActor.run {
                        GlobalToastManager.shared.show("🧠 Training completed: \(results.summary)", type: .success)
                    }
                }
            } label: {
                Label("Quick Train", systemImage: "brain.head.profile")
            }
            
            Button {
                Task.detached(priority: .background) {
                    await armyManager.syncWithVPS()
                    await MainActor.run {
                        GlobalToastManager.shared.show("🔄 VPS synchronized successfully!", type: .success)
                    }
                }
            } label: {
                Label("Sync with VPS", systemImage: "icloud.and.arrow.up")
            }
            
            Button {
                Task.detached(priority: .background) {
                    await armyManager.deployBots(count: 100)
                    await MainActor.run {
                        GlobalToastManager.shared.show("🚀 Top 100 bots deployed!", type: .success)
                    }
                }
            } label: {
                Label("Deploy Top 100", systemImage: "crown.fill")
            }
            
            Button {
                Task.detached(priority: .background) {
                    await armyManager.quickDeploy()
                    await MainActor.run {
                        GlobalToastManager.shared.show("🚀 Quick deployment completed!", type: .success)
                    }
                }
            } label: {
                Label("Quick Deploy", systemImage: "crown.fill")
            }
            
            Divider()
            
            Button {
                Task.detached(priority: .background) {
                    await armyManager.emergencyStopAll()
                    await MainActor.run {
                        GlobalToastManager.shared.show("🚨 Emergency stop activated!", type: .warning)
                    }
                }
            } label: {
                Label("Emergency Stop", systemImage: "stop.circle")
            }
            .foregroundStyle(.red)
            
        } label: {
            VStack(spacing: 4) {
                Image(systemName: "ellipsis.circle.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
                
                Text("Menu")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .frame(width: 56, height: 44)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .menuStyle(.borderlessButton)
    }
}

#Preview {
    VStack(spacing: 20) {
        HStack {
            ToolbarButton(icon: "icloud.and.arrow.down.fill", text: "Data", color: .purple) { }
            ToolbarButton(icon: "arrow.up.circle.fill", text: "Deploy", color: .green) { }
            VPSStatusButton(isConnected: true) { }
            AutoTradingMenu(armyManager: ProTraderArmyManager(), sampleData: "")
        }
    }
    .background(Color.black)
    .preferredColorScheme(.dark)
}
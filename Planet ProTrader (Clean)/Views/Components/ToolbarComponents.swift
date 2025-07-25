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
    let onStartTrading: () -> Void
    let onStopTrading: () -> Void
    let onQuickTrain: () -> Void
    let onSyncVPS: () -> Void
    let onDeployTop100: () -> Void
    let onQuickDeploy: () -> Void
    let onEmergencyStop: () -> Void
    
    @State private var showingMenu = false
    
    var body: some View {
        Menu {
            Button {
                onStartTrading()
            } label: {
                Label("Start Auto Trading", systemImage: "play.circle.fill")
            }
            
            Button {
                onStopTrading()
            } label: {
                Label("Stop Auto Trading", systemImage: "stop.circle.fill")
            }
            
            Divider()
            
            Button {
                onQuickTrain()
            } label: {
                Label("Quick Train", systemImage: "brain.head.profile")
            }
            
            Button {
                onSyncVPS()
            } label: {
                Label("Sync with VPS", systemImage: "icloud.and.arrow.up")
            }
            
            Button {
                onDeployTop100()
            } label: {
                Label("Deploy Top 100", systemImage: "crown.fill")
            }
            
            Button {
                onQuickDeploy()
            } label: {
                Label("Quick Deploy", systemImage: "bolt.fill")
            }
            
            Divider()
            
            Button {
                onEmergencyStop()
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

// MARK: - Simplified Menu Component for Easy Use
struct SimpleAutoTradingMenu: View {
    var body: some View {
        AutoTradingMenu(
            onStartTrading: {
                GlobalToastManager.shared.show("🤖 Auto-trading started!", type: .success)
            },
            onStopTrading: {
                GlobalToastManager.shared.show("⏹️ Auto-trading stopped", type: .info)
            },
            onQuickTrain: {
                GlobalToastManager.shared.show("🧠 Training started...", type: .info)
            },
            onSyncVPS: {
                GlobalToastManager.shared.show("🔄 VPS sync started...", type: .info)
            },
            onDeployTop100: {
                GlobalToastManager.shared.show("🚀 Deploying top 100 bots...", type: .success)
            },
            onQuickDeploy: {
                GlobalToastManager.shared.show("🚀 Quick deployment started...", type: .success)
            },
            onEmergencyStop: {
                GlobalToastManager.shared.show("🚨 Emergency stop activated!", type: .warning)
            }
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 12) {
            ToolbarButton(icon: "icloud.and.arrow.down.fill", text: "Data", color: .purple) { 
                print("Data button tapped")
            }
            
            ToolbarButton(icon: "arrow.up.circle.fill", text: "Deploy", color: .green) { 
                print("Deploy button tapped")
            }
            
            VPSStatusButton(isConnected: true) { 
                print("VPS status button tapped")
            }
            
            SimpleAutoTradingMenu()
        }
        
        // Example with custom actions
        HStack(spacing: 12) {
            ToolbarButton(icon: "brain.head.profile", text: "AI", color: .blue) { }
            ToolbarButton(icon: "chart.line.uptrend.xyaxis", text: "Stats", color: .orange) { }
            VPSStatusButton(isConnected: false) { }
            
            AutoTradingMenu(
                onStartTrading: { print("Custom start trading") },
                onStopTrading: { print("Custom stop trading") },
                onQuickTrain: { print("Custom quick train") },
                onSyncVPS: { print("Custom sync VPS") },
                onDeployTop100: { print("Custom deploy 100") },
                onQuickDeploy: { print("Custom quick deploy") },
                onEmergencyStop: { print("Custom emergency stop") }
            )
        }
    }
    .padding()
    .background(Color.black)
    .preferredColorScheme(.dark)
}
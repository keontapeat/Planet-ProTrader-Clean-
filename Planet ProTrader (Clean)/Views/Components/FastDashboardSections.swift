//
//  FastDashboardSections.swift
//  Planet ProTrader (Clean)
//
//  Performance-optimized dashboard sections using Apple's best practices
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI
import Foundation

// MARK: - Missing Component Definitions

struct QuickDeployButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                
                VStack(spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .frame(maxWidth: .infinity, minHeight: 80)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct ProTraderMetricCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let trend: TrendDirection
    
    enum TrendDirection {
        case up, down, stable
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                
                Spacer()
                
                Image(systemName: trendIcon)
                    .font(.caption)
                    .foregroundStyle(trendColor)
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
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private var trendIcon: String {
        switch trend {
        case .up: return "arrow.up.right"
        case .down: return "arrow.down.right"
        case .stable: return "minus"
        }
    }
    
    private var trendColor: Color {
        switch trend {
        case .up: return .green
        case .down: return .red
        case .stable: return .orange
        }
    }
}

struct ArmyStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
                
                Text(subtitle)
                    .font(.system(size: 10, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity, minHeight: 100)
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

struct QuickActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.blue)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Simplified Dashboard Sections for Basic Functionality

struct SimpleDashboardSection: View {
    let title: String
    let content: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundColor(.white)
            }
            
            Text(content)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct FastStatsCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                
                Text(title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
                
                Text(subtitle)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct DeploymentButtonSection: View {
    let onDeploy100: () -> Void
    let onDeployAll: () -> Void
    let onTrain: () -> Void
    let onSync: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Text("🚀")
                    .font(.title2)
                
                Text("BOT ARMY DEPLOYMENT")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                QuickDeployButton(
                    title: "Deploy 100 Bots",
                    subtitle: "Fast deployment",
                    icon: "bolt.fill",
                    color: .orange,
                    action: onDeploy100
                )
                
                QuickDeployButton(
                    title: "Deploy All 5K",
                    subtitle: "Full army",
                    icon: "crown.fill",
                    color: .red,
                    action: onDeployAll
                )
                
                QuickDeployButton(
                    title: "Train & Deploy",
                    subtitle: "With historical data",
                    icon: "brain.head.profile",
                    color: .purple,
                    action: onTrain
                )
                
                QuickDeployButton(
                    title: "VPS Sync",
                    subtitle: "Upload to server",
                    icon: "icloud.and.arrow.up",
                    color: .blue,
                    action: onSync
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct FastDashboardHeader: View {
    let deployedBots: Int
    let isConnected: Bool
    let dailyPnL: Double
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Text("💎")
                            .font(.title)
                        
                        Text("PROTRADER ARMY")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    
                    Text("5,000 ProTrader Bots • \(deployedBots) VPS Active")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 6) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(isConnected ? .green : .red)
                            .frame(width: 8, height: 8)
                        Text(isConnected ? "VPS CONNECTED" : "VPS OFFLINE")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(isConnected ? .green : .red)
                    }
                    
                    Text("24/7 AI Learning")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            
            // Daily P&L Display
            HStack {
                Text("Today's P&L:")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
                
                Spacer()
                
                Text(dailyPnL >= 0 ? "+$\(dailyPnL, specifier: "%.2f")" : "-$\(abs(dailyPnL), specifier: "%.2f")")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundStyle(dailyPnL >= 0 ? .green : .red)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.blue.opacity(0.2),
                            Color.cyan.opacity(0.1),
                            Color.indigo.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.5), Color.cyan.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
}

// MARK: - Preview with sample data
#Preview {
    ScrollView {
        VStack(spacing: 20) {
            FastDashboardHeader(
                deployedBots: 2450,
                isConnected: true,
                dailyPnL: 24567.50
            )
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                FastStatsCard(
                    title: "Active Bots",
                    value: "2,450",
                    subtitle: "Trading on VPS",
                    icon: "bolt.fill",
                    color: .green
                )
                
                FastStatsCard(
                    title: "Win Rate",
                    value: "87.5%",
                    subtitle: "Live performance",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .blue
                )
                
                FastStatsCard(
                    title: "GODMODE",
                    value: "347",
                    subtitle: "Elite bots",
                    icon: "crown.fill",
                    color: .orange
                )
                
                FastStatsCard(
                    title: "Total P&L",
                    value: "$47,892",
                    subtitle: "All time",
                    icon: "dollarsign.circle.fill",
                    color: .purple
                )
            }
            
            DeploymentButtonSection(
                onDeploy100: { print("Deploy 100") },
                onDeployAll: { print("Deploy All") },
                onTrain: { print("Train") },
                onSync: { print("Sync") }
            )
            
            SimpleDashboardSection(
                title: "🏆 TOP PERFORMERS",
                content: "Golden Eagle Bot: +$5,247 • Silver Hawk: +$3,892 • Bronze Scout: +$2,156",
                icon: "trophy.fill",
                color: .yellow
            )
        }
        .padding()
    }
    .background(Color.black)
    .preferredColorScheme(.dark)
}
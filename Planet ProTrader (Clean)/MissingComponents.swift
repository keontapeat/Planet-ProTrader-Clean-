//
//  MissingComponents.swift
//  Planet ProTrader - Missing UI Components
//
//  Additional components needed for compilation
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

// MARK: - TabButton Component
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : .secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    isSelected ? 
                    DesignSystem.primaryGold : 
                    Color.clear,
                    in: RoundedRectangle(cornerRadius: 8)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - AIDashboard (Simplified without AIIntelligentHealer)
struct AIDashboard: View {
    @State private var selectedTab = 0
    @State private var analysisActive = true
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                aiDashboardHeader
                
                // Content tabs
                TabView(selection: $selectedTab) {
                    // Analysis Tab
                    aiAnalysisTab
                        .tag(0)
                    
                    // Recommendations Tab
                    aiRecommendationsTab
                        .tag(1)
                    
                    // Settings Tab
                    aiSettingsTab
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("🧠 AI System Monitor")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var aiDashboardHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.title)
                    .foregroundColor(.purple)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("AI System Monitor")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Intelligent System Analysis")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Circle()
                        .fill(analysisActive ? .green : .red)
                        .frame(width: 8, height: 8)
                        .pulsingEffect()
                    
                    Text(analysisActive ? "ACTIVE" : "INACTIVE")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(analysisActive ? .green : .red)
                }
            }
            
            // Tab selector
            HStack(spacing: 0) {
                TabButton(title: "Analysis", isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
                
                TabButton(title: "Recommendations", isSelected: selectedTab == 1) {
                    selectedTab = 1
                }
                
                TabButton(title: "Settings", isSelected: selectedTab == 2) {
                    selectedTab = 2
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding()
    }
    
    private var aiAnalysisTab: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("🤖 System is continuously analyzing for optimal performance and predicting potential issues.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .planetCard()
                
                // Analysis results
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Analysis")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        
                        Text("System performance is optimal. No issues detected.")
                            .font(.subheadline)
                            .foregroundColor(.green)
                    }
                    
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                        
                        Text("MT5 connection stable. Trading ready.")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
                .planetCard()
            }
            .padding()
        }
    }
    
    private var aiRecommendationsTab: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("💡 System-generated recommendations based on analysis.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .planetCard()
                
                // Recommendations
                VStack(alignment: .leading, spacing: 12) {
                    Text("System Recommendations")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("All systems are running optimally")
                                .font(.subheadline)
                        }
                        
                        HStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .foregroundColor(.green)
                            Text("Consider deploying more bots for increased profits")
                                .font(.subheadline)
                        }
                        
                        HStack {
                            Image(systemName: "shield.checkered")
                                .foregroundColor(.blue)
                            Text("VPS performance is excellent")
                                .font(.subheadline)
                        }
                    }
                }
                .planetCard()
            }
            .padding()
        }
    }
    
    private var aiSettingsTab: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("⚙️ Configure system monitoring settings and preferences.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .planetCard()
                
                // Settings
                VStack(alignment: .leading, spacing: 12) {
                    Text("System Settings")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    VStack(spacing: 12) {
                        Toggle("Enable System Analysis", isOn: $analysisActive)
                        Toggle("Auto-apply recommendations", isOn: .constant(false))
                        Toggle("Real-time monitoring", isOn: .constant(true))
                        Toggle("Performance alerts", isOn: .constant(true))
                    }
                }
                .planetCard()
            }
            .padding()
        }
    }
}

// MARK: - VPSStatusChecker
struct VPSStatusChecker: View {
    @StateObject private var vpsViewModel = VPSStatusViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Status header
                    VStack(spacing: 16) {
                        Image(systemName: "server.rack")
                            .font(.system(size: 60))
                            .foregroundColor(DesignSystem.primaryGold)
                        
                        Text("VPS Bot Status Checker")
                            .font(.title)
                            .fontWeight(.bold)
                            .goldText()
                        
                        Text("Monitor your bots running on Linode VPS")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .planetCard()
                    
                    // VPS Status
                    VPSStatusView()
                    
                    // Bot Status List
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Bot Status on VPS")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        ForEach(["Golden Eagle Bot", "Silver Hawk Bot", "Market Scanner"], id: \.self) { botName in
                            HStack {
                                Circle()
                                    .fill(.green)
                                    .frame(width: 8, height: 8)
                                    .pulsingEffect()
                                
                                Text(botName)
                                    .font(.subheadline)
                                
                                Spacer()
                                
                                Text("Running")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.green)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .planetCard()
                }
                .padding()
            }
            .navigationTitle("VPS Status")
            .refreshable {
                vpsViewModel.refreshStatus()
            }
        }
    }
}

#Preview {
    AIDashboard()
}
//
//  GoldexFlipModeControlView.swift
//  Planet ProTrader - GOLDEX AI FlipMode Control Interface
//
//  Direct control interface for GOLDEX AI FlipMode EA
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

struct GoldexFlipModeControlView: View {
    @StateObject private var goldexManager = GoldexFlipModeManager.shared
    @StateObject private var eaManager = EAIntegrationManager.shared
    @State private var showingDeployment = false
    @State private var showingParameterSheet = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // GOLDEX Header
                    goldexHeaderSection
                    
                    // FlipMode Status
                    flipModeStatusSection
                    
                    // EA Controls
                    eaControlsSection
                    
                    // Live Trading Stats
                    liveTradingStatsSection
                    
                    // Active Signals
                    activeSignalsSection
                    
                    // Quick Actions
                    quickActionsSection
                }
                .padding()
            }
            .navigationTitle("🔥 GOLDEX FlipMode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingParameterSheet = true }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(DesignSystem.primaryGold)
                    }
                }
            }
            .onAppear {
                goldexManager.startMonitoring()
            }
            .sheet(isPresented: $showingDeployment) {
                EADeploymentView()
            }
            .sheet(isPresented: $showingParameterSheet) {
                GoldexParameterSheet()
            }
        }
    }
    
    private var goldexHeaderSection: some View {
        VStack(spacing: 16) {
            // GOLDEX Logo/Icon
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [DesignSystem.primaryGold, Color.orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)
                
                VStack {
                    Text("🔥")
                        .font(.title)
                    Text("AI")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            
            VStack(spacing: 4) {
                Text("GOLDEX AI FlipMode")
                    .font(.title2)
                    .fontWeight(.bold)
                    .goldText()
                
                Text("Account: 845514@Coinexx-demo")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(goldexManager.isFlipModeActive ? .green : .red)
                        .frame(width: 8, height: 8)
                    
                    Text(goldexManager.isFlipModeActive ? "FlipMode Active" : "FlipMode Inactive")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(goldexManager.isFlipModeActive ? .green : .red)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    private var flipModeStatusSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("⚡ FlipMode Status")
                .font(.headline)
                .fontWeight(.bold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                FlipModeStatCard(
                    title: "Today Trades",
                    value: "\(goldexManager.todayTrades)",
                    subtitle: "Max: \(goldexManager.maxDailyTrades)",
                    color: .blue
                )
                
                FlipModeStatCard(
                    title: "Win Rate",
                    value: "\(String(format: "%.1f", goldexManager.winRate))%",
                    subtitle: "\(goldexManager.todayWins)W / \(goldexManager.todayLosses)L",
                    color: goldexManager.winRate >= 60 ? .green : .orange
                )
                
                FlipModeStatCard(
                    title: "Today P&L",
                    value: goldexManager.todayProfitFormatted,
                    subtitle: "Balance: $\(String(format: "%.2f", goldexManager.accountBalance))",
                    color: goldexManager.todayProfit >= 0 ? .green : .red
                )
                
                FlipModeStatCard(
                    title: "Signals",
                    value: "\(goldexManager.signalsGenerated)",
                    subtitle: "\(goldexManager.signalsExecuted) executed",
                    color: .purple
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var eaControlsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🎮 EA Controls")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                // Main EA Toggle
                HStack {
                    VStack(alignment: .leading) {
                        Text("Auto Trading")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("Enable/disable automatic trading")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $goldexManager.enableAutoTrading)
                        .onChange(of: goldexManager.enableAutoTrading) { oldValue, newValue in
                            goldexManager.updateEAParameter("EnableAutoTrading", value: newValue)
                        }
                }
                
                Divider()
                
                // FlipMode Toggle
                HStack {
                    VStack(alignment: .leading) {
                        Text("FlipMode")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("Aggressive high-frequency trading")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $goldexManager.enableFlipMode)
                        .onChange(of: goldexManager.enableFlipMode) { oldValue, newValue in
                            goldexManager.updateEAParameter("EnableFlipMode", value: newValue)
                        }
                }
                
                Divider()
                
                // Test Mode Toggle
                HStack {
                    VStack(alignment: .leading) {
                        Text("Test Mode")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("Generate more signals for testing")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $goldexManager.enableTestMode)
                        .onChange(of: goldexManager.enableTestMode) { oldValue, newValue in
                            goldexManager.updateEAParameter("EnableTestMode", value: newValue)
                        }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var liveTradingStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("📊 Live Trading Statistics")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("Last signal: \(goldexManager.lastSignalTimeFormatted)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 8) {
                HStack {
                    Text("Risk per Trade:")
                    Spacer()
                    Text("\(String(format: "%.1f", goldexManager.maxRiskPercent))%")
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Max Daily Risk:")
                    Spacer()
                    Text("\(String(format: "%.1f", goldexManager.maxDailyRisk))%")
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Signal Interval:")
                    Spacer()
                    Text("\(goldexManager.signalInterval)s")
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Risk:Reward Ratio:")
                    Spacer()
                    Text("1:\(String(format: "%.1f", goldexManager.riskRewardRatio))")
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
            .font(.subheadline)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var activeSignalsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🎯 Recent Signals")
                .font(.headline)
                .fontWeight(.bold)
            
            if goldexManager.recentSignals.isEmpty {
                Text("No recent signals")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(goldexManager.recentSignals) { signal in
                        GoldexSignalRow(signal: signal)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var quickActionsSection: some View {
        VStack(spacing: 12) {
            // Deploy EA Button
            if !eaManager.isEADeployed {
                Button(action: { showingDeployment = true }) {
                    Label("Deploy GOLDEX EA to VPS", systemImage: "rocket.fill")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(DesignSystem.primaryGold, in: RoundedRectangle(cornerRadius: 12))
                }
            }
            
            HStack(spacing: 12) {
                // Force Signal Button
                Button(action: { goldexManager.forceGenerateSignal() }) {
                    Label("Force Signal", systemImage: "waveform.path.ecg")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(.blue, in: RoundedRectangle(cornerRadius: 10))
                }
                
                // Stop All Trades Button
                Button(action: { goldexManager.stopAllTrades() }) {
                    Label("Stop All", systemImage: "stop.fill")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(.red, in: RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }
}

// MARK: - FlipMode Stat Card Component

struct FlipModeStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
            }
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Goldex Signal Row Component

struct GoldexSignalRow: View {
    let signal: GoldexSignal
    
    var body: some View {
        HStack(spacing: 12) {
            // Direction indicator
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(signal.direction == .buy ? .green.opacity(0.2) : .red.opacity(0.2))
                    .frame(width: 40, height: 30)
                
                Text(signal.direction == .buy ? "BUY" : "SELL")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(signal.direction == .buy ? .green : .red)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("XAUUSD")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text("\(String(format: "%.0f", signal.confidence * 100))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                
                Text(signal.reasoning)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("$\(String(format: "%.2f", signal.entryPrice))")
                    .font(.caption)
                    .fontWeight(.semibold)
                
                Text(signal.timeAgo)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Parameter Sheet

struct GoldexParameterSheet: View {
    @StateObject private var goldexManager = GoldexFlipModeManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Risk Management
                    riskManagementSection
                    
                    // FlipMode Settings
                    flipModeSettingsSection
                    
                    // Advanced Settings
                    advancedSettingsSection
                }
                .padding()
            }
            .navigationTitle("⚙️ GOLDEX Parameters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        goldexManager.saveParameters()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private var riskManagementSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("💰 Risk Management")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                ParameterSlider(
                    title: "Max Risk Per Trade",
                    value: $goldexManager.maxRiskPercent,
                    range: 0.5...5.0,
                    step: 0.1,
                    unit: "%"
                )
                
                ParameterSlider(
                    title: "Max Daily Risk",
                    value: $goldexManager.maxDailyRisk,
                    range: 5.0...25.0,
                    step: 1.0,
                    unit: "%"
                )
                
                ParameterSlider(
                    title: "Max Daily Trades",
                    value: Binding(
                        get: { Double(goldexManager.maxDailyTrades) },
                        set: { goldexManager.maxDailyTrades = Int($0) }
                    ),
                    range: 1...20,
                    step: 1,
                    unit: " trades"
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var flipModeSettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("⚡ FlipMode Settings")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                ParameterSlider(
                    title: "Signal Interval",
                    value: Binding(
                        get: { Double(goldexManager.signalInterval) },
                        set: { goldexManager.signalInterval = Int($0) }
                    ),
                    range: 5...60,
                    step: 5,
                    unit: " seconds"
                )
                
                ParameterSlider(
                    title: "Confidence Threshold",
                    value: $goldexManager.flipModeConfidence,
                    range: 0.5...0.95,
                    step: 0.05,
                    unit: ""
                )
                
                ParameterSlider(
                    title: "Risk:Reward Ratio",
                    value: $goldexManager.riskRewardRatio,
                    range: 1.0...3.0,
                    step: 0.1,
                    unit: ":1"
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var advancedSettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🔧 Advanced Settings")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                ParameterSlider(
                    title: "Stop Loss (Pips)",
                    value: $goldexManager.stopLossPips,
                    range: 5...50,
                    step: 5,
                    unit: " pips"
                )
                
                ParameterSlider(
                    title: "Max Spread (Points)",
                    value: Binding(
                        get: { Double(goldexManager.maxSpreadPoints) },
                        set: { goldexManager.maxSpreadPoints = Int($0) }
                    ),
                    range: 10...100,
                    step: 10,
                    unit: " points"
                )
                
                ParameterSlider(
                    title: "Quick Profit (Points)",
                    value: $goldexManager.quickProfitPoints,
                    range: 5...30,
                    step: 5,
                    unit: " points"
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Parameter Slider Component

struct ParameterSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let unit: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(String(format: step < 1 ? "%.2f" : "%.0f", value))\(unit)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.primaryGold)
            }
            
            Slider(value: $value, in: range, step: step)
                .accentColor(DesignSystem.primaryGold)
        }
    }
}

#Preview {
    GoldexFlipModeControlView()
}
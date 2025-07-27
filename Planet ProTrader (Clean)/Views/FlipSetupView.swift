//
//  FlipSetupView.swift
//  Planet ProTrader (Clean)
//
//  Created by Keonta Peat on 1/25/25.
//

import SwiftUI

struct FlipSetupView: View {
    @StateObject private var flipManager = FlipChallengeManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedPreset: FlipPreset = .tenK
    @State private var customStartAmount: String = ""
    @State private var customTargetAmount: String = ""
    @State private var selectedTimeframe: FlipTimeframe = .oneWeek
    @State private var selectedStrategy: FlipStrategy = .balanced
    @State private var showingConfirmation = false
    @State private var createdChallenge: FlipChallenge?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Preset Selection
                    presetSelectionSection
                    
                    // Custom Amount (if custom preset selected)
                    if selectedPreset == .custom {
                        customAmountSection
                    }
                    
                    // Timeframe Selection
                    timeframeSelectionSection
                    
                    // Strategy Selection
                    strategySelectionSection
                    
                    // Challenge Summary
                    challengeSummarySection
                    
                    // Create Challenge Button
                    createChallengeButton
                }
                .padding()
            }
            .navigationTitle("🎯 Flip Challenge Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Challenge Created!", isPresented: $showingConfirmation) {
                Button("Start Now") {
                    if let challenge = createdChallenge {
                        flipManager.startChallenge(challenge)
                    }
                    dismiss()
                }
                Button("Start Later") {
                    dismiss()
                }
            } message: {
                Text("Your flip challenge has been created successfully!")
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "target")
                .font(.system(size: 50))
                .foregroundColor(DesignSystem.primaryGold)
            
            VStack(spacing: 8) {
                Text("Create Flip Challenge")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Set your trading goal and timeframe")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var presetSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("💰 Challenge Amount")
                .font(.headline)
                .fontWeight(.bold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(FlipPreset.allCases) { preset in
                    PresetCard(
                        preset: preset,
                        isSelected: selectedPreset == preset,
                        action: { selectedPreset = preset }
                    )
                }
            }
        }
    }
    
    private var customAmountSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🎛️ Custom Amounts")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Starting Amount")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("Enter starting amount", text: $customStartAmount)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Target Amount")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("Enter target amount", text: $customTargetAmount)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                }
            }
        }
    }
    
    private var timeframeSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("⏰ Timeframe")
                .font(.headline)
                .fontWeight(.bold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(FlipTimeframe.allCases) { timeframe in
                    TimeframeCard(
                        timeframe: timeframe,
                        isSelected: selectedTimeframe == timeframe,
                        action: { selectedTimeframe = timeframe }
                    )
                }
            }
        }
    }
    
    private var strategySelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📈 Strategy")
                .font(.headline)
                .fontWeight(.bold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(FlipStrategy.allCases) { strategy in
                    StrategyCard(
                        strategy: strategy,
                        isSelected: selectedStrategy == strategy,
                        action: { selectedStrategy = strategy }
                    )
                }
            }
        }
    }
    
    private var challengeSummarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📋 Challenge Summary")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                SummaryRow(
                    title: "Starting Amount:",
                    value: formatCurrency(getStartingAmount()),
                    color: .blue
                )
                
                SummaryRow(
                    title: "Target Amount:",
                    value: formatCurrency(getTargetAmount()),
                    color: .green
                )
                
                SummaryRow(
                    title: "Timeframe:",
                    value: "\(selectedTimeframe.displayName) (\(selectedTimeframe.difficulty))",
                    color: selectedTimeframe.color
                )
                
                SummaryRow(
                    title: "Strategy:",
                    value: "\(selectedStrategy.rawValue) (\(selectedStrategy.riskLevel) Risk)",
                    color: selectedStrategy.color
                )
                
                SummaryRow(
                    title: "Required Growth:",
                    value: "\(String(format: "%.1f", getRequiredGrowthPercentage()))%",
                    color: getRequiredGrowthPercentage() > 1000 ? .red : .orange
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var createChallengeButton: some View {
        Button(action: createChallenge) {
            HStack {
                Image(systemName: "target")
                    .font(.title3)
                
                Text("Create Challenge")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                isValidChallenge() ? DesignSystem.primaryGold : Color.gray,
                in: RoundedRectangle(cornerRadius: 12)
            )
        }
        .disabled(!isValidChallenge())
    }
    
    // MARK: - Helper Methods
    
    private func getStartingAmount() -> Double {
        if selectedPreset == .custom {
            return Double(customStartAmount) ?? 0
        }
        return selectedPreset.startingAmount
    }
    
    private func getTargetAmount() -> Double {
        if selectedPreset == .custom {
            return Double(customTargetAmount) ?? 0
        }
        return selectedPreset.targetAmount
    }
    
    private func getRequiredGrowthPercentage() -> Double {
        let start = getStartingAmount()
        let target = getTargetAmount()
        guard start > 0 else { return 0 }
        return ((target - start) / start) * 100
    }
    
    private func isValidChallenge() -> Bool {
        let start = getStartingAmount()
        let target = getTargetAmount()
        return start > 0 && target > start
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        return "$\(String(format: "%.0f", amount))"
    }
    
    private func createChallenge() {
        let challenge = flipManager.createChallenge(
            preset: selectedPreset,
            timeframe: selectedTimeframe,
            strategy: selectedStrategy,
            customStart: selectedPreset == .custom ? getStartingAmount() : 0,
            customTarget: selectedPreset == .custom ? getTargetAmount() : 0
        )
        
        createdChallenge = challenge
        showingConfirmation = true
    }
}

// MARK: - Supporting Views

struct PresetCard: View {
    let preset: FlipPreset
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(preset.rawValue)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? .white : preset.color)
                
                Text(preset.displayName)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(
                isSelected ? preset.color : preset.color.opacity(0.1),
                in: RoundedRectangle(cornerRadius: 12)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(preset.color, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TimeframeCard: View {
    let timeframe: FlipTimeframe
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(timeframe.rawValue)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? .white : timeframe.color)
                
                Text(timeframe.difficulty)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(
                isSelected ? timeframe.color : timeframe.color.opacity(0.1),
                in: RoundedRectangle(cornerRadius: 8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(timeframe.color, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct StrategyCard: View {
    let strategy: FlipStrategy
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(strategy.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : strategy.color)
                
                Text(strategy.description)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(strategy.riskLevel)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        isSelected ? Color.white.opacity(0.2) : strategy.color.opacity(0.2),
                        in: Capsule()
                    )
                    .foregroundColor(isSelected ? .white : strategy.color)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .padding(8)
            .background(
                isSelected ? strategy.color : strategy.color.opacity(0.1),
                in: RoundedRectangle(cornerRadius: 12)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(strategy.color, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SummaryRow: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

#Preview {
    FlipSetupView()
}
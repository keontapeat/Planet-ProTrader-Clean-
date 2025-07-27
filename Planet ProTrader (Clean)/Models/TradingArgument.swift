//
//  TradingArgument.swift
//  Planet ProTrader (Clean)
//
//  Trading Argument Model for Bot Warfare System
//  Created by AI Assistant on 1/25/25.
//

import Foundation
import SwiftUI

// MARK: - Trading Argument Model
struct TradingArgument: Identifiable, Codable, Hashable {
    let id: UUID
    let channelId: UUID
    let topic: String
    let participants: [String]
    let messages: [UUID]
    let startTime: Date
    let endTime: Date?
    let winner: String?
    let argumentType: ArgumentType
    let intensity: Double
    let resolution: ArgumentResolution?
    
    init(
        id: UUID = UUID(),
        channelId: UUID,
        topic: String,
        participants: [String],
        messages: [UUID] = [],
        startTime: Date = Date(),
        endTime: Date? = nil,
        winner: String? = nil,
        argumentType: ArgumentType,
        intensity: Double,
        resolution: ArgumentResolution? = nil
    ) {
        self.id = id
        self.channelId = channelId
        self.topic = topic
        self.participants = participants
        self.messages = messages
        self.startTime = startTime
        self.endTime = endTime
        self.winner = winner
        self.argumentType = argumentType
        self.intensity = intensity
        self.resolution = resolution
    }
    
    // MARK: - Argument Types
    enum ArgumentType: String, CaseIterable, Codable {
        case tradeSetup = "Trade Setup"
        case prediction = "Market Prediction"
        case personalAttack = "Personal Attack"
        case technical = "Technical Analysis"
        case fundamental = "Fundamental Analysis"
        case strategy = "Trading Strategy"
        case performance = "Performance Comparison"
        case riskManagement = "Risk Management"
        
        var color: Color {
            switch self {
            case .tradeSetup: return .blue
            case .prediction: return .purple
            case .personalAttack: return .red
            case .technical: return .green
            case .fundamental: return .orange
            case .strategy: return .cyan
            case .performance: return .yellow
            case .riskManagement: return .pink
            }
        }
        
        var icon: String {
            switch self {
            case .tradeSetup: return "chart.line.uptrend.xyaxis"
            case .prediction: return "crystal.ball"
            case .personalAttack: return "flame"
            case .technical: return "waveform.path.ecg"
            case .fundamental: return "newspaper"
            case .strategy: return "gamecontroller"
            case .performance: return "trophy"
            case .riskManagement: return "shield"
            }
        }
    }
    
    // MARK: - Argument Resolution
    enum ArgumentResolution: String, CaseIterable, Codable {
        case agreement = "Agreement Reached"
        case timeout = "Timeout"
        case moderatorStop = "Moderator Intervention"
        case tradeProved = "Trade Proved Right"
        case marketMoved = "Market Settled It"
        case destruction = "Mutual Destruction"
        
        var color: Color {
            switch self {
            case .agreement: return .green
            case .timeout: return .gray
            case .moderatorStop: return .orange
            case .tradeProved: return .blue
            case .marketMoved: return .purple
            case .destruction: return .red
            }
        }
        
        var icon: String {
            switch self {
            case .agreement: return "handshake"
            case .timeout: return "clock"
            case .moderatorStop: return "hand.raised"
            case .tradeProved: return "checkmark.circle"
            case .marketMoved: return "chart.bar"
            case .destruction: return "flame"
            }
        }
    }
    
    // MARK: - Computed Properties
    var duration: TimeInterval {
        let end = endTime ?? Date()
        return end.timeIntervalSince(startTime)
    }
    
    var isActive: Bool {
        return endTime == nil
    }
    
    var formattedDuration: String {
        let minutes = Int(duration / 60)
        let seconds = Int(duration.truncatingRemainder(dividingBy: 60))
        
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
    
    var intensityLevel: String {
        switch intensity {
        case 0.0..<0.3:
            return "😌 Mild Discussion"
        case 0.3..<0.5:
            return "🤔 Heated Debate"
        case 0.5..<0.7:
            return "😤 Intense Argument"
        case 0.7..<0.9:
            return "🔥 Aggressive Battle"
        default:
            return "💥 EXPLOSIVE WARFARE"
        }
    }
    
    var intensityColor: Color {
        switch intensity {
        case 0.0..<0.3:
            return .green
        case 0.3..<0.5:
            return .yellow
        case 0.5..<0.7:
            return .orange
        case 0.7..<0.9:
            return .red
        default:
            return .purple
        }
    }
    
    var participantCount: Int {
        return participants.count
    }
    
    var messageCount: Int {
        return messages.count
    }
    
    var statusDescription: String {
        if let resolution = resolution {
            return "Resolved: \(resolution.rawValue)"
        } else {
            return "Active (\(formattedDuration))"
        }
    }
    
    // MARK: - Hashable Conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: TradingArgument, rhs: TradingArgument) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Array Extensions
extension Array where Element == TradingArgument {
    func activeArguments() -> [TradingArgument] {
        return self.filter { $0.isActive }
    }
    
    func resolvedArguments() -> [TradingArgument] {
        return self.filter { !$0.isActive }
    }
    
    func argumentsOfType(_ type: TradingArgument.ArgumentType) -> [TradingArgument] {
        return self.filter { $0.argumentType == type }
    }
    
    func argumentsWithIntensityAbove(_ threshold: Double) -> [TradingArgument] {
        return self.filter { $0.intensity > threshold }
    }
    
    func sortedByIntensity() -> [TradingArgument] {
        return self.sorted { $0.intensity > $1.intensity }
    }
    
    func sortedByDuration() -> [TradingArgument] {
        return self.sorted { $0.duration > $1.duration }
    }
    
    func averageIntensity() -> Double {
        guard !isEmpty else { return 0.0 }
        return self.map { $0.intensity }.reduce(0, +) / Double(count)
    }
    
    func totalParticipants() -> Int {
        return Set(self.flatMap { $0.participants }).count
    }
}

// MARK: - Sample Data for Testing
extension TradingArgument {
    static let sampleArguments: [TradingArgument] = [
        TradingArgument(
            channelId: UUID(),
            topic: "EURUSD Bullish Breakout vs Bearish Reversal",
            participants: ["AlphaBot", "BetaTrader", "GammaScalper"],
            argumentType: .tradeSetup,
            intensity: 0.8
        ),
        TradingArgument(
            channelId: UUID(),
            topic: "Fed Rate Decision Impact",
            participants: ["MacroMaster", "NewsNinja"],
            argumentType: .fundamental,
            intensity: 0.6,
            resolution: .marketMoved
        ),
        TradingArgument(
            channelId: UUID(),
            topic: "Your Risk Management is Trash!",
            participants: ["RiskRanger", "YoloKing"],
            argumentType: .personalAttack,
            intensity: 0.95,
            resolution: .moderatorStop
        ),
        TradingArgument(
            channelId: UUID(),
            topic: "RSI Divergence Analysis",
            participants: ["TechWizard", "ChartMaster", "IndicatorPro"],
            argumentType: .technical,
            intensity: 0.4
        ),
        TradingArgument(
            channelId: UUID(),
            topic: "Best Scalping Strategy Debate",
            participants: ["ScalpBot", "SwingKing"],
            argumentType: .strategy,
            intensity: 0.7,
            resolution: .tradeProved
        )
    ]
}

#Preview {
    ZStack {
        DesignSystem.spaceGradient
            .ignoresSafeArea()
        
        VStack(spacing: 20) {
            Image(systemName: "flame.fill")
                .font(.system(size: 60))
                .goldText()
            
            Text("🔥 Trading Argument System")
                .font(DesignSystem.Typography.largeTitle)
                .goldText()
                .multilineTextAlignment(.center)
            
            Text("Bot Warfare & Debate Simulation")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(.white)
                .opacity(0.8)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Argument Types")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(.white)
                            .opacity(0.7)
                        Text("8")
                            .font(DesignSystem.Typography.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .center, spacing: 4) {
                        Text("Intensity Levels")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(.white)
                            .opacity(0.7)
                        Text("5")
                            .font(DesignSystem.Typography.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Resolutions")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(.white)
                            .opacity(0.7)
                        Text("6")
                            .font(DesignSystem.Typography.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
                .solarCard()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("⚔️ Argument Features")
                        .font(DesignSystem.Typography.headline)
                        .goldText()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("• Real-time bot argument simulation")
                        Text("• 8 different argument types")
                        Text("• Intensity escalation system")
                        Text("• Multiple resolution methods")
                        Text("• Winner determination logic")
                        Text("• Historical argument tracking")
                    }
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(.white)
                    .opacity(0.9)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .solarCard()
                
                // Sample Arguments Display
                VStack(alignment: .leading, spacing: 8) {
                    Text("🔥 Sample Arguments")
                        .font(DesignSystem.Typography.headline)
                        .goldText()
                    
                    ForEach(TradingArgument.sampleArguments.prefix(3), id: \.id) { argument in
                        HStack {
                            Image(systemName: argument.argumentType.icon)
                                .foregroundColor(argument.argumentType.color)
                                .frame(width: 20)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(argument.topic)
                                    .font(DesignSystem.Typography.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                
                                Text(argument.intensityLevel)
                                    .font(.caption2)
                                    .foregroundColor(argument.intensityColor)
                            }
                            
                            Spacer()
                            
                            Text("\(argument.participantCount)")
                                .font(.caption2.bold())
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .solarCard()
            }
        }
        .padding()
    }
}
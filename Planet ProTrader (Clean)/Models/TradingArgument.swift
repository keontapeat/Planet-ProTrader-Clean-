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
struct TradingArgument: Identifiable {
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
    enum ArgumentType: String, CaseIterable {
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
    enum ArgumentResolution: String, CaseIterable {
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
}

// MARK: - Extensions
extension TradingArgument: Codable {
    enum CodingKeys: String, CodingKey {
        case id, channelId, topic, participants, messages
        case startTime, endTime, winner, argumentType, intensity, resolution
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        channelId = try container.decode(UUID.self, forKey: .channelId)
        topic = try container.decode(String.self, forKey: .topic)
        participants = try container.decode([String].self, forKey: .participants)
        messages = try container.decode([UUID].self, forKey: .messages)
        startTime = try container.decode(Date.self, forKey: .startTime)
        endTime = try container.decodeIfPresent(Date.self, forKey: .endTime)
        winner = try container.decodeIfPresent(String.self, forKey: .winner)
        argumentType = try container.decode(ArgumentType.self, forKey: .argumentType)
        intensity = try container.decode(Double.self, forKey: .intensity)
        resolution = try container.decodeIfPresent(ArgumentResolution.self, forKey: .resolution)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(channelId, forKey: .channelId)
        try container.encode(topic, forKey: .topic)
        try container.encode(participants, forKey: .participants)
        try container.encode(messages, forKey: .messages)
        try container.encode(startTime, forKey: .startTime)
        try container.encodeIfPresent(endTime, forKey: .endTime)
        try container.encodeIfPresent(winner, forKey: .winner)
        try container.encode(argumentType, forKey: .argumentType)
        try container.encode(intensity, forKey: .intensity)
        try container.encodeIfPresent(resolution, forKey: .resolution)
    }
}

extension TradingArgument: Hashable {
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

#Preview {
    VStack(spacing: 20) {
        Image(systemName: "flame.fill")
            .font(.system(size: 60))
            .foregroundColor(.red)
        
        Text("Trading Argument System")
            .font(.largeTitle)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
        
        Text("Bot Warfare & Debate Simulation")
            .font(.title3)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
        
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Argument Types")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("8")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                VStack(alignment: .center, spacing: 4) {
                    Text("Intensity Levels")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("5")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Resolutions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("6")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("🔥 Argument Features")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("• Real-time bot argument simulation")
                    Text("• 8 different argument types")
                    Text("• Intensity escalation system")
                    Text("• Multiple resolution methods")
                    Text("• Winner determination logic")
                    Text("• Historical argument tracking")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.red.opacity(0.1))
            .cornerRadius(12)
        }
    }
    .padding()
}
//
//  AdvancedEnginesTypes.swift
//  Planet ProTrader
//
//  Supporting types for Advanced Trading Engines Integration
//  Created by AI Assistant on 1/25/25.
//

import Foundation
import SwiftUI

// MARK: - Advanced Engines Analysis Types
struct CandlestickData {
    let timestamp: Date
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let volume: Double
    
    var formattedPrice: String {
        String(format: "$%.2f", close)
    }
    
    var isGreen: Bool { close > open }
    var bodySize: Double { abs(close - open) }
    var wickSize: Double { high - low }
}

struct MACDData {
    let macd: Double
    let signal: Double
    let histogram: Double
    
    var isBullish: Bool { macd > signal }
    var strength: Double { abs(histogram) }
    
    var formattedMACD: String {
        String(format: "%.4f", macd)
    }
    
    var formattedSignal: String {
        String(format: "%.4f", signal)
    }
}

struct FibonacciLevels {
    let levels: [FibLevel]
    let swingHigh: Double
    let swingLow: Double
    let direction: FibDirection
    
    struct FibLevel {
        let percentage: Double
        let price: Double
        let label: String
        
        var formattedPrice: String {
            String(format: "$%.2f", price)
        }
        
        var formattedPercentage: String {
            String(format: "%.1f%%", percentage * 100)
        }
    }
    
    enum FibDirection {
        case uptrend
        case downtrend
        
        var color: Color {
            switch self {
            case .uptrend: return .green
            case .downtrend: return .red
            }
        }
        
        var icon: String {
            switch self {
            case .uptrend: return "arrow.up.circle.fill"
            case .downtrend: return "arrow.down.circle.fill"
            }
        }
    }
}

enum TrendDirection {
    case bullish
    case bearish
    case neutral
    
    var color: Color {
        switch self {
        case .bullish: return .green
        case .bearish: return .red
        case .neutral: return .gray
        }
    }
    
    var emoji: String {
        switch self {
        case .bullish: return "🐂"
        case .bearish: return "🐻"
        case .neutral: return "➡️"
        }
    }
}

// MARK: - Advanced Engines Report
struct AdvancedEnginesReport {
    let status: PersistentBotManager.AdvancedEnginesStatus
    let timeframeAnalysisActive: Bool
    let structureAnalysisActive: Bool
    let autopilotHealth: Double
    let strategyRebuilderStatus: SystemStatus
    let lastAnalysis: Date
    let analysisQuality: Double
    let nuclearResets: Int
    
    var overallRating: EngineRating {
        let avgHealth = (status.overallEngineHealth + autopilotHealth + (analysisQuality * 100)) / 3
        
        switch avgHealth {
        case 95...100: return .godmode
        case 85..<95: return .elite
        case 75..<85: return .advanced
        case 60..<75: return .active
        case 40..<60: return .limited
        default: return .offline
        }
    }
    
    enum EngineRating: String, CaseIterable {
        case godmode = "GODMODE"
        case elite = "ELITE"
        case advanced = "ADVANCED"
        case active = "ACTIVE"
        case limited = "LIMITED"
        case offline = "OFFLINE"
        
        var color: Color {
            switch self {
            case .godmode: return .purple
            case .elite: return .cyan
            case .advanced: return .green
            case .active: return .blue
            case .limited: return .orange
            case .offline: return .red
            }
        }
        
        var emoji: String {
            switch self {
            case .godmode: return "🚀"
            case .elite: return "⚡"
            case .advanced: return "🔥"
            case .active: return "✅"
            case .limited: return "⚠️"
            case .offline: return "❌"
            }
        }
        
        var description: String {
            switch self {
            case .godmode: return "Maximum performance with all systems optimized"
            case .elite: return "High-performance trading with advanced analysis"
            case .advanced: return "Professional-grade trading capabilities"
            case .active: return "Standard trading operations active"
            case .limited: return "Basic functionality with reduced features"
            case .offline: return "Systems offline or experiencing issues"
            }
        }
    }
    
    var healthPercentage: Int {
        Int(overallRating.rawValue == "GODMODE" ? 100 : 
            overallRating.rawValue == "ELITE" ? 90 :
            overallRating.rawValue == "ADVANCED" ? 80 :
            overallRating.rawValue == "ACTIVE" ? 70 :
            overallRating.rawValue == "LIMITED" ? 50 : 0)
    }
    
    var analysisQualityText: String {
        String(format: "%.1f%%", analysisQuality * 100)
    }
    
    var timeSinceLastAnalysis: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: lastAnalysis, relativeTo: Date())
    }
}

// MARK: - Advanced Analysis Result
struct AdvancedAnalysisResult {
    let symbol: String
    let timeframe: String
    let trend: SharedTypes.TrendDirection
    let confidence: Double
    let signals: [AnalysisSignal]
    let fibonacciLevels: TradingModels.FibonacciLevels?
    let macdData: TradingModels.MACDData?
    let candlestickPattern: CandlestickPattern?
    let timestamp: Date
    
    struct AnalysisSignal {
        let type: SignalType
        let strength: Double
        let description: String
        let action: TradeDirection?
        
        enum SignalType: String, CaseIterable {
            case entry = "Entry"
            case exit = "Exit"
            case warning = "Warning"
            case confirmation = "Confirmation"
            
            var color: Color {
                switch self {
                case .entry: return .green
                case .exit: return .red
                case .warning: return .orange
                case .confirmation: return .blue
                }
            }
            
            var icon: String {
                switch self {
                case .entry: return "arrow.right.circle.fill"
                case .exit: return "arrow.left.circle.fill"
                case .warning: return "exclamationmark.triangle.fill"
                case .confirmation: return "checkmark.circle.fill"
                }
            }
        }
    }
    
    enum CandlestickPattern: String, CaseIterable {
        case doji = "Doji"
        case hammer = "Hammer"
        case shootingStar = "Shooting Star"
        case engulfing = "Engulfing"
        case morningStar = "Morning Star"
        case eveningStar = "Evening Star"
        
        var isBullish: Bool {
            switch self {
            case .hammer, .morningStar, .engulfing:
                return true
            case .shootingStar, .eveningStar:
                return false
            case .doji:
                return false // Neutral
            }
        }
        
        var color: Color {
            if isBullish {
                return .green
            } else {
                return .red
            }
        }
        
        var description: String {
            switch self {
            case .doji: return "Market indecision - potential reversal"
            case .hammer: return "Bullish reversal signal"
            case .shootingStar: return "Bearish reversal signal"
            case .engulfing: return "Strong reversal pattern"
            case .morningStar: return "Bullish reversal confirmation"
            case .eveningStar: return "Bearish reversal confirmation"
            }
        }
    }
    
    var overallScore: Double {
        let trendWeight = 0.4
        let confidenceWeight = 0.3
        let signalWeight = 0.3
        
        let trendScore = trend == .neutral ? 0.5 : 1.0
        let avgSignalStrength = signals.isEmpty ? 0.5 : signals.map { $0.strength }.reduce(0, +) / Double(signals.count)
        
        return (trendScore * trendWeight) + (confidence * confidenceWeight) + (avgSignalStrength * signalWeight)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 60))
                    .foregroundColor(.purple)
                
                Text("Advanced Engines Integration")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Multi-Engine Analysis System")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            // Status Cards
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                VStack(spacing: 8) {
                    HStack {
                        Text("🚀")
                            .font(.title)
                        Text("GODMODE")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                    }
                    Text("Maximum Performance")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color.purple.opacity(0.1))
                .cornerRadius(12)
                
                VStack(spacing: 8) {
                    HStack {
                        Text("⚡")
                            .font(.title)
                        Text("98.5%")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    Text("Analysis Quality")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
                
                VStack(spacing: 8) {
                    HStack {
                        Text("🔥")
                            .font(.title)
                        Text("Active")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    Text("AutoPilot Status")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                
                VStack(spacing: 8) {
                    HStack {
                        Text("🎯")
                            .font(.title)
                        Text("Nuclear")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }
                    Text("Reset Ready")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
            }
            
            // Analysis Features
            VStack(alignment: .leading, spacing: 12) {
                Text("Advanced Features")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                VStack(spacing: 8) {
                    AdvancedFeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Multi-Timeframe Analysis", status: "Active")
                    AdvancedFeatureRow(icon: "waveform.path.ecg", title: "Market Structure Analysis", status: "Active")
                    AdvancedFeatureRow(icon: "brain.head.profile", title: "Self-Healing AutoPilot", status: "Monitoring")
                    AdvancedFeatureRow(icon: "arrow.triangle.2.circlepath", title: "Strategy Rebuilder", status: "Optimized")
                    AdvancedFeatureRow(icon: "scope", title: "Fibonacci Analysis", status: "Real-time")
                    AdvancedFeatureRow(icon: "waveform", title: "MACD Signals", status: "Enhanced")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
    }
}

struct AdvancedFeatureRow: View {
    let icon: String
    let title: String
    let status: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(title)
                .font(.body)
            
            Spacer()
            
            Text(status)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.2))
                .foregroundColor(.green)
                .cornerRadius(8)
        }
        .padding(.vertical, 4)
    }
}
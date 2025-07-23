//
//  MicroFlipGame.swift
//  Planet ProTrader (Clean)
//
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI
import Foundation

// MARK: - MicroFlipGame Model

struct MicroFlipGame: Identifiable, Codable {
    let id = UUID()
    let playerId: String
    let gameType: GameType
    let entryAmount: Double
    let targetAmount: Double
    let duration: TimeInterval
    var status: GameStatus
    let difficulty: Difficulty
    var currentBalance: Double
    var trades: [FlipTrade] = []
    var result: GameResult?
    let createdDate: Date
    var completedDate: Date?
    
    init(playerId: String, gameType: GameType, entryAmount: Double, targetAmount: Double, duration: TimeInterval, status: GameStatus, difficulty: Difficulty) {
        self.playerId = playerId
        self.gameType = gameType
        self.entryAmount = entryAmount
        self.targetAmount = targetAmount
        self.duration = duration
        self.status = status
        self.difficulty = difficulty
        self.currentBalance = entryAmount
        self.createdDate = Date()
    }
    
    // MARK: - Computed Properties
    
    var progressToTarget: Double {
        guard targetAmount > entryAmount else { return 0 }
        let progress = (currentBalance - entryAmount) / (targetAmount - entryAmount)
        return min(max(progress, 0), 1)
    }
    
    var timeRemaining: TimeInterval {
        let elapsed = Date().timeIntervalSince(createdDate)
        return max(duration - elapsed, 0)
    }
    
    var isTimeUp: Bool {
        timeRemaining <= 0
    }
    
    var profitLoss: Double {
        currentBalance - entryAmount
    }
    
    var profitLossPercentage: Double {
        ((currentBalance - entryAmount) / entryAmount) * 100
    }
    
    // MARK: - Game Types
    
    enum GameType: String, CaseIterable, Codable {
        case quickFlip = "Quick Flip"
        case speedRun = "Speed Run"
        case precision = "Precision"
        case endurance = "Endurance"
        case riskMaster = "Risk Master"
        case botBattle = "Bot Battle"
        
        var emoji: String {
            switch self {
            case .quickFlip: return "⚡"
            case .speedRun: return "🏃‍♂️"
            case .precision: return "🎯"
            case .endurance: return "🏋️‍♂️"
            case .riskMaster: return "🎲"
            case .botBattle: return "🤖"
            }
        }
        
        var displayName: String {
            return "\(emoji) \(rawValue)"
        }
        
        var description: String {
            switch self {
            case .quickFlip:
                return "Fast-paced 5-minute flips"
            case .speedRun:
                return "Race against time"
            case .precision:
                return "Accuracy over speed"
            case .endurance:
                return "Long-term challenge"
            case .riskMaster:
                return "High risk, high reward"
            case .botBattle:
                return "Compete against AI"
            }
        }
        
        var baseMultiplier: Double {
            switch self {
            case .quickFlip: return 1.5
            case .speedRun: return 2.0
            case .precision: return 1.8
            case .endurance: return 3.0
            case .riskMaster: return 4.0
            case .botBattle: return 2.5
            }
        }
    }
    
    // MARK: - Difficulty Levels
    
    enum Difficulty: String, CaseIterable, Codable {
        case rookie = "Rookie"
        case pro = "Pro"
        case expert = "Expert"
        
        var displayName: String {
            rawValue
        }
        
        var color: Color {
            switch self {
            case .rookie: return .green
            case .pro: return .blue
            case .expert: return .purple
            }
        }
        
        var multiplier: Double {
            switch self {
            case .rookie: return 1.0
            case .pro: return 1.2
            case .expert: return 1.5
            }
        }
    }
    
    // MARK: - Game Status
    
    enum GameStatus: String, CaseIterable, Codable {
        case active = "Active"
        case completed = "Completed"
        case failed = "Failed"
        case paused = "Paused"
        
        var displayName: String {
            rawValue
        }
        
        var color: Color {
            switch self {
            case .active: return .green
            case .completed: return .blue
            case .failed: return .red
            case .paused: return .orange
            }
        }
    }
    
    // MARK: - Game Result
    
    enum GameResult: Codable {
        case win(amount: Double)
        case loss(amount: Double)
        case timeout
        
        var displayText: String {
            switch self {
            case .win(let amount):
                return "+$\(String(format: "%.2f", amount))"
            case .loss(let amount):
                return "-$\(String(format: "%.2f", abs(amount)))"
            case .timeout:
                return "Timeout"
            }
        }
        
        var color: Color {
            switch self {
            case .win:
                return .green
            case .loss:
                return .red
            case .timeout:
                return .orange
            }
        }
    }
}

// MARK: - FlipTrade Model

struct FlipTrade: Identifiable, Codable {
    let id = UUID()
    let amount: Double
    let direction: TradeDirection
    let outcome: TradeOutcome
    let timestamp: Date
    let multiplier: Double
    
    enum TradeDirection: String, Codable {
        case up = "Up"
        case down = "Down"
        
        var emoji: String {
            switch self {
            case .up: return "📈"
            case .down: return "📉"
            }
        }
    }
    
    enum TradeOutcome: String, Codable {
        case win = "Win"
        case loss = "Loss"
        
        var color: Color {
            switch self {
            case .win: return .green
            case .loss: return .red
            }
        }
    }
    
    var profitLoss: Double {
        switch outcome {
        case .win:
            return amount * multiplier - amount
        case .loss:
            return -amount
        }
    }
}

// MARK: - Sample Data

extension MicroFlipGame {
    static let sampleGames: [MicroFlipGame] = [
        MicroFlipGame(
            playerId: "player1",
            gameType: .quickFlip,
            entryAmount: 50.0,
            targetAmount: 75.0,
            duration: 300,
            status: .completed,
            difficulty: .pro
        ),
        MicroFlipGame(
            playerId: "player1",
            gameType: .speedRun,
            entryAmount: 100.0,
            targetAmount: 200.0,
            duration: 180,
            status: .failed,
            difficulty: .expert
        ),
        MicroFlipGame(
            playerId: "player1",
            gameType: .precision,
            entryAmount: 25.0,
            targetAmount: 45.0,
            duration: 600,
            status: .completed,
            difficulty: .rookie
        )
    ]
}
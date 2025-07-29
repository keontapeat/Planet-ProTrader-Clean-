//
//  MarketplaceBotModel.swift
//  Planet ProTrader (Clean)
//
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI
import Foundation

// MARK: - Marketplace Bot Model
struct MarketplaceBotModel: Identifiable, Codable {
    let id = UUID()
    let name: String
    let creatorUsername: String
    let tagline: String
    let valueProposition: String
    let description: String
    let price: Double
    let rarity: BotRarity
    let tier: BotTier
    let verificationStatus: VerificationStatus
    let availability: BotAvailability
    let stats: BotStats
    let reviews: [BotReview]
    let tags: [String]
    let createdDate: Date
    let lastUpdated: Date
    
    // NEW: Character system and trading style
    var character: BotCharacter
    var tradingStyle: TradingStyle
    var isCustomizable: Bool
    var currentPitch: String
    var hasSpecialOffer: Bool
    var specialOfferDetails: String?
    
    var formattedPrice: String {
        if price == 0 {
            return "FREE"
        } else {
            return String(format: "$%.0f", price)
        }
    }
    
    var averageRating: Double {
        guard !reviews.isEmpty else { return 0.0 }
        return reviews.map(\.rating).reduce(0, +) / Double(reviews.count)
    }
    
    static func generateRandomBot() -> MarketplaceBotModel {
        let names = [
            "GoldMiner Pro", "Forex Wizard", "Crypto Beast", "Market Hunter", 
            "Profit Seeker", "Trade Master", "Currency King", "Scalp Legend",
            "Trend Rider", "Risk Ninja", "Money Maker", "Chart Reader",
            "Signal Prophet", "Trade Genius", "Market Shark", "Profit Hunter"
        ]
        
        let creators = [
            "TradingGuru", "MarketMaster", "ForexKing", "CryptoPro", 
            "ChartWizard", "ProfitMaker", "TrendFollower", "RiskManager",
            "QuantTrader", "AlgoExpert", "MarketShark", "TradingBot"
        ]
        
        let taglines = [
            "Your personal money-making machine",
            "Trades while you sleep, profits while you wake",
            "Turn $100 into $1000 with smart trading",
            "AI-powered trading for maximum profits",
            "The bot that never stops making money",
            "Professional trading made simple",
            "Your ticket to financial freedom",
            "Smart trading, guaranteed profits"
        ]
        
        let pitches = [
            "💰 Hire me and I'll make your money work 24/7!",
            "🚀 I've made my last 15 clients over $50K each!",
            "⚡ I can spot profitable trades in milliseconds!",
            "🎯 94% win rate - let me prove it to you!",
            "💎 I specialize in turning small accounts into big ones!",
            "🔥 I'm having a hot streak - 28 wins in a row!",
            "🧠 My AI brain never sleeps, never gets tired!",
            "⭐ 5-star rated by 500+ happy clients!"
        ]
        
        // Generate random reviews
        let reviewCount = Int.random(in: 5...50)
        let sampleReviews = (0..<reviewCount).map { _ in
            BotReview.generateRandom()
        }
        
        return MarketplaceBotModel(
            name: names.randomElement()!,
            creatorUsername: creators.randomElement()!,
            tagline: taglines.randomElement()!,
            valueProposition: "Advanced AI trading with proven results",
            description: "This bot uses cutting-edge algorithms to maximize your trading profits.",
            price: Double.random(in: 0...999),
            rarity: BotRarity.allCases.randomElement()!,
            tier: BotTier.allCases.randomElement()!,
            verificationStatus: VerificationStatus.allCases.randomElement()!,
            availability: BotAvailability.allCases.randomElement()!,
            stats: BotStats.generateRandom(),
            reviews: sampleReviews,
            tags: Array(["AI", "Automated", "Profitable"].shuffled().prefix(Int.random(in: 2...4))),
            createdDate: Date().addingTimeInterval(-Double.random(in: 0...2592000)),
            lastUpdated: Date().addingTimeInterval(-Double.random(in: 0...86400)),
            character: BotCharacter.randomCharacter(),
            tradingStyle: TradingStyle.allCases.randomElement()!,
            isCustomizable: Bool.random(),
            currentPitch: pitches.randomElement()!,
            hasSpecialOffer: Double.random(in: 0...1) < 0.3,
            specialOfferDetails: Bool.random() ? "50% OFF for first month!" : nil
        )
    }
}

// MARK: - Bot Review Model
struct BotReview: Identifiable, Codable {
    let id = UUID()
    let username: String
    let rating: Double
    let comment: String
    let date: Date
    let isVerified: Bool
    
    static func generateRandom() -> BotReview {
        let usernames = ["TradePro", "CryptoKing", "ForexMaster", "MarketGuru", "ProfitSeeker"]
        let comments = [
            "Amazing bot! Made 200% profit in first month.",
            "Solid performance, very reliable.",
            "Great for beginners, easy to use.",
            "Outstanding results, highly recommended!",
            "Perfect for my trading style."
        ]
        
        return BotReview(
            username: usernames.randomElement()!,
            rating: Double.random(in: 3.0...5.0),
            comment: comments.randomElement()!,
            date: Date().addingTimeInterval(-Double.random(in: 0...2592000)),
            isVerified: Bool.random()
        )
    }
}

// MARK: - Bot Stats Model
struct BotStats: Codable {
    let totalReturn: Double
    let winRate: Double
    let totalTrades: Int
    let totalUsers: Int
    let maxDrawdown: Double
    let sharpeRatio: Double
    let universeRank: Int
    let performanceGrade: String
    
    var formattedTotalReturn: String {
        let sign = totalReturn >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", totalReturn))%"
    }
    
    static func generateRandom() -> BotStats {
        let totalReturn = Double.random(in: -50...500)
        let winRate = Double.random(in: 45...95)
        
        return BotStats(
            totalReturn: totalReturn,
            winRate: winRate,
            totalTrades: Int.random(in: 100...5000),
            totalUsers: Int.random(in: 10...1000),
            maxDrawdown: Double.random(in: 2...25),
            sharpeRatio: Double.random(in: 0.5...4.0),
            universeRank: Int.random(in: 1...1000),
            performanceGrade: generatePerformanceGrade(totalReturn: totalReturn, winRate: winRate)
        )
    }
    
    static func generatePerformanceGrade(totalReturn: Double, winRate: Double) -> String {
        let score = (totalReturn * 0.6) + (winRate * 0.4)
        switch score {
        case 80...: return "S+"
        case 70..<80: return "S"
        case 60..<70: return "A+"
        case 50..<60: return "A"
        case 40..<50: return "B+"
        case 30..<40: return "B"
        default: return "C"
        }
    }
}

// MARK: - Bot Character Model
struct BotCharacter: Codable {
    let avatar: String
    let personality: String
    let specialties: [String]
    let catchPhrase: String
    
    static func randomCharacter() -> BotCharacter {
        let avatars = ["🤖", "👨‍💼", "👩‍💼", "🧙‍♂️", "🦾", "💎", "⚡", "🔥"]
        let personalities = ["Aggressive", "Conservative", "Balanced", "Risk-Taker", "Analytical"]
        let specialties = ["Scalping", "Swing Trading", "Day Trading", "Options", "Crypto"]
        let catchPhrases = [
            "Let's make money!",
            "Trading is my passion!",
            "Profit is the goal!",
            "Smart trades only!",
            "Risk management first!"
        ]
        
        return BotCharacter(
            avatar: avatars.randomElement()!,
            personality: personalities.randomElement()!,
            specialties: Array(specialties.shuffled().prefix(2)),
            catchPhrase: catchPhrases.randomElement()!
        )
    }
}

// MARK: - Bot Rarity Enum
enum BotRarity: String, CaseIterable, Codable {
    case common = "Common"
    case uncommon = "Uncommon"
    case rare = "Rare"
    case epic = "Epic"
    case legendary = "Legendary"
    case mythic = "Mythic"
    case godTier = "God Tier"
    
    var color: Color {
        switch self {
        case .common: return .gray
        case .uncommon: return .green
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .orange
        case .mythic: return .red
        case .godTier: return Color.yellow
        }
    }
    
    var sparkleEffect: String {
        switch self {
        case .common: return "⚪"
        case .uncommon: return "🟢"
        case .rare: return "🔵"
        case .epic: return "🟣"
        case .legendary: return "🟠"
        case .mythic: return "🔴"
        case .godTier: return "⭐"
        }
    }
    
    var dropRate: Double {
        switch self {
        case .common: return 45.0
        case .uncommon: return 30.0
        case .rare: return 15.0
        case .epic: return 7.5
        case .legendary: return 2.0
        case .mythic: return 0.4
        case .godTier: return 0.1
        }
    }
}

// MARK: - Bot Tier Enum
enum BotTier: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case professional = "Professional"
    case expert = "Expert"
    
    var color: Color {
        switch self {
        case .beginner: return .green
        case .intermediate: return .yellow
        case .advanced: return .orange
        case .professional: return .red
        case .expert: return .purple
        }
    }
    
    var icon: String {
        switch self {
        case .beginner: return "🌱"
        case .intermediate: return "🌿"
        case .advanced: return "🌳"
        case .professional: return "🏆"
        case .expert: return "👑"
        }
    }
}

// MARK: - Verification Status Enum
enum VerificationStatus: String, CaseIterable, Codable {
    case verified = "Verified"
    case pending = "Pending"
    case unverified = "Unverified"
    
    var icon: String {
        switch self {
        case .verified: return "checkmark.seal.fill"
        case .pending: return "clock.fill"
        case .unverified: return "questionmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .verified: return .green
        case .pending: return .orange
        case .unverified: return .gray
        }
    }
}

// MARK: - Bot Availability Enum
enum BotAvailability: String, CaseIterable, Codable {
    case available = "Available"
    case limited = "Limited"
    case exclusive = "Exclusive"
    case soldOut = "Sold Out"
    
    var icon: String {
        switch self {
        case .available: return "checkmark.circle.fill"
        case .limited: return "exclamationmark.triangle.fill"
        case .exclusive: return "crown.fill"
        case .soldOut: return "xmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .available: return .green
        case .limited: return .orange
        case .exclusive: return .purple
        case .soldOut: return .red
        }
    }
}

// MARK: - Preview
#Preview {
    VStack {
        Text("Sample Bot: \(MarketplaceBotModel.generateRandomBot().name)")
            .font(.title)
        Text("Rarity: \(MarketplaceBotModel.generateRandomBot().rarity.rawValue)")
            .font(.headline)
    }
    .padding()
}
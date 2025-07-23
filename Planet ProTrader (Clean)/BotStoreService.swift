//
//  BotStoreService.swift
//  Planet ProTrader (Clean)
//
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI
import Foundation

// MARK: - Bot Store Service
@MainActor
class BotStoreService: ObservableObject {
    static let shared = BotStoreService()
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var selectedCategory: BotStoreCategory = .all
    @Published var selectedRarity: BotRarity?
    @Published var selectedTier: BotTier?
    
    @Published var allBots: [MarketplaceBotModel] = []
    @Published var featuredBots: [MarketplaceBotModel] = []
    
    enum BotStoreCategory: String, CaseIterable {
        case all = "All"
        case featured = "Featured"
        case trending = "Trending"
        case new = "New"
        case popular = "Popular"
        case premium = "Premium"
        
        var icon: String {
            switch self {
            case .all: return "apps.iphone"
            case .featured: return "star.fill"
            case .trending: return "chart.line.uptrend.xyaxis"
            case .new: return "sparkles"
            case .popular: return "heart.fill"
            case .premium: return "crown.fill"
            }
        }
    }
    
    private init() {
        loadSampleData()
    }
    
    // MARK: - Public Methods
    
    func refreshData() async {
        isLoading = true
        errorMessage = nil
        
        // Simulate network delay
        try? await Task.sleep(for: .seconds(1))
        
        // In a real app, this would fetch from API
        loadSampleData()
        
        isLoading = false
    }
    
    func filteredBots() -> [MarketplaceBotModel] {
        var filtered = allBots
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { bot in
                bot.name.localizedCaseInsensitiveContains(searchText) ||
                bot.tagline.localizedCaseInsensitiveContains(searchText) ||
                bot.creatorUsername.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply category filter
        switch selectedCategory {
        case .all:
            break // No filtering
        case .featured:
            filtered = featuredBots
        case .trending:
            filtered = filtered.filter { $0.stats.totalUsers > 100 }
        case .new:
            filtered = filtered.filter { 
                Calendar.current.dateComponents([.day], from: $0.createdDate, to: Date()).day ?? 0 < 30 
            }
        case .popular:
            filtered = filtered.filter { $0.averageRating >= 4.0 }
        case .premium:
            filtered = filtered.filter { $0.price > 0 }
        }
        
        // Apply rarity filter
        if let rarity = selectedRarity {
            filtered = filtered.filter { $0.rarity == rarity }
        }
        
        // Apply tier filter
        if let tier = selectedTier {
            filtered = filtered.filter { $0.tier == tier }
        }
        
        return filtered
    }
    
    func clearFilters() {
        selectedRarity = nil
        selectedTier = nil
        searchText = ""
    }
    
    // MARK: - Private Methods
    
    private func loadSampleData() {
        // Sample bots data
        allBots = [
            MarketplaceBotModel(
                name: "Golden Eagle Pro",
                tagline: "Advanced gold trading with AI precision",
                creatorUsername: "TradeMaster",
                rarity: .legendary,
                tier: .professional,
                verificationStatus: .verified,
                availability: .available,
                price: 299.99,
                averageRating: 4.8,
                stats: BotStats(
                    totalReturn: 342.5,
                    winRate: 87.2,
                    totalTrades: 1250,
                    totalUsers: 450,
                    maxDrawdown: 8.5
                ),
                createdDate: Date().addingTimeInterval(-86400 * 45)
            ),
            
            MarketplaceBotModel(
                name: "Scalp Master",
                tagline: "Lightning-fast scalping bot",
                creatorUsername: "QuickTrader",
                rarity: .epic,
                tier: .advanced,
                verificationStatus: .verified,
                availability: .available,
                price: 149.99,
                averageRating: 4.5,
                stats: BotStats(
                    totalReturn: 156.8,
                    winRate: 73.4,
                    totalTrades: 2840,
                    totalUsers: 230,
                    maxDrawdown: 12.3
                ),
                createdDate: Date().addingTimeInterval(-86400 * 20)
            ),
            
            MarketplaceBotModel(
                name: "Trend Follower",
                tagline: "Reliable trend following strategy",
                creatorUsername: "TrendSeeker",
                rarity: .rare,
                tier: .intermediate,
                verificationStatus: .verified,
                availability: .available,
                price: 79.99,
                averageRating: 4.2,
                stats: BotStats(
                    totalReturn: 89.3,
                    winRate: 65.8,
                    totalTrades: 980,
                    totalUsers: 180,
                    maxDrawdown: 15.2
                ),
                createdDate: Date().addingTimeInterval(-86400 * 60)
            ),
            
            MarketplaceBotModel(
                name: "News Trader",
                tagline: "Trade the news with AI analysis",
                creatorUsername: "NewsBot",
                rarity: .epic,
                tier: .professional,
                verificationStatus: .pending,
                availability: .limited,
                price: 199.99,
                averageRating: 4.6,
                stats: BotStats(
                    totalReturn: 234.7,
                    winRate: 81.5,
                    totalTrades: 650,
                    totalUsers: 95,
                    maxDrawdown: 9.8
                ),
                createdDate: Date().addingTimeInterval(-86400 * 10)
            ),
            
            MarketplaceBotModel(
                name: "Crypto Hunter",
                tagline: "Multi-coin cryptocurrency bot",
                creatorUsername: "CryptoKing",
                rarity: .legendary,
                tier: .expert,
                verificationStatus: .verified,
                availability: .exclusive,
                price: 499.99,
                averageRating: 4.9,
                stats: BotStats(
                    totalReturn: 567.2,
                    winRate: 92.1,
                    totalTrades: 890,
                    totalUsers: 67,
                    maxDrawdown: 6.2
                ),
                createdDate: Date().addingTimeInterval(-86400 * 30)
            ),
            
            MarketplaceBotModel(
                name: "Safe Haven",
                tagline: "Conservative trading for beginners",
                creatorUsername: "SafeTrader",
                rarity: .common,
                tier: .beginner,
                verificationStatus: .verified,
                availability: .available,
                price: 29.99,
                averageRating: 4.0,
                stats: BotStats(
                    totalReturn: 23.4,
                    winRate: 58.7,
                    totalTrades: 450,
                    totalUsers: 320,
                    maxDrawdown: 5.1
                ),
                createdDate: Date().addingTimeInterval(-86400 * 90)
            )
        ]
        
        // Set featured bots (top performing ones)
        featuredBots = Array(allBots.sorted { $0.averageRating > $1.averageRating }.prefix(3))
    }
}

// MARK: - Marketplace Bot Model
struct MarketplaceBotModel: Identifiable, Codable {
    let id = UUID()
    let name: String
    let tagline: String
    let creatorUsername: String
    let rarity: BotRarity
    let tier: BotTier
    let verificationStatus: VerificationStatus
    let availability: BotAvailability
    let price: Double
    let averageRating: Double
    let stats: BotStats
    let createdDate: Date
    
    var formattedPrice: String {
        if price == 0 {
            return "FREE"
        } else {
            return String(format: "$%.0f", price)
        }
    }
}

// MARK: - Bot Stats Model
struct BotStats: Codable {
    let totalReturn: Double
    let winRate: Double
    let totalTrades: Int
    let totalUsers: Int
    let maxDrawdown: Double
    
    var formattedTotalReturn: String {
        let sign = totalReturn >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", totalReturn))%"
    }
}

// MARK: - Bot Rarity Enum
enum BotRarity: String, CaseIterable, Codable {
    case common = "Common"
    case rare = "Rare"
    case epic = "Epic"
    case legendary = "Legendary"
    
    var color: Color {
        switch self {
        case .common: return .gray
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .orange
        }
    }
    
    var sparkleEffect: String {
        switch self {
        case .common: return "⚪"
        case .rare: return "🔵"
        case .epic: return "🟣"
        case .legendary: return "🟠"
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
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
    @Published var activePitchingBots: [MarketplaceBotModel] = []
    @Published var testimonials: [BotTestimonial] = []
    @Published var hasSpecialOffers: Bool = true
    
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
        // Generate sample bots using the proper MarketplaceBotModel
        allBots = (1...25).map { _ in
            MarketplaceBotModel.generateRandomBot()
        }
        
        // Set featured bots (top performing ones by rating)
        featuredBots = Array(allBots
            .sorted { $0.averageRating > $1.averageRating }
            .prefix(5))
        
        // Set actively pitching bots (random selection)
        activePitchingBots = Array(allBots.shuffled().prefix(6))
        
        // Generate sample testimonials
        testimonials = generateSampleTestimonials()
    }

    // MARK: - Helper Methods
    
    func getBotsForAisle(_ aisle: BotStoreView.BotAisle) -> [MarketplaceBotModel] {
        switch aisle {
        case .featured:
            return featuredBots
        case .newArrivals:
            return allBots.filter { 
                Calendar.current.dateComponents([.day], from: $0.createdDate, to: Date()).day ?? 0 < 7 
            }
        case .hotDeals:
            return allBots.filter { $0.hasSpecialOffer }
        case .premium:
            return allBots.filter { $0.price > 500 }
        case .specialists:
            return allBots.filter { $0.tier == .expert || $0.tier == .professional }
        case .budget:
            return allBots.filter { $0.price < 100 }
        case .experimental:
            return allBots.filter { $0.rarity == .mythic || $0.rarity == .godTier }
        case .topRated:
            return allBots.filter { $0.averageRating >= 4.5 }.sorted { $0.averageRating > $1.averageRating }
        }
    }
    
    func rotatePitchingBots() {
        activePitchingBots = Array(allBots.shuffled().prefix(6))
    }
    
    private func generateSampleTestimonials() -> [BotTestimonial] {
        return [
            BotTestimonial(
                username: "TradePro123",
                userAvatar: "👨‍💼",
                botName: "GoldMiner Pro",
                rating: 5,
                review: "Made 300% profit in 3 months! This bot is incredible.",
                profit: "+$15,420",
                tradingPeriod: "3 months",
                verified: true,
                date: Date()
            ),
            BotTestimonial(
                username: "CryptoQueen",
                userAvatar: "👩‍💻",
                botName: "Market Hunter",
                rating: 5,
                review: "Best investment I ever made. Consistent daily profits!",
                profit: "+$8,750",
                tradingPeriod: "2 months",
                verified: true,
                date: Date()
            ),
            BotTestimonial(
                username: "StudentTrader",
                userAvatar: "🧑‍🎓",
                botName: "Profit Seeker",
                rating: 4,
                review: "Great for beginners like me. Easy to use and profitable.",
                profit: "+$2,100",
                tradingPeriod: "6 weeks",
                verified: false,
                date: Date()
            )
        ]
    }

    // MARK: - Computed Property for Marketplace Bots
    var marketplaceBots: [MarketplaceBotModel] {
        return allBots
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        VStack {
            Text("Bot Store Service")
                .font(.title)
            Text("Total Bots: \(BotStoreService.shared.allBots.count)")
            Text("Featured Bots: \(BotStoreService.shared.featuredBots.count)")
        }
        .padding()
    }
}
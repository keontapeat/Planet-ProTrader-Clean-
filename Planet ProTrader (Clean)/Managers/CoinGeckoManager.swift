//
//  CoinGeckoManager.swift
//  Planet ProTrader - CoinGecko API Integration
//
//  Comprehensive cryptocurrency data and market analysis
//  Created by AI Assistant on 1/25/25.
//

import Foundation
import SwiftUI

// MARK: - CoinGecko API Manager
@MainActor
class CoinGeckoManager: ObservableObject {
    static let shared = CoinGeckoManager()
    
    @Published var cryptoPrices: [String: CryptoPrice] = [:]
    @Published var marketData: CryptoMarketData?
    @Published var trendingCoins: [TrendingCoin] = []
    @Published var topGainers: [CryptoCoin] = []
    @Published var topLosers: [CryptoCoin] = []
    @Published var lastUpdated = Date()
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let networking = FreeAPINetworking.shared
    private let service = APIService.coinGecko
    
    private init() {
        print("🪙 CoinGecko Manager initialized")
    }
    
    // MARK: - Simple Price Data
    
    func getSimplePrices(
        ids: [String],
        vsCurrencies: [String] = ["usd"],
        includeMarketCap: Bool = true,
        include24hrVol: Bool = true,
        include24hrChange: Bool = true
    ) async throws -> [String: CoinGeckoSimplePrice.CryptoPrice] {
        let idsString = ids.joined(separator: ",")
        let currenciesString = vsCurrencies.joined(separator: ",")
        
        return try await networking.performRequest(
            service: service,
            endpoint: "/simple/price",
            parameters: [
                "ids": idsString,
                "vs_currencies": currenciesString,
                "include_market_cap": includeMarketCap,
                "include_24hr_vol": include24hrVol,
                "include_24hr_change": include24hrChange,
                "include_last_updated_at": true
            ],
            responseType: [String: CoinGeckoSimplePrice.CryptoPrice].self,
            cacheKey: "coingecko_simple_\(idsString)",
            cacheTTL: FreeAPIConfiguration.Cache.priceDataTTL
        )
    }
    
    // MARK: - Detailed Coin Data
    
    func getCoinData(id: String) async throws -> DetailedCoinData {
        return try await networking.performRequest(
            service: service,
            endpoint: "/coins/\(id)",
            parameters: [
                "localization": false,
                "tickers": false,
                "market_data": true,
                "community_data": true,
                "developer_data": false,
                "sparkline": true
            ],
            responseType: DetailedCoinData.self,
            cacheKey: "coingecko_detailed_\(id)",
            cacheTTL: FreeAPIConfiguration.Cache.technicalDataTTL
        )
    }
    
    // MARK: - Market Data
    
    func getMarketData() async throws -> CryptoMarketData {
        let globalData = try await networking.performRequest(
            service: service,
            endpoint: "/global",
            responseType: GlobalMarketResponse.self,
            cacheKey: "coingecko_global_market",
            cacheTTL: FreeAPIConfiguration.Cache.technicalDataTTL
        )
        
        let marketData = CryptoMarketData(
            totalMarketCap: globalData.data.totalMarketCap["usd"] ?? 0,
            total24hVolume: globalData.data.totalVolume["usd"] ?? 0,
            marketCapPercentage: globalData.data.marketCapPercentage,
            activeCryptocurrencies: globalData.data.activeCryptocurrencies,
            markets: globalData.data.markets,
            marketCapChangePercentage24h: globalData.data.marketCapChangePercentage24hUsd
        )
        
        self.marketData = marketData
        lastUpdated = Date()
        
        return marketData
    }
    
    // MARK: - Top Coins by Market Cap
    
    func getTopCoins(
        vsCurrency: String = "usd",
        count: Int = 100,
        page: Int = 1
    ) async throws -> [CryptoCoin] {
        return try await networking.performRequest(
            service: service,
            endpoint: "/coins/markets",
            parameters: [
                "vs_currency": vsCurrency,
                "order": "market_cap_desc",
                "per_page": count,
                "page": page,
                "sparkline": true,
                "price_change_percentage": "24h,7d,30d"
            ],
            responseType: [CryptoCoin].self,
            cacheKey: "coingecko_top_coins_\(count)_\(page)",
            cacheTTL: FreeAPIConfiguration.Cache.priceDataTTL
        )
    }
    
    // MARK: - Trending Coins
    
    func getTrendingCoins() async throws -> [TrendingCoin] {
        let response = try await networking.performRequest(
            service: service,
            endpoint: "/search/trending",
            responseType: TrendingResponse.self,
            cacheKey: "coingecko_trending",
            cacheTTL: FreeAPIConfiguration.Cache.newsDataTTL
        )
        
        trendingCoins = response.coins.map { $0.item }
        return trendingCoins
    }
    
    // MARK: - Price History
    
    func getPriceHistory(
        id: String,
        vsCurrency: String = "usd",
        days: Int = 7
    ) async throws -> [PricePoint] {
        let response = try await networking.performRequest(
            service: service,
            endpoint: "/coins/\(id)/market_chart",
            parameters: [
                "vs_currency": vsCurrency,
                "days": days,
                "interval": days <= 1 ? "hourly" : "daily"
            ],
            responseType: CoinGeckoPrice.self,
            cacheKey: "coingecko_history_\(id)_\(days)",
            cacheTTL: FreeAPIConfiguration.Cache.technicalDataTTL
        )
        
        return response.priceHistory
    }
    
    // MARK: - OHLC Data
    
    func getOHLCData(
        id: String,
        vsCurrency: String = "usd",
        days: Int = 7
    ) async throws -> [CandleData] {
        let response = try await networking.performRequest(
            service: service,
            endpoint: "/coins/\(id)/ohlc",
            parameters: [
                "vs_currency": vsCurrency,
                "days": days
            ],
            responseType: [[Double]].self,
            cacheKey: "coingecko_ohlc_\(id)_\(days)",
            cacheTTL: FreeAPIConfiguration.Cache.technicalDataTTL
        )
        
        return response.compactMap { ohlcArray in
            guard ohlcArray.count >= 5 else { return nil }
            
            return CandleData(
                open: ohlcArray[1],
                high: ohlcArray[2],
                low: ohlcArray[3],
                close: ohlcArray[4],
                volume: 0, // OHLC doesn't include volume
                timestamp: Date(timeIntervalSince1970: ohlcArray[0] / 1000)
            )
        }
    }
    
    // MARK: - Categories
    
    func getCategories() async throws -> [CryptoCategory] {
        return try await networking.performRequest(
            service: service,
            endpoint: "/coins/categories",
            responseType: [CryptoCategory].self,
            cacheKey: "coingecko_categories",
            cacheTTL: 3600 // Cache for 1 hour
        )
    }
    
    // MARK: - Exchange Data
    
    func getExchanges() async throws -> [CryptoExchange] {
        return try await networking.performRequest(
            service: service,
            endpoint: "/exchanges",
            parameters: [
                "per_page": 50,
                "page": 1
            ],
            responseType: [CryptoExchange].self,
            cacheKey: "coingecko_exchanges",
            cacheTTL: FreeAPIConfiguration.Cache.technicalDataTTL
        )
    }
    
    // MARK: - Fear & Greed Index
    
    func getFearGreedIndex() async throws -> FearGreedIndex {
        // Note: This might require a different endpoint or service
        // For now, we'll simulate it or integrate with Alternative.me API
        return FearGreedIndex(
            value: Int.random(in: 0...100),
            classification: FearGreedIndex.Classification.allCases.randomElement()!,
            timestamp: Date(),
            previousValue: Int.random(in: 0...100)
        )
    }
    
    // MARK: - Search Coins
    
    func searchCoins(query: String) async throws -> [CoinSearchResult] {
        return try await networking.performRequest(
            service: service,
            endpoint: "/search",
            parameters: ["query": query],
            responseType: CoinSearchResponse.self,
            cacheKey: "coingecko_search_\(query)",
            cacheTTL: 3600 // Cache searches for 1 hour
        ).coins
    }
    
    // MARK: - Comprehensive Market Analysis
    
    func getMarketAnalysis() async {
        isLoading = true
        
        do {
            // Get market data
            _ = try await getMarketData()
            
            // Get trending coins
            _ = try await getTrendingCoins()
            
            // Get top coins
            let topCoins = try await getTopCoins(count: 50)
            
            // Separate gainers and losers
            topGainers = topCoins
                .filter { ($0.priceChangePercentage24h ?? 0) > 0 }
                .sorted { ($0.priceChangePercentage24h ?? 0) > ($1.priceChangePercentage24h ?? 0) }
                .prefix(10)
                .map { $0 }
            
            topLosers = topCoins
                .filter { ($0.priceChangePercentage24h ?? 0) < 0 }
                .sorted { ($0.priceChangePercentage24h ?? 0) < ($1.priceChangePercentage24h ?? 0) }
                .prefix(10)
                .map { $0 }
            
            print("✅ CoinGecko market analysis completed")
            
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Failed to get market analysis: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Refresh Methods
    
    func refreshPrices(for coinIds: [String]) async {
        do {
            let prices = try await getSimplePrices(ids: coinIds)
            
            for (coinId, priceData) in prices {
                cryptoPrices[coinId] = CryptoPrice(
                    id: coinId,
                    currentPrice: priceData.usd,
                    marketCap: priceData.usdMarketCap,
                    volume24h: priceData.usd24hVol,
                    priceChange24h: priceData.usd24hChange,
                    lastUpdated: Date()
                )
            }
            
            lastUpdated = Date()
            
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Failed to refresh crypto prices: \(error)")
        }
    }
    
    func clearCache() {
        cryptoPrices.removeAll()
        marketData = nil
        trendingCoins.removeAll()
        topGainers.removeAll()
        topLosers.removeAll()
    }
}

// MARK: - Supporting Models

struct CryptoPrice {
    let id: String
    let currentPrice: Double
    let marketCap: Double?
    let volume24h: Double?
    let priceChange24h: Double?
    let lastUpdated: Date
    
    var formattedPrice: String {
        if currentPrice < 0.01 {
            return String(format: "$%.6f", currentPrice)
        } else if currentPrice < 1 {
            return String(format: "$%.4f", currentPrice)
        } else {
            return String(format: "$%.2f", currentPrice)
        }
    }
    
    var formattedChange: String {
        guard let change = priceChange24h else { return "N/A" }
        let sign = change >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", change))%"
    }
    
    var isPositive: Bool {
        (priceChange24h ?? 0) >= 0
    }
}

struct CryptoMarketData {
    let totalMarketCap: Double
    let total24hVolume: Double
    let marketCapPercentage: [String: Double]
    let activeCryptocurrencies: Int
    let markets: Int
    let marketCapChangePercentage24h: Double
    
    var formattedMarketCap: String {
        if totalMarketCap >= 1_000_000_000_000 {
            return String(format: "$%.2fT", totalMarketCap / 1_000_000_000_000)
        } else if totalMarketCap >= 1_000_000_000 {
            return String(format: "$%.2fB", totalMarketCap / 1_000_000_000)
        } else {
            return String(format: "$%.2fM", totalMarketCap / 1_000_000)
        }
    }
    
    var formattedVolume: String {
        if total24hVolume >= 1_000_000_000 {
            return String(format: "$%.2fB", total24hVolume / 1_000_000_000)
        } else {
            return String(format: "$%.2fM", total24hVolume / 1_000_000)
        }
    }
    
    var dominanceString: String {
        let btcDominance = marketCapPercentage["btc"] ?? 0
        let ethDominance = marketCapPercentage["eth"] ?? 0
        return "BTC: \(String(format: "%.1f", btcDominance))% | ETH: \(String(format: "%.1f", ethDominance))%"
    }
}

struct DetailedCoinData: Codable {
    let id: String
    let symbol: String
    let name: String
    let description: Description
    let image: ImageUrls
    let marketData: MarketData
    let communityData: CommunityData?
    
    struct Description: Codable {
        let en: String
    }
    
    struct ImageUrls: Codable {
        let thumb: String
        let small: String
        let large: String
    }
    
    struct MarketData: Codable {
        let currentPrice: [String: Double]
        let marketCap: [String: Double]
        let totalVolume: [String: Double]
        let priceChangePercentage24h: Double?
        let priceChangePercentage7d: Double?
        let priceChangePercentage30d: Double?
        let marketCapRank: Int?
        
        enum CodingKeys: String, CodingKey {
            case currentPrice = "current_price"
            case marketCap = "market_cap"
            case totalVolume = "total_volume"
            case priceChangePercentage24h = "price_change_percentage_24h"
            case priceChangePercentage7d = "price_change_percentage_7d"
            case priceChangePercentage30d = "price_change_percentage_30d"
            case marketCapRank = "market_cap_rank"
        }
    }
    
    struct CommunityData: Codable {
        let facebookLikes: Int?
        let twitterFollowers: Int?
        let redditAveragePosts48h: Double?
        let redditAverageComments48h: Double?
        let redditSubscribers: Int?
        let redditAccountsActive48h: Int?
        
        enum CodingKeys: String, CodingKey {
            case facebookLikes = "facebook_likes"
            case twitterFollowers = "twitter_followers"
            case redditAveragePosts48h = "reddit_average_posts_48h"
            case redditAverageComments48h = "reddit_average_comments_48h"
            case redditSubscribers = "reddit_subscribers"
            case redditAccountsActive48h = "reddit_accounts_active_48h"
        }
    }
}

struct CryptoCoin: Codable, Identifiable {
    let id: String
    let symbol: String
    let name: String
    let image: String
    let currentPrice: Double
    let marketCap: Double?
    let marketCapRank: Int?
    let fullyDilutedValuation: Double?
    let totalVolume: Double?
    let high24h: Double?
    let low24h: Double?
    let priceChange24h: Double?
    let priceChangePercentage24h: Double?
    let marketCapChange24h: Double?
    let marketCapChangePercentage24h: Double?
    let circulatingSupply: Double?
    let totalSupply: Double?
    let maxSupply: Double?
    let ath: Double?
    let athChangePercentage: Double?
    let athDate: String?
    let atl: Double?
    let atlChangePercentage: Double?
    let atlDate: String?
    let lastUpdated: String?
    let sparklineIn7d: SparklineData?
    
    enum CodingKeys: String, CodingKey {
        case id, symbol, name, image
        case currentPrice = "current_price"
        case marketCap = "market_cap"
        case marketCapRank = "market_cap_rank"
        case fullyDilutedValuation = "fully_diluted_valuation"
        case totalVolume = "total_volume"
        case high24h = "high_24h"
        case low24h = "low_24h"
        case priceChange24h = "price_change_24h"
        case priceChangePercentage24h = "price_change_percentage_24h"
        case marketCapChange24h = "market_cap_change_24h"
        case marketCapChangePercentage24h = "market_cap_change_percentage_24h"
        case circulatingSupply = "circulating_supply"
        case totalSupply = "total_supply"
        case maxSupply = "max_supply"
        case ath
        case athChangePercentage = "ath_change_percentage"
        case athDate = "ath_date"
        case atl
        case atlChangePercentage = "atl_change_percentage"
        case atlDate = "atl_date"
        case lastUpdated = "last_updated"
        case sparklineIn7d = "sparkline_in_7d"
    }
    
    struct SparklineData: Codable {
        let price: [Double?]
    }
    
    var formattedPrice: String {
        if currentPrice < 0.01 {
            return String(format: "$%.6f", currentPrice)
        } else if currentPrice < 1 {
            return String(format: "$%.4f", currentPrice)
        } else {
            return String(format: "$%.2f", currentPrice)
        }
    }
    
    var formattedMarketCap: String {
        guard let marketCap = marketCap else { return "N/A" }
        if marketCap >= 1_000_000_000 {
            return String(format: "$%.2fB", marketCap / 1_000_000_000)
        } else {
            return String(format: "$%.2fM", marketCap / 1_000_000)
        }
    }
    
    var changeColor: Color {
        (priceChangePercentage24h ?? 0) >= 0 ? .green : .red
    }
}

struct TrendingCoin: Codable, Identifiable {
    let id: String
    let coinId: Int
    let name: String
    let symbol: String
    let marketCapRank: Int
    let thumb: String
    let small: String
    let large: String
    let slug: String
    let priceBtc: Double
    let score: Int
    
    enum CodingKeys: String, CodingKey {
        case id, name, symbol, thumb, small, large, slug, score
        case coinId = "coin_id"
        case marketCapRank = "market_cap_rank"
        case priceBtc = "price_btc"
    }
}

struct TrendingResponse: Codable {
    let coins: [TrendingCoinWrapper]
    
    struct TrendingCoinWrapper: Codable {
        let item: TrendingCoin
    }
}

struct GlobalMarketResponse: Codable {
    let data: GlobalMarketData
    
    struct GlobalMarketData: Codable {
        let activeCryptocurrencies: Int
        let upcomingIcos: Int
        let ongoingIcos: Int
        let endedIcos: Int
        let markets: Int
        let totalMarketCap: [String: Double]
        let totalVolume: [String: Double]
        let marketCapPercentage: [String: Double]
        let marketCapChangePercentage24hUsd: Double
        let updatedAt: Int
        
        enum CodingKeys: String, CodingKey {
            case activeCryptocurrencies = "active_cryptocurrencies"
            case upcomingIcos = "upcoming_icos"
            case ongoingIcos = "ongoing_icos"
            case endedIcos = "ended_icos"
            case markets
            case totalMarketCap = "total_market_cap"
            case totalVolume = "total_volume"
            case marketCapPercentage = "market_cap_percentage"
            case marketCapChangePercentage24hUsd = "market_cap_change_percentage_24h_usd"
            case updatedAt = "updated_at"
        }
    }
}

struct CryptoCategory: Codable, Identifiable {
    let id: String
    let name: String
    let marketCap: Double
    let marketCapChange24h: Double
    let volume24h: Double
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case marketCap = "market_cap"
        case marketCapChange24h = "market_cap_change_24h"
        case volume24h = "volume_24h"
        case updatedAt = "updated_at"
    }
}

struct CryptoExchange: Codable, Identifiable {
    let id: String
    let name: String
    let yearEstablished: Int?
    let country: String?
    let description: String?
    let url: String
    let image: String
    let hasTradingIncentive: Bool?
    let trustScore: Int
    let trustScoreRank: Int?
    let tradeVolume24hBtc: Double
    let tradeVolume24hBtcNormalized: Double
    
    enum CodingKeys: String, CodingKey {
        case id, name, country, description, url, image
        case yearEstablished = "year_established"
        case hasTradingIncentive = "has_trading_incentive"
        case trustScore = "trust_score"
        case trustScoreRank = "trust_score_rank"
        case tradeVolume24hBtc = "trade_volume_24h_btc"
        case tradeVolume24hBtcNormalized = "trade_volume_24h_btc_normalized"
    }
}

struct FearGreedIndex {
    let value: Int
    let classification: Classification
    let timestamp: Date
    let previousValue: Int?
    
    enum Classification: String, CaseIterable {
        case extremeFear = "Extreme Fear"
        case fear = "Fear"
        case neutral = "Neutral"
        case greed = "Greed"
        case extremeGreed = "Extreme Greed"
        
        var color: Color {
            switch self {
            case .extremeFear: return .red
            case .fear: return .orange
            case .neutral: return .yellow
            case .greed: return .mint
            case .extremeGreed: return .green
            }
        }
        
        static func from(value: Int) -> Classification {
            switch value {
            case 0...24: return .extremeFear
            case 25...44: return .fear
            case 45...55: return .neutral
            case 56...75: return .greed
            case 76...100: return .extremeGreed
            default: return .neutral
            }
        }
    }
}

struct CoinSearchResponse: Codable {
    let coins: [CoinSearchResult]
}

struct CoinSearchResult: Codable, Identifiable {
    let id: String
    let name: String
    let symbol: String
    let marketCapRank: Int?
    let thumb: String
    let large: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, symbol, thumb, large
        case marketCapRank = "market_cap_rank"
    }
}

#Preview {
    VStack {
        Text("CoinGecko Manager")
            .font(.title)
        Text("Comprehensive crypto data")
            .font(.caption)
    }
}
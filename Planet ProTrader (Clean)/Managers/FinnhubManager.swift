//
//  FinnhubManager.swift
//  Planet ProTrader - Finnhub API Integration
//
//  Real-time market data, news, and financial information
//  Created by AI Assistant on 1/25/25.
//

import Foundation
import SwiftUI

// MARK: - Finnhub API Manager
@MainActor
class FinnhubManager: ObservableObject {
    static let shared = FinnhubManager()
    
    @Published var isConnected = false
    @Published var quotes: [String: FinnhubQuote] = [:]
    @Published var news: [FinnhubNews] = []
    @Published var lastUpdated = Date()
    @Published var errorMessage: String?
    
    private let networking = FreeAPINetworking.shared
    private let service = APIService.finnhub
    
    // Cache keys
    private let quoteCachePrefix = "finnhub_quote_"
    private let newsCacheKey = "finnhub_news_general"
    
    private init() {
        print("📊 Finnhub Manager initialized")
    }
    
    // MARK: - Real-time Quote Data
    
    func getQuote(symbol: String) async throws -> FinnhubQuote {
        let cacheKey = quoteCachePrefix + symbol
        
        let quote = try await networking.performRequest(
            service: service,
            endpoint: "/quote",
            parameters: [
                "symbol": symbol,
                "token": FreeAPIConfiguration.APIKeys.finnhub
            ],
            responseType: FinnhubQuote.self,
            cacheKey: cacheKey,
            cacheTTL: FreeAPIConfiguration.Cache.priceDataTTL
        )
        
        quotes[symbol] = quote
        lastUpdated = Date()
        isConnected = true
        
        return quote
    }
    
    func getMultipleQuotes(symbols: [String]) async {
        await withTaskGroup(of: Void.self) { group in
            for symbol in symbols {
                group.addTask {
                    do {
                        _ = try await self.getQuote(symbol: symbol)
                    } catch {
                        print("❌ Failed to get quote for \(symbol): \(error)")
                    }
                }
            }
        }
    }
    
    // MARK: - Historical Data (Candles)
    
    func getCandles(
        symbol: String,
        resolution: CandleResolution = .minute1,
        from: Date,
        to: Date
    ) async throws -> [CandleData] {
        let fromTimestamp = Int(from.timeIntervalSince1970)
        let toTimestamp = Int(to.timeIntervalSince1970)
        
        let response = try await networking.performRequest(
            service: service,
            endpoint: "/stock/candle",
            parameters: [
                "symbol": symbol,
                "resolution": resolution.rawValue,
                "from": fromTimestamp,
                "to": toTimestamp,
                "token": FreeAPIConfiguration.APIKeys.finnhub
            ],
            responseType: FinnhubCandle.self,
            cacheKey: "finnhub_candles_\(symbol)_\(resolution.rawValue)_\(fromTimestamp)_\(toTimestamp)",
            cacheTTL: FreeAPIConfiguration.Cache.technicalDataTTL
        )
        
        return response.candles
    }
    
    // MARK: - Market News
    
    func getGeneralNews(category: NewsCategory = .general) async throws -> [FinnhubNews] {
        let newsData = try await networking.performRequest(
            service: service,
            endpoint: "/news",
            parameters: [
                "category": category.rawValue,
                "token": FreeAPIConfiguration.APIKeys.finnhub
            ],
            responseType: [FinnhubNews].self,
            cacheKey: "finnhub_news_\(category.rawValue)",
            cacheTTL: FreeAPIConfiguration.Cache.newsDataTTL
        )
        
        news = newsData
        lastUpdated = Date()
        
        return newsData
    }
    
    func getCompanyNews(symbol: String, from: Date, to: Date) async throws -> [FinnhubNews] {
        let fromString = DateFormatter.finnhub.string(from: from)
        let toString = DateFormatter.finnhub.string(from: to)
        
        return try await networking.performRequest(
            service: service,
            endpoint: "/company-news",
            parameters: [
                "symbol": symbol,
                "from": fromString,
                "to": toString,
                "token": FreeAPIConfiguration.APIKeys.finnhub
            ],
            responseType: [FinnhubNews].self,
            cacheKey: "finnhub_company_news_\(symbol)_\(fromString)_\(toString)",
            cacheTTL: FreeAPIConfiguration.Cache.newsDataTTL
        )
    }
    
    // MARK: - Market Status
    
    func getMarketStatus(exchange: String = "US") async throws -> MarketStatus {
        let response = try await networking.performRequest(
            service: service,
            endpoint: "/stock/market-status",
            parameters: [
                "exchange": exchange,
                "token": FreeAPIConfiguration.APIKeys.finnhub
            ],
            responseType: FinnhubMarketStatus.self
        )
        
        return MarketStatus(
            isOpen: response.isOpen,
            session: response.session,
            timezone: response.timezone,
            holiday: response.holiday
        )
    }
    
    // MARK: - Forex Data
    
    func getForexRates(base: String = "USD") async throws -> [String: Double] {
        return try await networking.performRequest(
            service: service,
            endpoint: "/forex/rates",
            parameters: [
                "base": base,
                "token": FreeAPIConfiguration.APIKeys.finnhub
            ],
            responseType: [String: Double].self,
            cacheKey: "finnhub_forex_\(base)",
            cacheTTL: FreeAPIConfiguration.Cache.priceDataTTL
        )
    }
    
    // MARK: - Crypto Data
    
    func getCryptoCandles(
        symbol: String,
        resolution: CandleResolution = .minute1,
        from: Date,
        to: Date
    ) async throws -> [CandleData] {
        let fromTimestamp = Int(from.timeIntervalSince1970)
        let toTimestamp = Int(to.timeIntervalSince1970)
        
        let response = try await networking.performRequest(
            service: service,
            endpoint: "/crypto/candle",
            parameters: [
                "symbol": symbol,
                "resolution": resolution.rawValue,
                "from": fromTimestamp,
                "to": toTimestamp,
                "token": FreeAPIConfiguration.APIKeys.finnhub
            ],
            responseType: FinnhubCandle.self,
            cacheKey: "finnhub_crypto_candles_\(symbol)_\(resolution.rawValue)_\(fromTimestamp)_\(toTimestamp)",
            cacheTTL: FreeAPIConfiguration.Cache.technicalDataTTL
        )
        
        return response.candles
    }
    
    // MARK: - Market Sentiment
    
    func getMarketSentiment(symbol: String) async throws -> SentimentData {
        return try await networking.performRequest(
            service: service,
            endpoint: "/stock/sentiment",
            parameters: [
                "symbol": symbol,
                "token": FreeAPIConfiguration.APIKeys.finnhub
            ],
            responseType: SentimentData.self,
            cacheKey: "finnhub_sentiment_\(symbol)",
            cacheTTL: FreeAPIConfiguration.Cache.technicalDataTTL
        )
    }
    
    // MARK: - Symbol Search
    
    func searchSymbols(query: String) async throws -> [SymbolSearchResult] {
        return try await networking.performRequest(
            service: service,
            endpoint: "/search",
            parameters: [
                "q": query,
                "token": FreeAPIConfiguration.APIKeys.finnhub
            ],
            responseType: SymbolSearchResponse.self,
            cacheKey: "finnhub_search_\(query)",
            cacheTTL: 3600 // Cache searches for 1 hour
        ).result
    }
    
    // MARK: - Helper Methods
    
    func refreshAllData() async {
        do {
            // Refresh major forex pairs
            await getMultipleQuotes(symbols: FreeAPIConfiguration.TradingSymbols.forexMajors)
            
            // Refresh general news
            _ = try await getGeneralNews()
            
            print("✅ Finnhub data refreshed successfully")
            
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Failed to refresh Finnhub data: \(error)")
        }
    }
    
    func clearCache() {
        quotes.removeAll()
        news.removeAll()
    }
}

// MARK: - Supporting Types

enum CandleResolution: String, CaseIterable {
    case minute1 = "1"
    case minute5 = "5"
    case minute15 = "15"
    case minute30 = "30"
    case hour1 = "60"
    case day1 = "D"
    case week1 = "W"
    case month1 = "M"
    
    var displayName: String {
        switch self {
        case .minute1: return "1m"
        case .minute5: return "5m"
        case .minute15: return "15m"
        case .minute30: return "30m"
        case .hour1: return "1h"
        case .day1: return "1D"
        case .week1: return "1W"
        case .month1: return "1M"
        }
    }
}

enum NewsCategory: String, CaseIterable {
    case general = "general"
    case forex = "forex"
    case crypto = "crypto"
    case merger = "merger"
    
    var displayName: String {
        switch self {
        case .general: return "General"
        case .forex: return "Forex"
        case .crypto: return "Crypto"
        case .merger: return "M&A"
        }
    }
}

struct MarketStatus {
    let isOpen: Bool
    let session: String
    let timezone: String
    let holiday: String?
}

struct FinnhubMarketStatus: Codable {
    let isOpen: Bool
    let session: String
    let timezone: String
    let holiday: String?
}

struct SentimentData: Codable {
    let buzz: BuzzData
    let companyNewsScore: Double
    let sectorAverageNews: Double
    let sectorAverageBuzz: Double
    
    struct BuzzData: Codable {
        let articlesInLastWeek: Int
        let buzz: Double
        let weeklyAverage: Double
    }
}

struct SymbolSearchResponse: Codable {
    let count: Int
    let result: [SymbolSearchResult]
}

struct SymbolSearchResult: Codable, Identifiable {
    let id = UUID()
    let description: String
    let displaySymbol: String
    let symbol: String
    let type: String
}

// MARK: - Extensions

extension DateFormatter {
    static let finnhub: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

#Preview {
    VStack {
        Text("Finnhub Manager")
            .font(.title)
        Text("Real-time market data & news")
            .font(.caption)
    }
}
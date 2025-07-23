//
//  NewsAPIManager.swift
//  Planet ProTrader - NewsAPI Integration
//
//  Real-time financial news and market sentiment analysis
//  Created by AI Assistant on 1/25/25.
//

import Foundation
import SwiftUI

// MARK: - NewsAPI Manager
@MainActor
class NewsAPIManager: ObservableObject {
    static let shared = NewsAPIManager()
    
    @Published var headlines: [UnifiedNewsItem] = []
    @Published var businessNews: [UnifiedNewsItem] = []
    @Published var cryptoNews: [UnifiedNewsItem] = []
    @Published var forexNews: [UnifiedNewsItem] = []
    @Published var isLoading = false
    @Published var lastUpdated = Date()
    @Published var errorMessage: String?
    
    private let networking = FreeAPINetworking.shared
    private let service = APIService.newsAPI
    
    // News categories for financial markets
    private let financialSources = [
        "bloomberg", "reuters", "cnbc", "financial-times", "the-wall-street-journal",
        "fortune", "business-insider", "marketwatch", "yahoo-finance"
    ]
    
    private init() {
        print("📰 NewsAPI Manager initialized")
    }
    
    // MARK: - Top Headlines
    
    func getTopHeadlines(
        category: NewsAPICategory = .business,
        country: String = "us",
        pageSize: Int = 50
    ) async throws -> [UnifiedNewsItem] {
        let response = try await networking.performRequest(
            service: service,
            endpoint: "/top-headlines",
            parameters: [
                "category": category.rawValue,
                "country": country,
                "pageSize": pageSize,
                "apiKey": FreeAPIConfiguration.APIKeys.newsAPI
            ],
            responseType: NewsAPIResponse.self,
            cacheKey: "news_headlines_\(category.rawValue)_\(country)",
            cacheTTL: FreeAPIConfiguration.Cache.newsDataTTL
        )
        
        let unifiedNews = response.articles.map { article in
            UnifiedNewsItem(
                title: article.title,
                summary: article.description ?? "",
                source: article.source.name,
                publishedAt: article.publishedDate,
                url: article.url,
                imageURL: article.urlToImage,
                apiSource: .newsAPI
            )
        }
        
        headlines = unifiedNews
        lastUpdated = Date()
        
        return unifiedNews
    }
    
    // MARK: - Business & Financial News
    
    func getBusinessNews(pageSize: Int = 50) async throws -> [UnifiedNewsItem] {
        let response = try await networking.performRequest(
            service: service,
            endpoint: "/top-headlines",
            parameters: [
                "category": "business",
                "country": "us",
                "pageSize": pageSize,
                "apiKey": FreeAPIConfiguration.APIKeys.newsAPI
            ],
            responseType: NewsAPIResponse.self,
            cacheKey: "news_business",
            cacheTTL: FreeAPIConfiguration.Cache.newsDataTTL
        )
        
        let unifiedNews = response.articles.map { article in
            UnifiedNewsItem(
                title: article.title,
                summary: article.description ?? "",
                source: article.source.name,
                publishedAt: article.publishedDate,
                url: article.url,
                imageURL: article.urlToImage,
                apiSource: .newsAPI
            )
        }
        
        businessNews = unifiedNews
        return unifiedNews
    }
    
    // MARK: - Crypto News
    
    func getCryptoNews(pageSize: Int = 50) async throws -> [UnifiedNewsItem] {
        let response = try await networking.performRequest(
            service: service,
            endpoint: "/everything",
            parameters: [
                "q": "bitcoin OR ethereum OR cryptocurrency OR crypto OR blockchain OR DeFi",
                "sources": financialSources.joined(separator: ","),
                "sortBy": "publishedAt",
                "pageSize": pageSize,
                "language": "en",
                "apiKey": FreeAPIConfiguration.APIKeys.newsAPI
            ],
            responseType: NewsAPIResponse.self,
            cacheKey: "news_crypto",
            cacheTTL: FreeAPIConfiguration.Cache.newsDataTTL
        )
        
        let unifiedNews = response.articles.map { article in
            UnifiedNewsItem(
                title: article.title,
                summary: article.description ?? "",
                source: article.source.name,
                publishedAt: article.publishedDate,
                url: article.url,
                imageURL: article.urlToImage,
                apiSource: .newsAPI
            )
        }
        
        cryptoNews = unifiedNews
        return unifiedNews
    }
    
    // MARK: - Forex News
    
    func getForexNews(pageSize: Int = 50) async throws -> [UnifiedNewsItem] {
        let response = try await networking.performRequest(
            service: service,
            endpoint: "/everything",
            parameters: [
                "q": "forex OR currency OR USD OR EUR OR GBP OR JPY OR \"foreign exchange\" OR \"central bank\"",
                "sources": financialSources.joined(separator: ","),
                "sortBy": "publishedAt",
                "pageSize": pageSize,
                "language": "en",
                "apiKey": FreeAPIConfiguration.APIKeys.newsAPI
            ],
            responseType: NewsAPIResponse.self,
            cacheKey: "news_forex",
            cacheTTL: FreeAPIConfiguration.Cache.newsDataTTL
        )
        
        let unifiedNews = response.articles.map { article in
            UnifiedNewsItem(
                title: article.title,
                summary: article.description ?? "",
                source: article.source.name,
                publishedAt: article.publishedDate,
                url: article.url,
                imageURL: article.urlToImage,
                apiSource: .newsAPI
            )
        }
        
        forexNews = unifiedNews
        return unifiedNews
    }
    
    // MARK: - Custom Search
    
    func searchNews(
        query: String,
        sortBy: NewsSortBy = .publishedAt,
        pageSize: Int = 50,
        from: Date? = nil,
        to: Date? = nil
    ) async throws -> [UnifiedNewsItem] {
        var parameters: [String: Any] = [
            "q": query,
            "sortBy": sortBy.rawValue,
            "pageSize": pageSize,
            "language": "en",
            "apiKey": FreeAPIConfiguration.APIKeys.newsAPI
        ]
        
        // Add date filters if provided
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let fromDate = from {
            parameters["from"] = dateFormatter.string(from: fromDate)
        }
        
        if let toDate = to {
            parameters["to"] = dateFormatter.string(from: toDate)
        }
        
        let response = try await networking.performRequest(
            service: service,
            endpoint: "/everything",
            parameters: parameters,
            responseType: NewsAPIResponse.self,
            cacheKey: "news_search_\(query.replacingOccurrences(of: " ", with: "_"))",
            cacheTTL: FreeAPIConfiguration.Cache.newsDataTTL
        )
        
        return response.articles.map { article in
            UnifiedNewsItem(
                title: article.title,
                summary: article.description ?? "",
                source: article.source.name,
                publishedAt: article.publishedDate,
                url: article.url,
                imageURL: article.urlToImage,
                apiSource: .newsAPI
            )
        }
    }
    
    // MARK: - Financial Sources News
    
    func getFinancialSourcesNews(
        sources: [String]? = nil,
        pageSize: Int = 50
    ) async throws -> [UnifiedNewsItem] {
        let sourcesToUse = sources ?? financialSources
        
        let response = try await networking.performRequest(
            service: service,
            endpoint: "/top-headlines",
            parameters: [
                "sources": sourcesToUse.joined(separator: ","),
                "pageSize": pageSize,
                "apiKey": FreeAPIConfiguration.APIKeys.newsAPI
            ],
            responseType: NewsAPIResponse.self,
            cacheKey: "news_financial_sources",
            cacheTTL: FreeAPIConfiguration.Cache.newsDataTTL
        )
        
        return response.articles.map { article in
            UnifiedNewsItem(
                title: article.title,
                summary: article.description ?? "",
                source: article.source.name,
                publishedAt: article.publishedDate,
                url: article.url,
                imageURL: article.urlToImage,
                apiSource: .newsAPI
            )
        }
    }
    
    // MARK: - Market Sentiment Analysis
    
    func getMarketSentiment(for query: String = "stock market") async -> MarketSentiment {
        do {
            let newsItems = try await searchNews(
                query: query,
                pageSize: 100,
                from: Calendar.current.date(byAdding: .day, value: -7, to: Date())
            )
            
            return analyzeSentiment(from: newsItems)
            
        } catch {
            print("❌ Failed to get market sentiment: \(error)")
            return MarketSentiment(
                positive: 0.33,
                negative: 0.33,
                neutral: 0.34,
                overall: .neutral
            )
        }
    }
    
    private func analyzeSentiment(from newsItems: [UnifiedNewsItem]) -> MarketSentiment {
        guard !newsItems.isEmpty else {
            return MarketSentiment(positive: 0.33, negative: 0.33, neutral: 0.34, overall: .neutral)
        }
        
        let positiveKeywords = [
            "gain", "rise", "surge", "rally", "bull", "positive", "growth", "strong",
            "profit", "earnings", "beat", "exceed", "record", "high", "boost", "up"
        ]
        
        let negativeKeywords = [
            "fall", "drop", "decline", "crash", "bear", "negative", "loss", "weak",
            "miss", "disappoint", "concern", "worry", "fear", "sell", "down", "low"
        ]
        
        var positiveCount = 0
        var negativeCount = 0
        var neutralCount = 0
        
        for newsItem in newsItems {
            let text = (newsItem.title + " " + newsItem.summary).lowercased()
            
            let positiveMatches = positiveKeywords.filter { text.contains($0) }.count
            let negativeMatches = negativeKeywords.filter { text.contains($0) }.count
            
            if positiveMatches > negativeMatches {
                positiveCount += 1
            } else if negativeMatches > positiveMatches {
                negativeCount += 1
            } else {
                neutralCount += 1
            }
        }
        
        let total = Double(newsItems.count)
        let positivePercent = Double(positiveCount) / total
        let negativePercent = Double(negativeCount) / total
        let neutralPercent = Double(neutralCount) / total
        
        let overall: MarketSentiment.SentimentLevel
        if positivePercent > 0.6 {
            overall = .veryBullish
        } else if positivePercent > 0.4 {
            overall = .bullish
        } else if negativePercent > 0.6 {
            overall = .veryBearish
        } else if negativePercent > 0.4 {
            overall = .bearish
        } else {
            overall = .neutral
        }
        
        return MarketSentiment(
            positive: positivePercent,
            negative: negativePercent,
            neutral: neutralPercent,
            overall: overall
        )
    }
    
    // MARK: - Breaking News Alerts
    
    func getBreakingNews(keywords: [String] = ["breaking", "urgent", "alert"]) async throws -> [UnifiedNewsItem] {
        let keywordQuery = keywords.joined(separator: " OR ")
        
        return try await searchNews(
            query: keywordQuery,
            sortBy: .publishedAt,
            pageSize: 20,
            from: Calendar.current.date(byAdding: .hour, value: -2, to: Date())
        )
    }
    
    // MARK: - Comprehensive News Refresh
    
    func refreshAllNews() async {
        isLoading = true
        
        async let headlinesTask = getTopHeadlines()
        async let businessTask = getBusinessNews()
        async let cryptoTask = getCryptoNews()
        async let forexTask = getForexNews()
        
        do {
            _ = try await headlinesTask
            _ = try await businessTask
            _ = try await cryptoTask
            _ = try await forexTask
            
            print("✅ All news data refreshed successfully")
            
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Failed to refresh news data: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
}

// MARK: - NewsAPI Enums

enum NewsAPICategory: String, CaseIterable {
    case business = "business"
    case entertainment = "entertainment"
    case general = "general"
    case health = "health"
    case science = "science"
    case sports = "sports"
    case technology = "technology"
}

enum NewsSortBy: String, CaseIterable {
    case relevancy = "relevancy"
    case popularity = "popularity"
    case publishedAt = "publishedAt"
}
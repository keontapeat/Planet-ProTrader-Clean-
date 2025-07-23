//
//  FreeAPIConfiguration.swift
//  Planet ProTrader - Free APIs Configuration
//
//  Comprehensive free API integration for enhanced trading data
//  Created by AI Assistant on 1/25/25.
//

import Foundation

// MARK: - Free API Configuration Hub
struct FreeAPIConfiguration {
    
    // MARK: - API Keys (Replace with your actual keys)
    struct APIKeys {
        // Finnhub (Sign up at: https://finnhub.io)
        static let finnhub = "YOUR_FINNHUB_API_KEY"
        
        // Alpha Vantage (Sign up at: https://www.alphavantage.co/support/#api-key)
        static let alphaVantage = "YOUR_ALPHAVANTAGE_API_KEY"
        
        // Trading Economics (Sign up at: https://tradingeconomics.com/api/register)
        static let tradingEconomics = "YOUR_TRADING_ECONOMICS_API_KEY"
        
        // Fixer.io (Sign up at: https://fixer.io/product)
        static let fixer = "YOUR_FIXER_API_KEY"
        
        // NewsAPI (Sign up at: https://newsapi.org/register)
        static let newsAPI = "YOUR_NEWSAPI_KEY"
        
        // Twelve Data (Sign up at: https://twelvedata.com/pricing)
        static let twelveData = "YOUR_TWELVEDATA_API_KEY"
        
        // Polygon.io (Sign up at: https://polygon.io/pricing)
        static let polygon = "YOUR_POLYGON_API_KEY"
        
        // Note: CoinGecko, REST Countries, Yahoo Finance are free without API keys
    }
    
    // MARK: - API Endpoints
    struct Endpoints {
        // Finnhub - Market Data
        static let finnhub = "https://finnhub.io/api/v1"
        
        // Alpha Vantage - Financial Data
        static let alphaVantage = "https://www.alphavantage.co/query"
        
        // Trading Economics - Economic Calendar
        static let tradingEconomics = "https://api.tradingeconomics.com"
        
        // CoinGecko - Crypto Data (No API key required)
        static let coinGecko = "https://api.coingecko.com/api/v3"
        
        // Fixer.io - Forex Rates
        static let fixer = "http://data.fixer.io/api"
        
        // NewsAPI - Market News
        static let newsAPI = "https://newsapi.org/v2"
        
        // Twelve Data - Technical Analysis
        static let twelveData = "https://api.twelvedata.com"
        
        // Polygon.io - Market Data
        static let polygon = "https://api.polygon.io"
        
        // REST Countries - Economic Data (No API key required)
        static let restCountries = "https://restcountries.com/v3.1"
        
        // Yahoo Finance - Alternative (Unofficial)
        static let yahooFinance = "https://query1.finance.yahoo.com/v8/finance"
    }
    
    // MARK: - Rate Limits (calls per time period)
    struct RateLimits {
        static let finnhub = (calls: 60, period: 60.0) // 60 calls/minute
        static let alphaVantage = (calls: 25, period: 86400.0) // 25 calls/day
        static let tradingEconomics = (calls: 100, period: 86400.0) // 100 calls/day (free tier)
        static let coinGecko = (calls: 10, period: 60.0) // 10-50 calls/minute (no key)
        static let fixer = (calls: 100, period: 2592000.0) // 100 calls/month
        static let newsAPI = (calls: 1000, period: 86400.0) // 1000 calls/day
        static let twelveData = (calls: 800, period: 86400.0) // 800 calls/day
        static let polygon = (calls: 5, period: 60.0) // 5 calls/minute
        static let restCountries = (calls: 1000, period: 60.0) // No official limit
        static let yahooFinance = (calls: 100, period: 60.0) // Conservative estimate
    }
    
    // MARK: - Common Trading Symbols
    struct TradingSymbols {
        // Forex Major Pairs
        static let forexMajors = [
            "EURUSD", "GBPUSD", "USDJPY", "USDCHF",
            "AUDUSD", "USDCAD", "NZDUSD"
        ]
        
        // Forex Minors
        static let forexMinors = [
            "EURGBP", "EURJPY", "GBPJPY", "CHFJPY",
            "EURCHF", "AUDJPY", "GBPAUD"
        ]
        
        // Commodities
        static let commodities = [
            "XAUUSD", "XAGUSD", "USOIL", "UKOIL",
            "NATGAS", "COPPER", "PLATINUM"
        ]
        
        // Major Cryptocurrencies
        static let cryptos = [
            "bitcoin", "ethereum", "binancecoin", "cardano",
            "solana", "polkadot", "dogecoin", "avalanche-2"
        ]
        
        // Stock Indices
        static let indices = [
            "SPY", "QQQ", "DIA", "IWM",
            "VTI", "EFA", "EEM", "GLD"
        ]
        
        // Individual Stocks
        static let stocks = [
            "AAPL", "GOOGL", "MSFT", "AMZN",
            "TSLA", "META", "NVDA", "NFLX"
        ]
    }
    
    // MARK: - Request Timeouts
    struct Timeouts {
        static let standard: TimeInterval = 15.0
        static let long: TimeInterval = 30.0
        static let short: TimeInterval = 5.0
    }
    
    // MARK: - Cache Settings
    struct Cache {
        static let priceDataTTL: TimeInterval = 60 // 1 minute for price data
        static let newsDataTTL: TimeInterval = 300 // 5 minutes for news
        static let economicDataTTL: TimeInterval = 3600 // 1 hour for economic data
        static let technicalDataTTL: TimeInterval = 1800 // 30 minutes for technical data
    }
}

// MARK: - API Service Types
enum APIService: String, CaseIterable {
    case finnhub = "Finnhub"
    case alphaVantage = "Alpha Vantage"
    case tradingEconomics = "Trading Economics"
    case coinGecko = "CoinGecko"
    case fixer = "Fixer.io"
    case newsAPI = "NewsAPI"
    case twelveData = "Twelve Data"
    case polygon = "Polygon.io"
    case restCountries = "REST Countries"
    case yahooFinance = "Yahoo Finance"
    
    var requiresAPIKey: Bool {
        switch self {
        case .coinGecko, .restCountries, .yahooFinance:
            return false
        default:
            return true
        }
    }
    
    var endpoint: String {
        switch self {
        case .finnhub: return FreeAPIConfiguration.Endpoints.finnhub
        case .alphaVantage: return FreeAPIConfiguration.Endpoints.alphaVantage
        case .tradingEconomics: return FreeAPIConfiguration.Endpoints.tradingEconomics
        case .coinGecko: return FreeAPIConfiguration.Endpoints.coinGecko
        case .fixer: return FreeAPIConfiguration.Endpoints.fixer
        case .newsAPI: return FreeAPIConfiguration.Endpoints.newsAPI
        case .twelveData: return FreeAPIConfiguration.Endpoints.twelveData
        case .polygon: return FreeAPIConfiguration.Endpoints.polygon
        case .restCountries: return FreeAPIConfiguration.Endpoints.restCountries
        case .yahooFinance: return FreeAPIConfiguration.Endpoints.yahooFinance
        }
    }
    
    var rateLimit: (calls: Int, period: TimeInterval) {
        switch self {
        case .finnhub: return FreeAPIConfiguration.RateLimits.finnhub
        case .alphaVantage: return FreeAPIConfiguration.RateLimits.alphaVantage
        case .tradingEconomics: return FreeAPIConfiguration.RateLimits.tradingEconomics
        case .coinGecko: return FreeAPIConfiguration.RateLimits.coinGecko
        case .fixer: return FreeAPIConfiguration.RateLimits.fixer
        case .newsAPI: return FreeAPIConfiguration.RateLimits.newsAPI
        case .twelveData: return FreeAPIConfiguration.RateLimits.twelveData
        case .polygon: return FreeAPIConfiguration.RateLimits.polygon
        case .restCountries: return FreeAPIConfiguration.RateLimits.restCountries
        case .yahooFinance: return FreeAPIConfiguration.RateLimits.yahooFinance
        }
    }
}

// MARK: - API Status Tracking
class APIStatus: ObservableObject {
    @Published var serviceStatus: [APIService: ServiceStatus] = [:]
    @Published var lastUpdated = Date()
    
    enum ServiceStatus {
        case operational
        case degraded
        case offline
        case rateLimited
        case unauthorized
        
        var color: Color {
            switch self {
            case .operational: return .green
            case .degraded: return .yellow
            case .offline: return .red
            case .rateLimited: return .orange
            case .unauthorized: return .purple
            }
        }
        
        var description: String {
            switch self {
            case .operational: return "Operational"
            case .degraded: return "Degraded"
            case .offline: return "Offline"
            case .rateLimited: return "Rate Limited"
            case .unauthorized: return "Unauthorized"
            }
        }
    }
    
    init() {
        // Initialize all services as operational
        for service in APIService.allCases {
            serviceStatus[service] = .operational
        }
    }
    
    func updateStatus(_ service: APIService, status: ServiceStatus) {
        DispatchQueue.main.async {
            self.serviceStatus[service] = status
            self.lastUpdated = Date()
        }
    }
    
    func getStatus(_ service: APIService) -> ServiceStatus {
        return serviceStatus[service] ?? .offline
    }
}

import SwiftUI
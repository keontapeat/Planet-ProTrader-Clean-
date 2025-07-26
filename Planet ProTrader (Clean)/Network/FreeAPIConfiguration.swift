//
//  FreeAPIConfiguration.swift
//  Planet ProTrader - Free APIs Configuration
//
//  Comprehensive free API integration for enhanced trading data
//  Created by AI Assistant on 1/25/25.
//

import Foundation
import SwiftUI

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

// MARK: - API Service Helper Functions
struct APIServiceHelper {
    static func requiresAPIKey(_ service: APIService) -> Bool {
        switch service {
        case .coinGecko, .restCountries, .yahooFinance:
            return false
        default:
            return true
        }
    }
    
    static func getEndpoint(for service: APIService) -> String {
        switch service {
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
    
    static func getRateLimit(for service: APIService) -> (calls: Int, period: TimeInterval) {
        switch service {
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
    
    static func getAPIKey(for service: APIService) -> String {
        switch service {
        case .finnhub: return FreeAPIConfiguration.APIKeys.finnhub
        case .alphaVantage: return FreeAPIConfiguration.APIKeys.alphaVantage
        case .tradingEconomics: return FreeAPIConfiguration.APIKeys.tradingEconomics
        case .fixer: return FreeAPIConfiguration.APIKeys.fixer
        case .newsAPI: return FreeAPIConfiguration.APIKeys.newsAPI
        case .twelveData: return FreeAPIConfiguration.APIKeys.twelveData
        case .polygon: return FreeAPIConfiguration.APIKeys.polygon
        case .coinGecko, .restCountries, .yahooFinance: return ""
        }
    }
}

// MARK: - API Status Tracking
@MainActor
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
        
        var icon: String {
            switch self {
            case .operational: return "checkmark.circle.fill"
            case .degraded: return "exclamationmark.triangle.fill"
            case .offline: return "xmark.circle.fill"
            case .rateLimited: return "clock.circle.fill"
            case .unauthorized: return "lock.circle.fill"
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
        serviceStatus[service] = status
        lastUpdated = Date()
    }
    
    func getStatus(_ service: APIService) -> ServiceStatus {
        return serviceStatus[service] ?? .offline
    }
    
    func getOperationalServices() -> [APIService] {
        return APIService.allCases.filter { getStatus($0) == .operational }
    }
    
    func getOfflineServices() -> [APIService] {
        return APIService.allCases.filter { getStatus($0) == .offline }
    }
    
    func getOverallHealth() -> Double {
        let operationalCount = getOperationalServices().count
        let totalCount = APIService.allCases.count
        return Double(operationalCount) / Double(totalCount)
    }
    
    func getHealthColor() -> Color {
        let health = getOverallHealth()
        if health >= 0.8 { return .green }
        else if health >= 0.6 { return .yellow }
        else if health >= 0.4 { return .orange }
        else { return .red }
    }
    
    func getHealthDescription() -> String {
        let health = getOverallHealth()
        if health >= 0.8 { return "Excellent" }
        else if health >= 0.6 { return "Good" }
        else if health >= 0.4 { return "Fair" }
        else { return "Poor" }
    }
}

// MARK: - Rate Limiting Manager
@MainActor
class RateLimitManager: ObservableObject {
    private var requestCounts: [APIService: [(Date, Int)]] = [:]
    private let cleanupInterval: TimeInterval = 300 // 5 minutes
    
    @Published var rateLimitStatus: [APIService: Bool] = [:]
    
    init() {
        // Initialize rate limit status
        for service in APIService.allCases {
            rateLimitStatus[service] = false
        }
        
        // Start cleanup timer
        startCleanupTimer()
    }
    
    private func startCleanupTimer() {
        Timer.scheduledTimer(withTimeInterval: cleanupInterval, repeats: true) { _ in
            Task { @MainActor in
                self.cleanupOldRequests()
            }
        }
    }
    
    private func cleanupOldRequests() {
        let now = Date()
        
        for service in APIService.allCases {
            let rateLimit = APIServiceHelper.getRateLimit(for: service)
            let cutoffTime = now.addingTimeInterval(-rateLimit.period)
            
            requestCounts[service] = requestCounts[service]?.filter { $0.0 > cutoffTime } ?? []
        }
    }
    
    func canMakeRequest(to service: APIService) -> Bool {
        let rateLimit = APIServiceHelper.getRateLimit(for: service)
        let now = Date()
        let cutoffTime = now.addingTimeInterval(-rateLimit.period)
        
        let recentRequests = requestCounts[service]?.filter { $0.0 > cutoffTime } ?? []
        let totalRequests = recentRequests.reduce(0) { $0 + $1.1 }
        
        let canMake = totalRequests < rateLimit.calls
        rateLimitStatus[service] = !canMake
        
        return canMake
    }
    
    func recordRequest(to service: APIService, count: Int = 1) {
        let now = Date()
        
        if requestCounts[service] == nil {
            requestCounts[service] = []
        }
        
        requestCounts[service]?.append((now, count))
    }
    
    func getRemainingRequests(for service: APIService) -> Int {
        let rateLimit = APIServiceHelper.getRateLimit(for: service)
        let now = Date()
        let cutoffTime = now.addingTimeInterval(-rateLimit.period)
        
        let recentRequests = requestCounts[service]?.filter { $0.0 > cutoffTime } ?? []
        let totalRequests = recentRequests.reduce(0) { $0 + $1.1 }
        
        return max(0, rateLimit.calls - totalRequests)
    }
    
    func getTimeUntilReset(for service: APIService) -> TimeInterval {
        let rateLimit = APIServiceHelper.getRateLimit(for: service)
        
        guard let oldestRequest = requestCounts[service]?.first?.0 else {
            return 0
        }
        
        let resetTime = oldestRequest.addingTimeInterval(rateLimit.period)
        return max(0, resetTime.timeIntervalSinceNow)
    }
}

// MARK: - API Configuration Manager
@MainActor
class APIConfigurationManager: ObservableObject {
    static let shared = APIConfigurationManager()
    
    @Published var enabledServices: Set<APIService> = Set(APIService.allCases)
    @Published var customEndpoints: [APIService: String] = [:]
    @Published var customAPIKeys: [APIService: String] = [:]
    
    private init() {
        loadConfiguration()
    }
    
    private func loadConfiguration() {
        // Load from UserDefaults or configuration file
        if let savedServices = UserDefaults.standard.array(forKey: "EnabledAPIServices") as? [String] {
            enabledServices = Set(savedServices.compactMap { APIService(rawValue: $0) })
        }
        
        if let savedEndpoints = UserDefaults.standard.dictionary(forKey: "CustomEndpoints") as? [String: String] {
            customEndpoints = Dictionary(uniqueKeysWithValues: 
                savedEndpoints.compactMap { key, value in
                    guard let service = APIService(rawValue: key) else { return nil }
                    return (service, value)
                }
            )
        }
        
        if let savedKeys = UserDefaults.standard.dictionary(forKey: "CustomAPIKeys") as? [String: String] {
            customAPIKeys = Dictionary(uniqueKeysWithValues:
                savedKeys.compactMap { key, value in
                    guard let service = APIService(rawValue: key) else { return nil }
                    return (service, value)
                }
            )
        }
    }
    
    func saveConfiguration() {
        UserDefaults.standard.set(enabledServices.map { $0.rawValue }, forKey: "EnabledAPIServices")
        
        let endpointDict = Dictionary(uniqueKeysWithValues: customEndpoints.map { ($0.key.rawValue, $0.value) })
        UserDefaults.standard.set(endpointDict, forKey: "CustomEndpoints")
        
        let keyDict = Dictionary(uniqueKeysWithValues: customAPIKeys.map { ($0.key.rawValue, $0.value) })
        UserDefaults.standard.set(keyDict, forKey: "CustomAPIKeys")
    }
    
    func isServiceEnabled(_ service: APIService) -> Bool {
        return enabledServices.contains(service)
    }
    
    func enableService(_ service: APIService) {
        enabledServices.insert(service)
        saveConfiguration()
    }
    
    func disableService(_ service: APIService) {
        enabledServices.remove(service)
        saveConfiguration()
    }
    
    func setCustomEndpoint(_ endpoint: String, for service: APIService) {
        customEndpoints[service] = endpoint
        saveConfiguration()
    }
    
    func setCustomAPIKey(_ key: String, for service: APIService) {
        customAPIKeys[service] = key
        saveConfiguration()
    }
    
    func getEffectiveEndpoint(for service: APIService) -> String {
        return customEndpoints[service] ?? APIServiceHelper.getEndpoint(for: service)
    }
    
    func getEffectiveAPIKey(for service: APIService) -> String {
        return customAPIKeys[service] ?? APIServiceHelper.getAPIKey(for: service)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            Text("🔧 Free API Configuration")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text("Comprehensive API management for enhanced trading data")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("API Services")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("10")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .center, spacing: 4) {
                        Text("Free Tier")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("7/10")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Rate Limits")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Managed")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("🎯 Key Features")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("• Centralized API key management")
                        Text("• Automatic rate limiting protection")
                        Text("• Real-time service status monitoring")
                        Text("• Custom endpoint configuration")
                        Text("• Comprehensive symbol libraries")
                        Text("• Intelligent caching system")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
    .padding()
}
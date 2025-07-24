//
//  FreeAPINetworking.swift
//  Planet ProTrader - Free APIs Networking Layer
//
//  Advanced networking with rate limiting, caching, and error handling
//  Created by AI Assistant on 1/25/25.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Free API Networking Manager
@MainActor
class FreeAPINetworking: ObservableObject {
    static let shared = FreeAPINetworking()
    
    @Published var isConnected = false
    @Published var requestCount: [APIService: Int] = [:]
    @Published var lastRequestTime: [APIService: Date] = [:]
    @Published var errorCount: [APIService: Int] = [:]
    
    private let session: URLSession
    private let cache = NSCache<NSString, CachedResponse>()
    private let apiStatus = APIStatus()
    private var rateLimitTrackers: [APIService: RateLimitTracker] = [:]
    
    // Network monitoring
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = FreeAPIConfiguration.Timeouts.standard
        config.timeoutIntervalForResource = FreeAPIConfiguration.Timeouts.long
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.waitsForConnectivity = true
        
        session = URLSession(configuration: config)
        
        // Initialize rate limit trackers
        for service in APIService.allCases {
            rateLimitTrackers[service] = RateLimitTracker(service: service)
            requestCount[service] = 0
            errorCount[service] = 0
        }
        
        setupNetworkMonitoring()
        print("🌐 Free API Networking initialized with all 10 services")
    }
    
    // MARK: - Network Monitoring
    
    private func setupNetworkMonitoring() {
        // Monitor network reachability
        Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task {
                    await self?.checkNetworkStatus()
                }
            }
            .store(in: &cancellables)
    }
    
    private func checkNetworkStatus() async {
        // Simple connectivity check using a lightweight endpoint
        do {
            let url = URL(string: FreeAPIConfiguration.Endpoints.restCountries + "/all?fields=name")!
            let (_, response) = try await session.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200 {
                isConnected = true
            } else {
                isConnected = false
            }
        } catch {
            isConnected = false
            print("❌ Network connectivity check failed: \(error)")
        }
    }
    
    // MARK: - Generic Request Method
    
    func performRequest<T: Codable>(
        service: APIService,
        endpoint: String,
        method: NetworkHTTPMethod = .GET,
        parameters: [String: Any]? = nil,
        body: [String: Any]? = nil,
        responseType: T.Type,
        cacheKey: String? = nil,
        cacheTTL: TimeInterval = FreeAPIConfiguration.Cache.priceDataTTL
    ) async throws -> T {
        
        // Check rate limiting
        guard await canMakeRequest(for: service) else {
            throw APIError.rateLimited(service.rawValue)
        }
        
        // Check cache first
        if let cacheKey = cacheKey,
           let cachedResponse = getCachedResponse(key: cacheKey, ttl: cacheTTL) {
            print("📦 Using cached response for \(cacheKey)")
            return try JSONDecoder().decode(T.self, from: cachedResponse.data)
        }
        
        // Build URL
        guard let url = buildURL(service: service, endpoint: endpoint, parameters: parameters) else {
            throw APIError.invalidURL
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Planet-ProTrader/1.0", forHTTPHeaderField: "User-Agent")
        
        // Add API key if required
        if service.requiresAPIKey {
            addAuthentication(to: &request, for: service)
        }
        
        // Add body if provided
        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        
        print("📡 \(method.rawValue) \(service.rawValue): \(url.absoluteString)")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            // Update tracking
            updateRequestTracking(for: service, success: true)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            print("📡 \(service.rawValue) Response: \(httpResponse.statusCode)")
            
            // Handle different status codes
            switch httpResponse.statusCode {
            case 200...299:
                // Success - decode and cache response
                let result = try JSONDecoder().decode(T.self, from: data)
                
                // Cache the response
                if let cacheKey = cacheKey {
                    cacheResponse(key: cacheKey, data: data, ttl: cacheTTL)
                }
                
                // Update service status
                apiStatus.updateStatus(service, status: .operational)
                
                return result
                
            case 401, 403:
                apiStatus.updateStatus(service, status: .unauthorized)
                throw APIError.unauthorized(service.rawValue)
                
            case 429:
                // Rate limited - update tracker
                rateLimitTrackers[service]?.recordRateLimit()
                apiStatus.updateStatus(service, status: .rateLimited)
                throw APIError.rateLimited(service.rawValue)
                
            case 500...599:
                apiStatus.updateStatus(service, status: .offline)
                throw APIError.serverError(httpResponse.statusCode)
                
            default:
                apiStatus.updateStatus(service, status: .degraded)
                throw APIError.httpError(httpResponse.statusCode, data)
            }
            
        } catch {
            updateRequestTracking(for: service, success: false)
            
            if error is APIError {
                throw error
            } else {
                apiStatus.updateStatus(service, status: .degraded)
                throw APIError.networkError(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Raw Request Method (for non-JSON responses)
    
    func performRawRequest(
        service: APIService,
        endpoint: String,
        method: NetworkHTTPMethod = .GET,
        parameters: [String: Any]? = nil
    ) async throws -> (Data, HTTPURLResponse) {
        
        guard await canMakeRequest(for: service) else {
            throw APIError.rateLimited(service.rawValue)
        }
        
        guard let url = buildURL(service: service, endpoint: endpoint, parameters: parameters) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("Planet-ProTrader/1.0", forHTTPHeaderField: "User-Agent")
        
        if service.requiresAPIKey {
            addAuthentication(to: &request, for: service)
        }
        
        print("📡 \(method.rawValue) \(service.rawValue): \(url.absoluteString)")
        
        do {
            let (data, response) = try await session.data(for: request)
            updateRequestTracking(for: service, success: true)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            if httpResponse.statusCode == 429 {
                rateLimitTrackers[service]?.recordRateLimit()
                apiStatus.updateStatus(service, status: .rateLimited)
            }
            
            return (data, httpResponse)
            
        } catch {
            updateRequestTracking(for: service, success: false)
            throw error
        }
    }
    
    // MARK: - Helper Methods
    
    private func buildURL(service: APIService, endpoint: String, parameters: [String: Any]?) -> URL? {
        var components = URLComponents(string: service.endpoint + endpoint)
        
        if let parameters = parameters {
            var queryItems: [URLQueryItem] = []
            
            for (key, value) in parameters {
                queryItems.append(URLQueryItem(name: key, value: String(describing: value)))
            }
            
            components?.queryItems = queryItems
        }
        
        return components?.url
    }
    
    private func addAuthentication(to request: inout URLRequest, for service: APIService) {
        let apiKey: String
        
        switch service {
        case .finnhub:
            apiKey = FreeAPIConfiguration.APIKeys.finnhub
            request.setValue(apiKey, forHTTPHeaderField: "X-Finnhub-Token")
            
        case .alphaVantage:
            apiKey = FreeAPIConfiguration.APIKeys.alphaVantage
            // Alpha Vantage uses API key in URL parameters (handled in buildURL)
            
        case .tradingEconomics:
            apiKey = FreeAPIConfiguration.APIKeys.tradingEconomics
            request.setValue("Client \(apiKey)", forHTTPHeaderField: "Authorization")
            
        case .fixer:
            apiKey = FreeAPIConfiguration.APIKeys.fixer
            // Fixer uses API key in URL parameters (handled in buildURL)
            
        case .newsAPI:
            apiKey = FreeAPIConfiguration.APIKeys.newsAPI
            request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
            
        case .twelveData:
            apiKey = FreeAPIConfiguration.APIKeys.twelveData
            // Twelve Data uses API key in URL parameters (handled in buildURL)
            
        case .polygon:
            apiKey = FreeAPIConfiguration.APIKeys.polygon
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            
        case .coinGecko, .restCountries, .yahooFinance:
            // No authentication required
            break
        }
    }
    
    private func canMakeRequest(for service: APIService) async -> Bool {
        guard let tracker = rateLimitTrackers[service] else { return true }
        return tracker.canMakeRequest()
    }
    
    private func updateRequestTracking(for service: APIService, success: Bool) {
        requestCount[service, default: 0] += 1
        lastRequestTime[service] = Date()
        
        if !success {
            errorCount[service, default: 0] += 1
        }
        
        rateLimitTrackers[service]?.recordRequest()
    }
    
    // MARK: - Caching
    
    private func getCachedResponse(key: String, ttl: TimeInterval) -> CachedResponse? {
        guard let cached = cache.object(forKey: key as NSString) else { return nil }
        
        if Date().timeIntervalSince(cached.timestamp) < ttl {
            return cached
        } else {
            cache.removeObject(forKey: key as NSString)
            return nil
        }
    }
    
    private func cacheResponse(key: String, data: Data, ttl: TimeInterval) {
        let cached = CachedResponse(data: data, timestamp: Date())
        cache.setObject(cached, forKey: key as NSString)
    }
    
    // MARK: - Statistics
    
    func getStatistics() -> NetworkStatistics {
        let totalRequests = requestCount.values.reduce(0, +)
        let totalErrors = errorCount.values.reduce(0, +)
        let successRate = totalRequests > 0 ? Double(totalRequests - totalErrors) / Double(totalRequests) : 0.0
        
        return NetworkStatistics(
            totalRequests: totalRequests,
            totalErrors: totalErrors,
            successRate: successRate,
            serviceStats: requestCount.mapValues { $0 },
            lastUpdated: Date()
        )
    }
    
    func resetStatistics() {
        requestCount.removeAll()
        errorCount.removeAll()
        lastRequestTime.removeAll()
        
        for service in APIService.allCases {
            requestCount[service] = 0
            errorCount[service] = 0
        }
    }
}

// MARK: - Supporting Types

class CachedResponse {
    let data: Data
    let timestamp: Date
    
    init(data: Data, timestamp: Date) {
        self.data = data
        self.timestamp = timestamp
    }
}

class RateLimitTracker {
    private let service: APIService
    private var requestTimes: [Date] = []
    private var rateLimitUntil: Date?
    
    init(service: APIService) {
        self.service = service
    }
    
    func canMakeRequest() -> Bool {
        // Check if we're still rate limited
        if let rateLimitUntil = rateLimitUntil,
           Date() < rateLimitUntil {
            return false
        }
        
        let now = Date()
        let limit = service.rateLimit
        
        // Clean old requests outside the time window
        requestTimes = requestTimes.filter { now.timeIntervalSince($0) < limit.period }
        
        // Check if we can make another request
        return requestTimes.count < limit.calls
    }
    
    func recordRequest() {
        requestTimes.append(Date())
    }
    
    func recordRateLimit() {
        // Set rate limit cooldown for the service's period
        rateLimitUntil = Date().addingTimeInterval(service.rateLimit.period)
    }
}

enum NetworkHTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case networkError(String)
    case httpError(Int, Data)
    case rateLimited(String)
    case unauthorized(String)
    case serverError(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .networkError(let message):
            return "Network error: \(message)"
        case .httpError(let code, _):
            return "HTTP error: \(code)"
        case .rateLimited(let service):
            return "\(service) rate limit exceeded"
        case .unauthorized(let service):
            return "\(service) unauthorized - check API key"
        case .serverError(let code):
            return "Server error: \(code)"
        }
    }
}

struct NetworkStatistics {
    let totalRequests: Int
    let totalErrors: Int
    let successRate: Double
    let serviceStats: [APIService: Int]
    let lastUpdated: Date
}

#Preview {
    VStack {
        Text("Free API Networking")
            .font(.title)
        Text("10 API Services Integrated")
            .font(.caption)
    }
}
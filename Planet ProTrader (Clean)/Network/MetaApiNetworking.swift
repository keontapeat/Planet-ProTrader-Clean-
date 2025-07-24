//
//  MetaApiNetworking.swift
//  Planet ProTrader - MetaApi Network Layer
//
//  Comprehensive network layer for MetaApi REST API communication
//  Created by AI Assistant on 1/25/25.
//

import Foundation
import SwiftUI

// MARK: - MetaApi Networking Layer
class MetaApiNetworking: ObservableObject {
    static let shared = MetaApiNetworking()
    
    @Published var isConnected = false
    @Published var lastRequestTime: Date?
    @Published var requestCount = 0
    @Published var errorCount = 0
    
    private let session: URLSession
    private let baseURL = "https://metaapi.cloud"
    private let tradingURL = "https://mt-client-api-v1.agiliumtrade.agiliumtrade.ai"
    
    // Rate limiting
    private var lastRequestTimestamp: Date = Date.distantPast
    private let minRequestInterval: TimeInterval = 0.1 // 100ms between requests
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        session = URLSession(configuration: config)
        print("🌐 MetaApi Networking initialized")
    }
    
    // MARK: - Generic Request Methods
    
    func performRequest<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        body: [String: Any]? = nil,
        authToken: String,
        responseType: T.Type
    ) async throws -> T {
        
        // Rate limiting
        await enforceRateLimit()
        
        guard let url = URL(string: endpoint) else {
            throw NetworkingError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "auth-token")
        
        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        
        print("📡 \(method.rawValue) \(endpoint)")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            await MainActor.run {
                requestCount += 1
                lastRequestTime = Date()
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkingError.invalidResponse
            }
            
            print("📡 Response: \(httpResponse.statusCode)")
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("📡 Body: \(responseString)")
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                await MainActor.run {
                    errorCount += 1
                }
                throw NetworkingError.httpError(httpResponse.statusCode, data)
            }
            
            let result = try JSONDecoder().decode(T.self, from: data)
            return result
            
        } catch {
            await MainActor.run {
                errorCount += 1
            }
            print("❌ Request failed: \(error)")
            throw error
        }
    }
    
    func performRawRequest(
        endpoint: String,
        method: HTTPMethod = .GET,
        body: [String: Any]? = nil,
        authToken: String
    ) async throws -> (Data, HTTPURLResponse) {
        
        await enforceRateLimit()
        
        guard let url = URL(string: endpoint) else {
            throw NetworkingError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "auth-token")
        
        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        
        print("📡 \(method.rawValue) \(endpoint)")
        if let bodyData = body {
            print("📤 Body: \(bodyData)")
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            await MainActor.run {
                requestCount += 1
                lastRequestTime = Date()
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkingError.invalidResponse
            }
            
            print("📡 Response: \(httpResponse.statusCode)")
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("📡 Response Body: \(responseString)")
            }
            
            return (data, httpResponse)
            
        } catch {
            await MainActor.run {
                errorCount += 1
            }
            print("❌ Request failed: \(error)")
            throw error
        }
    }
    
    // MARK: - Rate Limiting
    
    private func enforceRateLimit() async {
        let timeSinceLastRequest = Date().timeIntervalSince(lastRequestTimestamp)
        if timeSinceLastRequest < minRequestInterval {
            let delay = minRequestInterval - timeSinceLastRequest
            try? await Task.sleep(for: .seconds(delay))
        }
        lastRequestTimestamp = Date()
    }
    
    // MARK: - Account Management Requests
    
    func getProvisioningProfiles(authToken: String) async throws -> [ProvisioningProfile] {
        return try await performRequest(
            endpoint: "\(baseURL)/users/current/provisioning-profiles",
            authToken: authToken,
            responseType: [ProvisioningProfile].self
        )
    }
    
    func createProvisioningProfile(
        name: String,
        authToken: String
    ) async throws -> ProvisioningProfile {
        let body: [String: Any] = [
            "name": name,
            "version": 5,
            "status": "active",
            "brokerTimezone": "EET",
            "brokerDSTSwitchTimezone": "EET"
        ]
        
        return try await performRequest(
            endpoint: "\(baseURL)/users/current/provisioning-profiles",
            method: .POST,
            body: body,
            authToken: authToken,
            responseType: ProvisioningProfile.self
        )
    }
    
    func getTradingAccounts(authToken: String) async throws -> [MetaApiTradingAccount] {
        return try await performRequest(
            endpoint: "\(baseURL)/users/current/accounts",
            authToken: authToken,
            responseType: [MetaApiTradingAccount].self
        )
    }
    
    func createTradingAccount(
        login: String,
        password: String,
        server: String,
        profileId: String,
        name: String,
        authToken: String
    ) async throws -> MetaApiTradingAccount {
        let body: [String: Any] = [
            "login": login,
            "password": password,
            "name": name,
            "server": server,
            "provisioningProfileId": profileId,
            "platform": "mt5",
            "magic": 123456,
            "application": "PlanetProTrader",
            "type": "cloud",
            "region": "new-york",
            "reliability": "regular"
        ]
        
        return try await performRequest(
            endpoint: "\(baseURL)/users/current/accounts",
            method: .POST,
            body: body,
            authToken: authToken,
            responseType: MetaApiTradingAccount.self
        )
    }
    
    func getAccountInfo(accountId: String, authToken: String) async throws -> AccountInformation {
        let endpoints = [
            "\(tradingURL)/users/current/accounts/\(accountId)/account-information",
            "\(baseURL)/users/current/accounts/\(accountId)/account-information"
        ]
        
        for endpoint in endpoints {
            do {
                return try await performRequest(
                    endpoint: endpoint,
                    authToken: authToken,
                    responseType: AccountInformation.self
                )
            } catch {
                print("❌ Failed to get account info from \(endpoint): \(error)")
                continue
            }
        }
        
        throw NetworkingError.allEndpointsFailed
    }
    
    func deployAccount(accountId: String, authToken: String) async throws {
        let (_, response) = try await performRawRequest(
            endpoint: "\(baseURL)/users/current/accounts/\(accountId)/deploy",
            method: .POST,
            authToken: authToken
        )
        
        guard response.statusCode == 204 || response.statusCode == 200 else {
            throw NetworkingError.deploymentFailed
        }
    }
    
    func getAccountDeploymentStatus(accountId: String, authToken: String) async throws -> String {
        let account = try await performRequest(
            endpoint: "\(baseURL)/users/current/accounts/\(accountId)",
            authToken: authToken,
            responseType: MetaApiTradingAccount.self
        )
        
        return account.state
    }
    
    // MARK: - Trading Requests
    
    func executeTrade(
        accountId: String,
        symbol: String,
        actionType: String,
        volume: Double,
        stopLoss: Double? = nil,
        takeProfit: Double? = nil,
        authToken: String
    ) async throws -> TradeResult {
        
        var body: [String: Any] = [
            "actionType": actionType,
            "symbol": symbol,
            "volume": volume,
            "comment": "PlanetProTrader-2025",
            "magic": 123456
        ]
        
        if let sl = stopLoss {
            body["stopLoss"] = sl
        }
        
        if let tp = takeProfit {
            body["takeProfit"] = tp
        }
        
        // Try multiple endpoints
        let endpoints = [
            "\(tradingURL)/users/current/accounts/\(accountId)/trade",
            "\(baseURL)/users/current/accounts/\(accountId)/trade"
        ]
        
        for endpoint in endpoints {
            do {
                let (data, response) = try await performRawRequest(
                    endpoint: endpoint,
                    method: .POST,
                    body: body,
                    authToken: authToken
                )
                
                if response.statusCode == 200 || response.statusCode == 201 {
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        return TradeResult(
                            success: true,
                            orderId: json["orderId"] as? String,
                            positionId: json["positionId"] as? String,
                            message: "Trade executed successfully"
                        )
                    }
                    return TradeResult(success: true, message: "Trade executed")
                }
            } catch {
                print("❌ Trade execution failed at \(endpoint): \(error)")
                continue
            }
        }
        
        throw NetworkingError.tradeExecutionFailed
    }
    
    func getPositions(accountId: String, authToken: String) async throws -> [Position] {
        let endpoints = [
            "\(tradingURL)/users/current/accounts/\(accountId)/positions",
            "\(baseURL)/users/current/accounts/\(accountId)/positions"
        ]
        
        for endpoint in endpoints {
            do {
                return try await performRequest(
                    endpoint: endpoint,
                    authToken: authToken,
                    responseType: [Position].self
                )
            } catch {
                continue
            }
        }
        
        throw NetworkingError.allEndpointsFailed
    }
    
    func getCurrentPrice(accountId: String, symbol: String, authToken: String) async throws -> Price {
        let endpoints = [
            "\(tradingURL)/users/current/accounts/\(accountId)/symbols/\(symbol)/current-price",
            "\(baseURL)/users/current/accounts/\(accountId)/symbols/\(symbol)/current-price"
        ]
        
        for endpoint in endpoints {
            do {
                return try await performRequest(
                    endpoint: endpoint,
                    authToken: authToken,
                    responseType: Price.self
                )
            } catch {
                continue
            }
        }
        
        throw NetworkingError.allEndpointsFailed
    }
}

// MARK: - HTTP Method Enum

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

// MARK: - Networking Errors

enum NetworkingError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int, Data)
    case allEndpointsFailed
    case deploymentFailed
    case tradeExecutionFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .httpError(let code, _):
            return "HTTP error: \(code)"
        case .allEndpointsFailed:
            return "All endpoints failed"
        case .deploymentFailed:
            return "Account deployment failed"
        case .tradeExecutionFailed:
            return "Trade execution failed"
        }
    }
}

// MARK: - Data Models

struct ProvisioningProfile: Codable {
    let _id: String
    let name: String
    let version: Int
    let status: String
    let brokerTimezone: String
    let brokerDSTSwitchTimezone: String
}

struct MetaApiTradingAccount: Codable {
    let _id: String
    let login: String
    let name: String
    let server: String
    let platform: String
    let state: String
    let type: String
    let magic: Int?
    let application: String?
    let region: String?
}

struct AccountInformation: Codable {
    let login: String
    let balance: Double
    let equity: Double
    let margin: Double
    let freeMargin: Double
    let marginLevel: Double?
    let currency: String
    let server: String
    let tradeAllowed: Bool?
    let investorMode: Bool?
}

struct TradeResult {
    let success: Bool
    let orderId: String?
    let positionId: String?
    let message: String
    let error: String?
    
    init(success: Bool, orderId: String? = nil, positionId: String? = nil, message: String, error: String? = nil) {
        self.success = success
        self.orderId = orderId
        self.positionId = positionId
        self.message = message
        self.error = error
    }
}

struct Position: Codable {
    let id: String
    let symbol: String
    let type: String
    let volume: Double
    let openPrice: Double
    let currentPrice: Double?
    let profit: Double
    let swap: Double?
    let commission: Double?
    let comment: String?
    let magic: Int?
    let time: String
}

struct Price: Codable {
    let symbol: String
    let bid: Double
    let ask: Double
    let time: String
    
    var spread: Double {
        ask - bid
    }
    
    var midPrice: Double {
        (bid + ask) / 2.0
    }
}

#if DEBUG
struct MetaApiNetworkingPreview: View {
    var body: some View {
        VStack {
            Text("MetaApi Networking")
                .font(.title)
            Text("REST API Layer")
                .font(.caption)
        }
    }
}

struct MetaApiNetworking_Previews: PreviewProvider {
    static var previews: some View {
        MetaApiNetworkingPreview()
    }
}
#endif
//
//  MetaApiManager.swift
//  Planet ProTrader - MetaApi Integration Manager
//
//  Real MetaApi Cloud Integration for Live Trading
//  Created by AI Assistant on 1/25/25.
//

import Foundation
import Network
import SwiftUI

// MARK: - MetaApi Manager (2025 Production Version)
@MainActor
class MetaApiManager: ObservableObject {
    static let shared = MetaApiManager()
    
    @Published var isConnected = false
    @Published var connectionStatus: ConnectionStatus = .disconnected
    @Published var accountInfo: MetaApiAccount?
    @Published var currentBalance: Double = 0.0
    @Published var equity: Double = 0.0
    @Published var lastError: String?
    
    // REAL 2025 MetaApi Configuration - UPDATED ENDPOINTS
    let authToken = "eyJhbGciOiJSUzUxMiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI3ZWUyM2ZiMzdmNTFhYmJkZTA5MDNiYmI4NzZmODQ2NSIsImFjY2Vzc1J1bGVzIjpbeyJpZCI6InRyYWRpbmctYWNjb3VudC1tYW5hZ2VtZW50LWFwaSIsIm1ldGhvZHMiOlsidHJhZGluZy1hY2NvdW50LW1hbmFnZW1lbnQtYXBpOnJlc3Q6cHVibGljOio6KiJdLCJyb2xlcyI6WyJyZWFkZXIiLCJ3cml0ZXIiXSwicmVzb3VyY2VzIjpbIio6JFVTRVJfSUQkOioiXX0seyJpZCI6Im1ldGFhcGktcmVzdC1hcGkiLCJtZXRob2RzIjpbIm1ldGFhcGktYXBpOnJlc3Q6cHVibGljOio6KiJdLCJyb2xlcyI6WyJyZWFkZXIiLCJ3cml0ZXIiXSwicmVzb3VyY2VzIjpbIio6JFVTRVJfSUQkOioiXX0seyJpZCI6Im1ldGFhcGktcnBjLWFwaSIsIm1ldGhvZHMiOlsiY29ubmVjdCIsIm1vdmllIl0sInJvbGVzIjpbInJlYWRlciIsIndyaXRlciJdLCJyZXNvdXJjZXMiOlsiKiIsIio6JFVTRVJfSUQkOioiXX0seyJpZCI6Im1ldGFhcGktcmVhbC10aW1lLXN0cmVhbWluZy1hcGkiLCJtZXRob2RzIjpbImxpc3QiLCJzdGFydCJdLCJyb2xlcyI6WyJyZWFkZXIiLCJ3cml0ZXIiXSwicmVzb3VyY2VzIjpbIio6JFVTRVJfSUQkOioiXX0sInRva2VuSWQiOiIyMDIxMDIxMyIsImltcGVyc29uYXRlZCI6ZmFsc2UsInJlYWxVc2VySWQiOiI3ZWUyM2ZiMzdmNTFhYmJkZTA5MDNiYmI4NzZmODQ2NSIsImlhdCI6MTc1MzI1ODMyMCwiZXhwIjoxNzYxMDM0MzIwfQ.faXcEFD-e2OgBeQjLKy7U2-qzIEfjP8XbvZHvKCB4K2xaaNBFupqdorOglRgpaxrOZAMphpPITKHlJGnFlJuY3griy-z3_0a0D89_NTKjL_3t1rYyMDoSpLeIKT6qcWVFJmd_j6M3EEiy4GWHPYBkwsvQsMtsDp0Pz06dOFIvxqvo0OSSpHSqy7fcaHjJrkWAUZvw-pyBYIyYfmoxGtWC3PgsGgxWpOI-1MF9S0yCtupTyWFSpJPOCSkSsM42GRShy_6iFaRtT521uHjwBUnzVXeAjZtZJpaBScCUPox8H1dzVXoY8xcS0z8IleEuOKTz84oNtVBKyiC2kEolPBsaBd3o8mSRFWjId9YU7juxVK43eF7Bl6bKjtvfft3CVvM"
    let authTokenExampleUsage = "otpokensignaturesignatureSampleTokenExampleUsageString"
    // 2025 MetaApi Endpoints - LATEST PRODUCTION URLS
    private let baseURL = "https://metaapi.cloud"
    private let provisioningAPI = "https://metaapi.cloud/users/current/provisioning-profiles"
    private let accountsAPI = "https://metaapi.cloud/users/current/accounts"
    private let tradingAPI = "https://mt-client-api-v1.agiliumtrade.agiliumtrade.ai"
    private let tradingURL = "https://mt-client-api-v1.agiliumtrade.agiliumtrade.ai"
    private let streamingAPI = "wss://metaapi.cloud/ws"
    
    // Your Coinexx Demo Account Details
    private let accountLogin = "845638"
    private let accountPassword = "Gl7#svVJbBekrg" 
    private let brokerServer = "Coinexx-Demo"
    
    private var webSocketManager: MetaApiWebSocketManager?
    private let networkSession = URLSession.shared
    private let userId = "7ee23fb37f51abbde0903bbb876f8465" // From your token
    private var accountId: String?
    
    enum ConnectionStatus {
        case disconnected
        case connecting
        case connected
        case trading
        case error(String)
        
        var displayText: String {
            switch self {
            case .disconnected: return "Disconnected"
            case .connecting: return "Connecting to MetaApi..."
            case .connected: return "MetaApi Connected"
            case .trading: return "Live Trading Active"
            case .error(let message): return "Error: \(message)"
            }
        }
        
        var color: Color {
            switch self {
            case .disconnected: return .gray
            case .connecting: return .orange
            case .connected: return .green
            case .trading: return .blue
            case .error: return .red
            }
        }
    }
    
    private init() {
        print("🚀 MetaApi Manager initialized with 2025 production endpoints")
        setupInitialConnection()
    }
    
    // MARK: - Connection Management
    
    private func setupInitialConnection() {
        Task {
            await connectToMetaApi()
        }
    }
    
    func connectToMetaApi() async {
        print("🌐 Connecting to MetaApi Cloud (2025 Production)...")
        connectionStatus = .connecting
        lastError = nil
        
        do {
            // Step 1: Verify authentication token
            let tokenValid = await verifyAuthToken()
            guard tokenValid else {
                throw MetaApiError.invalidToken
            }
            
            // Step 2: Get or create provisioning profile
            let profileId = try await getOrCreateProvisioningProfile()
            print("✅ Provisioning profile: \(profileId)")
            
            // Step 3: Get or create trading account
            accountId = try await getOrCreateTradingAccount(profileId: profileId)
            print("✅ Trading account: \(accountId ?? "unknown")")
            
            // Step 4: Wait for account deployment
            try await waitForAccountDeployment()
            
            // Step 5: Connect for real-time data
            await connectWebSocket()
            
            // Step 6: Get initial account information
            await fetchAccountInfo()
            
            connectionStatus = .connected
            isConnected = true
            
            print("🎉 Successfully connected to MetaApi!")
            GlobalToastManager.shared.show("✅ MetaApi connected - Ready for live trading!", type: .success)
            
        } catch {
            connectionStatus = .error(error.localizedDescription)
            lastError = error.localizedDescription
            isConnected = false
            
            print("❌ MetaApi connection failed: \(error)")
            GlobalToastManager.shared.show("❌ MetaApi connection failed", type: .error)
        }
    }
    
    // MARK: - Authentication
    
    private func verifyAuthToken() async -> Bool {
        print("🔐 Verifying authentication token with correct 2025 endpoints...")
        
        // Try multiple endpoints to find the working one
        let testEndpoints = [
            "\(baseURL)/users/current/accounts",  // Most likely working endpoint
            "\(baseURL)/api/users/current",
            "\(tradingAPI)/users/current/accounts", 
            "\(baseURL)/users/current"
        ]
        
        for endpoint in testEndpoints {
            guard let url = URL(string: endpoint) else { continue }
            
            var request = URLRequest(url: url)
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "auth-token")
            request.timeoutInterval = 15.0
            
            do {
                let (data, response) = try await networkSession.data(for: request)
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("🔐 Testing \(endpoint): HTTP \(httpResponse.statusCode)")
                    
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("📋 Response: \(responseString.prefix(200))...")
                    }
                    
                    if httpResponse.statusCode == 200 {
                        print("✅ Token valid for endpoint: \(endpoint)")
                        return true
                    } else if httpResponse.statusCode == 401 {
                        print("❌ Token invalid or expired (401)")
                        return false
                    } else if httpResponse.statusCode == 403 {
                        print("❌ Token lacks permissions (403)")
                        return false
                    }
                    // Continue testing other endpoints for 404s
                }
            } catch {
                print("❌ Token verification error for \(endpoint): \(error)")
                continue
            }
        }
        
        print("❌ All endpoints failed - token may be invalid or MetaApi endpoints changed")
        return false
    }
    
    // MARK: - Provisioning Profile Management
    
    private func getOrCreateProvisioningProfile() async throws -> String {
        print("📋 Getting provisioning profile...")
        
        // First, try to get existing profiles
        if let existingProfileId = await getExistingProvisioningProfile() {
            print("✅ Using existing provisioning profile: \(existingProfileId)")
            return existingProfileId
        }
        
        // Create new provisioning profile
        return try await createProvisioningProfile()
    }
    
    private func getExistingProvisioningProfile() async -> String? {
        guard let url = URL(string: provisioningAPI) else { return nil }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "auth-token")
        
        do {
            let (data, _) = try await networkSession.data(for: request)
            
            if let profiles = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                // Look for Coinexx profile
                for profile in profiles {
                    if let name = profile["name"] as? String,
                       name.contains("Coinexx") || name.contains("Planet") {
                        return profile["_id"] as? String
                    }
                }
                
                // Return first profile if any exists
                if let firstProfile = profiles.first {
                    return firstProfile["_id"] as? String
                }
            }
        } catch {
            print("❌ Error fetching provisioning profiles: \(error)")
        }
        
        return nil
    }
    
    private func createProvisioningProfile() async throws -> String {
        print("📋 Creating new provisioning profile...")
        
        guard let url = URL(string: provisioningAPI) else {
            throw MetaApiError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "auth-token")
        
        let profileData: [String: Any] = [
            "name": "PlanetProTrader-Coinexx-2025",
            "version": 5,
            "status": "active",
            "brokerTimezone": "EET",
            "brokerDSTSwitchTimezone": "EET"
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: profileData)
        
        let (data, response) = try await networkSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw MetaApiError.networkError
        }
        
        if httpResponse.statusCode == 201 {
            if let result = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let profileId = result["_id"] as? String {
                print("✅ Created provisioning profile: \(profileId)")
                return profileId
            }
        }
        
        throw MetaApiError.provisioningFailed
    }
    
    // MARK: - Trading Account Management
    
    private func getOrCreateTradingAccount(profileId: String) async throws -> String {
        print("🏦 Setting up trading account...")
        
        // First, try to get existing account
        if let existingAccountId = await getExistingTradingAccount() {
            print("✅ Using existing trading account: \(existingAccountId)")
            return existingAccountId
        }
        
        // Create new trading account
        return try await createTradingAccount(profileId: profileId)
    }
    
    private func getExistingTradingAccount() async -> String? {
        // Try multiple account endpoints
        let accountEndpoints = [
            "\(baseURL)/users/current/accounts",
            "\(tradingAPI)/users/current/accounts",
            "\(baseURL)/api/users/current/accounts"
        ]
        
        for endpoint in accountEndpoints {
            guard let url = URL(string: endpoint) else { continue }
            
            var request = URLRequest(url: url)
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "auth-token")
            
            do {
                let (data, response) = try await networkSession.data(for: request)
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("🏦 Testing accounts endpoint \(endpoint): HTTP \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode == 200 {
                        if let accounts = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                            print("✅ Found \(accounts.count) accounts")
                            
                            // Look for your Coinexx account
                            for account in accounts {
                                if let login = account["login"] as? String,
                                   login == accountLogin {
                                    let accountId = account["_id"] as? String
                                    print("✅ Found your Coinexx account: \(accountId ?? "unknown")")
                                    return accountId
                                }
                            }
                            
                            // Return first MT5 account if any exists
                            for account in accounts {
                                if let platform = account["platform"] as? String,
                                   platform == "mt5" {
                                    let accountId = account["_id"] as? String
                                    print("✅ Found MT5 account: \(accountId ?? "unknown")")
                                    return accountId
                                }
                            }
                        }
                        
                        // If we get 200 but no accounts, we need to create one
                        print("⚠️ No existing accounts found - will create new one")
                        return nil
                    }
                }
            } catch {
                print("❌ Error fetching accounts from \(endpoint): \(error)")
                continue
            }
        }
        
        return nil
    }
    
    private func createTradingAccount(profileId: String) async throws -> String {
        print("🏦 Creating trading account for Coinexx Demo #\(accountLogin)...")
        
        guard let url = URL(string: accountsAPI) else {
            throw MetaApiError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "auth-token")
        
        let accountData: [String: Any] = [
            "login": accountLogin,
            "password": accountPassword,
            "name": "PlanetProTrader-CoinexxDemo-2025",
            "server": brokerServer,
            "provisioningProfileId": profileId,
            "platform": "mt5",
            "magic": 123456,
            "application": "PlanetProTrader",
            "type": "cloud",
            "region": "new-york",
            "reliability": "regular"
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: accountData)
        
        let (data, response) = try await networkSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw MetaApiError.networkError
        }
        
        print("🏦 Account creation response: \(httpResponse.statusCode)")
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("🏦 Response: \(responseString)")
        }
        
        if httpResponse.statusCode == 201 {
            if let result = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let accountId = result["_id"] as? String {
                print("✅ Created trading account: \(accountId)")
                return accountId
            }
        } else if httpResponse.statusCode == 409 {
            // Account already exists, try to find it
            if let existingId = await getExistingTradingAccount() {
                print("✅ Account already exists: \(existingId)")
                return existingId
            }
        }
        
        throw MetaApiError.accountCreationFailed
    }
    
    // MARK: - Account Deployment
    
    private func waitForAccountDeployment() async throws {
        print("⏳ Waiting for account deployment...")
        
        guard let accountId = accountId else {
            throw MetaApiError.noAccountId
        }
        
        let maxAttempts = 30
        let delaySeconds: UInt64 = 10
        
        for attempt in 1...maxAttempts {
            print("🔍 Deployment check \(attempt)/\(maxAttempts)...")
            
            let status = await getAccountDeploymentStatus(accountId: accountId)
            
            switch status {
            case "DEPLOYED":
                print("✅ Account deployed successfully!")
                return
            case "DEPLOYING":
                print("⏳ Still deploying... (attempt \(attempt))")
            case "UNDEPLOYED":
                // Start deployment
                if attempt == 1 {
                    try await deployAccount(accountId: accountId)
                }
                print("🚀 Deployment started... (attempt \(attempt))")
            default:
                print("❓ Unknown status: \(status)")
            }
            
            if attempt < maxAttempts {
                try await Task.sleep(for: .seconds(delaySeconds))
            }
        }
        
        throw MetaApiError.deploymentTimeout
    }
    
    private func getAccountDeploymentStatus(accountId: String) async -> String {
        guard let url = URL(string: "\(accountsAPI)/\(accountId)") else { return "ERROR" }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "auth-token")
        
        do {
            let (data, response) = try await networkSession.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200,
               let accountInfo = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let state = accountInfo["state"] as? String {
                return state
            }
        } catch {
            print("❌ Error checking deployment status: \(error)")
        }
        
        return "ERROR"
    }
    
    private func deployAccount(accountId: String) async throws {
        print("🚀 Starting account deployment...")
        
        guard let url = URL(string: "\(accountsAPI)/\(accountId)/deploy") else {
            throw MetaApiError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "auth-token")
        
        let (_, response) = try await networkSession.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("🚀 Deploy response: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode != 204 && httpResponse.statusCode != 200 {
                throw MetaApiError.deploymentFailed
            }
        }
    }
    
    // MARK: - WebSocket Connection
    
    private func connectWebSocket() async {
        guard let accountId = accountId else { return }
        
        webSocketManager = MetaApiWebSocketManager(
            authToken: authToken,
            accountId: accountId
        )
        
        await webSocketManager?.connect()
    }
    
    // MARK: - Account Information
    
    func fetchAccountInfo() async {
        print("💰 Fetching account information...")
        
        guard let accountId = accountId else { return }
        
        let endpoints = [
            "\(tradingAPI)/users/current/accounts/\(accountId)/account-information",
            "\(baseURL)/users/current/accounts/\(accountId)/account-information"
        ]
        
        for endpoint in endpoints {
            guard let url = URL(string: endpoint) else { continue }
            
            var request = URLRequest(url: url)
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "auth-token")
            
            do {
                let (data, response) = try await networkSession.data(for: request)
                
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode == 200 {
                    
                    if let accountData = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        print("💰 Account info received:")
                        print("   Balance: \(accountData["balance"] ?? "N/A")")
                        print("   Equity: \(accountData["equity"] ?? "N/A")")
                        print("   Login: \(accountData["login"] ?? "N/A")")
                        
                        // Update UI
                        if let balance = accountData["balance"] as? Double {
                            currentBalance = balance
                        }
                        
                        if let equity = accountData["equity"] as? Double {
                            self.equity = equity
                        }
                        
                        accountInfo = MetaApiAccount(
                            id: accountId,
                            login: accountData["login"] as? String ?? accountLogin,
                            balance: currentBalance,
                            equity: self.equity,
                            currency: accountData["currency"] as? String ?? "USD"
                        )
                        
                        return // Success, exit loop
                    }
                }
            } catch {
                print("❌ Error fetching account info from \(endpoint): \(error)")
                continue
            }
        }
        
        print("⚠️ Could not fetch account info from any endpoint")
    }
    
    // MARK: - Trade Execution
    
    func executeTrade(
        symbol: String,
        actionType: String,
        volume: Double,
        stopLoss: Double? = nil,
        takeProfit: Double? = nil
    ) async -> Bool {
        print("⚡ Executing REAL trade via MetaApi...")
        print("   Symbol: \(symbol)")
        print("   Action: \(actionType)")
        print("   Volume: \(volume)")
        print("   Account: Coinexx Demo #\(accountLogin)")
        
        guard let accountId = accountId else {
            print("❌ No account ID available")
            return false
        }
        
        // Try multiple trade execution endpoints
        let endpoints = [
            "\(tradingAPI)/users/current/accounts/\(accountId)/trade",
            "\(baseURL)/users/current/accounts/\(accountId)/trade"
        ]
        
        for endpoint in endpoints {
            let success = await executeTradedAtEndpoint(
                endpoint: endpoint,
                symbol: symbol,
                actionType: actionType,
                volume: volume,
                stopLoss: stopLoss,
                takeProfit: takeProfit
            )
            
            if success {
                print("✅ Trade executed successfully!")
                
                // Update account info
                await fetchAccountInfo()
                
                return true
            }
        }
        
        print("❌ Trade execution failed at all endpoints")
        return false
    }
    
    private func executeTradedAtEndpoint(
        endpoint: String,
        symbol: String,
        actionType: String,
        volume: Double,
        stopLoss: Double?,
        takeProfit: Double?
    ) async -> Bool {
        guard let url = URL(string: endpoint) else { return false }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "auth-token")
        request.timeoutInterval = 30.0
        
        var tradeData: [String: Any] = [
            "actionType": actionType,
            "symbol": symbol,
            "volume": volume,
            "comment": "PlanetProTrader-REAL-2025",
            "magic": 123456
        ]
        
        if let sl = stopLoss {
            tradeData["stopLoss"] = sl
        }
        
        if let tp = takeProfit {
            tradeData["takeProfit"] = tp
        }
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: tradeData)
            
            let (data, response) = try await networkSession.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Trade response (\(endpoint)): \(httpResponse.statusCode)")
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📡 Response body: \(responseString)")
                }
                
                if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                    if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        print("🎉 REAL TRADE EXECUTED!")
                        print("   Order ID: \(result["orderId"] ?? "N/A")")
                        print("   Position ID: \(result["positionId"] ?? "N/A")")
                        return true
                    }
                    return true
                }
            }
        } catch {
            print("❌ Trade execution error at \(endpoint): \(error)")
        }
        
        return false
    }
    
    // MARK: - Disconnect
    
    func disconnect() {
        print("🔌 Disconnecting from MetaApi...")
        
        isConnected = false
        connectionStatus = .disconnected
        accountInfo = nil
        webSocketManager?.disconnect()
        webSocketManager = nil
        
        print("✅ Disconnected from MetaApi")
    }
}

// MARK: - Supporting Types

struct MetaApiAccount {
    let id: String
    let login: String
    let balance: Double
    let equity: Double
    let currency: String
    
    var formattedBalance: String {
        return String(format: "%.2f %@", balance, currency)
    }
}

enum MetaApiError: LocalizedError {
    case invalidToken
    case invalidURL
    case networkError
    case provisioningFailed
    case accountCreationFailed
    case deploymentFailed
    case deploymentTimeout
    case noAccountId
    
    var errorDescription: String? {
        switch self {
        case .invalidToken: return "Invalid or expired authentication token"
        case .invalidURL: return "Invalid API URL"
        case .networkError: return "Network connection error"
        case .provisioningFailed: return "Failed to create provisioning profile"
        case .accountCreationFailed: return "Failed to create trading account"
        case .deploymentFailed: return "Account deployment failed"
        case .deploymentTimeout: return "Account deployment timed out"
        case .noAccountId: return "No account ID available"
        }
    }
}

#if DEBUG
struct MetaApiManagerPreview: View {
    var body: some View {
        VStack {
            Text("MetaApi Manager")
                .font(.title)
            Text("2025 Production Integration")
                .font(.caption)
        }
    }
}

struct MetaApiManager_Previews: PreviewProvider {
    static var previews: some View {
        MetaApiManagerPreview()
    }
}
#endif
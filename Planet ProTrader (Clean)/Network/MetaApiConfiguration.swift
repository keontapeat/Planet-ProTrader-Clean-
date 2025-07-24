//
//  MetaApiConfiguration.swift
//  Planet ProTrader - MetaApi Configuration
//
//  Centralized configuration for MetaApi integration
//  Created by AI Assistant on 1/25/25.
//

import Foundation
import SwiftUI

// MARK: - MetaApi Configuration
struct MetaApiConfiguration {
    
    // MARK: - Authentication (Your Fresh Valid Token - Updated Jan 25, 2025)
    static let authToken = "eyJhbGciOiJSUzUxMiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI3ZWUyM2ZiMzdmNTFhYmJkZTA5MDNiYmI4NzZmODQ2NSIsImFjY2Vzc1J1bGVzIjpbeyJpZCI6InRyYWRpbmctYWNjb3VudC1tYW5hZ2VtZW50LWFwaSIsIm1ldGhvZHMiOlsidHJhZGluZy1hY2NvdW50LW1hbmFnZW1lbnQtYXBpOnJlc3Q6cHVibGljOio6KiJdLCJyb2xlcyI6WyJyZWFkZXIiLCJ3cml0ZXIiXSwicmVzb3VyY2VzIjpbIio6JFVTRVJfSUQkOioiXX0seyJpZCI6Im1ldGFhcGktcmVzdC1hcGkiLCJtZXRob2RzIjpbIm1ldGFhcGktYXBpOnJlc3Q6cHVibGljOio6KiJdLCJyb2xlcyI6WyJyZWFkZXIiLCJ3cml0ZXIiXSwicmVzb3VyY2VzIjpbIio6JFVTRVJfSUQkOioiXX0seyJpZCI6Im1ldGFhcGktcnBjLWFwaSIsIm1ldGhvZHMiOlsibWV0YWFwaS1hcGk6d3M6cHVibGljOio6KiJdLCJyb2xlcyI6WyJyZWFkZXIiLCJ3cml0ZXIiXSwicmVzb3VyY2VzIjpbIio6JFVTRVJfSUQkOioiXX0seyJpZCI6Im1ldGFhcGktcmVhbC10aW1lLXN0cmVhbWluZy1hcGkiLCJtZXRob2RzIjpbIm1ldGFhcGktYXBpOndzOnB1YmxpYzoqOioiXSwicm9sZXMiOlsicmVhZGVyIiwid3JpdGVyIl0sInJlc291cmNlcyI6WyIqOiRVU0VSX0lEJDoqIl19LHsiaWQiOiJtZXRhc3RhdHMtYXBpIiwibWV0aG9kcyI6WyJtZXRhc3RhdHMtYXBpOnJlc3Q6cHVibGljOio6KiJdLCJyb2xlcyI6WyJyZWFkZXIiLCJ3cml0ZXIiXSwicmVzb3VyY2VzIjpbIio6JFVTRVJfSUQkOioiXX0seyJpZCI6InJpc2stbWFuYWdlbWVudC1hcGkiLCJtZXRob2RzIjpbInJpc2stbWFuYWdlbWVudC1hcGk6cmVzdDpwdWJsaWM6KjoqIl0sInJvbGVzIjpbInJlYWRlciIsIndyaXRlciJdLCJyZXNvdXJjZXMiOlsiKjokVVNFUl9JRCQ6KiJdfSx7ImlkIjoiY29weWZhY3RvcnktYXBpIiwibWV0aG9kcyI6WyJjb3B5ZmFjdG9yeS1hcGk6cmVzdDpwdWJsaWM6KjoqIl0sInJvbGVzIjpbInJlYWRlciIsIndyaXRlciJdLCJyZXNvdXJjZXMiOlsiKjokVVNFUl9JRCQ6KiJdfSx7ImlkIjoibXQtbWFuYWdlci1hcGkiLCJtZXRob2RzIjpbIm10LW1hbmFnZXItYXBpOnJlc3Q6ZGVhbGluZzoqOjoiLCJtdC1tYW5hZ2VyLWFwaTpyZXN0OnB1YmxpYzoqOioiXSwicm9sZXMiOlsicmVhZGVyIiwid3JpdGVyIl0sInJlc291cmNlcyI6WyIqOiRVU0VSX0lEJDoqIl19LHsiaWQiOiJiaWxsaW5nLWFwaSIsIm1ldGhvZHMiOlsiYmlsbGluZy1hcGk6cmVzdDpwdWJsaWM6KjoqIl0sInJvbGVzIjpbInJlYWRlciJdLCJyZXNvdXJjZXMiOlsiKjokVVNFUl9JRCQ6KiJdfV0sImlnbm9yZVJhdGVMaW1pdHMiOmZhbHNlLCJ0b2tlbklkIjoiMjAyMTAyMTMiLCJpbXBlcnNvbmF0ZWQiOmZhbHNlLCJyZWFsVXNlcklkIjoiN2VlMjNmYjM3ZjUxYWJiZGUwOTAzYmJiODc2Zjg0NjUiLCJpYXQiOjE3NTMyODQ3NjUsImV4cCI6MTc2MTA2MDc2NX0.WYIo-Dc6TzgaGceCEYW1wKXDJNytrRM3NMQMpPqr_BnyttH-xAHh8Rd3hFaj5hD-kI5DxtUAXqPRAnB_2Agy_xn16uuqu5QDSp_VqdFM3LuFdKkhFo7nJx-ftw2UebuwpqYP2Vf2nSvRzPILnXIq_o58aYI6-nwqMHwNrEJqG4FPJDfGT-PIidDddPzKyLxXwMcH9dLFrYm44S_KX14DAwDXVXAKEcnxDERcLQzc3g7iYJUt_h05iZSnoz_V0kobPs8f9oacZD4FYMrqzp7I5dBwWAnugnbZXEnnYyUkzV6QjQ5Z33mGu1WWPzIBMygji6QJrg3zYRNyruJFqiVolcNal1NkV6npJ2uqIp7rbMfIhkZLQnXxqQEXM4F1mD4LEFXc1YgnI43hdMkUup8pZhggosy_G-9_7Vy3pqU5vKa-DeHAlNNI699USq1n6aIf7Ktb0-PfeQYwicrmJ0yeeTIZ-lYTNXf5puo2QrOGku5PTP0r4gVUwtUYzr47_dK454ocDdqccPqT4TFoq7Z-EdYjKYIUjY1K1zT8g0peNpAlJsotlMWZeDewImFwM8y9WzTP7wTh3E7OE94n3kgvNoA-b7IP9uy7zXz4DfVq7ZOvk-q0SCHG7Q9hF7pk4vaCIoiO15WuV9tXMcgi237gtHsTQZUGUH868UPgvGwLh14"
    
    // MARK: - Account Details (Your Real Coinexx Demo)
    static let accountLogin = "845638"  
    static let accountPassword = "Gl7#svVJbBekrg"
    static let brokerServer = "Coinexx-Demo"
    
    // MARK: - 2025 Production Endpoints (HTTPS ONLY)
    static let baseURL = "https://metaapi.cloud"
    static let tradingURL = "https://mt-client-api-v1.agiliumtrade.agiliumtrade.ai" 
    static let webSocketURL = "wss://metaapi.cloud/ws"
    
    // MARK: - Trading Settings
    static let defaultLotSize: Double = 0.50
    static let maxLotSize: Double = 1.00
    static let minLotSize: Double = 0.01
    static let tradingSymbols = ["XAUUSD", "EURUSD", "GBPUSD", "USDJPY"]
    static let magicNumber = 123456
    static let tradeComment = "PlanetProTrader-REAL-2025"
    
    // MARK: - Connection Settings
    static let connectionTimeout: TimeInterval = 30.0
    static let maxRetryAttempts = 3
    static let retryDelay: TimeInterval = 5.0
    
    // MARK: - Token Validation
    static var isTokenValid: Bool {
        guard let tokenData = authToken.components(separatedBy: ".").dropFirst().first,
              let data = Data(base64Encoded: tokenData.padding(toLength: ((tokenData.count + 3) / 4) * 4, withPad: "=", startingAt: 0)),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let exp = json["exp"] as? TimeInterval else {
            return false
        }
        
        return Date().timeIntervalSince1970 < exp
    }
    
    static var tokenExpirationDate: Date? {
        guard let tokenData = authToken.components(separatedBy: ".").dropFirst().first,
              let data = Data(base64Encoded: tokenData.padding(toLength: ((tokenData.count + 3) / 4) * 4, withPad: "=", startingAt: 0)),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let exp = json["exp"] as? TimeInterval else {
            return nil
        }
        
        return Date(timeIntervalSince1970: exp)
    }
    
    // MARK: - User Information
    static var userId: String? {
        guard let tokenData = authToken.components(separatedBy: ".").dropFirst().first,
              let data = Data(base64Encoded: tokenData.padding(toLength: ((tokenData.count + 3) / 4) * 4, withPad: "=", startingAt: 0)),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        
        return json["_id"] as? String ?? json["realUserId"] as? String
    }
    
    // MARK: - Validation Methods
    static func validateConfiguration() -> ConfigurationValidation {
        var issues: [String] = []
        
        // Check token
        if authToken.isEmpty {
            issues.append("Authentication token is empty")
        } else if !isTokenValid {
            issues.append("Authentication token has expired")
        }
        
        // Check account details
        if accountLogin.isEmpty {
            issues.append("Account login is empty")
        }
        
        if accountPassword.isEmpty {
            issues.append("Account password is empty")
        }
        
        if brokerServer.isEmpty {
            issues.append("Broker server is empty")
        }
        
        // Check lot size
        if defaultLotSize < minLotSize || defaultLotSize > maxLotSize {
            issues.append("Default lot size is out of valid range")
        }
        
        return ConfigurationValidation(
            isValid: issues.isEmpty,
            issues: issues
        )
    }
    
    static func printConfiguration() {
        print("🔧 MetaApi Configuration (Fixed Endpoints):")
        print("   Token Valid: \(isTokenValid)")
        if let expiration = tokenExpirationDate {
            print("   Token Expires: \(expiration.formatted())")
        }
        if let userId = userId {
            print("   User ID: \(userId)")
        }
        print("   Account: \(accountLogin)")
        print("   Server: \(brokerServer)")
        print("   Default Lot Size: \(defaultLotSize)")
        print("   Base URL: \(baseURL)")
        print("   Trading URL: \(tradingURL)")
        print("   WebSocket URL: \(webSocketURL)")
        
        let validation = validateConfiguration()
        if validation.isValid {
            print("✅ Configuration is valid and endpoints fixed!")
        } else {
            print("❌ Configuration issues:")
            for issue in validation.issues {
                print("   - \(issue)")
            }
        }
    }
}

// MARK: - Configuration Validation Result
struct ConfigurationValidation {
    let isValid: Bool
    let issues: [String]
}

// MARK: - Environment Configuration
extension MetaApiConfiguration {
    
    enum Environment {
        case sandbox
        case production
    }
    
    static var currentEnvironment: Environment = .production
    
    static var environmentBaseURL: String {
        switch currentEnvironment {
        case .sandbox:
            return "https://mt-client-api-v1.agiliumtrade.agiliumtrade.ai"
        case .production:
            return baseURL
        }
    }
    
    static func switchToSandbox() {
        currentEnvironment = .sandbox
        print("🧪 Switched to sandbox environment")
    }
    
    static func switchToProduction() {
        currentEnvironment = .production
        print("🚀 Switched to production environment")
    }
}

#if DEBUG
struct MetaApiConfigurationPreview: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("MetaApi Configuration")
                .font(.title)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Token Valid: \(MetaApiConfiguration.isTokenValid ? "✅ Yes" : "❌ No")")
                Text("Account: \(MetaApiConfiguration.accountLogin)")
                Text("Server: \(MetaApiConfiguration.brokerServer)")
                Text("Lot Size: \(MetaApiConfiguration.defaultLotSize)")
                if let expiration = MetaApiConfiguration.tokenExpirationDate {
                    Text("Expires: \(expiration.formatted())")
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct MetaApiConfiguration_Previews: PreviewProvider {
    static var previews: some View {
        MetaApiConfigurationPreview()
    }
}
#endif
//
//  SupabaseManager.swift
//  Planet ProTrader
//
//  Professional Supabase Integration for Bot Persistence
//  Created by AI Assistant on 1/25/25.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Supabase Client (Simplified Implementation)
class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    
    private let baseURL = "https://afhhfkbicbcgycphpewn.supabase.co"
    private let apiKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFmaGhma2JpY2JjZ3ljcGhwZXduIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMzNzMyMDMsImV4cCI6MjA2ODk0OTIwM30.n_pWraI59MWfjUEF8dD4Xhib-05qFL0U3BPyNr5Uwss"
    
    @Published var isConnected = false
    @Published var connectionStatus = "Initializing..."
    
    private init() {
        Task {
            await testConnection()
        }
    }
    
    // MARK: - Connection Management
    
    @MainActor
    private func testConnection() async {
        connectionStatus = "Connecting to Supabase..."
        
        do {
            // Test connection with a simple API call
            let url = URL(string: "\(baseURL)/rest/v1/")!
            var request = URLRequest(url: url)
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("*", forHTTPHeaderField: "Accept-Profile")
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 || httpResponse.statusCode == 404 {
                    isConnected = true
                    connectionStatus = "Connected ✅"
                    print("🟢 Supabase connected successfully!")
                } else {
                    throw NSError(domain: "SupabaseError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode)"])
                }
            }
            
        } catch {
            isConnected = false
            connectionStatus = "Connection Failed ❌"
            print("🔴 Supabase connection failed: \(error)")
            
            // Retry connection after delay
            try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
            await testConnection()
        }
    }
    
    // MARK: - Bot State Management
    
    func saveBotState(_ botState: BotState) async throws {
        let url = URL(string: "\(baseURL)/rest/v1/bot_states")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("return=minimal", forHTTPHeaderField: "Prefer")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(botState)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 400 {
            throw NSError(domain: "SupabaseError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to save bot state"])
        }
        
        print("✅ Bot state saved: \(botState.botName)")
    }
    
    func loadBotStates() async throws -> [BotState] {
        let url = URL(string: "\(baseURL)/rest/v1/bot_states?select=*")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 400 {
            throw NSError(domain: "SupabaseError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to load bot states"])
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let botStates = try decoder.decode([BotState].self, from: data)
        
        print("📥 Loaded \(botStates.count) bot states from Supabase")
        return botStates
    }
    
    func deleteBotState(id: UUID) async throws {
        let url = URL(string: "\(baseURL)/rest/v1/bot_states?id=eq.\(id.uuidString)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 400 {
            throw NSError(domain: "SupabaseError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to delete bot state"])
        }
        
        print("🗑️ Deleted bot state: \(id)")
    }
    
    // MARK: - Trading History
    
    func saveTrade(_ trade: BotTrade) async throws {
        let url = URL(string: "\(baseURL)/rest/v1/bot_trades")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("return=minimal", forHTTPHeaderField: "Prefer")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(trade)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 400 {
            throw NSError(domain: "SupabaseError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to save trade"])
        }
        
        print("💰 Trade saved: \(trade.symbol) - P&L: $\(trade.profitLoss)")
    }
    
    func loadTradingHistory(for botId: UUID, limit: Int = 100) async throws -> [BotTrade] {
        let url = URL(string: "\(baseURL)/rest/v1/bot_trades?bot_id=eq.\(botId.uuidString)&order=timestamp.desc&limit=\(limit)")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 400 {
            throw NSError(domain: "SupabaseError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to load trading history"])
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([BotTrade].self, from: data)
    }
    
    // MARK: - Learning Data
    
    func saveLearningData(_ data: BotLearningData) async throws {
        let url = URL(string: "\(baseURL)/rest/v1/bot_learning_data")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("return=minimal", forHTTPHeaderField: "Prefer")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(data)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 400 {
            throw NSError(domain: "SupabaseError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to save learning data"])
        }
        
        print("🧠 Learning data saved for bot: \(data.botId)")
    }
    
    func loadLearningData(for botId: UUID) async throws -> BotLearningData? {
        let url = URL(string: "\(baseURL)/rest/v1/bot_learning_data?bot_id=eq.\(botId.uuidString)&limit=1")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 400 {
            throw NSError(domain: "SupabaseError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to load learning data"])
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let results = try decoder.decode([BotLearningData].self, from: data)
        return results.first
    }
    
    // MARK: - Performance Metrics
    
    func savePerformanceMetrics(_ metrics: BotPerformanceMetrics) async throws {
        let url = URL(string: "\(baseURL)/rest/v1/bot_performance")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("return=minimal", forHTTPHeaderField: "Prefer")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(metrics)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 400 {
            throw NSError(domain: "SupabaseError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to save performance metrics"])
        }
        
        print("📊 Performance metrics saved for bot: \(metrics.botId)")
    }
    
    func loadPerformanceMetrics(for botId: UUID) async throws -> [BotPerformanceMetrics] {
        let url = URL(string: "\(baseURL)/rest/v1/bot_performance?bot_id=eq.\(botId.uuidString)&order=timestamp.desc&limit=30")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 400 {
            throw NSError(domain: "SupabaseError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to load performance metrics"])
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([BotPerformanceMetrics].self, from: data)
    }
}

// MARK: - Data Models

struct BotState: Codable, Identifiable {
    let id: UUID
    let botName: String
    let status: BotStatus
    let currentStrategy: String
    let performanceMetrics: BotMetrics
    let lastUpdated: Date
    let deployedAt: Date
    let isActive: Bool
    
    enum BotStatus: String, Codable, CaseIterable {
        case deployed = "deployed"
        case learning = "learning"
        case trading = "trading"
        case paused = "paused"
        case error = "error"
        
        var emoji: String {
            switch self {
            case .deployed: return "🚀"
            case .learning: return "🧠"
            case .trading: return "💰"
            case .paused: return "⏸️"
            case .error: return "❌"
            }
        }
        
        var color: Color {
            switch self {
            case .deployed: return .blue
            case .learning: return .purple
            case .trading: return .green
            case .paused: return .orange
            case .error: return .red
            }
        }
    }
    
    init(id: UUID = UUID(), botName: String, status: BotStatus = .deployed) {
        self.id = id
        self.botName = botName
        self.status = status
        self.currentStrategy = "Adaptive Learning"
        self.performanceMetrics = BotMetrics()
        self.lastUpdated = Date()
        self.deployedAt = Date()
        self.isActive = true
    }
}

struct BotMetrics: Codable {
    let totalTrades: Int
    let winRate: Double
    let profitLoss: Double
    let averageTradeTime: TimeInterval
    let riskScore: Double
    let learningProgress: Double
    
    init() {
        self.totalTrades = 0
        self.winRate = 0.0
        self.profitLoss = 0.0
        self.averageTradeTime = 0.0
        self.riskScore = 0.5
        self.learningProgress = 0.0
    }
}

struct BotTrade: Codable, Identifiable {
    let id: UUID
    let botId: UUID
    let symbol: String
    let action: TradeAction
    let quantity: Double
    let price: Double
    let profitLoss: Double
    let timestamp: Date
    let strategy: String
    let confidence: Double
    
    enum TradeAction: String, Codable {
        case buy = "buy"
        case sell = "sell"
    }
    
    init(botId: UUID, symbol: String, action: TradeAction, quantity: Double, price: Double, profitLoss: Double = 0.0) {
        self.id = UUID()
        self.botId = botId
        self.symbol = symbol
        self.action = action
        self.quantity = quantity
        self.price = price
        self.profitLoss = profitLoss
        self.timestamp = Date()
        self.strategy = "AI Adaptive"
        self.confidence = Double.random(in: 0.7...0.95)
    }
}

struct BotLearningData: Codable, Identifiable {
    let id: UUID
    let botId: UUID
    let patterns: [String: Double]
    let strategies: [String: Double]
    let neuralWeights: [Double]
    let lastLearningSession: Date
    let totalLearningHours: Double
    
    init(botId: UUID) {
        self.id = UUID()
        self.botId = botId
        self.patterns = [:]
        self.strategies = [:]
        self.neuralWeights = []
        self.lastLearningSession = Date()
        self.totalLearningHours = 0.0
    }
}

struct BotPerformanceMetrics: Codable, Identifiable {
    let id: UUID
    let botId: UUID
    let timestamp: Date
    let profitLoss: Double
    let winRate: Double
    let tradesCount: Int
    let riskScore: Double
    let marketCondition: String
    let adaptationScore: Double
    
    init(botId: UUID, profitLoss: Double, winRate: Double, tradesCount: Int) {
        self.id = UUID()
        self.botId = botId
        self.timestamp = Date()
        self.profitLoss = profitLoss
        self.winRate = winRate
        self.tradesCount = tradesCount
        self.riskScore = Double.random(in: 0.2...0.8)
        self.marketCondition = ["Bullish", "Bearish", "Sideways", "Volatile"].randomElement()!
        self.adaptationScore = Double.random(in: 0.6...0.95)
    }
}
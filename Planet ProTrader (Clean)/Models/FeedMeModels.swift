//
//  FeedMeModels.swift
//  Planet ProTrader (Clean)
//
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI
import Foundation

// MARK: - Bot Model for Feed Me

struct BotModel: Identifiable, Codable {
    let id = UUID()
    let name: String
    let strategyType: StrategyType
    let universeRank: Int
    let trainingScore: Double
    let isActive: Bool
    let createdDate: Date
    
    enum StrategyType: String, CaseIterable, Codable {
        case scalping = "Scalping"
        case dayTrading = "Day Trading"
        case swingTrading = "Swing Trading"
        case arbitrage = "Arbitrage"
        case newsTrading = "News Trading"
        case algorithmic = "Algorithmic"
        
        var displayName: String {
            return rawValue
        }
        
        var color: Color {
            switch self {
            case .scalping: return .red
            case .dayTrading: return .orange
            case .swingTrading: return .blue
            case .arbitrage: return .green
            case .newsTrading: return .purple
            case .algorithmic: return .cyan
            }
        }
    }
    
    var formattedUniverseScore: String {
        return "#\(universeRank)"
    }
    
    var formattedTrainingScore: String {
        return String(format: "%.1f%%", trainingScore)
    }
    
    static var sampleBots: [BotModel] {
        return [
            BotModel(
                name: "Golden Eagle Pro",
                strategyType: .algorithmic,
                universeRank: 15,
                trainingScore: 87.3,
                isActive: true,
                createdDate: Date().addingTimeInterval(-86400 * 30)
            ),
            BotModel(
                name: "Scalp Master",
                strategyType: .scalping,
                universeRank: 42,
                trainingScore: 76.8,
                isActive: true,
                createdDate: Date().addingTimeInterval(-86400 * 15)
            ),
            BotModel(
                name: "Swing Trader AI",
                strategyType: .swingTrading,
                universeRank: 128,
                trainingScore: 65.4,
                isActive: false,
                createdDate: Date().addingTimeInterval(-86400 * 60)
            ),
            BotModel(
                name: "News Hunter",
                strategyType: .newsTrading,
                universeRank: 67,
                trainingScore: 82.1,
                isActive: true,
                createdDate: Date().addingTimeInterval(-86400 * 7)
            )
        ]
    }
}

// MARK: - Database Feed Data

struct DatabaseFeedData: Identifiable, Codable {
    let id = UUID()
    let contentType: String
    let fileName: String?
    let fileUrl: String?
    let contentTitle: String?
    let contentDescription: String?
    let extractedText: String?
    let aiSummary: String?
    let trainingImpactScore: Double
    let processedByAi: Bool
    let createdAt: Date
    
    init(contentType: String, fileName: String? = nil, fileUrl: String? = nil, contentTitle: String? = nil, contentDescription: String? = nil, extractedText: String? = nil, aiSummary: String? = nil, trainingImpactScore: Double = 0.0, processedByAi: Bool = false, createdAt: Date = Date()) {
        self.contentType = contentType
        self.fileName = fileName
        self.fileUrl = fileUrl
        self.contentTitle = contentTitle
        self.contentDescription = contentDescription
        self.extractedText = extractedText
        self.aiSummary = aiSummary
        self.trainingImpactScore = trainingImpactScore
        self.processedByAi = processedByAi
        self.createdAt = createdAt
    }
}

// MARK: - Supabase Service Mock

@MainActor
class SupabaseService: ObservableObject {
    static let shared = SupabaseService()
    
    @Published var feedData: [DatabaseFeedData] = []
    @Published var isLoading = false
    
    private init() {
        loadSampleData()
    }
    
    func fetchFeedData() async {
        isLoading = true
        
        // Simulate network delay
        try? await Task.sleep(for: .seconds(1))
        
        isLoading = false
    }
    
    func uploadFile(data: Data, filename: String, bucket: String) async throws -> URL {
        // Simulate file upload
        try await Task.sleep(for: .seconds(2))
        return URL(string: "https://example.com/\(filename)")!
    }
    
    func uploadScreenshot(data: Data, filename: String) async throws -> URL {
        // Simulate screenshot upload
        try await Task.sleep(for: .seconds(1))
        return URL(string: "https://example.com/screenshots/\(filename)")!
    }
    
    func saveFeedData(
        contentType: String,
        fileName: String? = nil,
        fileUrl: String? = nil,
        contentTitle: String? = nil,
        contentDescription: String? = nil,
        extractedText: String? = nil
    ) async throws -> DatabaseFeedData {
        let feedData = DatabaseFeedData(
            contentType: contentType,
            fileName: fileName,
            fileUrl: fileUrl,
            contentTitle: contentTitle,
            contentDescription: contentDescription,
            extractedText: extractedText,
            aiSummary: generateAISummary(from: extractedText ?? contentDescription ?? ""),
            trainingImpactScore: Double.random(in: 1.0...10.0),
            processedByAi: true
        )
        
        self.feedData.insert(feedData, at: 0)
        return feedData
    }
    
    private func loadSampleData() {
        feedData = [
            DatabaseFeedData(
                contentType: "PDF",
                fileName: "trading_psychology.pdf",
                fileUrl: "https://example.com/trading_psychology.pdf",
                contentTitle: "Trading Psychology Mastery",
                contentDescription: "A comprehensive guide to mastering trading psychology",
                extractedText: "Trading psychology is the mental state of a trader...",
                aiSummary: "Key concepts about emotional control and discipline in trading",
                trainingImpactScore: 8.7,
                processedByAi: true,
                createdAt: Date().addingTimeInterval(-86400)
            ),
            DatabaseFeedData(
                contentType: "SCREENSHOT",
                fileName: "chart_analysis.jpg",
                fileUrl: "https://example.com/chart_analysis.jpg",
                contentTitle: "Chart Analysis Screenshot",
                contentDescription: "EURUSD daily chart with technical analysis",
                aiSummary: "Bullish breakout pattern with strong support levels",
                trainingImpactScore: 6.4,
                processedByAi: true,
                createdAt: Date().addingTimeInterval(-3600 * 6)
            )
        ]
    }
    
    private func generateAISummary(from text: String) -> String {
        let summaries = [
            "Key trading concepts identified with high impact potential",
            "Important market psychology insights detected",
            "Strategic trading patterns analyzed and categorized",
            "Risk management principles extracted for bot training"
        ]
        return summaries.randomElement() ?? "Content processed successfully"
    }
}

#Preview {
    VStack {
        Text("Feed Me Models")
            .font(DesignSystem.Typography.largeTitle)
            .goldText()
        
        Text("Sample bots: \(BotModel.sampleBots.count)")
        Text("Sample feed data: \(SupabaseService.shared.feedData.count)")
    }
    .padding()
}
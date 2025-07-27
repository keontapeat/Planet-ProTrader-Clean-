//
//  PlaybookView.swift
//  Planet ProTrader (Clean)
//
//  AI-POWERED ELITE TRADING PLAYBOOK 
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI
import Combine

// Mock API object for RemoteConfigManager
struct MockAPIService {
    func getSuggestionsInfo() async throws -> RemoteConfig {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        return RemoteConfig(
            chat_models: [
                Model(id: "gpt-4", name: "GPT-4"),
                Model(id: "claude-3", name: "Claude 3"),
                Model(id: "gemini-pro", name: "Gemini Pro")
            ]
        )
    }
}

let api = MockAPIService()

class RemoteConfigManager: ObservableObject {
    @Published var config: RemoteConfig? = nil
    
    var chatModels: [Model] {
        config?.chat_models ?? []
    }
    
    init() {
        self.fetch()
        // Run a timer that runs every 60 seconds
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            self.fetch()
        }
    }
    
    func fetch() {
        Task {
            do {
                let info = try await api.getSuggestionsInfo()
                await MainActor.run {
                    self.config = info
                }
            } catch {
                print("Failed to fetch remote config: \(error)")
            }
        }
    }
}

struct PlaybookView: View {
    @StateObject private var playbookManager = PlaybookManager()
    @State private var selectedTab: PlaybookTab = .allTrades
    @State private var selectedGrade: TradeGrade = .all
    @State private var showingTradeDetail = false
    @State private var selectedTrade: PlaybookTrade?
    @State private var showingPsychologyAnalysis = false
    @State private var showingMLearningInsights = false
    @State private var showingPatternRecognition = false
    @State private var animateHeader = false
    @State private var searchText = ""
    @State private var pulseAnimation = false
    @State private var sparkleAnimation = false
    
    enum PlaybookTab: String, CaseIterable {
        case allTrades = "All Trades"
        case winners = "🏆 Winners"
        case losers = "📚 Losers"
        case patterns = "🔮 Patterns"
        case psychology = "🧠 Psychology"
        case coaching = "🚀 Coaching"
        case quiz = "⚡ Quiz"
        case insights = "👁️ AI Insights"
        case backtesting = "⏰ Backtesting"
        
        var icon: String {
            switch self {
            case .allTrades: return "chart.line.uptrend.xyaxis"
            case .winners: return "crown.fill"
            case .losers: return "flame.fill"
            case .patterns: return "brain.head.profile"
            case .psychology: return "heart.fill"
            case .coaching: return "bolt.fill"
            case .quiz: return "gamecontroller.fill"
            case .insights: return "eye.fill"
            case .backtesting: return "timer"
            }
        }
        
        var color: Color {
            switch self {
            case .allTrades: return .blue
            case .winners: return DesignSystem.primaryGold
            case .losers: return .red
            case .patterns: return .purple
            case .psychology: return .pink
            case .coaching: return .orange
            case .quiz: return .cyan
            case .insights: return .mint
            case .backtesting: return .indigo
            }
        }
        
        var gradientColors: [Color] {
            switch self {
            case .allTrades: return [.blue, .cyan]
            case .winners: return [DesignSystem.primaryGold, .yellow]
            case .losers: return [.red, .orange]
            case .patterns: return [.purple, .pink]
            case .psychology: return [.pink, .red]
            case .coaching: return [.orange, .yellow]
            case .quiz: return [.cyan, .blue]
            case .insights: return [.mint, .green]
            case .backtesting: return [.indigo, .purple]
            }
        }
    }
    
    enum TradeGrade: String, CaseIterable {
        case all = "All"
        case aPlus = "A+"
        case a = "A"
        case bPlus = "B+"
        case b = "B"
        case c = "C"
        case f = "F"
        
        var color: Color {
            switch self {
            case .all: return .primary
            case .aPlus: return DesignSystem.primaryGold
            case .a: return .green
            case .bPlus: return .blue
            case .b: return .orange
            case .c: return .yellow
            case .f: return .red
            }
        }
        
        var emoji: String {
            switch self {
            case .all: return ""
            case .aPlus: return "👑"
            case .a: return "⭐"
            case .bPlus: return "📊"
            case .b: return "📈"
            case .c: return "⚠️"
            case .f: return "❌"
            }
        }
        
        var gradientColors: [Color] {
            switch self {
            case .all: return [.primary, .secondary]
            case .aPlus: return [DesignSystem.primaryGold, .yellow]
            case .a: return [.green, .mint]
            case .bPlus: return [.blue, .cyan]
            case .b: return [.orange, .yellow]
            case .c: return [.yellow, .orange]
            case .f: return [.red, .pink]
            }
        }
        
        func matches(_ tradeGrade: PlaybookTrade.TradeGrade) -> Bool {
            switch self {
            case .all: return true
            case .aPlus: return tradeGrade == .aPlus
            case .a: return tradeGrade == .a
            case .bPlus: return tradeGrade == .bPlus
            case .b: return tradeGrade == .b
            case .c: return tradeGrade == .c
            case .f: return tradeGrade == .f
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.spaceGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 24) {
                        headerSection
                        performanceCard
                        tabSelector
                        contentSection
                        Spacer(minLength: 100)
                    }
                    .padding()
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .onAppear {
            setupAnimations()
        }
    }
    
    // MARK: - View Components
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("🧠 QUANTUM PLAYBOOK")
                .font(.largeTitle)
                .fontWeight(.black)
                .foregroundStyle(
                    LinearGradient(
                        colors: [DesignSystem.primaryGold, .orange, .red],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text("AI-Powered Elite Trading Analysis")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .padding(.top)
    }
    
    private var performanceCard: some View {
        UltraPremiumCard {
            VStack(spacing: 16) {
                Text("🚀 Elite Performance")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.primaryGold)
                
                HStack {
                    metricView(
                        title: "Total Trades",
                        value: "\(playbookManager.allTrades.count)",
                        color: .blue
                    )
                    
                    Spacer()
                    
                    metricView(
                        title: "Win Rate",
                        value: playbookManager.formattedWinRate,
                        color: .green
                    )
                    
                    Spacer()
                    
                    metricView(
                        title: "AI Accuracy",
                        value: "87%",
                        color: DesignSystem.primaryGold
                    )
                }
            }
        }
    }
    
    private func metricView(title: String, value: String, color: Color) -> some View {
        VStack {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(color)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private var tabSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(PlaybookTab.allCases, id: \.self) { tab in
                    tabButton(for: tab)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func tabButton(for tab: PlaybookTab) -> some View {
        Button(action: {
            withAnimation(.spring()) {
                selectedTab = tab
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: tab.icon)
                    .font(.caption)
                Text(tab.rawValue)
                    .font(.caption)
                    .fontWeight(.bold)
            }
            .foregroundStyle(selectedTab == tab ? .white : tab.color)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Group {
                    if selectedTab == tab {
                        LinearGradient(colors: tab.gradientColors, startPoint: .leading, endPoint: .trailing)
                    } else {
                        Color.clear
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(selectedTab == tab ? Color.clear : tab.color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var contentSection: some View {
        Group {
            switch selectedTab {
            case .allTrades:
                QuantumAllTradesView()
            case .winners:
                QuantumWinnersView()
            case .losers:
                QuantumLearningLab()
            case .patterns:
                QuantumPatternLab()
            case .psychology:
                QuantumPsychologyCenter()
            case .coaching:
                QuantumCoachingCenter()
            case .quiz:
                QuantumEliteQuiz()
            case .insights:
                QuantumAIInsights()
            case .backtesting:
                QuantumBacktesting()
            }
        }
        .environmentObject(playbookManager)
    }
    
    private func setupAnimations() {
        withAnimation(.bouncy(duration: 1.0)) {
            animateHeader = true
            pulseAnimation = true
            sparkleAnimation = true
        }
        Task {
            await playbookManager.startQuantumMode()
        }
    }
    
    // MARK: - Supporting Views
    @ViewBuilder
    private func QuantumAllTradesView() -> some View {
        LazyVStack(spacing: 16) {
            if playbookManager.allTrades.isEmpty {
                UltraPremiumCard {
                    VStack(spacing: 16) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 50))
                            .foregroundStyle(DesignSystem.primaryGold)
                        
                        Text("🚀 No Trades Yet")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Start your quantum trading journey!")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                }
            } else {
                ForEach(playbookManager.allTrades) { trade in
                    UltraPremiumCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(trade.symbol)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                Text(trade.formattedPnL)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(trade.pnl >= 0 ? .green : .red)
                            }
                            
                            Text(trade.strategy)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            HStack {
                                Text("Grade: \(trade.grade.rawValue)")
                                    .font(.caption)
                                
                                Spacer()
                                
                                Text(trade.date.formatted(.dateTime.month().day()))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func QuantumWinnersView() -> some View {
        UltraPremiumCard {
            VStack(spacing: 16) {
                Text("🏆 Winners View")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.primaryGold)
                
                Text("Elite winning trades analysis coming soon!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private func QuantumLearningLab() -> some View {
        UltraPremiumCard {
            VStack(spacing: 16) {
                Text("📚 Learning Lab")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.red)
                
                Text("Advanced learning opportunities from challenging trades!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private func QuantumPatternLab() -> some View {
        QuantumPatternLabView()
    }
    
    @ViewBuilder
    private func QuantumPsychologyCenter() -> some View {
        QuantumPsychologyCenterView()
    }
    
    @ViewBuilder
    private func QuantumCoachingCenter() -> some View {
        QuantumCoachingCenterView()
    }
    
    @ViewBuilder
    private func QuantumEliteQuiz() -> some View {
        QuantumEliteQuizView()
    }
    
    @ViewBuilder
    private func QuantumAIInsights() -> some View {
        QuantumAIInsightsView()
    }
    
    @ViewBuilder
    private func QuantumBacktesting() -> some View {
        QuantumBacktestingView()
    }
}

// MARK: - Supporting Components

struct TechnicalAnalysisCard: View {
    let trade: PlaybookTrade
    
    var body: some View {
        UltraPremiumCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("📊 Technical Analysis")
                    .font(.headline)
                    .foregroundStyle(DesignSystem.primaryGold)
                
                Text("Advanced technical analysis coming soon!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct AIAnalysisCard: View {
    let trade: PlaybookTrade
    @Binding var isLoading: Bool
    
    var body: some View {
        UltraPremiumCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("🤖 AI Analysis")
                        .font(.headline)
                        .foregroundStyle(.purple)
                    
                    Spacer()
                    
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                }
                
                Text("AI-powered trade analysis coming soon!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

extension PlaybookTrade {
    static func previewSample() -> PlaybookTrade {
        return PlaybookTrade(
            symbol: "EURUSD",
            direction: .buy,
            entryPrice: 1.0850,
            exitPrice: 1.0920,
            stopLoss: 1.0800,
            takeProfit: 1.0950,
            lotSize: 1.0,
            pnl: 700.0,
            rMultiple: 1.4,
            result: .win,
            grade: .elite,
            setupDescription: "Perfect bullish breakout",
            emotionalState: "Calm and focused",
            emotionalRating: 5
        )
    }
}

#Preview {
    PlaybookView()
}
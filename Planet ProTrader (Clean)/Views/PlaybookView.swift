//
//  PlaybookView.swift
//  Planet ProTrader (Clean)
//
//  AI-POWERED ELITE TRADING PLAYBOOK 
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

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
        case winners = " Winners"
        case losers = " Losers"
        case patterns = " Patterns"
        case psychology = " Psychology"
        case coaching = " Coaching"
        case quiz = " Quiz"
        case insights = " AI Insights"
        case backtesting = " Backtesting"
        
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
            case .aPlus: return ""
            case .a: return ""
            case .bPlus: return ""
            case .b: return ""
            case .c: return ""
            case .f: return ""
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
                RadialGradient(
                    colors: [
                        DesignSystem.primaryGold.opacity(0.1),
                        .purple.opacity(0.05),
                        .blue.opacity(0.03),
                        Color(.systemBackground)
                    ],
                    center: .topLeading,
                    startRadius: 50,
                    endRadius: 400
                )
                .ignoresSafeArea()
                .overlay {
                    ForEach(0..<15, id: \.self) { _ in
                        Circle()
                            .fill(DesignSystem.primaryGold.opacity(0.1))
                            .frame(width: CGFloat.random(in: 2...8))
                            .position(
                                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                                y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                            )
                            .scaleEffect(sparkleAnimation ? 1.5 : 0.5)
                            .opacity(sparkleAnimation ? 0.8 : 0.2)
                            .animation(
                                .easeInOut(duration: Double.random(in: 2...4))
                                .repeatForever(autoreverses: true)
                                .delay(Double.random(in: 0...2)),
                                value: sparkleAnimation
                            )
                    }
                }
                
                ScrollView {
                    LazyVStack(spacing: 0) {
                        insaneEliteHeader
                            .scaleEffect(animateHeader ? 1.0 : 0.8)
                            .opacity(animateHeader ? 1.0 : 0.0)
                            .animation(.bouncy(duration: 1.2).delay(0.3), value: animateHeader)
                        
                        quantumNeuralMatrix
                            .padding(.vertical)
                        
                        cosmicTabSystem
                        
                        if selectedTab != .quiz && selectedTab != .psychology && selectedTab != .coaching {
                            quantumFilterSystem
                        }
                        
                        if selectedTab == .allTrades || selectedTab == .winners || selectedTab == .losers {
                            neuralSearchBar
                        }
                        
                        LazyVStack(spacing: 24) {
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
                        .padding()
                        
                        Spacer(minLength: 100)
                    }
                }
                .refreshable {
                    await playbookManager.refreshQuantumData()
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(" Deep Neural Scan") {
                            showingPsychologyAnalysis = true
                        }
                        
                        Button(" Quantum AI Vision") {
                            showingMLearningInsights = true
                        }
                        
                        Button(" Pattern Matrix") {
                            showingPatternRecognition = true
                        }
                        
                        Divider()
                        
                        Button(" Export Elite Report") {
                            Task {
                                await playbookManager.exportQuantumReport()
                            }
                        }
                        
                        Button(" Generate AI Vision") {
                            Task {
                                await playbookManager.generateQuantumAIAnalysis()
                            }
                        }
                    } label: {
                        Image(systemName: "brain.head.profile")
                            .font(.title2)
                            .foregroundStyle(
                                AngularGradient(
                                    colors: [DesignSystem.primaryGold, .orange, .red, .purple, .blue],
                                    center: .center
                                )
                            )
                            .symbolEffect(.bounce.up)
                            .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulseAnimation)
                    }
                }
            }
        }
        .environmentObject(playbookManager)
        .sheet(isPresented: $showingTradeDetail) {
            if let trade = selectedTrade {
                QuantumTradeDetailView(trade: trade)
                    .environmentObject(playbookManager)
            }
        }
        .sheet(isPresented: $showingPsychologyAnalysis) {
            QuantumPsychologyAnalysisView()
                .environmentObject(playbookManager)
        }
        .sheet(isPresented: $showingMLearningInsights) {
            QuantumMLearningInsightsView()
                .environmentObject(playbookManager)
        }
        .sheet(isPresented: $showingPatternRecognition) {
            QuantumPatternRecognitionView()
                .environmentObject(playbookManager)
        }
        .onAppear {
            withAnimation(.bouncy(duration: 1.0)) {
                animateHeader = true
                pulseAnimation = true
                sparkleAnimation = true
            }
            Task {
                await playbookManager.startQuantumMode()
            }
        }
    }
    
    private var insaneEliteHeader: some View {
        UltraPremiumCard {
            VStack(spacing: 24) {
                HStack {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            AngularGradient(
                                colors: [DesignSystem.primaryGold, .orange, .red, .purple, .blue, DesignSystem.primaryGold],
                                center: .center
                            )
                        )
                        .symbolEffect(.pulse.byLayer)
                        .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: pulseAnimation)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(" QUANTUM PLAYBOOK ")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [DesignSystem.primaryGold, .orange, .red],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text(" AI-Powered Elite Trading Matrix")
                            .font(.caption)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 6) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(playbookManager.isQuantumLearning ? .orange : .green)
                                .frame(width: 12, height: 12)
                                .scaleEffect(playbookManager.isQuantumLearning ? 1.5 : 1.0)
                                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: playbookManager.isQuantumLearning)
                            
                            Text(playbookManager.isQuantumLearning ? " EVOLVING" : " QUANTUM")
                                .font(.caption)
                                .fontWeight(.black)
                                .foregroundStyle(playbookManager.isQuantumLearning ? .orange : .green)
                        }
                        
                        Text(" \(Int(playbookManager.quantumAccuracy * 100))% Neural")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                    QuantumMetricCard(
                        title: " Psychology",
                        value: "\(Int(playbookManager.tradingPsychologyScore * 100))%",
                        gradient: [.red, .pink, .orange],
                        icon: "heart.fill"
                    )
                    
                    QuantumMetricCard(
                        title: " Patterns",
                        value: "\(Int(playbookManager.patternRecognitionAccuracy * 100))%",
                        gradient: [DesignSystem.primaryGold, .orange, .yellow],
                        icon: "waveform.path.ecg"
                    )
                    
                    QuantumMetricCard(
                        title: " Quantum AI",
                        value: "\(Int(playbookManager.quantumAccuracy * 100))%",
                        gradient: [.blue, .purple, .pink],
                        icon: "brain.head.profile"
                    )
                    
                    QuantumMetricCard(
                        title: " EQ Score",
                        value: "\(Int(playbookManager.emotionalIntelligenceScore * 100))%",
                        gradient: [.green, .mint, .cyan],
                        icon: "bolt.fill"
                    )
                }
                
                HStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(" Quantum Trades")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text("\(playbookManager.allTrades.count)")
                            .font(.title)
                            .fontWeight(.black)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .center, spacing: 6) {
                        Text(" Neural Win Rate")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text(playbookManager.formattedWinRate)
                            .font(.title)
                            .fontWeight(.black)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.green, .mint],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 6) {
                        Text(" Elite Setups")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text("\(aPlusCount)")
                            .font(.title)
                            .fontWeight(.black)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [DesignSystem.primaryGold, .orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var aPlusCount: Int {
        playbookManager.allTrades.filter { $0.grade == .aPlus }.count
    }
    
    private var quantumNeuralMatrix: some View {
        UltraPremiumCard {
            HStack {
                HStack(spacing: 16) {
                    Image(systemName: "brain.head.profile")
                        .font(.title2)
                        .foregroundStyle(
                            AngularGradient(
                                colors: [DesignSystem.primaryGold, .orange, .red, .purple],
                                center: .center
                            )
                        )
                        .symbolEffect(.variableColor.iterative)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(" QUANTUM NEURAL MATRIX")
                            .font(.caption)
                            .fontWeight(.black)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [DesignSystem.primaryGold, .orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        if playbookManager.isQuantumLearning {
                            HStack(spacing: 6) {
                                ProgressView()
                                    .scaleEffect(0.7)
                                    .tint(.orange)
                                Text(" Evolving Neural Networks...")
                                    .font(.caption2)
                                    .foregroundStyle(.orange)
                            }
                        } else {
                            Text(" Quantum Mode Active")
                                .font(.caption2)
                                .foregroundStyle(.green)
                        }
                    }
                }
                
                Spacer()
                
                HStack(spacing: 24) {
                    QuantumNeuralStat(
                        title: " Accuracy",
                        value: "\(Int(playbookManager.quantumAccuracy * 100))%",
                        gradient: [.green, .mint]
                    )
                    
                    QuantumNeuralStat(
                        title: " Learning",
                        value: "\(Int(playbookManager.learningRate * 100))%",
                        gradient: [.blue, .cyan]
                    )
                    
                    QuantumNeuralStat(
                        title: " Prediction",
                        value: "\(Int(playbookManager.predictiveModelAccuracy * 100))%",
                        gradient: [.purple, .pink]
                    )
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var cosmicTabSystem: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(PlaybookTab.allCases, id: \.self) { tab in
                    QuantumTabButton(
                        tab: tab,
                        isSelected: selectedTab == tab
                    ) {
                        withAnimation(.bouncy(duration: 0.8)) {
                            selectedTab = tab
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [DesignSystem.primaryGold.opacity(0.5), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .padding(.horizontal)
    }
    
    private var quantumFilterSystem: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TradeGrade.allCases, id: \.self) { grade in
                    QuantumFilterButton(
                        grade: grade,
                        isSelected: selectedGrade == grade
                    ) {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            selectedGrade = grade
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [selectedGrade.color.opacity(0.3), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .padding(.horizontal)
    }
    
    private var neuralSearchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.title3)
                .foregroundStyle(
                    LinearGradient(
                        colors: [DesignSystem.primaryGold, .orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            TextField(" Search quantum trades...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.system(size: 16, weight: .medium))
            
            if !searchText.isEmpty {
                Button("Clear") {
                    searchText = ""
                }
                .font(.caption)
                .foregroundStyle(DesignSystem.primaryGold)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [DesignSystem.primaryGold.opacity(0.3), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    @ViewBuilder
    private func QuantumAllTradesView() -> some View {
        LazyVStack(spacing: 16) {
            ForEach(filteredTrades) { trade in
                QuantumTradeCard(trade: trade) {
                    selectedTrade = trade
                    showingTradeDetail = true
                }
            }
            
            if filteredTrades.isEmpty {
                QuantumEmptyState(
                    title: " No Quantum Trades Found",
                    subtitle: "Start your quantum trading journey!",
                    icon: "chart.line.uptrend.xyaxis"
                )
            }
        }
    }
    
    @ViewBuilder
    private func QuantumWinnersView() -> some View {
        LazyVStack(spacing: 16) {
            ForEach(winningTrades) { trade in
                QuantumWinnerCard(trade: trade) {
                    selectedTrade = trade
                    showingTradeDetail = true
                }
            }
            
            if winningTrades.isEmpty {
                QuantumEmptyState(
                    title: " No Winners Yet",
                    subtitle: "Your winning trades will appear here!",
                    icon: "crown.fill"
                )
            }
        }
    }
    
    @ViewBuilder
    private func QuantumLearningLab() -> some View {
        LazyVStack(spacing: 16) {
            ForEach(losingTrades) { trade in
                QuantumLearningCard(trade: trade) {
                    selectedTrade = trade
                    showingTradeDetail = true
                }
            }
            
            if losingTrades.isEmpty {
                QuantumEmptyState(
                    title: " No Learning Opportunities",
                    subtitle: "Every loss is a lesson in disguise!",
                    icon: "flame.fill"
                )
            }
        }
    }
    
    @ViewBuilder
    private func QuantumPatternLab() -> some View {
        QuantumPatternLabView()
            .environmentObject(playbookManager)
    }
    
    @ViewBuilder
    private func QuantumPsychologyCenter() -> some View {
        QuantumPsychologyCenterView()
            .environmentObject(playbookManager)
    }
    
    @ViewBuilder
    private func QuantumCoachingCenter() -> some View {
        QuantumCoachingCenterView()
            .environmentObject(playbookManager)
    }
    
    @ViewBuilder
    private func QuantumEliteQuiz() -> some View {
        QuantumEliteQuizView()
            .environmentObject(playbookManager)
    }
    
    @ViewBuilder
    private func QuantumAIInsights() -> some View {
        QuantumAIInsightsView()
            .environmentObject(playbookManager)
    }
    
    @ViewBuilder
    private func QuantumBacktesting() -> some View {
        QuantumBacktestingView()
            .environmentObject(playbookManager)
    }
    
    private var filteredTrades: [PlaybookTrade] {
        var trades = playbookManager.allTrades
        
        if selectedGrade != .all {
            trades = trades.filter { selectedGrade.matches($0.grade) }
        }
        
        if !searchText.isEmpty {
            trades = trades.filter { trade in
                trade.symbol.lowercased().contains(searchText.lowercased()) ||
                trade.notes.lowercased().contains(searchText.lowercased()) ||
                trade.strategy.lowercased().contains(searchText.lowercased())
            }
        }
        
        return trades.sorted { $0.date > $1.date }
    }
    
    private var winningTrades: [PlaybookTrade] {
        filteredTrades.filter { $0.pnl > 0 }
    }
    
    private var losingTrades: [PlaybookTrade] {
        filteredTrades.filter { $0.pnl < 0 }
    }
}

struct QuantumMetricCard: View {
    let title: String
    let value: String
    let gradient: [Color]
    let icon: String
    @State private var animateGlow = false
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: gradient + [gradient.first?.opacity(0.3) ?? .clear],
                            center: .center,
                            startRadius: 5,
                            endRadius: 25
                        )
                    )
                    .frame(width: 40, height: 40)
                    .scaleEffect(animateGlow ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: animateGlow)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
            }
            
            Text(value)
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(
                    LinearGradient(
                        colors: gradient,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text(title)
                .font(.system(size: 8, weight: .medium))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            animateGlow = true
        }
    }
}

struct QuantumNeuralStat: View {
    let title: String
    let value: String
    let gradient: [Color]
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(
                    LinearGradient(
                        colors: gradient,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text(title)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.secondary)
        }
    }
}

struct QuantumTabButton: View {
    let tab: PlaybookView.PlaybookTab
    let isSelected: Bool
    let action: () -> Void
    @State private var hoverEffect = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: tab.icon)
                    .font(.system(size: 16, weight: .semibold))
                
                Text(tab.rawValue)
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundStyle(isSelected ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                Group {
                    if isSelected {
                        LinearGradient(
                            colors: tab.gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        Color.clear
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color.clear : tab.color.opacity(0.3),
                        lineWidth: 1
                    )
            )
            .scaleEffect(hoverEffect ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: hoverEffect)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            hoverEffect = hovering
        }
    }
}

struct QuantumFilterButton: View {
    let grade: PlaybookView.TradeGrade
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(grade.emoji)
                    .font(.system(size: 14))
                
                Text(grade.rawValue)
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundStyle(isSelected ? .white : grade.color)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Group {
                    if isSelected {
                        LinearGradient(
                            colors: grade.gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        grade.color.opacity(0.1)
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(grade.color.opacity(isSelected ? 0 : 0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct QuantumTradeCard: View {
    let trade: PlaybookTrade
    let action: () -> Void
    @State private var glowAnimation = false
    
    var body: some View {
        Button(action: action) {
            UltraPremiumCard {
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 8) {
                                Text(trade.grade.emoji)
                                    .font(.title2)
                                
                                Text(trade.symbol)
                                    .font(.system(size: 18, weight: .black))
                                    .foregroundStyle(.primary)
                                
                                Text(trade.grade.rawValue)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(
                                        LinearGradient(
                                            colors: trade.grade.gradientColors,
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                            
                            Text(trade.strategy)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 6) {
                            Text(trade.formattedPnL)
                                .font(.system(size: 18, weight: .black))
                                .foregroundStyle(trade.pnl >= 0 ? .green : .red)
                            
                            Text(trade.date.formatted(.dateTime.month().day()))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    if !trade.notes.isEmpty {
                        Text(trade.notes)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(2)
                    }
                    
                    HStack {
                        Label("Entry: \(trade.formattedEntryPrice)", systemImage: "arrow.right.circle.fill")
                            .font(.caption2)
                            .foregroundStyle(.blue)
                        
                        Spacer()
                        
                        Label("Exit: \(trade.formattedExitPrice)", systemImage: "arrow.left.circle.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(glowAnimation ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.3), value: glowAnimation)
        .onHover { hovering in
            glowAnimation = hovering
        }
    }
}

struct QuantumWinnerCard: View {
    let trade: PlaybookTrade
    let action: () -> Void
    @State private var celebrationAnimation = false
    
    var body: some View {
        Button(action: action) {
            UltraPremiumCard {
                VStack(spacing: 16) {
                    HStack {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [DesignSystem.primaryGold, .yellow, .orange],
                                            center: .center,
                                            startRadius: 5,
                                            endRadius: 25
                                        )
                                    )
                                    .frame(width: 50, height: 50)
                                    .scaleEffect(celebrationAnimation ? 1.1 : 1.0)
                                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: celebrationAnimation)
                                
                                Text("")
                                    .font(.title2)
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(spacing: 8) {
                                    Text(trade.symbol)
                                        .font(.system(size: 20, weight: .black))
                                        .foregroundStyle(.primary)
                                    
                                    Text(" WINNER")
                                        .font(.caption)
                                        .fontWeight(.black)
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(
                                            LinearGradient(
                                                colors: [.green, .mint],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                }
                                
                                Text(trade.strategy)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 6) {
                            Text(trade.formattedPnL)
                                .font(.system(size: 22, weight: .black))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.green, .mint],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            
                            Text(" Profit")
                                .font(.caption2)
                                .foregroundStyle(.green)
                        }
                    }
                    
                    if !trade.notes.isEmpty {
                        Text(" " + trade.notes)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(2)
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            celebrationAnimation = true
        }
    }
}

struct QuantumLearningCard: View {
    let trade: PlaybookTrade
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            UltraPremiumCard {
                VStack(spacing: 16) {
                    HStack {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [.red, .orange, .pink],
                                            center: .center,
                                            startRadius: 5,
                                            endRadius: 25
                                        )
                                    )
                                    .frame(width: 50, height: 50)
                                
                                Text("")
                                    .font(.title2)
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(spacing: 8) {
                                    Text(trade.symbol)
                                        .font(.system(size: 20, weight: .black))
                                        .foregroundStyle(.primary)
                                    
                                    Text(" LESSON")
                                        .font(.caption)
                                        .fontWeight(.black)
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(
                                            LinearGradient(
                                                colors: [.red, .orange],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                }
                                
                                Text(trade.strategy)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 6) {
                            Text(trade.formattedPnL)
                                .font(.system(size: 22, weight: .black))
                                .foregroundStyle(.red)
                            
                            Text(" Learn")
                                .font(.caption2)
                                .foregroundStyle(.red)
                        }
                    }
                    
                    if !trade.notes.isEmpty {
                        Text(" " + trade.notes)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(2)
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct QuantumEmptyState: View {
    let title: String
    let subtitle: String
    let icon: String
    @State private var floatAnimation = false
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundStyle(
                    LinearGradient(
                        colors: [DesignSystem.primaryGold, .orange, .yellow],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .offset(y: floatAnimation ? -10 : 10)
                .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: floatAnimation)
            
            VStack(spacing: 12) {
                Text(title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .onAppear {
            floatAnimation = true
        }
    }
}

struct PlaybookView_Previews: PreviewProvider {
    static var previews: some View {
        PlaybookView()
    }
}
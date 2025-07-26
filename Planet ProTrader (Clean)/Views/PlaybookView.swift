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
                                        .fontWeight(.bold)
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
                                        .fontWeight(.bold)
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

struct TradeChartSection: View {
    let trade: PlaybookTrade
    @State private var selectedTimeframe = "5m"
    @State private var showingFullScreen = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Trade Chart")
                    .font(.headline)
                
                Spacer()
                
                // Timeframe selector
                Picker("Timeframe", selection: $selectedTimeframe) {
                    Text("1m").tag("1m")
                    Text("5m").tag("5m")
                    Text("15m").tag("15m")
                    Text("Daily").tag("D")
                }
                .pickerStyle(.segmented)
                .frame(width: 180)
            }
            
            // Trade Chart with annotations
            ZStack {
                // Chart placeholder - in real app would be actual chart
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black)
                    .frame(height: 300)
                    .overlay(
                        Text("Chart Screenshot Area")
                            .foregroundColor(.gray)
                    )
                
                // Fullscreen button
                VStack {
                    HStack {
                        Spacer()
                        Button(action: { showingFullScreen = true }) {
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .padding()
                    }
                    Spacer()
                }
            }
            
            // Key levels
            HStack(spacing: 20) {
                ChartLevelIndicator(label: "Entry", price: trade.formattedEntryPrice, color: .blue)
                ChartLevelIndicator(label: "Stop", price: trade.formattedStopPrice, color: .red)
                ChartLevelIndicator(label: "Target", price: trade.formattedTargetPrice, color: .green)
                ChartLevelIndicator(label: "Exit", price: trade.formattedExitPrice, color: .orange)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .sheet(isPresented: $showingFullScreen) {
            FullScreenChartView(trade: trade)
        }
    }
}

struct ChartLevelIndicator: View {
    let label: String
    let price: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
            
            Text(price)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
    }
}

struct AIAnalysisSection: View {
    let trade: PlaybookTrade
    @Binding var isLoading: Bool
    @State private var aiAnalysis: AITradeAnalysis?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "brain")
                    .foregroundColor(.purple)
                Text("AI Trade Analysis")
                    .font(.headline)
                
                Spacer()
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Button("Refresh") {
                        generateAIAnalysis()
                    }
                    .font(.caption)
                    .foregroundColor(.purple)
                }
            }
            
            if let analysis = aiAnalysis {
                VStack(alignment: .leading, spacing: 12) {
                    // AI Score
                    HStack {
                        Text("AI Trade Score:")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text("\(analysis.score)/100")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(analysis.scoreColor)
                        
                        Image(systemName: "sparkles")
                            .foregroundColor(analysis.scoreColor)
                    }
                    
                    // Key Insights
                    ForEach(analysis.insights, id: \.self) { insight in
                        HStack(alignment: .top) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.yellow)
                            Text(insight)
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Pattern Recognition
                    if !analysis.patterns.isEmpty {
                        Divider()
                        
                        Text("Patterns Detected:")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        HStack {
                            ForEach(analysis.patterns, id: \.self) { pattern in
                                PatternTag(pattern: pattern)
                            }
                            Spacer()
                        }
                    }
                }
            } else {
                Button(action: generateAIAnalysis) {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Generate AI Analysis")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple.opacity(0.2))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.purple.opacity(0.1))
        .cornerRadius(12)
        .onAppear {
            generateAIAnalysis()
        }
    }
    
    private func generateAIAnalysis() {
        isLoading = true
        
        // Simulate AI analysis
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            aiAnalysis = AITradeAnalysis(
                score: Int.random(in: 65...95),
                insights: [
                    "Strong entry at key support level with volume confirmation",
                    "Exit timing could be improved - left 0.35 points on the table",
                    "Risk management was excellent with 1:2.5 risk/reward achieved",
                    "Pattern recognition: Classic bull flag breakout on 5-min chart"
                ],
                patterns: ["Bull Flag", "Volume Breakout", "Support Bounce"],
                recommendations: [
                    "Consider scaling out 1/3 position at 1R profit",
                    "Watch for divergence on RSI for better exit timing",
                    "This setup has 73% win rate based on your last 50 similar trades"
                ]
            )
            isLoading = false
        }
    }
}

struct AITradeAnalysis {
    let score: Int
    let insights: [String]
    let patterns: [String]
    let recommendations: [String]
    
    var scoreColor: Color {
        if score >= 85 { return .green }
        else if score >= 70 { return .blue }
        else if score >= 50 { return .orange }
        else { return .red }
    }
}

struct PatternTag: View {
    let pattern: String
    
    var body: some View {
        Text(pattern)
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.2))
            .cornerRadius(12)
    }
}

struct TechnicalAnalysisCard: View {
    let trade: PlaybookTrade
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Technical Analysis")
                .font(.headline)
            
            // Market Context
            AnalysisRow(
                icon: "chart.line.uptrend.xyaxis",
                title: "Market Context",
                value: "Uptrend",
                detail: "SPY +0.8%, above VWAP",
                color: .green
            )
            
            // Key Levels
            AnalysisRow(
                icon: "chart.bar.xaxis",
                title: "Key Levels",
                value: "Support Bounce",
                detail: "Entered at daily S1 pivot",
                color: .blue
            )
            
            // Volume Analysis
            AnalysisRow(
                icon: "chart.bar.fill",
                title: "Volume",
                value: "Above Average",
                detail: "2.3x relative volume",
                color: .purple
            )
            
            // Indicators
            AnalysisRow(
                icon: "waveform.path.ecg",
                title: "Indicators",
                value: "Aligned",
                detail: "RSI: 45→62, MACD: Bullish cross",
                color: .orange
            )
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct ExecutionAnalysisCard: View {
    let trade: PlaybookTrade
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Execution Analysis")
                .font(.headline)
            
            // Entry Execution
            ExecutionMetric(
                title: "Entry Execution",
                rating: 4,
                detail: "Entered within 0.05 of target price",
                suggestion: "Consider using limit orders for better fills"
            )
            
            // Position Sizing
            ExecutionMetric(
                title: "Position Sizing",
                rating: 5,
                detail: "Perfect 1% risk maintained",
                suggestion: nil
            )
            
            // Stop Placement
            ExecutionMetric(
                title: "Stop Placement",
                rating: 3,
                detail: "Stop was slightly too tight",
                suggestion: "Give trades more room based on ATR"
            )
            
            // Exit Execution
            ExecutionMetric(
                title: "Exit Execution",
                rating: 3,
                detail: "Exited early - left money on table",
                suggestion: "Use trailing stops or scale out strategy"
            )
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct ExecutionMetric: View {
    let title: String
    let rating: Int
    let detail: String
    let suggestion: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= rating ? "star.fill" : "star")
                            .font(.caption)
                            .foregroundColor(star <= rating ? .yellow : .gray)
                    }
                }
            }
            
            Text(detail)
                .font(.caption)
                .foregroundColor(.gray)
            
            if let suggestion = suggestion {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                    
                    Text(suggestion)
                        .font(.caption)
                        .foregroundColor(.yellow)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct RiskManagementCard: View {
    let trade: PlaybookTrade
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Risk Management")
                .font(.headline)
            
            // Risk metrics grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                RiskMetric(
                    title: "R-Multiple",
                    value: trade.rMultiple,
                    color: trade.rMultipleValue > 0 ? .green : .red
                )
                
                RiskMetric(
                    title: "Risk %",
                    value: "1.0%",
                    color: .blue
                )
                
                RiskMetric(
                    title: "Win Probability",
                    value: "68%",
                    color: .purple
                )
                
                RiskMetric(
                    title: "Expected Value",
                    value: "+$127",
                    color: .green
                )
            }
            
            Divider()
            
            // Risk Assessment
            Text("Risk Assessment")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("Position size aligned with account risk rules")
                    .font(.caption)
            }
            
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("Stop loss placed below key support")
                    .font(.caption)
            }
            
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                Text("Consider wider stop based on recent volatility")
                    .font(.caption)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct RiskMetric: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct SMBStyleReviewCard: View {
    let trade: PlaybookTrade
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(.orange)
                Text("SMB Capital Style Review")
                    .font(.headline)
            }
            
            Text("\"One Good Trade\" Analysis")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // Categories Mike Bellafiore emphasizes
            ReviewCategory(
                title: "Preparation",
                grade: "B+",
                comment: "Good pre-market prep, identified key levels. Could improve by reviewing similar historical setups."
            )
            
            ReviewCategory(
                title: "Entry Execution",
                grade: "A-",
                comment: "Waited for confirmation, sized appropriately. Excellent patience shown."
            )
            
            ReviewCategory(
                title: "Trade Management",
                grade: "B",
                comment: "Followed initial plan but could have scaled out for better profit optimization."
            )
            
            ReviewCategory(
                title: "Mental Game",
                grade: "A",
                comment: "Stayed disciplined, no emotional decisions. This is elite-level emotional control."
            )
            
            // Overall recommendation
            VStack(alignment: .leading, spacing: 8) {
                Text("Coach's Note:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                
                Text("This trade shows strong process adherence. To move from good to great, focus on optimizing exits through scaling strategies. Consider adding this setup to your A+ playbook after 5 more successful iterations.")
                    .font(.caption)
                    .foregroundColor(.white)
                    .italic()
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(8)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct ReviewCategory: View {
    let title: String
    let grade: String
    let comment: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(grade)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(gradeColor)
            }
            
            Text(comment)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
    
    var gradeColor: Color {
        if grade.contains("A") { return .green }
        else if grade.contains("B") { return .blue }
        else if grade.contains("C") { return .orange }
        else { return .red }
    }
}

struct AnalysisRow: View {
    let icon: String
    let title: String
    let value: String
    let detail: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            }
            
            Spacer()
            
            Text(detail)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

struct FullScreenChartView: View {
    let trade: PlaybookTrade
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                // Full screen chart placeholder
                Text("Full Screen Chart View")
                    .foregroundColor(.white)
                    .font(.title)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

struct ShareSheet: View {
    let trade: PlaybookTrade
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Share Trade Analysis")
                    .font(.headline)
                    .padding()
                
                // Preview of what will be shared
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Trade summary
                        ShareableTradeCard(trade: trade)
                        
                        // Chart preview
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 200)
                            .overlay(
                                Text("Chart Screenshot")
                                    .foregroundColor(.gray)
                            )
                        
                        // Key insights
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Key Insights:")
                                .font(.headline)
                            
                            Text("• Entry at key support level")
                            Text("• Risk/Reward: 1:2.5")
                            Text("• Pattern: Bull flag breakout")
                            Text("• Exit: Scaled out at targets")
                        }
                        .font(.subheadline)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .padding()
                }
                
                HStack(spacing: 20) {
                    ShareButton(title: "Twitter", icon: "message.fill", color: .blue) {
                        // Share to Twitter
                    }
                    
                    ShareButton(title: "Discord", icon: "person.3.fill", color: .purple) {
                        // Share to Discord
                    }
                    
                    ShareButton(title: "Export", icon: "square.and.arrow.up", color: .green) {
                        // Export as PDF
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ShareableTradeCard: View {
    let trade: PlaybookTrade
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(trade.symbol)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text(trade.formattedPnL)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(trade.pnl > 0 ? .green : .red)
            }
            
            HStack {
                Label("Strategy: \(trade.strategy)", systemImage: "chart.line.uptrend.xyaxis")
                    .font(.caption)
                
                Spacer()
                
                Text(trade.date.formatted(.dateTime.month().day().hour().minute()))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct ShareButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(color.opacity(0.2))
            .cornerRadius(12)
        }
    }
}

// MARK: - Enhanced PlaybookTrade Model

extension PlaybookTrade {
    var formattedStopPrice: String {
        let stopPrice = entryPrice - (entryPrice * 0.02) // 2% stop
        return String(format: "$%.2f", stopPrice)
    }
    
    var formattedTargetPrice: String {
        let targetPrice = entryPrice + (entryPrice * 0.05) // 5% target
        return String(format: "$%.2f", targetPrice)
    }
    
    var rMultiple: String {
        let risk = entryPrice - (entryPrice * 0.02)
        let reward = exitPrice - entryPrice
        let riskAmount = entryPrice - risk
        let rMultipleValue = riskAmount > 0 ? reward / riskAmount : 0
        return String(format: "%.1fR", rMultipleValue)
    }
    
    var rMultipleValue: Double {
        let risk = entryPrice - (entryPrice * 0.02)
        let reward = exitPrice - entryPrice
        let riskAmount = entryPrice - risk
        return riskAmount > 0 ? reward / riskAmount : 0
    }
}

// MARK: - Screenshot Functionality

struct ScreenshotView: View {
    let trade: PlaybookTrade
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Trade Analysis Report")
                        .font(.headline)
                    Text(Date().formatted(.dateTime.month().day().year()))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "checkmark.seal.fill")
                    .font(.title)
                    .foregroundColor(.green)
            }
            .padding()
            .background(Color.black)
            
            // Trade Info
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(trade.symbol)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(trade.strategy)
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.blue)
                        .cornerRadius(20)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text(trade.formattedPnL)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(trade.pnl > 0 ? .green : .red)
                    
                    Text(trade.rMultiple)
                        .font(.headline)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            // Chart placeholder
            Rectangle()
                .fill(Color.gray.opacity(0.1))
                .frame(height: 300)
                .overlay(
                    Text("Chart with entry/exit markers")
                        .foregroundColor(.gray)
                )
            
            // Key Metrics
            HStack(spacing: 20) {
                MetricBox(title: "Entry", value: trade.formattedEntryPrice, color: .blue)
                MetricBox(title: "Exit", value: trade.formattedExitPrice, color: .orange)
                MetricBox(title: "Stop", value: trade.formattedStopPrice, color: .red)
                MetricBox(title: "Risk", value: "1%", color: .purple)
            }
            .padding()
            
            // AI Analysis Summary
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "brain")
                        .foregroundColor(.purple)
                    Text("AI Analysis")
                        .font(.headline)
                    Spacer()
                    Text("Score: 88/100")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    BulletPoint(text: "Excellent entry at key support level", color: .green)
                    BulletPoint(text: "Strong risk management with 1:2.5 R/R", color: .green)
                    BulletPoint(text: "Exit timing could be optimized", color: .orange)
                    BulletPoint(text: "Pattern: Bull flag breakout confirmed", color: .blue)
                }
            }
            .padding()
            .background(Color.purple.opacity(0.1))
            .cornerRadius(12)
            .padding()
            
            // Footer
            HStack {
                Text("Generated by ProTrader Playbook")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text("@YourTradingHandle")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
        }
        .background(Color.black)
        .foregroundColor(.white)
    }
}

struct MetricBox: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            
            Text(value)
                .font(.headline)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
    }
}

struct BulletPoint: View {
    let text: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
                .offset(y: 6)
            
            Text(text)
                .font(.subheadline)
        }
    }
}

// MARK: - AI Coaching Suggestions

struct AICoachingView: View {
    let trade: PlaybookTrade
    @State private var coachingInsights: [CoachingInsight] = []
    @State private var isLoading = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "person.fill.questionmark")
                    .foregroundColor(.orange)
                Text("AI Coaching Insights")
                    .font(.headline)
                
                Spacer()
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            
            if coachingInsights.isEmpty && !isLoading {
                Button(action: generateCoachingInsights) {
                    Label("Generate Coaching Insights", systemImage: "sparkles")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange.opacity(0.2))
                        .cornerRadius(8)
                }
            } else {
                ForEach(coachingInsights) { insight in
                    CoachingInsightRow(insight: insight)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func generateCoachingInsights() {
        isLoading = true
        
        // Simulate AI analysis
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            coachingInsights = [
                CoachingInsight(
                    category: "Entry Timing",
                    observation: "You entered after the second candle confirmation",
                    coaching: "Consider entering on the first confirmation with smaller size to improve R/R",
                    priority: .medium
                ),
                CoachingInsight(
                    category: "Position Management",
                    observation: "Full position exit at first target",
                    coaching: "Try scaling out: 1/3 at 1R, 1/3 at 2R, let 1/3 run with trailing stop",
                    priority: .high
                ),
                CoachingInsight(
                    category: "Psychology",
                    observation: "Quick exit suggests fear of giving back profits",
                    coaching: "Trust your analysis. Set alerts and walk away to avoid micromanaging",
                    priority: .medium
                )
            ]
            isLoading = false
        }
    }
}

struct CoachingInsight: Identifiable {
    let id = UUID()
    let category: String
    let observation: String
    let coaching: String
    let priority: Priority
    
    enum Priority {
        case high, medium, low
        
        var color: Color {
            switch self {
            case .high: return .red
            case .medium: return .orange
            case .low: return .yellow
            }
        }
    }
}

struct CoachingInsightRow: View {
    let insight: CoachingInsight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(insight.category)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Circle()
                    .fill(insight.priority.color)
                    .frame(width: 8, height: 8)
            }
            
            Text(insight.observation)
                .font(.caption)
                .foregroundColor(.gray)
            
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.caption)
                    .foregroundColor(.yellow)
                
                Text(insight.coaching)
                    .font(.caption)
                    .foregroundColor(.yellow)
            }
            .padding(8)
            .background(Color.yellow.opacity(0.1))
            .cornerRadius(6)
        }
        .padding(.vertical, 4)
    }
}

// ... existing code ...

struct PlaybookView_Previews: PreviewProvider {
    static var previews: some View {
        PlaybookView()
    }
}
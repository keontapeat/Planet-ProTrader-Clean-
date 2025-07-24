//
//  QuantumPlaybookViews.swift
//  Planet ProTrader (Clean)
//
//  🤯🔥 QUANTUM PLAYBOOK SUPPORTING VIEWS 🔥🤯
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

// MARK: - 🔮 QUANTUM PATTERN LAB VIEW

struct QuantumPatternLabView: View {
    @EnvironmentObject var playbookManager: PlaybookManager
    @State private var selectedPattern: TradingPattern?
    @State private var animatePatterns = false
    
    var body: some View {
        LazyVStack(spacing: 20) {
            // Header
            HStack {
                Text("🔮 QUANTUM PATTERN LAB")
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .pink, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Spacer()
                
                Text("\(playbookManager.tradingPatterns.count) Patterns")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Pattern Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ForEach(playbookManager.tradingPatterns) { pattern in
                    QuantumPatternCard(pattern: pattern) {
                        selectedPattern = pattern
                    }
                    .scaleEffect(animatePatterns ? 1.0 : 0.8)
                    .opacity(animatePatterns ? 1.0 : 0.0)
                    .animation(
                        .spring(response: 0.6, dampingFraction: 0.8)
                        .delay(Double(playbookManager.tradingPatterns.firstIndex(of: pattern) ?? 0) * 0.1),
                        value: animatePatterns
                    )
                }
            }
        }
        .onAppear {
            animatePatterns = true
        }
        .sheet(item: $selectedPattern) { pattern in
            QuantumPatternDetailView(pattern: pattern)
        }
    }
}

struct QuantumPatternCard: View {
    let pattern: TradingPattern
    let action: () -> Void
    @State private var glowEffect = false
    
    var body: some View {
        Button(action: action) {
            UltraPremiumCard {
                VStack(spacing: 12) {
                    HStack {
                        Text(pattern.category.emoji)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(pattern.name)
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                                .lineLimit(2)
                            
                            Text(pattern.category.rawValue)
                                .font(.caption2)
                                .foregroundStyle(pattern.category.color)
                        }
                        
                        Spacer()
                    }
                    
                    VStack(spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Success Rate")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                
                                Text(pattern.formattedSuccessRate)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.green)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("Avg Return")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                
                                Text(pattern.formattedAverageReturn)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(pattern.averageReturn >= 0 ? .green : .red)
                            }
                        }
                        
                        HStack {
                            Text("\(pattern.occurrences) trades")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            Text("R:R \(pattern.formattedRiskReward)")
                                .font(.caption2)
                                .foregroundStyle(DesignSystem.primaryGold)
                        }
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(glowEffect ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.3), value: glowEffect)
        .onHover { hovering in
            glowEffect = hovering
        }
    }
}

// MARK: - 🧠 QUANTUM PSYCHOLOGY CENTER

struct QuantumPsychologyCenterView: View {
    @EnvironmentObject var playbookManager: PlaybookManager
    @State private var selectedInsight: PsychologyInsight?
    @State private var animateInsights = false
    
    var body: some View {
        LazyVStack(spacing: 20) {
            // Header
            HStack {
                Text("🧠 QUANTUM PSYCHOLOGY CENTER")
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.pink, .red, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("EQ Score")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Text("\(Int(playbookManager.emotionalIntelligenceScore * 100))%")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(DesignSystem.primaryGold)
                }
            }
            
            // Psychology Insights
            LazyVStack(spacing: 12) {
                ForEach(playbookManager.psychologyInsights) { insight in
                    QuantumPsychologyInsightCard(insight: insight) {
                        selectedInsight = insight
                    }
                    .scaleEffect(animateInsights ? 1.0 : 0.8)
                    .opacity(animateInsights ? 1.0 : 0.0)
                    .animation(
                        .spring(response: 0.6, dampingFraction: 0.8)
                        .delay(Double(playbookManager.psychologyInsights.firstIndex(of: insight) ?? 0) * 0.1),
                        value: animateInsights
                    )
                }
            }
            
            // Mark Douglas Wisdom
            QuantumMarkDouglasWisdom()
        }
        .onAppear {
            animateInsights = true
        }
        .sheet(item: $selectedInsight) { insight in
            QuantumPsychologyDetailView(insight: insight)
        }
    }
}

struct QuantumPsychologyInsightCard: View {
    let insight: PsychologyInsight
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            UltraPremiumCard {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        HStack(spacing: 8) {
                            Text(insight.category.emoji)
                                .font(.title3)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(insight.title)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.primary)
                                    .lineLimit(2)
                                
                                Text(insight.category.rawValue)
                                    .font(.caption2)
                                    .foregroundStyle(insight.category.color)
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(insight.severity.emoji)
                                .font(.title3)
                            
                            Text(insight.severity.rawValue)
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(insight.severity.color)
                        }
                    }
                    
                    Text(insight.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                    
                    if !insight.markDouglasQuote.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("💭 Mark Douglas Wisdom:")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(DesignSystem.primaryGold)
                            
                            Text("\"\(insight.markDouglasQuote)\"")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .italic()
                                .lineLimit(2)
                        }
                        .padding(.top, 4)
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct QuantumMarkDouglasWisdom: View {
    @State private var currentQuoteIndex = 0
    @State private var animateQuote = false
    
    private let markDouglasQuotes = [
        "The hard reality of trading is that every trade has an uncertain outcome.",
        "Anything can happen in the markets at any moment.",
        "You don't need to know what's going to happen next to make money.",
        "There's a random distribution between wins and losses for any given set of variables.",
        "An edge is nothing more than an indication of a higher probability of one thing happening over another.",
        "Every moment in the market is unique.",
        "The five fundamental truths will become your core trading beliefs."
    ]
    
    var body: some View {
        UltraPremiumCard {
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "brain.head.profile")
                        .font(.title2)
                        .foregroundStyle(DesignSystem.primaryGold)
                    
                    Text("💭 MARK DOUGLAS WISDOM")
                        .font(.system(size: 16, weight: .black))
                        .foregroundStyle(DesignSystem.primaryGold)
                    
                    Spacer()
                    
                    Button("Next") {
                        withAnimation(.spring()) {
                            currentQuoteIndex = (currentQuoteIndex + 1) % markDouglasQuotes.count
                            animateQuote.toggle()
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(DesignSystem.primaryGold)
                }
                
                Text("\"\(markDouglasQuotes[currentQuoteIndex])\"")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .italic()
                    .scaleEffect(animateQuote ? 1.02 : 1.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: animateQuote)
                
                Text("- Mark Douglas, Trading in the Zone")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - 🚀 QUANTUM COACHING CENTER

struct QuantumCoachingCenterView: View {
    @EnvironmentObject var playbookManager: PlaybookManager
    @State private var selectedCoachingArea: CoachingArea = .psychology
    @State private var animateCoaching = false
    
    enum CoachingArea: String, CaseIterable {
        case psychology = "Psychology"
        case riskManagement = "Risk Management"
        case entryTiming = "Entry Timing"
        case exitStrategy = "Exit Strategy"
        case patternRecognition = "Pattern Recognition"
        case marketAnalysis = "Market Analysis"
        
        var emoji: String {
            switch self {
            case .psychology: return "🧠"
            case .riskManagement: return "🛡️"
            case .entryTiming: return "⏰"
            case .exitStrategy: return "🎯"
            case .patternRecognition: return "🔮"
            case .marketAnalysis: return "📊"
            }
        }
        
        var color: Color {
            switch self {
            case .psychology: return .pink
            case .riskManagement: return .blue
            case .entryTiming: return .orange
            case .exitStrategy: return .green
            case .patternRecognition: return .purple
            case .marketAnalysis: return DesignSystem.primaryGold
            }
        }
    }
    
    var body: some View {
        LazyVStack(spacing: 20) {
            // Header
            HStack {
                Text("🚀 QUANTUM COACHING CENTER")
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .yellow, .red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Spacer()
                
                Text("AI Powered")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Coaching Area Selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(CoachingArea.allCases, id: \.self) { area in
                        Button(action: {
                            withAnimation(.spring()) {
                                selectedCoachingArea = area
                            }
                        }) {
                            HStack(spacing: 6) {
                                Text(area.emoji)
                                    .font(.system(size: 12))
                                
                                Text(area.rawValue)
                                    .font(.caption)
                                    .fontWeight(.bold)
                            }
                            .foregroundStyle(selectedCoachingArea == area ? .white : area.color)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                selectedCoachingArea == area ? 
                                area.color : 
                                area.color.opacity(0.1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
            
            // Coaching Content
            QuantumCoachingContent(area: selectedCoachingArea)
                .scaleEffect(animateCoaching ? 1.0 : 0.9)
                .opacity(animateCoaching ? 1.0 : 0.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: selectedCoachingArea)
        }
        .onAppear {
            animateCoaching = true
        }
    }
}

struct QuantumCoachingContent: View {
    let area: QuantumCoachingCenterView.CoachingArea
    
    var body: some View {
        UltraPremiumCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(area.emoji)
                        .font(.title2)
                    
                    Text(area.rawValue + " Coaching")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Text("AI Generated")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    CoachingTip(
                        title: getCoachingTitle(for: area),
                        description: getCoachingDescription(for: area),
                        action: getCoachingAction(for: area)
                    )
                    
                    CoachingExercise(
                        title: getExerciseTitle(for: area),
                        description: getExerciseDescription(for: area),
                        duration: "5-10 min"
                    )
                }
            }
        }
    }
    
    private func getCoachingTitle(for area: QuantumCoachingCenterView.CoachingArea) -> String {
        switch area {
        case .psychology:
            return "Emotional State Management"
        case .riskManagement:
            return "Position Sizing Optimization"
        case .entryTiming:
            return "Perfect Entry Recognition"
        case .exitStrategy:
            return "Profit Maximization Techniques"
        case .patternRecognition:
            return "Pattern Confirmation Skills"
        case .marketAnalysis:
            return "Market Structure Analysis"
        }
    }
    
    private func getCoachingDescription(for area: QuantumCoachingCenterView.CoachingArea) -> String {
        switch area {
        case .psychology:
            return "Your recent trades show emotional interference. Practice the 'observer mindset' - watch your thoughts without judgment during live trading."
        case .riskManagement:
            return "Your position sizes vary too much based on emotions. Stick to 1-2% risk per trade regardless of how confident you feel about the setup."
        case .entryTiming:
            return "You're entering trades 15% too early on average. Wait for the complete setup confirmation before entering positions."
        case .exitStrategy:
            return "Your winning trades are being closed 20% too early. Consider using trailing stops to maximize profits on trending moves."
        case .patternRecognition:
            return "Focus on fewer, higher-quality patterns. You're recognizing patterns correctly but need to be more selective with entries."
        case .marketAnalysis:
            return "Improve your multi-timeframe analysis. Check higher timeframes for context before entering trades on lower timeframes."
        }
    }
    
    private func getCoachingAction(for area: QuantumCoachingCenterView.CoachingArea) -> String {
        switch area {
        case .psychology:
            return "Practice mindfulness meditation for 10 minutes before each trading session"
        case .riskManagement:
            return "Create a position sizing calculator and use it for every single trade"
        case .entryTiming:
            return "Set up alerts for your setups instead of watching charts all day"
        case .exitStrategy:
            return "Define your exit strategy before entering each trade"
        case .patternRecognition:
            return "Focus on mastering 2-3 patterns instead of trying to trade everything"
        case .marketAnalysis:
            return "Always check daily and 4-hour charts before entering any trade"
        }
    }
    
    private func getExerciseTitle(for area: QuantumCoachingCenterView.CoachingArea) -> String {
        switch area {
        case .psychology:
            return "Emotional State Check"
        case .riskManagement:
            return "Risk Calculator Drill"
        case .entryTiming:
            return "Setup Confirmation Practice"
        case .exitStrategy:
            return "Exit Planning Exercise"
        case .patternRecognition:
            return "Pattern Quality Assessment"
        case .marketAnalysis:
            return "Multi-Timeframe Analysis"
        }
    }
    
    private func getExerciseDescription(for area: QuantumCoachingCenterView.CoachingArea) -> String {
        switch area {
        case .psychology:
            return "Rate your emotional state from 1-10 before each trade. Only trade when you're at 7+."
        case .riskManagement:
            return "Calculate position size for 10 different account balances and risk percentages."
        case .entryTiming:
            return "Review 20 chart setups and identify which ones have complete confirmation signals."
        case .exitStrategy:
            return "Plan exit strategies for 5 different market scenarios before entering your next trade."
        case .patternRecognition:
            return "Grade 30 patterns from A+ to F based on quality and context."
        case .marketAnalysis:
            return "Analyze the same trade setup on 1m, 15m, 1h, 4h, and daily timeframes."
        }
    }
}

struct CoachingTip: View {
    let title: String
    let description: String
    let action: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("💡 \(title)")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(DesignSystem.primaryGold)
            
            Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            HStack {
                Text("Action:")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
                
                Text(action)
                    .font(.caption2)
                    .foregroundStyle(.blue)
            }
        }
        .padding()
        .background(.blue.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct CoachingExercise: View {
    let title: String
    let description: String
    let duration: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("🎯 \(title)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.green)
                
                Spacer()
                
                Text(duration)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.green.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - ⚡ QUANTUM ELITE QUIZ

struct QuantumEliteQuizView: View {
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswer: Int?
    @State private var showingResult = false
    @State private var score = 0
    @State private var quizCompleted = false
    
    private let quizQuestions = [
        QuizQuestion(
            question: "According to Mark Douglas, what is the most important aspect of successful trading?",
            answers: [
                "Technical analysis skills",
                "Psychological discipline",
                "Market timing ability",
                "Risk management rules"
            ],
            correctAnswer: 1,
            explanation: "Mark Douglas emphasizes that trading is 80% psychology and 20% technical skills."
        ),
        QuizQuestion(
            question: "What should you do when a trade goes against you?",
            answers: [
                "Add to the position to average down",
                "Hope it will turn around",
                "Cut the loss according to your plan",
                "Wait for it to break even"
            ],
            correctAnswer: 2,
            explanation: "Successful traders always follow their predetermined exit rules and cut losses quickly."
        ),
        QuizQuestion(
            question: "What is the 'probabilistic mindset' in trading?",
            answers: [
                "Every trade will be a winner",
                "You can predict market movements",
                "Each trade has uncertain outcome",
                "Patterns always repeat exactly"
            ],
            correctAnswer: 2,
            explanation: "A probabilistic mindset means accepting that each trade has an uncertain outcome, but over many trades, your edge will play out."
        )
    ]
    
    var body: some View {
        LazyVStack(spacing: 24) {
            // Header
            HStack {
                Text("⚡ QUANTUM ELITE QUIZ")
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.cyan, .blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Spacer()
                
                if !quizCompleted {
                    Text("\(currentQuestionIndex + 1)/\(quizQuestions.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            if quizCompleted {
                QuizResultView(score: score, totalQuestions: quizQuestions.count) {
                    resetQuiz()
                }
            } else {
                QuizQuestionView(
                    question: quizQuestions[currentQuestionIndex],
                    selectedAnswer: $selectedAnswer,
                    showingResult: $showingResult
                ) {
                    nextQuestion()
                }
            }
        }
    }
    
    private func nextQuestion() {
        if let selected = selectedAnswer {
            if selected == quizQuestions[currentQuestionIndex].correctAnswer {
                score += 1
            }
        }
        
        if currentQuestionIndex < quizQuestions.count - 1 {
            currentQuestionIndex += 1
            selectedAnswer = nil
            showingResult = false
        } else {
            quizCompleted = true
        }
    }
    
    private func resetQuiz() {
        currentQuestionIndex = 0
        selectedAnswer = nil
        showingResult = false
        score = 0
        quizCompleted = false
    }
}

struct QuizQuestion {
    let question: String
    let answers: [String]
    let correctAnswer: Int
    let explanation: String
}

struct QuizQuestionView: View {
    let question: QuizQuestion
    @Binding var selectedAnswer: Int?
    @Binding var showingResult: Bool
    let onNext: () -> Void
    
    var body: some View {
        UltraPremiumCard {
            VStack(alignment: .leading, spacing: 20) {
                Text(question.question)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.primary)
                
                VStack(spacing: 12) {
                    ForEach(
                        Array(question.answers.enumerated()), id: \.offset
                    ) { index, answer in
                        Button(action: {
                            selectedAnswer = index
                            showingResult = true
                        }) {
                            HStack {
                                Text(answer)
                                    .font(.system(size: 14))
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                                
                                if showingResult {
                                    Image(systemName: index == question.correctAnswer ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundStyle(index == question.correctAnswer ? .green : .red)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(getAnswerBackgroundColor(index: index))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(getAnswerBorderColor(index: index), lineWidth: 2)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(showingResult)
                    }
                }
                
                if showingResult {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("💡 Explanation:")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(DesignSystem.primaryGold)
                        
                        Text(question.explanation)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(.orange.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    Button("Next Question") {
                        onNext()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }
        }
    }
    
    private func getAnswerBackgroundColor(index: Int) -> Color {
        if !showingResult {
            return selectedAnswer == index ? .blue.opacity(0.2) : .clear
        }
        
        if index == question.correctAnswer {
            return .green.opacity(0.2)
        } else if selectedAnswer == index {
            return .red.opacity(0.2)
        }
        
        return .clear
    }
    
    private func getAnswerBorderColor(index: Int) -> Color {
        if !showingResult {
            return selectedAnswer == index ? .blue : .clear
        }
        
        if index == question.correctAnswer {
            return .green
        } else if selectedAnswer == index {
            return .red
        }
        
        return .clear
    }
}

struct QuizResultView: View {
    let score: Int
    let totalQuestions: Int
    let onRestart: () -> Void
    @State private var celebrateAnimation = false
    
    var scorePercentage: Double {
        return Double(score) / Double(totalQuestions)
    }
    
    var scoreGrade: String {
        switch scorePercentage {
        case 0.9...: return "A+"
        case 0.8..<0.9: return "A"
        case 0.7..<0.8: return "B"
        case 0.6..<0.7: return "C"
        default: return "F"
        }
    }
    
    var scoreEmoji: String {
        switch scorePercentage {
        case 0.9...: return "🏆"
        case 0.8..<0.9: return "⭐"
        case 0.7..<0.8: return "👍"
        case 0.6..<0.7: return "📚"
        default: return "💪"
        }
    }
    
    var body: some View {
        UltraPremiumCard {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Text(scoreEmoji)
                        .font(.system(size: 64))
                        .scaleEffect(celebrateAnimation ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: celebrateAnimation)
                    
                    Text("Quiz Complete!")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    HStack {
                        Text("Score:")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        Text("\(score)/\(totalQuestions)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                        
                        Text("(\(Int(scorePercentage * 100))%)")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        Text(scoreGrade)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(DesignSystem.primaryGold)
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("📊 Performance Analysis:")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(DesignSystem.primaryGold)
                    
                    Text(getPerformanceMessage())
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                    
                    Text("🎯 Next Steps:")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.blue)
                        .padding(.top, 8)
                    
                    Text(getNextStepsMessage())
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Button("Take Quiz Again") {
                    onRestart()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
        .onAppear {
            celebrateAnimation = true
        }
    }
    
    private func getPerformanceMessage() -> String {
        switch scorePercentage {
        case 0.9...:
            return "Outstanding! You have a strong understanding of trading psychology and Mark Douglas principles. Your mindset is well-aligned with professional trading standards."
        case 0.8..<0.9:
            return "Excellent work! You demonstrate solid knowledge of trading psychology. Continue applying these principles in your live trading."
        case 0.7..<0.8:
            return "Good foundation! You understand the basics but there's room for improvement. Focus on the concepts you missed."
        case 0.6..<0.7:
            return "You're on the right track, but need more study. Review Mark Douglas's core concepts about trading psychology."
        default:
            return "This shows areas where you need significant improvement. Consider re-reading 'Trading in the Zone' and practicing these principles."
        }
    }
    
    private func getNextStepsMessage() -> String {
        switch scorePercentage {
        case 0.9...:
            return "Continue applying these principles consistently. Consider mentoring other traders or taking on more advanced trading strategies."
        case 0.8..<0.9:
            return "Practice implementing these concepts in your daily trading routine. Start a trading journal to track your psychological state."
        case 0.7..<0.8:
            return "Review the questions you missed and study those specific areas. Practice meditation or mindfulness exercises."
        case 0.6..<0.7:
            return "Spend more time studying trading psychology. Consider taking smaller positions while you develop your mental game."
        default:
            return "Focus on mastering the fundamentals before risking significant capital. Start with paper trading to practice these concepts."
        }
    }
}

// MARK: - 🤖 QUANTUM AI INSIGHTS

struct QuantumAIInsightsView: View {
    @EnvironmentObject var playbookManager: PlaybookManager
    @State private var selectedInsightCategory: AIInsightCategory = .performance
    @State private var animateInsights = false
    
    enum AIInsightCategory: String, CaseIterable {
        case performance = "Performance"
        case patterns = "Patterns"
        case psychology = "Psychology"
        case risk = "Risk Management"
        case timing = "Timing"
        case market = "Market Analysis"
        
        var emoji: String {
            switch self {
            case .performance: return "📊"
            case .patterns: return "🔮"
            case .psychology: return "🧠"
            case .risk: return "🛡️"
            case .timing: return "⏰"
            case .market: return "🌍"
            }
        }
        
        var color: Color {
            switch self {
            case .performance: return .blue
            case .patterns: return .purple
            case .psychology: return .pink
            case .risk: return .green
            case .timing: return .orange
            case .market: return DesignSystem.primaryGold
            }
        }
    }
    
    var body: some View {
        LazyVStack(spacing: 20) {
            // Header
            HStack {
                Text("👁️ QUANTUM AI INSIGHTS")
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.mint, .green, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("AI Accuracy")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Text("\(Int(playbookManager.quantumAccuracy * 100))%")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.green)
                }
            }
            
            // Category Selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(AIInsightCategory.allCases, id: \.self) { category in
                        Button(action: {
                            withAnimation(.spring()) {
                                selectedInsightCategory = category
                            }
                        }) {
                            HStack(spacing: 6) {
                                Text(category.emoji)
                                    .font(.system(size: 12))
                                
                                Text(category.rawValue)
                                    .font(.caption)
                                    .fontWeight(.bold)
                            }
                            .foregroundStyle(selectedInsightCategory == category ? .white : category.color)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                selectedInsightCategory == category ? 
                                category.color : 
                                category.color.opacity(0.1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
            
            // AI Insights Content
            QuantumAIInsightContent(category: selectedInsightCategory)
                .scaleEffect(animateInsights ? 1.0 : 0.9)
                .opacity(animateInsights ? 1.0 : 0.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: selectedInsightCategory)
        }
        .onAppear {
            animateInsights = true
        }
    }
}

struct QuantumAIInsightContent: View {
    let category: QuantumAIInsightsView.AIInsightCategory
    
    var body: some View {
        LazyVStack(spacing: 16) {
            ForEach(0..<3) { index in
                AIInsightCard(
                    insight: getAIInsight(for: category, index: index),
                    category: category
                )
            }
        }
    }
    
    private func getAIInsight(for category: QuantumAIInsightsView.AIInsightCategory, index: Int) -> AIInsight {
        switch category {
        case .performance:
            let insights = [
                AIInsight(
                    title: "Win Rate Optimization Detected",
                    description: "Your win rate could increase by 12% by avoiding trades during low volatility periods (14:00-16:00 EST).",
                    confidence: 0.87,
                    impact: .high,
                    actionable: true
                ),
                AIInsight(
                    title: "Position Size Analysis",
                    description: "Your average position size is 23% smaller on winning trades vs losing trades, indicating potential fear-based sizing.",
                    confidence: 0.92,
                    impact: .medium,
                    actionable: true
                ),
                AIInsight(
                    title: "Profit Factor Improvement",
                    description: "By extending your average hold time by 2.3 hours, your profit factor could improve from 1.4 to 1.8.",
                    confidence: 0.78,
                    impact: .high,
                    actionable: true
                )
            ]
            return insights[index]
            
        case .patterns:
            let insights = [
                AIInsight(
                    title: "Breakout Pattern Mastery",
                    description: "You have an 89% success rate with breakout pullback patterns on EURUSD between 8:00-12:00 GMT.",
                    confidence: 0.94,
                    impact: .high,
                    actionable: false
                ),
                AIInsight(
                    title: "Double Bottom Recognition",
                    description: "Your double bottom pattern recognition accuracy is 76%. Focus on volume confirmation to improve to 85%+.",
                    confidence: 0.81,
                    impact: .medium,
                    actionable: true
                ),
                AIInsight(
                    title: "Triangle Pattern Weakness",
                    description: "Triangle patterns have a 34% success rate in your trading. Consider avoiding or improving entry criteria.",
                    confidence: 0.88,
                    impact: .medium,
                    actionable: true
                )
            ]
            return insights[index]
            
        case .psychology:
            let insights = [
                AIInsight(
                    title: "Emotional State Correlation",
                    description: "Your trading performance decreases by 28% on Mondays, likely due to weekend analysis paralysis.",
                    confidence: 0.85,
                    impact: .high,
                    actionable: true
                ),
                AIInsight(
                    title: "Revenge Trading Detection",
                    description: "After losses > $500, your next trade size increases by 45% on average, indicating revenge trading tendencies.",
                    confidence: 0.91,
                    impact: .critical,
                    actionable: true
                ),
                AIInsight(
                    title: "Confidence Level Optimization",
                    description: "Your best trades occur when you rate your confidence level between 7-8 out of 10. Avoid 9-10 confidence trades.",
                    confidence: 0.83,
                    impact: .medium,
                    actionable: true
                )
            ]
            return insights[index]
            
        case .risk:
            let insights = [
                AIInsight(
                    title: "Risk-Reward Ratio Analysis",
                    description: "Your actual risk-reward ratio is 1:2.1, but your planned ratio is 1:3.0. You're exiting winners too early.",
                    confidence: 0.93,
                    impact: .high,
                    actionable: true
                ),
                AIInsight(
                    title: "Stop Loss Optimization",
                    description: "Moving your stops 15% wider would reduce stop-outs by 31% while only decreasing win rate by 3%.",
                    confidence: 0.79,
                    impact: .medium,
                    actionable: true
                ),
                AIInsight(
                    title: "Position Correlation Risk",
                    description: "You frequently hold correlated positions (EURUSD & GBPUSD), increasing your overall portfolio risk by 18%.",
                    confidence: 0.86,
                    impact: .medium,
                    actionable: true
                )
            ]
            return insights[index]
            
        case .timing:
            let insights = [
                AIInsight(
                    title: "Optimal Entry Timing",
                    description: "Your entries are 12 minutes too early on average. Waiting for additional confirmation could improve win rate by 8%.",
                    confidence: 0.84,
                    impact: .medium,
                    actionable: true
                ),
                AIInsight(
                    title: "Session Performance Analysis",
                    description: "Your London session performance is 34% better than New York session. Consider focusing on 3:00-11:00 EST.",
                    confidence: 0.89,
                    impact: .high,
                    actionable: true
                ),
                AIInsight(
                    title: "Exit Timing Optimization",
                    description: "You exit positions 2.7 hours too early on trending days. Use ATR-based trailing stops for better timing.",
                    confidence: 0.77,
                    impact: .medium,
                    actionable: true
                )
            ]
            return insights[index]
            
        case .market:
            let insights = [
                AIInsight(
                    title: "Market Regime Detection",
                    description: "Current market regime is 'Low Volatility Trending'. Your strategies perform 23% better in this regime.",
                    confidence: 0.91,
                    impact: .high,
                    actionable: false
                ),
                AIInsight(
                    title: "Currency Correlation Shift",
                    description: "EURUSD-GBPUSD correlation has increased to 0.87 (from 0.64). Adjust position sizing accordingly.",
                    confidence: 0.95,
                    impact: .medium,
                    actionable: true
                ),
                AIInsight(
                    title: "Volatility Forecast",
                    description: "Expected volatility spike in next 48 hours (78% probability). Consider reducing position sizes or increasing stops.",
                    confidence: 0.78,
                    impact: .high,
                    actionable: true
                )
            ]
            return insights[index]
        }
    }
}

struct AIInsight {
    let title: String
    let description: String
    let confidence: Double
    let impact: Impact
    let actionable: Bool
    
    enum Impact: String, CaseIterable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        case critical = "Critical"
        
        var color: Color {
            switch self {
            case .low: return .gray
            case .medium: return .blue
            case .high: return .orange
            case .critical: return .red
            }
        }
        
        var emoji: String {
            switch self {
            case .low: return "ℹ️"
            case .medium: return "⚠️"
            case .high: return "🔥"
            case .critical: return "🚨"
            }
        }
    }
}

struct AIInsightCard: View {
    let insight: AIInsight
    let category: QuantumAIInsightsView.AIInsightCategory
    
    var body: some View {
        UltraPremiumCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    HStack(spacing: 8) {
                        Text(category.emoji)
                            .font(.title3)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(insight.title)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.primary)
                                .lineLimit(2)
                            
                            Text(category.rawValue)
                                .font(.caption2)
                                .foregroundStyle(category.color)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 4) {
                            Text(insight.impact.emoji)
                                .font(.caption)
                            
                            Text(insight.impact.rawValue)
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(insight.impact.color)
                        }
                        
                        Text("\(Int(insight.confidence * 100))% confident")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Text(insight.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(4)
                
                if insight.actionable {
                    HStack {
                        Text("💡 Actionable")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(DesignSystem.primaryGold)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        Spacer()
                        
                        Button("Apply Insight") {
                            // Action to apply insight
                        }
                        .font(.caption2)
                        .foregroundStyle(DesignSystem.primaryGold)
                    }
                }
            }
        }
    }
}

// MARK: - ⏰ QUANTUM BACKTESTING

struct QuantumBacktestingView: View {
    @EnvironmentObject var playbookManager: PlaybookManager
    @State private var selectedStrategy: BacktestStrategy = .breakoutPullback
    @State private var backtestResults: BacktestResult?
    @State private var isRunningBacktest = false
    @State private var animateResults = false
    
    enum BacktestStrategy: String, CaseIterable {
        case breakoutPullback = "Breakout Pullback"
        case supportResistance = "Support/Resistance"
        case trendFollowing = "Trend Following"
        case meanReversion = "Mean Reversion"
        case momentum = "Momentum"
        
        var emoji: String {
            switch self {
            case .breakoutPullback: return "🚀"
            case .supportResistance: return "⚡"
            case .trendFollowing: return "📈"
            case .meanReversion: return "🔄"
            case .momentum: return "💨"
            }
        }
        
        var color: Color {
            switch self {
            case .breakoutPullback: return DesignSystem.primaryGold
            case .supportResistance: return .blue
            case .trendFollowing: return .green
            case .meanReversion: return .purple
            case .momentum: return .orange
            }
        }
    }
    
    var body: some View {
        LazyVStack(spacing: 20) {
            // Header
            HStack {
                Text("⏰ QUANTUM BACKTESTING")
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.indigo, .purple, .pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Spacer()
                
                if isRunningBacktest {
                    HStack(spacing: 6) {
                        ProgressView()
                            .scaleEffect(0.7)
                        Text("Running...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            // Strategy Selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(BacktestStrategy.allCases, id: \.self) { strategy in
                        Button(action: {
                            withAnimation(.spring()) {
                                selectedStrategy = strategy
                            }
                        }) {
                            HStack(spacing: 8) {
                                Text(strategy.emoji)
                                    .font(.system(size: 14))
                                
                                Text(strategy.rawValue)
                                    .font(.caption)
                                    .fontWeight(.bold)
                            }
                            .foregroundStyle(selectedStrategy == strategy ? .white : strategy.color)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                selectedStrategy == strategy ? 
                                strategy.color : 
                                strategy.color.opacity(0.1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
            
            // Run Backtest Button
            if backtestResults == nil || !isRunningBacktest {
                Button("🚀 Run Quantum Backtest") {
                    runBacktest()
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(isRunningBacktest)
            }
            
            // Backtest Results
            if let results = backtestResults {
                BacktestResultsView(results: results)
                    .scaleEffect(animateResults ? 1.0 : 0.9)
                    .opacity(animateResults ? 1.0 : 0.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animateResults)
            }
        }
    }
    
    private func runBacktest() {
        isRunningBacktest = true
        backtestResults = nil
        
        Task {
            // Simulate backtest running
            try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
            
            await MainActor.run {
                backtestResults = generateBacktestResults(for: selectedStrategy)
                isRunningBacktest = false
                animateResults = true
            }
        }
    }
    
    private func generateBacktestResults(for strategy: BacktestStrategy) -> BacktestResult {
        // Generate realistic backtest results based on strategy
        let baseWinRate = Double.random(in: 0.55...0.75)
        let baseProfitFactor = Double.random(in: 1.2...2.8)
        let totalTrades = Int.random(in: 150...300)
        let winningTrades = Int(Double(totalTrades) * baseWinRate)
        let losingTrades = totalTrades - winningTrades
        
        return BacktestResult(
            strategy: strategy,
            totalTrades: totalTrades,
            winningTrades: winningTrades,
            losingTrades: losingTrades,
            winRate: baseWinRate,
            profitFactor: baseProfitFactor,
            totalReturn: Double.random(in: 15.0...45.0),
            maxDrawdown: Double.random(in: 8.0...18.0),
            averageWin: Double.random(in: 250...450),
            averageLoss: Double.random(in: 150...280),
            largestWin: Double.random(in: 800...1500),
            largestLoss: Double.random(in: 400...800),
            consecutiveWins: Int.random(in: 5...12),
            consecutiveLosses: Int.random(in: 3...7),
            period: "2023-2024 (12 months)"
        )
    }
}

struct BacktestResult {
    let strategy: QuantumBacktestingView.BacktestStrategy
    let totalTrades: Int
    let winningTrades: Int
    let losingTrades: Int
    let winRate: Double
    let profitFactor: Double
    let totalReturn: Double
    let maxDrawdown: Double
    let averageWin: Double
    let averageLoss: Double
    let largestWin: Double
    let largestLoss: Double
    let consecutiveWins: Int
    let consecutiveLosses: Int
    let period: String
    
    var formattedWinRate: String {
        return String(format: "%.1f%%", winRate * 100)
    }
    
    var formattedProfitFactor: String {
        return String(format: "%.2f", profitFactor)
    }
    
    var formattedTotalReturn: String {
        return String(format: "+%.1f%%", totalReturn)
    }
    
    var formattedMaxDrawdown: String {
        return String(format: "%.1f%%", maxDrawdown)
    }
}

struct BacktestResultsView: View {
    let results: BacktestResult
    
    var body: some View {
        LazyVStack(spacing: 16) {
            // Results Header
            UltraPremiumCard {
                VStack(spacing: 16) {
                    HStack {
                        HStack(spacing: 8) {
                            Text(results.strategy.emoji)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(results.strategy.rawValue)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.primary)
                                
                                Text("Backtest Results")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(results.formattedTotalReturn)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.green)
                            
                            Text(results.period)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    // Key Metrics
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                        BacktestMetric(
                            title: "Win Rate",
                            value: results.formattedWinRate,
                            color: .green
                        )
                        
                        BacktestMetric(
                            title: "Profit Factor",
                            value: results.formattedProfitFactor,
                            color: .blue
                        )
                        
                        BacktestMetric(
                            title: "Max Drawdown",
                            value: results.formattedMaxDrawdown,
                            color: .red
                        )
                    }
                }
            }
            
            // Detailed Statistics
            UltraPremiumCard {
                VStack(alignment: .leading, spacing: 16) {
                    Text("📊 Detailed Statistics")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(DesignSystem.primaryGold)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        StatRow(title: "Total Trades", value: "\(results.totalTrades)")
                        StatRow(title: "Winning Trades", value: "\(results.winningTrades)")
                        StatRow(title: "Losing Trades", value: "\(results.losingTrades)")
                        StatRow(title: "Average Win", value: String(format: "$%.0f", results.averageWin))
                        StatRow(title: "Average Loss", value: String(format: "$%.0f", results.averageLoss))
                        StatRow(title: "Largest Win", value: String(format: "$%.0f", results.largestWin))
                        StatRow(title: "Largest Loss", value: String(format: "$%.0f", results.largestLoss))
                        StatRow(title: "Max Consecutive Wins", value: "\(results.consecutiveWins)")
                        StatRow(title: "Max Consecutive Losses", value: "\(results.consecutiveLosses)")
                        StatRow(title: "Expectancy", value: String(format: "$%.0f", (results.averageWin * results.winRate) - (results.averageLoss * (1 - results.winRate))))
                    }
                }
            }
        }
    }
}

struct BacktestMetric: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(color)
            
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
        }
    }
}

// MARK: - 🔥 SHEET VIEWS

struct QuantumTradeDetailView: View {
    let trade: PlaybookTrade
    @EnvironmentObject var playbookManager: PlaybookManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Trade Header
                    UltraPremiumCard {
                        VStack(spacing: 16) {
                            HStack {
                                HStack(spacing: 12) {
                                    Text(trade.grade.emoji)
                                        .font(.system(size: 32))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(trade.symbol)
                                            .font(.system(size: 24, weight: .black))
                                            .foregroundStyle(.primary)
                                        
                                        Text(trade.strategy)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text(trade.formattedPnL)
                                        .font(.system(size: 24, weight: .black))
                                        .foregroundStyle(trade.pnl >= 0 ? .green : .red)
                                    
                                    Text(trade.formattedProfitPercentage)
                                        .font(.caption)
                                        .foregroundStyle(trade.pnl >= 0 ? .green : .red)
                                }
                            }
                            
                            // Trade Details Grid
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                                TradeDetailMetric(
                                    title: "Entry",
                                    value: trade.formattedEntryPrice,
                                    color: .blue
                                )
                                
                                TradeDetailMetric(
                                    title: "Exit",
                                    value: trade.formattedExitPrice,
                                    color: .orange
                                )
                                
                                TradeDetailMetric(
                                    title: "R:R",
                                    value: trade.formattedRiskReward,
                                    color: DesignSystem.primaryGold
                                )
                            }
                        }
                    }
                    
                    // Trade Analysis
                    if !trade.notes.isEmpty {
                        UltraPremiumCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("📝 Trade Notes")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(DesignSystem.primaryGold)
                                
                                Text(trade.notes)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                            }
                        }
                    }
                    
                    // Psychology Analysis
                    if !trade.psychologyNotes.isEmpty {
                        UltraPremiumCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("🧠 Psychology Analysis")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.pink)
                                
                                Text(trade.psychologyNotes)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                            }
                        }
                    }
                    
                    // Trade Metadata
                    UltraPremiumCard {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("📊 Trade Metadata")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.blue)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                                MetadataRow(title: "Setup", value: trade.setup.rawValue)
                                MetadataRow(title: "Timeframe", value: trade.timeframe)
                                MetadataRow(title: "Market Condition", value: trade.marketCondition.rawValue)
                                MetadataRow(title: "Quantity", value: String(format: "%.0f", trade.quantity))
                                MetadataRow(title: "Max Drawdown", value: String(format: "$%.2f", trade.maxDrawdown))
                                MetadataRow(title: "Hold Time", value: formatHoldingPeriod(trade.holdingPeriod))
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Trade Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(DesignSystem.primaryGold)
                }
            }
        }
    }
    
    private func formatHoldingPeriod(_ period: TimeInterval) -> String {
        let hours = Int(period) / 3600
        let minutes = (Int(period) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct TradeDetailMetric: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(color)
            
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct MetadataRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// Placeholder views for the sheet presentations
struct QuantumPsychologyAnalysisView: View {
    @EnvironmentObject var playbookManager: PlaybookManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Text("🤯 Deep Psychology Analysis Coming Soon!")
                .font(.title)
                .navigationTitle("Psychology Analysis")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") { dismiss() }
                    }
                }
        }
    }
}

struct QuantumMLearningInsightsView: View {
    @EnvironmentObject var playbookManager: PlaybookManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Text("🚀 ML Insights Coming Soon!")
                .font(.title)
                .navigationTitle("ML Insights")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") { dismiss() }
                    }
                }
        }
    }
}

struct QuantumPatternRecognitionView: View {
    @EnvironmentObject var playbookManager: PlaybookManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Text("🔮 Pattern Recognition Coming Soon!")
                .font(.title)
                .navigationTitle("Pattern Recognition")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") { dismiss() }
                    }
                }
        }
    }
}

struct QuantumPatternDetailView: View {
    let pattern: TradingPattern
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("🔮 Pattern: \(pattern.name)")
                        .font(.title2)
                        .padding()
                    
                    Text(pattern.description)
                        .padding()
                }
            }
            .navigationTitle("Pattern Detail")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct QuantumPsychologyDetailView: View {
    let insight: PsychologyInsight
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("🧠 \(insight.title)")
                        .font(.title2)
                        .padding()
                    
                    Text(insight.description)
                        .padding()
                    
                    Text(insight.suggestion)
                        .padding()
                }
            }
            .navigationTitle("Psychology Insight")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    PlaybookView()
}
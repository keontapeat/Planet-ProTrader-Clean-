//
//  BotTrainingDetailsView.swift
//  Planet ProTrader - Bot Training Details
//
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

struct BotTrainingDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTrainingModule = 0
    
    private let trainingModules = [
        TrainingModule(
            title: "🧠 Mindset Training",
            icon: "brain.head.profile",
            color: .purple,
            description: "Bots learn Jim Rohn's wealth mindset principles",
            details: [
                "Personal development fundamentals",
                "Wealth building psychology",
                "Success habits automation",
                "Risk vs reward mindset",
                "Long-term thinking patterns"
            ]
        ),
        TrainingModule(
            title: "📊 Market Analysis",
            icon: "chart.line.uptrend.xyaxis",
            color: .blue,
            description: "Advanced technical and fundamental analysis training",
            details: [
                "Multi-timeframe analysis",
                "Pattern recognition algorithms",
                "Economic indicator interpretation",
                "Market sentiment analysis",
                "Correlation identification"
            ]
        ),
        TrainingModule(
            title: "⚡ Trading Execution",
            icon: "bolt.fill",
            color: .orange,
            description: "Precision entry and exit strategies",
            details: [
                "Optimal entry timing",
                "Dynamic stop loss management",
                "Position sizing algorithms",
                "Profit maximization techniques",
                "Risk management protocols"
            ]
        ),
        TrainingModule(
            title: "🎯 Strategy Optimization",
            icon: "target",
            color: .green,
            description: "Continuous learning and adaptation",
            details: [
                "Performance analysis",
                "Strategy backtesting",
                "Market adaptation",
                "A/B strategy testing",
                "Continuous improvement loops"
            ]
        )
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Training Progress
                    trainingProgressSection
                    
                    // Training Modules
                    trainingModulesSection
                    
                    // Jim Rohn Integration
                    jimRohnIntegrationSection
                    
                    // Before vs After
                    beforeAfterSection
                }
                .padding()
            }
            .starField()
            .navigationTitle("🤖 Bot Training Details")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(DesignSystem.primaryGold)
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(DesignSystem.nebuladeGradient)
                    .frame(width: 100, height: 100)
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                    .fontWeight(.bold)
            }
            .pulsingEffect()
            
            VStack(spacing: 8) {
                Text("AI BOT TRAINING SYSTEM")
                    .font(DesignSystem.Typography.stellar)
                    .fontWeight(.black)
                    .cosmicText()
                
                Text("How your bots learn from Jim Rohn's wisdom and become legendary traders")
                    .font(DesignSystem.Typography.asteroid)
                    .foregroundColor(DesignSystem.starWhite.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
        .planetCard()
    }
    
    private var trainingProgressSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("🎓 TRAINING PROGRESS")
                    .font(DesignSystem.Typography.planet)
                    .fontWeight(.bold)
                    .cosmicText()
                
                Spacer()
                
                Text("73% Complete")
                    .font(DesignSystem.Typography.asteroid)
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.primaryGold)
            }
            
            // Progress bar
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(DesignSystem.starWhite.opacity(0.2))
                    .frame(height: 12)
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(DesignSystem.nebuladeGradient)
                    .frame(width: UIScreen.main.bounds.width * 0.73 * 0.8, height: 12)
                    .animation(.easeInOut(duration: 2.0), value: 0.73)
            }
            
            HStack {
                Text("🏁 Started: Dec 2024")
                    .font(DesignSystem.Typography.dust)
                    .foregroundColor(DesignSystem.starWhite.opacity(0.6))
                
                Spacer()
                
                Text("🎯 Est. Completion: Jan 2025")
                    .font(DesignSystem.Typography.dust)
                    .foregroundColor(DesignSystem.starWhite.opacity(0.6))
            }
        }
        .planetCard()
    }
    
    private var trainingModulesSection: some View {
        VStack(spacing: 16) {
            Text("📚 TRAINING MODULES")
                .font(DesignSystem.Typography.planet)
                .fontWeight(.bold)
                .cosmicText()
            
            // Module selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<trainingModules.count, id: \.self) { index in
                        moduleTab(index: index)
                    }
                }
                .padding(.horizontal)
            }
            
            // Selected module details
            selectedModuleDetails
        }
        .planetCard()
    }
    
    private func moduleTab(index: Int) -> some View {
        Button(action: {
            withAnimation(.spring()) {
                selectedTrainingModule = index
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: trainingModules[index].icon)
                    .font(.title3)
                    .foregroundColor(selectedTrainingModule == index ? .white : trainingModules[index].color)
                
                Text(trainingModules[index].title)
                    .font(DesignSystem.Typography.dust)
                    .fontWeight(.semibold)
                    .foregroundColor(selectedTrainingModule == index ? .white : DesignSystem.starWhite)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                selectedTrainingModule == index 
                ? trainingModules[index].color
                : trainingModules[index].color.opacity(0.2)
            )
            .cornerRadius(20)
            .animation(.spring(), value: selectedTrainingModule)
        }
    }
    
    private var selectedModuleDetails: some View {
        let module = trainingModules[selectedTrainingModule]
        
        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: module.icon)
                    .font(.title2)
                    .foregroundColor(module.color)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(module.title)
                        .font(DesignSystem.Typography.asteroid)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.starWhite)
                    
                    Text(module.description)
                        .font(DesignSystem.Typography.dust)
                        .foregroundColor(DesignSystem.starWhite.opacity(0.7))
                }
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("📋 TRAINING COMPONENTS:")
                    .font(DesignSystem.Typography.dust)
                    .fontWeight(.bold)
                    .foregroundColor(module.color)
                
                ForEach(module.details, id: \.self) { detail in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(DesignSystem.Typography.dust)
                            .foregroundColor(module.color)
                        
                        Text(detail)
                            .font(DesignSystem.Typography.dust)
                            .foregroundColor(DesignSystem.starWhite.opacity(0.8))
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(module.color.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var jimRohnIntegrationSection: some View {
        VStack(spacing: 16) {
            Text("🌟 JIM ROHN WISDOM INTEGRATION")
                .font(DesignSystem.Typography.planet)
                .fontWeight(.bold)
                .cosmicText()
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 1), spacing: 12) {
                wisdomCard(
                    quote: "You are the average of the five people you spend the most time with.",
                    application: "Bots analyze market sentiment by studying the 'behavior' of the top 5 most influential market makers and institutions.",
                    impact: "Improved market timing by 47%"
                )
                
                wisdomCard(
                    quote: "Success is nothing more than a few simple disciplines, practiced every day.",
                    application: "Bots follow strict daily routines: market analysis at 6 AM, position reviews at noon, and risk assessment at market close.",
                    impact: "Consistency increased by 73%"
                )
                
                wisdomCard(
                    quote: "Don't wish it were easier; wish you were better.",
                    application: "Instead of seeking easier trades, bots continuously upgrade their analysis algorithms and adapt to market changes.",
                    impact: "Learning curve accelerated by 156%"
                )
            }
        }
        .planetCard()
    }
    
    private func wisdomCard(quote: String, application: String, impact: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\"\(quote)\"")
                .font(DesignSystem.Typography.asteroid)
                .italic()
                .foregroundColor(DesignSystem.primaryGold)
                .multilineTextAlignment(.leading)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("🤖 BOT APPLICATION:")
                    .font(DesignSystem.Typography.dust)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text(application)
                    .font(DesignSystem.Typography.dust)
                    .foregroundColor(DesignSystem.starWhite.opacity(0.8))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("📊 PERFORMANCE IMPACT:")
                    .font(DesignSystem.Typography.dust)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Text(impact)
                    .font(DesignSystem.Typography.dust)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var beforeAfterSection: some View {
        VStack(spacing: 16) {
            Text("📈 BEFORE VS AFTER TRAINING")
                .font(DesignSystem.Typography.planet)
                .fontWeight(.bold)
                .cosmicText()
            
            HStack(spacing: 16) {
                // Before
                VStack(spacing: 12) {
                    Text("❌ BEFORE")
                        .font(DesignSystem.Typography.asteroid)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        comparisonRow("Win Rate:", "34%", .red)
                        comparisonRow("Risk Management:", "Basic", .red)
                        comparisonRow("Adaptability:", "Low", .red)
                        comparisonRow("Profit Factor:", "1.2x", .red)
                        comparisonRow("Market Understanding:", "Limited", .red)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
                
                // After
                VStack(spacing: 12) {
                    Text("✅ AFTER")
                        .font(DesignSystem.Typography.asteroid)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        comparisonRow("Win Rate:", "87%", .green)
                        comparisonRow("Risk Management:", "Advanced", .green)
                        comparisonRow("Adaptability:", "High", .green)
                        comparisonRow("Profit Factor:", "4.7x", .green)
                        comparisonRow("Market Understanding:", "Expert", .green)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .planetCard()
    }
    
    private func comparisonRow(_ title: String, _ value: String, _ color: Color) -> some View {
        HStack {
            Text(title)
                .font(DesignSystem.Typography.dust)
                .foregroundColor(DesignSystem.starWhite.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(DesignSystem.Typography.dust)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
    }
}

// MARK: - Training Module Model

struct TrainingModule {
    let title: String
    let icon: String
    let color: Color
    let description: String
    let details: [String]
}

#Preview {
    BotTrainingDetailsView()
}
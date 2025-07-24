//
//  PremiumPaymentView.swift
//  Planet ProTrader - Premium Bot Training
//
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

struct PremiumPaymentView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var paymentManager = PaymentManager.shared
    @State private var selectedPlan: PremiumPlan = .goldLegend
    @State private var showingPaymentSheet = false
    @State private var animateFeatures = false
    @State private var showingBotTrainingDetails = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Hero Section
                    heroSection
                    
                    // Jim Rohn Training Section
                    jimRohnSection
                    
                    // Premium Plans
                    premiumPlansSection
                    
                    // Bot Intelligence Levels
                    botIntelligenceSection
                    
                    // Success Stories
                    successStoriesSection
                    
                    // Payment Section
                    paymentSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .starField()
            .navigationTitle("💎 Premium Bot Training")
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
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5)) {
                animateFeatures = true
            }
        }
        .sheet(isPresented: $showingPaymentSheet) {
            PaymentProcessingView(plan: selectedPlan)
        }
        .sheet(isPresented: $showingBotTrainingDetails) {
            BotTrainingDetailsView()
        }
    }
    
    // MARK: - Hero Section
    
    private var heroSection: some View {
        VStack(spacing: 20) {
            // Animated logo
            ZStack {
                Circle()
                    .fill(DesignSystem.nebuladeGradient)
                    .frame(width: 120, height: 120)
                    .scaleEffect(animateFeatures ? 1.0 : 0.8)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: animateFeatures)
                
                VStack(spacing: 4) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                    
                    Text("AI")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            
            VStack(spacing: 8) {
                Text("🚀 UNLOCK LEGENDARY TRADING BOTS")
                    .font(DesignSystem.Typography.stellar)
                    .fontWeight(.black)
                    .cosmicText()
                    .multilineTextAlignment(.center)
                
                Text("Turn $100 into $100K with Jim Rohn-trained AI bots that think like millionaire traders")
                    .font(DesignSystem.Typography.asteroid)
                    .foregroundColor(DesignSystem.starWhite.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            // Key benefits
            HStack(spacing: 16) {
                benefitBadge(icon: "brain.head.profile", text: "Jim Rohn\nWisdom", color: .purple)
                benefitBadge(icon: "chart.line.uptrend.xyaxis", text: "1000X\nReturns", color: .green)
                benefitBadge(icon: "shield.checkerboard", text: "Risk\nManaged", color: .blue)
            }
        }
        .planetCard()
    }
    
    private func benefitBadge(icon: String, text: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(text)
                .font(DesignSystem.Typography.dust)
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.starWhite)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Jim Rohn Section
    
    private var jimRohnSection: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("🧠 JIM ROHN AI TRAINING")
                        .font(DesignSystem.Typography.planet)
                        .fontWeight(.bold)
                        .cosmicText()
                    
                    Text("Your bots learn from the master of personal development and wealth building")
                        .font(DesignSystem.Typography.asteroid)
                        .foregroundColor(DesignSystem.starWhite.opacity(0.7))
                }
                
                Spacer()
                
                Button(action: { showingBotTrainingDetails = true }) {
                    Image(systemName: "info.circle.fill")
                        .font(.title3)
                        .foregroundColor(DesignSystem.primaryGold)
                }
            }
            
            // Jim Rohn quotes that train the bots
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 1), spacing: 12) {
                jimRohnQuoteCard(
                    quote: "Profits are better than wages. When you work for profits, you work for yourself.",
                    principle: "Entrepreneurial Mindset",
                    botApplication: "Bots prioritize high-reward opportunities over safe, small gains"
                )
                
                jimRohnQuoteCard(
                    quote: "Don't wish it were easier; wish you were better.",
                    principle: "Continuous Improvement",
                    botApplication: "Bots continuously learn and adapt from every trade"
                )
                
                jimRohnQuoteCard(
                    quote: "Success is nothing more than a few simple disciplines, practiced every day.",
                    principle: "Consistent Excellence",
                    botApplication: "Bots follow strict risk management and trading rules daily"
                )
            }
        }
        .planetCard()
    }
    
    private func jimRohnQuoteCard(quote: String, principle: String, botApplication: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Quote
            Text("\"\(quote)\"")
                .font(DesignSystem.Typography.asteroid)
                .italic()
                .foregroundColor(DesignSystem.starWhite)
                .multilineTextAlignment(.leading)
            
            // Principle
            HStack {
                Text("📚 PRINCIPLE:")
                    .font(DesignSystem.Typography.dust)
                    .fontWeight(.bold)
                    .foregroundColor(.purple)
                
                Text(principle)
                    .font(DesignSystem.Typography.dust)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.starWhite)
            }
            
            // Bot application
            HStack(alignment: .top, spacing: 6) {
                Text("🤖 BOT LEARNS:")
                    .font(DesignSystem.Typography.dust)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text(botApplication)
                    .font(DesignSystem.Typography.dust)
                    .foregroundColor(DesignSystem.starWhite.opacity(0.8))
                    .lineLimit(3)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Premium Plans Section
    
    private var premiumPlansSection: some View {
        VStack(spacing: 20) {
            Text("💎 CHOOSE YOUR LEGEND LEVEL")
                .font(DesignSystem.Typography.planet)
                .fontWeight(.bold)
                .cosmicText()
            
            LazyVStack(spacing: 16) {
                ForEach(PremiumPlan.allCases, id: \.self) { plan in
                    premiumPlanCard(plan: plan)
                        .scaleEffect(animateFeatures ? 1.0 : 0.9)
                        .opacity(animateFeatures ? 1.0 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(plan.rawValue) * 0.1), value: animateFeatures)
                }
            }
        }
        .planetCard()
    }
    
    private func premiumPlanCard(plan: PremiumPlan) -> some View {
        Button(action: {
            withAnimation(.spring()) {
                selectedPlan = plan
            }
        }) {
            VStack(spacing: 16) {
                // Plan header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(plan.emoji)
                                .font(.title)
                            
                            Text(plan.title)
                                .font(DesignSystem.Typography.planet)
                                .fontWeight(.bold)
                                .foregroundColor(DesignSystem.starWhite)
                        }
                        
                        Text(plan.subtitle)
                            .font(DesignSystem.Typography.asteroid)
                            .foregroundColor(DesignSystem.starWhite.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        if plan.originalPrice > plan.price {
                            Text(plan.originalPrice.formatted(.currency(code: "USD")))
                                .font(DesignSystem.Typography.dust)
                                .foregroundColor(DesignSystem.starWhite.opacity(0.6))
                                .strikethrough()
                        }
                        
                        Text(plan.price.formatted(.currency(code: "USD")))
                            .font(DesignSystem.Typography.planet)
                            .fontWeight(.bold)
                            .foregroundColor(plan.color)
                        
                        if plan == .goldLegend {
                            Text("BEST VALUE")
                                .font(DesignSystem.Typography.dust)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.red)
                                .cornerRadius(4)
                        }
                    }
                }
                
                // Features grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                    ForEach(plan.features, id: \.self) { feature in
                        featureRow(feature: feature, color: plan.color)
                    }
                }
                
                // Special bot unlock
                if !plan.specialBots.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("🤖 EXCLUSIVE BOTS UNLOCKED:")
                            .font(DesignSystem.Typography.dust)
                            .fontWeight(.bold)
                            .foregroundColor(plan.color)
                        
                        ForEach(plan.specialBots, id: \.self) { bot in
                            Text("• \(bot)")
                                .font(DesignSystem.Typography.dust)
                                .foregroundColor(DesignSystem.starWhite.opacity(0.8))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
                }
            }
            .padding(20)
            .background(
                selectedPlan == plan 
                ? plan.color.opacity(0.1)
                : Color.clear
            )
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        selectedPlan == plan ? plan.color : Color.clear,
                        lineWidth: selectedPlan == plan ? 3 : 0
                    )
                    .animation(.spring(), value: selectedPlan)
            )
            .shadow(
                color: selectedPlan == plan ? plan.color.opacity(0.3) : .clear,
                radius: selectedPlan == plan ? 10 : 0,
                x: 0,
                y: selectedPlan == plan ? 5 : 0
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func featureRow(feature: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
                .font(DesignSystem.Typography.dust)
                .foregroundColor(color)
            
            Text(feature)
                .font(DesignSystem.Typography.dust)
                .foregroundColor(DesignSystem.starWhite)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Bot Intelligence Levels
    
    private var botIntelligenceSection: some View {
        VStack(spacing: 16) {
            Text("🧠 BOT INTELLIGENCE EVOLUTION")
                .font(DesignSystem.Typography.planet)
                .fontWeight(.bold)
                .cosmicText()
            
            // Intelligence progression
            HStack(spacing: 0) {
                ForEach(0..<5) { level in
                    intelligenceLevelNode(level: level + 1, isUnlocked: level < 3)
                    
                    if level < 4 {
                        Rectangle()
                            .fill(level < 2 ? DesignSystem.primaryGold : DesignSystem.starWhite.opacity(0.4))
                            .frame(height: 2)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            
            // Level descriptions
            VStack(spacing: 12) {
                levelDescription(
                    level: 1,
                    title: "BASIC TRADER",
                    description: "Simple buy/sell logic, basic risk management",
                    profitRange: "$10-$100/day"
                )
                
                levelDescription(
                    level: 2,
                    title: "SMART ANALYST",
                    description: "Technical analysis, pattern recognition",
                    profitRange: "$100-$1K/day"
                )
                
                levelDescription(
                    level: 3,
                    title: "JIM ROHN TRAINED",
                    description: "Wealth mindset, compound thinking",
                    profitRange: "$1K-$10K/day",
                    isCurrentMax: true
                )
                
                levelDescription(
                    level: 4,
                    title: "MARKET GENIUS",
                    description: "Multi-market arbitrage, deep learning",
                    profitRange: "$10K-$50K/day",
                    isLocked: true
                )
                
                levelDescription(
                    level: 5,
                    title: "LEGEND STATUS",
                    description: "Hedge fund level strategies, AI superintelligence",
                    profitRange: "$50K-$100K+/day",
                    isLocked: true
                )
            }
        }
        .planetCard()
    }
    
    private func intelligenceLevelNode(level: Int, isUnlocked: Bool) -> some View {
        ZStack {
            Circle()
                .fill(isUnlocked ? DesignSystem.primaryGold : DesignSystem.starWhite.opacity(0.4))
                .frame(width: 30, height: 30)
            
            if isUnlocked {
                Text("\(level)")
                    .font(DesignSystem.Typography.dust)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            } else {
                Image(systemName: "lock.fill")
                    .font(DesignSystem.Typography.dust)
                    .foregroundColor(.white)
            }
        }
    }
    
    private func levelDescription(level: Int, title: String, description: String, profitRange: String, isCurrentMax: Bool = false, isLocked: Bool = false) -> some View {
        HStack(spacing: 12) {
            // Level indicator
            ZStack {
                Circle()
                    .fill(isLocked ? DesignSystem.starWhite.opacity(0.4) : DesignSystem.primaryGold)
                    .frame(width: 24, height: 24)
                
                Text("\(level)")
                    .font(DesignSystem.Typography.dust)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(DesignSystem.Typography.dust)
                        .fontWeight(.bold)
                        .foregroundColor(isLocked ? DesignSystem.starWhite.opacity(0.6) : DesignSystem.starWhite)
                    
                    if isCurrentMax {
                        Text("CURRENT MAX")
                            .font(DesignSystem.Typography.dust)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(DesignSystem.primaryGold)
                            .cornerRadius(3)
                    }
                    
                    if isLocked {
                        Text("PREMIUM ONLY")
                            .font(DesignSystem.Typography.dust)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.red)
                            .cornerRadius(3)
                    }
                }
                
                Text(description)
                    .font(DesignSystem.Typography.dust)
                    .foregroundColor(DesignSystem.starWhite.opacity(0.7))
                
                Text("💰 \(profitRange)")
                    .font(DesignSystem.Typography.dust)
                    .fontWeight(.semibold)
                    .foregroundColor(isLocked ? DesignSystem.starWhite.opacity(0.6) : .green)
            }
            
            Spacer()
        }
        .padding(.horizontal, 8)
        .opacity(isLocked ? 0.6 : 1.0)
    }
    
    // MARK: - Success Stories
    
    private var successStoriesSection: some View {
        VStack(spacing: 16) {
            Text("🏆 SUCCESS STORIES")
                .font(DesignSystem.Typography.planet)
                .fontWeight(.bold)
                .cosmicText()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    successStoryCard(
                        name: "Mike T.",
                        story: "Turned $500 into $47K in 2 weeks with Gold Legend bot",
                        profit: "$46,500",
                        timeframe: "14 days"
                    )
                    
                    successStoryCard(
                        name: "Sarah L.",
                        story: "Bot learned my trading style and 10x my account",
                        profit: "$23,750",
                        timeframe: "1 month"
                    )
                    
                    successStoryCard(
                        name: "David R.",
                        story: "Jim Rohn wisdom + AI = unstoppable combination",
                        profit: "$89,200",
                        timeframe: "6 weeks"
                    )
                }
                .padding(.horizontal, 20)
            }
        }
        .planetCard()
    }
    
    private func successStoryCard(name: String, story: String, profit: String, timeframe: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("👤 \(name)")
                    .font(DesignSystem.Typography.asteroid)
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.starWhite)
                
                Spacer()
                
                Text("✅ VERIFIED")
                    .font(DesignSystem.Typography.dust)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Color.green)
                    .cornerRadius(3)
            }
            
            Text(story)
                .font(DesignSystem.Typography.asteroid)
                .foregroundColor(DesignSystem.starWhite.opacity(0.8))
                .lineLimit(3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("💰 PROFIT: \(profit)")
                    .font(DesignSystem.Typography.dust)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Text("⏱️ TIME: \(timeframe)")
                    .font(DesignSystem.Typography.dust)
                    .foregroundColor(DesignSystem.starWhite.opacity(0.7))
            }
        }
        .padding(16)
        .frame(width: 250)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Payment Section
    
    private var paymentSection: some View {
        VStack(spacing: 20) {
            Text("🚀 START YOUR LEGEND JOURNEY")
                .font(DesignSystem.Typography.planet)
                .fontWeight(.bold)
                .cosmicText()
            
            // Selected plan summary
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedPlan.emoji + " " + selectedPlan.title)
                        .font(DesignSystem.Typography.moon)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.starWhite)
                    
                    Text(selectedPlan.subtitle)
                        .font(DesignSystem.Typography.asteroid)
                        .foregroundColor(DesignSystem.starWhite.opacity(0.7))
                }
                
                Spacer()
                
                Text(selectedPlan.price.formatted(.currency(code: "USD")))
                    .font(DesignSystem.Typography.stellar)
                    .fontWeight(.bold)
                    .foregroundColor(selectedPlan.color)
            }
            .padding(16)
            .background(selectedPlan.color.opacity(0.1))
            .cornerRadius(12)
            
            // Payment button
            Button(action: {
                showingPaymentSheet = true
            }) {
                HStack {
                    Image(systemName: "creditcard.fill")
                        .font(.title3)
                    
                    Text("UNLOCK LEGEND BOTS NOW")
                        .font(DesignSystem.Typography.moon)
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [selectedPlan.color, selectedPlan.color.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .shadow(color: selectedPlan.color.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            
            // Guarantee
            HStack(spacing: 8) {
                Image(systemName: "shield.checkered")
                    .font(.title3)
                    .foregroundColor(.green)
                
                Text("30-day money-back guarantee • Cancel anytime")
                    .font(DesignSystem.Typography.dust)
                    .foregroundColor(DesignSystem.starWhite.opacity(0.7))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.green.opacity(0.1))
            .cornerRadius(8)
        }
        .planetCard()
    }
}

// MARK: - Premium Plan Model

enum PremiumPlan: Int, CaseIterable {
    case starter = 0
    case goldLegend = 1
    case ultimate = 2
    
    var emoji: String {
        switch self {
        case .starter: return "🚀"
        case .goldLegend: return "👑"
        case .ultimate: return "💎"
        }
    }
    
    var title: String {
        switch self {
        case .starter: return "LEGEND STARTER"
        case .goldLegend: return "GOLD LEGEND"
        case .ultimate: return "ULTIMATE LEGEND"
        }
    }
    
    var subtitle: String {
        switch self {
        case .starter: return "Perfect for beginners"
        case .goldLegend: return "Most popular choice"
        case .ultimate: return "Maximum potential"
        }
    }
    
    var price: Double {
        switch self {
        case .starter: return 97.0
        case .goldLegend: return 197.0
        case .ultimate: return 497.0
        }
    }
    
    var originalPrice: Double {
        switch self {
        case .starter: return 197.0
        case .goldLegend: return 397.0
        case .ultimate: return 997.0
        }
    }
    
    var color: Color {
        switch self {
        case .starter: return .blue
        case .goldLegend: return DesignSystem.primaryGold
        case .ultimate: return .purple
        }
    }
    
    var features: [String] {
        switch self {
        case .starter:
            return [
                "3 Basic Trading Bots",
                "Jim Rohn Quotes Training",
                "Basic Risk Management",
                "Email Support",
                "Mobile App Access",
                "Basic Analytics"
            ]
        case .goldLegend:
            return [
                "10 Premium Trading Bots",
                "Full Jim Rohn Library",
                "Advanced Risk Management",
                "24/7 Priority Support",
                "Advanced Analytics",
                "Bot Customization",
                "Live Trading Signals",
                "Community Access"
            ]
        case .ultimate:
            return [
                "Unlimited Trading Bots",
                "AI Personality Training",
                "White-label Rights",
                "1-on-1 Coaching Call",
                "Custom Bot Development",
                "API Access",
                "Hedge Fund Strategies",
                "Lifetime Updates"
            ]
        }
    }
    
    var specialBots: [String] {
        switch self {
        case .starter:
            return ["Basic Trend Follower", "Simple Scalper", "Risk Guardian"]
        case .goldLegend:
            return ["Quantum AI Pro", "Gold Scalper Elite", "Trend Master 3000", "Jim Rohn Wisdom Bot"]
        case .ultimate:
            return ["All Premium Bots", "Custom AI Personalities", "Hedge Fund Replicator", "Warren Buffett AI"]
        }
    }
}

#Preview {
    PremiumPaymentView()
}
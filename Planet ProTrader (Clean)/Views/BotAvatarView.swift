//
//  BotAvatarView.swift
//  Planet ProTrader (Clean)
//
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

struct BotAvatarView: View {
    let bot: MarketplaceBotModel
    let size: CGFloat
    let showEffects: Bool
    
    @State private var isAnimating = false
    @State private var sparkleOffset: CGFloat = 0
    @State private var glowIntensity: Double = 0.5
    
    init(bot: MarketplaceBotModel, size: CGFloat = 80, showEffects: Bool = true) {
        self.bot = bot
        self.size = size
        self.showEffects = showEffects
    }
    
    var body: some View {
        ZStack {
            // Base avatar circle
            baseAvatar
            
            // Bot initials or icon
            botContent
            
            // Rarity effects
            if showEffects {
                rarityEffects
            }
            
            // Sparkle effects for high-tier bots
            if showEffects && (bot.rarity == .legendary || bot.rarity == .mythic || bot.rarity == .godTier) {
                sparkleEffects
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            startAnimations()
        }
    }
    
    // MARK: - Base Avatar
    
    private var baseAvatar: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: avatarGradientColors,
                    center: .topLeading,
                    startRadius: size * 0.1,
                    endRadius: size * 0.6
                )
            )
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                bot.rarity.color.opacity(0.8),
                                bot.rarity.color.opacity(0.3),
                                bot.rarity.color.opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: size * 0.04
                    )
            )
            .shadow(
                color: bot.rarity.color.opacity(0.6),
                radius: showEffects ? size * 0.1 : size * 0.05,
                x: 0,
                y: showEffects ? size * 0.05 : size * 0.02
            )
            .scaleEffect(isAnimating ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
    }
    
    private var avatarGradientColors: [Color] {
        switch bot.rarity {
        case .common:
            return [Color(.systemGray4), Color(.systemGray5)]
        case .uncommon:
            return [Color.green.opacity(0.7), Color.green.opacity(0.3)]
        case .rare:
            return [Color.blue.opacity(0.7), Color.blue.opacity(0.3)]
        case .epic:
            return [Color.purple.opacity(0.7), Color.purple.opacity(0.3)]
        case .legendary:
            return [Color.orange.opacity(0.8), Color.yellow.opacity(0.4)]
        case .mythic:
            return [Color.red.opacity(0.8), Color.pink.opacity(0.4)]
        case .godTier:
            return [DesignSystem.primaryGold, Color.yellow, DesignSystem.primaryGold.opacity(0.3)]
        }
    }
    
    // MARK: - Bot Content
    
    private var botContent: some View {
        ZStack {
            // Bot initials
            Text(botInitials)
                .font(.system(size: size * 0.3, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
            
            // Trading style indicator
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    
                    Image(systemName: tradingStyleIcon)
                        .font(.system(size: size * 0.15, weight: .bold))
                        .foregroundColor(bot.tradingStyle.color)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: size * 0.25, height: size * 0.25)
                        )
                        .offset(x: size * 0.1, y: size * 0.1)
                }
            }
        }
    }
    
    private var botInitials: String {
        let words = bot.name.components(separatedBy: " ")
        if words.count >= 2 {
            return String(words[0].prefix(1)) + String(words[1].prefix(1))
        } else {
            return String(bot.name.prefix(2))
        }
    }
    
    private var tradingStyleIcon: String {
        switch bot.tradingStyle {
        case .scalping: return "bolt.fill"
        case .dayTrading: return "sun.max.fill"
        case .swingTrading: return "wave.3.right"
        case .positionTrading: return "chart.line.uptrend.xyaxis"
        case .algorithmic: return "cpu.fill"
        case .highFrequency: return "bolt.circle.fill"
        case .arbitrage: return "arrow.left.arrow.right"
        case .momentum: return "arrow.up.right"
        case .meanReversion: return "arrow.clockwise"
        case .breakout: return "arrow.up.circle"
        case .contrarian: return "arrow.turn.up.left"
        case .gridTrading: return "grid"
        case .newsTrading: return "newspaper.fill"
        case .socialTrading: return "person.2.fill"
        }
    }
    
    // MARK: - Rarity Effects
    
    private var rarityEffects: some View {
        ZStack {
            // Glow effect for epic+ bots
            if bot.rarity.rawValue != "Common" && bot.rarity.rawValue != "Uncommon" {
                Circle()
                    .fill(bot.rarity.color.opacity(0.3))
                    .blur(radius: size * 0.08)
                    .scaleEffect(1.3)
                    .opacity(glowIntensity)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: glowIntensity)
            }
            
            // Pulsing ring for legendary+ bots
            if bot.rarity == .legendary || bot.rarity == .mythic || bot.rarity == .godTier {
                Circle()
                    .stroke(
                        bot.rarity.color.opacity(0.6),
                        lineWidth: size * 0.02
                    )
                    .scaleEffect(isAnimating ? 1.4 : 1.2)
                    .opacity(isAnimating ? 0.0 : 0.8)
                    .animation(.easeOut(duration: 2.0).repeatForever(), value: isAnimating)
            }
        }
    }
    
    // MARK: - Sparkle Effects
    
    private var sparkleEffects: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { index in
                Circle()
                    .fill(Color.white)
                    .frame(width: size * 0.04, height: size * 0.04)
                    .offset(
                        x: cos(Double(index) * .pi / 4) * (size * 0.7) + sparkleOffset,
                        y: sin(Double(index) * .pi / 4) * (size * 0.7) + sparkleOffset
                    )
                    .opacity(Double.random(in: 0.3...1.0))
                    .scaleEffect(Double.random(in: 0.5...1.5))
                    .animation(
                        .easeInOut(duration: Double.random(in: 1.0...2.0))
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.2),
                        value: sparkleOffset
                    )
            }
        }
        .rotationEffect(.degrees(isAnimating ? 360 : 0))
        .animation(.linear(duration: 20.0).repeatForever(autoreverses: false), value: isAnimating)
    }
    
    // MARK: - Animation Control
    
    private func startAnimations() {
        if showEffects {
            withAnimation {
                isAnimating = true
                sparkleOffset = 10
                glowIntensity = 0.8
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 30) {
        Text("🤖 Bot Avatar Showcase")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(DesignSystem.primaryGold)
        
        HStack(spacing: 20) {
            VStack(spacing: 8) {
                BotAvatarView(
                    bot: MarketplaceBotModel(
                        name: "Golden Eagle Pro",
                        creatorUsername: "TradeMaster",
                        tagline: "Advanced gold trading",
                        valueProposition: "Premium trading bot",
                        description: "Advanced AI trading algorithms",
                        price: 999.99,
                        rarity: .godTier,
                        tier: .expert,
                        verificationStatus: .verified,
                        availability: .exclusive,
                        stats: BotStats(
                            totalReturn: 500.0,
                            winRate: 95.0,
                            totalTrades: 1000,
                            totalUsers: 10,
                            maxDrawdown: 2.0,
                            sharpeRatio: 3.5,
                            universeRank: 1,
                            performanceGrade: "S+"
                        ),
                        reviews: [],
                        tags: ["Premium", "AI"],
                        createdDate: Date(),
                        lastUpdated: Date(),
                        character: BotCharacter(
                            avatar: "🦅",
                            personality: "Aggressive",
                            specialties: ["Gold Trading"],
                            catchPhrase: "Golden profits!"
                        ),
                        tradingStyle: .algorithmic,
                        isCustomizable: true,
                        currentPitch: "I'm the best at gold trading!",
                        hasSpecialOffer: false
                    ),
                    size: 100,
                    showEffects: true
                )
                
                Text("God Tier")
                    .font(.caption)
                    .foregroundColor(DesignSystem.primaryGold)
            }
            
            VStack(spacing: 8) {
                BotAvatarView(
                    bot: MarketplaceBotModel(
                        name: "Scalp Master",
                        creatorUsername: "QuickTrader",
                        tagline: "Lightning fast",
                        valueProposition: "Fast scalping bot",
                        description: "Ultra-fast scalping algorithms",
                        price: 299.99,
                        rarity: .legendary,
                        tier: .professional,
                        verificationStatus: .verified,
                        availability: .available,
                        stats: BotStats(
                            totalReturn: 200.0,
                            winRate: 80.0,
                            totalTrades: 500,
                            totalUsers: 50,
                            maxDrawdown: 10.0,
                            sharpeRatio: 2.5,
                            universeRank: 15,
                            performanceGrade: "A+"
                        ),
                        reviews: [],
                        tags: ["Fast", "Scalping"],
                        createdDate: Date(),
                        lastUpdated: Date(),
                        character: BotCharacter(
                            avatar: "⚡",
                            personality: "Aggressive",
                            specialties: ["Scalping"],
                            catchPhrase: "Speed is money!"
                        ),
                        tradingStyle: .scalping,
                        isCustomizable: true,
                        currentPitch: "I'm the fastest trader!",
                        hasSpecialOffer: false
                    ),
                    size: 100,
                    showEffects: true
                )
                
                Text("Legendary")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            
            VStack(spacing: 8) {
                BotAvatarView(
                    bot: MarketplaceBotModel(
                        name: "Safe Trader",
                        creatorUsername: "SafeTrader",
                        tagline: "Conservative approach",
                        valueProposition: "Safe and steady",
                        description: "Conservative trading approach",
                        price: 29.99,
                        rarity: .common,
                        tier: .beginner,
                        verificationStatus: .verified,
                        availability: .available,
                        stats: BotStats(
                            totalReturn: 25.0,
                            winRate: 60.0,
                            totalTrades: 100,
                            totalUsers: 200,
                            maxDrawdown: 5.0,
                            sharpeRatio: 1.2,
                            universeRank: 500,
                            performanceGrade: "B"
                        ),
                        reviews: [],
                        tags: ["Safe", "Conservative"],
                        createdDate: Date(),
                        lastUpdated: Date(),
                        character: BotCharacter(
                            avatar: "🛡️",
                            personality: "Conservative",
                            specialties: ["Risk Management"],
                            catchPhrase: "Steady wins!"
                        ),
                        tradingStyle: .dayTrading,
                        isCustomizable: false,
                        currentPitch: "Safe and reliable trading!",
                        hasSpecialOffer: false
                    ),
                    size: 100,
                    showEffects: true
                )
                
                Text("Common")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
    .padding()
}
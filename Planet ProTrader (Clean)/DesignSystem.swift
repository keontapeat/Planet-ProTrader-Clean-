//
//  DesignSystem.swift
//  Planet ProTrader - Solar System Edition
//
//  Ultra-Modern Cosmic Design System
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI
import Foundation

struct DesignSystem {
    
    // MARK: - Cosmic Colors
    static let spaceBlack = Color(red: 0.08, green: 0.08, blue: 0.12) // #141421
    static let deepSpace = Color(red: 0.12, green: 0.12, blue: 0.18) // #1F1F2E
    static let cosmicBlue = Color(red: 0.2, green: 0.4, blue: 0.8) // #3366CC
    static let stellarPurple = Color(red: 0.4, green: 0.2, blue: 0.8) // #6633CC
    static let nebulaPink = Color(red: 0.8, green: 0.2, blue: 0.6) // #CC3399
    static let solarOrange = Color(red: 1.0, green: 0.6, blue: 0.2) // #FF9933
    static let planetGreen = Color(red: 0.2, green: 0.8, blue: 0.4) // #33CC66
    static let starWhite = Color(red: 0.95, green: 0.95, blue: 1.0) // #F2F2FF
    
    // Trading Colors
    static let profitGreen = Color(red: 0.0, green: 0.9, blue: 0.4) // #00E666
    static let lossRed = Color(red: 0.9, green: 0.2, blue: 0.2) // #E63333
    static let neutralBlue = Color(red: 0.3, green: 0.7, blue: 1.0) // #4DB3FF
    
    // Backward Compatibility - Gold Colors
    static let primaryGold = solarOrange // Map gold to solar orange
    static let secondaryGold = Color(red: 1.0, green: 0.647, blue: 0.0) // #FFA500
    static let accentGold = Color(red: 0.855, green: 0.647, blue: 0.125) // #DAA520
    
    static let tradingGreen = profitGreen
    static let tradingRed = lossRed
    static let tradingBlue = neutralBlue
    
    static let successGreen = Color.green
    static let dangerRed = Color.red
    static let warningOrange = Color.orange
    static let infoBlue = Color.blue
    
    // MARK: - Cosmic Gradients
    static let galaxyGradient = LinearGradient(
        colors: [spaceBlack, deepSpace, cosmicBlue.opacity(0.3)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let nebuladeGradient = LinearGradient(
        colors: [stellarPurple, nebulaPink, solarOrange],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let solarGradient = LinearGradient(
        colors: [solarOrange, Color.yellow, starWhite],
        startPoint: .center,
        endPoint: .bottom
    )
    
    static let planetEarthGradient = LinearGradient(
        colors: [planetGreen, cosmicBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let spaceGradient = RadialGradient(
        colors: [spaceBlack, deepSpace.opacity(0.8), cosmicBlue.opacity(0.2)],
        center: .center,
        startRadius: 50,
        endRadius: 400
    )
    
    // Backward Compatibility - Gold Gradients
    static let goldGradient = LinearGradient(
        colors: [primaryGold, secondaryGold],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let premiumGradient = LinearGradient(
        colors: [primaryGold, accentGold, secondaryGold],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let backgroundGradient = LinearGradient(
        colors: [
            Color(.systemBackground),
            primaryGold.opacity(0.05),
            Color(.systemBackground)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - Typography
    struct Typography {
        static let cosmic = Font.system(size: 34, weight: .black, design: .rounded)
        static let stellar = Font.system(size: 28, weight: .heavy, design: .rounded)
        static let planet = Font.system(size: 22, weight: .bold, design: .rounded)
        static let moon = Font.system(size: 17, weight: .semibold, design: .default)
        static let asteroid = Font.system(size: 14, weight: .medium, design: .default)
        static let dust = Font.system(size: 12, weight: .regular, design: .default)
        
        // Backward Compatibility
        static let largeTitle = cosmic
        static let title1 = stellar
        static let title2 = planet
        static let headline = moon
        static let body = asteroid
        static let caption = dust
        
        // Trading-specific
        static let priceFont = Font.system(size: 36, weight: .black, design: .monospaced)
        static let metricFont = Font.system(size: 16, weight: .bold, design: .rounded)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let asteroid: CGFloat = 4
        static let moon: CGFloat = 8
        static let planet: CGFloat = 16
        static let star: CGFloat = 24
        static let galaxy: CGFloat = 32
        static let universe: CGFloat = 48
        
        // Backward Compatibility
        static let xs = asteroid
        static let sm = moon
        static let md = planet
        static let lg = star
        static let xl = galaxy
    }
    
    // MARK: - Corner Radius
    struct Radius {
        static let meteor: CGFloat = 8
        static let planet: CGFloat = 16
        static let star: CGFloat = 24
        static let blackHole: CGFloat = 50
    }
    
    // Backward Compatibility
    struct CornerRadius {
        static let sm = Radius.meteor
        static let md = Radius.planet
        static let lg = Radius.star
        static let xl = Radius.blackHole
    }
    
    // MARK: - Animations
    struct Animation {
        static let orbit = SwiftUI.Animation.linear(duration: 20.0).repeatForever(autoreverses: false)
        static let pulse = SwiftUI.Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)
        static let sparkle = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.6)
        static let warp = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let hyperspace = SwiftUI.Animation.spring(response: 0.8, dampingFraction: 0.9)
        
        // Backward Compatibility
        static let quick = warp
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let spring = SwiftUI.Animation.spring(response: 0.6, dampingFraction: 0.8)
        static let bouncy = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.6)
    }
}

// MARK: - Cosmic View Extensions
extension View {
    func solarCard() -> some View {
        self
            .padding(DesignSystem.Spacing.planet)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.Radius.planet))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.planet)
                    .stroke(DesignSystem.cosmicBlue.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: DesignSystem.cosmicBlue.opacity(0.2), radius: 12, x: 0, y: 6)
    }
    
    // Backward Compatibility
    func standardCard() -> some View {
        self.solarCard()
    }
    
    func planetCard() -> some View {
        self
            .padding(DesignSystem.Spacing.star)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.Radius.star))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.star)
                    .stroke(DesignSystem.nebuladeGradient, lineWidth: 2)
            )
            .shadow(color: DesignSystem.stellarPurple.opacity(0.4), radius: 16, x: 0, y: 8)
    }
    
    // Backward Compatibility
    func premiumCard() -> some View {
        self.planetCard()
    }
    
    func starField() -> some View {
        self.background(DesignSystem.spaceGradient)
    }
    
    func cosmicText() -> some View {
        self.foregroundStyle(DesignSystem.nebuladeGradient)
    }
    
    // Backward Compatibility
    func goldText() -> some View {
        self.cosmicText()
    }
    
    func solarText() -> some View {
        self.foregroundStyle(DesignSystem.solarGradient)
    }
    
    func profitLossText(_ isProfit: Bool) -> some View {
        self.foregroundColor(isProfit ? DesignSystem.profitGreen : DesignSystem.lossRed)
    }
    
    // Backward Compatibility
    func profitText(_ isProfit: Bool) -> some View {
        self.profitLossText(isProfit)
    }
    
    func orbitingEffect(_ isActive: Bool = true) -> some View {
        self
            .rotationEffect(.degrees(isActive ? 360 : 0))
            .animation(isActive ? DesignSystem.Animation.orbit : .none, value: isActive)
    }
    
    func pulsingEffect(_ isActive: Bool = true) -> some View {
        self
            .scaleEffect(isActive ? 1.1 : 1.0)
            .opacity(isActive ? 0.8 : 1.0)
            .animation(isActive ? DesignSystem.Animation.pulse : .none, value: isActive)
    }
    
    // Backward Compatibility
    func pulseEffect(_ isActive: Bool = true) -> some View {
        self.pulsingEffect(isActive)
    }
    
    func sparkleEffect() -> some View {
        self
            .overlay(
                ZStack {
                    ForEach(0..<5) { i in
                        Circle()
                            .fill(DesignSystem.starWhite)
                            .frame(width: 2, height: 2)
                            .offset(
                                x: CGFloat.random(in: -50...50),
                                y: CGFloat.random(in: -50...50)
                            )
                            .opacity(Double.random(in: 0.3...1.0))
                            .animation(
                                DesignSystem.Animation.sparkle
                                    .delay(Double(i) * 0.2),
                                value: UUID()
                            )
                    }
                }
            )
    }
}

// MARK: - Cosmic Button Styles
struct CosmicButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.moon)
            .foregroundColor(DesignSystem.starWhite)
            .padding(.horizontal, DesignSystem.Spacing.star)
            .padding(.vertical, DesignSystem.Spacing.planet)
            .background(DesignSystem.nebuladeGradient, in: RoundedRectangle(cornerRadius: DesignSystem.Radius.planet))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.planet)
                    .stroke(DesignSystem.starWhite.opacity(0.2), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .brightness(configuration.isPressed ? -0.1 : 0)
            .animation(DesignSystem.Animation.warp, value: configuration.isPressed)
            .shadow(color: DesignSystem.stellarPurple.opacity(0.5), radius: 8)
    }
}

struct SolarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.moon)
            .foregroundColor(.white)
            .padding(.horizontal, DesignSystem.Spacing.star)
            .padding(.vertical, DesignSystem.Spacing.planet)
            .background(DesignSystem.solarGradient, in: RoundedRectangle(cornerRadius: DesignSystem.Radius.planet))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .brightness(configuration.isPressed ? -0.1 : 0)
            .animation(DesignSystem.Animation.warp, value: configuration.isPressed)
            .shadow(color: DesignSystem.solarOrange.opacity(0.5), radius: 8)
    }
}

// Backward Compatibility - Primary Button Style
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.headline)
            .foregroundColor(.white)
            .padding(.horizontal, DesignSystem.Spacing.star)
            .padding(.vertical, DesignSystem.Spacing.planet)
            .background(DesignSystem.nebuladeGradient, in: RoundedRectangle(cornerRadius: DesignSystem.Radius.planet))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(DesignSystem.Animation.warp, value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == CosmicButtonStyle {
    static var cosmic: CosmicButtonStyle { CosmicButtonStyle() }
}

extension ButtonStyle where Self == SolarButtonStyle {
    static var solar: SolarButtonStyle { SolarButtonStyle() }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }
}

#Preview {
    ZStack {
        DesignSystem.spaceGradient
            .ignoresSafeArea()
        
        VStack(spacing: 24) {
            Text("Planet ProTrader")
                .font(DesignSystem.Typography.cosmic)
                .cosmicText()
                .sparkleEffect()
            
            Text("Solar System Dashboard")
                .font(DesignSystem.Typography.stellar)
                .solarText()
            
            Text("Trading in the cosmos")
                .solarCard()
                .pulsingEffect()
            
            Text("Premium Space Trading")
                .planetCard()
                .orbitingEffect()
            
            HStack(spacing: 20) {
                Button("Deploy Bot") {}
                    .buttonStyle(.cosmic)
                
                Button("Trade Now") {}
                    .buttonStyle(.solar)
            }
            
            HStack(spacing: 16) {
                Text("$2,374.85")
                    .font(DesignSystem.Typography.priceFont)
                    .profitLossText(true)
                
                Text("+$45.30")
                    .font(DesignSystem.Typography.metricFont)
                    .profitLossText(true)
            }
            .solarCard()
        }
        .padding()
    }
}
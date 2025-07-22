//
//  DesignSystem.swift
//  Planet ProTrader - Clean Foundation
//
//  Complete Professional Design System
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI
import Foundation

struct DesignSystem {
    
    // MARK: - Colors
    static let primaryGold = Color(red: 1.0, green: 0.843, blue: 0.0) // #FFD700
    static let secondaryGold = Color(red: 1.0, green: 0.647, blue: 0.0) // #FFA500
    static let accentGold = Color(red: 0.855, green: 0.647, blue: 0.125) // #DAA520
    
    static let tradingGreen = Color(red: 0.0, green: 0.8, blue: 0.0) // #00CC00
    static let tradingRed = Color(red: 0.9, green: 0.0, blue: 0.0) // #E60000
    static let tradingBlue = Color(red: 0.0, green: 0.478, blue: 1.0) // #007AFF
    
    static let successGreen = Color.green
    static let dangerRed = Color.red
    static let warningOrange = Color.orange
    static let infoBlue = Color.blue
    
    // MARK: - Gradients
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
        static let largeTitle = Font.system(size: 34, weight: .black, design: .rounded)
        static let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
        static let title2 = Font.system(size: 22, weight: .bold, design: .rounded)
        static let headline = Font.system(size: 17, weight: .semibold, design: .default)
        static let body = Font.system(size: 17, weight: .regular, design: .default)
        static let caption = Font.system(size: 12, weight: .regular, design: .default)
        
        // Trading-specific
        static let priceFont = Font.system(size: 32, weight: .black, design: .monospaced)
        static let metricFont = Font.system(size: 14, weight: .semibold, design: .rounded)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
    }
    
    // MARK: - Animation
    struct Animation {
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let spring = SwiftUI.Animation.spring(response: 0.6, dampingFraction: 0.8)
        static let bouncy = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.6)
    }
}

// MARK: - View Extensions
extension View {
    func standardCard() -> some View {
        self
            .padding(DesignSystem.Spacing.md)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    func premiumCard() -> some View {
        self
            .padding(DesignSystem.Spacing.lg)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .stroke(DesignSystem.goldGradient, lineWidth: 1)
            )
            .shadow(color: DesignSystem.primaryGold.opacity(0.3), radius: 12, x: 0, y: 6)
    }
    
    func goldText() -> some View {
        self.foregroundStyle(DesignSystem.goldGradient)
    }
    
    func profitText(_ isProfit: Bool) -> some View {
        self.foregroundColor(isProfit ? DesignSystem.tradingGreen : DesignSystem.tradingRed)
    }
    
    func pulseEffect(_ isActive: Bool = true) -> some View {
        self
            .scaleEffect(isActive ? 1.05 : 1.0)
            .animation(
                isActive ? 
                DesignSystem.Animation.spring.repeatForever(autoreverses: true) :
                DesignSystem.Animation.standard,
                value: isActive
            )
    }
}

// MARK: - Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.headline)
            .foregroundColor(.white)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(DesignSystem.goldGradient, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(DesignSystem.Animation.quick, value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }
}

#Preview {
    VStack(spacing: 20) {
        Text("Design System Preview")
            .font(DesignSystem.Typography.largeTitle)
            .goldText()
        
        Text("Professional UI Components")
            .standardCard()
        
        Text("Premium Card Example")
            .premiumCard()
        
        Button("Primary Button") {
            // Action
        }
        .buttonStyle(.primary)
        
        HStack(spacing: 16) {
            Text("$2,374.85")
                .font(DesignSystem.Typography.priceFont)
                .profitText(true)
            
            Text("+$45.30")
                .font(DesignSystem.Typography.metricFont)
                .profitText(true)
        }
        .standardCard()
    }
    .padding()
    .background(DesignSystem.backgroundGradient)
}
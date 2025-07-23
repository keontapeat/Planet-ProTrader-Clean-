//
//  OnboardingView.swift
//  Planet ProTrader - Cosmic Onboarding Experience
//
//  Epic Interstellar Journey to Trading Excellence
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI
import AVFoundation

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var isAnimating = false
    @State private var showContent = false
    @Binding var hasCompletedOnboarding: Bool
    
    @StateObject private var audioPlayer = BackgroundAudioPlayer.shared
    
    let pages = OnboardingPage.allPages
    
    var body: some View {
        ZStack {
            // Background
            backgroundView
            
            // Content
            if showContent {
                contentView
            }
            
            // Navigation
            if showContent {
                navigationView
            }
        }
        .preferredColorScheme(.dark)
        .ignoresSafeArea()
        .onAppear {
            startOnboarding()
        }
        .onDisappear {
            audioPlayer.stop()
        }
    }
    
    private var backgroundView: some View {
        DesignSystem.spaceGradient
            .ignoresSafeArea()
    }
    
    private var contentView: some View {
        TabView(selection: $currentPage) {
            ForEach(0..<pages.count, id: \.self) { index in
                pageView(for: pages[index], at: index)
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .opacity(showContent ? 1 : 0)
        .animation(.easeInOut(duration: 0.5), value: showContent)
    }
    
    private var navigationView: some View {
        VStack {
            Spacer()
            
            HStack {
                // Page indicators
                pageIndicators
                
                Spacer()
                
                // Buttons
                navigationButtons
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 50)
        }
        .opacity(showContent ? 1 : 0)
        .animation(.easeInOut(duration: 0.8), value: showContent)
    }
    
    private var pageIndicators: some View {
        HStack(spacing: 12) {
            ForEach(0..<pages.count, id: \.self) { index in
                let isActive = index == currentPage
                Circle()
                    .fill(isActive ? DesignSystem.cosmicBlue : Color.white.opacity(0.3))
                    .frame(width: isActive ? 12 : 8, height: isActive ? 12 : 8)
                    .scaleEffect(isActive ? 1.2 : 1.0)
                    .animation(.spring(), value: currentPage)
            }
        }
    }
    
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            if currentPage < pages.count - 1 {
                skipButton
                nextButton
            } else {
                launchButton
            }
        }
    }
    
    private var skipButton: some View {
        Button("Skip") {
            ButtonSFXPlayer.play()
            completeOnboarding()
        }
        .font(DesignSystem.Typography.asteroid)
        .foregroundColor(DesignSystem.starWhite.opacity(0.7))
    }
    
    private var nextButton: some View {
        Button("Next") {
            ButtonSFXPlayer.play()
            withAnimation(.spring()) {
                currentPage += 1
            }
        }
        .buttonStyle(.cosmic)
    }
    
    private var launchButton: some View {
        Button("🚀 Launch Mission") {
            ButtonSFXPlayer.play()
            completeOnboarding()
        }
        .buttonStyle(.solar)
        .pulsingEffect()
    }
    
    private func pageView(for page: OnboardingPage, at index: Int) -> some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon
            iconView(for: page)
            
            // Content
            textContent(for: page)
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
    
    private func iconView(for page: OnboardingPage) -> some View {
        ZStack {
            Circle()
                .fill(page.gradient)
                .frame(width: 180, height: 180)
                .shadow(color: page.glowColor.opacity(0.5), radius: 20)
                .pulsingEffect(isAnimating)
            
            Text(page.icon)
                .font(.system(size: 70))
        }
    }
    
    private func textContent(for page: OnboardingPage) -> some View {
        VStack(spacing: 20) {
            // Title
            Text(page.title)
                .font(DesignSystem.Typography.stellar)
                .cosmicText()
                .multilineTextAlignment(.center)
            
            // Description
            Text(page.description)
                .font(DesignSystem.Typography.moon)
                .foregroundColor(DesignSystem.starWhite.opacity(0.9))
                .multilineTextAlignment(.center)
                .lineLimit(nil)
            
            // Features
            featuresView(for: page)
        }
    }
    
    private func featuresView(for page: OnboardingPage) -> some View {
        VStack(spacing: 12) {
            ForEach(page.features, id: \.self) { feature in
                featureRow(feature)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func featureRow(_ feature: String) -> some View {
        HStack {
            Circle()
                .fill(DesignSystem.profitGreen)
                .frame(width: 8, height: 8)
            
            Text(feature)
                .font(DesignSystem.Typography.asteroid)
                .foregroundColor(DesignSystem.starWhite.opacity(0.8))
            
            Spacer()
        }
    }
    
    private func startOnboarding() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 1.0)) {
                showContent = true
                isAnimating = true
            }
        }
        
        // Fixed the filename - it's missing the 'i' at the beginning
        audioPlayer.play(sound: "interstellar_theme.mp3", volume: 0.6, loop: true)
    }
    
    private func completeOnboarding() {
        withAnimation(.easeInOut(duration: 0.5)) {
            showContent = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            audioPlayer.stop()
            hasCompletedOnboarding = true
        }
    }
}

// MARK: - Onboarding Page Data
struct OnboardingPage {
    let title: String
    let description: String
    let icon: String
    let features: [String]
    let gradient: LinearGradient
    let glowColor: Color
    
    static let allPages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome to Trading Galaxy",
            description: "Embark on an epic journey through the cosmos of profitable trading",
            icon: "🌌",
            features: [
                "AI-powered trading algorithms",
                "Real-time market analysis",
                "Professional trading tools"
            ],
            gradient: DesignSystem.nebuladeGradient,
            glowColor: DesignSystem.stellarPurple
        ),
        
        OnboardingPage(
            title: "AI Trading Constellation",
            description: "Deploy sophisticated AI bots that trade like professionals",
            icon: "🤖",
            features: [
                "Multiple trading strategies",
                "24/7 autonomous trading",
                "Advanced risk management"
            ],
            gradient: LinearGradient(
                colors: [DesignSystem.cosmicBlue, DesignSystem.stellarPurple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            glowColor: DesignSystem.cosmicBlue
        ),
        
        OnboardingPage(
            title: "Solar Trading System",
            description: "Access professional tools and real-time data feeds",
            icon: "☀️",
            features: [
                "Live gold & forex prices",
                "Advanced charting tools",
                "Real-time profit tracking"
            ],
            gradient: DesignSystem.solarGradient,
            glowColor: DesignSystem.solarOrange
        ),
        
        OnboardingPage(
            title: "Mission Control Center",
            description: "Monitor your portfolio from a beautiful cosmic dashboard",
            icon: "🚀",
            features: [
                "Orbital trading dashboard",
                "Performance analytics",
                "Portfolio management"
            ],
            gradient: DesignSystem.planetEarthGradient,
            glowColor: DesignSystem.planetGreen
        ),
        
        OnboardingPage(
            title: "Ready for Profits",
            description: "You're all set to begin your journey to trading excellence!",
            icon: "🌟",
            features: [
                "Start with demo account",
                "Deploy your first AI bot",
                "Begin earning profits"
            ],
            gradient: LinearGradient(
                colors: [DesignSystem.solarOrange, DesignSystem.profitGreen],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            glowColor: DesignSystem.starWhite
        )
    ]
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
//
//  OnboardingView.swift
//  Planet ProTrader - Onboarding Experience
//
//  Professional Onboarding Flow
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    @State private var animateContent = false
    
    let pages = [
        OnboardingPage(
            title: "Welcome to Planet ProTrader",
            subtitle: "Your cosmic trading journey begins here",
            description: "Advanced AI-powered trading bots designed for the professional trader",
            systemImage: "globe.americas.fill",
            color: DesignSystem.primaryGold
        ),
        OnboardingPage(
            title: "AI Trading Bots",
            subtitle: "Automated trading excellence",
            description: "Deploy sophisticated AI bots that trade 24/7 with proven strategies",
            systemImage: "brain.head.profile",
            color: DesignSystem.cosmicBlue
        ),
        OnboardingPage(
            title: "Real-Time Analytics",
            subtitle: "Professional market insights",
            description: "Monitor your performance with advanced charts and real-time data",
            systemImage: "chart.line.uptrend.xyaxis",
            color: DesignSystem.stellarPurple
        ),
        OnboardingPage(
            title: "Start Trading",
            subtitle: "Ready to begin?",
            description: "Connect your account and let our AI bots generate profits for you",
            systemImage: "rocket.fill",
            color: DesignSystem.solarOrange
        )
    ]
    
    var body: some View {
        ZStack {
            DesignSystem.AnimatedStarField()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Content Area
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page, isActive: currentPage == index)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                // Bottom Controls
                VStack(spacing: 24) {
                    // Page Indicator
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? DesignSystem.primaryGold : Color.white.opacity(0.3))
                                .frame(width: currentPage == index ? 12 : 8, height: currentPage == index ? 12 : 8)
                                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentPage)
                        }
                    }
                    
                    // Action Buttons
                    HStack(spacing: 16) {
                        if currentPage > 0 {
                            Button("Back") {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    currentPage -= 1
                                }
                            }
                            .buttonStyle(OnboardingSecondaryButtonStyle())
                        }
                        
                        Spacer()
                        
                        Button(currentPage == pages.count - 1 ? "Get Started" : "Next") {
                            if currentPage == pages.count - 1 {
                                // Complete onboarding
                                withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                                    hasCompletedOnboarding = true
                                }
                            } else {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    currentPage += 1
                                }
                            }
                        }
                        .buttonStyle(OnboardingPrimaryButtonStyle())
                    }
                    .padding(.horizontal, 32)
                }
                .padding(.bottom, 50)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                animateContent = true
            }
        }
    }
}

// MARK: - Onboarding Page Model
struct OnboardingPage {
    let title: String
    let subtitle: String
    let description: String
    let systemImage: String
    let color: Color
}

// MARK: - Onboarding Page View
struct OnboardingPageView: View {
    let page: OnboardingPage
    let isActive: Bool
    @State private var animateIcon = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Icon
            Image(systemName: page.systemImage)
                .font(.system(size: 80, weight: .ultraLight))
                .foregroundStyle(
                    LinearGradient(
                        colors: [page.color, page.color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(animateIcon ? 1.1 : 1.0)
                .rotationEffect(.degrees(animateIcon ? 5 : 0))
                .animation(
                    .spring(response: 2.0, dampingFraction: 0.6).repeatForever(autoreverses: true),
                    value: animateIcon
                )
            
            // Text Content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, page.color.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .multilineTextAlignment(.center)
                
                Text(page.subtitle)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(page.color)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 32)
            
            Spacer()
        }
        .opacity(isActive ? 1 : 0.7)
        .scaleEffect(isActive ? 1 : 0.9)
        .animation(.spring(response: 0.8, dampingFraction: 0.7), value: isActive)
        .onAppear {
            if isActive {
                animateIcon = true
            }
        }
        .onChange(of: isActive) { oldValue, newValue in
            if newValue {
                animateIcon = true
            }
        }
    }
}

// MARK: - Button Styles
struct OnboardingPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [DesignSystem.primaryGold, DesignSystem.solarOrange],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: Capsule()
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: configuration.isPressed)
            .shadow(color: DesignSystem.primaryGold.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

struct OnboardingSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .stroke(.white.opacity(0.3), lineWidth: 2)
                    .background(.ultraThinMaterial, in: Capsule())
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
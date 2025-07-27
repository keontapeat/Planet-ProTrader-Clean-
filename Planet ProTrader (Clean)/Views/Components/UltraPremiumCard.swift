//
//  UltraPremiumCard.swift
//  Planet ProTrader (Clean)
//
//  Ultra Premium Card Component for Quantum Playbook
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

struct UltraPremiumCard<Content: View>: View {
    let content: Content
    @State private var glowAnimation = false
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(20)
            .background {
                ZStack {
                    // Base background
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                    
                    // Gradient overlay
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    DesignSystem.primaryGold.opacity(0.1),
                                    .clear,
                                    DesignSystem.primaryGold.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Animated border
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    DesignSystem.primaryGold.opacity(glowAnimation ? 0.8 : 0.3),
                                    .clear,
                                    DesignSystem.primaryGold.opacity(glowAnimation ? 0.3 : 0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                        .animation(
                            .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                            value: glowAnimation
                        )
                }
            }
            .shadow(
                color: DesignSystem.primaryGold.opacity(0.2),
                radius: glowAnimation ? 12 : 8,
                x: 0,
                y: glowAnimation ? 8 : 4
            )
            .animation(
                .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                value: glowAnimation
            )
            .onAppear {
                glowAnimation = true
            }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 20) {
            UltraPremiumCard {
                VStack(spacing: 12) {
                    Text("🏆 Elite Performance")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(DesignSystem.primaryGold)
                    
                    Text("This is an ultra-premium card with animated glow effects and elegant styling.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    
                    HStack {
                        VStack {
                            Text("$2,450")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(.green)
                            Text("Profit")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack {
                            Text("87%")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(.blue)
                            Text("Win Rate")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack {
                            Text("2.3R")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(DesignSystem.primaryGold)
                            Text("Avg R")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            
            UltraPremiumCard {
                HStack {
                    Image(systemName: "brain.head.profile")
                        .font(.title)
                        .foregroundStyle(DesignSystem.primaryGold)
                    
                    VStack(alignment: .leading) {
                        Text("Quantum Analysis")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text("AI-powered insights for elite trading")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding()
    }
}
//
//  Planet_ProTrader__Clean_App.swift
//  Planet ProTrader - Main App Entry Point
//
//  Professional Trading App - Clean Version
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

@main
struct Planet_ProTrader__Clean_App: App {
    // Initialize all managers (CLEAN: Removed SelfHealingSystem)
    @StateObject private var tradingManager = TradingManager.shared
    @StateObject private var botManager = BotManager.shared
    @StateObject private var accountManager = AccountManager.shared
    @StateObject private var hapticManager = HapticManager.shared
    
    // Add onboarding state - Reset this to test
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if !hasCompletedOnboarding {
                    OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                        .onAppear {
                            print("🚀 OnboardingView appeared!")
                        }
                } else {
                    ContentView()
                        .environmentObject(tradingManager)
                        .environmentObject(botManager)
                        .environmentObject(accountManager)
                        .environmentObject(hapticManager)
                        .preferredColorScheme(.light)
                        .onAppear {
                            setupApp()
                        }
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                }
            }
            .animation(.easeInOut(duration: 0.6), value: hasCompletedOnboarding)
            .onAppear {
                print("🔍 App launched. Onboarding completed: \(hasCompletedOnboarding)")
            }
        }
    }
    
    private func setupApp() {
        // CLEAN: Simplified setup without self-healing system
        
        // Initialize managers with basic setup
        Task {
            // Refresh data for all managers
            await tradingManager.refreshData()
            await botManager.refreshBots()
            await accountManager.refreshAccount()
        }
        
        print("🚀 Planet ProTrader initialized successfully")
        print("💰 MT5 Trading Engine ready for Coinexx Demo")
        print("🏥 VPS Monitoring enabled for 172.234.201.231")
    }
}

#Preview {
    ContentView()
        .environmentObject(TradingManager.shared)
        .environmentObject(BotManager.shared)
        .environmentObject(AccountManager.shared)
        .environmentObject(HapticManager.shared)
}
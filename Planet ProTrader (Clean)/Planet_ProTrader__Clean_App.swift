//
//  Planet_ProTrader__Clean_App.swift
//  Planet ProTrader - Main App Entry Point
//
//  Professional Trading App with AI Self-Healing
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

@main
struct Planet_ProTrader__Clean_App: App {
    // Initialize all managers
    @StateObject private var tradingManager = TradingManager.shared
    @StateObject private var botManager = BotManager.shared
    @StateObject private var accountManager = AccountManager.shared
    @StateObject private var hapticManager = HapticManager.shared
    @StateObject private var selfHealingSystem = SelfHealingSystem.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(tradingManager)
                .environmentObject(botManager)
                .environmentObject(accountManager)
                .environmentObject(hapticManager)
                .environmentObject(selfHealingSystem)
                .preferredColorScheme(.light)
                .onAppear {
                    setupApp()
                }
        }
    }
    
    private func setupApp() {
        // Start self-healing system
        if !selfHealingSystem.isMonitoring {
            selfHealingSystem.startMonitoring()
        }
        
        // Initialize managers with basic setup
        Task {
            // Refresh data for all managers
            await tradingManager.refreshData()
            await botManager.refreshBots()
            await accountManager.refreshAccount()
        }
        
        print("🚀 Planet ProTrader initialized successfully")
        print("🧠 GPT-4 Self-Healing System activated")
        print("🏥 VPS Monitoring enabled for 172.234.201.231")
    }
}

#Preview {
    ContentView()
        .environmentObject(TradingManager.shared)
        .environmentObject(BotManager.shared)
        .environmentObject(AccountManager.shared)
        .environmentObject(HapticManager.shared)
        .environmentObject(SelfHealingSystem.shared)
}
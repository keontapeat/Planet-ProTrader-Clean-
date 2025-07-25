//
//  ColorExtensions.swift
//  Planet ProTrader - Custom Color Extensions
//
//  Professional color palette for the ultimate trading experience
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

extension Color {
    // MARK: - Premium Gold Colors
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.0)
    static let lightGold = Color(red: 1.0, green: 0.92, blue: 0.4)
    static let darkGold = Color(red: 0.85, green: 0.65, blue: 0.0)
    
    // MARK: - ProTrader Brand Colors
    static let proTraderPrimary = Color(red: 0.0, green: 0.5, blue: 1.0)
    static let proTraderSecondary = Color(red: 0.2, green: 0.8, blue: 1.0)
    static let proTraderAccent = Color.gold
    
    // MARK: - Trading Status Colors
    static let profit = Color.green
    static let loss = Color.red
    static let pending = Color.orange
    static let godmode = Color.gold
    
    // MARK: - Confidence Level Colors
    static let confidenceGodmode = Color.gold        // 95%+
    static let confidenceExpert = Color.red         // 90-95%
    static let confidenceAdvanced = Color.purple    // 80-90%
    static let confidenceIntermediate = Color.blue  // 70-80%
    static let confidenceBeginner = Color.green     // 60-70%
    static let confidenceTraining = Color.gray      // <60%
}

// MARK: - Gradient Presets
extension LinearGradient {
    static let proTraderGradient = LinearGradient(
        colors: [Color.proTraderPrimary, Color.proTraderSecondary],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let goldGradient = LinearGradient(
        colors: [Color.gold, Color.yellow, Color.orange],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let wealthGradient = LinearGradient(
        colors: [Color.gold, Color.lightGold, Color.darkGold],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let successGradient = LinearGradient(
        colors: [Color.green, Color.mint, Color.teal],
        startPoint: .leading,
        endPoint: .trailing
    )
}

#Preview {
    VStack(spacing: 20) {
        Text("ProTrader")
            .font(.title.bold())
            .foregroundStyle(LinearGradient.proTraderGradient)
        
        Text("Where Poverty Doesn't Exist")
            .font(.title2.bold())
            .foregroundStyle(LinearGradient.goldGradient)
        
        HStack(spacing: 10) {
            Circle().fill(Color.gold).frame(width: 30, height: 30)
            Circle().fill(Color.lightGold).frame(width: 30, height: 30)
            Circle().fill(Color.darkGold).frame(width: 30, height: 30)
        }
    }
    .padding()
    .background(Color.black)
}
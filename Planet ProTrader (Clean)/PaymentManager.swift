//
//  PaymentManager.swift
//  Planet ProTrader - Payment Management
//
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI
import Foundation

// MARK: - Payment Manager

class PaymentManager: ObservableObject {
    static let shared = PaymentManager()
    
    @Published var isProcessing = false
    @Published var paymentSuccess = false
    @Published var isPremiumUser = false
    @Published var currentPlan: PremiumPlan?
    @Published var purchaseDate: Date?
    
    private init() {
        loadPremiumStatus()
    }
    
    func processPurchase(plan: PremiumPlan) async {
        await MainActor.run {
            self.isProcessing = true
        }
        
        // Simulate payment processing with realistic steps
        await simulatePaymentProcessing()
        
        await MainActor.run {
            self.isProcessing = false
            self.paymentSuccess = true
            self.isPremiumUser = true
            self.currentPlan = plan
            self.purchaseDate = Date()
            
            // Save premium status
            self.savePremiumStatus()
            
            // Show success notification
            GlobalToastManager.shared.show("🎉 Welcome to the Legend Club!", type: .success)
        }
    }
    
    private func simulatePaymentProcessing() async {
        // Step 1: Validate payment info
        try? await Task.sleep(for: .seconds(1.5))
        
        // Step 2: Process payment
        try? await Task.sleep(for: .seconds(2.0))
        
        // Step 3: Activate bots
        try? await Task.sleep(for: .seconds(1.5))
        
        // Step 4: Load training
        try? await Task.sleep(for: .seconds(1.0))
        
        // Step 5: Complete
        try? await Task.sleep(for: .seconds(0.5))
    }
    
    func restorePurchases() async {
        await MainActor.run {
            self.isProcessing = true
        }
        
        // Simulate restore process
        try? await Task.sleep(for: .seconds(2.0))
        
        await MainActor.run {
            self.isProcessing = false
            
            // For demo purposes, restore if user was previously premium
            if UserDefaults.standard.bool(forKey: "was_premium_user") {
                self.isPremiumUser = true
                self.currentPlan = PremiumPlan(rawValue: UserDefaults.standard.integer(forKey: "premium_plan")) ?? .goldLegend
                self.purchaseDate = UserDefaults.standard.object(forKey: "purchase_date") as? Date
                
                GlobalToastManager.shared.show("✅ Premium status restored!", type: .success)
            } else {
                GlobalToastManager.shared.show("ℹ️ No previous purchases found", type: .info)
            }
        }
    }
    
    func cancelSubscription() {
        isPremiumUser = false
        currentPlan = nil
        purchaseDate = nil
        savePremiumStatus()
        
        GlobalToastManager.shared.show("❌ Premium status cancelled", type: .info)
    }
    
    private func savePremiumStatus() {
        UserDefaults.standard.set(isPremiumUser, forKey: "is_premium_user")
        UserDefaults.standard.set(isPremiumUser, forKey: "was_premium_user") // For restore
        
        if let plan = currentPlan {
            UserDefaults.standard.set(plan.rawValue, forKey: "premium_plan")
        }
        
        if let date = purchaseDate {
            UserDefaults.standard.set(date, forKey: "purchase_date")
        }
    }
    
    private func loadPremiumStatus() {
        isPremiumUser = UserDefaults.standard.bool(forKey: "is_premium_user")
        
        if isPremiumUser {
            let planRawValue = UserDefaults.standard.integer(forKey: "premium_plan")
            currentPlan = PremiumPlan(rawValue: planRawValue)
            purchaseDate = UserDefaults.standard.object(forKey: "purchase_date") as? Date
        }
    }
    
    // Helper methods for UI
    var premiumStatusText: String {
        guard isPremiumUser, let plan = currentPlan else {
            return "Free User"
        }
        return "\(plan.emoji) \(plan.title)"
    }
    
    var daysSinceUpgrade: Int? {
        guard let purchaseDate = purchaseDate else { return nil }
        return Calendar.current.dateComponents([.day], from: purchaseDate, to: Date()).day
    }
    
    func hasAccess(to feature: PremiumFeature) -> Bool {
        guard isPremiumUser, let plan = currentPlan else {
            return feature.isAvailableInFree
        }
        
        return feature.isAvailable(in: plan)
    }
}

// MARK: - Premium Features

enum PremiumFeature: String, CaseIterable {
    case basicBots = "basic_bots"
    case premiumBots = "premium_bots"
    case unlimitedBots = "unlimited_bots"
    case jimRohnTraining = "jim_rohn_training"
    case advancedAnalytics = "advanced_analytics"
    case prioritySupport = "priority_support"
    case customBotDevelopment = "custom_bot_development"
    case whiteLabel = "white_label"
    case hedgeFundStrategies = "hedge_fund_strategies"
    case personalCoaching = "personal_coaching"
    
    var displayName: String {
        switch self {
        case .basicBots: return "Basic Trading Bots"
        case .premiumBots: return "Premium Trading Bots"
        case .unlimitedBots: return "Unlimited Trading Bots"
        case .jimRohnTraining: return "Jim Rohn AI Training"
        case .advancedAnalytics: return "Advanced Analytics"
        case .prioritySupport: return "Priority Support"
        case .customBotDevelopment: return "Custom Bot Development"
        case .whiteLabel: return "White-label Rights"
        case .hedgeFundStrategies: return "Hedge Fund Strategies"
        case .personalCoaching: return "Personal Coaching"
        }
    }
    
    var isAvailableInFree: Bool {
        switch self {
        case .basicBots:
            return true
        default:
            return false
        }
    }
    
    func isAvailable(in plan: PremiumPlan) -> Bool {
        switch self {
        case .basicBots:
            return true
        case .premiumBots, .jimRohnTraining, .advancedAnalytics, .prioritySupport:
            return plan.rawValue >= PremiumPlan.starter.rawValue
        case .unlimitedBots, .customBotDevelopment, .whiteLabel, .hedgeFundStrategies, .personalCoaching:
            return plan == .ultimate
        }
    }
}

// MARK: - Premium Status View

struct PremiumStatusView: View {
    @StateObject private var paymentManager = PaymentManager.shared
    @State private var showingPremiumView = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Status indicator
            ZStack {
                Circle()
                    .fill(paymentManager.isPremiumUser ? DesignSystem.primaryGold : DesignSystem.starWhite.opacity(0.3))
                    .frame(width: 32, height: 32)
                
                Image(systemName: paymentManager.isPremiumUser ? "crown.fill" : "lock.fill")
                    .font(.caption)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(paymentManager.premiumStatusText)
                    .font(DesignSystem.Typography.asteroid)
                    .fontWeight(.bold)
                    .foregroundColor(paymentManager.isPremiumUser ? DesignSystem.primaryGold : DesignSystem.starWhite)
                
                if let days = paymentManager.daysSinceUpgrade {
                    Text("Upgraded \(days) days ago")
                        .font(DesignSystem.Typography.dust)
                        .foregroundColor(DesignSystem.starWhite.opacity(0.6))
                } else if !paymentManager.isPremiumUser {
                    Text("Tap to upgrade")
                        .font(DesignSystem.Typography.dust)
                        .foregroundColor(DesignSystem.starWhite.opacity(0.6))
                }
            }
            
            Spacer()
            
            if !paymentManager.isPremiumUser {
                Button("Upgrade") {
                    showingPremiumView = true
                }
                .font(DesignSystem.Typography.dust)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(DesignSystem.primaryGold, in: Capsule())
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .onTapGesture {
            if !paymentManager.isPremiumUser {
                showingPremiumView = true
            }
        }
        .sheet(isPresented: $showingPremiumView) {
            PremiumPaymentView()
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        PremiumStatusView()
        
        // Demo feature access
        VStack(spacing: 8) {
            ForEach(PremiumFeature.allCases.prefix(5), id: \.self) { feature in
                HStack {
                    Image(systemName: PaymentManager.shared.hasAccess(to: feature) ? "checkmark.circle.fill" : "lock.circle.fill")
                        .foregroundColor(PaymentManager.shared.hasAccess(to: feature) ? .green : .red)
                    
                    Text(feature.displayName)
                        .font(DesignSystem.Typography.dust)
                        .foregroundColor(DesignSystem.starWhite)
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
        .planetCard()
    }
    .padding()
    .starField()
}
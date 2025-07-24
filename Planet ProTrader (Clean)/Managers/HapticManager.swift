//
//  HapticManager.swift
//  Planet ProTrader - Haptic Feedback System
//
//  Professional haptic feedback for trading actions
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI
import UIKit

class HapticManager: ObservableObject {
    static let shared = HapticManager()
    
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let notificationFeedback = UINotificationFeedbackGenerator()
    
    private init() {
        // Prepare generators for faster response
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        selectionFeedback.prepare()
        notificationFeedback.prepare()
    }
    
    // MARK: - Impact Feedback
    func lightImpact() {
        impactLight.impactOccurred()
    }
    
    func impact() {
        impactMedium.impactOccurred()
    }
    
    func heavyImpact() {
        impactHeavy.impactOccurred()
    }
    
    // MARK: - Selection Feedback
    func selection() {
        selectionFeedback.selectionChanged()
    }
    
    // MARK: - Notification Feedback
    func success() {
        notificationFeedback.notificationOccurred(.success)
    }
    
    func warning() {
        notificationFeedback.notificationOccurred(.warning)
    }
    
    func error() {
        notificationFeedback.notificationOccurred(.error)
    }
    
    // MARK: - Trading-Specific Feedback
    func tradeExecuted() {
        success()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.impact()
        }
    }
    
    func botDeployed() {
        success()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.lightImpact()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.lightImpact()
        }
    }
    
    func priceAlert() {
        warning()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.lightImpact()
        }
    }
    
    func connectionLost() {
        error()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.heavyImpact()
        }
    }
    
    func connectionRestored() {
        success()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.lightImpact()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.lightImpact()
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("🎮 Haptic Feedback Manager")
            .font(DesignSystem.Typography.largeTitle)
            .goldText()
        
        VStack(spacing: 12) {
            Button("Light Impact") {
                HapticManager.shared.lightImpact()
            }
            .buttonStyle(.primary)
            
            Button("Medium Impact") {
                HapticManager.shared.impact()
            }
            .buttonStyle(.primary)
            
            Button("Success") {
                HapticManager.shared.success()
            }
            .buttonStyle(.primary)
            
            Button("Trade Executed") {
                HapticManager.shared.tradeExecuted()
            }
            .buttonStyle(.primary)
        }
    }
    .padding()
}
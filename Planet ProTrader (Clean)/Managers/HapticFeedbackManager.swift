//
//  HapticFeedbackManager.swift
//  Planet ProTrader (Clean)
//
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI
import UIKit

class HapticFeedbackManager: ObservableObject {
    static let shared = HapticFeedbackManager()
    
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let notificationFeedback = UINotificationFeedbackGenerator()
    
    enum ImpactStyle {
        case light
        case medium
        case heavy
        case success
        case warning
        case error
        case selection
    }
    
    private init() {
        // Prepare generators for faster response
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        selectionFeedback.prepare()
        notificationFeedback.prepare()
    }
    
    // MARK: - Main Impact Method
    func impact(_ style: ImpactStyle) {
        switch style {
        case .light:
            impactLight.impactOccurred()
        case .medium:
            impactMedium.impactOccurred()
        case .heavy:
            impactHeavy.impactOccurred()
        case .success:
            notificationFeedback.notificationOccurred(.success)
        case .warning:
            notificationFeedback.notificationOccurred(.warning)
        case .error:
            notificationFeedback.notificationOccurred(.error)
        case .selection:
            selectionFeedback.selectionChanged()
        }
    }
    
    // MARK: - Convenience Methods
    func lightImpact() {
        impact(.light)
    }
    
    func mediumImpact() {
        impact(.medium)
    }
    
    func heavyImpact() {
        impact(.heavy)
    }
    
    func success() {
        impact(.success)
    }
    
    func warning() {
        impact(.warning)
    }
    
    func error() {
        impact(.error)
    }
    
    func selection() {
        impact(.selection)
    }
    
    // MARK: - Trading-Specific Feedback
    func tradeExecuted() {
        success()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.impact(.medium)
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
    
    func competitionJoined() {
        success()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.impact(.medium)
        }
    }
    
    func cardFlipped() {
        impact(.light)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.selection()
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
                HapticFeedbackManager.shared.impact(.light)
            }
            .buttonStyle(.primary)
            
            Button("Medium Impact") {
                HapticFeedbackManager.shared.impact(.medium)
            }
            .buttonStyle(.primary)
            
            Button("Success") {
                HapticFeedbackManager.shared.impact(.success)
            }
            .buttonStyle(.primary)
            
            Button("Card Flipped") {
                HapticFeedbackManager.shared.cardFlipped()
            }
            .buttonStyle(.primary)
            
            Button("Competition Joined") {
                HapticFeedbackManager.shared.competitionJoined()
            }
            .buttonStyle(.primary)
        }
    }
    .padding()
}
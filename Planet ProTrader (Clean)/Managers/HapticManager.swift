//
//  HapticManager.swift
//  Planet ProTrader - Haptic Feedback Management
//
//  Professional Haptic Feedback System
//  Created by AI Assistant on 1/25/25.
//

import Foundation
import UIKit

class HapticManager: ObservableObject {
    static let shared = HapticManager()
    
    // MARK: - Haptic Generators
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let notificationFeedback = UINotificationFeedbackGenerator()
    
    private init() {
        prepareHaptics()
    }
    
    // MARK: - Preparation
    private func prepareHaptics() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        selectionFeedback.prepare()
        notificationFeedback.prepare()
    }
    
    // MARK: - Impact Feedback
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        switch style {
        case .light:
            impactLight.impactOccurred()
        case .medium:
            impactMedium.impactOccurred()
        case .heavy:
            impactHeavy.impactOccurred()
        @unknown default:
            impactMedium.impactOccurred()
        }
    }
    
    // MARK: - Selection Feedback
    func selectionChanged() {
        selectionFeedback.selectionChanged()
    }
    
    // MARK: - Notification Feedback
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        notificationFeedback.notificationOccurred(type)
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
        notification(.success)
    }
    
    func warning() {
        notification(.warning)
    }
    
    func error() {
        notification(.error)
    }
    
    // MARK: - Trading-Specific Haptics
    func tradeExecuted() {
        heavyImpact()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.success()
        }
    }
    
    func tradeError() {
        heavyImpact()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.error()
        }
    }
    
    func buttonPress() {
        lightImpact()
    }
    
    func volumeChange() {
        selectionChanged()
    }
    
    func chartInteraction() {
        lightImpact()
    }
    
    func overlayDismiss() {
        mediumImpact()
    }
}
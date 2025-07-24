//
//  PaymentProcessingView.swift
//  Planet ProTrader - Payment Processing
//
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

struct PaymentProcessingView: View {
    let plan: PremiumPlan
    @Environment(\.dismiss) private var dismiss
    @StateObject private var paymentManager = PaymentManager.shared
    @State private var processingStep = 0
    @State private var showSuccess = false
    
    private let processingSteps = [
        "🔐 Validating payment information...",
        "💳 Processing secure payment...",
        "🤖 Activating premium bots...",
        "🧠 Loading Jim Rohn AI training...",
        "✅ Welcome to Legend status!"
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.spaceGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    if showSuccess {
                        successView
                    } else {
                        processingView
                    }
                }
                .padding()
            }
            .navigationTitle("Premium Upgrade")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if showSuccess {
                        Button("Done") {
                            dismiss()
                        }
                        .foregroundColor(DesignSystem.primaryGold)
                    }
                }
            }
        }
        .onAppear {
            startPaymentProcess()
        }
    }
    
    private var processingView: some View {
        VStack(spacing: 32) {
            // Processing animation
            ZStack {
                Circle()
                    .stroke(DesignSystem.cosmicBlue.opacity(0.3), lineWidth: 8)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: CGFloat(processingStep + 1) / CGFloat(processingSteps.count))
                    .stroke(DesignSystem.nebuladeGradient, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: processingStep)
                
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 40))
                    .foregroundColor(DesignSystem.primaryGold)
                    .scaleEffect(1.0 + sin(Date().timeIntervalSince1970 * 2) * 0.1)
                    .animation(.easeInOut(duration: 1.0).repeatForever(), value: processingStep)
            }
            
            // Plan info
            VStack(spacing: 16) {
                Text(plan.emoji + " " + plan.title)
                    .font(DesignSystem.Typography.stellar)
                    .fontWeight(.bold)
                    .cosmicText()
                
                Text(plan.price.formatted(.currency(code: "USD")))
                    .font(DesignSystem.Typography.cosmic)
                    .fontWeight(.black)
                    .foregroundColor(plan.color)
                
                Text(plan.subtitle)
                    .font(DesignSystem.Typography.asteroid)
                    .foregroundColor(DesignSystem.starWhite.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .planetCard()
            
            // Processing steps
            VStack(spacing: 16) {
                ForEach(0..<processingSteps.count, id: \.self) { index in
                    processingStepView(index: index, step: processingSteps[index])
                }
            }
            .planetCard()
        }
    }
    
    private func processingStepView(index: Int, step: String) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(index <= processingStep ? DesignSystem.primaryGold : DesignSystem.starWhite.opacity(0.3))
                    .frame(width: 32, height: 32)
                    .animation(.spring(), value: processingStep)
                
                if index < processingStep {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                } else if index == processingStep {
                    ProgressView()
                        .scaleEffect(0.7)
                        .tint(.white)
                } else {
                    Text("\(index + 1)")
                        .font(DesignSystem.Typography.dust)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.starWhite.opacity(0.6))
                }
            }
            
            Text(step)
                .font(DesignSystem.Typography.asteroid)
                .foregroundColor(
                    index <= processingStep 
                    ? DesignSystem.starWhite 
                    : DesignSystem.starWhite.opacity(0.5)
                )
                .animation(.easeInOut, value: processingStep)
            
            Spacer()
        }
    }
    
    private var successView: some View {
        VStack(spacing: 32) {
            // Success animation
            ZStack {
                Circle()
                    .fill(DesignSystem.planetGreen.opacity(0.2))
                    .frame(width: 160, height: 160)
                    .scaleEffect(1.0 + sin(Date().timeIntervalSince1970 * 3) * 0.05)
                    .animation(.easeInOut(duration: 2.0).repeatForever(), value: showSuccess)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(DesignSystem.planetGreen)
                    .scaleEffect(showSuccess ? 1.0 : 0.1)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6), value: showSuccess)
            }
            
            VStack(spacing: 16) {
                Text("🎉 WELCOME TO LEGEND STATUS!")
                    .font(DesignSystem.Typography.stellar)
                    .fontWeight(.black)
                    .cosmicText()
                    .multilineTextAlignment(.center)
                
                Text("Your \(plan.title) bots are now active and ready to generate legendary profits!")
                    .font(DesignSystem.Typography.asteroid)
                    .foregroundColor(DesignSystem.starWhite.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                // Activated features
                VStack(spacing: 8) {
                    Text("✅ ACTIVATED FEATURES:")
                        .font(DesignSystem.Typography.asteroid)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.planetGreen)
                    
                    ForEach(plan.features.prefix(4), id: \.self) { feature in
                        Text("• \(feature)")
                            .font(DesignSystem.Typography.dust)
                            .foregroundColor(DesignSystem.starWhite.opacity(0.8))
                    }
                    
                    if plan.features.count > 4 {
                        Text("...and \(plan.features.count - 4) more features!")
                            .font(DesignSystem.Typography.dust)
                            .foregroundColor(DesignSystem.primaryGold)
                            .fontWeight(.semibold)
                    }
                }
            }
            .planetCard()
            
            // Next steps
            VStack(spacing: 12) {
                Text("🚀 NEXT STEPS:")
                    .font(DesignSystem.Typography.asteroid)
                    .fontWeight(.bold)
                    .cosmicText()
                
                Text("1. Your premium bots are now available in the AI Bots tab")
                Text("2. Check your email for exclusive trading strategies")
                Text("3. Join our premium community for insider tips")
            }
            .font(DesignSystem.Typography.dust)
            .foregroundColor(DesignSystem.starWhite.opacity(0.8))
            .planetCard()
            
            Button("Start Trading with Legend Bots") {
                dismiss()
            }
            .buttonStyle(.cosmic)
        }
    }
    
    private func startPaymentProcess() {
        Task {
            for step in 0..<processingSteps.count {
                try? await Task.sleep(for: .seconds(1.5))
                await MainActor.run {
                    processingStep = step
                }
            }
            
            try? await Task.sleep(for: .seconds(1))
            
            await MainActor.run {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                    showSuccess = true
                }
                
                // Show success toast
                GlobalToastManager.shared.show("🎉 Welcome to the Legend Club!", type: .success)
                
                // Success haptic
                let successFeedback = UINotificationFeedbackGenerator()
                successFeedback.notificationOccurred(.success)
            }
        }
    }
}

#Preview {
    PaymentProcessingView(plan: .goldLegend)
}
//
//  WalletModels.swift
//  Planet ProTrader (Clean)
//
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI
import Foundation

// MARK: - Wallet Transaction Model

struct WalletTransaction: Identifiable, Codable {
    let id = UUID()
    let type: TransactionType
    let amount: Double
    let description: String
    let timestamp: Date
    let status: TransactionStatus
    
    enum TransactionType: String, CaseIterable, Codable {
        case deposit = "deposit"
        case withdrawal = "withdrawal"
        case transfer = "transfer"
        case botEarning = "bot_earning"
        case tradingFee = "trading_fee"
        
        var displayName: String {
            switch self {
            case .deposit: return "Deposit"
            case .withdrawal: return "Withdrawal"
            case .transfer: return "Transfer"
            case .botEarning: return "Bot Earning"
            case .tradingFee: return "Trading Fee"
            }
        }
        
        var emoji: String {
            switch self {
            case .deposit: return "plus.circle.fill"
            case .withdrawal: return "minus.circle.fill"
            case .transfer: return "arrow.left.arrow.right.circle.fill"
            case .botEarning: return "brain.head.profile"
            case .tradingFee: return "creditcard.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .deposit, .botEarning: return .green
            case .withdrawal, .tradingFee: return .red
            case .transfer: return .blue
            }
        }
    }
    
    enum TransactionStatus: String, CaseIterable, Codable {
        case pending = "pending"
        case completed = "completed"
        case failed = "failed"
        case cancelled = "cancelled"
        
        var color: Color {
            switch self {
            case .pending: return .orange
            case .completed: return .green
            case .failed: return .red
            case .cancelled: return .gray
            }
        }
    }
    
    static var sampleTransactions: [WalletTransaction] {
        return [
            WalletTransaction(
                type: .botEarning,
                amount: 247.50,
                description: "Golden Eagle Pro - Daily Profits",
                timestamp: Date().addingTimeInterval(-3600),
                status: .completed
            ),
            WalletTransaction(
                type: .deposit,
                amount: 1000.00,
                description: "Card Deposit - ****4532",
                timestamp: Date().addingTimeInterval(-86400),
                status: .completed
            ),
            WalletTransaction(
                type: .transfer,
                amount: -500.00,
                description: "Transfer to Trading Fuel",
                timestamp: Date().addingTimeInterval(-86400 * 2),
                status: .completed
            ),
            WalletTransaction(
                type: .withdrawal,
                amount: -350.75,
                description: "Bank Withdrawal - Wells Fargo",
                timestamp: Date().addingTimeInterval(-86400 * 3),
                status: .completed
            ),
            WalletTransaction(
                type: .tradingFee,
                amount: -12.50,
                description: "Trading Commission",
                timestamp: Date().addingTimeInterval(-86400 * 4),
                status: .completed
            )
        ]
    }
}

// MARK: - Premium Card Component

struct UltraPremiumCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [
                                DesignSystem.primaryGold.opacity(0.3),
                                .clear,
                                DesignSystem.primaryGold.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
}

// MARK: - Wallet Sheet Views (Placeholder)

struct WalletTransferView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "arrow.left.arrow.right.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.blue)
                
                Text("Transfer Funds")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Transfer between your wallets")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("Close") {
                    dismiss()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding()
            .navigationTitle("Transfer")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct CardPaymentView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.green)
                
                Text("Add Funds")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Fund your trading wallet")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("Close") {
                    dismiss()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding()
            .navigationTitle("Add Funds")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct WithdrawalView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "arrow.down.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.green)
                
                Text("Withdraw Funds")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Cash out your earnings")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("Close") {
                    dismiss()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding()
            .navigationTitle("Withdraw")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("💰 Wallet Models")
            .font(DesignSystem.Typography.largeTitle)
            .goldText()
        
        UltraPremiumCard {
            VStack {
                Text("Sample Transaction")
                Text("$247.50")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
        }
        
        Text("Sample transactions: \(WalletTransaction.sampleTransactions.count)")
    }
    .padding()
}
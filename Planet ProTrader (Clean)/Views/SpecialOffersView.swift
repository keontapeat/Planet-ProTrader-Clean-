//
//  SpecialOffersView.swift
//  Planet ProTrader (Clean)
//
//  Special offers and deals view
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

struct SpecialOffersView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var cartManager = BotCartManager.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Flash sale banner
                    flashSaleBanner
                    
                    // Bundle deals
                    bundleDealsSection
                    
                    // Limited time offers
                    limitedTimeSection
                }
                .padding()
            }
            .navigationTitle("🎉 Special Offers")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var flashSaleBanner: some View {
        VStack(spacing: 16) {
            Text("⚡ FLASH SALE ⚡")
                .font(.title)
                .fontWeight(.black)
                .foregroundColor(.white)
            
            Text("3 Premium Bots for $299")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(DesignSystem.primaryGold)
            
            Text("Limited Time: 2h 15m left")
                .font(.headline)
                .foregroundColor(.red)
            
            Button("CLAIM DEAL") {
                // Add bundle to cart
            }
            .font(.headline)
            .fontWeight(.bold)
            .foregroundColor(.black)
            .padding(.horizontal, 30)
            .padding(.vertical, 12)
            .background(DesignSystem.primaryGold)
            .cornerRadius(25)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [.red, .orange],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
    }
    
    private var bundleDealsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📦 Bundle Deals")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                BundleDealCard(
                    title: "Starter Pack",
                    description: "3 beginner-friendly bots",
                    originalPrice: 150,
                    salePrice: 99,
                    discount: "34% OFF"
                )
                
                BundleDealCard(
                    title: "Pro Trader Bundle",
                    description: "5 professional trading bots",
                    originalPrice: 750,
                    salePrice: 499,
                    discount: "33% OFF"
                )
                
                BundleDealCard(
                    title: "Elite Collection",
                    description: "10 legendary & mythic bots",
                    originalPrice: 2000,
                    salePrice: 1299,
                    discount: "35% OFF"
                )
            }
        }
    }
    
    private var limitedTimeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("⏰ Limited Time Offers")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                LimitedOfferCard(
                    title: "Weekend Special",
                    description: "50% off all scalping bots",
                    timeLeft: "2 days",
                    discount: "50% OFF"
                )
                
                LimitedOfferCard(
                    title: "New User Bonus",
                    description: "First bot purchase gets 2nd free",
                    timeLeft: "7 days",
                    discount: "BOGO"
                )
            }
        }
    }
}

struct BundleDealCard: View {
    let title: String
    let description: String
    let originalPrice: Int
    let salePrice: Int
    let discount: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("$\(originalPrice)")
                        .font(.caption)
                        .strikethrough()
                        .foregroundColor(.gray)
                    
                    Text("$\(salePrice)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.primaryGold)
                    
                    Text(discount)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(.red.opacity(0.2))
                        .cornerRadius(6)
                }
            }
            
            Button("Add Bundle to Cart") {
                // Add bundle to cart
            }
            .font(.subheadline)
            .fontWeight(.bold)
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(DesignSystem.primaryGold)
            .cornerRadius(12)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
}

struct LimitedOfferCard: View {
    let title: String
    let description: String
    let timeLeft: String
    let discount: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text("⏰ \(timeLeft) left")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text(discount)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.orange)
                    .cornerRadius(8)
                
                Button("Claim") {
                    // Claim offer
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

#Preview {
    SpecialOffersView()
}
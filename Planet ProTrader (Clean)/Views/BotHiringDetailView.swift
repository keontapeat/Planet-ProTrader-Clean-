//
//  BotHiringDetailView.swift
//  Planet ProTrader (Clean)
//
//  Bot hiring detail view for marketplace
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

struct BotHiringDetailView: View {
    let bot: MarketplaceBotModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var cartManager = BotCartManager.shared
    @State private var showingCustomization = false
    @State private var showingContract = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Hero section with bot avatar
                    heroSection
                    
                    // Bot details and pitch
                    botDetailsSection
                    
                    // Performance stats
                    performanceSection
                    
                    // Reviews section
                    reviewsSection
                    
                    // Hiring section
                    hiringSection
                }
                .padding()
            }
            .navigationTitle("Hire \(bot.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("🛒") {
                        cartManager.addToCart(bot)
                    }
                }
            }
        }
        .sheet(isPresented: $showingCustomization) {
            BotCustomizationView(bot: bot)
        }
    }
    
    private var heroSection: some View {
        VStack(spacing: 16) {
            BotCharacterAvatar(bot: bot, size: 120)
            
            VStack(spacing: 8) {
                Text(bot.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(bot.tagline)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                HStack {
                    Text("by \(bot.creatorUsername)")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    if bot.verificationStatus == .verified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
    
    private var botDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🎯 Bot's Pitch")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(bot.currentPitch)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .padding()
                .background(.blue.opacity(0.2))
                .cornerRadius(12)
            
            Text("📋 Description")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(bot.description)
                .font(.body)
                .foregroundColor(.gray)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
    
    private var performanceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📊 Performance Stats")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                HiringStatCard(
                    title: "Total Return",
                    value: bot.stats.formattedTotalReturn,
                    color: bot.stats.totalReturn >= 0 ? .green : .red
                )
                
                HiringStatCard(
                    title: "Win Rate",
                    value: String(format: "%.1f%%", bot.stats.winRate),
                    color: .blue
                )
                
                HiringStatCard(
                    title: "Total Trades",
                    value: "\(bot.stats.totalTrades)",
                    color: .purple
                )
                
                HiringStatCard(
                    title: "Users",
                    value: "\(bot.stats.totalUsers)",
                    color: .orange
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
    
    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("⭐ Reviews")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack(spacing: 2) {
                    ForEach(0..<5) { star in
                        Image(systemName: star < Int(bot.averageRating) ? "star.fill" : "star")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                }
                
                Text(String(format: "%.1f", bot.averageRating))
                    .font(.caption)
                    .foregroundColor(.white)
            }
            
            if !bot.reviews.isEmpty {
                VStack(spacing: 12) {
                    ForEach(bot.reviews.prefix(3)) { review in
                        HiringReviewCard(
                            username: review.username,
                            rating: Int(review.rating),
                            comment: review.comment,
                            date: "2 days ago" // You could format review.date here
                        )
                    }
                }
            } else {
                Text("No reviews yet - be the first!")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.gray.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
    
    private var hiringSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Hiring Fee")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text(bot.formattedPrice)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.primaryGold)
                }
                
                Spacer()
                
                if bot.hasSpecialOffer {
                    VStack(alignment: .trailing) {
                        Text("🔥 SPECIAL OFFER!")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                        
                        Text(bot.specialOfferDetails ?? "Limited time!")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            VStack(spacing: 12) {
                Button("💰 HIRE THIS BOT") {
                    cartManager.addToCart(bot)
                    dismiss()
                }
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(DesignSystem.primaryGold)
                .cornerRadius(25)
                
                if bot.isCustomizable {
                    Button("🎨 Customize & Hire") {
                        showingCustomization = true
                    }
                    .font(.subheadline)
                    .foregroundColor(.purple)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.purple.opacity(0.2))
                    .cornerRadius(20)
                }
                
                Button("📋 View Contract") {
                    showingContract = true
                }
                .font(.subheadline)
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(.blue.opacity(0.2))
                .cornerRadius(20)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
}

struct HiringStatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct HiringReviewCard: View {
    let username: String
    let rating: Int
    let comment: String
    let date: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(username)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack(spacing: 1) {
                    ForEach(0..<5) { star in
                        Image(systemName: star < rating ? "star.fill" : "star")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                    }
                }
            }
            
            Text(comment)
                .font(.caption)
                .foregroundColor(.gray)
            
            Text(date)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    BotHiringDetailView(bot: MarketplaceBotModel.generateRandomBot())
}
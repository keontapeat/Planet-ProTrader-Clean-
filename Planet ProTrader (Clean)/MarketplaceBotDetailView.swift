//
//  MarketplaceBotDetailView.swift
//  Planet ProTrader (Clean)
//
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

struct MarketplaceBotDetailView: View {
    let bot: MarketplaceBotModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingPurchaseAlert = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Hero section
                    heroSection
                    
                    // Stats section
                    statsSection
                    
                    // Tab selection
                    tabSelection
                    
                    // Tab content
                    tabContent
                    
                    // Purchase section
                    purchaseSection
                }
                .padding()
            }
            .navigationTitle(bot.name)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(DesignSystem.cosmicBlue)
                }
            }
        }
        .alert("Purchase Bot", isPresented: $showingPurchaseAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Purchase \(bot.formattedPrice)") {
                // Handle purchase
            }
        } message: {
            Text("Are you sure you want to purchase \(bot.name) for \(bot.formattedPrice)?")
        }
    }
    
    // MARK: - Hero Section
    
    private var heroSection: some View {
        VStack(spacing: 16) {
            // Bot avatar
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [bot.rarity.color.opacity(0.8), bot.rarity.color.opacity(0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 160)
                
                VStack(spacing: 12) {
                    Text(bot.rarity.sparkleEffect)
                        .font(.system(size: 48))
                    
                    Text(bot.tier.icon)
                        .font(.system(size: 32))
                    
                    HStack(spacing: 8) {
                        Text(bot.rarity.rawValue)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(8)
                        
                        Text(bot.tier.rawValue)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(8)
                    }
                }
            }
            
            // Bot info
            VStack(spacing: 8) {
                Text(bot.tagline)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 16) {
                    // Creator
                    HStack(spacing: 4) {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.blue)
                        Text("by \(bot.creatorUsername)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Verification
                    HStack(spacing: 4) {
                        Image(systemName: bot.verificationStatus.icon)
                            .foregroundColor(bot.verificationStatus.color)
                        Text(bot.verificationStatus.rawValue)
                            .font(.subheadline)
                            .foregroundColor(bot.verificationStatus.color)
                    }
                    
                    // Availability
                    HStack(spacing: 4) {
                        Image(systemName: bot.availability.icon)
                            .foregroundColor(bot.availability.color)
                        Text(bot.availability.rawValue)
                            .font(.subheadline)
                            .foregroundColor(bot.availability.color)
                    }
                }
                
                // Rating
                HStack(spacing: 8) {
                    HStack(spacing: 2) {
                        ForEach(0..<5) { star in
                            Image(systemName: star < Int(bot.averageRating) ? "star.fill" : "star")
                                .font(.caption)
                                .foregroundColor(.yellow)
                        }
                    }
                    
                    Text(String(format: "%.1f", bot.averageRating))
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("(\(bot.stats.totalUsers) users)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .planetCard()
    }
    
    // MARK: - Stats Section
    
    private var statsSection: some View {
        VStack(spacing: 16) {
            Text("📊 Performance Stats")
                .font(.headline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                StatCard(
                    title: "Total Return",
                    value: bot.stats.formattedTotalReturn,
                    color: bot.stats.totalReturn >= 0 ? .green : .red,
                    icon: "chart.line.uptrend.xyaxis"
                )
                
                StatCard(
                    title: "Win Rate",
                    value: String(format: "%.1f%%", bot.stats.winRate),
                    color: .blue,
                    icon: "target"
                )
                
                StatCard(
                    title: "Total Trades",
                    value: "\(bot.stats.totalTrades)",
                    color: .purple,
                    icon: "arrow.left.arrow.right"
                )
                
                StatCard(
                    title: "Max Drawdown",
                    value: String(format: "%.1f%%", bot.stats.maxDrawdown),
                    color: .orange,
                    icon: "chart.line.downtrend.xyaxis"
                )
            }
        }
        .planetCard()
    }
    
    // MARK: - Tab Selection
    
    private var tabSelection: some View {
        HStack(spacing: 0) {
            ForEach(0..<3, id: \.self) { index in
                Button(action: {
                    selectedTab = index
                }) {
                    Text(tabTitle(for: index))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(selectedTab == index ? .white : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            selectedTab == index 
                            ? DesignSystem.cosmicBlue 
                            : Color.clear
                        )
                }
            }
        }
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func tabTitle(for index: Int) -> String {
        switch index {
        case 0: return "Overview"
        case 1: return "Strategy"
        case 2: return "Reviews"
        default: return ""
        }
    }
    
    // MARK: - Tab Content
    
    private var tabContent: some View {
        Group {
            switch selectedTab {
            case 0:
                overviewTab
            case 1:
                strategyTab
            case 2:
                reviewsTab
            default:
                EmptyView()
            }
        }
    }
    
    private var overviewTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📝 About This Bot")
                .font(.headline)
                .fontWeight(.bold)
            
            Text("This is a sample description for \(bot.name). In a real app, this would contain detailed information about the bot's functionality, trading approach, and unique features.")
                .font(.body)
                .foregroundColor(.secondary)
            
            Text("🔧 Features")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.top)
            
            VStack(alignment: .leading, spacing: 8) {
                FeatureRow(icon: "brain.head.profile", text: "AI-powered decision making", color: .blue)
                FeatureRow(icon: "shield.checkered", text: "Risk management built-in", color: .green)
                FeatureRow(icon: "clock.arrow.circlepath", text: "24/7 automated trading", color: .orange)
                FeatureRow(icon: "chart.bar.xaxis", text: "Real-time performance tracking", color: .purple)
            }
        }
        .planetCard()
    }
    
    private var strategyTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🎯 Trading Strategy")
                .font(.headline)
                .fontWeight(.bold)
            
            Text("This bot uses advanced algorithms and machine learning to identify profitable trading opportunities. The strategy is based on technical analysis, market sentiment, and risk management principles.")
                .font(.body)
                .foregroundColor(.secondary)
            
            Text("📈 Indicators Used")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.top)
            
            VStack(alignment: .leading, spacing: 8) {
                IndicatorRow(name: "Moving Averages", description: "Trend identification")
                IndicatorRow(name: "RSI", description: "Momentum analysis")
                IndicatorRow(name: "MACD", description: "Signal generation")
                IndicatorRow(name: "Bollinger Bands", description: "Volatility assessment")
            }
        }
        .planetCard()
    }
    
    private var reviewsTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("⭐ User Reviews")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                ReviewCard(
                    username: "TraderPro123",
                    rating: 5,
                    comment: "Excellent bot! Consistent profits and great risk management.",
                    date: "2 days ago"
                )
                
                ReviewCard(
                    username: "InvestorGuru",
                    rating: 4,
                    comment: "Good performance overall, though had some rough patches during volatile markets.",
                    date: "1 week ago"
                )
                
                ReviewCard(
                    username: "CryptoMaster",
                    rating: 5,
                    comment: "Best bot I've used so far. Highly recommended!",
                    date: "2 weeks ago"
                )
            }
        }
        .planetCard()
    }
    
    // MARK: - Purchase Section
    
    private var purchaseSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Price")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(bot.formattedPrice)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.cosmicBlue)
                }
                
                Spacer()
                
                Button("Purchase Bot") {
                    showingPurchaseAlert = true
                }
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 140, height: 44)
                .background(DesignSystem.solarOrange)
                .cornerRadius(12)
            }
            
            Text("30-day money-back guarantee")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .planetCard()
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct AFeatureRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

struct IndicatorRow: View {
    let name: String
    let description: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct ReviewCard: View {
    let username: String
    let rating: Int
    let comment: String
    let date: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(username)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                HStack(spacing: 2) {
                    ForEach(0..<5) { star in
                        Image(systemName: star < rating ? "star.fill" : "star")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                }
                
                Text(date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(comment)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    MarketplaceBotDetailView(
        bot: MarketplaceBotModel(
            name: "Golden Eagle Pro",
            tagline: "Advanced gold trading with AI precision",
            creatorUsername: "TradeMaster",
            rarity: .legendary,
            tier: .professional,
            verificationStatus: .verified,
            availability: .available,
            price: 299.99,
            averageRating: 4.8,
            stats: BotStats(
                totalReturn: 342.5,
                winRate: 87.2,
                totalTrades: 1250,
                totalUsers: 450,
                maxDrawdown: 8.5
            ),
            createdDate: Date().addingTimeInterval(-86400 * 45)
        )
    )
}

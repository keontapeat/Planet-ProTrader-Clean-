//
//  BotStoreView.swift
//  Planet ProTrader - Interactive Bot Hiring Marketplace
//
//  GROCERY SHOPPING FOR MONEY-MAKING BOTS 🛒💰
//  Bots actively compete to be hired to trade your money!
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI
import Foundation

struct BotStoreView: View {
    @StateObject private var storeService = BotStoreService.shared
    @StateObject private var cartManager = BotCartManager.shared
    
    @State private var selectedBot: MarketplaceBotModel?
    @State private var showingBotDetail = false
    @State private var showingCart = false
    @State private var showingBotChat = false
    @State private var showingCustomization = false
    @State private var animateCards = false
    @State private var selectedCard: UUID?
    @State private var shoppingMode: ShoppingMode = .browse
    @State private var currentAisle: BotAisle = .featured
    @State private var showingSpecialOffers = false
    @State private var cartShakeAnimation = false
    
    enum ShoppingMode {
        case browse, shopping, negotiating, customizing
        
        var title: String {
            switch self {
            case .browse: return "🛒 Bot Grocery Store"
            case .shopping: return "💰 Hiring Bots"
            case .negotiating: return "🤝 Negotiating Deals"
            case .customizing: return "🎨 Customizing Bots"
            }
        }
    }
    
    enum BotAisle: String, CaseIterable {
        case featured = "⭐ Featured Traders"
        case newArrivals = "🆕 New Arrivals"
        case hotDeals = "🔥 Hot Deals"
        case premium = "💎 Premium Bots"
        case specialists = "🎯 Specialists"
        case budget = "💵 Budget Friendly"
        case experimental = "🧪 Experimental"
        case topRated = "🏆 Top Rated"
        
        var emoji: String {
            String(rawValue.prefix(2))
        }
        
        var description: String {
            switch self {
            case .featured: return "Hand-picked money makers"
            case .newArrivals: return "Fresh off the assembly line"
            case .hotDeals: return "Limited time offers"
            case .premium: return "Elite traders only"
            case .specialists: return "Niche market experts"
            case .budget: return "Great value picks"
            case .experimental: return "Cutting-edge AI"
            case .topRated: return "Community favorites"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated starfield background
                DesignSystem.AnimatedStarField()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Shopping header with cart
                    shoppingHeader
                    
                    // Aisle selector (like grocery store aisles)
                    aisleSelector
                    
                    // Special announcements banner
                    if storeService.hasSpecialOffers {
                        specialOffersbanner
                    }
                    
                    // Main shopping area
                    ScrollView {
                        VStack(spacing: 20) {
                            // Shopping cart summary (if items in cart)
                            if !cartManager.cartItems.isEmpty {
                                cartSummaryCard
                            }
                            
                            // Bots actively pitching themselves
                            activePitchesSection
                            
                            // Main bot marketplace
                            botMarketplaceSection
                            
                            // Bot testimonials
                            botTestimonialsSection
                        }
                        .padding()
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                setupShoppingExperience()
            }
            .sheet(isPresented: $showingBotDetail) {
                if let bot = selectedBot {
                    BotHiringDetailView(bot: bot)
                }
            }
            .sheet(isPresented: $showingCart) {
                BotShoppingCartView()
            }
            .sheet(isPresented: $showingBotChat) {
                if let bot = selectedBot {
                    BotNegotiationChatView(bot: bot)
                }
            }
            .sheet(isPresented: $showingCustomization) {
                if let bot = selectedBot {
                    BotCustomizationView(bot: bot)
                }
            }
            .sheet(isPresented: $showingSpecialOffers) {
                SpecialOffersView()
            }
        }
    }
    
    // MARK: - Shopping Header
    private var shoppingHeader: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(shoppingMode.title)
                        .font(.title2)
                        .fontWeight(.black)
                        .foregroundColor(.white)
                    
                    Text("Bots competing to manage your money!")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Shopping cart button
                Button(action: {
                    showingCart = true
                }) {
                    ZStack {
                        Image(systemName: "cart.fill")
                            .font(.title2)
                            .foregroundColor(DesignSystem.primaryGold)
                            .scaleEffect(cartShakeAnimation ? 1.2 : 1.0)
                            .animation(.bouncy(duration: 0.3), value: cartShakeAnimation)
                        
                        if cartManager.cartItems.count > 0 {
                            Text("\(cartManager.cartItems.count)")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(6)
                                .background(Circle().fill(.red))
                                .offset(x: 12, y: -12)
                        }
                    }
                }
                .onReceive(cartManager.$cartItems) { _ in
                    withAnimation {
                        cartShakeAnimation = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        cartShakeAnimation = false
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)
            
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search for money-making bots...", text: $storeService.searchText)
                    .foregroundColor(.white)
                
                if !storeService.searchText.isEmpty {
                    Button("Clear") {
                        storeService.searchText = ""
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
        .background(Color.black.opacity(0.8))
    }
    
    // MARK: - Aisle Selector
    private var aisleSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(BotAisle.allCases, id: \.self) { aisle in
                    aisleButton(aisle: aisle)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
        .background(.thinMaterial)
    }
    
    private func aisleButton(aisle: BotAisle) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                currentAisle = aisle
            }
        }) {
            VStack(spacing: 6) {
                Text(aisle.emoji)
                    .font(.title2)
                
                VStack(spacing: 2) {
                    Text(aisle.rawValue.dropFirst(2))
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(currentAisle == aisle ? .white : .primary)
                    
                    Text(aisle.description)
                        .font(.caption2)
                        .foregroundColor(currentAisle == aisle ? .white.opacity(0.8) : .secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                currentAisle == aisle 
                ? AnyShapeStyle(DesignSystem.primaryGold)
                : AnyShapeStyle(.ultraThinMaterial)
            )
            .cornerRadius(16)
            .shadow(color: currentAisle == aisle ? DesignSystem.primaryGold.opacity(0.3) : .clear, radius: 8)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Special Offers Banner
    private var specialOffersbanner: some View {
        Button(action: {
            showingSpecialOffers = true
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("🎉 FLASH SALE!")
                        .font(.headline)
                        .fontWeight(.black)
                        .foregroundColor(.white)
                    
                    Text("3 Premium Bots for the price of 1!")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("⏰ 2h 15m left")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                    
                    Text("TAP TO CLAIM")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [.red, .orange, .red],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.white.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(animateCards ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: animateCards)
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }
    
    // MARK: - Cart Summary Card
    private var cartSummaryCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("🛒 Your Hiring Cart")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("View Cart") {
                    showingCart = true
                }
                .font(.caption)
                .foregroundColor(DesignSystem.primaryGold)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(DesignSystem.primaryGold.opacity(0.2))
                .cornerRadius(8)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(cartManager.cartItems.prefix(5)) { item in
                        CartItemPreview(item: item)
                    }
                    
                    if cartManager.cartItems.count > 5 {
                        Text("+\(cartManager.cartItems.count - 5) more")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(.ultraThinMaterial)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 4)
            }
            
            HStack {
                Text("Total Investment: \(cartManager.formattedTotal)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.primaryGold)
                
                Spacer()
                
                Button("💰 HIRE ALL BOTS") {
                    cartManager.processHiring()
                }
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(DesignSystem.primaryGold)
                .cornerRadius(20)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(DesignSystem.primaryGold.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Active Pitches Section
    private var activePitchesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("🎤 BOTS PITCHING FOR YOUR MONEY")
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("LIVE")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.red)
                    .cornerRadius(12)
                    .pulsingEffect()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(storeService.activePitchingBots) { bot in
                        BotPitchCard(bot: bot) {
                            selectedBot = bot
                            showingBotChat = true
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    // MARK: - Bot Marketplace Section
    private var botMarketplaceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("\(currentAisle.emoji) \(currentAisle.rawValue.dropFirst(2))")
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(getBotsForCurrentAisle().count) bots available")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 16) {
                ForEach(getBotsForCurrentAisle()) { bot in
                    InteractiveBotCard(bot: bot) {
                        selectedBot = bot
                        showingBotDetail = true
                    }
                }
            }
        }
    }
    
    // MARK: - Bot Testimonials Section
    private var botTestimonialsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("💬 WHAT OTHER TRADERS SAY")
                .font(.headline)
                .fontWeight(.black)
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(storeService.testimonials) { testimonial in
                        TestimonialCard(testimonial: testimonial)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    // MARK: - Helper Methods and Data
    private func setupShoppingExperience() {
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            animateCards = true
        }
        
        // Start bot pitching animations
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            storeService.rotatePitchingBots()
        }
    }
    
    private func getBotsForCurrentAisle() -> [MarketplaceBotModel] {
        return storeService.getBotsForAisle(currentAisle)
    }
}

// MARK: - Bot Pitch Card
struct BotPitchCard: View {
    let bot: MarketplaceBotModel
    let onTap: () -> Void
    @State private var showingPitch = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Bot character avatar
                BotCharacterAvatar(bot: bot, size: 60)
                
                VStack(spacing: 8) {
                    Text(bot.name)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    // Bot's pitch bubble
                    VStack(spacing: 6) {
                        Text("💬")
                            .font(.caption)
                        
                        Text(bot.currentPitch)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.ultraThinMaterial)
                            .cornerRadius(8)
                    }
                    
                    // Quick stats
                    HStack(spacing: 12) {
                        VStack(spacing: 2) {
                            Text("\(bot.stats.formattedTotalReturn)")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            Text("Returns")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        
                        VStack(spacing: 2) {
                            Text(String(format: "%.0f%%", bot.stats.winRate))
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            Text("Win Rate")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Action buttons
                    HStack(spacing: 8) {
                        Button("Chat") {
                            onTap()
                        }
                        .font(.caption2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.blue)
                        .cornerRadius(6)
                        
                        Button("🛒 Hire") {
                            BotCartManager.shared.addToCart(bot)
                        }
                        .font(.caption2)
                        .foregroundColor(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(DesignSystem.primaryGold)
                        .cornerRadius(6)
                    }
                }
            }
            .padding()
            .frame(width: 180)
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(bot.rarity.color.opacity(0.5), lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Interactive Bot Card
struct InteractiveBotCard: View {
    let bot: MarketplaceBotModel
    let onTap: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Bot character avatar with customization indicator
                ZStack {
                    BotCharacterAvatar(bot: bot, size: 80)
                    
                    if bot.isCustomizable {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Image(systemName: "paintbrush.fill")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                    .padding(4)
                                    .background(.purple)
                                    .clipShape(Circle())
                            }
                        }
                    }
                }
                
                VStack(spacing: 8) {
                    // Bot name and verification
                    HStack {
                        Text(bot.name)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        if bot.verificationStatus == .verified {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    // Bot's value proposition
                    Text(bot.valueProposition)
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    // Performance metrics
                    VStack(spacing: 4) {
                        HStack {
                            Text("ROI:")
                                .font(.caption2)
                                .foregroundColor(.gray)
                            Spacer()
                            Text(bot.stats.formattedTotalReturn)
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(bot.stats.totalReturn >= 0 ? .green : .red)
                        }
                        
                        HStack {
                            Text("Win Rate:")
                                .font(.caption2)
                                .foregroundColor(.gray)
                            Spacer()
                            Text(String(format: "%.0f%%", bot.stats.winRate))
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                        
                        HStack {
                            Text("Clients:")
                                .font(.caption2)
                                .foregroundColor(.gray)
                            Spacer()
                            Text("\(bot.stats.totalUsers)")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.purple)
                        }
                    }
                    
                    // Price and hiring fee
                    VStack(spacing: 4) {
                        HStack {
                            Text(bot.formattedPrice)
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(DesignSystem.primaryGold)
                            
                            Spacer()
                            
                            // Star rating
                            HStack(spacing: 1) {
                                ForEach(0..<5) { star in
                                    Image(systemName: star < Int(bot.averageRating) ? "star.fill" : "star")
                                        .font(.caption2)
                                        .foregroundColor(.yellow)
                                }
                            }
                        }
                        
                        if bot.hasSpecialOffer {
                            Text("🔥 LIMITED OFFER!")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                                .pulsingEffect()
                        }
                    }
                    
                    // Action buttons
                    HStack(spacing: 6) {
                        Button("💬") {
                            // Open chat with bot
                        }
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(6)
                        .background(.blue.opacity(0.8))
                        .clipShape(Circle())
                        
                        Button("🛒 HIRE") {
                            BotCartManager.shared.addToCart(bot)
                        }
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(DesignSystem.primaryGold)
                        .cornerRadius(12)
                        
                        if bot.isCustomizable {
                            Button("🎨") {
                                // Open customization
                            }
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(6)
                            .background(.purple.opacity(0.8))
                            .clipShape(Circle())
                        }
                    }
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isHovered ? bot.rarity.color : bot.rarity.color.opacity(0.3), 
                        lineWidth: isHovered ? 3 : 1
                    )
            )
            .scaleEffect(isHovered ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Bot Character Avatar
struct BotCharacterAvatar: View {
    let bot: MarketplaceBotModel
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Rarity background
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            bot.rarity.color.opacity(0.8),
                            bot.rarity.color.opacity(0.3),
                            bot.rarity.color.opacity(0.1)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size/2
                    )
                )
                .frame(width: size, height: size)
            
            // Bot character
            Text(bot.character.avatar)
                .font(.system(size: size * 0.6))
            
            // Animated elements for rare bots
            if bot.rarity.rawValue == "Legendary" || bot.rarity.rawValue == "Mythic" {
                ForEach(0..<3) { i in
                    Circle()
                        .stroke(bot.rarity.color.opacity(0.5), lineWidth: 2)
                        .frame(width: size + CGFloat(i * 10), height: size + CGFloat(i * 10))
                        .scaleEffect(1.0 + sin(Date().timeIntervalSince1970 + Double(i)) * 0.1)
                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: Date())
                }
            }
        }
    }
}

// MARK: - Cart Item Preview
struct CartItemPreview: View {
    let item: CartItem
    
    var body: some View {
        VStack(spacing: 4) {
            BotCharacterAvatar(bot: item.bot, size: 40)
            
            Text(item.bot.name)
                .font(.caption2)
                .foregroundColor(.white)
                .lineLimit(1)
            
            Text(item.bot.formattedPrice)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(DesignSystem.primaryGold)
        }
        .padding(8)
        .background(.ultraThinMaterial)
        .cornerRadius(8)
    }
}

// MARK: - Testimonial Card
struct TestimonialCard: View {
    let testimonial: BotTestimonial
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(testimonial.userAvatar)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(testimonial.username)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 1) {
                        ForEach(0..<5) { star in
                            Image(systemName: star < testimonial.rating ? "star.fill" : "star")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                        }
                    }
                }
                
                Spacer()
            }
            
            Text(testimonial.review)
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(4)
            
            HStack {
                Text("Bot: \(testimonial.botName)")
                    .font(.caption2)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text(testimonial.profit)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .frame(width: 200)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview {
    BotStoreView()
}
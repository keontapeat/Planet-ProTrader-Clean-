//
//  BotCartManager.swift
//  Planet ProTrader - Bot Shopping Cart
//
//  Shopping cart system for hiring bots
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI
import Foundation

struct CartItem: Identifiable, Codable {
    let id = UUID()
    let bot: MarketplaceBotModel
    let addedDate: Date
    var quantity: Int = 1
    var negotiatedPrice: Double?
    var customization: ABotCharacter.CharacterCustomization?
    
    var finalPrice: Double {
        return negotiatedPrice ?? bot.price
    }
    
    var formattedFinalPrice: String {
        if finalPrice == 0 {
            return "FREE"
        } else {
            return "$\(String(format: "%.2f", finalPrice))"
        }
    }
}

@MainActor
class BotCartManager: ObservableObject {
    static let shared = BotCartManager()
    
    @Published var cartItems: [CartItem] = []
    @Published var isProcessingHiring = false
    @Published var lastHiredBots: [MarketplaceBotModel] = []
    
    var totalItems: Int {
        cartItems.reduce(0) { $0 + $1.quantity }
    }
    
    var totalCost: Double {
        cartItems.reduce(0) { $0 + ($1.finalPrice * Double($1.quantity)) }
    }
    
    var formattedTotal: String {
        if totalCost == 0 {
            return "FREE"
        } else {
            return "$\(String(format: "%.2f", totalCost))"
        }
    }
    
    private init() {
        loadCart()
    }
    
    // MARK: - Cart Management
    
    func addToCart(_ bot: MarketplaceBotModel) {
        // Check if bot is already in cart
        if let existingIndex = cartItems.firstIndex(where: { $0.bot.id == bot.id }) {
            cartItems[existingIndex].quantity += 1
        } else {
            let cartItem = CartItem(bot: bot, addedDate: Date())
            cartItems.append(cartItem)
        }
        
        saveCart()
        
        // Show success feedback
        GlobalToastManager.shared.show("🤖 \(bot.name) added to hiring cart!", type: .success)
        
        // Trigger cart animation
        objectWillChange.send()
    }
    
    func removeFromCart(_ item: CartItem) {
        cartItems.removeAll { $0.id == item.id }
        saveCart()
        GlobalToastManager.shared.show("Bot removed from cart", type: .info)
    }
    
    func updateQuantity(for item: CartItem, quantity: Int) {
        if let index = cartItems.firstIndex(where: { $0.id == item.id }) {
            if quantity > 0 {
                cartItems[index].quantity = quantity
            } else {
                cartItems.remove(at: index)
            }
            saveCart()
        }
    }
    
    func clearCart() {
        cartItems.removeAll()
        saveCart()
        GlobalToastManager.shared.show("Cart cleared", type: .info)
    }
    
    // MARK: - Hiring Process
    
    func processHiring() {
        guard !cartItems.isEmpty else { return }
        
        isProcessingHiring = true
        
        Task {
            // Simulate hiring process
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            
            await MainActor.run {
                let hiredBots = cartItems.map { $0.bot }
                lastHiredBots = hiredBots
                
                // Deploy bots to PersistentBotManager
                for item in cartItems {
                    let proTraderBot = ProTraderBot(
                        botNumber: Int.random(in: 1...9999),
                        name: item.bot.name,
                        xp: 100.0,
                        confidence: Double.random(in: 0.7...0.9),
                        strategy: ProTraderBot.TradingStrategy.scalping,
                        wins: 0,
                        losses: 0,
                        totalTrades: 0,
                        profitLoss: 0.0,
                        learningHistory: [],
                        lastTraining: nil,
                        isActive: true,
                        specialization: ProTraderBot.BotSpecialization.goldExpert,
                        aiEngine: ProTraderBot.AIEngineType.neuralNetwork,
                        vpsStatus: ProTraderBot.VPSStatus.connected
                    )
                    
                    PersistentBotManager.shared.deployBot(proTraderBot)
                }
                
                // Clear cart
                cartItems.removeAll()
                saveCart()
                
                isProcessingHiring = false
                
                GlobalToastManager.shared.show("🎉 Successfully hired \(hiredBots.count) bots! They're now working for you!", type: .success)
            }
        }
    }
    
    func negotiatePrice(for item: CartItem, newPrice: Double) {
        if let index = cartItems.firstIndex(where: { $0.id == item.id }) {
            cartItems[index].negotiatedPrice = newPrice
            saveCart()
        }
    }
    
    func applyCustomization(for item: CartItem, customization: ABotCharacter.CharacterCustomization) {
        if let index = cartItems.firstIndex(where: { $0.id == item.id }) {
            cartItems[index].customization = customization
            saveCart()
        }
    }
    
    // MARK: - Persistence
    
    private func saveCart() {
        if let data = try? JSONEncoder().encode(cartItems) {
            UserDefaults.standard.set(data, forKey: "BotShoppingCart")
        }
    }
    
    private func loadCart() {
        if let data = UserDefaults.standard.data(forKey: "BotShoppingCart"),
           let items = try? JSONDecoder().decode([CartItem].self, from: data) {
            cartItems = items
        }
    }
}

// MARK: - Shopping Cart View
struct BotShoppingCartView: View {
    @StateObject private var cartManager = BotCartManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingCheckout = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.AnimatedStarField()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if cartManager.cartItems.isEmpty {
                        emptyCartView
                    } else {
                        cartContentView
                    }
                }
            }
            .navigationTitle("🛒 Hiring Cart")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(DesignSystem.primaryGold)
                }
                
                if !cartManager.cartItems.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Clear") {
                            cartManager.clearCart()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
        }
    }
    
    private var emptyCartView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Text("🛒")
                .font(.system(size: 80))
            
            Text("Your Hiring Cart is Empty")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Browse the bot marketplace and hire some money-making bots!")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Browse Bots") {
                dismiss()
            }
            .font(.headline)
            .foregroundColor(.black)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(DesignSystem.primaryGold)
            .cornerRadius(25)
            
            Spacer()
        }
    }
    
    private var cartContentView: some View {
        VStack(spacing: 0) {
            // Cart items list
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(cartManager.cartItems) { item in
                        CartItemCard(item: item)
                    }
                }
                .padding()
            }
            
            // Checkout section
            checkoutSection
        }
    }
    
    private var checkoutSection: some View {
        VStack(spacing: 16) {
            Divider()
            
            // Total summary
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Bots: \(cartManager.totalItems)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("Total Investment:")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text(cartManager.formattedTotal)
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundColor(DesignSystem.primaryGold)
            }
            
            // Hire button
            Button(action: {
                cartManager.processHiring()
                dismiss()
            }) {
                HStack {
                    if cartManager.isProcessingHiring {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                        Text("Hiring Bots...")
                    } else {
                        Text("💰 HIRE ALL BOTS")
                    }
                }
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(DesignSystem.primaryGold)
                .cornerRadius(25)
            }
            .disabled(cartManager.isProcessingHiring)
        }
        .padding()
        .background(.ultraThinMaterial)
    }
}

// MARK: - Cart Item Card
struct CartItemCard: View {
    let item: CartItem
    @StateObject private var cartManager = BotCartManager.shared
    
    var body: some View {
        HStack(spacing: 16) {
            // Bot avatar
            BotCharacterAvatar(bot: item.bot, size: 60)
            
            // Bot info
            VStack(alignment: .leading, spacing: 6) {
                Text(item.bot.name)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("by \(item.bot.creatorUsername)")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack {
                    Text("Win Rate: \(String(format: "%.0f%%", item.bot.stats.winRate))")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    if let negotiatedPrice = item.negotiatedPrice {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(item.bot.formattedPrice)
                                .font(.caption2)
                                .strikethrough()
                                .foregroundColor(.gray)
                            
                            Text("$\(String(format: "%.2f", negotiatedPrice))")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                    } else {
                        Text(item.formattedFinalPrice)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(DesignSystem.primaryGold)
                    }
                }
            }
            
            // Quantity controls
            VStack(spacing: 8) {
                Button("+") {
                    cartManager.updateQuantity(for: item, quantity: item.quantity + 1)
                }
                .font(.caption)
                .foregroundColor(.white)
                .padding(8)
                .background(.green)
                .clipShape(Circle())
                
                Text("\(item.quantity)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Button("-") {
                    cartManager.updateQuantity(for: item, quantity: item.quantity - 1)
                }
                .font(.caption)
                .foregroundColor(.white)
                .padding(8)
                .background(.red)
                .clipShape(Circle())
                
                Button("🗑️") {
                    cartManager.removeFromCart(item)
                }
                .font(.caption)
                .padding(4)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(item.bot.rarity.color.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    BotShoppingCartView()
}
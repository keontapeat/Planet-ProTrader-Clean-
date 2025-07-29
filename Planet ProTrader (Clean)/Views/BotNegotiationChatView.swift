//
//  BotNegotiationChatView.swift
//  Planet ProTrader (Clean)
//
//  Chat interface for negotiating with bots
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

struct BotNegotiationChatView: View {
    let bot: MarketplaceBotModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var cartManager = BotCartManager.shared
    @State private var messages: [ChatMessage] = []
    @State private var newMessage = ""
    @State private var negotiatedPrice: Double = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Chat header
                chatHeader
                
                // Messages
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            ChatBubble(message: message)
                        }
                    }
                    .padding()
                }
                
                // Input area
                chatInput
            }
            .navigationBarHidden(true)
            .onAppear {
                setupInitialChat()
            }
        }
    }
    
    private var chatHeader: some View {
        HStack {
            Button("Close") {
                dismiss()
            }
            .foregroundColor(.blue)
            
            Spacer()
            
            VStack(spacing: 4) {
                BotCharacterAvatar(bot: bot, size: 40)
                
                Text(bot.name)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Button("Hire") {
                if negotiatedPrice > 0 {
                    cartManager.negotiatePrice(
                        for: CartItem(bot: bot, addedDate: Date()),
                        newPrice: negotiatedPrice
                    )
                }
                cartManager.addToCart(bot)
                dismiss()
            }
            .fontWeight(.bold)
            .foregroundColor(DesignSystem.primaryGold)
        }
        .padding()
        .background(.ultraThinMaterial)
    }
    
    private var chatInput: some View {
        HStack {
            TextField("Message \(bot.name)...", text: $newMessage)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button("Send") {
                sendMessage()
            }
            .foregroundColor(.blue)
            .disabled(newMessage.isEmpty)
        }
        .padding()
        .background(.ultraThinMaterial)
    }
    
    private func setupInitialChat() {
        negotiatedPrice = bot.price
        
        messages = [
            ChatMessage(
                id: UUID(),
                text: "👋 Hey there! I'm \(bot.name), your potential trading partner!",
                isFromBot: true,
                timestamp: Date()
            ),
            ChatMessage(
                id: UUID(),
                text: bot.currentPitch,
                isFromBot: true,
                timestamp: Date().addingTimeInterval(1)
            ),
            ChatMessage(
                id: UUID(),
                text: "My standard rate is \(bot.formattedPrice), but I'm open to negotiation! What do you think?",
                isFromBot: true,
                timestamp: Date().addingTimeInterval(2)
            )
        ]
    }
    
    private func sendMessage() {
        let userMessage = ChatMessage(
            id: UUID(),
            text: newMessage,
            isFromBot: false,
            timestamp: Date()
        )
        messages.append(userMessage)
        
        // Generate bot response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let botResponse = generateBotResponse(to: newMessage)
            messages.append(botResponse)
        }
        
        newMessage = ""
    }
    
    private func generateBotResponse(to userMessage: String) -> ChatMessage {
        let lowercaseMessage = userMessage.lowercased()
        
        var response = ""
        
        if lowercaseMessage.contains("price") || lowercaseMessage.contains("cost") || lowercaseMessage.contains("cheap") {
            let discount = Double.random(in: 0.1...0.3)
            negotiatedPrice = bot.price * (1 - discount)
            response = "I understand budget is important! How about \(String(format: "$%.0f", negotiatedPrice))? That's \(String(format: "%.0f%%", discount * 100)) off my usual rate!"
        } else if lowercaseMessage.contains("performance") || lowercaseMessage.contains("results") {
            response = "Great question! I have a \(String(format: "%.1f%%", bot.stats.winRate)) win rate and have generated \(bot.stats.formattedTotalReturn) returns for my clients. My track record speaks for itself!"
        } else if lowercaseMessage.contains("experience") || lowercaseMessage.contains("background") {
            response = "I've been trading for years and have helped \(bot.stats.totalUsers) clients achieve their financial goals. I specialize in \(bot.character.specialties.joined(separator: " and "))."
        } else if lowercaseMessage.contains("yes") || lowercaseMessage.contains("deal") || lowercaseMessage.contains("hire") {
            response = "Excellent! I'm excited to work with you and help grow your portfolio. Let's make some money together! 💰"
        } else if lowercaseMessage.contains("no") || lowercaseMessage.contains("expensive") {
            let betterDiscount = Double.random(in: 0.2...0.4)
            negotiatedPrice = bot.price * (1 - betterDiscount)
            response = "I really want to work with you! How about \(String(format: "$%.0f", negotiatedPrice))? That's my best offer - \(String(format: "%.0f%%", betterDiscount * 100)) off!"
        } else {
            let responses = [
                "That's interesting! Tell me more about your trading goals.",
                "I love working with motivated traders like you!",
                "My \(bot.character.catchPhrase)",
                "I'm confident I can help you achieve great results!",
                "What other questions do you have about my trading approach?"
            ]
            response = responses.randomElement()!
        }
        
        return ChatMessage(
            id: UUID(),
            text: response,
            isFromBot: true,
            timestamp: Date()
        )
    }
}

struct ChatMessage: Identifiable {
    let id: UUID
    let text: String
    let isFromBot: Bool
    let timestamp: Date
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if !message.isFromBot {
                Spacer()
            }
            
            VStack(alignment: message.isFromBot ? .leading : .trailing, spacing: 4) {
                Text(message.text)
                    .font(.subheadline)
                    .foregroundColor(message.isFromBot ? .white : .black)
                    .padding()
                    .background(
                        message.isFromBot 
                        ? .blue.opacity(0.8)
                        : DesignSystem.primaryGold
                    )
                    .cornerRadius(16)
                    .frame(maxWidth: 250, alignment: message.isFromBot ? .leading : .trailing)
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            if message.isFromBot {
                Spacer()
            }
        }
    }
}

#Preview {
    BotNegotiationChatView(bot: MarketplaceBotModel.generateRandomBot())
}
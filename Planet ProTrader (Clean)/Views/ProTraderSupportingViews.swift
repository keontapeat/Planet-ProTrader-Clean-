//
//  ProTraderSupportingViews.swift
//  Planet ProTrader - Solar System Edition
//
//  Created by Keonta Peat on 1/25/25.
//

import SwiftUI
import Foundation

// MARK: - ProTrader Metric Card
struct AProTraderMetricCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let trend: TrendDirection
    
    enum TrendDirection {
        case up, down, stable
        
        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .stable: return "minus"
            }
        }
        
        var color: Color {
            switch self {
            case .up: return .green
            case .down: return .red
            case .stable: return .gray
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(color)
                
                Spacer()
                
                Image(systemName: trend.icon)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(trend.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
                
                Text(subtitle)
                    .font(.system(size: 10, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Army Stat Card
struct MyArmyStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(color)
            
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            Text(title)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.8))
            
            Text(subtitle)
                .font(.system(size: 8, weight: .regular, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Quick Action Button
struct TheQuickActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.blue)
                
                Text(title)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text(subtitle)
                    .font(.system(size: 10, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Top Performer Row
struct MTopPerformerRow: View {
    let rank: Int
    let bot: ProTraderBot
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Rank
                ZStack {
                    Circle()
                        .fill(rankColor)
                        .frame(width: 32, height: 32)
                    
                    Text("\(rank)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                
                // Bot Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(bot.name)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        
                        Spacer()
                        
                        Text(bot.confidenceLevel)
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(confidenceColor(bot.confidence))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(confidenceColor(bot.confidence).opacity(0.2), in: Capsule())
                    }
                    
                    HStack {
                        Text("Confidence: \(String(format: "%.1f%%", bot.confidence * 100))")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.7))
                        
                        Spacer()
                        
                        Text("P&L: \(formatCurrency(bot.profitLoss))")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(bot.profitLoss >= 0 ? .green : .red)
                    }
                }
                
                // Status indicator
                Circle()
                    .fill(bot.isActive ? .green : .gray)
                    .frame(width: 8, height: 8)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return .orange
        case 2: return .gray
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2)
        default: return .blue
        }
    }
    
    private func confidenceColor(_ confidence: Double) -> Color {
        switch confidence {
        case 0.95...: return .orange
        case 0.9..<0.95: return .red
        case 0.8..<0.9: return .purple
        case 0.7..<0.8: return .blue
        case 0.6..<0.7: return .green
        default: return .gray
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}

// MARK: - Confidence Chart View
struct ConfidenceChartView: View {
    let bots: [ProTraderBot]
    
    private var confidenceData: [(String, Int, Color)] {
        let godmode = bots.filter { $0.confidence >= 0.95 }.count
        let godlike = bots.filter { $0.confidence >= 0.9 && $0.confidence < 0.95 }.count
        let elite = bots.filter { $0.confidence >= 0.8 && $0.confidence < 0.9 }.count
        let pro = bots.filter { $0.confidence >= 0.7 && $0.confidence < 0.8 }.count
        let advanced = bots.filter { $0.confidence >= 0.6 && $0.confidence < 0.7 }.count
        let learning = bots.filter { $0.confidence < 0.6 }.count
        
        return [
            ("GODMODE", godmode, .orange),
            ("GODLIKE", godlike, .red),
            ("ELITE", elite, .purple),
            ("PRO", pro, .blue),
            ("ADVANCED", advanced, .green),
            ("LEARNING", learning, .gray)
        ]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Chart bars
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(confidenceData, id: \.0) { category, count, color in
                    VStack(spacing: 8) {
                        // Bar
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [color, color.opacity(0.6)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: CGFloat(count) / CGFloat(bots.count) * 120 + 20)
                        
                        // Category label
                        VStack(spacing: 2) {
                            Text("\(count)")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            
                            Text(category)
                                .font(.system(size: 8, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                    }
                }
            }
            
            // Legend
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                ForEach(confidenceData, id: \.0) { category, count, color in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(color)
                            .frame(width: 8, height: 8)
                        
                        Text(category)
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.8))
                        
                        Spacer()
                        
                        Text("\(count)")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                }
            }
        }
    }
}

// MARK: - Bot Detail View (Enhanced version)
struct BotDetailView: View {
    let bot: ProTraderBot
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Bot Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(bot.name)
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                
                                Text("Bot #\(bot.botNumber)")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text(bot.confidenceLevel)
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(confidenceColor(bot.confidence))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(confidenceColor(bot.confidence).opacity(0.2), in: Capsule())
                                
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(bot.isActive ? .green : .gray)
                                        .frame(width: 8, height: 8)
                                    
                                    Text(bot.isActive ? "ACTIVE" : "IDLE")
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundStyle(bot.isActive ? .green : .gray)
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(confidenceColor(bot.confidence).opacity(0.3), lineWidth: 1)
                            )
                    )
                    
                    // Performance Metrics
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Performance Metrics")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                            MyStatCard(title: "Confidence", value: String(format: "%.1f%%", bot.confidence * 100))
                            MyStatCard(title: "Win Rate", value: String(format: "%.1f%%", bot.winRate))
                            MyStatCard(title: "P&L", value: formatCurrency(bot.profitLoss))
                            MyStatCard(title: "Total Trades", value: "\(bot.totalTrades)")
                            MyStatCard(title: "XP Points", value: String(format: "%.0f", bot.xp))
                            MyStatCard(title: "Grade", value: bot.performanceGrade)
                        }
                    }
                    
                    // Bot Configuration
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Configuration")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        
                        VStack(spacing: 12) {
                            ProTraderInfoRow(label: "Strategy", value: bot.strategy.rawValue)
                            ProTraderInfoRow(label: "Specialization", value: bot.specialization.rawValue)
                            ProTraderInfoRow(label: "AI Engine", value: bot.aiEngine.rawValue)
                            ProTraderInfoRow(label: "VPS Status", value: bot.vpsStatus.rawValue)
                            
                            if let lastTraining = bot.lastTraining {
                                ProTraderInfoRow(label: "Last Training", value: formatDate(lastTraining))
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.white.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(.white.opacity(0.1), lineWidth: 1)
                                )
                        )
                    }
                    
                    Spacer()
                }
                .padding(20)
            }
            .background(Color.black)
            .navigationTitle("Bot Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(.blue)
                }
            }
        }
    }
    
    private func confidenceColor(_ confidence: Double) -> Color {
        switch confidence {
        case 0.95...: return .orange
        case 0.9..<0.95: return .red
        case 0.8..<0.9: return .purple
        case 0.7..<0.8: return .blue
        case 0.6..<0.7: return .green
        default: return .gray
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct MyStatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, minHeight: 80)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct ProTraderInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
        }
    }
}

// MARK: - Enhanced ProTrader GPT Chat View
struct ProTraderGPTChatView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var messages: [ChatMessage] = [
        ChatMessage(content: "👋 Hello! I'm your ProTrader AI Assistant. How can I help you optimize your trading bots today?", isUser: false)
    ]
    @State private var inputText = ""
    
    struct ChatMessage: Identifiable {
        let id = UUID()
        let content: String
        let isUser: Bool
        let timestamp = Date()
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Messages
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(messages) { message in
                            HStack {
                                if message.isUser {
                                    Spacer()
                                    
                                    Text(message.content)
                                        .padding(12)
                                        .background(Color.blue.opacity(0.2))
                                        .foregroundStyle(.white)
                                        .cornerRadius(12)
                                        .frame(maxWidth: .infinity * 0.8, alignment: .trailing)
                                } else {
                                    HStack(alignment: .top, spacing: 8) {
                                        Text("🤖")
                                            .font(.title3)
                                        
                                        Text(message.content)
                                            .padding(12)
                                            .background(.white.opacity(0.1))
                                            .foregroundStyle(.white)
                                            .cornerRadius(12)
                                            .frame(maxWidth: .infinity * 0.8, alignment: .leading)
                                    }
                                    
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding(16)
                }
                
                // Input area
                HStack(spacing: 12) {
                    TextField("Ask about your bots...", text: $inputText)
                        .textFieldStyle(.roundedBorder)
                    
                    Button("Send") {
                        sendMessage()
                    }
                    .disabled(inputText.isEmpty)
                    .buttonStyle(.borderedProminent)
                }
                .padding(16)
            }
            .background(Color.black)
            .navigationTitle("ProTrader GPT")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(.blue)
                }
            }
        }
    }
    
    private func sendMessage() {
        let userMessage = ChatMessage(content: inputText, isUser: true)
        messages.append(userMessage)
        
        let aiResponse = generateAIResponse(to: inputText)
        let aiMessage = ChatMessage(content: aiResponse, isUser: false)
        
        inputText = ""
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            messages.append(aiMessage)
        }
    }
    
    private func generateAIResponse(to input: String) -> String {
        let responses = [
            "🎯 Based on your query, I recommend focusing on your GODMODE bots for maximum profit potential.",
            "📊 Your bot army is performing well! Consider increasing the confidence threshold for better results.",
            "⚡ I suggest deploying more bots to the trending markets for optimal returns.",
            "🧠 Your AI models are learning efficiently. Keep training with fresh market data!",
            "🚀 Your VPS connection is stable. Perfect time to scale up your trading operations.",
            "💡 Try adjusting your risk management settings for more consistent performance."
        ]
        return responses.randomElement() ?? "Thanks for your question! I'm here to help optimize your ProTrader Army."
    }
}

#Preview {
    VStack(spacing: 20) {
        AProTraderMetricCard(
            icon: "brain.head.profile",
            title: "Avg Confidence",
            value: "87.5%",
            subtitle: "Target: 90%+",
            color: .blue,
            trend: .up
        )
        
        MyArmyStatCard(
            title: "Active Bots",
            value: "4,250",
            icon: "robot",
            color: .green,
            subtitle: "Trading Now"
        )
    }
    .padding(20)
    .background(Color.black)
    .preferredColorScheme(.dark)
}
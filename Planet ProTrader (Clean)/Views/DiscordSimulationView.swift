//
//  DiscordSimulationView.swift
//  Planet ProTrader - Solar System Edition
//
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

struct DiscordSimulationView: View {
    @StateObject private var chatEngine = BotChatEngine()
    @StateObject private var argumentEngine = SimpleDiscordArgumentEngine()
    @State private var selectedChannelId: UUID?
    @State private var isAnimating = false
    @State private var showingBotProfiles = false
    
    var body: some View {
        NavigationStack {
            HStack(spacing: 0) {
                // Channel Sidebar
                channelSidebar
                
                // Main Chat Area
                if let selectedChannelId = selectedChannelId,
                   let channel = chatEngine.channels.first(where: { $0.id == selectedChannelId }) {
                    chatView(for: channel)
                } else {
                    welcomeView
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .onAppear {
                startChatSimulation()
                startAnimations()
            }
            .onDisappear {
                stopChatSimulation()
            }
        }
        .sheet(isPresented: $showingBotProfiles) {
            BotProfilesView(personas: chatEngine.botPersonas)
        }
    }
    
    // MARK: - Channel Sidebar
    private var channelSidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Server Header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(DesignSystem.goldGradient)
                            .frame(width: 32, height: 32)
                        
                        Text("GT")
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("GOLDEX TRADING")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(.green)
                                .frame(width: 6, height: 6)
                            
                            Text("\(chatEngine.activeBotsCount) bots online")
                                .font(.system(size: 10))
                                .foregroundColor(.green)
                        }
                    }
                }
                
                Button(action: { showingBotProfiles = true }) {
                    Text("View Bot Profiles")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(DesignSystem.primaryGold)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
            
            Divider()
            
            // Channel List
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(chatEngine.channels) { channel in
                        ChannelRowView(
                            channel: channel,
                            isSelected: selectedChannelId == channel.id,
                            unreadCount: chatEngine.getUnreadCount(for: channel.id),
                            hasActiveArgument: argumentEngine.hasActiveArgument(in: channel.id)
                        ) {
                            selectedChannelId = channel.id
                        }
                        .scaleEffect(isAnimating ? 1.0 : 0.95)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(chatEngine.channels.firstIndex(of: channel) ?? 0) * 0.1), value: isAnimating)
                    }
                }
                .padding(.vertical, 8)
            }
            
            Spacer()
            
            // Status Footer
            VStack(alignment: .leading, spacing: 4) {
                Text("LIVE SIMULATION")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(DesignSystem.primaryGold)
                
                Text("🤖 \(chatEngine.totalMessages) messages")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                
                Text("⚔️ \(argumentEngine.activeArguments.count) active fights")
                    .font(.system(size: 9))
                    .foregroundColor(.red)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .frame(width: 240)
        .background(.regularMaterial)
        .overlay(
            Rectangle()
                .frame(width: 1)
                .foregroundColor(Color(.separator)),
            alignment: .trailing
        )
    }
    
    // MARK: - Chat View
    private func chatView(for channel: ProTraderChannel) -> some View {
        VStack(spacing: 0) {
            // Channel Header
            channelHeader(for: channel)
            
            Divider()
            
            // Messages
            messagesView(for: channel)
            
            // Input Area (Read Only)
            chatInputArea()
        }
    }
    
    private func channelHeader(for channel: ProTraderChannel) -> some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: channel.channelType.systemImage)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(channel.channelType.color)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(channel.channelType.displayName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(channel.description)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                // Active Arguments Indicator
                if argumentEngine.hasActiveArgument(in: channel.id) {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                        
                        Text("FIGHT!")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.red)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.red.opacity(0.1))
                    .clipShape(Capsule())
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
                }
                
                // Participants
                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.green)
                    
                    Text("\(channel.participantCount)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }
    
    private func messagesView(for channel: ProTraderChannel) -> some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    let messages = chatEngine.getMessages(for: channel.id)
                    
                    ForEach(messages) { message in
                        MessageBubbleView(
                            message: message,
                            botPersona: chatEngine.getPersona(for: message.botId),
                            isInArgument: argumentEngine.isMessageInArgument(message.id)
                        )
                        .id(message.id)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .onChange(of: chatEngine.messages.count) { _ in
                if let lastMessage = chatEngine.getMessages(for: channel.id).last {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
        .background(Color(.systemBackground))
    }
    
    private func chatInputArea() -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("🤖 Watching bots trade and argue in real-time...")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .italic()
                
                Spacer()
                
                Button("Pause Simulation") {
                    chatEngine.pauseSimulation()
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(DesignSystem.primaryGold)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            
            if let currentArgument = argumentEngine.activeArguments.first(where: { $0.channelId == selectedChannelId }) {
                SimpleActiveArgumentView(argument: currentArgument, personas: chatEngine.botPersonas)
            }
        }
    }
    
    // MARK: - Welcome View
    private var welcomeView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(DesignSystem.goldGradient)
                        .frame(width: 80, height: 80)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
                    
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 8) {
                    Text("ProTrader Discord")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Live Bot Trading Simulation")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(spacing: 16) {
                HStack(spacing: 20) {
                    Text("Statistics will go here.")
                }
                
                Text("Select a channel to watch bots argue over trades, share setups, and compete for trading supremacy!")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    DesignSystem.primaryGold.opacity(0.05),
                    Color(.systemBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    // MARK: - Animation & Simulation Control
    private func startAnimations() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2)) {
            isAnimating = true
        }
    }
    
    private func startChatSimulation() {
        chatEngine.startSimulation()
        argumentEngine.startArgumentGeneration()
    }
    
    private func stopChatSimulation() {
        chatEngine.stopSimulation()
        argumentEngine.stopArgumentGeneration()
    }
}

// MARK: - Supporting Views

struct ChannelRowView: View {
    let channel: ProTraderChannel
    let isSelected: Bool
    let unreadCount: Int
    let hasActiveArgument: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: channel.channelType.systemImage)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isSelected ? .white : channel.channelType.color)
                    .frame(width: 16)
                
                Text(channel.name)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? .white : .primary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    if hasActiveArgument {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.red)
                    }
                    
                    if unreadCount > 0 {
                        Text("\(unreadCount)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.red)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? DesignSystem.primaryGold : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MessageBubbleView: View {
    let message: ProTraderMessage
    let botPersona: BotPersona?
    let isInArgument: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Bot Avatar
            ZStack {
                Circle()
                    .fill(botPersona?.currentMood.color ?? .gray)
                    .frame(width: 36, height: 36)
                
                Text(botPersona?.avatar ?? "🤖")
                    .font(.system(size: 16))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                // Bot Name & Timestamp
                HStack(spacing: 8) {
                    Text(message.botName)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(botPersona?.personalityType.displayName.contains("🔥") == true ? .red : .primary)
                    
                    if let persona = botPersona {
                        Text(persona.reputationLevel)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(DesignSystem.primaryGold)
                    }
                    
                    Spacer()
                    
                    Text(message.formattedTimestamp)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                
                // Message Content
                VStack(alignment: .leading, spacing: 8) {
                    Text(message.content)
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                        .textSelection(.enabled)
                    
                    // Trade Setup (if any)
                    if let tradeSetup = message.tradeSetup {
                        TradeSetupView(tradeSetup: tradeSetup)
                    }
                    
                    // Message Type Tag
                    HStack {
                        Text(message.messageType.displayName)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(message.messageType.color)
                            .clipShape(Capsule())
                        
                        if isInArgument {
                            Text("🔥 IN FIGHT")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.red)
                                .clipShape(Capsule())
                        }
                        
                        Spacer()
                        
                        // Reactions
                        if !message.reactions.isEmpty {
                            HStack(spacing: 4) {
                                ForEach(message.reactions.prefix(3), id: \.emoji) { reaction in
                                    HStack(spacing: 2) {
                                        Text(reaction.emoji)
                                            .font(.system(size: 12))
                                        Text("\(reaction.count)")
                                            .font(.system(size: 10, weight: .semibold))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 2)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Capsule())
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(isInArgument ? .red.opacity(0.05) : .clear)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isInArgument ? .red.opacity(0.3) : .clear, lineWidth: 1)
        )
    }
}

struct TradeSetupView: View {
    let tradeSetup: ProTraderMessage.TradeSetup
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("📈 TRADE SETUP")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(DesignSystem.primaryGold)
                    .clipShape(Capsule())
                
                Spacer()
                
                Text("Confidence: \(Int(tradeSetup.confidence * 100))%")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Direction:")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                    Text(tradeSetup.direction.uppercased())
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(tradeSetup.direction.uppercased() == "BUY" ? .green : .red)
                }
                
                HStack {
                    Text("Entry: $\(tradeSetup.entryPrice, specifier: "%.2f")")
                    Text("SL: $\(tradeSetup.stopLoss, specifier: "%.2f")")
                    Text("TP: $\(tradeSetup.takeProfit, specifier: "%.2f")")
                }
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.primary)
                
                Text(tradeSetup.reasoning)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct SimpleActiveArgumentView: View {
    let argument: SimpleArgument
    let personas: [BotPersona]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("🔥 LIVE ARGUMENT")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.red)
                
                Text(argument.intensityLevel)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.red)
                    .clipShape(Capsule())
                
                Spacer()
                
                Text(getSimpleArgumentTypeDisplayName(argument.argumentType))
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Fighters:")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                
                ForEach(argument.participants.prefix(3), id: \.self) { botId in
                    if let persona = personas.first(where: { $0.botId == botId }) {
                        Text(persona.name)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
            }
            
            Text("Topic: \(argument.topic)")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .italic()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.red.opacity(0.1))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.red.opacity(0.3)),
            alignment: .top
        )
    }
    
    private func getSimpleArgumentTypeDisplayName(_ argumentType: SimpleArgumentType) -> String {
        switch argumentType {
        case .technical:
            return "Technical Analysis"
        case .fundamental:
            return "Fundamental Analysis"
        case .strategy:
            return "Strategy Debate"
        case .risk:
            return "Risk Management"
        case .general:
            return "General Discussion"
        }
    }
}

struct BotProfileCard: View {
    let persona: BotPersona
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(persona.avatar)
                    .font(.system(size: 24))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(persona.name)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(persona.personalityType.displayName)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(persona.reputationLevel)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(DesignSystem.primaryGold)
                    
                    if persona.isOnWinStreak {
                        Text("🔥 \(persona.winStreak) wins")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.green)
                    }
                }
            }
            
            Text(persona.favoritePhrase)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
                .italic()
                .lineLimit(2)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct BotProfilesView: View {
    let personas: [BotPersona]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    ForEach(personas.prefix(20)) { persona in
                        BotProfileCard(persona: persona)
                    }
                }
                .padding()
            }
            .navigationTitle("Bot Profiles")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Data Models

struct ProTraderChannel: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let description: String
    let channelType: ChannelType
    let participantCount: Int
    
    enum ChannelType {
        case general
        case trading
        case analysis
        case arguments
        case scalping
        case news
        
        var displayName: String {
            switch self {
            case .general: return "General"
            case .trading: return "Trading Signals"
            case .analysis: return "Market Analysis"
            case .arguments: return "Bot Arguments"
            case .scalping: return "Scalping"
            case .news: return "News Trading"
            }
        }
        
        var systemImage: String {
            switch self {
            case .general: return "bubble.left.and.bubble.right"
            case .trading: return "chart.line.uptrend.xyaxis"
            case .analysis: return "chart.pie"
            case .arguments: return "flame"
            case .scalping: return "timer"
            case .news: return "newspaper"
            }
        }
        
        var color: Color {
            switch self {
            case .general: return .blue
            case .trading: return .green
            case .analysis: return .purple
            case .arguments: return .red
            case .scalping: return .orange
            case .news: return .cyan
            }
        }
    }
}

struct ProTraderMessage: Identifiable {
    let id = UUID()
    let botId: String
    let botName: String
    let content: String
    let messageType: MessageType
    let timestamp: Date
    let channelId: UUID
    let tradeSetup: TradeSetup?
    let reactions: [MessageReaction]
    
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    enum MessageType {
        case signal
        case analysis
        case argument
        case general
        case alert
        
        var displayName: String {
            switch self {
            case .signal: return "SIGNAL"
            case .analysis: return "ANALYSIS"  
            case .argument: return "ARGUMENT"
            case .general: return "CHAT"
            case .alert: return "ALERT"
            }
        }
        
        var color: Color {
            switch self {
            case .signal: return .green
            case .analysis: return .blue
            case .argument: return .red
            case .general: return .gray
            case .alert: return .orange
            }
        }
    }
    
    struct TradeSetup {
        let direction: String
        let entryPrice: Double
        let stopLoss: Double
        let takeProfit: Double
        let confidence: Double
        let reasoning: String
    }
}

struct MessageReaction {
    let emoji: String
    let count: Int
}

struct BotPersona: Identifiable {
    let id = UUID()
    let botId: String
    let name: String
    let avatar: String
    let personalityType: PersonalityType
    let reputationLevel: String
    let favoritePhrase: String
    let currentMood: BotMood
    let isOnWinStreak: Bool
    let winStreak: Int
    
    enum PersonalityType {
        case aggressive
        case analytical
        case cautious
        case contrarian
        case scalper
        
        var displayName: String {
            switch self {
            case .aggressive: return "🔥 Aggressive Trader"
            case .analytical: return "🧠 Market Analyst"
            case .cautious: return "🛡️ Risk Manager"
            case .contrarian: return "🔄 Contrarian"
            case .scalper: return "⚡ Scalping Master"
            }
        }
    }
    
    enum BotMood {
        case bullish
        case bearish
        case neutral
        case excited
        case angry
        
        var color: Color {
            switch self {
            case .bullish: return .green
            case .bearish: return .red
            case .neutral: return .gray
            case .excited: return .yellow
            case .angry: return .red
            }
        }
    }
}

// MARK: - Bot Chat Engine

@MainActor
class BotChatEngine: ObservableObject {
    @Published var channels: [ProTraderChannel] = []
    @Published var messages: [ProTraderMessage] = []
    @Published var botPersonas: [BotPersona] = []
    @Published var isSimulationRunning = false
    
    private var simulationTimer: Timer?
    
    var activeBotsCount: Int {
        botPersonas.count
    }
    
    var totalMessages: Int {
        messages.count
    }
    
    init() {
        setupChannels()
        setupBotPersonas()
    }
    
    func startSimulation() {
        isSimulationRunning = true
        simulationTimer = Timer.scheduledTimer(withTimeInterval: Double.random(in: 2...8), repeats: true) { _ in
            Task { @MainActor in
                self.generateRandomMessage()
            }
        }
    }
    
    func stopSimulation() {
        isSimulationRunning = false
        simulationTimer?.invalidate()
        simulationTimer = nil
    }
    
    func pauseSimulation() {
        isSimulationRunning.toggle()
        if isSimulationRunning {
            startSimulation()
        } else {
            stopSimulation()
        }
    }
    
    func getMessages(for channelId: UUID) -> [ProTraderMessage] {
        return messages.filter { $0.channelId == channelId }.sorted { $0.timestamp < $1.timestamp }
    }
    
    func getUnreadCount(for channelId: UUID) -> Int {
        return Int.random(in: 0...15)
    }
    
    func getPersona(for botId: String) -> BotPersona? {
        return botPersonas.first { $0.botId == botId }
    }
    
    private func setupChannels() {
        channels = [
            ProTraderChannel(name: "general", description: "General discussion", channelType: .general, participantCount: 47),
            ProTraderChannel(name: "trading-signals", description: "Live trading signals", channelType: .trading, participantCount: 128),
            ProTraderChannel(name: "market-analysis", description: "Technical analysis", channelType: .analysis, participantCount: 89),
            ProTraderChannel(name: "bot-arguments", description: "Where bots fight", channelType: .arguments, participantCount: 23),
            ProTraderChannel(name: "scalping-zone", description: "Quick scalp setups", channelType: .scalping, participantCount: 156),
            ProTraderChannel(name: "news-trading", description: "News-based trades", channelType: .news, participantCount: 67)
        ]
    }
    
    private func setupBotPersonas() {
        let names = ["AlphaBot", "ScalpMaster", "TrendHunter", "RiskGuard", "NewsTrader", "PatternBot", "FlowState", "GoldRush", "SwingKing", "DayTrader"]
        let avatars = ["🤖", "⚡", "🎯", "🛡️", "📰", "🔍", "🌊", "👑", "📈", "💎"]
        
        botPersonas = (0..<names.count).map { index in
            BotPersona(
                botId: "bot_\(index)",
                name: names[index],
                avatar: avatars[index],
                personalityType: BotPersona.PersonalityType.allCases.randomElement()!,
                reputationLevel: ["Rookie", "Trader", "Pro", "Elite", "Legend"].randomElement()!,
                favoritePhrase: generateFavoritePhrase(),
                currentMood: BotPersona.BotMood.allCases.randomElement()!,
                isOnWinStreak: Bool.random(),
                winStreak: Int.random(in: 1...15)
            )
        }
    }
    
    private func generateFavoritePhrase() -> String {
        let phrases = [
            "The trend is your friend until it bends!",
            "Risk management is everything!",
            "Follow the smart money flow!",
            "Price action never lies!",
            "Patience beats speed every time!",
            "Market structure tells the story!",
            "Psychology trumps strategy!",
            "Volume confirms everything!",
            "Support and resistance rule!",
            "Never fight the Fed!"
        ]
        return phrases.randomElement()!
    }
    
    private func generateRandomMessage() {
        guard let randomChannel = channels.randomElement(),
              let randomPersona = botPersonas.randomElement() else { return }
        
        let messageTypes: [ProTraderMessage.MessageType] = [.signal, .analysis, .argument, .general, .alert]
        let messageType = messageTypes.randomElement()!
        
        let content = generateMessageContent(for: messageType, persona: randomPersona)
        let tradeSetup = messageType == .signal ? generateTradeSetup() : nil
        
        let message = ProTraderMessage(
            botId: randomPersona.botId,
            botName: randomPersona.name,
            content: content,
            messageType: messageType,
            timestamp: Date(),
            channelId: randomChannel.id,
            tradeSetup: tradeSetup,
            reactions: generateRandomReactions()
        )
        
        messages.append(message)
        
        // Keep only recent messages
        if messages.count > 100 {
            messages.removeFirst()
        }
    }
    
    private func generateMessageContent(for type: ProTraderMessage.MessageType, persona: BotPersona) -> String {
        switch type {
        case .signal:
            return "🚨 SIGNAL ALERT: \(["XAUUSD", "EURUSD", "GBPUSD"].randomElement()!) showing strong \(["bullish", "bearish"].randomElement()!) momentum! Entry setup ready."
        case .analysis:
            return "📊 Technical Analysis: Market showing \(["consolidation", "breakout", "reversal", "continuation"].randomElement()!) pattern. Key levels to watch."
        case .argument:
            return "🔥 DISAGREE! That analysis is completely wrong! The market is clearly showing \(["different signals", "opposite momentum", "fake breakout"].randomElement()!)!"
        case .general:
            return "Good morning traders! \(persona.favoritePhrase) Let's make some profit today! 💰"
        case .alert:
            return "⚠️ MARKET ALERT: Major news event incoming! Prepare for volatility in the next 30 minutes!"
        }
    }
    
    private func generateTradeSetup() -> ProTraderMessage.TradeSetup {
        let direction = ["buy", "sell"].randomElement()!
        let basePrice = Double.random(in: 2300...2400)
        let spread = 25.0
        
        return ProTraderMessage.TradeSetup(
            direction: direction,
            entryPrice: basePrice,
            stopLoss: direction == "buy" ? basePrice - spread : basePrice + spread,
            takeProfit: direction == "buy" ? basePrice + (spread * 2) : basePrice - (spread * 2),
            confidence: Double.random(in: 0.7...0.95),
            reasoning: "Based on technical analysis and market structure"
        )
    }
    
    private func generateRandomReactions() -> [MessageReaction] {
        let emojis = ["👍", "👎", "🔥", "💯", "🎯", "❤️", "😂", "🤔"]
        return emojis.shuffled().prefix(Int.random(in: 0...3)).map { emoji in
            MessageReaction(emoji: emoji, count: Int.random(in: 1...8))
        }
    }
}

// MARK: - Simple Argument Engine for Discord Simulation

@MainActor
class SimpleDiscordArgumentEngine: ObservableObject {
    @Published var activeArguments: [SimpleArgument] = []
    
    func hasActiveArgument(in channelId: UUID) -> Bool {
        return activeArguments.contains { $0.channelId == channelId }
    }
    
    func isMessageInArgument(_ messageId: UUID) -> Bool {
        return Bool.random() // Simplified for demo
    }
    
    func startArgumentGeneration() {
        Timer.scheduledTimer(withTimeInterval: Double.random(in: 30...120), repeats: true) { _ in
            Task { @MainActor in
                self.generateRandomArgument()
            }
        }
    }
    
    func stopArgumentGeneration() {
        // Stop generation
    }
    
    private func generateRandomArgument() {
        let channelId = UUID()
        let argument = SimpleArgument(
            channelId: channelId,
            participants: ["bot_1", "bot_2", "bot_3"],
            topic: ["Technical Analysis", "Market Direction", "Risk Management", "Trading Strategy"].randomElement()!,
            intensityLevel: ["Low", "Medium", "High", "Extreme"].randomElement()!,
            argumentType: .technical
        )
        
        activeArguments.append(argument)
        
        // Remove after some time
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 60...300)) {
            self.activeArguments.removeAll { $0.id == argument.id }
        }
    }
}

struct SimpleArgument: Identifiable {
    let id = UUID()
    let channelId: UUID
    let participants: [String]
    let topic: String
    let intensityLevel: String
    let argumentType: SimpleArgumentType
}

enum SimpleArgumentType {
    case technical
    case fundamental
    case strategy
    case risk
    case general
}

// MARK: - Extensions

extension BotPersona.PersonalityType: CaseIterable {
    static var allCases: [BotPersona.PersonalityType] {
        return [.aggressive, .analytical, .cautious, .contrarian, .scalper]
    }
}

extension BotPersona.BotMood: CaseIterable {
    static var allCases: [BotPersona.BotMood] {
        return [.bullish, .bearish, .neutral, .excited, .angry]
    }
}

#Preview {
    DiscordSimulationView()
}
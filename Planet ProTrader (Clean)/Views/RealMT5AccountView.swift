//
//  RealMT5AccountView.swift
//  Planet ProTrader - Real MT5 Integration
//
//  Professional MT5 Account Connection and Bot Assignment Interface
//  Connect Coinexx account and assign top bots instantly
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

struct RealMT5AccountView: View {
    @StateObject private var mt5Manager = RealMT5TradingManager.shared
    @StateObject private var armyManager = ProTraderArmyManager()
    
    @State private var showingConnectionSheet = false
    @State private var showingBotAssignment = false
    @State private var selectedBot: ProTraderBot?
    @State private var animateCards = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.AnimatedStarField()
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 20) {
                        connectionStatusSection
                        
                        if mt5Manager.isConnectedToMT5 {
                            accountInfoSection
                            
                            // ADD: Real-time Top Bots section
                            topBotsLiveSection
                            
                            assignedBotsSection
                            liveTradesSection
                            availableBotsSection
                        } else {
                            // Show Top Bots even if disconnected for discovery
                            topBotsLiveSection
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Real MT5 Trading")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                setupView()
            }
            .sheet(isPresented: $showingConnectionSheet) {
                MT5ConnectionSheet(mt5Manager: mt5Manager)
            }
            .sheet(isPresented: $showingBotAssignment) {
                if let bot = selectedBot {
                    BotAssignmentSheet(
                        bot: bot,
                        mt5Manager: mt5Manager,
                        onAssign: { positionSize, maxRisk in
                            Task {
                                await mt5Manager.assignBotToRealTrading(
                                    bot: bot,
                                    positionSize: positionSize,
                                    maxRisk: maxRisk
                                )
                            }
                            showingBotAssignment = false
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - Connection Status Section
    private var connectionStatusSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("🔗 MT5 CONNECTION STATUS")
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .tracking(1.2)
                
                Spacer()
                
                Text(mt5Manager.connectionStatus)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(mt5Manager.isConnectedToMT5 ? .green : .red)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background((mt5Manager.isConnectedToMT5 ? Color.green : Color.red).opacity(0.2), in: Capsule())
            }
            
            if !mt5Manager.isConnectedToMT5 {
                VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        Image(systemName: "server.rack")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        
                        Text("Connect Your Coinexx MT5 Account")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Connect your real Coinexx trading account to assign your best bots for live trading")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button(action: {
                        showingConnectionSheet = true
                    }) {
                        HStack {
                            Image(systemName: "link")
                            Text("CONNECT COINEXX ACCOUNT")
                                .fontWeight(.bold)
                                .tracking(1)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.orange)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.vertical, 20)
            } else {
                HStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Connected to Coinexx")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        if let account = mt5Manager.accountInfo {
                            Text("Account: \(account.login) • \(account.server)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    Button("Disconnect") {
                        mt5Manager.disconnectFromMT5()
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.red.opacity(0.2), in: Capsule())
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.orange.opacity(0.3), lineWidth: 2)
                )
        )
    }
    
    // MARK: - Account Info Section
    private var accountInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("💰 ACCOUNT INFORMATION")
                .font(.headline)
                .fontWeight(.black)
                .foregroundColor(.white)
                .tracking(1.2)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                AccountInfoCard(
                    title: "Balance",
                    value: "$\(String(format: "%.2f", mt5Manager.accountBalance))",
                    color: .blue,
                    icon: "banknote.fill"
                )
                
                AccountInfoCard(
                    title: "Equity",
                    value: "$\(String(format: "%.2f", mt5Manager.equity))",
                    color: .green,
                    icon: "chart.line.uptrend.xyaxis"
                )
                
                AccountInfoCard(
                    title: "Free Margin",
                    value: "$\(String(format: "%.2f", mt5Manager.freeMargin))",
                    color: .orange,
                    icon: "dollarsign.circle"
                )
                
                AccountInfoCard(
                    title: "Daily P&L",
                    value: "\(mt5Manager.dailyPnL >= 0 ? "+" : "")$\(String(format: "%.2f", mt5Manager.dailyPnL))",
                    color: mt5Manager.dailyPnL >= 0 ? .green : .red,
                    icon: "arrow.up.arrow.down"
                )
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Risk Utilization")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(String(format: "%.1f", mt5Manager.getRiskUtilization()))%")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
                
                ProgressView(value: mt5Manager.getRiskUtilization(), total: 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                    .scaleEffect(y: 2)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.blue.opacity(0.3), lineWidth: 2)
                )
        )
    }
    
    // MARK: - Real-time Top Bots Section (NEW)
    private var topBotsLiveSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 10) {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(.yellow)
                    Text("🏆 TOP BOTS — LIVE")
                        .font(.headline)
                        .fontWeight(.black)
                        .foregroundColor(.white)
                        .tracking(1.2)
                }
                
                Spacer()
                
                Text("REAL-TIME")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.yellow.opacity(0.2), in: Capsule())
            }
            
            if armyManager.bots.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 36))
                            .foregroundColor(.gray)
                        Text("Deploy or connect to load top bots")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(.vertical, 20)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(getTopBotsLive().enumerated()), id: \.element.id) { index, bot in
                            TopBotLiveCard(rank: index + 1, bot: bot) {
                                selectedBot = bot
                                showingBotAssignment = true
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.yellow.opacity(0.3), lineWidth: 1.5)
                )
        )
    }
    
    // MARK: - Assigned Bots Section
    private var assignedBotsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("🤖 ASSIGNED BOTS (\(mt5Manager.assignedBots.count))")
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .tracking(1.2)
                
                Spacer()
                
                Text("REAL MONEY")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.green.opacity(0.2), in: Capsule())
            }
            
            if mt5Manager.assignedBots.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "robot")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    
                    Text("No bots assigned to real trading")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("Assign your top-performing bots below")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(mt5Manager.assignedBots) { assignedBot in
                        AssignedBotCard(
                            assignedBot: assignedBot,
                            onRemove: {
                                mt5Manager.removeBotFromRealTrading(botId: assignedBot.bot.id)
                            },
                            onUpdateRisk: { positionSize, maxRisk in
                                mt5Manager.updateBotRiskSettings(
                                    botId: assignedBot.bot.id,
                                    positionSize: positionSize,
                                    maxRisk: maxRisk
                                )
                            }
                        )
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.green.opacity(0.3), lineWidth: 2)
                )
        )
    }
    
    // MARK: - Live Trades Section
    private var liveTradesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("📊 LIVE TRADES (\(mt5Manager.liveTrades.count))")
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .tracking(1.2)
                
                Spacer()
                
                Text("ACTIVE")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.cyan)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.cyan.opacity(0.2), in: Capsule())
            }
            
            if mt5Manager.liveTrades.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.flattrend.xyaxis")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    
                    Text("No active trades")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("Assigned bots will execute trades automatically")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(mt5Manager.liveTrades) { trade in
                        LiveTradeCard(
                            trade: trade,
                            onClose: {
                                Task {
                                    await mt5Manager.closeTrade(tradeId: trade.id)
                                }
                            }
                        )
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.cyan.opacity(0.3), lineWidth: 2)
                )
        )
    }
    
    // MARK: - Available Bots Section
    private var availableBotsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("⭐ TOP PERFORMING BOTS")
                .font(.headline)
                .fontWeight(.black)
                .foregroundColor(.white)
                .tracking(1.2)
            
            Text("Assign your best bots to trade with real money")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            LazyVStack(spacing: 12) {
                ForEach(getAvailableTopBots()) { bot in
                    AvailableBotCard(
                        bot: bot,
                        onAssign: {
                            selectedBot = bot
                            showingBotAssignment = true
                        }
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.purple.opacity(0.3), lineWidth: 2)
                )
        )
    }
    
    // MARK: - Helper Methods
    
    private func setupView() {
        withAnimation(.easeInOut(duration: 0.8)) {
            animateCards = true
        }
        
        Task {
            await armyManager.quickSetup()
        }
    }
    
    private func getAvailableTopBots() -> [ProTraderBot] {
        let assignedBotIds = Set(mt5Manager.assignedBots.map { $0.bot.id })
        
        return armyManager.bots
            .filter { !assignedBotIds.contains($0.id) }
            .filter { $0.confidence >= 0.8 }
            .sorted { $0.confidence > $1.confidence }
            .prefix(10)
            .map { $0 }
    }
    
    private func getTopBotsLive() -> [ProTraderBot] {
        return armyManager.bots
            .sorted {
                if $0.profitLoss == $1.profitLoss {
                    return $0.confidence > $1.confidence
                }
                return $0.profitLoss > $1.profitLoss
            }
            .prefix(10)
            .map { $0 }
    }
}

// MARK: - Supporting Views

struct AccountInfoCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.5), lineWidth: 1)
                )
        )
    }
}

struct AssignedBotCard: View {
    let assignedBot: AssignedBot
    let onRemove: () -> Void
    let onUpdateRisk: (Double, Double) -> Void
    
    @State private var showingRiskEditor = false
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(.green.opacity(0.3))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(assignedBot.bot.name.prefix(2))
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(assignedBot.bot.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                HStack {
                    Text("\(assignedBot.positionSize, specifier: "%.2f") lots")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("•")
                        .foregroundColor(.gray)
                    
                    Text("\(assignedBot.maxRiskPercent, specifier: "%.1f")% risk")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(assignedBot.realPnL >= 0 ? "+" : "")$\(String(format: "%.2f", assignedBot.realPnL))")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(assignedBot.realPnL >= 0 ? .green : .red)
                
                Text("\(assignedBot.totalRealTrades) trades")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Menu {
                Button("Edit Risk Settings") {
                    showingRiskEditor = true
                }
                
                Button("Remove from Real Trading", role: .destructive) {
                    onRemove()
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.green.opacity(0.3), lineWidth: 1)
                )
        )
        .sheet(isPresented: $showingRiskEditor) {
            RiskSettingsSheet(
                currentPositionSize: assignedBot.positionSize,
                currentMaxRisk: assignedBot.maxRiskPercent,
                onUpdate: onUpdateRisk
            )
        }
    }
}

struct LiveTradeCard: View {
    let trade: LiveMT5Trade
    let onClose: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(trade.symbol)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(trade.direction.rawValue.uppercased())
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(trade.direction == .buy ? .green : .red)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background((trade.direction == .buy ? Color.green : Color.red).opacity(0.2), in: Capsule())
                }
                
                Text("Bot: \(trade.botName)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                let sign = trade.currentPnL >= 0 ? "+" : ""
                Text("\(sign)$\(String(format: "%.2f", trade.currentPnL))")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(trade.currentPnL >= 0 ? .green : .red)
                
                Text("\(String(format: "%.2f", trade.volume)) lots")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Button("Close") {
                onClose()
            }
            .font(.caption)
            .foregroundColor(.red)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.red.opacity(0.2), in: Capsule())
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.cyan.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct AvailableBotCard: View {
    let bot: ProTraderBot
    let onAssign: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(.purple.opacity(0.3))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(bot.name.prefix(2))
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(bot.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                HStack {
                    Text("Confidence: \(Int(bot.confidence * 100))%")
                        .font(.caption)
                        .foregroundColor(.cyan)
                    
                    Text("•")
                        .foregroundColor(.gray)
                    
                    Text("W/L: \(bot.wins)/\(bot.losses)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("+$\(String(format: "%.0f", bot.profitLoss))")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Button("ASSIGN") {
                    onAssign()
                }
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.orange)
                .clipShape(Capsule())
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.purple.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Top Bot Live Card
struct TopBotLiveCard: View {
    let rank: Int
    let bot: ProTraderBot
    let onAssign: () -> Void
    
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .blue
        }
    }
    
    private var winRate: Double {
        let total = max(1, bot.wins + bot.losses)
        return (Double(bot.wins) / Double(total)) * 100.0
    }
    
    private var reason: String {
        if winRate >= 60 && bot.confidence >= 0.85 {
            return "High confidence + consistent win rate"
        } else if bot.confidence >= 0.9 {
            return "Very high confidence from learning"
        } else if winRate >= 55 {
            return "Solid win rate performance"
        } else {
            return "Good momentum and stability"
        }
    }
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(rankColor)
                        .frame(width: 26, height: 26)
                    Text("#\(rank)")
                        .font(.caption)
                        .fontWeight(.black)
                        .foregroundColor(.black)
                }
                Text(bot.name)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(1)
                Spacer()
            }
            
            HStack(spacing: 16) {
                VStack(spacing: 2) {
                    Text("+$\(String(format: "%.0f", bot.profitLoss))")
                        .font(.headline)
                        .fontWeight(.black)
                        .foregroundColor(.green)
                    Text("PnL")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                VStack(spacing: 2) {
                    Text("\(Int(winRate))%")
                        .font(.headline)
                        .fontWeight(.black)
                        .foregroundColor(.cyan)
                    Text("Win")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                VStack(spacing: 2) {
                    Text("\(Int(bot.confidence * 100))%")
                        .font(.headline)
                        .fontWeight(.black)
                        .foregroundColor(.mint)
                    Text("Conf")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            
            HStack(spacing: 6) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
                Text(reason)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                Spacer()
            }
            
            Button {
                onAssign()
            } label: {
                Text("ASSIGN TO REAL")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.orange, in: Capsule())
            }
        }
        .padding(12)
        .frame(width: 200)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(rankColor.opacity(0.4), lineWidth: 1)
                )
        )
    }
}

#Preview {
    RealMT5AccountView()
        .preferredColorScheme(.dark)
}
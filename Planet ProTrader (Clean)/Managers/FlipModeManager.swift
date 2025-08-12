import Foundation
import SwiftUI

struct FlipAccountCredentials: Codable, Equatable {
    var broker: String
    var server: String
    var login: String
    var password: String
}

struct FlipBotEntry: Codable, Identifiable, Equatable {
    let id: UUID
    let botId: UUID
    let name: String
    var startingBalance: Double
    var equity: Double
    var realizedPnL: Double
    var winRate: Double
    var tradesCount: Int
    
    init(botId: UUID, name: String, startingBalance: Double) {
        self.id = UUID()
        self.botId = botId
        self.name = name
        self.startingBalance = startingBalance
        self.equity = startingBalance
        self.realizedPnL = 0
        self.winRate = 0
        self.tradesCount = 0
    }
}

struct FlipTrade: Codable, Identifiable {
    let id: UUID
    let sessionId: UUID
    let botId: UUID
    let symbol: String
    let action: String
    let volume: Double
    let price: Double
    let profit: Double
    let timestamp: Date
}

struct FlipSession: Codable, Identifiable {
    let id: UUID
    var title: String
    var createdAt: Date
    var targetEquity: Double
    var startingBalance: Double
    var isLiveRoutingEnabled: Bool
    var coinexxCredentials: FlipAccountCredentials?
    var bots: [FlipBotEntry]
    var isCompleted: Bool
    var winnerBotId: UUID?
    
    init(
        title: String,
        startingBalance: Double,
        targetEquity: Double = 5_000,
        coinexxCredentials: FlipAccountCredentials? = nil,
        isLiveRoutingEnabled: Bool = false,
        bots: [FlipBotEntry]
    ) {
        self.id = UUID()
        self.title = title
        self.createdAt = Date()
        self.targetEquity = targetEquity
        self.startingBalance = startingBalance
        self.isLiveRoutingEnabled = isLiveRoutingEnabled
        self.coinexxCredentials = coinexxCredentials
        self.bots = bots
        self.isCompleted = false
        self.winnerBotId = nil
    }
}

@MainActor
final class FlipModeManager: ObservableObject {
    static let shared = FlipModeManager()
    
    @Published var sessions: [FlipSession] = []
    @Published var currentSession: FlipSession?
    @Published var recentTrades: [FlipTrade] = []
    @Published var isRunning = false
    
    private var timer: Timer?
    private init() {}
    
    func startNewSession(
        title: String = "Coinexx Flip Challenge",
        startingBalance: Double = 1_000,
        targetEquity: Double = 5_000,
        selectedBots: [ProTraderBot],
        coinexx: FlipAccountCredentials? = nil,
        liveRouting: Bool = false
    ) async {
        let entries = selectedBots.map { FlipBotEntry(botId: $0.id, name: $0.name, startingBalance: startingBalance) }
        var session = FlipSession(
            title: title,
            startingBalance: startingBalance,
            targetEquity: targetEquity,
            coinexxCredentials: coinexx,
            isLiveRoutingEnabled: liveRouting,
            bots: entries
        )
        currentSession = session
        sessions.insert(session, at: 0)
        
        try? await SupabaseManager.shared.saveFlipSession(session)
        startTicking()
    }
    
    func stopSession() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    private func startTicking() {
        isRunning = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.tickOnce()
            }
        }
    }
    
    private func randomGoldPrice() -> Double {
        Double.random(in: 2300.0...2450.0)
    }
    
    private func randomVolume() -> Double {
        Double([0.05, 0.1, 0.2, 0.3].randomElement()!)
    }
    
    private func randomAction() -> String {
        Bool.random() ? "BUY" : "SELL"
    }
    
    private func flipPnL(multiplier: Double) -> Double {
        Double.random(in: -15...60) * multiplier
    }
    
    private func leverage(for equity: Double, baseline: Double) -> Double {
        let progress = max(0, min(1, (equity - baseline) / (5_000 - baseline)))
        return 1.0 + (progress * 1.5)
    }
    
    private func winnerIfAny(_ session: FlipSession) -> UUID? {
        session.bots.first(where: { $0.equity >= session.targetEquity })?.botId
    }
    
    private func routeLiveIfEnabled(
        session: FlipSession,
        bot: FlipBotEntry,
        symbol: String,
        action: String,
        volume: Double
    ) async {
        guard session.isLiveRoutingEnabled else { return }
        let type: MT5OrderType = action == "BUY" ? .buy : .sell
        try? await MT5BridgeService.shared.placeOrder(
            accountLogin: session.coinexxCredentials?.login,
            accountServer: session.coinexxCredentials?.server,
            symbol: symbol,
            volume: volume,
            type: type,
            sl: nil,
            tp: nil,
            botId: bot.botId.uuidString,
            botName: bot.name,
            mode: "flip"
        )
    }
    
    private func recordTrade(_ trade: FlipTrade) {
        recentTrades.insert(trade, at: 0)
        if recentTrades.count > 60 {
            recentTrades.removeLast()
        }
        Task {
            try? await SupabaseManager.shared.saveFlipTrade(trade)
        }
    }
    
    private func updateSession(_ session: FlipSession) {
        if let idx = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[idx] = session
        }
        currentSession = session
        Task {
            try? await SupabaseManager.shared.updateFlipSession(session)
        }
    }
    
    private func tickOnce() async {
        guard var session = currentSession, !session.isCompleted else { return }
        
        // Simulate one trade per bot per tick (with progressive leverage)
        for i in 0..<session.bots.count {
            var b = session.bots[i]
            let symbol = "XAUUSD"
            let action = randomAction()
            let price = randomGoldPrice()
            let volume = randomVolume()
            let lev = leverage(for: b.equity, baseline: session.startingBalance)
            let pnl = flipPnL(multiplier: lev)
            
            b.tradesCount += 1
            if pnl > 0 {
                let wins = Int(round((b.winRate / 100.0) * Double(b.tradesCount - 1))) + 1
                b.winRate = (Double(wins) / Double(b.tradesCount)) * 100.0
            } else {
                let wins = max(0, Int(round((b.winRate / 100.0) * Double(b.tradesCount - 1))))
                b.winRate = (Double(wins) / Double(b.tradesCount)) * 100.0
            }
            
            b.realizedPnL += pnl
            b.equity = max(0, b.startingBalance + b.realizedPnL)
            
            session.bots[i] = b
            
            let trade = FlipTrade(
                id: UUID(),
                sessionId: session.id,
                botId: b.botId,
                symbol: symbol,
                action: action,
                volume: volume,
                price: price,
                profit: pnl,
                timestamp: Date()
            )
            recordTrade(trade)
            
            await routeLiveIfEnabled(session: session, bot: b, symbol: symbol, action: action, volume: volume)
        }
        
        if let winner = winnerIfAny(session) {
            session.isCompleted = true
            session.winnerBotId = winner
            stopSession()
        }
        
        updateSession(session)
    }
}
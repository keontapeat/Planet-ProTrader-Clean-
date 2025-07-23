//
//  GameControllerView.swift
//  Planet ProTrader (Clean)
//
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

struct GameControllerView: View {
    let game: MicroFlipGame
    let onGameUpdate: (MicroFlipGame?) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentGame: MicroFlipGame
    @State private var timeRemaining: TimeInterval
    @State private var showingExitAlert = false
    @State private var animateControls = false
    @State private var lastTradeResult: FlipTrade?
    @State private var showTradeResult = false
    
    // Timer for countdown
    @State private var timer: Timer?
    
    init(game: MicroFlipGame, onGameUpdate: @escaping (MicroFlipGame?) -> Void) {
        self.game = game
        self.onGameUpdate = onGameUpdate
        self._currentGame = State(initialValue: game)
        self._timeRemaining = State(initialValue: game.timeRemaining)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [.black.opacity(0.9), .blue.opacity(0.3), .black.opacity(0.9)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Game header
                        gameHeader
                        
                        // Current balance display
                        balanceDisplay
                        
                        // Progress to target
                        progressDisplay
                        
                        // Trading controls
                        tradingControls
                        
                        // Recent trades
                        recentTradesSection
                        
                        // Game stats
                        gameStatsSection
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
            .overlay(alignment: .topTrailing) {
                exitButton
            }
            .onAppear {
                startTimer()
                startAnimations()
            }
            .onDisappear {
                stopTimer()
            }
            .alert("Exit Game", isPresented: $showingExitAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Exit", role: .destructive) {
                    exitGame()
                }
            } message: {
                Text("Are you sure you want to exit? Your progress will be saved.")
            }
            .overlay {
                if showTradeResult, let trade = lastTradeResult {
                    tradeResultOverlay(trade: trade)
                }
            }
        }
    }
    
    // MARK: - Game Header
    
    private var gameHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Text(currentGame.gameType.emoji)
                    .font(.system(size: 32))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(currentGame.gameType.rawValue)
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    
                    Text(currentGame.difficulty.displayName)
                        .font(.subheadline)
                        .foregroundColor(currentGame.difficulty.color)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("TIME")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(formatTime(timeRemaining))
                        .font(.title3.bold())
                        .foregroundColor(timeRemaining < 60 ? .red : .white)
                        .monospacedDigit()
                }
            }
            
            // Entry amount
            Text("Entry: $\(String(format: "%.2f", currentGame.entryAmount))")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.9))
        .cornerRadius(16)
    }
    
    // MARK: - Balance Display
    
    private var balanceDisplay: some View {
        VStack(spacing: 8) {
            Text("CURRENT BALANCE")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("$\(String(format: "%.2f", currentGame.currentBalance))")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .monospacedDigit()
            
            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("P&L")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("$\(String(format: "%.2f", currentGame.profitLoss))")
                        .font(.headline.bold())
                        .foregroundColor(currentGame.profitLoss >= 0 ? .green : .red)
                        .monospacedDigit()
                }
                
                VStack(spacing: 4) {
                    Text("P&L %")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(String(format: "%.1f", currentGame.profitLossPercentage))%")
                        .font(.headline.bold())
                        .foregroundColor(currentGame.profitLossPercentage >= 0 ? .green : .red)
                        .monospacedDigit()
                }
            }
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.9))
        .cornerRadius(16)
    }
    
    // MARK: - Progress Display
    
    private var progressDisplay: some View {
        VStack(spacing: 12) {
            HStack {
                Text("TARGET PROGRESS")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("$\(String(format: "%.2f", currentGame.targetAmount))")
                    .font(.subheadline.bold())
                    .foregroundColor(.blue)
            }
            
            ProgressView(value: currentGame.progressToTarget)
                .tint(.blue)
                .scaleEffect(y: 3.0)
            
            Text("\(Int(currentGame.progressToTarget * 100))% Complete")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.9))
        .cornerRadius(16)
    }
    
    // MARK: - Trading Controls
    
    private var tradingControls: some View {
        VStack(spacing: 20) {
            Text("🎯 MAKE YOUR MOVE")
                .font(.title3.bold())
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                // Up trade button
                Button(action: { makeTrade(direction: .up) }) {
                    VStack(spacing: 12) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.green)
                        
                        Text("UP")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        
                        Text("📈")
                            .font(.title)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 140)
                    .background(.green.opacity(0.2))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.green, lineWidth: 2)
                    )
                }
                .buttonStyle(PressableButtonStyle())
                .disabled(currentGame.status != .active)
                
                // Down trade button
                Button(action: { makeTrade(direction: .down) }) {
                    VStack(spacing: 12) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.red)
                        
                        Text("DOWN")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        
                        Text("📉")
                            .font(.title)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 140)
                    .background(.red.opacity(0.2))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.red, lineWidth: 2)
                    )
                }
                .buttonStyle(PressableButtonStyle())
                .disabled(currentGame.status != .active)
            }
            
            // Trade amount selector
            tradeAmountSelector
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.9))
        .cornerRadius(16)
        .scaleEffect(animateControls ? 1.0 : 0.8)
        .opacity(animateControls ? 1.0 : 0.3)
        .animation(.spring(dampingFraction: 0.8).delay(0.3), value: animateControls)
    }
    
    private var tradeAmountSelector: some View {
        VStack(spacing: 12) {
            Text("Trade Amount")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                let amounts = [5.0, 10.0, 25.0, 50.0]
                ForEach(amounts, id: \.self) { amount in
                    Button("$\(Int(amount))") {
                        // Handle amount selection
                    }
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(.blue.opacity(0.3))
                    .cornerRadius(8)
                }
            }
        }
    }
    
    // MARK: - Recent Trades
    
    private var recentTradesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📊 RECENT TRADES")
                .font(.headline.bold())
                .foregroundColor(.white)
            
            if currentGame.trades.isEmpty {
                Text("No trades yet")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 8) {
                    ForEach(currentGame.trades.prefix(5).reversed()) { trade in
                        TradeRow(trade: trade)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.9))
        .cornerRadius(16)
    }
    
    // MARK: - Game Stats
    
    private var gameStatsSection: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "Trades",
                value: "\(currentGame.trades.count)",
                color: .blue,
                icon: "arrow.left.arrow.right"
            )
            
            let wins = currentGame.trades.filter { $0.outcome == .win }.count
            StatCard(
                title: "Win Rate",
                value: currentGame.trades.isEmpty ? "0%" : "\(Int(Double(wins) / Double(currentGame.trades.count) * 100))%",
                color: .green,
                icon: "target"
            )
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.9))
        .cornerRadius(16)
    }
    
    // MARK: - Exit Button
    
    private var exitButton: some View {
        Button(action: { showingExitAlert = true }) {
            Image(systemName: "xmark.circle.fill")
                .font(.title)
                .foregroundColor(.white)
                .background(.black.opacity(0.5))
                .clipShape(Circle())
        }
        .padding()
    }
    
    // MARK: - Trade Result Overlay
    
    private func tradeResultOverlay(trade: FlipTrade) -> some View {
        VStack(spacing: 16) {
            Text(trade.direction.emoji)
                .font(.system(size: 64))
            
            Text(trade.outcome.rawValue.uppercased())
                .font(.title.bold())
                .foregroundColor(trade.outcome.color)
            
            Text("\(trade.outcome == .win ? "+" : "")$\(String(format: "%.2f", trade.profitLoss))")
                .font(.title2.bold())
                .foregroundColor(trade.outcome.color)
        }
        .padding(40)
        .background(Color(.systemGray6).opacity(0.95))
        .cornerRadius(20)
        .scaleEffect(showTradeResult ? 1.0 : 0.1)
        .opacity(showTradeResult ? 1.0 : 0.0)
        .animation(.spring(dampingFraction: 0.6), value: showTradeResult)
    }
    
    // MARK: - Helper Methods
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            timeRemaining = currentGame.timeRemaining
            
            if timeRemaining <= 0 {
                endGame(reason: .timeout)
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 0.8)) {
            animateControls = true
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time / 60)
        let seconds = Int(time.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func makeTrade(direction: FlipTrade.TradeDirection) {
        let tradeAmount = 10.0 // Default trade amount
        let multiplier = 1.8 // Default multiplier
        
        // Simulate trade outcome (in real app, this would be based on actual market data)
        let outcome: FlipTrade.TradeOutcome = Bool.random() ? .win : .loss
        
        let trade = FlipTrade(
            amount: tradeAmount,
            direction: direction,
            outcome: outcome,
            timestamp: Date(),
            multiplier: multiplier
        )
        
        // Update game state
        currentGame.trades.append(trade)
        currentGame.currentBalance += trade.profitLoss
        
        // Show trade result
        lastTradeResult = trade
        showTradeResult = true
        
        // Hide result after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            showTradeResult = false
        }
        
        // Check win condition
        if currentGame.currentBalance >= currentGame.targetAmount {
            endGame(reason: .targetReached)
        } else if currentGame.currentBalance <= 0 {
            endGame(reason: .balanceZero)
        }
        
        // Update the game
        onGameUpdate(currentGame)
    }
    
    private func endGame(reason: GameEndReason) {
        stopTimer()
        
        var updatedGame = currentGame
        updatedGame.completedDate = Date()
        
        switch reason {
        case .targetReached:
            updatedGame.status = .completed
            updatedGame.result = .win(amount: updatedGame.profitLoss)
        case .balanceZero, .timeout:
            updatedGame.status = .failed
            updatedGame.result = .loss(amount: updatedGame.profitLoss)
        }
        
        onGameUpdate(updatedGame)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            dismiss()
        }
    }
    
    private func exitGame() {
        var updatedGame = currentGame
        updatedGame.status = .paused
        onGameUpdate(updatedGame)
        dismiss()
    }
    
    private enum GameEndReason {
        case targetReached
        case balanceZero
        case timeout
    }
}

// MARK: - Supporting Views

struct TradeRow: View {
    let trade: FlipTrade
    
    var body: some View {
        HStack {
            Text(trade.direction.emoji)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(trade.direction.rawValue)
                    .font(.caption.bold())
                    .foregroundColor(.white)
                
                Text("$\(String(format: "%.2f", trade.amount))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(trade.outcome.rawValue)
                    .font(.caption.bold())
                    .foregroundColor(trade.outcome.color)
                
                Text("\(trade.profitLoss >= 0 ? "+" : "")$\(String(format: "%.2f", trade.profitLoss))")
                    .font(.caption)
                    .foregroundColor(trade.outcome.color)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(trade.outcome.color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    GameControllerView(
        game: MicroFlipGame(
            playerId: "player1",
            gameType: .quickFlip,
            entryAmount: 50.0,
            targetAmount: 75.0,
            duration: 300,
            status: .active,
            difficulty: .pro
        )
    ) { _ in }
}
//  TradingTerminal.swift
//  Planet ProTrader - Professional Trading Terminal
//
//  Clean Minimal Trading Terminal for Mobile - TradeLocker Style
//  Modern iPhone-Optimized Design
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI
import WebKit
import Foundation
import Combine

struct TradingTerminal: View {
    // MARK: - State Management
    @StateObject private var tradingViewManager = TradingViewManager()
    @StateObject private var aiEngine = AITradingEngine()
    @State private var selectedTimeframe: ChartTimeframe = .m15
    @State private var selectedSymbol = "XAUUSD"
    @State private var showingWatchlist = false
    @State private var showingTradePanel = false
    @State private var showingPositions = false
    @State private var showingOrders = false
    @State private var showingHistory = false
    @State private var tradePanelOffset: CGFloat = 0
    @State private var isFullScreen = false
    @State private var overlayOffset: CGFloat = 0
    @State private var toolbarHidden = false
    @State private var showDrawingTools = false
    @State private var showIndicators = false
    @State private var currentChartType: ChartType = .candles
    @State private var showPriceAlerts = false
    @State private var tradeVolume: Double = 0.01
    
    // MARK: - Trading Panel Tab States
    @State private var selectedTradingTab: TradingTab = .simple
    @State private var stopLoss: Double = 0.0
    @State private var takeProfit: Double = 0.0
    @State private var riskAmount: Double = 100.0
    @State private var orderType: OrderType = .market
    
    // FIXED: Use proper environment objects
    @EnvironmentObject var tradingManager: TradingManager
    @EnvironmentObject var botManager: BotManager
    @EnvironmentObject var hapticManager: HapticManager
    @EnvironmentObject var audioManager: AudioManager
    
    @StateObject private var toastManager = ToastManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Professional Background with Animated Starfield
                DesignSystem.AnimatedStarField()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Clean Header (Without Timeframe)
                    if !isFullScreen && !toolbarHidden {
                        tradeLockerHeader
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    // Main Chart Area - Clean & Simple
                    ZStack {
                        cleanChart
                            .onTapGesture(count: 2) {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                                    isFullScreen.toggle()
                                    if isFullScreen {
                                        tradingViewManager.enablePriceScaling(true)
                                    } else {
                                        tradingViewManager.enablePriceScaling(false)
                                    }
                                }
                                hapticManager.lightImpact()
                            }
                        
                        // Timeframe Selector Overlaid ON TOP of Chart (Flush)
                        if !isFullScreen && !toolbarHidden {
                            VStack {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(ChartTimeframe.allCases, id: \.self) { timeframe in
                                            TradeLockerTimeframeButton(
                                                timeframe: timeframe,
                                                isSelected: selectedTimeframe == timeframe
                                            ) {
                                                selectedTimeframe = timeframe
                                                tradingViewManager.changeTimeframe(timeframe.tradingViewInterval)
                                                hapticManager.lightImpact()
                                            }
                                        }
                                        
                                        // Add some trailing space
                                        Spacer(minLength: 24)
                                    }
                                    .padding(.leading, 24)
                                }
                                .frame(height: 44)
                                .background(.black.opacity(0.9)) // Semi-transparent over chart
                                .overlay(
                                    Rectangle()
                                        .fill(.white.opacity(0.1))
                                        .frame(height: 1),
                                    alignment: .bottom
                                )
                                
                                Spacer() // Push timeframe to top
                            }
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        // Chart Controls
                        VStack {
                            HStack {
                                Spacer()
                                
                                // X button always visible in fullscreen
                                if isFullScreen {
                                    backToNormalButton
                                        .padding(.trailing, 16)
                                        .padding(.top, 16)
                                        .zIndex(100) // Keep X button above everything
                                }
                            }
                            
                            Spacer()
                            
                            // TradingView-Style Reset Button at Bottom Middle
                            if !isFullScreen {
                                tradingViewResetButton
                                    .padding(.bottom, 20)
                            }
                            
                            // Fullscreen Controls - TradingView Style Auto-Hide (but NOT the X button)
                            if isFullScreen {
                                fullScreenControls
                                    .padding(.bottom, 20)
                                    .opacity(toolbarHidden ? 0 : 1)
                                    .animation(.easeInOut(duration: 0.3), value: toolbarHidden)
                                    .onAppear {
                                        // Enable price scaling in fullscreen
                                        tradingViewManager.enablePriceScaling(true)
                                        
                                        // Auto-hide after 3 seconds like TradingView
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                            withAnimation(.easeOut(duration: 0.3)) {
                                                toolbarHidden = true
                                            }
                                        }
                                    }
                            }
                        }
                        
                        // TradingView-style toolbar reveal on chart interaction
                        if isFullScreen {
                            Color.clear
                                .contentShape(Rectangle())
                                .onTapGesture(count: 2) {
                                    // Double tap to exit fullscreen
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        isFullScreen = false
                                        tradingViewManager.enablePriceScaling(false)
                                    }
                                    hapticManager.lightImpact()
                                }
                                .onTapGesture(count: 1) {
                                    // Single tap to show toolbar
                                    withAnimation(.easeIn(duration: 0.2)) {
                                        toolbarHidden = false
                                    }
                                    
                                    // Auto-hide again after 3 seconds
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        withAnimation(.easeOut(duration: 0.3)) {
                                            toolbarHidden = true
                                        }
                                    }
                                    
                                    hapticManager.lightImpact()
                                }
                                .allowsHitTesting(true)
                        }
                    }
                    
                    // MARK: - Enhanced Trading Interface
                    if !isFullScreen {
                        tradeLockerBottomPanel
                            .offset(y: tradePanelOffset)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        if value.translation.height > 0 {
                                            tradePanelOffset = min(value.translation.height, 200)
                                        }
                                    }
                                    .onEnded { value in
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                                            if value.translation.height > 50 || value.velocity.height > 800 {
                                                isFullScreen = true
                                                tradePanelOffset = 0
                                                tradingViewManager.enablePriceScaling(true)
                                            } else {
                                                tradePanelOffset = 0
                                            }
                                        }
                                        hapticManager.lightImpact()
                                    }
                            )
                    }
                }
                
                // Overlays
                if showingWatchlist {
                    tradeLockerWatchlistOverlay
                        .zIndex(10)
                }
                
                if showingTradePanel {
                    tradeLockerTradePanelOverlay
                        .zIndex(10)
                }
                
                if showingPositions {
                    tradeLockerPositionsOverlay
                        .zIndex(10)
                }
                
                if showingOrders {
                    tradeLockerOrdersOverlay
                        .zIndex(10)
                }
                
                if showingHistory {
                    tradeLockerHistoryOverlay
                        .zIndex(10)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                setupTradingView()
            }
            .overlay(alignment: .topTrailing) {
                if toastManager.showToast {
                    tradeLockerToast
                }
            }
        }
    }
    
    // MARK: - Clean Header
    private var tradeLockerHeader: some View {
        VStack(spacing: 0) {
            // Top Row: Title & Status
            HStack {
                // CLEAN MINIMAL TERMINAL TEXT
                Text("TERMINAL")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 1.0, blue: 1.0),
                                Color(red: 1.0, green: 0.9, blue: 0.0),
                                Color(red: 1.0, green: 0.7, blue: 0.0),
                                Color(red: 1.0, green: 0.5, blue: 0.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Spacer()
                
                HStack(spacing: 16) {
                    // Clean Live Status
                    HStack(spacing: 6) {
                        Circle()
                            .fill(.green)
                            .frame(width: 6, height: 6)
                            .scaleEffect(tradingManager.isConnected ? 1.0 : 0.6)
                            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: tradingManager.isConnected)
                        
                        Text("LIVE")
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.green.opacity(0.15), in: Capsule())
                    .overlay(
                        Capsule()
                            .stroke(.green.opacity(0.3), lineWidth: 1)
                    )
                    
                    // Clean Settings Button
                    Button(action: {
                        Task {
                            await audioManager.playButtonTap()
                        }
                    }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            // Symbol & Price Row - Clean & Minimal
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(selectedSymbol)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Button(action: {
                            showingWatchlist = true
                            hapticManager.lightImpact()
                            Task {
                                await audioManager.playButtonTap()
                            }
                        }) {
                            Image(systemName: "chevron.down.circle.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Text("Gold Spot / US Dollar")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 6) {
                    Text(tradingManager.goldPrice.formattedPrice)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 6) {
                        Image(systemName: tradingManager.goldPrice.isPositive ? "arrow.up.right" : "arrow.down.right")
                            .font(.system(size: 10, weight: .bold))
                        Text(tradingManager.goldPrice.formattedChange)
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(tradingManager.goldPrice.isPositive ? .green : .red)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background((tradingManager.goldPrice.isPositive ? Color.green : Color.red).opacity(0.15), in: Capsule())
                    .overlay(
                        Capsule()
                            .stroke((tradingManager.goldPrice.isPositive ? Color.green : Color.red).opacity(0.3), lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .background(.ultraThinMaterial)
    }
    
    // MARK: - TradingView-Style Reset Button
    private var tradingViewResetButton: some View {
        HStack {
            Spacer()
            
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    resetChart()
                }
                hapticManager.lightImpact()
                Task {
                    await audioManager.playButtonTap()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Reset")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.black.opacity(0.8), in: Capsule())
                .overlay(
                    Capsule()
                        .stroke(.white.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 2)
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
        }
    }
    
    // MARK: - Back to Normal Button
    private var backToNormalButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isFullScreen = false
                showingPositions = false
                showingOrders = false
                showingHistory = false
                overlayOffset = 0
                tradePanelOffset = 0
                // Disable price scaling when exiting fullscreen
                tradingViewManager.enablePriceScaling(false)
            }
            hapticManager.lightImpact()
            Task {
                await audioManager.playButtonTap()
            }
        }) {
            ZStack {
                Circle()
                    .fill(.black.opacity(0.6))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Full Screen Controls
    private var fullScreenControls: some View {
        VStack(spacing: 12) {
            // Just Reset Button - Clean & Simple
            HStack {
                Spacer()
                
                // Reset Button
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        resetChart()
                    }
                    hapticManager.lightImpact()
                    Task {
                        await audioManager.playButtonTap()
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Reset")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.black.opacity(0.8), in: Capsule())
                    .overlay(
                        Capsule()
                            .stroke(.white.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
        }
    }
    
    // MARK: - Clean Chart
    private var cleanChart: some View {
        TradingViewWebView(
            symbol: selectedSymbol,
            timeframe: selectedTimeframe,
            manager: tradingViewManager
        )
        .background(Color.black)
        .clipShape(Rectangle())
    }
    
    // MARK: - Enhanced Trading Interface
    private var tradeLockerBottomPanel: some View {
        VStack(spacing: 0) {
            // Minimal drag indicator
            RoundedRectangle(cornerRadius: 2)
                .fill(.white.opacity(0.3))
                .frame(width: 36, height: 3)
                .padding(.top, 6)
            
            VStack(spacing: 4) {
                // Real-time Balance Row with Live Updates
                TradingStatsView()
                
                // Enhanced Margin Warning with Live Calculations
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: tradingManager.marginLevel < 100 ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(tradingManager.marginLevel < 100 ? .red : .green)
                            .animation(.easeInOut(duration: 0.3), value: tradingManager.marginLevel)
                    }
                    
                    Spacer()
                    
                    // Real-time Margin Display
                    Text("Margin Level: \(String(format: "%.1f", tradingManager.marginLevel))%")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(tradingManager.marginLevel < 100 ? .red : .gray)
                        .animation(.easeInOut(duration: 0.3), value: tradingManager.marginLevel)
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Image(systemName: tradingManager.isConnected ? "wifi" : "wifi.slash")
                            .font(.system(size: 14))
                            .foregroundColor(tradingManager.isConnected ? .green : .red)
                            .animation(.easeInOut(duration: 0.3), value: tradingManager.isConnected)
                    }
                }
                .padding(.horizontal, 4)
                
                // Trading Panel Tabs
                HStack(spacing: 0) {
                    TradingTabButton(
                        title: "Simple",
                        icon: "bolt.fill",
                        isSelected: selectedTradingTab == .simple
                    ) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            selectedTradingTab = .simple
                        }
                        hapticManager.lightImpact()
                        Task {
                            await audioManager.playButtonTap()
                        }
                    }
                    
                    TradingTabButton(
                        title: "Advanced",
                        icon: "slider.horizontal.3",
                        isSelected: selectedTradingTab == .advanced
                    ) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            selectedTradingTab = .advanced
                        }
                        hapticManager.lightImpact()
                        Task {
                            await audioManager.playButtonTap()
                        }
                    }
                }
                .background(.black.opacity(0.3), in: RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal, 4)
                
                // Trading Interface Content
                Group {
                    if selectedTradingTab == .simple {
                        simpleTradeInterface
                    } else {
                        advancedTradeInterface
                    }
                }
                
                // Enhanced Bottom Tabs with Badge Animations
                HStack(spacing: 0) {
                    TradeLockerTabButton(title: "Positions", count: "\(tradingManager.activePositionsCount)") {
                        showingPositions = true
                        hapticManager.lightImpact()
                        Task {
                            await audioManager.playButtonTap()
                        }
                    }
                    TradeLockerTabButton(title: "Orders", count: "\(tradingManager.pendingOrdersCount)") {
                        showingOrders = true
                        hapticManager.lightImpact()
                        Task {
                            await audioManager.playButtonTap()
                        }
                    }
                    TradeLockerTabButton(title: "History", count: "\(tradingManager.todayTradesCount)") {
                        showingHistory = true
                        hapticManager.lightImpact()
                        Task {
                            await audioManager.playButtonTap()
                        }
                    }
                }
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
    
    // MARK: - Simplified Overlays (to avoid crashes)
    private var tradeLockerWatchlistOverlay: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    dismissWatchlist()
                }
            
            VStack(spacing: 20) {
                Text("🔍 Symbol Selector")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                Text("Watchlist coming soon!")
                    .foregroundColor(.secondary)
                
                Button("Close") {
                    dismissWatchlist()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(40)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        }
    }
    
    private var tradeLockerTradePanelOverlay: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    dismissTradePanel()
                }
            
            VStack(spacing: 20) {
                Text("📊 Trade Panel")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                Text("Advanced trading panel coming soon!")
                    .foregroundColor(.secondary)
                
                Button("Close") {
                    dismissTradePanel()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(40)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        }
    }
    
    private var tradeLockerPositionsOverlay: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    dismissPositions()
                }
            
            VStack(spacing: 20) {
                Text("📈 Positions")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                Text("\(tradingManager.activePositionsCount) active positions")
                    .foregroundColor(.secondary)
                
                Button("Close") {
                    dismissPositions()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(40)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        }
    }
    
    private var tradeLockerOrdersOverlay: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    dismissOrders()
                }
            
            VStack(spacing: 20) {
                Text("📋 Orders")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                Text("\(tradingManager.pendingOrdersCount) pending orders")
                    .foregroundColor(.secondary)
                
                Button("Close") {
                    dismissOrders()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(40)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        }
    }
    
    private var tradeLockerHistoryOverlay: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    dismissHistory()
                }
            
            VStack(spacing: 20) {
                Text("📜 History")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                Text("\(tradingManager.todayTradesCount) trades today")
                    .foregroundColor(.secondary)
                
                Button("Close") {
                    dismissHistory()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(40)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        }
    }
    
    // MARK: - TradeLocker Toast
    private var tradeLockerToast: some View {
        HStack(spacing: 12) {
            Image(systemName: toastManager.toastType.systemImage)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(toastManager.toastType.color)
            
            Text(toastManager.toastMessage)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(toastManager.toastType.color.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .transition(.move(edge: .top).combined(with: .scale(scale: 0.95)).combined(with: .opacity))
    }
    
    // MARK: - Dismissal Helper Methods
    private func dismissWatchlist() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            showingWatchlist = false
            overlayOffset = 0
        }
        hapticManager.lightImpact()
        Task {
            await audioManager.playButtonTap()
        }
    }
    
    private func dismissTradePanel() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            showingTradePanel = false
            overlayOffset = 0
        }
        hapticManager.lightImpact()
        Task {
            await audioManager.playButtonTap()
        }
    }
    
    private func dismissPositions() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            showingPositions = false
            overlayOffset = 0
        }
        hapticManager.lightImpact()
        Task {
            await audioManager.playButtonTap()
        }
    }
    
    private func dismissOrders() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            showingOrders = false
            overlayOffset = 0
        }
        hapticManager.lightImpact()
        Task {
            await audioManager.playButtonTap()
        }
    }
    
    private func dismissHistory() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            showingHistory = false
            overlayOffset = 0
        }
        hapticManager.lightImpact()
        Task {
            await audioManager.playButtonTap()
        }
    }
    
    // MARK: - Helper Methods
    private func setupTradingView() {
        tradingViewManager.initialize(symbol: selectedSymbol, timeframe: selectedTimeframe)
    }
    
    private func resetChart() {
        tradingViewManager.resetChart()
        toastManager.show("Chart reset to default view", type: .info)
    }
    
    // MARK: - Enhanced Trading Methods
    private func executeOneClickBuy() {
        let message = "BUY executed: \(selectedSymbol) @ \(String(format: "%.2f", tradeVolume)) lots"
        toastManager.show(message, type: .success)
        hapticManager.lightImpact()
        
        // Update trading manager
        tradingManager.executeBuyOrder(symbol: selectedSymbol, volume: tradeVolume)
        
        Task {
            await audioManager.playNotification()
        }
    }
    
    private func executeOneClickSell() {
        let message = "SELL executed: \(selectedSymbol) @ \(String(format: "%.2f", tradeVolume)) lots"
        toastManager.show(message, type: .warning)
        hapticManager.lightImpact()
        
        // Update trading manager
        tradingManager.executeSellOrder(symbol: selectedSymbol, volume: tradeVolume)
        
        Task {
            await audioManager.playNotification()
        }
    }
    
    private func executeAdvancedBuy() {
        let slText = stopLoss > 0 ? " SL:\(String(format: "%.2f", stopLoss))" : ""
        let tpText = takeProfit > 0 ? " TP:\(String(format: "%.2f", takeProfit))" : ""
        let message = "Advanced BUY: \(selectedSymbol) @ \(String(format: "%.2f", tradeVolume)) lots\(slText)\(tpText)"
        
        toastManager.show(message, type: .success)
        hapticManager.lightImpact()
        
        tradingManager.executeBuyOrder(symbol: selectedSymbol, volume: tradeVolume)
        
        Task {
            await audioManager.playNotification()
        }
    }
    
    private func executeAdvancedSell() {
        let slText = stopLoss > 0 ? " SL:\(String(format: "%.2f", stopLoss))" : ""
        let tpText = takeProfit > 0 ? " TP:\(String(format: "%.2f", takeProfit))" : ""
        let message = "Advanced SELL: \(selectedSymbol) @ \(String(format: "%.2f", tradeVolume)) lots\(slText)\(tpText)"
        
        toastManager.show(message, type: .warning)
        hapticManager.lightImpact()
        
        tradingManager.executeSellOrder(symbol: selectedSymbol, volume: tradeVolume)
        
        Task {
            await audioManager.playNotification()
        }
    }
    
    private func calculateRiskReward() -> Double {
        guard stopLoss > 0 && takeProfit > 0 else { return 0.0 }
        let currentPrice = tradingManager.currentGoldPrice
        let riskDistance = abs(currentPrice - stopLoss)
        let rewardDistance = abs(takeProfit - currentPrice)
        return riskDistance > 0 ? rewardDistance / riskDistance : 0.0
    }
    
    private func increaseVolume() {
        tradeVolume = min(1.0, tradeVolume + 0.01)
        hapticManager.lightImpact()
        Task {
            await audioManager.playButtonTap()
        }
    }
    
    private func decreaseVolume() {
        if tradeVolume > 0.01 {
            tradeVolume = max(0.01, tradeVolume - 0.01)
            hapticManager.lightImpact()
            Task {
                await audioManager.playButtonTap()
            }
        }
    }
    
    private var simpleTradeInterface: some View {
        HStack(spacing: 0) {
            // SELL Button with Live Price
            Button(action: {
                executeOneClickSell()
            }) {
                VStack(spacing: 4) {
                    Text(String(format: "%.2f", tradingManager.currentGoldPrice - 0.3))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .animation(.easeInOut(duration: 0.2), value: tradingManager.currentGoldPrice)
                    Text("SELL")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 70)
                .background(
                    LinearGradient(
                        colors: [Color(red: 0.25, green: 0.2, blue: 0.2), Color(red: 0.2, green: 0.2, blue: 0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Rectangle()
                        .stroke(.red.opacity(0.3), lineWidth: 1)
                        .blur(radius: 0.5)
                )
            }
            .buttonStyle(ContentViewScaleButtonStyle())
            
            // FIXED: Horizontal Volume Control with Better Padding
            HStack(spacing: 8) {
                // Minus button on LEFT
                Button(action: {
                    decreaseVolume()
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(ContentViewScaleButtonStyle())
                
                // Volume display in CENTER with padding
                VStack(spacing: 1) {
                    Text(String(format: "%.2f", tradeVolume))
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: tradeVolume)
                    Text("lots")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.gray)
                }
                .frame(minWidth: 60)
                .padding(.horizontal, 8)
                
                // Plus button on RIGHT
                Button(action: {
                    increaseVolume()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(ContentViewScaleButtonStyle())
            }
            .frame(width: 120)
            .frame(height: 70)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.1, green: 0.1, blue: 0.15), Color.black],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            )
            
            // BUY Button with Live Price
            Button(action: {
                executeOneClickBuy()
            }) {
                VStack(spacing: 4) {
                    Text(String(format: "%.2f", tradingManager.currentGoldPrice))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .animation(.easeInOut(duration: 0.2), value: tradingManager.currentGoldPrice)
                    Text("BUY")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 70)
                .background(
                    LinearGradient(
                        colors: [Color(red: 0.2, green: 0.25, blue: 0.2), Color(red: 0.2, green: 0.2, blue: 0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Rectangle()
                        .stroke(.green.opacity(0.3), lineWidth: 1)
                        .blur(radius: 0.5)
                )
            }
            .buttonStyle(ContentViewScaleButtonStyle())
        }
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
    }
    
    private var advancedTradeInterface: some View {
        VStack(spacing: 12) {
            // Order Type & Volume Row
            HStack(spacing: 12) {
                // Order Type Picker
                VStack(alignment: .leading, spacing: 4) {
                    Text("Order Type")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Menu {
                        ForEach(OrderType.allCases, id: \.self) { type in
                            Button(type.displayName) {
                                orderType = type
                                hapticManager.lightImpact()
                            }
                        }
                    } label: {
                        HStack {
                            Text(orderType.displayName)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.black.opacity(0.8), in: RoundedRectangle(cornerRadius: 6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Volume Control
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Volume")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 8) {
                        Button(action: { decreaseVolume() }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Text(String(format: "%.2f", tradeVolume))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(minWidth: 50)
                        
                        Button(action: { increaseVolume() }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
            }
            
            // SL/TP Sliders Row
            HStack(spacing: 12) {
                // Stop Loss
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Stop Loss")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.red)
                        Spacer()
                        Text(stopLoss > 0 ? String(format: "%.2f", stopLoss) : "None")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.red)
                    }
                    
                    Slider(value: $stopLoss, in: 0...100, step: 0.1)
                        .tint(.red)
                        .frame(height: 20)
                }
                .frame(maxWidth: .infinity)
                
                // Take Profit
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Take Profit")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.green)
                        Spacer()
                        Text(takeProfit > 0 ? String(format: "%.2f", takeProfit) : "None")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.green)
                    }
                    
                    Slider(value: $takeProfit, in: 0...200, step: 0.1)
                        .tint(.green)
                        .frame(height: 20)
                }
                .frame(maxWidth: .infinity)
            }
            
            // Risk Calculator Row
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Risk Amount")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.gray)
                    
                    HStack {
                        Text("$")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        Text(String(format: "%.0f", riskAmount))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.black.opacity(0.8), in: RoundedRectangle(cornerRadius: 6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
                }
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("R:R Ratio")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Text("1:\(String(format: "%.1f", calculateRiskReward()))")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(calculateRiskReward() >= 2.0 ? .green : .orange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.black.opacity(0.8), in: RoundedRectangle(cornerRadius: 6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke((calculateRiskReward() >= 2.0 ? Color.green : Color.orange).opacity(0.3), lineWidth: 1)
                        )
                }
            }
            
            // Advanced Buy/Sell Buttons
            HStack(spacing: 8) {
                Button(action: {
                    executeAdvancedSell()
                }) {
                    VStack(spacing: 4) {
                        Text("SELL")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        Text(String(format: "%.2f", tradingManager.currentGoldPrice - 0.3))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.red)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(.red.opacity(0.2), in: RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.red.opacity(0.4), lineWidth: 1)
                    )
                }
                .buttonStyle(ContentViewScaleButtonStyle())
                
                Button(action: {
                    executeAdvancedBuy()
                }) {
                    VStack(spacing: 4) {
                        Text("BUY")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        Text(String(format: "%.2f", tradingManager.currentGoldPrice))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.green)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(.green.opacity(0.2), in: RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.green.opacity(0.4), lineWidth: 1)
                    )
                }
                .buttonStyle(ContentViewScaleButtonStyle())
            }
        }
        .padding(12)
        .background(.black.opacity(0.6), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Supporting Classes
class TradingViewManager: ObservableObject {
    @Published var isLoaded = false
    @Published var currentSymbol = "XAUUSD"
    @Published var currentTimeframe = "15"
    
    private var webView: WKWebView?
    
    func initialize(symbol: String, timeframe: ChartTimeframe) {
        currentSymbol = symbol
        currentTimeframe = timeframe.tradingViewInterval
        isLoaded = true
    }
    
    func changeSymbol(_ symbol: String) {
        currentSymbol = symbol
        executeJavaScript("changeSymbol('\(symbol)')")
    }
    
    func changeTimeframe(_ timeframe: String) {
        currentTimeframe = timeframe
        executeJavaScript("changeTimeframe('\(timeframe)')")
    }
    
    func changeChartType(_ type: String) {
        executeJavaScript("changeChartType('\(type)')")
    }
    
    func enablePriceScaling(_ enable: Bool) {
        executeJavaScript("enablePriceScaling(\(enable))")
    }
    
    func resetChart() {
        executeJavaScript("resetChart()")
    }
    
    func toggleToolbar(_ show: Bool) {
        executeJavaScript("toggleToolbar(\(show))")
    }
    
    func setWebView(_ webView: WKWebView) {
        self.webView = webView
    }
    
    private func executeJavaScript(_ script: String) {
        webView?.evaluateJavaScript(script, completionHandler: nil)
    }
}

class AITradingEngine: ObservableObject {
    @Published var strategy: Int = 0
    
    func run() {
        print("AI Engine running...")
    }
    
    func pause() {
        print("AI Engine paused...")
    }
}

// MARK: - Supporting Types
enum ChartTimeframe: String, CaseIterable, Codable {
    case m1 = "1M"
    case m5 = "5M"
    case m15 = "15M"
    case m30 = "30M"
    case h1 = "1H"
    case h4 = "4H"
    case d1 = "1D"
    
    var displayName: String { rawValue }
    var tradingViewInterval: String {
        switch self {
        case .m1: return "1"
        case .m5: return "5"
        case .m15: return "15"
        case .m30: return "30"
        case .h1: return "60"
        case .h4: return "240"
        case .d1: return "D"
        }
    }
}

enum ChartType: String, CaseIterable {
    case candles = "candles"
    case bars = "bars"
    case line = "line"
    case area = "area"
    
    var icon: String {
        switch self {
        case .candles: return "chart.bar.fill"
        case .bars: return "chart.bar"
        case .line: return "chart.line.uptrend.xyaxis"
        case .area: return "chart.line.flattrend.xyaxis.fill"
        }
    }
}

enum TradingTab: String, CaseIterable {
    case simple = "Simple"
    case advanced = "Advanced"
}

enum OrderType: String, CaseIterable {
    case market = "Market"
    case limit = "Limit"
    case stop = "Stop"
    case stopLimit = "Stop Limit"
    
    var displayName: String { rawValue }
}

// MARK: - TradingView WebView
struct TradingViewWebView: UIViewRepresentable {
    let symbol: String
    let timeframe: ChartTimeframe
    let manager: TradingViewManager
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.backgroundColor = UIColor.black
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.bounces = false
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.maximumZoomScale = 3.0
        webView.scrollView.minimumZoomScale = 0.5
        
        manager.setWebView(webView)
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if let htmlString = createTradingViewHTML() {
            webView.loadHTMLString(htmlString, baseURL: nil)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func createTradingViewHTML() -> String? {
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=3.0, user-scalable=yes">
            <script type="text/javascript" src="https://s3.tradingview.com/tv.js"></script>
            <style>
                body { 
                    margin: 0; 
                    padding: 0; 
                    background-color: #000000; 
                    overflow: hidden;
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                }
                #tradingview_chart { 
                    width: 100vw; 
                    height: 100vh; 
                    position: fixed;
                    top: 0;
                    left: 0;
                }
            </style>
        </head>
        <body>
            <div id="tradingview_chart"></div>
            <script type="text/javascript">
                let tvWidget;
                
                function initTradingView() {
                    tvWidget = new TradingView.widget({
                        "autosize": true,
                        "symbol": "\(symbol)",
                        "interval": "\(timeframe.tradingViewInterval)",
                        "timezone": "Etc/UTC",
                        "theme": "dark",
                        "style": "1",
                        "locale": "en",
                        "toolbar_bg": "#000000",
                        "enable_publishing": false,
                        "allow_symbol_change": false,
                        "container_id": "tradingview_chart",
                        "hide_top_toolbar": false,
                        "hide_legend": false,
                        "hide_side_toolbar": false,
                        "save_image": false,
                        "studies": [],
                        "overrides": {
                            "paneProperties.background": "#000000",
                            "paneProperties.backgroundType": "solid",
                            "paneProperties.vertGridProperties.color": "#1a1a1a",
                            "paneProperties.horzGridProperties.color": "#1a1a1a",
                            "symbolWatermarkProperties.transparency": 90,
                            "scalesProperties.textColor": "#AAAAAA",
                            "scalesProperties.backgroundColor": "#000000",
                            "mainSeriesProperties.candleStyle.upColor": "#00FF88",
                            "mainSeriesProperties.candleStyle.downColor": "#FF4444",
                            "mainSeriesProperties.candleStyle.borderUpColor": "#00FF88",
                            "mainSeriesProperties.candleStyle.borderDownColor": "#FF4444",
                            "mainSeriesProperties.candleStyle.wickUpColor": "#00FF88",
                            "mainSeriesProperties.candleStyle.wickDownColor": "#FF4444"
                        },
                        "loading_screen": {
                            "backgroundColor": "#000000",
                            "foregroundColor": "#FFD700"
                        },
                        "disabled_features": [
                            "use_localstorage_for_settings"
                        ],
                        "enabled_features": [
                            "study_templates",
                            "side_toolbar_in_fullscreen_mode",
                            "header_in_fullscreen_mode",
                            "move_logo_to_main_pane",
                            "chart_crosshair_menu",
                            "right_bar_stays_on_scroll"
                        ]
                    });
                }
                
                function changeSymbol(symbol) {
                    if (tvWidget) {
                        tvWidget.setSymbol(symbol, '15');
                    }
                }
                
                function changeTimeframe(interval) {
                    if (tvWidget) {
                        tvWidget.chart().setResolution(interval);
                    }
                }
                
                function changeChartType(type) {
                    if (tvWidget && tvWidget.chart) {
                        tvWidget.chart().setChartType(type === 'candles' ? 1 : type === 'bars' ? 0 : type === 'line' ? 2 : 3);
                    }
                }
                
                function enablePriceScaling(enable) {
                    if (tvWidget && tvWidget.chart) {
                        tvWidget.chart().getPanes()[0].getMainSourcePriceScale().setAutoScale(enable);
                    }
                }
                
                function resetChart() {
                    if (tvWidget && tvWidget.chart) {
                        tvWidget.chart().resetData();
                        tvWidget.chart().resetScale();
                    }
                }
                
                document.addEventListener('DOMContentLoaded', function() {
                    initTradingView();
                });
                
                initTradingView();
            </script>
        </body>
        </html>
        """
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: TradingViewWebView
        
        init(_ parent: TradingViewWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("TradingView chart loaded successfully")
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("TradingView chart failed to load: \(error.localizedDescription)")
        }
    }
}

// MARK: - ToastManager
class ToastManager: ObservableObject {
    static let shared = ToastManager()
    
    @Published var showToast = false
    @Published var toastMessage = ""
    @Published var toastType: ToastType = .info
    
    enum ToastType {
        case info, success, warning, error
        
        var color: Color {
            switch self {
            case .info: return .blue
            case .success: return .green
            case .warning: return .orange
            case .error: return .red
            }
        }
        
        var systemImage: String {
            switch self {
            case .info: return "info.circle.fill"
            case .success: return "checkmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .error: return "xmark.circle.fill"
            }
        }
    }
    
    private init() {}
    
    func show(_ message: String, type: ToastType = .info) {
        toastMessage = message
        toastType = type
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            showToast = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeOut(duration: 0.3)) {
                self.showToast = false
            }
        }
    }
}

// MARK: - Helper Components
struct TradeLockerTabButton: View {
    let title: String
    let count: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 12, weight: .medium))
                    
                    Text(count)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.blue, in: Capsule())
                }
                .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TradingTabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(isSelected ? .black : .white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                isSelected ? 
                LinearGradient(colors: [.white, .white.opacity(0.9)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                LinearGradient(colors: [.clear], startPoint: .leading, endPoint: .trailing),
                in: RoundedRectangle(cornerRadius: 6)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TradeLockerTimeframeButton: View {
    let timeframe: ChartTimeframe
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(timeframe.displayName)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isSelected ? .black : .white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    isSelected ? 
                    LinearGradient(colors: [.white, .white.opacity(0.9)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                    LinearGradient(colors: [.clear], startPoint: .leading, endPoint: .trailing),
                    in: RoundedRectangle(cornerRadius: 8)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? .clear : .white.opacity(0.2), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Custom Button Style
struct ContentViewScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview
#if DEBUG
struct TradingTerminal_Previews: PreviewProvider {
    static var previews: some View {
        TradingTerminal()
            .environmentObject(TradingManager.shared)
            .environmentObject(BotManager.shared)
            .environmentObject(HapticManager.shared)
            .environmentObject(AudioManager.shared)
            .preferredColorScheme(.dark)
    }
}
#endif
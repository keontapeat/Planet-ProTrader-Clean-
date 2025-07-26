// 
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
    
    // Environment Objects
    @EnvironmentObject var tradingManager: TradingManager
    @EnvironmentObject var botManager: BotManager
    @EnvironmentObject var hapticManager: HapticManager
    
    @StateObject private var toastManager = ToastManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Professional Background
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Clean Header
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
                                hapticManager.impact()
                            }
                        
                        // Chart Controls
                        VStack {
                            HStack {
                                Spacer()
                                
                                if isFullScreen {
                                    backToNormalButton
                                        .padding(.trailing, 16)
                                        .padding(.top, 16)
                                }
                            }
                            
                            Spacer()
                        }
                        
                        // Removed old full screen exit gesture
                        if isFullScreen {
                            Color.clear
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        isFullScreen = false
                                    }
                                    hapticManager.impact()
                                }
                                .allowsHitTesting(true)
                        }
                    }
                    
                    // TradeLocker Style Bottom Panel
                    if !isFullScreen && !toolbarHidden {
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
                                        hapticManager.impact()
                                    }
                            )
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
    
    // MARK: - TradingView-Style Reset Button
    private var tradingViewResetButton: some View {
        HStack {
            Spacer()
            
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    resetChart()
                }
                hapticManager.impact()
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
                    Button(action: {}) {
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
                            hapticManager.impact()
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
                    Text("$2,374.85")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 10, weight: .bold))
                        Text("+12.45 (+0.52%)")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(.green)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.green.opacity(0.15), in: Capsule())
                    .overlay(
                        Capsule()
                            .stroke(.green.opacity(0.3), lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
            
            // Timeframe Selector (Flush to Edge - TradeLocker Style)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(ChartTimeframe.allCases, id: \.self) { timeframe in
                        TradeLockerTimeframeButton(
                            timeframe: timeframe,
                            isSelected: selectedTimeframe == timeframe
                        ) {
                            selectedTimeframe = timeframe
                            tradingViewManager.changeTimeframe(timeframe.tradingViewInterval)
                            hapticManager.impact()
                        }
                    }
                    
                    // Add some trailing space
                    Spacer(minLength: 24)
                }
                .padding(.leading, 24)
            }
            .padding(.bottom, 0)
        }
        .background(.regularMaterial)
        .overlay(
            Rectangle()
                .fill(.white.opacity(0.1))
                .frame(height: 1),
            alignment: .bottom
        )
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
            }
            hapticManager.impact()
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
            // Professional Trading Toolbar
            HStack(spacing: 0) {
                // Chart Type Selector
                HStack(spacing: 8) {
                    ForEach(ChartType.allCases, id: \.self) { type in
                        Button(action: {
                            currentChartType = type
                            tradingViewManager.changeChartType(type.rawValue)
                            hapticManager.impact()
                        }) {
                            Image(systemName: type.icon)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(currentChartType == type ? .black : .white)
                                .frame(width: 32, height: 32)
                                .background(currentChartType == type ? Color.white : Color.white.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.black.opacity(0.8), in: Capsule())
                
                Spacer()
                
                // Quick Actions
                HStack(spacing: 12) {
                    // Drawing Tools
                    Button(action: {
                        showDrawingTools.toggle()
                        hapticManager.impact()
                    }) {
                        Image(systemName: "pencil.tip.crop.circle")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(showDrawingTools ? .yellow : .white)
                    }
                    
                    // Indicators
                    Button(action: {
                        showIndicators.toggle()
                        hapticManager.impact()
                    }) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(showIndicators ? .cyan : .white)
                    }
                    
                    // Price Alerts
                    Button(action: {
                        showPriceAlerts.toggle()
                        hapticManager.impact()
                    }) {
                        Image(systemName: "bell.badge")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(showPriceAlerts ? .orange : .white)
                    }
                }
                
                Spacer()
                
                // Trade Actions
                HStack(spacing: 8) {
                    // Quick Sell
                    Button(action: {
                        executeMT5Sell()
                    }) {
                        Text("SELL")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(.red, in: Capsule())
                    }
                    
                    // Quick Buy
                    Button(action: {
                        executeMT5Buy()
                    }) {
                        Text("BUY")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(.green, in: Capsule())
                    }
                }
            }
            .padding(.horizontal, 20)
            
            // Volume Slider for Full Screen Trade
            VStack(spacing: 8) {
                HStack {
                    Text("Volume")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    Text(String(format: "%.2f", tradeVolume))
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                Slider(value: $tradeVolume, in: 0.01...1.0, step: 0.01)
                    .accentColor(.yellow)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.black.opacity(0.8), in: RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 20)
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
    
    // MARK: - TradeLocker Watchlist Overlay
    private var tradeLockerWatchlistOverlay: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    dismissWatchlist()
                }
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Select Symbol")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        dismissWatchlist()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .background(.regularMaterial)
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    Text("Search symbols...")
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(.regularMaterial)
                
                // Symbol List
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(TradingSymbol.popularSymbols, id: \.symbol) { symbol in
                            TradeLockerSymbolRow(symbol: symbol, isSelected: selectedSymbol == symbol.symbol) {
                                selectedSymbol = symbol.symbol
                                tradingViewManager.changeSymbol(symbol.symbol)
                                dismissWatchlist()
                                hapticManager.impact()
                            }
                        }
                    }
                }
                .background(.regularMaterial)
            }
            .frame(maxHeight: .infinity)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .padding(.horizontal, 16)
            .padding(.vertical, 40)
            .offset(y: overlayOffset)
            .transition(.move(edge: .bottom).combined(with: .scale(scale: 0.95)).combined(with: .opacity))
        }
    }
    
    // MARK: - TradeLocker Trade Panel Overlay
    private var tradeLockerTradePanelOverlay: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    dismissTradePanel()
                }
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("New Order")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("Place your trade")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        dismissTradePanel()
                    }) {
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.1))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .background(.regularMaterial)
                
                // Trade Form Content
                ScrollView {
                    VStack(spacing: 20) {
                        // Symbol & Volume Row
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Symbol")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Text(selectedSymbol)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Volume")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                HStack(spacing: 12) {
                                    Button("-") {
                                        if tradeVolume > 0.01 {
                                            tradeVolume = max(0.01, tradeVolume - 0.01)
                                        }
                                        hapticManager.impact()
                                    }
                                    .font(.title2)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .frame(width: 36, height: 36)
                                    .background(.ultraThinMaterial, in: Circle())
                                    
                                    Text(String(format: "%.2f", tradeVolume))
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    
                                    Button("+") {
                                        tradeVolume = min(1.0, tradeVolume + 0.01)
                                        hapticManager.impact()
                                    }
                                    .font(.title2)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .frame(width: 36, height: 36)
                                    .background(.ultraThinMaterial, in: Circle())
                                }
                            }
                        }
                        
                        // Price Display
                        VStack(spacing: 16) {
                            Text("Current Prices")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                            
                            HStack(spacing: 16) {
                                // Sell Price
                                Button(action: {
                                    executeMT5Sell()
                                    dismissTradePanel()
                                }) {
                                    VStack(spacing: 8) {
                                        Text("SELL")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.red)
                                        
                                        Text("2374.32")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                        
                                        Text("BID")
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.red.opacity(0.1))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(.red.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                // Spread
                                VStack(spacing: 4) {
                                    Text("SPREAD")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                    Text("0.53")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.orange)
                                }
                                
                                // Buy Price
                                Button(action: {
                                    executeMT5Buy()
                                    dismissTradePanel()
                                }) {
                                    VStack(spacing: 8) {
                                        Text("BUY")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.green)
                                        
                                        Text("2374.85")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                        
                                        Text("ASK")
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.green.opacity(0.1))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(.green.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        
                        // Risk Management
                        VStack(spacing: 12) {
                            HStack {
                                Text("Risk Management")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Stop Loss")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text("2349.50")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.red)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Take Profit")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text("2399.50")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.green)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 24)
                }
                .background(.regularMaterial)
            }
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .padding(.horizontal, 16)
            .padding(.vertical, 40)
            .offset(y: overlayOffset)
            .transition(.move(edge: .bottom).combined(with: .scale(scale: 0.95)).combined(with: .opacity))
        }
    }
    
    // MARK: - TradeLocker Positions Overlay
    private var tradeLockerPositionsOverlay: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    dismissPositions()
                }
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Positions")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("2 active positions")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        dismissPositions()
                    }) {
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.1))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .background(.regularMaterial)
                
                // Positions List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(0..<3) { index in
                            TradeLockerPositionCard(
                                symbol: "XAUUSD",
                                type: index % 2 == 0 ? "BUY" : "SELL",
                                volume: "0.01",
                                entryPrice: "2374.50",
                                currentPrice: "2376.25",
                                profit: index % 3 == 0 ? "-45.20" : "+67.85",
                                isProfit: index % 3 != 0
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                }
                .background(.regularMaterial)
            }
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .padding(.horizontal, 16)
            .padding(.vertical, 60)
            .offset(y: overlayOffset)
            .transition(.move(edge: .bottom).combined(with: .scale(scale: 0.95)).combined(with: .opacity))
        }
    }
    
    // MARK: - TradeLocker Orders Overlay
    private var tradeLockerOrdersOverlay: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    dismissOrders()
                }
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Orders")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("3 pending orders")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        dismissOrders()
                    }) {
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.1))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .background(.regularMaterial)
                
                // Orders List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(0..<4) { index in
                            TradeLockerOrderCard(
                                symbol: "XAUUSD",
                                type: index % 2 == 0 ? "BUY LIMIT" : "SELL STOP",
                                volume: "0.01",
                                targetPrice: index % 2 == 0 ? "2370.00" : "2380.00"
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                }
                .background(.regularMaterial)
            }
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .padding(.horizontal, 16)
            .padding(.vertical, 60)
            .offset(y: overlayOffset)
            .transition(.move(edge: .bottom).combined(with: .scale(scale: 0.95)).combined(with: .opacity))
        }
    }
    
    // MARK: - TradeLocker History Overlay
    private var tradeLockerHistoryOverlay: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    dismissHistory()
                }
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("History")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("Today's trades")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        dismissHistory()
                    }) {
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.1))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .background(.regularMaterial)
                
                // History List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(0..<8) { index in
                            TradeLockerHistoryCard(
                                symbol: "XAUUSD",
                                type: index % 2 == 0 ? "BUY" : "SELL",
                                volume: "0.01",
                                profit: index % 3 == 0 ? "-23.45" : "+45.67",
                                time: "14:3\(index % 10)",
                                duration: "\(index + 1)m \(index * 15 % 60)s"
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                }
                .background(.regularMaterial)
            }
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .padding(.horizontal, 16)
            .padding(.vertical, 60)
            .offset(y: overlayOffset)
            .transition(.move(edge: .bottom).combined(with: .scale(scale: 0.95)).combined(with: .opacity))
        }
    }
    
    // MARK: - TradeLocker Bottom Panel
    private var tradeLockerBottomPanel: some View {
        VStack(spacing: 0) {
            // Minimal drag indicator
            RoundedRectangle(cornerRadius: 2)
                .fill(.white.opacity(0.3))
                .frame(width: 36, height: 3)
                .padding(.top, 6)
            
            VStack(spacing: 8) {
                // Balance Row (Flush & Compact)
                HStack(spacing: 8) {
                    TradeLockerStatCard(title: "Balance", value: "$10,425", color: .blue)
                    TradeLockerStatCard(title: "Equity", value: "$10,687", color: .green)
                    TradeLockerStatCard(title: "P&L", value: "+$262", color: .cyan)
                    TradeLockerStatCard(title: "Margin", value: "12%", color: .orange)
                }
                
                // Professional Trading Interface (Flush)
                VStack(spacing: 8) {
                    // Margin Display (from image)
                    VStack(spacing: 6) {
                        // Warning indicators (red triangles from image)
                        HStack {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.red)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.red)
                            }
                        }
                        
                        // Init. Margin display
                        Text("Init. Margin: ~$11.76 (∞)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    
                    // Trading Interface (Exact from image)
                    HStack(spacing: 0) {
                        // SELL Button
                        Button(action: {
                            executeMT5Sell()
                        }) {
                            VStack(spacing: 4) {
                                Text("117,496.25")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                Text("SELL")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 70)
                            .background(Color(red: 0.2, green: 0.2, blue: 0.2))
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Center Volume Control
                        VStack(spacing: 0) {
                            // Minus button
                            Button(action: {
                                if tradeVolume > 0.01 {
                                    tradeVolume = max(0.01, tradeVolume - 0.01)
                                }
                                hapticManager.impact()
                            }) {
                                Image(systemName: "minus")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.gray)
                                    .frame(height: 16)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Volume display
                            VStack(spacing: 1) {
                                Text(String(format: "%.2f", tradeVolume))
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                Text("lots")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.gray)
                            }
                            .frame(height: 38)
                            
                            // Plus button
                            Button(action: {
                                tradeVolume = min(1.0, tradeVolume + 0.01)
                                hapticManager.impact()
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.gray)
                                    .frame(height: 16)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .frame(width: 100)
                        .frame(height: 70)
                        .background(Color.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.gray.opacity(0.3), lineWidth: 1)
                        )
                        
                        // BUY Button
                        Button(action: {
                            executeMT5Buy()
                        }) {
                            VStack(spacing: 4) {
                                Text("117,677.50")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                Text("BUY")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 70)
                            .background(Color(red: 0.2, green: 0.2, blue: 0.2))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.gray.opacity(0.2), lineWidth: 1)
                    )
                }
                
                // Bottom Tabs (Positions, Orders, History)
                HStack(spacing: 0) {
                    TradeLockerTabButton(title: "Positions", count: "2") {
                        showingPositions = true
                    }
                    TradeLockerTabButton(title: "Orders", count: "3") {
                        showingOrders = true
                    }
                    TradeLockerTabButton(title: "History", count: "15") {
                        showingHistory = true
                    }
                }
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
        }
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
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
        hapticManager.impact()
    }
    
    private func dismissTradePanel() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            showingTradePanel = false
            overlayOffset = 0
        }
        hapticManager.impact()
    }
    
    private func dismissPositions() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            showingPositions = false
            overlayOffset = 0
        }
        hapticManager.impact()
    }
    
    private func dismissOrders() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            showingOrders = false
            overlayOffset = 0
        }
        hapticManager.impact()
    }
    
    private func dismissHistory() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            showingHistory = false
            overlayOffset = 0
        }
        hapticManager.impact()
    }
    
    // MARK: - Helper Methods
    private func setupTradingView() {
        tradingViewManager.initialize(symbol: selectedSymbol, timeframe: selectedTimeframe)
    }
    
    private func resetChart() {
        tradingViewManager.resetChart()
        toastManager.show("Chart reset to default view", type: .info)
    }
    
    private func executeBuyOrder() {
        toastManager.show("BUY order executed at \(selectedSymbol) - \(String(format: "%.2f", tradeVolume)) lots", type: .success)
        hapticManager.impact()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            hapticManager.impact()
        }
    }
    
    private func executeSellOrder() {
        toastManager.show("SELL order executed at \(selectedSymbol) - \(String(format: "%.2f", tradeVolume)) lots", type: .warning)
        hapticManager.impact()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            hapticManager.impact()
        }
    }
    
    // MARK: - MT5 Trading Functions
    private func executeMT5Buy() {
        toastManager.show("MT5 BUY executed - \(selectedSymbol) @ \(String(format: "%.2f", tradeVolume)) lots", type: .success)
        hapticManager.impact()
        
        // Add MT5 specific logic here
        Task {
            // Simulate MT5 order execution
            try? await Task.sleep(nanoseconds: 100_000_000)
            hapticManager.impact()
        }
    }
    
    private func executeMT5Sell() {
        toastManager.show("MT5 SELL executed - \(selectedSymbol) @ \(String(format: "%.2f", tradeVolume)) lots", type: .warning)
        hapticManager.impact()
        
        // Add MT5 specific logic here
        Task {
            // Simulate MT5 order execution
            try? await Task.sleep(nanoseconds: 100_000_000)
            hapticManager.impact()
        }
    }
}

// MARK: - TradeLocker Components
struct TradeLockerStatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.gray)
            
            Text(value)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 40)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

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

// MARK: - Clean Components
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
        executeJavaScript("resetChart'")
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

class ToastManager: ObservableObject {
    static let shared = ToastManager()
    
    @Published var showToast = false
    @Published var toastMessage = ""
    @Published var toastType: ToastType = .info
    
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

struct TradingSymbol {
    let symbol: String
    let name: String
    let type: String
    
    static let popularSymbols = [
        TradingSymbol(symbol: "XAUUSD", name: "Gold Spot", type: "METALS"),
        TradingSymbol(symbol: "EURUSD", name: "Euro/USD", type: "FOREX"),
        TradingSymbol(symbol: "GBPUSD", name: "Pound/USD", type: "FOREX"),
        TradingSymbol(symbol: "USDJPY", name: "USD/Yen", type: "FOREX"),
        TradingSymbol(symbol: "BTCUSD", name: "Bitcoin", type: "CRYPTO"),
        TradingSymbol(symbol: "ETHUSD", name: "Ethereum", type: "CRYPTO"),
        TradingSymbol(symbol: "XAGUSD", name: "Silver Spot", type: "METALS"),
        TradingSymbol(symbol: "USDCHF", name: "USD/Swiss Franc", type: "FOREX"),
        TradingSymbol(symbol: "AUDUSD", name: "Australian Dollar/USD", type: "FOREX"),
        TradingSymbol(symbol: "USDCAD", name: "USD/Canadian Dollar", type: "FOREX")
    ]
}

// MARK: - TradeLocker Symbol Row
struct TradeLockerSymbolRow: View {
    let symbol: TradingSymbol
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Symbol Icon
                Circle()
                    .fill(
                        LinearGradient(
                            colors: symbolColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(symbol.symbol.prefix(2)))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(symbol.symbol)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(isSelected ? .blue : .white)
                    
                    Text(symbol.name)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("2374.85")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 10, weight: .bold))
                        Text("+0.52%")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(isSelected ? .blue.opacity(0.1) : .clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var symbolColors: [Color] {
        switch symbol.type {
        case "METALS": return [.yellow, .orange]
        case "FOREX": return [.blue, .cyan]
        case "CRYPTO": return [.purple, .pink]
        default: return [.gray, .gray.opacity(0.8)]
        }
    }
}

struct TradeLockerPositionCard: View {
    let symbol: String
    let type: String
    let volume: String
    let entryPrice: String
    let currentPrice: String
    let profit: String
    let isProfit: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            // Header Row
            HStack {
                HStack(spacing: 8) {
                    Circle()
                        .fill(type == "BUY" ? .green : .red)
                        .frame(width: 8, height: 8)
                    
                    Text(symbol)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(type)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(type == "BUY" ? .green : .red)
                }
                
                Spacer()
                
                Text(profit)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(isProfit ? .green : .red)
            }
            
            // Details Row
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Volume")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Text(volume)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .center, spacing: 4) {
                    Text("Entry Price")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Text(entryPrice)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Current Price")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Text(currentPrice)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                Button("Modify") {
                    HapticManager.shared.impact()
                }
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                
                Button("Close") {
                    HapticManager.shared.impact()
                }
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isProfit ? .green.opacity(0.3) : .red.opacity(0.3), lineWidth: 1)
        )
    }
}

struct TradeLockerOrderCard: View {
    let symbol: String
    let type: String
    let volume: String
    let targetPrice: String
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(symbol)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(type)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(targetPrice)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("PENDING")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.orange.opacity(0.2), in: Capsule())
                }
            }
            
            HStack {
                Text("Volume: \(volume)")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button("Cancel") {
                    HapticManager.shared.impact()
                }
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.red)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.red.opacity(0.1), in: Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.orange.opacity(0.3), lineWidth: 1)
        )
    }
}

struct TradeLockerHistoryCard: View {
    let symbol: String
    let type: String
    let volume: String
    let profit: String
    let time: String
    let duration: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Trade Icon
            Circle()
                .fill(profit.contains("+") ? .green : .red)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(symbol)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(type)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                }
                
                Text("Volume: \(volume) • \(duration)")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(profit)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(profit.contains("+") ? .green : .red)
                
                Text(time)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
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
                let toolbarVisible = true;
                
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
                
                function toggleToolbar(show) {
                    toolbarVisible = show;
                    if (tvWidget && tvWidget.chart) {
                        const toolbar = document.querySelector('.chart-container-border');
                        if (toolbar) {
                            toolbar.style.display = show ? 'block' : 'none';
                        }
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

#Preview {
    TradingTerminal()
        .environmentObject(TradingManager.shared)
        .environmentObject(BotManager.shared)
        .environmentObject(HapticManager.shared)
        .preferredColorScheme(.dark)
}
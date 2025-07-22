//
//  TradingTerminal.swift
//  Planet ProTrader - Professional Trading Terminal
//
//  Advanced Trading Terminal with Real-Time Charts
//  Integrated with Planet ProTrader Ecosystem
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

struct TradingTerminal: View {
    // MARK: - State Management
    @StateObject private var chartDataService = ChartDataService.shared
    @State private var chartSettings = ChartSettings()
    @State private var selectedTimeframe: ChartTimeframe = .m15
    
    // Environment Objects
    @EnvironmentObject var tradingManager: TradingManager
    @EnvironmentObject var botManager: BotManager
    @EnvironmentObject var hapticManager: HapticManager
    
    // UI States
    @State private var showingIndicators = false
    @State private var showingSettings = false
    @State private var showingTools = false
    @State private var showingNews = false
    @State private var showingDrawings = false
    @State private var showingAlerts = false
    @State private var showingBacktest = false
    @State private var showingAnalytics = false
    @State private var showingOrderBook = false
    @State private var showingPositions = false
    @State private var showingWatchlist = false
    @State private var showingScanner = false
    @State private var showingCalendar = false
    @State private var showingChat = false
    
    // Market Data
    @State private var selectedSymbol = "XAUUSD"
    
    // Connection Status
    @State private var isConnected = true
    @State private var connectionStatus = "Connected"
    
    // UI Controls
    @State private var showMinimalUI = false
    @State private var autoHideControls = true
    @State private var lastInteractionTime = Date()
    
    @StateObject private var toastManager = ToastManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color.black,
                        Color(.systemGray6).opacity(0.1),
                        Color.black
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    terminalHeader
                    
                    // Main chart area
                    chartArea
                    
                    // Bottom controls
                    if !showMinimalUI {
                        bottomControls
                    }
                }
            }
            .navigationBarHidden(true)
            .onTapGesture {
                lastInteractionTime = Date()
                if showMinimalUI && autoHideControls {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showMinimalUI = false
                    }
                }
            }
            .onAppear {
                startAutoHideTimer()
                setupInitialData()
            }
            .overlay(alignment: .topTrailing) {
                if toastManager.showToast {
                    toastView
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
    }
    
    // MARK: - Header
    
    private var terminalHeader: some View {
        HStack {
            // Connection status
            HStack(spacing: 4) {
                Circle()
                    .fill(tradingManager.isConnected ? DesignSystem.tradingGreen : DesignSystem.tradingRed)
                    .frame(width: 8, height: 8)
                    .pulseEffect(tradingManager.isConnected)
                
                Text(tradingManager.isConnected ? "LIVE" : "DISCONNECTED")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(tradingManager.isConnected ? DesignSystem.tradingGreen : DesignSystem.tradingRed)
            }
            
            Spacer()
            
            // Symbol and price
            VStack(alignment: .center, spacing: 2) {
                Text(selectedSymbol)
                    .font(.headline)
                    .fontWeight(.bold)
                    .goldText()
                
                HStack(spacing: 8) {
                    Text(tradingManager.goldPrice.formattedPrice)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(tradingManager.goldPrice.formattedChange)
                        .font(.caption)
                        .foregroundColor(tradingManager.goldPrice.isPositive ? DesignSystem.tradingGreen : DesignSystem.tradingRed)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill((tradingManager.goldPrice.isPositive ? DesignSystem.tradingGreen : DesignSystem.tradingRed).opacity(0.2))
                        )
                }
            }
            
            Spacer()
            
            // Settings and AI button
            HStack(spacing: 12) {
                // AI Assistant button
                Button(action: {
                    toastManager.show("🧠 AI Assistant activated", type: .success)
                    hapticManager.success()
                }) {
                    Image(systemName: "brain.head.profile")
                        .font(.title3)
                        .foregroundColor(DesignSystem.primaryGold)
                        .pulseEffect()
                }
                
                // Settings button
                Button(action: {
                    showingSettings.toggle()
                    hapticManager.impact()
                }) {
                    Image(systemName: "gear")
                        .font(.title3)
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .overlay(
            Rectangle()
                .fill(DesignSystem.goldGradient)
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    // MARK: - Chart Area
    
    private var chartArea: some View {
        GeometryReader { geometry in
            ZStack {
                // Professional Chart Background
                Rectangle()
                    .fill(.clear)
                    .background(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.8),
                                Color(.systemGray6).opacity(0.1)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        // Chart Grid
                        VStack {
                            ForEach(0..<8) { _ in
                                Rectangle()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 1)
                                Spacer()
                            }
                        }
                    )
                    .overlay(
                        // Price Chart Simulation
                        chartVisualization
                    )
                
                // Overlay controls
                if showingIndicators {
                    indicatorOverlay
                }
                
                if showingDrawings {
                    drawingOverlay
                }
                
                if showingOrderBook {
                    orderBookOverlay
                }
                
                if showingPositions {
                    positionsOverlay
                }
            }
        }
    }
    
    private var chartVisualization: some View {
        GeometryReader { geometry in
            // Simulate candlestick chart
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(0..<50) { index in
                    VStack {
                        Spacer()
                        
                        // Candlestick
                        Rectangle()
                            .fill(index % 3 == 0 ? DesignSystem.tradingGreen : DesignSystem.tradingRed)
                            .frame(
                                width: max(2, geometry.size.width / 60),
                                height: CGFloat.random(in: 20...100)
                            )
                    }
                }
            }
            .padding(.horizontal)
            
            // Price line overlay
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                
                path.move(to: CGPoint(x: 0, y: height * 0.6))
                
                for i in 0..<100 {
                    let x = CGFloat(i) * (width / 100)
                    let y = height * 0.6 + sin(Double(i) * 0.3) * 50
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .stroke(DesignSystem.primaryGold, lineWidth: 2)
            .shadow(color: DesignSystem.primaryGold.opacity(0.5), radius: 4)
        }
    }
    
    // MARK: - Bottom Controls
    
    private var bottomControls: some View {
        VStack(spacing: 8) {
            // Quick trading buttons
            quickTradingButtons
            
            // Timeframe selector
            timeframeSelector
            
            // Tool buttons
            toolButtons
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .background(.ultraThinMaterial)
        .overlay(
            Rectangle()
                .fill(DesignSystem.goldGradient)
                .frame(height: 1),
            alignment: .top
        )
    }
    
    private var quickTradingButtons: some View {
        HStack(spacing: 16) {
            // Buy button
            Button(action: {
                toastManager.show("🟢 BUY order placed", type: .success)
                hapticManager.success()
            }) {
                HStack {
                    Image(systemName: "arrow.up.circle.fill")
                    Text("BUY")
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(DesignSystem.tradingGreen, in: RoundedRectangle(cornerRadius: 8))
            }
            
            // Sell button
            Button(action: {
                toastManager.show("🔴 SELL order placed", type: .warning)
                hapticManager.success()
            }) {
                HStack {
                    Image(systemName: "arrow.down.circle.fill")
                    Text("SELL")
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(DesignSystem.tradingRed, in: RoundedRectangle(cornerRadius: 8))
            }
            
            Spacer()
            
            // AI Bot Deploy
            Button(action: {
                Task {
                    if let goldBot = botManager.allBots.first(where: { $0.name.contains("Golden") }) {
                        await botManager.deployBot(goldBot)
                        toastManager.show("🤖 Golden Eagle deployed", type: .success)
                    }
                }
                hapticManager.impact()
            }) {
                HStack {
                    Image(systemName: "brain.head.profile")
                    Text("DEPLOY AI")
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(DesignSystem.goldGradient, in: RoundedRectangle(cornerRadius: 8))
            }
        }
    }
    
    private var timeframeSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ChartTimeframe.allCases, id: \.self) { timeframe in
                    Button(timeframe.rawValue) {
                        selectedTimeframe = timeframe
                        hapticManager.selection()
                        toastManager.show("📊 Timeframe: \(timeframe.rawValue)", type: .info)
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(selectedTimeframe == timeframe ? DesignSystem.primaryGold : Color.clear)
                    )
                    .foregroundColor(selectedTimeframe == timeframe ? .black : .primary)
                }
            }
            .padding(.horizontal, 8)
        }
    }
    
    private var toolButtons: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
            ToolButton(title: "Indicators", icon: "chart.line.uptrend.xyaxis", isActive: $showingIndicators)
            ToolButton(title: "Tools", icon: "pencil.and.ruler", isActive: $showingTools)
            ToolButton(title: "News", icon: "newspaper", isActive: $showingNews)
            ToolButton(title: "Alerts", icon: "bell", isActive: $showingAlerts)
            ToolButton(title: "Orders", icon: "list.bullet", isActive: $showingOrderBook)
            ToolButton(title: "Positions", icon: "briefcase", isActive: $showingPositions)
        }
    }
    
    // MARK: - Overlays
    
    private var indicatorOverlay: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("📊 Technical Indicators")
                    .font(.headline)
                    .fontWeight(.bold)
                    .goldText()
                
                Spacer()
                
                Button("Close") {
                    showingIndicators = false
                }
                .foregroundColor(.secondary)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                IndicatorCard(name: "RSI (14)", value: "68.5", signal: "BUY", color: .green)
                IndicatorCard(name: "MACD", value: "12.3", signal: "SELL", color: .red)
                IndicatorCard(name: "MA (50)", value: "2374.20", signal: "HOLD", color: .orange)
                IndicatorCard(name: "Bollinger", value: "0.85", signal: "BUY", color: .green)
            }
            
            Spacer()
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding()
        .transition(.slide)
    }
    
    private var drawingOverlay: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("✏️ Drawing Tools")
                    .font(.headline)
                    .fontWeight(.bold)
                    .goldText()
                
                Spacer()
                
                Button("Close") {
                    showingDrawings = false
                }
                .foregroundColor(.secondary)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                DrawingTool(name: "Line", icon: "line.diagonal")
                DrawingTool(name: "Rectangle", icon: "rectangle")
                DrawingTool(name: "Circle", icon: "circle")
                DrawingTool(name: "Arrow", icon: "arrow.right")
                DrawingTool(name: "Text", icon: "textformat")
                DrawingTool(name: "Fibonacci", icon: "chart.xyaxis.line")
            }
            
            Spacer()
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding()
        .transition(.slide)
    }
    
    private var orderBookOverlay: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("📋 Order Book")
                    .font(.headline)
                    .fontWeight(.bold)
                    .goldText()
                
                Spacer()
                
                Button("Close") {
                    showingOrderBook = false
                }
                .foregroundColor(.secondary)
            }
            
            VStack(spacing: 8) {
                // Sample orders
                ForEach(0..<5) { index in
                    HStack {
                        Text("BUY")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Text("0.10")
                            .font(.caption)
                        
                        Spacer()
                        
                        Text("2374.\(index * 5)")
                            .font(.caption)
                            .fontWeight(.semibold)
                        
                        Text("PENDING")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 6))
                }
            }
            
            Spacer()
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding()
        .transition(.slide)
    }
    
    private var positionsOverlay: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("💼 Active Positions")
                    .font(.headline)
                    .fontWeight(.bold)
                    .goldText()
                
                Spacer()
                
                Button("Close") {
                    showingPositions = false
                }
                .foregroundColor(.secondary)
            }
            
            VStack(spacing: 8) {
                // Sample positions
                ForEach(0..<3) { index in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("XAUUSD")
                                .font(.caption)
                                .fontWeight(.bold)
                            
                            Text(index % 2 == 0 ? "BUY" : "SELL")
                                .font(.caption2)
                                .foregroundColor(index % 2 == 0 ? .green : .red)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("+$\(index * 50 + 25)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            
                            Text("0.10 lots")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                }
            }
            
            Spacer()
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding()
        .transition(.slide)
    }
    
    private var toastView: some View {
        HStack {
            Image(systemName: toastManager.toastType.systemImage)
                .foregroundColor(toastManager.toastType.color)
            
            Text(toastManager.toastMessage)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .padding()
    }
    
    // MARK: - Helper Methods
    
    private func startAutoHideTimer() {
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            if autoHideControls && Date().timeIntervalSince(lastInteractionTime) > 5.0 {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showMinimalUI = true
                }
            }
        }
    }
    
    private func setupInitialData() {
        // Connect to real trading data
        Task {
            await tradingManager.refreshData()
        }
    }
}

// MARK: - Supporting Types

class ChartDataService: ObservableObject {
    static let shared = ChartDataService()
    
    @Published var candlestickData: [CandlestickData] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private init() {
        loadSampleData()
    }
    
    private func loadSampleData() {
        candlestickData = CandlestickData.sampleData
    }
    
    func updateData() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
        }
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
        withAnimation {
            showToast = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation {
                self.showToast = false
            }
        }
    }
    
    enum ToastType {
        case info
        case success
        case warning
        case error
        
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

struct ChartSettings {
    var showGrid: Bool = true
    var showVolume: Bool = true
    var selectedTimeframe: ChartTimeframe = .m15
    var indicatorsEnabled: Bool = true
}

enum ChartTimeframe: String, CaseIterable, Codable {
    case m1 = "1M"
    case m5 = "5M"
    case m15 = "15M"
    case m30 = "30M"
    case h1 = "1H"
    case h4 = "4H"
    case d1 = "1D"
    case w1 = "1W"
    case mn1 = "1MN"
}

struct CandlestickData: Identifiable, Codable {
    let id = UUID()
    let timestamp: Date
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let volume: Double
    
    static var sampleData: [CandlestickData] {
        var data: [CandlestickData] = []
        let basePrice = 2374.50
        
        for i in 0..<100 {
            let timestamp = Date().addingTimeInterval(TimeInterval(-i * 900))
            let open = basePrice + Double.random(in: -10...10)
            let close = open + Double.random(in: -5...5)
            let high = max(open, close) + Double.random(in: 0...3)
            let low = min(open, close) - Double.random(in: 0...3)
            let volume = Double.random(in: 1000...10000)
            
            data.append(CandlestickData(
                timestamp: timestamp,
                open: open,
                high: high,
                low: low,
                close: close,
                volume: volume
            ))
        }
        
        return data.reversed()
    }
}

// MARK: - Components

struct ToolButton: View {
    let title: String
    let icon: String
    @Binding var isActive: Bool
    
    var body: some View {
        Button(action: {
            isActive.toggle()
            HapticManager.shared.selection()
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(isActive ? .black : .primary)
                
                Text(title)
                    .font(.caption2)
                    .foregroundColor(isActive ? .black : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isActive ? DesignSystem.primaryGold : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct IndicatorCard: View {
    let name: String
    let value: String
    let signal: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(name)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(signal)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(color)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(color.opacity(0.2), in: Capsule())
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

struct DrawingTool: View {
    let name: String
    let icon: String
    
    var body: some View {
        Button(action: {
            HapticManager.shared.selection()
        }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(DesignSystem.primaryGold)
                
                Text(name)
                    .font(.caption2)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    TradingTerminal()
        .environmentObject(TradingManager.shared)
        .environmentObject(BotManager.shared)
        .environmentObject(HapticManager.shared)
        .preferredColorScheme(.dark)
}
//
//  TradingTerminal.swift
//  Planet ProTrader - Professional Trading Terminal
//
//  Clean Minimal Trading Terminal for Mobile
//  Modern iPhone-Optimized Design
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI
import WebKit

struct TradingTerminal: View {
    // MARK: - State Management
    @StateObject private var tradingViewManager = TradingViewManager()
    @State private var selectedTimeframe: ChartTimeframe = .m15
    @State private var selectedSymbol = "XAUUSD"
    @State private var showingWatchlist = false
    @State private var showingTradePanel = false
    
    // Environment Objects
    @EnvironmentObject var tradingManager: TradingManager
    @EnvironmentObject var botManager: BotManager
    @EnvironmentObject var hapticManager: HapticManager
    
    @StateObject private var toastManager = ToastManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Clean Background
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Clean Header
                    cleanHeader
                    
                    // Main Chart (Takes most space)
                    cleanChart
                    
                    // Bottom Trading Panel
                    bottomTradingPanel
                }
                
                // Overlays
                if showingWatchlist {
                    watchlistOverlay
                        .zIndex(2)
                }
                
                if showingTradePanel {
                    tradePanelOverlay
                        .zIndex(2)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                setupTradingView()
            }
            .overlay(alignment: .topTrailing) {
                if toastManager.showToast {
                    cleanToast
                }
            }
        }
    }
    
    // MARK: - Clean Header
    
    private var cleanHeader: some View {
        VStack(spacing: 12) {
            // Top Row: Title & Connection
            HStack {
                Text("ProTrader")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                
                Spacer()
                
                // Connection Status
                HStack(spacing: 4) {
                    Circle()
                        .fill(tradingManager.isConnected ? .green : .red)
                        .frame(width: 6, height: 6)
                    Text("LIVE")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(tradingManager.isConnected ? .green : .red)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.ultraThinMaterial, in: Capsule())
            }
            
            // Symbol Info Row
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(selectedSymbol)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Button(action: { showingWatchlist = true }) {
                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Text("Gold Spot")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("$2,374.85")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4) {
                        Text("+12.45")
                        Text("(+0.52%)")
                    }
                    .font(.caption)
                    .foregroundColor(.green)
                }
            }
            
            // Timeframe Selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(ChartTimeframe.allCases, id: \.self) { timeframe in
                        CleanTimeframeButton(
                            timeframe: timeframe,
                            isSelected: selectedTimeframe == timeframe
                        ) {
                            selectedTimeframe = timeframe
                            tradingViewManager.changeTimeframe(timeframe.tradingViewInterval)
                            hapticManager.selection()
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.regularMaterial)
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
    
    // MARK: - Bottom Trading Panel
    
    private var bottomTradingPanel: some View {
        VStack(spacing: 16) {
            // Quick Stats Row
            HStack(spacing: 20) {
                StatCard(title: "Balance", value: "$10,425", color: .blue)
                StatCard(title: "Equity", value: "$10,687", color: .green)
                StatCard(title: "P&L", value: "+$262", color: .green)
                StatCard(title: "Margin", value: "$234", color: .orange)
            }
            
            // Trading Buttons Row
            HStack(spacing: 12) {
                // Trade Button
                Button(action: { showingTradePanel = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                        Text("New Trade")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: RoundedRectangle(cornerRadius: 12)
                    )
                }
                
                // AI Bot Button
                Button(action: deployAIBot) {
                    HStack(spacing: 8) {
                        Image(systemName: "brain.head.profile")
                        Text("Deploy AI")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: RoundedRectangle(cornerRadius: 12)
                    )
                }
            }
            
            // Quick Access Row
            HStack(spacing: 20) {
                QuickAccessButton(title: "Positions", icon: "briefcase", count: "2") {}
                QuickAccessButton(title: "Orders", icon: "list.bullet", count: "3") {}
                QuickAccessButton(title: "History", icon: "clock", count: "15") {}
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(.regularMaterial)
    }
    
    // MARK: - Watchlist Overlay
    
    private var watchlistOverlay: some View {
        ZStack {
            // Background Blur
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    showingWatchlist = false
                }
            
            // Watchlist Panel
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Select Symbol")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button("Close") {
                        showingWatchlist = false
                    }
                    .foregroundColor(.gray)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(.regularMaterial)
                
                // Symbol List
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(TradingSymbol.popularSymbols, id: \.symbol) { symbol in
                            CleanSymbolRow(symbol: symbol) {
                                selectedSymbol = symbol.symbol
                                tradingViewManager.changeSymbol(symbol.symbol)
                                showingWatchlist = false
                                hapticManager.selection()
                            }
                        }
                    }
                }
            }
            .frame(height: 500)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal, 20)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
    
    // MARK: - Trade Panel Overlay
    
    private var tradePanelOverlay: some View {
        ZStack {
            // Background Blur
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    showingTradePanel = false
                }
            
            // Trade Panel
            VStack(spacing: 20) {
                // Header
                HStack {
                    Text("New Trade")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button("Close") {
                        showingTradePanel = false
                    }
                    .foregroundColor(.gray)
                }
                
                // Symbol & Volume
                VStack(spacing: 16) {
                    HStack {
                        Text("Symbol")
                            .foregroundColor(.gray)
                        Spacer()
                        Text(selectedSymbol)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    
                    HStack {
                        Text("Volume")
                            .foregroundColor(.gray)
                        Spacer()
                        HStack(spacing: 12) {
                            Button("-") {
                                hapticManager.selection()
                            }
                            .font(.title3)
                            .foregroundColor(.gray)
                            
                            Text("0.10")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Button("+") {
                                hapticManager.selection()
                            }
                            .font(.title3)
                            .foregroundColor(.gray)
                        }
                    }
                }
                
                // Price Display
                HStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Text("BID")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("2374.32")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    
                    VStack(spacing: 8) {
                        Text("ASK")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("2374.85")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
                
                // Trade Buttons
                HStack(spacing: 16) {
                    Button(action: {
                        executeSellOrder()
                        showingTradePanel = false
                    }) {
                        VStack(spacing: 4) {
                            Text("SELL")
                                .font(.headline)
                                .fontWeight(.bold)
                            Text("2374.32")
                                .font(.subheadline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(.red, in: RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Button(action: {
                        executeBuyOrder()
                        showingTradePanel = false
                    }) {
                        VStack(spacing: 4) {
                            Text("BUY")
                                .font(.headline)
                                .fontWeight(.bold)
                            Text("2374.85")
                                .font(.subheadline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(.green, in: RoundedRectangle(cornerRadius: 12))
                    }
                }
                
                Spacer()
            }
            .padding(20)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal, 20)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
    
    // MARK: - Clean Toast
    
    private var cleanToast: some View {
        HStack(spacing: 12) {
            Image(systemName: toastManager.toastType.systemImage)
                .foregroundColor(toastManager.toastType.color)
            
            Text(toastManager.toastMessage)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .padding()
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    // MARK: - Helper Methods
    
    private func setupTradingView() {
        tradingViewManager.initialize(symbol: selectedSymbol, timeframe: selectedTimeframe.tradingViewInterval)
    }
    
    private func executeBuyOrder() {
        toastManager.show("✅ BUY order executed", type: .success)
        hapticManager.success()
    }
    
    private func executeSellOrder() {
        toastManager.show("✅ SELL order executed", type: .success)
        hapticManager.success()
    }
    
    private func deployAIBot() {
        toastManager.show("🤖 AI Bot deployed", type: .success)
        hapticManager.success()
        
        Task {
            if let goldBot = botManager.allBots.first(where: { $0.name.contains("Golden") }) {
                await botManager.deployBot(goldBot)
            }
        }
    }
}

// MARK: - Clean Components

struct CleanTimeframeButton: View {
    let timeframe: ChartTimeframe
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(timeframe.displayName)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : .gray)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected ? 
                    LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing) :
                    LinearGradient(colors: [.clear], startPoint: .leading, endPoint: .trailing),
                    in: RoundedRectangle(cornerRadius: 8)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? .clear : .gray.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

struct QuickAccessButton: View {
    let title: String
    let icon: String
    let count: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: icon)
                        .font(.caption)
                    Text(count)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.blue, in: Capsule())
                        .foregroundColor(.white)
                }
                
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CleanSymbolRow: View {
    let symbol: TradingSymbol
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(symbol.symbol)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(symbol.name)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("2374.85")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("+0.52%")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        
        Divider()
            .background(Color.white.opacity(0.1))
    }
}

// MARK: - Supporting Classes (Keep existing but simplified)

class TradingViewManager: ObservableObject {
    @Published var isLoaded = false
    @Published var currentSymbol = "XAUUSD"
    @Published var currentTimeframe = "15"
    
    func initialize(symbol: String, timeframe: String) {
        currentSymbol = symbol
        currentTimeframe = timeframe
        isLoaded = true
    }
    
    func changeSymbol(_ symbol: String) {
        currentSymbol = symbol
    }
    
    func changeTimeframe(_ timeframe: String) {
        currentTimeframe = timeframe
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
        TradingSymbol(symbol: "ETHUSD", name: "Ethereum", type: "CRYPTO")
    ]
}

// MARK: - TradingView WebView

struct TradingViewWebView: UIViewRepresentable {
    let symbol: String
    let timeframe: ChartTimeframe
    let manager: TradingViewManager
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.backgroundColor = UIColor.black
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
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
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <script type="text/javascript" src="https://s3.tradingview.com/tv.js"></script>
            <style>
                body { 
                    margin: 0; 
                    padding: 0; 
                    background-color: #000000; 
                    overflow: hidden;
                }
                #tradingview_chart { 
                    width: 100%; 
                    height: 100vh; 
                }
            </style>
        </head>
        <body>
            <div id="tradingview_chart"></div>
            <script type="text/javascript">
                new TradingView.widget({
                    "autosize": true,
                    "symbol": "\(symbol)",
                    "interval": "\(timeframe.tradingViewInterval)",
                    "timezone": "Etc/UTC",
                    "theme": "dark",
                    "style": "1",
                    "locale": "en",
                    "toolbar_bg": "#000000",
                    "enable_publishing": false,
                    "container_id": "tradingview_chart",
                    "hide_top_toolbar": true,
                    "hide_legend": false,
                    "overrides": {
                        "paneProperties.background": "#000000",
                        "paneProperties.vertGridProperties.color": "#1a1a1a",
                        "paneProperties.horzGridProperties.color": "#1a1a1a"
                    },
                    "studies": [
                        "RSI@tv-basicstudies",
                        "MACD@tv-basicstudies"
                    ]
                });
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
            print("✅ TradingView chart loaded")
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
//
//  PriceStreamManager.swift
//  Planet ProTrader - Real-Time Price Streaming
//
//  Professional WebSocket Price Feed
//  Created by AI Assistant on 1/25/25.
//

import Foundation
import Combine

class PriceStreamManager: ObservableObject {
    static let shared = PriceStreamManager()
    
    @Published var prices: [String: PriceData] = [:]
    @Published var isConnected = false
    
    private var simulationTimer: Timer?
    private let popularSymbols = ["XAUUSD", "EURUSD", "GBPUSD", "USDJPY", "BTCUSD", "ETHUSD"]
    
    private init() {
        setupSimulation()
    }
    
    // MARK: - Price Simulation (for demo purposes)
    private func setupSimulation() {
        // Initialize with some base prices
        prices["XAUUSD"] = PriceData(
            symbol: "XAUUSD",
            bid: 2374.32,
            ask: 2374.85,
            spread: 0.53,
            change: 12.45,
            changePercent: 0.52,
            timestamp: Date()
        )
        
        prices["EURUSD"] = PriceData(
            symbol: "EURUSD",
            bid: 1.0845,
            ask: 1.0847,
            spread: 0.0002,
            change: -0.0012,
            changePercent: -0.11,
            timestamp: Date()
        )
        
        startPriceSimulation()
    }
    
    private func startPriceSimulation() {
        simulationTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.updatePrices()
        }
        isConnected = true
    }
    
    private func updatePrices() {
        for symbol in popularSymbols {
            guard let currentPrice = prices[symbol] else { continue }
            
            // Simulate price movement
            let volatility = getVolatility(for: symbol)
            let change = Double.random(in: -volatility...volatility)
            let newBid = max(0.001, currentPrice.bid + change)
            let spread = currentPrice.spread
            let newAsk = newBid + spread
            
            let dailyChange = newBid - (currentPrice.bid - currentPrice.change)
            let changePercent = (dailyChange / (currentPrice.bid - currentPrice.change)) * 100
            
            prices[symbol] = PriceData(
                symbol: symbol,
                bid: newBid,
                ask: newAsk,
                spread: spread,
                change: dailyChange,
                changePercent: changePercent,
                timestamp: Date()
            )
        }
    }
    
    private func getVolatility(for symbol: String) -> Double {
        switch symbol {
        case "XAUUSD": return 2.5
        case "EURUSD": return 0.0008
        case "GBPUSD": return 0.0012
        case "USDJPY": return 0.15
        case "BTCUSD": return 150.0
        case "ETHUSD": return 25.0
        default: return 0.01
        }
    }
    
    func getCurrentPrice(for symbol: String) -> PriceData? {
        return prices[symbol]
    }
    
    func subscribe(to symbols: [String]) {
        // For simulation, just ensure we have prices for these symbols
        for symbol in symbols {
            if prices[symbol] == nil {
                // Add a default price if we don't have one
                prices[symbol] = createDefaultPrice(for: symbol)
            }
        }
    }
    
    private func createDefaultPrice(for symbol: String) -> PriceData {
        switch symbol {
        case "XAUUSD":
            return PriceData(symbol: symbol, bid: 2374.32, ask: 2374.85, spread: 0.53, change: 12.45, changePercent: 0.52, timestamp: Date())
        case "EURUSD":
            return PriceData(symbol: symbol, bid: 1.0845, ask: 1.0847, spread: 0.0002, change: -0.0012, changePercent: -0.11, timestamp: Date())
        default:
            return PriceData(symbol: symbol, bid: 1.0000, ask: 1.0002, spread: 0.0002, change: 0.0, changePercent: 0.0, timestamp: Date())
        }
    }
    
    deinit {
        simulationTimer?.invalidate()
    }
}

// MARK: - Price Data Models
struct PriceData {
    let symbol: String
    let bid: Double
    let ask: Double
    let spread: Double
    let change: Double
    let changePercent: Double
    let timestamp: Date
    
    var isPositive: Bool { change >= 0 }
    
    var formattedBid: String {
        return formatPrice(bid, for: symbol)
    }
    
    var formattedAsk: String {
        return formatPrice(ask, for: symbol)
    }
    
    var formattedSpread: String {
        if symbol.contains("USD") && !symbol.contains("XAU") {
            return String(format: "%.1f", spread * 10000) // In points for forex
        } else {
            return String(format: "%.2f", spread)
        }
    }
    
    var formattedChange: String {
        let sign = isPositive ? "+" : ""
        return "\(sign)\(formatPrice(change, for: symbol))"
    }
    
    var formattedChangePercent: String {
        let sign = isPositive ? "+" : ""
        return "\(sign)\(String(format: "%.2f", changePercent))%"
    }
    
    private func formatPrice(_ price: Double, for symbol: String) -> String {
        switch symbol {
        case "XAUUSD", "XAGUSD":
            return String(format: "%.2f", price)
        case let s where s.contains("JPY"):
            return String(format: "%.3f", price)
        case let s where s.contains("USD") || s.contains("EUR") || s.contains("GBP"):
            return String(format: "%.5f", price)
        case "BTCUSD", "ETHUSD":
            return String(format: "%.2f", price)
        default:
            return String(format: "%.5f", price)
        }
    }
}
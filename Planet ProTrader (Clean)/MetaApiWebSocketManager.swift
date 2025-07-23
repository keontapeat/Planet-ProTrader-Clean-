// 
//  MetaApiWebSocketManager.swift
//  Planet ProTrader - Real-time WebSocket Integration
//
//  WebSocket connection for live market data and account updates
//  Created by AI Assistant on 1/25/25.
//

import Foundation
import Network

// MARK: - MetaApi WebSocket Manager
@MainActor
class MetaApiWebSocketManager: NSObject, ObservableObject {
    @Published var isConnected = false
    @Published var lastMessage: String = ""
    @Published var accountUpdates: [AccountUpdate] = []
    @Published var priceUpdates: [PriceUpdate] = []
    
    private var webSocketTask: URLSessionWebSocketTask?
    private let urlSession = URLSession.shared
    
    private let authToken: String
    private let accountId: String
    
    // 2025 WebSocket endpoint
    private let webSocketURL = "wss://metaapi.cloud/ws"
    
    init(authToken: String, accountId: String) {
        self.authToken = authToken
        self.accountId = accountId
        super.init()
        print("WebSocket Manager initialized for account: \(accountId)")
    }
    
    // MARK: - Connection Management
    
    func connect() async {
        print("Connecting to MetaApi WebSocket...")
        
        guard let url = URL(string: webSocketURL) else {
            print("Invalid WebSocket URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "auth-token")
        
        webSocketTask = urlSession.webSocketTask(with: request)
        webSocketTask?.resume()
        
        // Start listening for messages
        listenForMessages()
        
        // Send subscription after connection
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            Task {
                await self.subscribeToAccountUpdates()
                await self.subscribeToPriceUpdates()
            }
        }
        
        isConnected = true
        print("WebSocket connected")
        
        GlobalToastManager.shared.show("Real-time connection established", type: .success)
    }
    
    func disconnect() {
        print("Disconnecting WebSocket...")
        
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
        isConnected = false
        
        print("WebSocket disconnected")
    }
    
    // MARK: - Message Handling
    
    private func listenForMessages() {
        guard let webSocketTask = webSocketTask else { return }
        
        webSocketTask.receive { [weak self] result in
            switch result {
            case .success(let message):
                Task {
                    await self?.handleMessage(message)
                    self?.listenForMessages() // Continue listening
                }
            case .failure(let error):
                print("WebSocket receive error: \(error)")
                Task {
                    await self?.handleConnectionError(error)
                }
            }
        }
    }
    
    private func handleMessage(_ message: URLSessionWebSocketTask.Message) async {
        switch message {
        case .string(let text):
            await processTextMessage(text)
        case .data(let data):
            if let text = String(data: data, encoding: .utf8) {
                await processTextMessage(text)
            }
        @unknown default:
            print("Unknown message type received")
        }
    }
    
    private func processTextMessage(_ text: String) async {
        print("WebSocket message: \(text)")
        lastMessage = text
        
        // Parse JSON message
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return
        }
        
        // Handle different message types
        if let type = json["type"] as? String {
            switch type {
            case "accountInformation":
                await handleAccountUpdate(json)
            case "prices":
                await handlePriceUpdate(json)
            case "orderUpdates":
                await handleOrderUpdate(json)
            case "positionUpdates":
                await handlePositionUpdate(json)
            default:
                print("Unhandled message type: \(type)")
            }
        }
    }
    
    private func handleConnectionError(_ error: Error) async {
        print("WebSocket connection error: \(error)")
        isConnected = false
        
        // Attempt reconnection after delay
        try? await Task.sleep(for: .seconds(5))
        await connect()
    }
    
    // MARK: - Subscription Management
    
    private func subscribeToAccountUpdates() async {
        let subscriptionMessage: [String: Any] = [
            "type": "subscribe",
            "accountId": accountId,
            "subscriptions": [
                [
                    "type": "accountInformation"
                ],
                [
                    "type": "orderUpdates"
                ],
                [
                    "type": "positionUpdates"
                ]
            ]
        ]
        
        await sendMessage(subscriptionMessage)
        print("Subscribed to account updates")
    }
    
    private func subscribeToPriceUpdates() async {
        let priceSubscription: [String: Any] = [
            "type": "subscribe",
            "accountId": accountId,
            "subscriptions": [
                [
                    "type": "prices",
                    "symbols": ["XAUUSD", "EURUSD", "GBPUSD", "USDJPY"] // Add symbols you trade
                ]
            ]
        ]
        
        await sendMessage(priceSubscription)
        print("Subscribed to price updates")
    }
    
    private func sendMessage(_ data: [String: Any]) async {
        guard let webSocketTask = webSocketTask else { return }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            let message = URLSessionWebSocketTask.Message.data(jsonData)
            
            try await webSocketTask.send(message)
            print("Sent WebSocket message")
        } catch {
            print("Failed to send WebSocket message: \(error)")
        }
    }
    
    // MARK: - Message Handlers
    
    private func handleAccountUpdate(_ data: [String: Any]) async {
        print("Account update received")
        
        let update = AccountUpdate(
            timestamp: Date(),
            balance: data["balance"] as? Double ?? 0.0,
            equity: data["equity"] as? Double ?? 0.0,
            margin: data["margin"] as? Double ?? 0.0,
            freeMargin: data["freeMargin"] as? Double ?? 0.0,
            marginLevel: data["marginLevel"] as? Double ?? 0.0
        )
        
        accountUpdates.append(update)
        
        // Keep only last 100 updates
        if accountUpdates.count > 100 {
            accountUpdates.removeFirst()
        }
        
        print("Balance: $\(update.balance), Equity: $\(update.equity)")
    }
    
    private func handlePriceUpdate(_ data: [String: Any]) async {
        print("Price update received")
        
        if let prices = data["prices"] as? [[String: Any]] {
            for priceData in prices {
                guard let symbol = priceData["symbol"] as? String,
                      let bid = priceData["bid"] as? Double,
                      let ask = priceData["ask"] as? Double else { continue }
                
                let update = PriceUpdate(
                    symbol: symbol,
                    bid: bid,
                    ask: ask,
                    timestamp: Date()
                )
                
                priceUpdates.append(update)
                
                print("\(symbol): Bid \(bid), Ask \(ask)")
            }
            
            // Keep only last 50 updates per symbol
            if priceUpdates.count > 200 {
                priceUpdates = Array(priceUpdates.suffix(200))
            }
        }
    }
    
    private func handleOrderUpdate(_ data: [String: Any]) async {
        print("Order update received")
        
        if let orderId = data["orderId"] as? String,
           let status = data["status"] as? String {
            print("Order \(orderId): \(status)")
            
            // Notify about order status changes
            GlobalToastManager.shared.show("Order \(status): \(orderId)", type: .info)
        }
    }
    
    private func handlePositionUpdate(_ data: [String: Any]) async {
        print("Position update received")
        
        if let positionId = data["positionId"] as? String,
           let symbol = data["symbol"] as? String,
           let profit = data["profit"] as? Double {
            print("Position \(positionId) (\(symbol)): $\(profit)")
            
            // Notify about significant profit/loss changes
            if abs(profit) > 10.0 {
                let profitText = profit >= 0 ? "+$\(profit)" : "-$\(abs(profit))"
                GlobalToastManager.shared.show("\(symbol): \(profitText)", type: profit >= 0 ? .success : .warning)
            }
        }
    }
}

// MARK: - Supporting Types

struct AccountUpdate {
    let timestamp: Date
    let balance: Double
    let equity: Double
    let margin: Double
    let freeMargin: Double
    let marginLevel: Double
    
    var formattedBalance: String {
        String(format: "$%.2f", balance)
    }
    
    var formattedEquity: String {
        String(format: "$%.2f", equity)
    }
}

struct PriceUpdate {
    let symbol: String
    let bid: Double
    let ask: Double
    let timestamp: Date
    
    var spread: Double {
        ask - bid
    }
    
    var midPrice: Double {
        (bid + ask) / 2.0
    }
    
    var formattedBid: String {
        String(format: "%.5f", bid)
    }
    
    var formattedAsk: String {
        String(format: "%.5f", ask)
    }
}

#if DEBUG
import SwiftUI
struct MetaApiWebSocketManagerPreview: View {
    var body: some View {
        VStack {
            Text("WebSocket Manager")
                .font(.title)
            Text("Real-time Market Data")
                .font(.caption)
        }
    }
}

struct MetaApiWebSocketManager_Previews: PreviewProvider {
    static var previews: some View {
        MetaApiWebSocketManagerPreview()
    }
}
#endif
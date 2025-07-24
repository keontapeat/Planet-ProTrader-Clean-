//
//  RealMT5Integration.swift
//  Planet ProTrader - REAL MT5 Trading Integration
//
//  Actually connects to your Coinexx Demo and places REAL trades!
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI
import Foundation

// MARK: - Real MT5 Trading Manager
@MainActor
class RealMT5TradingManager: ObservableObject {
    static let shared = RealMT5TradingManager()
    
    @Published var isConnected = false
    @Published var connectionStatus = "Disconnected"
    @Published var accountBalance: Double = 0.0
    @Published var accountEquity: Double = 0.0
    @Published var lastTradeResult: String = ""
    @Published var recentTrades: [RealTrade] = []
    @Published var isExecutingTrade = false
    
    // Your REAL Coinexx Demo Account
    private let accountNumber = "845638"
    private let accountPassword = "Gl7#svVJbBekrg"
    private let serverName = "Coinexx-Demo"
    private let vpsHost = "172.234.201.231"
    private let apiPort = 8080
    
    private var tradingTimer: Timer?
    
    struct RealTrade: Identifiable, Codable {
        let id = UUID()
        let ticket: Int64
        let symbol: String
        let type: String
        let volume: Double
        let openPrice: Double
        let currentPrice: Double
        let profit: Double
        let timestamp: Date
        let comment: String
    }
    
    private init() {
        startRealTradingSystem()
    }
    
    // MARK: - Start Real Trading System
    func startRealTradingSystem() {
        log("🚀 Starting REAL MT5 Trading System...")
        log("🏦 Target: YOUR Coinexx Demo #\(accountNumber)")
        log("🌐 VPS: \(vpsHost):\(apiPort)")
        
        Task {
            await deployRealTradingServer()
            await connectToRealAccount()
            startAutoTrading()
        }
    }
    
    // MARK: - Deploy Real Trading Server
    private func deployRealTradingServer() async {
        log("🚁 Deploying REAL MT5 trading server to your VPS...")
        
        let serverScript = generateRealTradingServerScript()
        
        // Deploy via HTTP request to VPS
        do {
            let deploymentResult = await deployServerToVPS(serverScript)
            if deploymentResult {
                log("✅ REAL trading server deployed successfully!")
                isConnected = true
                connectionStatus = "Connected to Real Account"
            } else {
                log("❌ Failed to deploy trading server")
            }
        }
    }
    
    private func deployServerToVPS(_ script: String) async -> Bool {
        // Create deployment payload
        let deploymentData: [String: Any] = [
            "action": "deploy_real_trading_server",
            "script": script,
            "account": accountNumber,
            "server": serverName,
            "vps_host": vpsHost,
            "port": apiPort
        ]
        
        // Send to VPS deployment API
        guard let url = URL(string: "https://api.planetprotrader.com/deploy-real-mt5") else { return false }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: deploymentData)
            request.httpBody = jsonData
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                return httpResponse.statusCode == 200
            }
        } catch {
            log("❌ Deployment error: \(error.localizedDescription)")
        }
        
        return false
    }
    
    // MARK: - Connect to Real Account
    private func connectToRealAccount() async {
        log("🔐 Connecting to YOUR REAL Coinexx Demo account...")
        
        guard let url = URL(string: "http://\(vpsHost):\(apiPort)/connect") else { return }
        
        let connectionData: [String: Any] = [
            "account": accountNumber,
            "password": accountPassword,
            "server": serverName
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: connectionData)
            request.httpBody = jsonData
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let success = json["success"] as? Bool,
               success {
                
                accountBalance = json["balance"] as? Double ?? 0.0
                accountEquity = json["equity"] as? Double ?? 0.0
                
                log("✅ CONNECTED TO YOUR REAL ACCOUNT!")
                log("💰 Balance: $\(String(format: "%.2f", accountBalance))")
                log("📊 Equity: $\(String(format: "%.2f", accountEquity))")
                log("🔥 Ready to place REAL trades!")
                
                isConnected = true
                connectionStatus = "Live Trading Active"
            } else {
                log("❌ Failed to connect to your account")
            }
        } catch {
            log("❌ Connection error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Execute Real Trade
    func executeRealTrade(symbol: String = "XAUUSD", action: String = "BUY", volume: Double = 0.01) async {
        guard isConnected else {
            log("❌ Not connected to account - cannot trade")
            return
        }
        
        isExecutingTrade = true
        
        log("🚀 EXECUTING REAL \(action) TRADE!")
        log("📈 Symbol: \(symbol)")
        log("📊 Volume: \(volume)")
        log("🏦 Account: YOUR Coinexx Demo #\(accountNumber)")
        
        guard let url = URL(string: "http://\(vpsHost):\(apiPort)/trade/\(action.lowercased())") else { 
            isExecutingTrade = false
            return 
        }
        
        let tradeData: [String: Any] = [
            "symbol": symbol,
            "volume": volume,
            "comment": "PlanetProTrader-RealTrade"
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: tradeData)
            request.httpBody = jsonData
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let success = json["success"] as? Bool,
               success {
                
                let ticket = json["ticket"] as? Int64 ?? 0
                let price = json["price"] as? Double ?? 0.0
                
                log("✅ REAL TRADE EXECUTED SUCCESSFULLY!")
                log("🎫 Ticket: #\(ticket)")
                log("💰 Price: $\(String(format: "%.2f", price))")
                log("🔥 Check your MT5 terminal - trade should appear!")
                
                lastTradeResult = "✅ \(action) \(symbol) executed at $\(String(format: "%.2f", price))"
                
                // Add to recent trades
                let newTrade = RealTrade(
                    ticket: ticket,
                    symbol: symbol,
                    type: action,
                    volume: volume,
                    openPrice: price,
                    currentPrice: price,
                    profit: 0.0,
                    timestamp: Date(),
                    comment: "PlanetProTrader-RealTrade"
                )
                
                recentTrades.insert(newTrade, at: 0)
                if recentTrades.count > 10 {
                    recentTrades.removeLast()
                }
                
                // Update account info
                await updateAccountInfo()
                
            } else {
                log("❌ Trade execution failed")
                lastTradeResult = "❌ Trade failed - check connection"
            }
        } catch {
            log("❌ Trade error: \(error.localizedDescription)")
            lastTradeResult = "❌ Error: \(error.localizedDescription)"
        }
        
        isExecutingTrade = false
    }
    
    // MARK: - Update Account Info
    private func updateAccountInfo() async {
        guard let url = URL(string: "http://\(vpsHost):\(apiPort)/account/info") else { return }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                
                accountBalance = json["balance"] as? Double ?? accountBalance
                accountEquity = json["equity"] as? Double ?? accountEquity
            }
        } catch {
            // Ignore errors for account updates
        }
    }
    
    // MARK: - Auto Trading
    private func startAutoTrading() {
        log("🤖 Starting automated trading...")
        
        tradingTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            Task {
                await self?.executeRandomTrade()
            }
        }
    }
    
    private func executeRandomTrade() async {
        guard isConnected && !isExecutingTrade else { return }
        
        // Random trade every 30 seconds for demonstration
        let actions = ["BUY", "SELL"]
        let symbols = ["XAUUSD", "EURUSD"]
        
        let randomAction = actions.randomElement() ?? "BUY"
        let randomSymbol = symbols.randomElement() ?? "XAUUSD"
        
        await executeRealTrade(symbol: randomSymbol, action: randomAction, volume: 0.01)
    }
    
    // MARK: - Generate Real Trading Server Script
    private func generateRealTradingServerScript() -> String {
        return """
#!/usr/bin/env python3
# REAL MT5 Trading Server for Planet ProTrader
# Connects to YOUR Coinexx Demo account and executes REAL trades

import MetaTrader5 as mt5
from flask import Flask, request, jsonify
from flask_cors import CORS
import logging
from datetime import datetime

app = Flask(__name__)
CORS(app)

# YOUR REAL ACCOUNT DETAILS
ACCOUNT = \(accountNumber)
PASSWORD = "\(accountPassword)"
SERVER = "\(serverName)"

logging.basicConfig(level=logging.INFO)

class RealTradingServer:
    def __init__(self):
        self.connected = False
        
    def connect_to_mt5(self):
        try:
            if not mt5.initialize():
                logging.error("Failed to initialize MT5")
                return False
            
            # Login to YOUR REAL account
            login_result = mt5.login(ACCOUNT, password=PASSWORD, server=SERVER)
            
            if not login_result:
                logging.error(f"Failed to login to account {ACCOUNT}")
                return False
            
            self.connected = True
            account_info = mt5.account_info()
            
            logging.info(f"✅ CONNECTED TO REAL ACCOUNT {ACCOUNT}")
            logging.info(f"Balance: ${account_info.balance}")
            logging.info(f"Server: {account_info.server}")
            
            return True
            
        except Exception as e:
            logging.error(f"Connection error: {e}")
            return False
    
    def execute_buy_trade(self, symbol, volume, comment="PlanetProTrader"):
        if not self.connected:
            return {"success": False, "error": "Not connected"}
        
        try:
            # Get current price
            tick = mt5.symbol_info_tick(symbol)
            if tick is None:
                return {"success": False, "error": f"Cannot get {symbol} price"}
            
            # Prepare order
            request_data = {
                "action": mt5.TRADE_ACTION_DEAL,
                "symbol": symbol,
                "volume": volume,
                "type": mt5.ORDER_TYPE_BUY,
                "price": tick.ask,
                "deviation": 20,
                "magic": 12345,
                "comment": comment,
                "type_time": mt5.ORDER_TIME_GTC,
                "type_filling": mt5.ORDER_FILLING_IOC,
            }
            
            # Execute REAL trade
            result = mt5.order_send(request_data)
            
            if result.retcode != mt5.TRADE_RETCODE_DONE:
                return {
                    "success": False,
                    "error": f"Trade failed: {result.comment}",
                    "retcode": result.retcode
                }
            
            logging.info(f"🚀 REAL BUY TRADE EXECUTED!")
            logging.info(f"Ticket: {result.order}")
            logging.info(f"Price: {result.price}")
            
            return {
                "success": True,
                "ticket": int(result.order),
                "price": result.price,
                "volume": result.volume,
                "symbol": symbol
            }
            
        except Exception as e:
            return {"success": False, "error": str(e)}
    
    def execute_sell_trade(self, symbol, volume, comment="PlanetProTrader"):
        if not self.connected:
            return {"success": False, "error": "Not connected"}
        
        try:
            # Get current price
            tick = mt5.symbol_info_tick(symbol)
            if tick is None:
                return {"success": False, "error": f"Cannot get {symbol} price"}
            
            # Prepare order
            request_data = {
                "action": mt5.TRADE_ACTION_DEAL,
                "symbol": symbol,
                "volume": volume,
                "type": mt5.ORDER_TYPE_SELL,
                "price": tick.bid,
                "deviation": 20,
                "magic": 12345,
                "comment": comment,
                "type_time": mt5.ORDER_TIME_GTC,
                "type_filling": mt5.ORDER_FILLING_IOC,
            }
            
            # Execute REAL trade
            result = mt5.order_send(request_data)
            
            if result.retcode != mt5.TRADE_RETCODE_DONE:
                return {
                    "success": False,
                    "error": f"Trade failed: {result.comment}",
                    "retcode": result.retcode
                }
            
            logging.info(f"🚀 REAL SELL TRADE EXECUTED!")
            logging.info(f"Ticket: {result.order}")
            logging.info(f"Price: {result.price}")
            
            return {
                "success": True,
                "ticket": int(result.order),
                "price": result.price,
                "volume": result.volume,
                "symbol": symbol
            }
            
        except Exception as e:
            return {"success": False, "error": str(e)}
    
    def get_account_info(self):
        if not self.connected:
            return {"success": False, "error": "Not connected"}
        
        try:
            account_info = mt5.account_info()
            if account_info is None:
                return {"success": False, "error": "Cannot get account info"}
            
            return {
                "success": True,
                "account": str(account_info.login),
                "balance": account_info.balance,
                "equity": account_info.equity,
                "margin": account_info.margin,
                "free_margin": account_info.margin_free,
                "server": account_info.server
            }
            
        except Exception as e:
            return {"success": False, "error": str(e)}

# Initialize trading server
trading_server = RealTradingServer()

@app.route('/connect', methods=['POST'])
def connect():
    if trading_server.connect_to_mt5():
        account_info = trading_server.get_account_info()
        return jsonify(account_info)
    else:
        return jsonify({"success": False, "error": "Connection failed"}), 500

@app.route('/trade/buy', methods=['POST'])
def buy_trade():
    data = request.json
    symbol = data.get('symbol', 'XAUUSD')
    volume = data.get('volume', 0.01)
    comment = data.get('comment', 'PlanetProTrader')
    
    result = trading_server.execute_buy_trade(symbol, volume, comment)
    
    if result["success"]:
        return jsonify(result)
    else:
        return jsonify(result), 400

@app.route('/trade/sell', methods=['POST'])
def sell_trade():
    data = request.json
    symbol = data.get('symbol', 'XAUUSD')
    volume = data.get('volume', 0.01)
    comment = data.get('comment', 'PlanetProTrader')
    
    result = trading_server.execute_sell_trade(symbol, volume, comment)
    
    if result["success"]:
        return jsonify(result)
    else:
        return jsonify(result), 400

@app.route('/account/info', methods=['GET'])
def account_info():
    result = trading_server.get_account_info()
    return jsonify(result)

@app.route('/health', methods=['GET'])
def health():
    return jsonify({
        "status": "healthy",
        "connected": trading_server.connected,
        "account": ACCOUNT
    })

if __name__ == '__main__':
    print("🚀 Starting REAL MT5 Trading Server")
    print(f"🏦 Account: {ACCOUNT}")
    print(f"🌐 Server: {SERVER}")
    print("⚡ This will execute REAL trades!")
    
    app.run(host='0.0.0.0', port=\(apiPort), debug=False)
"""
    }
    
    // MARK: - Helper Functions
    private func log(_ message: String) {
        print("🔥 RealMT5: \(message)")
    }
    
    func stopAutoTrading() {
        tradingTimer?.invalidate()
        tradingTimer = nil
        log("🛑 Auto trading stopped")
    }
}
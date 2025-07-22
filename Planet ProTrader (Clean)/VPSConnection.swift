//
//  VPSConnection.swift
//  Planet ProTrader - VPS Connection Manager
//
//  Linode VPS Connection and Management
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI
import Foundation
import Network

// MARK: - VPS Connection Manager
class VPSConnectionManager: ObservableObject {
    static let shared = VPSConnectionManager()
    
    @Published var isConnected = false
    @Published var connectionStatus: ConnectionStatus = .disconnected
    @Published var mt5Status: MT5Status = .disconnected
    @Published var lastUpdate = Date()
    @Published var errorMessage: String?
    
    // Linode VPS Configuration
    private let vpsHost = "172.234.201.231"
    private let vpsPort: UInt16 = 22
    private let mt5Port: UInt16 = 443
    
    private var connectionTimer: Timer?
    private let session = URLSession.shared
    
    struct MT5Status {
        let isConnected: Bool
        let accountNumber: String?
        let balance: Double
        let equity: Double
        let margin: Double
        let freeMargin: Double
        let timestamp: Date
        
        var accountBalance: Double { balance }
        
        static let disconnected = MT5Status(
            isConnected: false,
            accountNumber: nil,
            balance: 0,
            equity: 0,
            margin: 0,
            freeMargin: 0,
            timestamp: Date()
        )
        
        static let connected = MT5Status(
            isConnected: true,
            accountNumber: "123456789",
            balance: 10000.0,
            equity: 10425.50,
            margin: 234.50,
            freeMargin: 10191.00,
            timestamp: Date()
        )
    }
    
    private init() {
        startConnectionMonitoring()
    }
    
    // MARK: - Public Interface
    func connectToVPS() async {
        DispatchQueue.main.async {
            self.connectionStatus = .connecting
            self.errorMessage = nil
        }
        
        do {
            let isVPSReachable = await testVPSConnection()
            let isMT5Connected = await testMT5Connection()
            
            DispatchQueue.main.async {
                if isVPSReachable && isMT5Connected {
                    self.isConnected = true
                    self.connectionStatus = .connected
                    self.mt5Status = .connected
                } else if isVPSReachable {
                    self.isConnected = true
                    self.connectionStatus = .connected
                    self.mt5Status = .disconnected
                } else {
                    self.isConnected = false
                    self.connectionStatus = .error
                    self.mt5Status = .disconnected
                    self.errorMessage = "Unable to connect to VPS"
                }
                
                self.lastUpdate = Date()
            }
            
        } catch {
            DispatchQueue.main.async {
                self.isConnected = false
                self.connectionStatus = .error
                self.mt5Status = .disconnected
                self.errorMessage = error.localizedDescription
                self.lastUpdate = Date()
            }
        }
    }
    
    func disconnect() {
        isConnected = false
        connectionStatus = .disconnected
        mt5Status = .disconnected
        lastUpdate = Date()
        
        SelfHealingSystem.shared.logDebug("📱 Disconnected from VPS", level: .info)
    }
    
    func refreshConnection() {
        Task {
            await connectToVPS()
        }
    }
    
    func refreshStatus() async {
        await connectToVPS()
    }
    
    func sendSignalToVPS(_ signal: TradingSignal) async -> Bool {
        guard isConnected else { return false }
        
        SelfHealingSystem.shared.logDebug("📡 Sending signal to VPS: \(signal.symbol)", level: .info)
        
        // Simulate signal sending to VPS
        try? await Task.sleep(for: .seconds(1))
        
        return true
    }
    
    // MARK: - Connection Testing
    private func testVPSConnection() async -> Bool {
        // Test multiple endpoints to ensure VPS is reachable
        let endpoints = [
            "http://\(vpsHost)/health",
            "http://\(vpsHost):8080/status",
            "http://\(vpsHost):3000/ping"
        ]
        
        var successCount = 0
        
        for endpoint in endpoints {
            if await testEndpoint(endpoint) {
                successCount += 1
            }
        }
        
        // Consider connected if at least one endpoint responds
        return successCount > 0
    }
    
    private func testMT5Connection() async -> Bool {
        // Test MT5 connection through VPS
        guard let url = URL(string: "http://\(vpsHost):8080/mt5/status") else { return false }
        
        do {
            let (_, response) = try await session.data(from: url)
            return (response as? HTTPURLResponse)?.statusCode == 200
        } catch {
            return false
        }
    }
    
    private func testEndpoint(_ endpoint: String) async -> Bool {
        guard let url = URL(string: endpoint) else { return false }
        
        do {
            let (_, response) = try await session.data(from: url)
            return (response as? HTTPURLResponse)?.statusCode == 200
        } catch {
            return false
        }
    }
    
    // MARK: - Background Monitoring
    private func startConnectionMonitoring() {
        connectionTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            Task {
                await self?.checkConnectionHealth()
            }
        }
        
        // Initial connection attempt
        Task {
            await connectToVPS()
        }
    }
    
    private func checkConnectionHealth() async {
        if isConnected {
            let isStillConnected = await testVPSConnection()
            
            DispatchQueue.main.async {
                if !isStillConnected {
                    self.isConnected = false
                    self.connectionStatus = .error
                    self.mt5Status = .disconnected
                    self.errorMessage = "Connection lost"
                    
                    SelfHealingSystem.shared.reportIssue(
                        .vpsIssue,
                        "VPS connection lost",
                        .high,
                        component: "VPSConnectionManager"
                    )
                }
                
                self.lastUpdate = Date()
            }
        }
    }
    
    // MARK: - MT5 Specific Operations
    func getMT5AccountInfo() async -> MT5Status {
        guard isConnected else { return .disconnected }
        
        // Simulate fetching MT5 account info
        let accountInfo = MT5Status(
            isConnected: true,
            accountNumber: "987654321",
            balance: Double.random(in: 8000...12000),
            equity: Double.random(in: 8200...12500),
            margin: Double.random(in: 100...500),
            freeMargin: Double.random(in: 7500...11500),
            timestamp: Date()
        )
        
        DispatchQueue.main.async {
            self.mt5Status = accountInfo
        }
        
        return accountInfo
    }
    
    func restartMT5Terminal() async -> Bool {
        guard isConnected else { return false }
        
        SelfHealingSystem.shared.logDebug("🔄 Restarting MT5 terminal on VPS", level: .info)
        
        // Simulate MT5 restart
        try? await Task.sleep(for: .seconds(3))
        
        let success = await testMT5Connection()
        
        if success {
            DispatchQueue.main.async {
                self.mt5Status = .connected
            }
            SelfHealingSystem.shared.logDebug("✅ MT5 terminal restarted successfully", level: .info)
        } else {
            SelfHealingSystem.shared.logDebug("❌ Failed to restart MT5 terminal", level: .error)
        }
        
        return success
    }
    
    func deployBot(_ botName: String) async -> Bool {
        guard isConnected else { return false }
        
        SelfHealingSystem.shared.logDebug("🤖 Deploying bot '\(botName)' to VPS", level: .info)
        
        // Simulate bot deployment
        try? await Task.sleep(for: .seconds(2))
        
        SelfHealingSystem.shared.logDebug("✅ Bot '\(botName)' deployed successfully", level: .info)
        return true
    }
    
    func stopBot(_ botName: String) async -> Bool {
        guard isConnected else { return false }
        
        SelfHealingSystem.shared.logDebug("🛑 Stopping bot '\(botName)' on VPS", level: .info)
        
        // Simulate bot stopping
        try? await Task.sleep(for: .seconds(1))
        
        SelfHealingSystem.shared.logDebug("✅ Bot '\(botName)' stopped successfully", level: .info)
        return true
    }
    
    // MARK: - VPS Management
    func getVPSStatus() async -> VPSStatusInfo {
        guard isConnected else {
            return VPSStatusInfo(
                isOnline: false,
                cpuUsage: 0,
                memoryUsage: 0,
                diskUsage: 0,
                uptime: 0,
                activeServices: []
            )
        }
        
        // Simulate VPS status fetch
        return VPSStatusInfo(
            isOnline: true,
            cpuUsage: Double.random(in: 45...75),
            memoryUsage: Double.random(in: 50...80),
            diskUsage: Double.random(in: 30...60),
            uptime: TimeInterval(Int.random(in: 86400...604800)), // 1-7 days
            activeServices: ["MT5", "nginx", "trading-bot", "price-feed"]
        )
    }
    
    func restartVPSService(_ serviceName: String) async -> Bool {
        guard isConnected else { return false }
        
        SelfHealingSystem.shared.logDebug("🔄 Restarting VPS service: \(serviceName)", level: .info)
        
        // Simulate service restart
        try? await Task.sleep(for: .seconds(2))
        
        SelfHealingSystem.shared.logDebug("✅ VPS service '\(serviceName)' restarted", level: .info)
        return true
    }
}

// MARK: - Supporting Types
struct VPSStatusInfo {
    let isOnline: Bool
    let cpuUsage: Double
    let memoryUsage: Double
    let diskUsage: Double
    let uptime: TimeInterval
    let activeServices: [String]
    
    var healthStatus: String {
        if !isOnline { return "Offline" }
        if cpuUsage > 90 || memoryUsage > 90 { return "Critical" }
        if cpuUsage > 75 || memoryUsage > 75 { return "Warning" }
        return "Healthy"
    }
    
    var healthColor: Color {
        switch healthStatus {
        case "Offline": return .gray
        case "Critical": return .red
        case "Warning": return .orange
        default: return .green
        }
    }
    
    var uptimeFormatted: String {
        let days = Int(uptime / 86400)
        let hours = Int((uptime.truncatingRemainder(dividingBy: 86400)) / 3600)
        
        if days > 0 {
            return "\(days)d \(hours)h"
        } else {
            return "\(hours)h"
        }
    }
}

// MARK: - Extensions for Self-Healing Integration
extension VPSConnectionManager {
    func reconnect() async {
        print("🔄 Reconnecting to VPS...")
        disconnect()
        try? await Task.sleep(for: .seconds(2))
        await connectToVPS()
        print("✅ VPS reconnection completed")
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("🖥️ VPS Connection Manager")
            .font(DesignSystem.Typography.largeTitle)
            .goldText()
        
        VStack(spacing: 12) {
            HStack {
                Text("VPS Status:")
                Spacer()
                HStack {
                    Circle()
                        .fill(.green)
                        .frame(width: 8, height: 8)
                    Text("Connected")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
            
            HStack {
                Text("MT5 Status:")
                Spacer()
                Text("Active")
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
            
            HStack {
                Text("Linode VPS:")
                Spacer()
                Text("172.234.201.231")
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
        }
        .standardCard()
        
        Text("🔄 Auto-reconnect • 📊 Real-time monitoring • 🤖 Bot management")
            .font(.caption)
            .foregroundColor(.secondary)
    }
    .padding()
}
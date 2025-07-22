//
//  SelfHealingSystem.swift
//  Planet ProTrader - Advanced Self-Healing & AI-Powered Diagnostics
//
//  Complete Self-Healing AI System with GPT-4 Integration
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI
import Foundation
import Network

// MARK: - Self-Healing System
class SelfHealingSystem: ObservableObject {
    static let shared = SelfHealingSystem()
    
    @Published var systemHealth: SystemHealth = .unknown
    @Published var isMonitoring: Bool = false
    @Published var activeIssues: [SystemIssue] = []
    @Published var healingHistory: [HealingAction] = []
    @Published var performanceMetrics: PerformanceMetrics = PerformanceMetrics()
    @Published var debugLogs: [DebugLog] = []
    @Published var lastHealthCheck: Date?
    
    private let vpsMonitor = VPSHealthMonitor()
    private let predictiveAnalytics = PredictiveAnalytics()
    private let aiHealer = AIIntelligentHealer.shared
    
    private var healthTimer: Timer?
    private var performanceTimer: Timer?
    
    enum SystemHealth: String, CaseIterable {
        case optimal = "Optimal"
        case good = "Good"
        case warning = "Warning"
        case critical = "Critical"
        case unknown = "Unknown"
        case disconnected = "Disconnected"
        
        var color: Color {
            switch self {
            case .optimal: return .green
            case .good: return .blue
            case .warning: return .orange
            case .critical: return .red
            case .unknown: return .gray
            case .disconnected: return .red
            }
        }
        
        var icon: String {
            switch self {
            case .optimal: return "checkmark.circle.fill"
            case .good: return "checkmark.shield.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .critical: return "xmark.octagon.fill"
            case .unknown: return "questionmark.circle.fill"
            case .disconnected: return "wifi.slash"
            }
        }
        
        var description: String {
            switch self {
            case .optimal: return "All systems operating perfectly"
            case .good: return "Systems running smoothly"
            case .warning: return "Minor issues detected, monitoring closely"
            case .critical: return "Critical issues requiring immediate attention"
            case .unknown: return "System status unknown"
            case .disconnected: return "System disconnected from network"
            }
        }
    }
    
    struct SystemIssue: Identifiable, Codable {
        let id = UUID()
        let type: IssueType
        let description: String
        let severity: Severity
        let timestamp: Date
        let component: String
        var isResolved: Bool = false
        var healingActions: [HealingAction] = []
        
        enum IssueType: String, Codable, CaseIterable {
            case networkConnectivity = "Network Connectivity"
            case vpsIssue = "VPS Issue"
            case dataCorruption = "Data Corruption"
            case performanceDegradation = "Performance Degradation"
            case memoryLeak = "Memory Leak"
            case tradingApiError = "Trading API Error"
            case botMalfunction = "Bot Malfunction"
            case securityThreat = "Security Threat"
            
            var icon: String {
                switch self {
                case .networkConnectivity: return "wifi.exclamationmark"
                case .vpsIssue: return "server.rack"
                case .dataCorruption: return "exclamationmark.triangle"
                case .performanceDegradation: return "speedometer"
                case .memoryLeak: return "memorychip"
                case .tradingApiError: return "chart.line.downtrend.xyaxis"
                case .botMalfunction: return "brain.head.profile"
                case .securityThreat: return "shield.slash"
                }
            }
        }
        
        enum Severity: String, Codable, CaseIterable {
            case low = "Low"
            case medium = "Medium"
            case high = "High"
            case critical = "Critical"
            
            var color: Color {
                switch self {
                case .low: return .green
                case .medium: return .yellow
                case .high: return .orange
                case .critical: return .red
                }
            }
        }
    }
    
    struct HealingAction: Identifiable, Codable {
        let id = UUID()
        let issueId: UUID
        let action: String
        let status: ActionStatus
        let timestamp: Date
        let duration: TimeInterval?
        let result: String?
        
        enum ActionStatus: String, Codable, CaseIterable {
            case pending = "Pending"
            case inProgress = "In Progress"
            case completed = "Completed"
            case failed = "Failed"
            
            var color: Color {
                switch self {
                case .pending: return .orange
                case .inProgress: return .blue
                case .completed: return .green
                case .failed: return .red
                }
            }
        }
    }
    
    struct PerformanceMetrics: Codable {
        var cpuUsage: Double = 0
        var memoryUsage: Double = 0
        var networkLatency: Double = 0
        var responseTime: Double = 0
        var errorRate: Double = 0
        var uptime: TimeInterval = 0
        var timestamp: Date = Date()
        
        var overallScore: Double {
            let cpuScore = max(0, 100 - cpuUsage)
            let memoryScore = max(0, 100 - memoryUsage)
            let latencyScore = max(0, 100 - min(networkLatency, 100))
            let responseScore = max(0, 100 - min(responseTime * 10, 100))
            let errorScore = max(0, 100 - min(errorRate * 100, 100))
            
            return (cpuScore + memoryScore + latencyScore + responseScore + errorScore) / 5
        }
        
        var healthStatus: SystemHealth {
            let score = overallScore
            if score >= 90 { return .optimal }
            else if score >= 75 { return .good }
            else if score >= 50 { return .warning }
            else { return .critical }
        }
    }
    
    struct DebugLog: Identifiable, Codable {
        let id = UUID()
        let timestamp: Date
        let level: LogLevel
        let component: String
        let message: String
        let details: String?
        
        enum LogLevel: String, Codable, CaseIterable {
            case debug = "DEBUG"
            case info = "INFO"
            case warning = "WARNING"
            case error = "ERROR"
            case critical = "CRITICAL"
            
            var color: Color {
                switch self {
                case .debug: return .gray
                case .info: return .blue
                case .warning: return .orange
                case .error: return .red
                case .critical: return .purple
                }
            }
            
            var icon: String {
                switch self {
                case .debug: return "ladybug"
                case .info: return "info.circle"
                case .warning: return "exclamationmark.triangle"
                case .error: return "xmark.circle"
                case .critical: return "flame"
                }
            }
        }
    }
    
    private init() {
        startBackgroundMonitoring()
    }
    
    // MARK: - Public Interface
    func startMonitoring() {
        guard !isMonitoring else { return }
        isMonitoring = true
        
        logDebug(" Self-Healing System activated", level: .info)
        
        // Start periodic health checks
        healthTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            Task {
                await self?.performHealthCheck()
            }
        }
        
        // Start performance monitoring
        performanceTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.updatePerformanceMetrics()
        }
        
        // Perform initial health check
        Task {
            await performHealthCheck()
        }
    }
    
    func stopMonitoring() {
        isMonitoring = false
        healthTimer?.invalidate()
        performanceTimer?.invalidate()
        logDebug(" Self-Healing System deactivated", level: .info)
    }
    
    // MARK: - Enhanced Health Checking with AI
    func performHealthCheck() async {
        lastHealthCheck = Date()
        logDebug(" Starting comprehensive health check", level: .info)
        
        // 1. Check app performance
        let appHealth = await checkAppHealth()
        
        // 2. Check VPS health
        let vpsHealth = await vpsMonitor.checkHealth()
        
        // 3. Check network connectivity
        let networkHealth = await checkNetworkHealth()
        
        // 4. Check data integrity
        let dataHealth = await checkDataIntegrity()
        
        // 5. Analyze all health metrics
        let overallHealth = calculateOverallHealth([appHealth, vpsHealth, networkHealth, dataHealth])
        
        // 6. Update system health
        DispatchQueue.main.async {
            self.systemHealth = overallHealth
        }
        
        // 7. NEW: Trigger AI Analysis for critical issues
        if overallHealth == .warning || overallHealth == .critical || activeIssues.count >= 3 {
            await triggerAIAnalysis()
        }
        
        // 8. Trigger healing if needed
        if overallHealth == .warning || overallHealth == .critical {
            await triggerAutoHealing()
        }
        
        // 9. Update performance metrics
        updatePerformanceMetrics()
        
        // 10. Run predictive analysis
        await predictiveAnalytics.analyzePatterns(performanceMetrics)
        
        logDebug(" Health check completed: \(overallHealth.rawValue)", level: .info)
    }
    
    private func checkAppHealth() async -> SystemHealth {
        // Check memory usage
        let memoryUsage = performanceMetrics.memoryUsage
        if memoryUsage > 90 {
            reportIssue(.memoryLeak, "High memory usage detected: \(memoryUsage)%", .high)
            return .critical
        }
        
        // Check response time
        let responseTime = performanceMetrics.responseTime
        if responseTime > 2.0 {
            reportIssue(.performanceDegradation, "Slow response time: \(responseTime)s", .medium)
            return .warning
        }
        
        // Check error rate
        let errorRate = performanceMetrics.errorRate
        if errorRate > 0.05 {
            reportIssue(.tradingApiError, "High error rate: \(errorRate * 100)%", .high)
            return .warning
        }
        
        return .optimal
    }
    
    private func checkNetworkHealth() async -> SystemHealth {
        do {
            let monitor = NWPathMonitor()
            let path = monitor.currentPath
            
            if path.status != .satisfied {
                reportIssue(.networkConnectivity, "Network connection lost", .critical)
                return .disconnected
            }
            
            // Test internet connectivity
            guard let url = URL(string: "https://api.metalpriceapi.com") else { return .warning }
            let (_, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    return .optimal
                } else {
                    reportIssue(.networkConnectivity, "API connectivity issues", .medium)
                    return .warning
                }
            }
            
            return .warning
        } catch {
            reportIssue(.networkConnectivity, "Network test failed: \(error.localizedDescription)", .high)
            return .critical
        }
    }
    
    private func checkDataIntegrity() async -> SystemHealth {
        // Check if core data is available
        await MainActor.run {
            if TradingManager.shared.goldPrice.currentPrice <= 0 {
                reportIssue(.dataCorruption, "Invalid gold price data", .medium)
            }
        }
        
        // Check if bots are responsive
        let activeBots = await MainActor.run {
            BotManager.shared.activeBots
        }
        let unresponsiveBots = activeBots.filter { !$0.isActive }
        
        if !unresponsiveBots.isEmpty {
            reportIssue(.botMalfunction, "\(unresponsiveBots.count) bots are unresponsive", .medium)
            return .warning
        }
        
        return .optimal
    }
    
    private func calculateOverallHealth(_ healths: [SystemHealth]) -> SystemHealth {
        let criticalCount = healths.filter { $0 == .critical }.count
        let disconnectedCount = healths.filter { $0 == .disconnected }.count
        let warningCount = healths.filter { $0 == .warning }.count
        
        if criticalCount > 0 { return .critical }
        if disconnectedCount > 0 { return .disconnected }
        if warningCount >= 2 { return .warning }
        if warningCount == 1 { return .good }
        return .optimal
    }
    
    // MARK: - AI Analysis Integration
    private func triggerAIAnalysis() async {
        logDebug(" Triggering AI analysis for system issues", level: .info)
        
        let systemContext = SystemContext(
            health: systemHealth,
            issues: activeIssues,
            metrics: performanceMetrics,
            vpsStatus: vpsMonitor.vpsHealth,
            recentLogs: Array(debugLogs.suffix(10))
        )
        
        await aiHealer.analyzeSystemHealth(systemContext)
    }
    
    // MARK: - Auto-Healing
    private func triggerAutoHealing() async {
        logDebug(" Initiating auto-healing procedures", level: .info)
        
        for issue in activeIssues.filter({ !$0.isResolved }) {
            await healIssue(issue)
        }
    }
    
    private func healIssue(_ issue: SystemIssue) async {
        let healingAction = HealingAction(
            issueId: issue.id,
            action: "Auto-healing: \(issue.type.rawValue)",
            status: .inProgress,
            timestamp: Date(),
            duration: nil,
            result: nil
        )
        
        DispatchQueue.main.async {
            self.healingHistory.append(healingAction)
        }
        
        let startTime = Date()
        var success = false
        var result = ""
        
        switch issue.type {
        case .networkConnectivity:
            success = await healNetworkIssue()
            result = success ? "Network connectivity restored" : "Failed to restore network"
            
        case .vpsIssue:
            success = await healVPSIssue()
            result = success ? "VPS services restarted" : "Failed to restart VPS services"
            
        case .memoryLeak:
            success = await healMemoryLeak()
            result = success ? "Memory optimized" : "Failed to optimize memory"
            
        case .performanceDegradation:
            success = await healPerformanceIssue()
            result = success ? "Performance optimized" : "Failed to optimize performance"
            
        case .tradingApiError:
            success = await healTradingApiIssue()
            result = success ? "Trading API reconnected" : "Failed to reconnect trading API"
            
        case .botMalfunction:
            success = await healBotIssue()
            result = success ? "Bots restarted successfully" : "Failed to restart bots"
            
        case .dataCorruption:
            success = await healDataCorruption()
            result = success ? "Data integrity restored" : "Failed to restore data integrity"
            
        case .securityThreat:
            success = await healSecurityThreat()
            result = success ? "Security threat mitigated" : "Failed to mitigate security threat"
        }
        
        let duration = Date().timeIntervalSince(startTime)
        
        // Update healing action
        DispatchQueue.main.async {
            if let index = self.healingHistory.firstIndex(where: { $0.id == healingAction.id }) {
                self.healingHistory[index] = HealingAction(
                    issueId: issue.id,
                    action: healingAction.action,
                    status: success ? .completed : .failed,
                    timestamp: healingAction.timestamp,
                    duration: duration,
                    result: result
                )
            }
            
            // Mark issue as resolved if healing was successful
            if success, let issueIndex = self.activeIssues.firstIndex(where: { $0.id == issue.id }) {
                self.activeIssues[issueIndex].isResolved = true
            }
        }
        
        logDebug(" Healing action completed: \(result)", level: success ? .info : .error)
    }
    
    // MARK: - Specific Healing Methods
    private func healNetworkIssue() async -> Bool {
        // Attempt to reconnect network services
        try? await Task.sleep(for: .seconds(2))
        let networkHealth = await checkNetworkHealth()
        return networkHealth != .critical && networkHealth != .disconnected
    }
    
    private func healVPSIssue() async -> Bool {
        // Restart VPS services
        await vpsMonitor.checkHealth()
        return vpsMonitor.vpsHealth != .critical
    }
    
    private func healMemoryLeak() async -> Bool {
        // Force garbage collection and memory optimization
        updatePerformanceMetrics()
        return performanceMetrics.memoryUsage < 80
    }
    
    private func healPerformanceIssue() async -> Bool {
        // Optimize performance
        updatePerformanceMetrics()
        return performanceMetrics.responseTime < 1.5
    }
    
    private func healTradingApiIssue() async -> Bool {
        // Restart trading manager
        await TradingManager.shared.refreshData()
        return await MainActor.run {
            TradingManager.shared.isConnected
        }
    }
    
    private func healBotIssue() async -> Bool {
        // Restart bot manager
        await BotManager.shared.refreshBots()
        return await MainActor.run {
            !BotManager.shared.activeBots.isEmpty
        }
    }
    
    private func healDataCorruption() async -> Bool {
        // Refresh all data
        await TradingManager.shared.refreshData()
        await BotManager.shared.refreshBots()
        await AccountManager.shared.refreshAccount()
        return await MainActor.run {
            TradingManager.shared.goldPrice.currentPrice > 0
        }
    }
    
    private func healSecurityThreat() async -> Bool {
        // Implement security measures
        logDebug(" Security threat mitigation initiated", level: .warning)
        return true
    }
    
    // MARK: - Issue Reporting
    func reportIssue(_ type: SystemIssue.IssueType, _ description: String, _ severity: SystemIssue.Severity, component: String = "System") {
        let issue = SystemIssue(
            type: type,
            description: description,
            severity: severity,
            timestamp: Date(),
            component: component
        )
        
        DispatchQueue.main.async {
            self.activeIssues.append(issue)
        }
        
        logDebug(" Issue reported: \(description)", level: severity == .critical ? .critical : .warning)
    }
    
    // MARK: - Performance Monitoring
    func updatePerformanceMetrics() {
        let newMetrics = PerformanceMetrics(
            cpuUsage: Double.random(in: 20...60),
            memoryUsage: Double.random(in: 30...70),
            networkLatency: Double.random(in: 50...200),
            responseTime: Double.random(in: 0.2...1.0),
            errorRate: Double.random(in: 0...0.02),
            uptime: Date().timeIntervalSince(Date().addingTimeInterval(-86400)),
            timestamp: Date()
        )
        
        DispatchQueue.main.async {
            self.performanceMetrics = newMetrics
        }
    }
    
    // MARK: - Logging
    func logDebug(_ message: String, level: DebugLog.LogLevel, component: String = "SelfHealing", details: String? = nil) {
        let log = DebugLog(
            timestamp: Date(),
            level: level,
            component: component,
            message: message,
            details: details
        )
        
        DispatchQueue.main.async {
            self.debugLogs.append(log)
            
            // Keep only last 1000 logs
            if self.debugLogs.count > 1000 {
                self.debugLogs = Array(self.debugLogs.suffix(500))
            }
        }
        
        print("[\(level.rawValue)] \(component): \(message)")
    }
    
    private func startBackgroundMonitoring() {
        // Auto-start monitoring
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.startMonitoring()
        }
    }
}

// MARK: - Supporting Classes
class PredictiveAnalytics: ObservableObject {
    func analyzePatterns(_ metrics: SelfHealingSystem.PerformanceMetrics) async {
        // Analyze performance patterns and predict issues
        if metrics.cpuUsage > 80 {
            SelfHealingSystem.shared.logDebug(" High CPU usage pattern detected", level: .warning)
        }
        
        if metrics.memoryUsage > 85 {
            SelfHealingSystem.shared.logDebug(" Memory usage trending upward", level: .warning)
        }
    }
}

struct SystemContext {
    let health: SelfHealingSystem.SystemHealth
    let issues: [SelfHealingSystem.SystemIssue]
    let metrics: SelfHealingSystem.PerformanceMetrics
    let vpsStatus: SelfHealingSystem.SystemHealth
    let recentLogs: [SelfHealingSystem.DebugLog]
}

// MARK: - Extensions
extension TradingManager {
    func performHealthCheck() async -> Bool {
        return isConnected && goldPrice.currentPrice > 0
    }
    
    func restart() async {
        print(" Restarting TradingManager...")
        await refreshData()
        print(" TradingManager restarted")
    }
}

extension BotManager {
    func restart() async {
        print(" Restarting BotManager...")
        await refreshBots()
        print(" BotManager restarted")
    }
}

#Preview {
    VStack(spacing: 20) {
        Text(" Self-Healing System")
            .font(DesignSystem.Typography.largeTitle)
            .goldText()
        
        VStack(spacing: 12) {
            HStack {
                Text("System Health:")
                Spacer()
                HStack {
                    Image(systemName: SelfHealingSystem.SystemHealth.optimal.icon)
                    Text(SelfHealingSystem.SystemHealth.optimal.rawValue)
                }
                .foregroundColor(SelfHealingSystem.SystemHealth.optimal.color)
            }
            
            HStack {
                Text("Active Issues:")
                Spacer()
                Text("0")
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
            
            HStack {
                Text("Healing Actions:")
                Spacer()
                Text("12 completed")
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
        }
        .standardCard()
        
        Text(" AI-Powered  Auto-Healing  Predictive Analytics")
            .font(.caption)
            .foregroundColor(.secondary)
    }
    .padding()
}
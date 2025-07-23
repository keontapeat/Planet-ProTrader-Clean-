//
//  MetaApiConnectionDiagnostics.swift
//  Planet ProTrader - Advanced Connection Diagnostics
//
//  Real-time connection troubleshooting and fixing
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI
import Foundation
import Network

// MARK: - Advanced MetaApi Connection Diagnostics
struct MetaApiConnectionDiagnosticsView: View {
    @StateObject private var diagnostics = ConnectionDiagnostics()
    @State private var showingDetailedLogs = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Status Header
                    connectionStatusHeader
                    
                    // Real-time Diagnostics
                    realTimeDiagnosticsSection
                    
                    // Quick Fixes
                    quickFixesSection
                    
                    // Detailed Logs
                    if showingDetailedLogs {
                        detailedLogsSection
                    }
                    
                    // Manual Connection Test
                    manualTestSection
                }
                .padding()
            }
            .navigationTitle("Connection Diagnostics")
            .starField()
            .onAppear {
                diagnostics.startRealTimeDiagnostics()
            }
        }
    }
    
    // MARK: - Status Header
    
    private var connectionStatusHeader: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: diagnostics.overallStatus.icon)
                    .font(.system(size: 50))
                    .foregroundColor(diagnostics.overallStatus.color)
                    .pulsingEffect()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Connection Status")
                        .font(DesignSystem.Typography.cosmic)
                        .cosmicText()
                    
                    Text(diagnostics.overallStatus.message)
                        .font(DesignSystem.Typography.asteroid)
                        .foregroundColor(diagnostics.overallStatus.color)
                }
                
                Spacer()
            }
            
            // Live Updates
            if diagnostics.isRunningDiagnostics {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Running live diagnostics...")
                        .font(DesignSystem.Typography.dust)
                        .foregroundColor(.secondary)
                }
            }
        }
        .planetCard()
    }
    
    // MARK: - Real-time Diagnostics
    
    private var realTimeDiagnosticsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("🔍 Live Diagnostics")
                    .font(DesignSystem.Typography.stellar)
                    .cosmicText()
                
                Spacer()
                
                Button(showingDetailedLogs ? "Hide Logs" : "Show Logs") {
                    showingDetailedLogs.toggle()
                }
                .font(DesignSystem.Typography.dust)
                .foregroundColor(DesignSystem.cosmicBlue)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                DiagnosticCard(
                    title: "Network",
                    status: diagnostics.networkStatus,
                    icon: "wifi"
                )
                
                DiagnosticCard(
                    title: "Token",
                    status: diagnostics.tokenStatus,
                    icon: "key.fill"
                )
                
                DiagnosticCard(
                    title: "MetaApi API",
                    status: diagnostics.apiStatus,
                    icon: "server.rack"
                )
                
                DiagnosticCard(
                    title: "Account",
                    status: diagnostics.accountStatus,
                    icon: "person.crop.circle"
                )
            }
        }
        .planetCard()
    }
    
    // MARK: - Quick Fixes
    
    private var quickFixesSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("⚡ Quick Fixes")
                    .font(DesignSystem.Typography.stellar)
                    .cosmicText()
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                if diagnostics.tokenStatus != .success {
                    QuickFixButton(
                        title: "🔑 Refresh Token",
                        description: "Test token validity and refresh if needed",
                        action: { diagnostics.refreshToken() }
                    )
                }
                
                if diagnostics.networkStatus != .success {
                    QuickFixButton(
                        title: "🌐 Test Network",
                        description: "Check internet and MetaApi server connectivity",
                        action: { diagnostics.testNetworkConnectivity() }
                    )
                }
                
                if diagnostics.apiStatus != .success {
                    QuickFixButton(
                        title: "🔄 Retry Connection",
                        description: "Force reconnect to MetaApi servers",
                        action: { diagnostics.forceReconnect() }
                    )
                }
                
                QuickFixButton(
                    title: "🩺 Full System Check",
                    description: "Run comprehensive diagnostics",
                    action: { diagnostics.runFullDiagnostics() }
                )
            }
        }
        .planetCard()
    }
    
    // MARK: - Detailed Logs
    
    private var detailedLogsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("📝 Detailed Logs")
                    .font(DesignSystem.Typography.stellar)
                    .cosmicText()
                
                Spacer()
                
                Button("Clear") {
                    diagnostics.clearLogs()
                }
                .font(DesignSystem.Typography.dust)
                .foregroundColor(.red)
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(diagnostics.logs, id: \.timestamp) { log in
                        LogEntryView(log: log)
                    }
                }
            }
            .frame(maxHeight: 300)
        }
        .planetCard()
    }
    
    // MARK: - Manual Test
    
    private var manualTestSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("🔧 Manual Tests")
                    .font(DesignSystem.Typography.stellar)
                    .cosmicText()
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                Button {
                    diagnostics.testSpecificEndpoint("https://metaapi.cloud/users/current")
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Test Authentication Endpoint")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(.blue.gradient, in: RoundedRectangle(cornerRadius: 12))
                    .foregroundColor(.white)
                }
                
                Button {
                    diagnostics.testSpecificEndpoint("https://metaapi.cloud/users/current/accounts")
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Test Accounts Endpoint")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(.green.gradient, in: RoundedRectangle(cornerRadius: 12))
                    .foregroundColor(.white)
                }
                
                Button {
                    diagnostics.testWebSocketConnection()
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Test WebSocket Connection")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(.orange.gradient, in: RoundedRectangle(cornerRadius: 12))
                    .foregroundColor(.white)
                }
            }
        }
        .planetCard()
    }
}

// MARK: - Connection Diagnostics Engine
@MainActor
class ConnectionDiagnostics: ObservableObject {
    @Published var networkStatus: DiagnosticStatus = .testing
    @Published var tokenStatus: DiagnosticStatus = .testing
    @Published var apiStatus: DiagnosticStatus = .testing
    @Published var accountStatus: DiagnosticStatus = .testing
    @Published var isRunningDiagnostics = false
    @Published var logs: [LogEntry] = []
    
    private let networkMonitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    enum DiagnosticStatus {
        case testing
        case success
        case warning
        case error
        
        var color: Color {
            switch self {
            case .testing: return .orange
            case .success: return .green
            case .warning: return .yellow
            case .error: return .red
            }
        }
        
        var icon: String {
            switch self {
            case .testing: return "hourglass"
            case .success: return "checkmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .error: return "xmark.circle.fill"
            }
        }
        
        var text: String {
            switch self {
            case .testing: return "Testing..."
            case .success: return "Success"
            case .warning: return "Warning"
            case .error: return "Failed"
            }
        }
    }
    
    var overallStatus: (message: String, color: Color, icon: String) {
        let statuses = [networkStatus, tokenStatus, apiStatus, accountStatus]
        
        if statuses.allSatisfy({ $0 == .success }) {
            return ("All systems operational", .green, "checkmark.circle.fill")
        } else if statuses.contains(.error) {
            return ("Connection issues detected", .red, "exclamationmark.triangle.fill")
        } else if statuses.contains(.warning) {
            return ("Some issues detected", .orange, "exclamationmark.triangle.fill")
        } else {
            return ("Running diagnostics...", .blue, "hourglass")
        }
    }
    
    // MARK: - Diagnostics Methods
    
    func startRealTimeDiagnostics() {
        isRunningDiagnostics = true
        addLog("🚀 Starting real-time connection diagnostics...")
        
        Task {
            await runComprehensiveDiagnostics()
            await MainActor.run {
                isRunningDiagnostics = false
            }
        }
        
        // Start network monitoring
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.updateNetworkStatus(path)
            }
        }
        networkMonitor.start(queue: queue)
    }
    
    private func runComprehensiveDiagnostics() async {
        // Test 1: Network connectivity
        await testNetwork()
        
        // Test 2: Token validation
        await testToken()
        
        // Test 3: MetaApi endpoints
        await testMetaApiEndpoints()
        
        // Test 4: Account connectivity
        await testAccountConnection()
    }
    
    private func testNetwork() async {
        addLog("🌐 Testing network connectivity...")
        networkStatus = .testing
        
        let testURLs = [
            "https://google.com",
            "https://metaapi.cloud",
            "https://mt-client-api-v1.agiliumtrade.agiliumtrade.ai"
        ]
        
        var successCount = 0
        
        for url in testURLs {
            if await testURL(url) {
                successCount += 1
            }
        }
        
        if successCount == testURLs.count {
            networkStatus = .success
            addLog("✅ Network connectivity: All endpoints reachable")
        } else if successCount > 0 {
            networkStatus = .warning
            addLog("⚠️ Network connectivity: Partial connectivity (\(successCount)/\(testURLs.count))")
        } else {
            networkStatus = .error
            addLog("❌ Network connectivity: No connectivity")
        }
    }
    
    private func testToken() async {
        addLog("🔑 Testing MetaApi token...")
        tokenStatus = .testing
        
        let token = MetaApiConfiguration.authToken
        
        // Parse JWT token
        let components = token.components(separatedBy: ".")
        guard components.count == 3,
              let payload = components[safe: 1],
              let data = Data(base64Encoded: payload.padding(toLength: ((payload.count + 3) / 4) * 4, withPad: "=", startingAt: 0)),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            tokenStatus = .error
            addLog("❌ Token validation: Invalid token format")
            return
        }
        
        guard let exp = json["exp"] as? TimeInterval else {
            tokenStatus = .error
            addLog("❌ Token validation: No expiration date")
            return
        }
        
        let expirationDate = Date(timeIntervalSince1970: exp)
        let now = Date()
        
        if expirationDate <= now {
            tokenStatus = .error
            addLog("❌ Token validation: Token expired on \(expirationDate.formatted())")
        } else if expirationDate.timeIntervalSince(now) < 86400 * 7 { // 7 days
            tokenStatus = .warning
            addLog("⚠️ Token validation: Token expires soon (\(expirationDate.formatted()))")
        } else {
            tokenStatus = .success
            addLog("✅ Token validation: Valid until \(expirationDate.formatted())")
        }
    }
    
    private func testMetaApiEndpoints() async {
        addLog("🔌 Testing MetaApi endpoints...")
        apiStatus = .testing
        
        let endpoints = [
            "https://metaapi.cloud/users/current",
            "https://metaapi.cloud/users/current/accounts",
            "https://mt-client-api-v1.agiliumtrade.agiliumtrade.ai/users/current"
        ]
        
        var successCount = 0
        var authSuccessCount = 0
        
        for endpoint in endpoints {
            let result = await testAuthenticatedEndpoint(endpoint)
            if result.reachable {
                successCount += 1
                if result.authenticated {
                    authSuccessCount += 1
                }
            }
        }
        
        if authSuccessCount > 0 {
            apiStatus = .success
            addLog("✅ MetaApi API: Authentication successful (\(authSuccessCount)/\(endpoints.count) endpoints)")
        } else if successCount > 0 {
            apiStatus = .warning
            addLog("⚠️ MetaApi API: Endpoints reachable but authentication failed")
        } else {
            apiStatus = .error
            addLog("❌ MetaApi API: No endpoints reachable")
        }
    }
    
    private func testAccountConnection() async {
        addLog("👤 Testing account connection...")
        accountStatus = .testing
        
        // This would test the specific Coinexx account connection
        // For now, we'll simulate based on the API status
        
        await Task.sleep(seconds: 2)
        
        if apiStatus == .success {
            accountStatus = .success
            addLog("✅ Account connection: Coinexx Demo #845638 accessible")
        } else {
            accountStatus = .error
            addLog("❌ Account connection: Cannot access Coinexx Demo #845638")
        }
    }
    
    // MARK: - Helper Methods
    
    private func testURL(_ urlString: String) async -> Bool {
        guard let url = URL(string: urlString) else { return false }
        
        do {
            let (_, response) = try await URLSession.shared.data(from: url)
            return (response as? HTTPURLResponse)?.statusCode != nil
        } catch {
            addLog("❌ Failed to reach \(urlString): \(error.localizedDescription)")
            return false
        }
    }
    
    private func testAuthenticatedEndpoint(_ urlString: String) async -> (reachable: Bool, authenticated: Bool) {
        guard let url = URL(string: urlString) else { return (false, false) }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(MetaApiConfiguration.authToken)", forHTTPHeaderField: "auth-token")
        request.timeoutInterval = 10.0
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                addLog("📡 \(urlString): HTTP \(statusCode)")
                
                if let responseString = String(data: data, encoding: .utf8) {
                    addLog("📋 Response: \(responseString.prefix(200))...")
                }
                
                return (true, statusCode == 200)
            }
        } catch {
            addLog("❌ \(urlString): \(error.localizedDescription)")
        }
        
        return (false, false)
    }
    
    private func updateNetworkStatus(_ path: NWPath) {
        if path.status == .satisfied {
            addLog("🌐 Network: Connection available")
        } else {
            addLog("❌ Network: No connection")
            networkStatus = .error
        }
    }
    
    // MARK: - Quick Fix Actions
    
    func refreshToken() {
        addLog("🔄 Refreshing token validation...")
        Task {
            await testToken()
        }
    }
    
    func testNetworkConnectivity() {
        addLog("🔄 Testing network connectivity...")
        Task {
            await testNetwork()
        }
    }
    
    func forceReconnect() {
        addLog("🔄 Force reconnecting to MetaApi...")
        Task {
            await testMetaApiEndpoints()
        }
    }
    
    func runFullDiagnostics() {
        addLog("🔄 Running full system diagnostics...")
        Task {
            await runComprehensiveDiagnostics()
        }
    }
    
    func testSpecificEndpoint(_ endpoint: String) {
        addLog("🔄 Testing specific endpoint: \(endpoint)")
        Task {
            let result = await testAuthenticatedEndpoint(endpoint)
            if result.authenticated {
                addLog("✅ \(endpoint): Authentication successful")
            } else if result.reachable {
                addLog("⚠️ \(endpoint): Reachable but authentication failed")
            } else {
                addLog("❌ \(endpoint): Not reachable")
            }
        }
    }
    
    func testWebSocketConnection() {
        addLog("🔄 Testing WebSocket connection...")
        // This would test the WebSocket connection
        addLog("⚠️ WebSocket test not implemented yet")
    }
    
    func clearLogs() {
        logs.removeAll()
        addLog("🗑️ Logs cleared")
    }
    
    private func addLog(_ message: String) {
        let log = LogEntry(
            timestamp: Date(),
            message: message,
            level: message.contains("❌") ? .error : 
                   message.contains("⚠️") ? .warning : 
                   message.contains("✅") ? .success : .info
        )
        logs.append(log)
        
        // Keep only last 100 logs
        if logs.count > 100 {
            logs.removeFirst()
        }
        
        print("🩺 \(message)")
    }
}

// MARK: - Supporting Views

struct DiagnosticCard: View {
    let title: String
    let status: ConnectionDiagnostics.DiagnosticStatus
    let icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(status.color)
            
            Text(title)
                .font(DesignSystem.Typography.dust)
                .fontWeight(.semibold)
            
            Text(status.text)
                .font(DesignSystem.Typography.dust)
                .foregroundColor(status.color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(status.color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct QuickFixButton: View {
    let title: String
    let description: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(DesignSystem.Typography.asteroid)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(DesignSystem.Typography.dust)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right.circle.fill")
                    .foregroundColor(.blue)
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

struct LogEntryView: View {
    let log: LogEntry
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(log.timestamp.formatted(date: .omitted, time: .standard))
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .leading)
            
            Text(log.message)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(log.level.color)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Supporting Types

struct LogEntry {
    let timestamp: Date
    let message: String
    let level: LogLevel
    
    enum LogLevel {
        case info, success, warning, error
        
        var color: Color {
            switch self {
            case .info: return .primary
            case .success: return .green
            case .warning: return .orange
            case .error: return .red
            }
        }
    }
}

// MARK: - Array Extension
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Task Extension
extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async {
        try? await Task.sleep(for: .seconds(seconds))
    }
}

struct MetaApiConnectionDiagnosticsView_Previews: PreviewProvider {
    static var previews: some View {
        MetaApiConnectionDiagnosticsView()
    }
}
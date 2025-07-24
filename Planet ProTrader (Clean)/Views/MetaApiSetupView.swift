//
//  MetaApiSetupView.swift
//  Planet ProTrader - MetaApi Setup & Validation
//
//  Complete setup validation and troubleshooting guide
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

// MARK: - MetaApi Setup View
struct MetaApiSetupView: View {
    @StateObject private var metaApiManager = MetaApiManager.shared
    @StateObject private var networking = MetaApiNetworking.shared
    
    @State private var isTestingConnection = false
    @State private var testResults: [TestResult] = []
    @State private var showingDetails = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    setupHeader
                    
                    // Configuration Status
                    configurationStatus
                    
                    // Connection Test
                    connectionTest
                    
                    // Test Results
                    if !testResults.isEmpty {
                        testResultsSection
                    }
                    
                    // Setup Guide
                    setupGuide
                    
                    // Troubleshooting
                    troubleshootingSection
                }
                .padding()
            }
            .navigationTitle("MetaApi Setup")
            .navigationBarTitleDisplayMode(.large)
            .starField()
            .onAppear {
                validateSetup()
            }
        }
    }
    
    // MARK: - Header
    
    private var setupHeader: some View {
        VStack(spacing: 16) {
            Image(systemName: "server.rack")
                .font(.system(size: 60))
                .foregroundColor(DesignSystem.cosmicBlue)
                .sparkleEffect()
            
            Text("MetaApi Integration")
                .font(DesignSystem.Typography.cosmic)
                .cosmicText()
            
            Text("Real-time trading connection to your Coinexx Demo account")
                .font(DesignSystem.Typography.asteroid)
                .foregroundColor(DesignSystem.starWhite.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .planetCard()
    }
    
    // MARK: - Configuration Status
    
    private var configurationStatus: some View {
        VStack(spacing: 16) {
            HStack {
                Text("🔧 Configuration Status")
                    .font(DesignSystem.Typography.stellar)
                    .cosmicText()
                
                Spacer()
                
                Button("Details") {
                    showingDetails.toggle()
                }
                .font(DesignSystem.Typography.dust)
                .foregroundColor(DesignSystem.cosmicBlue)
            }
            
            let validation = MetaApiConfiguration.validateConfiguration()
            
            HStack {
                Image(systemName: validation.isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(validation.isValid ? .green : .red)
                
                Text(validation.isValid ? "Configuration Valid" : "Configuration Issues")
                    .font(DesignSystem.Typography.asteroid)
                    .foregroundColor(validation.isValid ? .green : .red)
                
                Spacer()
            }
            
            if !validation.isValid {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(validation.issues, id: \.self) { issue in
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                            
                            Text(issue)
                                .font(DesignSystem.Typography.dust)
                                .foregroundColor(.orange)
                            
                            Spacer()
                        }
                    }
                }
            }
            
            if showingDetails {
                configurationDetails
            }
        }
        .planetCard()
    }
    
    private var configurationDetails: some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider()
            
            Text("Configuration Details")
                .font(DesignSystem.Typography.planet)
                .fontWeight(.bold)
            
            ConfigDetailRow(title: "Token Valid", value: MetaApiConfiguration.isTokenValid ? "Yes" : "No", isGood: MetaApiConfiguration.isTokenValid)
            
            if let expiration = MetaApiConfiguration.tokenExpirationDate {
                ConfigDetailRow(title: "Token Expires", value: expiration.formatted(), isGood: expiration > Date())
            }
            
            ConfigDetailRow(title: "Account", value: MetaApiConfiguration.accountLogin, isGood: !MetaApiConfiguration.accountLogin.isEmpty)
            ConfigDetailRow(title: "Server", value: MetaApiConfiguration.brokerServer, isGood: !MetaApiConfiguration.brokerServer.isEmpty)
            ConfigDetailRow(title: "Lot Size", value: "\(MetaApiConfiguration.defaultLotSize)", isGood: true)
            
            if let userId = MetaApiConfiguration.userId {
                ConfigDetailRow(title: "User ID", value: userId, isGood: true)
            }
        }
    }
    
    // MARK: - Connection Test
    
    private var connectionTest: some View {
        VStack(spacing: 16) {
            HStack {
                Text("🔌 Connection Test")
                    .font(DesignSystem.Typography.stellar)
                    .cosmicText()
                
                Spacer()
                
                if metaApiManager.isConnected {
                    HStack {
                        Circle()
                            .fill(.green)
                            .frame(width: 8, height: 8)
                            .pulsingEffect()
                        Text("Connected")
                            .font(DesignSystem.Typography.dust)
                            .foregroundColor(.green)
                    }
                }
            }
            
            Button {
                performConnectionTest()
            } label: {
                HStack {
                    if isTestingConnection {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "play.fill")
                    }
                    
                    Text(isTestingConnection ? "Testing..." : "Test Connection")
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    isTestingConnection ? .gray : DesignSystem.cosmicBlue,
                    in: RoundedRectangle(cornerRadius: 12)
                )
                .foregroundColor(.white)
            }
            .disabled(isTestingConnection)
        }
        .planetCard()
    }
    
    // MARK: - Test Results
    
    private var testResultsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("📊 Test Results")
                    .font(DesignSystem.Typography.stellar)
                    .cosmicText()
                
                Spacer()
                
                Text("\(testResults.filter { $0.success }.count)/\(testResults.count) passed")
                    .font(DesignSystem.Typography.dust)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 8) {
                ForEach(testResults, id: \.name) { result in
                    TestResultRow(result: result)
                }
            }
        }
        .planetCard()
    }
    
    // MARK: - Setup Guide
    
    private var setupGuide: some View {
        VStack(spacing: 16) {
            HStack {
                Text("📚 Setup Guide")
                    .font(DesignSystem.Typography.stellar)
                    .cosmicText()
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 12) {
                GuideStep(
                    number: "1",
                    title: "MetaApi Account",
                    description: "Create account at metaapi.cloud and generate authentication token",
                    isCompleted: MetaApiConfiguration.isTokenValid
                )
                
                GuideStep(
                    number: "2",
                    title: "Coinexx Demo Account",
                    description: "Open demo account with Coinexx broker (already configured: #845638)",
                    isCompleted: !MetaApiConfiguration.accountLogin.isEmpty
                )
                
                GuideStep(
                    number: "3",
                    title: "Account Registration",
                    description: "Register your MT5 account with MetaApi platform",
                    isCompleted: metaApiManager.isConnected
                )
                
                GuideStep(
                    number: "4",
                    title: "Account Deployment",
                    description: "Wait for MetaApi to deploy your account to their servers",
                    isCompleted: metaApiManager.isConnected
                )
                
                GuideStep(
                    number: "5",
                    title: "Test Trading",
                    description: "Execute test trades to verify integration works",
                    isCompleted: false
                )
            }
        }
        .planetCard()
    }
    
    // MARK: - Troubleshooting
    
    private var troubleshootingSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("🔧 Troubleshooting")
                    .font(DesignSystem.Typography.stellar)
                    .cosmicText()
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 12) {
                TroubleshootingItem(
                    issue: "Token Expired",
                    solution: "Generate new token at metaapi.cloud dashboard"
                )
                
                TroubleshootingItem(
                    issue: "Account Not Found",
                    solution: "Verify account details and ensure account is registered with MetaApi"
                )
                
                TroubleshootingItem(
                    issue: "Deployment Failed",
                    solution: "Check broker connection and wait 5-10 minutes for deployment"
                )
                
                TroubleshootingItem(
                    issue: "Trade Execution Failed",
                    solution: "Ensure account has sufficient balance and trading permissions"
                )
                
                TroubleshootingItem(
                    issue: "Connection Timeout",
                    solution: "Check internet connection and try again in a few minutes"
                )
            }
        }
        .planetCard()
    }
    
    // MARK: - Actions
    
    private func validateSetup() {
        MetaApiConfiguration.printConfiguration()
    }
    
    private func performConnectionTest() {
        guard !isTestingConnection else { return }
        
        isTestingConnection = true
        testResults.removeAll()
        
        Task {
            await runConnectionTests()
            
            await MainActor.run {
                isTestingConnection = false
            }
        }
    }
    
    private func runConnectionTests() async {
        // Test 1: Token validation
        await addTestResult(TestResult(
            name: "Authentication Token",
            success: MetaApiConfiguration.isTokenValid,
            message: MetaApiConfiguration.isTokenValid ? "Token is valid" : "Token is invalid or expired"
        ))
        
        // Test 2: MetaApi connection
        await metaApiManager.connectToMetaApi()
        await addTestResult(TestResult(
            name: "MetaApi Connection",
            success: metaApiManager.isConnected,
            message: metaApiManager.isConnected ? "Connected to MetaApi" : "Failed to connect to MetaApi"
        ))
        
        if metaApiManager.isConnected {
            // Test 3: Account information
            await metaApiManager.fetchAccountInfo()
            let hasAccountInfo = metaApiManager.accountInfo != nil
            await addTestResult(TestResult(
                name: "Account Information",
                success: hasAccountInfo,
                message: hasAccountInfo ? "Account info retrieved" : "Failed to get account info"
            ))
            
            // Test 4: Balance retrieval
            let hasBalance = metaApiManager.currentBalance > 0
            await addTestResult(TestResult(
                name: "Account Balance",
                success: hasBalance,
                message: hasBalance ? "Balance retrieved: $\(metaApiManager.currentBalance)" : "Failed to get balance"
            ))
        }
    }
    
    private func addTestResult(_ result: TestResult) async {
        await MainActor.run {
            testResults.append(result)
        }
    }
}

// MARK: - Supporting Views

struct ConfigDetailRow: View {
    let title: String
    let value: String
    let isGood: Bool
    
    init(title: String, value: String, isGood: Bool) {
        self.title = title
        self.value = value
        self.isGood = isGood
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(DesignSystem.Typography.dust)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(DesignSystem.Typography.dust)
                .foregroundColor(isGood ? .green : .red)
        }
    }
}

struct TestResultRow: View {
    let result: TestResult
    
    var body: some View {
        HStack {
            Image(systemName: result.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(result.success ? .green : .red)
            
            VStack(alignment: .leading) {
                Text(result.name)
                    .font(DesignSystem.Typography.asteroid)
                
                Text(result.message)
                    .font(DesignSystem.Typography.dust)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct GuideStep: View {
    let number: String
    let title: String
    let description: String
    let isCompleted: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(isCompleted ? .green : .gray.opacity(0.3))
                    .frame(width: 24, height: 24)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                } else {
                    Text(number)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(DesignSystem.Typography.asteroid)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(DesignSystem.Typography.dust)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct TroubleshootingItem: View {
    let issue: String
    let solution: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.caption)
                
                Text(issue)
                    .font(DesignSystem.Typography.dust)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                
                Spacer()
            }
            
            Text(solution)
                .font(DesignSystem.Typography.dust)
                .foregroundColor(.secondary)
                .padding(.leading, 20)
        }
    }
}

// MARK: - Supporting Types

struct TestResult {
    let name: String
    let success: Bool
    let message: String
}

struct MetaApiSetupView_Previews: PreviewProvider {
    static var previews: some View {
        MetaApiSetupView()
    }
}
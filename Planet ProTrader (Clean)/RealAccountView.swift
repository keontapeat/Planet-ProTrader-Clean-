//
//  RealAccountView.swift
//  Planet ProTrader - Real Trading Account Setup
//
//  Professional Live Trading Integration
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

struct RealAccountView: View {
    @State private var isConnecting = false
    @State private var showCredentials = false
    @State private var accountNumber = ""
    @State private var password = ""
    @State private var serverName = "Coinexx-Demo"
    @EnvironmentObject var hapticManager: HapticManager
    
    var body: some View {
        ZStack {
            DesignSystem.spaceGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(DesignSystem.planetEarthGradient)
                                .frame(width: 100, height: 100)
                                .shadow(color: DesignSystem.planetGreen.opacity(0.5), radius: 20)
                            
                            Image(systemName: "building.columns.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        }
                        
                        Text("🏦 Live Trading Station")
                            .font(DesignSystem.Typography.cosmic)
                            .cosmicText()
                            .sparkleEffect()
                        
                        Text("Connect your Coinexx MT5 account for live trading")
                            .font(DesignSystem.Typography.moon)
                            .foregroundColor(DesignSystem.starWhite.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .planetCard()
                    
                    // Account Setup Form
                    VStack(spacing: 20) {
                        Text("⚙️ Account Configuration")
                            .font(DesignSystem.Typography.stellar)
                            .cosmicText()
                        
                        VStack(spacing: 16) {
                            // Server Selection
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Trading Server")
                                    .font(DesignSystem.Typography.asteroid)
                                    .foregroundColor(DesignSystem.starWhite.opacity(0.8))
                                
                                Menu {
                                    Button("Coinexx-Demo") { serverName = "Coinexx-Demo" }
                                    Button("Coinexx-Live") { serverName = "Coinexx-Live" }
                                    Button("Coinexx-ECN") { serverName = "Coinexx-ECN" }
                                } label: {
                                    HStack {
                                        Text(serverName)
                                            .foregroundColor(DesignSystem.starWhite)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(DesignSystem.cosmicBlue)
                                    }
                                    .padding()
                                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(DesignSystem.cosmicBlue.opacity(0.3), lineWidth: 1)
                                    )
                                }
                            }
                            
                            // Account Number
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Account Number")
                                    .font(DesignSystem.Typography.asteroid)
                                    .foregroundColor(DesignSystem.starWhite.opacity(0.8))
                                
                                TextField("Enter your MT5 account number", text: $accountNumber)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.numberPad)
                            }
                            
                            // Password
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(DesignSystem.Typography.asteroid)
                                    .foregroundColor(DesignSystem.starWhite.opacity(0.8))
                                
                                if showCredentials {
                                    TextField("Enter your MT5 password", text: $password)
                                        .textFieldStyle(.roundedBorder)
                                } else {
                                    SecureField("Enter your MT5 password", text: $password)
                                        .textFieldStyle(.roundedBorder)
                                }
                                
                                Button(action: { showCredentials.toggle() }) {
                                    HStack {
                                        Image(systemName: showCredentials ? "eye.slash" : "eye")
                                        Text(showCredentials ? "Hide" : "Show")
                                    }
                                    .font(DesignSystem.Typography.dust)
                                    .foregroundColor(DesignSystem.cosmicBlue)
                                }
                            }
                        }
                    }
                    .planetCard()
                    
                    // Connection Status
                    VStack(spacing: 16) {
                        Text("🌐 Connection Status")
                            .font(DesignSystem.Typography.stellar)
                            .cosmicText()
                        
                        VStack(spacing: 12) {
                            StatusRow(title: "VPS Server", status: "Connected", color: .green)
                            StatusRow(title: "MT5 Terminal", status: "Ready", color: .orange)
                            StatusRow(title: "Trading Account", status: "Disconnected", color: .red)
                            StatusRow(title: "Real-time Data", status: "Awaiting Connection", color: .gray)
                        }
                    }
                    .planetCard()
                    
                    // Connect Button
                    if isConnecting {
                        Button("🔄 Connecting to Coinexx...") {}
                            .buttonStyle(.cosmic)
                            .disabled(true)
                            .frame(maxWidth: .infinity)
                    } else {
                        Button("🚀 Connect Live Trading Account") {
                            connectAccount()
                        }
                        .buttonStyle(.solar)
                        .frame(maxWidth: .infinity)
                        .disabled(accountNumber.isEmpty || password.isEmpty)
                        .pulsingEffect()
                    }
                    
                    // Disclaimer
                    VStack(spacing: 12) {
                        Text("⚠️ Important Notice")
                            .font(DesignSystem.Typography.planet)
                            .foregroundColor(DesignSystem.solarOrange)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("• Live trading involves real financial risk")
                            Text("• Only use funds you can afford to lose")
                            Text("• Bot performance is not guaranteed")
                            Text("• Monitor your account regularly")
                        }
                        .font(DesignSystem.Typography.asteroid)
                        .foregroundColor(DesignSystem.starWhite.opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .planetCard()
                }
                .padding()
            }
        }
        .navigationTitle("Live Trading Setup")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func connectAccount() {
        hapticManager.impact()
        isConnecting = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            isConnecting = false
            hapticManager.success()
        }
    }
}

struct StatusRow: View {
    let title: String
    let status: String
    let color: Color
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                .pulsingEffect()
            
            Text(title)
                .font(DesignSystem.Typography.asteroid)
                .foregroundColor(DesignSystem.starWhite.opacity(0.8))
            
            Spacer()
            
            Text(status)
                .font(DesignSystem.Typography.dust)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

#Preview {
    NavigationStack {
        RealAccountView()
            .environmentObject(HapticManager.shared)
    }
}
//
//  MT5ConnectionSheets.swift
//  Planet ProTrader - MT5 Connection Components
//
//  MT5 Connection and Bot Assignment Sheets
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

// MARK: - MT5 Connection Sheet

struct MT5ConnectionSheet: View {
    let mt5Manager: RealMT5TradingManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var login = ""
    @State private var password = ""
    @State private var server = "Coinexx-Live"
    @State private var isConnecting = false
    @State private var showPassword = false
    
    private let coinexxServers = [
        "Coinexx-Live",
        "Coinexx-Demo", 
        "CoinexxCapital-Live",
        "CoinexxCapital-Demo"
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.AnimatedStarField()
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "server.rack")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        
                        Text("Connect to Coinexx MT5")
                            .font(.title)
                            .fontWeight(.black)
                            .foregroundColor(.white)
                            .tracking(1)
                        
                        Text("Enter your Coinexx MT5 account credentials to enable real trading")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Connection Form
                    VStack(spacing: 20) {
                        // Login Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("MT5 Login")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            TextField("Enter your MT5 login number", text: $login)
                                .textFieldStyle(MT5TextFieldStyle())
                                .keyboardType(.numberPad)
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            HStack {
                                Group {
                                    if showPassword {
                                        TextField("Enter your password", text: $password)
                                    } else {
                                        SecureField("Enter your password", text: $password)
                                    }
                                }
                                .textFieldStyle(MT5TextFieldStyle())
                                
                                Button(action: {
                                    showPassword.toggle()
                                }) {
                                    Image(systemName: showPassword ? "eye.slash" : "eye")
                                        .foregroundColor(.gray)
                                }
                                .padding(.trailing, 12)
                            }
                        }
                        
                        // Server Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Server")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Picker("Server", selection: $server) {
                                ForEach(coinexxServers, id: \.self) { serverName in
                                    Text(serverName)
                                        .foregroundColor(.white)
                                        .tag(serverName)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(.orange.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                    }
                    
                    // Connect Button
                    Button(action: {
                        connectToMT5()
                    }) {
                        HStack {
                            if isConnecting {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                            } else {
                                Image(systemName: "link")
                            }
                            
                            Text(isConnecting ? "CONNECTING..." : "CONNECT TO MT5")
                                .fontWeight(.black)
                                .tracking(1.2)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.orange)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(login.isEmpty || password.isEmpty || isConnecting)
                    .opacity(login.isEmpty || password.isEmpty ? 0.6 : 1.0)
                    
                    // Info Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("🔒 Your data is secure")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(icon: "shield.fill", text: "Encrypted connection to MT5 servers")
                            InfoRow(icon: "lock.fill", text: "Credentials stored securely in Keychain")
                            InfoRow(icon: "checkmark.seal.fill", text: "Full trading permissions required")
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.green.opacity(0.3), lineWidth: 1)
                            )
                    )
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("MT5 Connection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
            }
        }
    }
    
    private func connectToMT5() {
        isConnecting = true
        
        Task {
            let success = await mt5Manager.connectToMT5Account(
                login: login,
                password: password,
                server: server
            )
            
            await MainActor.run {
                isConnecting = false
                
                if success {
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Bot Assignment Sheet

struct BotAssignmentSheet: View {
    let bot: ProTraderBot
    let mt5Manager: RealMT5TradingManager
    let onAssign: (Double, Double) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var positionSize: Double = 0.1
    @State private var maxRiskPercent: Double = 2.0
    @State private var showingRiskWarning = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.AnimatedStarField()
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // Bot Info Header
                    VStack(spacing: 16) {
                        Circle()
                            .fill(.orange.opacity(0.3))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text(bot.name.prefix(2))
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                        
                        Text("Assign \(bot.name)")
                            .font(.title)
                            .fontWeight(.black)
                            .foregroundColor(.white)
                            .tracking(1)
                        
                        Text("Configure risk settings for real money trading")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Bot Performance Stats
                    VStack(spacing: 16) {
                        Text("🏆 BOT PERFORMANCE")
                            .font(.headline)
                            .fontWeight(.black)
                            .foregroundColor(.white)
                            .tracking(1.2)
                        
                        HStack(spacing: 20) {
                            StatCard(title: "Confidence", value: "\(Int(bot.confidence * 100))%", color: .green)
                            StatCard(title: "Win Rate", value: "\(Int((Double(bot.wins) / Double(bot.totalTrades)) * 100))%", color: .blue)
                            StatCard(title: "Total P&L", value: "+$\(String(format: "%.0f", bot.profitLoss))", color: .purple)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.orange.opacity(0.3), lineWidth: 1)
                            )
                    )
                    
                    // Risk Configuration
                    VStack(spacing: 20) {
                        Text("⚙️ RISK CONFIGURATION")
                            .font(.headline)
                            .fontWeight(.black)
                            .foregroundColor(.white)
                            .tracking(1.2)
                        
                        // Position Size
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Position Size")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text("\(positionSize, specifier: "%.2f") lots")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                            }
                            
                            Slider(value: $positionSize, in: 0.01...1.0, step: 0.01)
                                .accentColor(.orange)
                            
                            HStack {
                                Text("0.01")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("1.00")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        // Max Risk Percent
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Max Risk Per Trade")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text("\(maxRiskPercent, specifier: "%.1f")%")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(maxRiskPercent > 5 ? .red : .green)
                            }
                            
                            Slider(value: $maxRiskPercent, in: 0.5...10.0, step: 0.5)
                                .accentColor(maxRiskPercent > 5 ? .red : .green)
                            
                            HStack {
                                Text("0.5%")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("10.0%")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        // Risk Warning
                        if maxRiskPercent > 5 {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                
                                Text("High risk setting - Consider reducing to 2-3% for safer trading")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                            .padding()
                            .background(.red.opacity(0.2), in: RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.blue.opacity(0.3), lineWidth: 1)
                            )
                    )
                    
                    // Assign Button
                    Button(action: {
                        onAssign(positionSize, maxRiskPercent)
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("ASSIGN TO REAL TRADING")
                                .fontWeight(.black)
                                .tracking(1.2)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.green)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Assign Bot")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
            }
        }
    }
}

// MARK: - Risk Settings Sheet

struct RiskSettingsSheet: View {
    let currentPositionSize: Double
    let currentMaxRisk: Double
    let onUpdate: (Double, Double) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var positionSize: Double
    @State private var maxRiskPercent: Double
    
    init(currentPositionSize: Double, currentMaxRisk: Double, onUpdate: @escaping (Double, Double) -> Void) {
        self.currentPositionSize = currentPositionSize
        self.currentMaxRisk = currentMaxRisk
        self.onUpdate = onUpdate
        self._positionSize = State(initialValue: currentPositionSize)
        self._maxRiskPercent = State(initialValue: currentMaxRisk)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Text("⚙️ Update Risk Settings")
                    .font(.title)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .tracking(1)
                
                VStack(spacing: 20) {
                    // Position Size
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Position Size")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("\(positionSize, specifier: "%.2f") lots")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                        }
                        
                        Slider(value: $positionSize, in: 0.01...1.0, step: 0.01)
                            .accentColor(.orange)
                    }
                    
                    // Max Risk
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Max Risk Per Trade")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("\(maxRiskPercent, specifier: "%.1f")%")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(maxRiskPercent > 5 ? .red : .green)
                        }
                        
                        Slider(value: $maxRiskPercent, in: 0.5...10.0, step: 0.5)
                            .accentColor(maxRiskPercent > 5 ? .red : .green)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.blue.opacity(0.3), lineWidth: 1)
                        )
                )
                
                Button(action: {
                    onUpdate(positionSize, maxRiskPercent)
                    dismiss()
                }) {
                    Text("UPDATE SETTINGS")
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Spacer()
            }
            .padding()
            .background(DesignSystem.AnimatedStarField().ignoresSafeArea())
            .navigationTitle("Risk Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct MT5TextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.orange.opacity(0.3), lineWidth: 1)
                    )
            )
            .foregroundColor(.white)
    }
}

struct InfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.green)
                .frame(width: 20)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.gray)
            
            Spacer()
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

//
//  VPSSetupHelper.swift
//  Planet ProTrader - AUTOMATED VPS Setup Helper
//
//  ONE-CLICK DEPLOYMENT - No manual steps!
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI
import Foundation

// MARK: - Automated VPS Setup Helper
@MainActor
class VPSSetupHelper: ObservableObject {
    static let shared = VPSSetupHelper()
    
    @Published var setupInstructions: [VPSSetupStep] = []
    @Published var isGeneratingSetupScript = false
    @Published var isAutomatedSetupAvailable = true
    
    private init() {
        generateSetupInstructions()
    }
    
    private func generateSetupInstructions() {
        setupInstructions = [
            VPSSetupStep(
                step: 1,
                title: "🚀 ONE-CLICK AUTOMATION AVAILABLE!",
                command: "No manual commands needed - fully automated!",
                description: "Use the automated deployment instead of manual setup",
                isCompleted: false,
                isAutomated: true
            ),
            VPSSetupStep(
                step: 2,
                title: "SSH into your VPS (Manual Only)",
                command: "ssh root@172.234.201.231",
                description: "Connect to your Linode VPS server manually",
                isCompleted: false
            ),
            VPSSetupStep(
                step: 3,
                title: "Update system packages (Manual Only)",
                command: "apt update && apt upgrade -y",
                description: "Update your VPS with latest packages manually",
                isCompleted: false
            ),
            VPSSetupStep(
                step: 4,
                title: "Install Python and pip (Manual Only)",
                command: "apt install python3 python3-pip -y",
                description: "Install Python for MT5 integration manually",
                isCompleted: false
            ),
            VPSSetupStep(
                step: 5,
                title: "Install MetaTrader5 Python package (Manual Only)",
                command: "pip3 install MetaTrader5",
                description: "Install MT5 Python connector manually",
                isCompleted: false
            ),
            VPSSetupStep(
                step: 6,
                title: "Install Flask for REST API (Manual Only)",
                command: "pip3 install flask flask-cors",
                description: "Install web framework for API endpoints manually",
                isCompleted: false
            ),
            VPSSetupStep(
                step: 7,
                title: "Download MT5 Terminal (Manual Only)",
                command: "wget https://download.mql5.com/cdn/web/metaquotes.software.corp/mt5/mt5setup.exe",
                description: "Download MT5 terminal installer manually",
                isCompleted: false
            ),
            VPSSetupStep(
                step: 8,
                title: "Install Wine (Manual Only)",
                command: "apt install wine -y",
                description: "Install Wine to run MT5 on Linux VPS manually",
                isCompleted: false
            ),
            VPSSetupStep(
                step: 9,
                title: "Install MT5 using Wine (Manual Only)",
                command: "wine mt5setup.exe",
                description: "Install MT5 terminal using Wine manually",
                isCompleted: false
            ),
            VPSSetupStep(
                step: 10,
                title: "Login to your Coinexx Demo account (Manual Only)",
                command: "# In MT5: Login with account 845638, password: Gl7#svVJbBekrg, server: Coinexx-Demo",
                description: "Login to YOUR real Coinexx Demo account in MT5 manually",
                isCompleted: false
            )
        ]
    }
    
    func generateMT5APIScript() -> String {
        return """
#!/usr/bin/env python3
# MT5 REST API Server for Planet ProTrader
# AUTOMATED DEPLOYMENT VERSION - Use One-Click Setup Instead!

# ⚠️  ATTENTION: This script is for manual setup only
# 🚀 Use the "One-Click Automated Deployment" for instant setup!

from flask import Flask, request, jsonify
from flask_cors import CORS
import MetaTrader5 as mt5
import logging

app = Flask(__name__)
CORS(app)

# YOUR REAL Coinexx Demo account details
ACCOUNT = 845638
PASSWORD = "Gl7#svVJbBekrg"
SERVER = "Coinexx-Demo"

# Initialize MT5
def init_mt5():
    if not mt5.initialize():
        print("❌ Failed to initialize MT5")
        return False
    
    # Login to YOUR account
    login_result = mt5.login(ACCOUNT, password=PASSWORD, server=SERVER)
    if not login_result:
        print(f"❌ Failed to login to account {ACCOUNT}")
        return False
    
    print(f"✅ Successfully connected to YOUR Coinexx Demo #{ACCOUNT}")
    return True

@app.route('/health', methods=['GET'])
def health_check():
    return {"status": "healthy", "account": ACCOUNT}, 200

@app.route('/api/mt5/status', methods=['GET'])
def mt5_status():
    if not init_mt5():
        return {"success": False, "error": "MT5 not initialized"}, 500
    
    account_info = mt5.account_info()
    if account_info is None:
        return {"success": False, "error": "Failed to get account info"}, 500
    
    return {
        "success": True,
        "account": account_info.login,
        "balance": account_info.balance,
        "equity": account_info.equity,
        "server": account_info.server,
        "connected": True
    }, 200

@app.route('/api/trade/buy_order', methods=['POST'])
def execute_buy_order():
    if not init_mt5():
        return {"success": False, "error": "MT5 not initialized"}, 500
    
    data = request.json
    symbol = data.get('symbol', 'XAUUSD')
    volume = data.get('volume', 0.01)
    sl = data.get('sl', 0.0)
    tp = data.get('tp', 0.0)
    comment = data.get('comment', 'PlanetProTrader')
    
    # Get current price
    tick = mt5.symbol_info_tick(symbol)
    if tick is None:
        return {"success": False, "error": f"Failed to get {symbol} price"}, 400
    
    # Prepare buy request
    request_data = {
        "action": mt5.TRADE_ACTION_DEAL,
        "symbol": symbol,
        "volume": volume,
        "type": mt5.ORDER_TYPE_BUY,
        "price": tick.ask,
        "sl": sl,
        "tp": tp,
        "deviation": 20,
        "magic": 12345,
        "comment": comment,
        "type_time": mt5.ORDER_TIME_GTC,
        "type_filling": mt5.ORDER_FILLING_IOC,
    }
    
    # Execute REAL trade on YOUR account
    result = mt5.order_send(request_data)
    
    if result.retcode != mt5.TRADE_RETCODE_DONE:
        return {
            "success": False, 
            "error": f"Trade failed: {result.retcode}",
            "description": result.comment
        }, 400
    
    print(f"✅ REAL BUY TRADE EXECUTED ON YOUR ACCOUNT #{ACCOUNT}")
    print(f"   Symbol: {symbol}, Volume: {volume}, Price: {result.price}")
    
    return {
        "success": True,
        "ticket": int(result.order),
        "price": result.price,
        "volume": result.volume,
        "account": ACCOUNT,
        "message": f"BUY order executed on YOUR Coinexx Demo #{ACCOUNT}"
    }, 200

if __name__ == '__main__':
    print("🚀 Starting MT5 REST API server for Planet ProTrader")
    print(f"📊 Target Account: YOUR Coinexx Demo #{ACCOUNT}")
    print("🔥 This will execute REAL trades on your account!")
    print("⚠️  NOTE: Consider using the One-Click Automated Deployment instead!")
    
    # Start the server
    app.run(host='0.0.0.0', port=8080, debug=True)
"""
    }
}

struct VPSSetupStep: Identifiable {
    let id = UUID()
    let step: Int
    let title: String
    let command: String
    let description: String
    var isCompleted: Bool
    var isAutomated: Bool = false
}

// MARK: - VPS Setup Options View
struct VPSSetupOptionsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingAutomatedSetup = false
    @State private var showingManualSetup = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "server.rack")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Setup Your VPS")
                            .font(DesignSystem.Typography.cosmic)
                            .cosmicText()
                        
                        Text("Choose how you want to deploy your trading server")
                            .font(DesignSystem.Typography.asteroid)
                            .foregroundColor(DesignSystem.starWhite.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .planetCard()
                    
                    // Automated Option (Recommended)
                    VStack(spacing: 20) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("🚀 Automated Setup")
                                        .font(DesignSystem.Typography.stellar)
                                        .fontWeight(.bold)
                                        .cosmicText()
                                    
                                    Text("RECOMMENDED")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(.green, in: Capsule())
                                }
                                
                                Text("One-click deployment with ZERO manual steps")
                                    .font(DesignSystem.Typography.asteroid)
                                    .foregroundColor(DesignSystem.starWhite.opacity(0.8))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "bolt.fill")
                                .font(.title)
                                .foregroundColor(.yellow)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            FeatureRow(icon: "checkmark.circle.fill", text: "Fully automated - just click activate!", color: .green)
                            FeatureRow(icon: "timer", text: "Setup completes in 5-10 minutes", color: .blue)
                            FeatureRow(icon: "shield.checkered", text: "Auto-connects to YOUR account #845638", color: .purple)
                            FeatureRow(icon: "gear.badge.checkmark", text: "Self-healing with auto-restart", color: .orange)
                            FeatureRow(icon: "network", text: "Real-time monitoring & logs", color: .cyan)
                        }
                        
                        Button {
                            showingAutomatedSetup = true
                        } label: {
                            HStack {
                                Image(systemName: "rocket.fill")
                                Text("START AUTOMATED SETUP")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                        }
                        .buttonStyle(.solar)
                    }
                    .planetCard()
                    
                    // Manual Option
                    VStack(spacing: 20) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("🛠️ Manual Setup")
                                    .font(DesignSystem.Typography.stellar)
                                    .cosmicText()
                                
                                Text("Step-by-step instructions for advanced users")
                                    .font(DesignSystem.Typography.asteroid)
                                    .foregroundColor(DesignSystem.starWhite.opacity(0.8))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "terminal")
                                .font(.title)
                                .foregroundColor(.gray)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            FeatureRow(icon: "terminal.fill", text: "SSH commands and scripts", color: .gray)
                            FeatureRow(icon: "clock", text: "30-60 minutes setup time", color: .orange)
                            FeatureRow(icon: "person.fill", text: "Requires technical knowledge", color: .red)
                            FeatureRow(icon: "doc.text", text: "Detailed instructions provided", color: .blue)
                        }
                        
                        Button {
                            showingManualSetup = true
                        } label: {
                            HStack {
                                Image(systemName: "doc.text")
                                Text("VIEW MANUAL INSTRUCTIONS")
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                        }
                        .buttonStyle(.cosmic)
                    }
                    .planetCard()
                    
                    // Warning
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.yellow)
                            Text("Important")
                                .font(DesignSystem.Typography.stellar)
                                .fontWeight(.semibold)
                                .foregroundColor(.yellow)
                        }
                        
                        Text("Both methods will connect to YOUR REAL Coinexx Demo account #845638 and execute ACTUAL trades. Make sure you're ready for live trading!")
                            .font(DesignSystem.Typography.asteroid)
                            .foregroundColor(DesignSystem.starWhite.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .planetCard()
                }
                .padding()
            }
            .starField()
            .navigationTitle("VPS Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(DesignSystem.cosmicBlue)
                }
            }
            .sheet(isPresented: $showingAutomatedSetup) {
                CompleteAutomationView()
            }
            .sheet(isPresented: $showingManualSetup) {
                ManualVPSSetupView()
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(text)
                .font(DesignSystem.Typography.dust)
                .foregroundColor(DesignSystem.starWhite.opacity(0.8))
            
            Spacer()
        }
    }
}

// MARK: - Manual Setup View (Fallback)
struct ManualVPSSetupView: View {
    @StateObject private var setupHelper = VPSSetupHelper.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingScript = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "terminal")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        
                        Text("Manual VPS Setup")
                            .font(DesignSystem.Typography.cosmic)
                            .cosmicText()
                        
                        Text("Advanced setup for technical users")
                            .font(DesignSystem.Typography.asteroid)
                            .foregroundColor(DesignSystem.starWhite.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .planetCard()
                    
                    // Recommendation Banner
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.yellow)
                            Text("💡 Recommendation")
                                .font(DesignSystem.Typography.stellar)
                                .fontWeight(.semibold)
                                .cosmicText()
                        }
                        
                        Text("The automated setup is much faster and easier! Consider using that instead unless you specifically need manual control.")
                            .font(DesignSystem.Typography.asteroid)
                            .foregroundColor(DesignSystem.starWhite.opacity(0.8))
                            .multilineTextAlignment(.center)
                        
                        Button("Use Automated Setup Instead") {
                            dismiss()
                        }
                        .buttonStyle(.solar)
                    }
                    .planetCard()
                    
                    // Quick Script Generation
                    VStack(spacing: 16) {
                        Text("🐍 Quick Script Generation")
                            .font(DesignSystem.Typography.stellar)
                            .cosmicText()
                        
                        Button("Generate Complete Setup Script") {
                            showingScript = true
                        }
                        .buttonStyle(.cosmic)
                        .frame(maxWidth: .infinity)
                        
                        Text("This will generate a complete Python script configured for YOUR account that you can run on your VPS.")
                            .font(DesignSystem.Typography.dust)
                            .foregroundColor(DesignSystem.starWhite.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .planetCard()
                    
                    // Manual Steps (for reference)
                    VStack(spacing: 16) {
                        Text("📋 Manual Steps Reference")
                            .font(DesignSystem.Typography.stellar)
                            .cosmicText()
                        
                        LazyVStack(spacing: 12) {
                            ForEach(setupHelper.setupInstructions.filter { !$0.isAutomated }) { step in
                                ManualStepCard(step: step)
                            }
                        }
                    }
                    .planetCard()
                }
                .padding()
            }
            .starField()
            .navigationTitle("Manual Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(DesignSystem.cosmicBlue)
                }
            }
            .sheet(isPresented: $showingScript) {
                VPSScriptView()
            }
        }
    }
}

struct ManualStepCard: View {
    let step: VPSSetupStep
    @State private var showingCommand = false
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(step.isCompleted ? .green : DesignSystem.cosmicBlue.opacity(0.3))
                        .frame(width: 32, height: 32)
                    
                    if step.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Text("\(step.step)")
                            .font(DesignSystem.Typography.dust)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(step.title)
                        .font(DesignSystem.Typography.asteroid)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(step.description)
                        .font(DesignSystem.Typography.dust)
                        .foregroundColor(DesignSystem.starWhite.opacity(0.7))
                }
                
                Spacer()
                
                Button(showingCommand ? "Hide" : "Show") {
                    showingCommand.toggle()
                }
                .font(DesignSystem.Typography.dust)
                .foregroundColor(DesignSystem.cosmicBlue)
            }
            
            if showingCommand {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Command:")
                        .font(DesignSystem.Typography.dust)
                        .foregroundColor(DesignSystem.starWhite.opacity(0.7))
                    
                    Text(step.command)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.green)
                        .padding(8)
                        .background(.black.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(step.isCompleted ? .green.opacity(0.5) : DesignSystem.cosmicBlue.opacity(0.3), lineWidth: 1)
        )
    }
}

struct VPSScriptView: View {
    @StateObject private var setupHelper = VPSSetupHelper.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Copy this script to your VPS and run it:")
                        .font(DesignSystem.Typography.planet)
                        .cosmicText()
                    
                    ScrollView {
                        Text(setupHelper.generateMT5APIScript())
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.green)
                            .padding()
                            .background(.black.opacity(0.8), in: RoundedRectangle(cornerRadius: 12))
                    }
                    .frame(maxHeight: 400)
                    
                    VStack(spacing: 12) {
                        Text("📝 Instructions:")
                            .font(DesignSystem.Typography.asteroid)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("1. SSH into your VPS: ssh root@172.234.201.231")
                            Text("2. Create file: nano mt5_api.py")
                            Text("3. Paste the script above")
                            Text("4. Save and exit: Ctrl+X, Y, Enter")
                            Text("5. Run: python3 mt5_api.py")
                        }
                        .font(DesignSystem.Typography.dust)
                        .foregroundColor(DesignSystem.starWhite.opacity(0.8))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .planetCard()
                    
                    // Recommendation
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.yellow)
                            Text("Still Recommend Automation")
                                .font(DesignSystem.Typography.stellar)
                                .fontWeight(.semibold)
                                .foregroundColor(.yellow)
                        }
                        
                        Text("The automated deployment handles all of this for you, plus error handling, auto-restart, logging, and more!")
                            .font(DesignSystem.Typography.asteroid)
                            .foregroundColor(DesignSystem.starWhite.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .planetCard()
                }
                .padding()
            }
            .starField()
            .navigationTitle("MT5 API Script")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(DesignSystem.cosmicBlue)
                }
            }
        }
    }
}

#Preview {
    VPSSetupOptionsView()
}
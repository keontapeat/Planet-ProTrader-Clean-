//
//  VPSSetupView.swift
//  Planet ProTrader - VPS Setup Interface
//
//  Professional VPS setup and management interface
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

// MARK: - VPS Setup View
struct VPSSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var audioManager = AudioManager.shared
    @State private var selectedProvider = "DigitalOcean"
    @State private var serverRegion = "New York"
    @State private var serverSize = "Basic ($5/month)"
    @State private var isConnecting = false
    @State private var connectionStatus = "Not Connected"
    @State private var animateCards = false
    
    private let vpsProviders = ["DigitalOcean", "AWS", "Google Cloud", "Vultr", "Linode"]
    private let regions = ["New York", "San Francisco", "London", "Singapore", "Frankfurt"]
    private let serverSizes = ["Basic ($5/month)", "Standard ($10/month)", "Premium ($20/month)", "Pro ($40/month)"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Space Background
                DesignSystem.spaceGradient.ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 24) {
                        // Header Section
                        headerSection
                        
                        // Connection Status
                        statusSection
                        
                        // Provider Selection
                        providerSection
                        
                        // Server Configuration
                        configurationSection
                        
                        // Action Buttons
                        actionSection
                        
                        // Information Section
                        infoSection
                    }
                    .padding()
                }
            }
            .navigationTitle("VPS Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                        // FIXED: Wrap async call in Task
                        Task {
                            await audioManager.playButtonTap()
                        }
                    }
                    .foregroundColor(.blue)
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 0.6)) {
                    animateCards = true
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "server.rack")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple, .blue, .cyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("🖥️ VPS Server Setup")
                .font(.title.bold())
                .foregroundColor(.white)
            
            Text("Deploy your trading bots to a professional Virtual Private Server for 24/7 operation")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .opacity(animateCards ? 1 : 0)
        .animation(.easeInOut.delay(0.1), value: animateCards)
    }
    
    private var statusSection: some View {
        VStack(spacing: 12) {
            Text("📡 Connection Status")
                .font(.headline.bold())
                .foregroundColor(.white)
            
            HStack {
                Circle()
                    .fill(connectionStatus == "Connected" ? .green : .red)
                    .frame(width: 12, height: 12)
                
                Text(connectionStatus)
                    .font(.subheadline.bold())
                    .foregroundColor(connectionStatus == "Connected" ? .green : .red)
                
                Spacer()
                
                if isConnecting {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.blue)
                }
            }
            .padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            )
        }
        .opacity(animateCards ? 1 : 0)
        .animation(.easeInOut.delay(0.2), value: animateCards)
    }
    
    private var providerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("☁️ VPS Provider")
                .font(.headline.bold())
                .foregroundColor(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(vpsProviders, id: \.self) { provider in
                    Button(action: {
                        selectedProvider = provider
                        // FIXED: Wrap async call in Task
                        Task {
                            await audioManager.playButtonTap()
                        }
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: getProviderIcon(provider))
                                .font(.title2)
                                .foregroundColor(selectedProvider == provider ? .blue : .gray)
                            
                            Text(provider)
                                .font(.caption.bold())
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background {
                            if selectedProvider == provider {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.blue.opacity(0.2))
                            } else {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.ultraThinMaterial)
                            }
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(selectedProvider == provider ? .blue : .clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .opacity(animateCards ? 1 : 0)
        .animation(.easeInOut.delay(0.3), value: animateCards)
    }
    
    private var configurationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("⚙️ Server Configuration")
                .font(.headline.bold())
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                // Region Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Server Region")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                    
                    Picker("Region", selection: $serverRegion) {
                        ForEach(regions, id: \.self) { region in
                            Text(region).tag(region)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.blue)
                    .padding(12)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                }
                
                // Server Size Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Server Size & Pricing")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                    
                    Picker("Size", selection: $serverSize) {
                        ForEach(serverSizes, id: \.self) { size in
                            Text(size).tag(size)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.green)
                    .padding(12)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .opacity(animateCards ? 1 : 0)
        .animation(.easeInOut.delay(0.4), value: animateCards)
    }
    
    private var actionSection: some View {
        VStack(spacing: 12) {
            // Main Action Button
            Button(action: {
                connectToVPS()
            }) {
                HStack {
                    if isConnecting {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.white)
                    } else {
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                    }
                    
                    Text(isConnecting ? "Connecting..." : "Deploy VPS Server")
                        .font(.title3.bold())
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: RoundedRectangle(cornerRadius: 12)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .disabled(isConnecting)
            
            // Secondary Actions
            HStack(spacing: 12) {
                Button("Test Connection") {
                    testConnection()
                }
                .font(.subheadline.bold())
                .foregroundColor(.orange)
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                
                Button("View Logs") {
                    viewLogs()
                }
                .font(.subheadline.bold())
                .foregroundColor(.cyan)
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
            }
        }
        .opacity(animateCards ? 1 : 0)
        .animation(.easeInOut.delay(0.5), value: animateCards)
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ℹ️ Important Information")
                .font(.headline.bold())
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 8) {
                VPSInfoRow(icon: "checkmark.circle", text: "24/7 uptime for continuous trading")
                VPSInfoRow(icon: "shield.fill", text: "Secure encrypted connections")
                VPSInfoRow(icon: "speedometer", text: "Low latency trading execution")
                VPSInfoRow(icon: "dollarsign.circle", text: "Pay only for what you use")
                VPSInfoRow(icon: "gear", text: "Automatic bot deployment")
            }
            .padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
        }
        .opacity(animateCards ? 1 : 0)
        .animation(.easeInOut.delay(0.6), value: animateCards)
    }
    
    // MARK: - Helper Functions
    
    private func getProviderIcon(_ provider: String) -> String {
        switch provider {
        case "DigitalOcean": return "water.waves"
        case "AWS": return "cloud.fill"
        case "Google Cloud": return "globe"
        case "Vultr": return "flame.fill"
        case "Linode": return "square.stack.3d.up.fill"
        default: return "server.rack"
        }
    }
    
    private func connectToVPS() {
        isConnecting = true
        // FIXED: Wrap async call in Task
        Task {
            await audioManager.playDeploy()
        }
        
        // Simulate connection process
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            isConnecting = false
            connectionStatus = "Connected"
            // FIXED: Wrap async call in Task
            Task {
                await audioManager.playSuccess()
            }
            
            GlobalToastManager.shared.show("🎉 VPS Server deployed successfully!", type: .success)
        }
    }
    
    private func testConnection() {
        // FIXED: Wrap async call in Task
        Task {
            await audioManager.playButtonTap()
        }
        GlobalToastManager.shared.show("🔍 Testing connection to \(selectedProvider)...", type: .info)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            GlobalToastManager.shared.show("✅ Connection test successful!", type: .success)
        }
    }
    
    private func viewLogs() {
        // FIXED: Wrap async call in Task
        Task {
            await audioManager.playButtonTap()
        }
        GlobalToastManager.shared.show("📋 VPS logs - Coming soon!", type: .info)
    }
}

// MARK: - Supporting Views
struct VPSInfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.green)
                .frame(width: 16)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white)
            
            Spacer()
        }
    }
}

// MARK: - Preview
#Preview {
    VPSSetupView()
}
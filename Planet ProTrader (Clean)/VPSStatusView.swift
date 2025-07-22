//
//  VPSStatusView.swift
//  Planet ProTrader - VPS Status Component
//
//  Real-time VPS Health Status Display
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

struct VPSStatusView: View {
    @StateObject private var vpsViewModel = VPSStatusViewModel()
    @State private var showingDetails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("VPS Connection")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                if vpsViewModel.isCheckingStatus {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Button("Refresh") {
                        vpsViewModel.refreshStatus()
                    }
                    .font(.caption)
                    .foregroundColor(DesignSystem.primaryGold)
                }
            }
            
            HStack {
                Image(systemName: vpsViewModel.connectionStatus.icon)
                    .font(.title2)
                    .foregroundColor(vpsViewModel.connectionStatus.color)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(vpsViewModel.connectionStatus.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(vpsViewModel.connectionStatus.color)
                    
                    if let serverInfo = vpsViewModel.serverInfo {
                        Text("Linode VPS - \(serverInfo.ip)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("172.234.201.231 - Chicago, IL")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if let serverInfo = vpsViewModel.serverInfo {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(serverInfo.healthStatus)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(serverInfo.healthColor)
                        
                        Text("CPU: \(Int(serverInfo.cpuUsage))%")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            if let errorMessage = vpsViewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.top, 4)
            }
            
            if let lastChecked = vpsViewModel.lastChecked {
                Text("Last checked: \(lastChecked, format: .dateTime.hour().minute())")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .standardCard()
        .onTapGesture {
            showingDetails = true
        }
        .sheet(isPresented: $showingDetails) {
            VPSDetailView(viewModel: vpsViewModel)
        }
        .onAppear {
            if vpsViewModel.serverInfo == nil {
                vpsViewModel.refreshStatus()
            }
        }
    }
}

struct VPSDetailView: View {
    @ObservedObject var viewModel: VPSStatusViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Connection Status
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: viewModel.connectionStatus.icon)
                                .font(.title)
                                .foregroundColor(viewModel.connectionStatus.color)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(viewModel.connectionStatus.rawValue)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(viewModel.connectionStatus.color)
                                
                                Text("Linode VPS Status")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                    }
                    .standardCard()
                    
                    // Server Information
                    if let serverInfo = viewModel.serverInfo {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Server Details")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            VStack(spacing: 12) {
                                DetailRow(title: "IP Address", value: serverInfo.ip)
                                DetailRow(title: "Region", value: serverInfo.region)
                                DetailRow(title: "Uptime", value: serverInfo.uptime)
                                DetailRow(title: "Health Status", value: serverInfo.healthStatus, valueColor: serverInfo.healthColor)
                                DetailRow(title: "Active Connections", value: "\(serverInfo.activeConnections)")
                            }
                        }
                        .standardCard()
                        
                        // Performance Metrics
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Performance Metrics")
                                .font(.headline)
                                .fontWeight(.bold()
                            
                            VStack(spacing: 12) {
                                MetricRow(title: "CPU Usage", value: serverInfo.cpuUsage, unit: "%", maxValue: 100)
                                MetricRow(title: "Memory Usage", value: serverInfo.memoryUsage, unit: "%", maxValue: 100)
                                MetricRow(title: "Disk Usage", value: serverInfo.diskUsage, unit: "%", maxValue: 100)
                            }
                        }
                        .standardCard()
                    }
                    
                    // Actions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Actions")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 8) {
                            Button("Refresh Status") {
                                viewModel.refreshStatus()
                            }
                            .buttonStyle(.primary)
                            .disabled(viewModel.isCheckingStatus)
                            
                            Button("View Logs") {
                                // Navigate to logs
                            }
                            .buttonStyle(.secondary)
                            
                            Button("Restart Services") {
                                // Restart VPS services
                            }
                            .buttonStyle(.secondary)
                        }
                    }
                    .standardCard()
                }
                .padding()
            }
            .navigationTitle("VPS Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    let valueColor: Color?
    
    init(title: String, value: String, valueColor: Color? = nil) {
        self.title = title
        self.value = value
        self.valueColor = valueColor
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(valueColor ?? .primary)
        }
    }
}

struct MetricRow: View {
    let title: String
    let value: Double
    let unit: String
    let maxValue: Double
    
    var progressValue: Double {
        min(value / maxValue, 1.0)
    }
    
    var progressColor: Color {
        if value > maxValue * 0.9 { return .red }
        else if value > maxValue * 0.75 { return .orange }
        else { return .green }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(String(format: "%.1f", value))\(unit)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(progressColor)
            }
            
            ProgressView(value: progressValue)
                .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
        }
    }
}

// Secondary button style
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.headline)
            .foregroundColor(DesignSystem.primaryGold)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .stroke(DesignSystem.primaryGold, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(DesignSystem.Animation.quick, value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static var secondary: SecondaryButtonStyle { SecondaryButtonStyle() }
}

#Preview {
    VPSStatusView()
        .padding()
}
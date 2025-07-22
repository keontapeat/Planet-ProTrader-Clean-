//
//  SelfHealingDashboard.swift
//  Planet ProTrader - Self-Healing Dashboard
//
//  Advanced System Health & Auto-Healing Interface
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI
import Foundation

// MARK: - Self-Healing Dashboard View
struct SelfHealingDashboard: View {
    @StateObject private var selfHealingSystem = SelfHealingSystem.shared
    @StateObject private var vpsMonitor = VPSHealthMonitor()
    @State private var selectedTab = 0
    @State private var showingLogDetails = false
    @State private var selectedIssue: SelfHealingSystem.SystemIssue?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with system status
                systemStatusHeader
                
                // Tab selector
                tabSelector
                
                // Content based on selected tab
                TabView(selection: $selectedTab) {
                    // Overview Tab
                    overviewTab
                        .tag(0)
                    
                    // Active Issues Tab
                    activeIssuesTab
                        .tag(1)
                    
                    // Healing History Tab
                    healingHistoryTab
                        .tag(2)
                    
                    // Performance Metrics Tab
                    performanceMetricsTab
                        .tag(3)
                    
                    // Debug Logs Tab
                    debugLogsTab
                        .tag(4)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("🤖 Self-Healing System")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await selfHealingSystem.performHealthCheck()
            }
            .sheet(item: $selectedIssue) { issue in
                IssueDetailView(issue: issue)
            }
            .sheet(isPresented: $showingLogDetails) {
                LogDetailView(logs: selfHealingSystem.debugLogs)
            }
        }
        .onAppear {
            if !selfHealingSystem.isMonitoring {
                selfHealingSystem.startMonitoring()
            }
        }
    }
    
    // MARK: - System Status Header
    private var systemStatusHeader: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("System Health")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: selfHealingSystem.systemHealth.icon)
                            .font(.title2)
                            .foregroundColor(selfHealingSystem.systemHealth.color)
                        
                        Text(selfHealingSystem.systemHealth.rawValue)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(selfHealingSystem.systemHealth.color)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    if selfHealingSystem.isMonitoring {
                        HStack {
                            Circle()
                                .fill(.green)
                                .frame(width: 8, height: 8)
                                .pulseEffect()
                            
                            Text("MONITORING")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                    }
                    
                    if let lastCheck = selfHealingSystem.lastHealthCheck {
                        Text("Updated \(lastCheck, format: .dateTime.hour().minute())")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Quick stats
            HStack(spacing: 16) {
                StatPill(
                    title: "Active Issues",
                    value: "\(selfHealingSystem.activeIssues.filter { !$0.isResolved }.count)",
                    color: selfHealingSystem.activeIssues.isEmpty ? .green : .red
                )
                
                StatPill(
                    title: "Healing Actions",
                    value: "\(selfHealingSystem.healingHistory.filter { $0.status == .completed }.count)",
                    color: .blue
                )
                
                StatPill(
                    title: "Uptime",
                    value: formatUptime(selfHealingSystem.performanceMetrics.uptime),
                    color: .green
                )
                
                StatPill(
                    title: "Performance",
                    value: "\(Int(selfHealingSystem.performanceMetrics.overallScore))%",
                    color: selfHealingSystem.performanceMetrics.healthStatus.color
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(selfHealingSystem.systemHealth.color.opacity(0.3), lineWidth: 1)
        )
        .padding()
    }
    
    // MARK: - Tab Selector
    private var tabSelector: some View {
        HStack(spacing: 0) {
            TabButton(title: "Overview", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            
            TabButton(title: "Issues", isSelected: selectedTab == 1, badge: selfHealingSystem.activeIssues.filter { !$0.isResolved }.count) {
                selectedTab = 1
            }
            
            TabButton(title: "Healing", isSelected: selectedTab == 2) {
                selectedTab = 2
            }
            
            TabButton(title: "Metrics", isSelected: selectedTab == 3) {
                selectedTab = 3
            }
            
            TabButton(title: "Logs", isSelected: selectedTab == 4, badge: selfHealingSystem.debugLogs.filter { $0.level == .error || $0.level == .critical }.count) {
                selectedTab = 4
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Overview Tab
    private var overviewTab: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // System health description
                VStack(alignment: .leading, spacing: 8) {
                    Text("System Analysis")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(selfHealingSystem.systemHealth.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .standardCard()
                
                // Recent activity
                recentActivitySection
                
                // VPS health status
                vpsHealthSection
                
                // Quick actions
                quickActionsSection
            }
            .padding()
        }
    }
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.headline)
                .fontWeight(.bold)
            
            if selfHealingSystem.healingHistory.isEmpty {
                EmptyStateView(
                    icon: "clock",
                    title: "No Recent Activity",
                    subtitle: "System healing actions will appear here",
                    color: .gray
                )
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(selfHealingSystem.healingHistory.prefix(5), id: \.id) { action in
                        HealingActionRow(action: action)
                    }
                }
            }
        }
        .standardCard()
    }
    
    private var vpsHealthSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("VPS Health Status")
                .font(.headline)
                .fontWeight(.bold)
            
            HStack {
                Image(systemName: vpsMonitor.vpsHealth.icon)
                    .font(.title2)
                    .foregroundColor(vpsMonitor.vpsHealth.color)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(vpsMonitor.vpsHealth.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("Linode VPS - 172.234.201.231")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let metrics = vpsMonitor.linodeMetrics {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("CPU: \(Int(metrics.cpuUsage))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("RAM: \(Int(metrics.memoryUsage))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .standardCard()
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.bold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ActionButton(
                    title: "Force Health Check",
                    icon: "stethoscope",
                    color: .blue
                ) {
                    Task {
                        await selfHealingSystem.performHealthCheck()
                    }
                }
                
                ActionButton(
                    title: "Clear Resolved Issues",
                    icon: "trash",
                    color: .orange
                ) {
                    selfHealingSystem.activeIssues.removeAll { $0.isResolved }
                }
                
                ActionButton(
                    title: "Export Logs",
                    icon: "square.and.arrow.up",
                    color: .green
                ) {
                    // Export logs functionality
                }
                
                ActionButton(
                    title: "Reset System",
                    icon: "arrow.clockwise",
                    color: .red
                ) {
                    // Reset system functionality
                }
            }
        }
        .standardCard()
    }
    
    // MARK: - Active Issues Tab
    private var activeIssuesTab: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if selfHealingSystem.activeIssues.filter({ !$0.isResolved }).isEmpty {
                    EmptyStateView(
                        icon: "checkmark.shield",
                        title: "No Active Issues",
                        subtitle: "All systems are running smoothly",
                        color: .green
                    )
                    .padding(.top, 50)
                } else {
                    ForEach(selfHealingSystem.activeIssues.filter { !$0.isResolved }, id: \.id) { issue in
                        IssueCard(issue: issue) {
                            selectedIssue = issue
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Healing History Tab
    private var healingHistoryTab: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if selfHealingSystem.healingHistory.isEmpty {
                    EmptyStateView(
                        icon: "wrench.and.screwdriver",
                        title: "No Healing History",
                        subtitle: "Healing actions will appear here when performed",
                        color: .gray
                    )
                    .padding(.top, 50)
                } else {
                    ForEach(selfHealingSystem.healingHistory.reversed(), id: \.id) { action in
                        HealingActionCard(action: action)
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Performance Metrics Tab
    private var performanceMetricsTab: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Overall performance score
                PerformanceScoreCard(metrics: selfHealingSystem.performanceMetrics)
                
                // Individual metrics
                MetricsGrid(metrics: selfHealingSystem.performanceMetrics)
                
                // Performance chart placeholder
                VStack(alignment: .leading, spacing: 12) {
                    Text("Performance Trends")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("📊 Performance charts coming soon")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 120)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
                .standardCard()
            }
            .padding()
        }
    }
    
    // MARK: - Debug Logs Tab
    private var debugLogsTab: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                if selfHealingSystem.debugLogs.isEmpty {
                    EmptyStateView(
                        icon: "doc.text",
                        title: "No Debug Logs",
                        subtitle: "System logs will appear here",
                        color: .gray
                    )
                    .padding(.top, 50)
                } else {
                    ForEach(selfHealingSystem.debugLogs.reversed().prefix(100), id: \.id) { log in
                        LogRow(log: log)
                    }
                }
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("View All") {
                    showingLogDetails = true
                }
            }
        }
    }
    
    // Helper functions
    private func formatUptime(_ uptime: TimeInterval) -> String {
        let hours = Int(uptime / 3600)
        let days = hours / 24
        
        if days > 0 {
            return "\(days)d"
        } else {
            return "\(hours)h"
        }
    }
}

// MARK: - Supporting Views
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }
}

struct StatPill: View {
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
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let badge: Int
    let action: () -> Void
    
    init(title: String, isSelected: Bool, badge: Int = 0, action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.badge = badge
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? DesignSystem.primaryGold : .secondary)
                
                if badge > 0 {
                    Text("\(badge)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.red, in: Capsule())
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                isSelected ? DesignSystem.primaryGold.opacity(0.1) : .clear,
                in: RoundedRectangle(cornerRadius: 8)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct HealingActionRow: View {
    let action: SelfHealingSystem.HealingAction
    
    var body: some View {
        HStack {
            Circle()
                .fill(action.status.color)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(action.action)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(action.timestamp, format: .dateTime.hour().minute())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(action.status.rawValue)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(action.status.color)
        }
        .padding(.vertical, 4)
    }
}

struct IssueCard: View {
    let issue: SelfHealingSystem.SystemIssue
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: issue.type.icon)
                    .font(.title2)
                    .foregroundColor(issue.severity.color)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(issue.type.rawValue)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(issue.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack {
                        Text(issue.severity.rawValue)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(issue.severity.color, in: Capsule())
                        
                        Spacer()
                        
                        Text(issue.timestamp, format: .dateTime.hour().minute())
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct HealingActionCard: View {
    let action: SelfHealingSystem.HealingAction
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(action.action)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(action.status.rawValue)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(action.status.color, in: Capsule())
            }
            
            if let result = action.result {
                Text(result)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text(action.timestamp, format: .dateTime.hour().minute())
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let duration = action.duration {
                    Text("Duration: \(String(format: "%.1f", duration))s")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .standardCard()
    }
}

struct PerformanceScoreCard: View {
    let metrics: SelfHealingSystem.PerformanceMetrics
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Overall Performance Score")
                .font(.headline)
                .fontWeight(.bold)
            
            ZStack {
                Circle()
                    .stroke(.quaternary, lineWidth: 8)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: metrics.overallScore / 100)
                    .stroke(metrics.healthStatus.color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                
                VStack {
                    Text("\(Int(metrics.overallScore))")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(metrics.healthStatus.color)
                    
                    Text("SCORE")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
            }
        }
        .standardCard()
    }
}

struct MetricsGrid: View {
    let metrics: SelfHealingSystem.PerformanceMetrics
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
            MetricCard(title: "CPU Usage", value: "\(Int(metrics.cpuUsage))%", color: metrics.cpuUsage > 80 ? .red : .green)
            MetricCard(title: "Memory Usage", value: "\(Int(metrics.memoryUsage))%", color: metrics.memoryUsage > 80 ? .red : .green)
            MetricCard(title: "Network Latency", value: "\(Int(metrics.networkLatency))ms", color: metrics.networkLatency > 100 ? .red : .green)
            MetricCard(title: "Response Time", value: "\(String(format: "%.1f", metrics.responseTime))s", color: metrics.responseTime > 1 ? .red : .green)
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct LogRow: View {
    let log: SelfHealingSystem.DebugLog
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: log.level.icon)
                .font(.caption)
                .foregroundColor(log.level.color)
                .frame(width: 16)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(log.level.rawValue)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(log.level.color)
                    
                    Text(log.component)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(log.timestamp, format: .dateTime.hour().minute().second())
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Text(log.message)
                    .font(.caption)
                    .foregroundColor(.primary)
                
                if let details = log.details {
                    Text(details)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct IssueDetailView: View {
    let issue: SelfHealingSystem.SystemIssue
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Issue header
                    HStack {
                        Image(systemName: issue.type.icon)
                            .font(.title)
                            .foregroundColor(issue.severity.color)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(issue.type.rawValue)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(issue.component)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .standardCard()
                    
                    // Issue details
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Description")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text(issue.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .standardCard()
                    
                    // Healing actions if any
                    if !issue.healingActions.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Healing Actions")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            ForEach(issue.healingActions, id: \.id) { action in
                                HealingActionRow(action: action)
                            }
                        }
                        .standardCard()
                    }
                }
                .padding()
            }
            .navigationTitle("Issue Details")
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

struct LogDetailView: View {
    let logs: [SelfHealingSystem.DebugLog]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(logs.reversed(), id: \.id) { log in
                    LogRow(log: log)
                }
            }
            .navigationTitle("Debug Logs")
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

#Preview {
    SelfHealingDashboard()
}
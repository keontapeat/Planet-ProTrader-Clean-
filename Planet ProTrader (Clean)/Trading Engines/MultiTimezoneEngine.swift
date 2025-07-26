//
//  MultiTimezoneEngine.swift
//  Planet ProTrader (Clean)
//
//  Multi-Timezone Trading Coordination Engine
//  Created by AI Assistant on 1/25/25.
//

import Foundation
import Combine
import SwiftUI

// MARK: - Multi-Timezone Trading Coordination Engine
@MainActor
class MultiTimezoneEngine: ObservableObject {
    @Published var globalAccuracy: Double = 0.0
    @Published var activeRegions: [TradingRegion] = []
    @Published var totalAccounts: Int = 0
    @Published var activeAccounts: Int = 0
    @Published var isCoordinating: Bool = false
    @Published var synchronizationStatus: SynchronizationStatus = .synchronized
    @Published var latencyMetrics: LatencyMetrics = LatencyMetrics()
    @Published var globalPerformance: GlobalPerformance = GlobalPerformance()
    
    private var cancellables = Set<AnyCancellable>()
    
    enum TradingRegion: String, CaseIterable {
        case us = "United States"
        case eu = "Europe"
        case asia = "Asia"
        case canada = "Canada"
        case uk = "United Kingdom"
        case australia = "Australia"
        
        var timezone: TimeZone {
            switch self {
            case .us: return TimeZone(identifier: "America/New_York")!
            case .eu: return TimeZone(identifier: "Europe/London")!
            case .asia: return TimeZone(identifier: "Asia/Tokyo")!
            case .canada: return TimeZone(identifier: "America/Toronto")!
            case .uk: return TimeZone(identifier: "Europe/London")!
            case .australia: return TimeZone(identifier: "Australia/Sydney")!
            }
        }
        
        var color: Color {
            switch self {
            case .us: return .blue
            case .eu: return .green
            case .asia: return .red
            case .canada: return .purple
            case .uk: return .orange
            case .australia: return .yellow
            }
        }
    }
    
    enum SynchronizationStatus: String, CaseIterable {
        case synchronized = "Synchronized"
        case syncing = "Syncing"
        case partialSync = "Partial Sync"
        case desynchronized = "Desynchronized"
        case offline = "Offline"
        
        var color: Color {
            switch self {
            case .synchronized: return .green
            case .syncing: return .yellow
            case .partialSync: return .orange
            case .desynchronized: return .red
            case .offline: return .gray
            }
        }
    }
    
    struct LatencyMetrics {
        var averageLatency: Double = 0.0
        var maxLatency: Double = 0.0
        var minLatency: Double = 0.0
        var regionalLatencies: [TradingRegion: Double] = [:]
        var lastMeasurement: Date = Date()
        var slaCompliance: Double = 0.0
        var targetLatency: Double = 50.0 // ms
        
        var healthColor: Color {
            if averageLatency < targetLatency { return .green }
            else if averageLatency < targetLatency * 1.5 { return .orange }
            else { return .red }
        }
        
        var formattedAverage: String {
            String(format: "%.1f ms", averageLatency)
        }
    }
    
    struct GlobalPerformance {
        var totalAccuracy: Double = 0.0
        var totalTrades: Int = 0
        var totalProfit: Double = 0.0
        var winRate: Double = 0.0
        var profitFactor: Double = 0.0
        var maxDrawdown: Double = 0.0
        var regionalContributions: [TradingRegion: Double] = [:]
        var bestRegion: TradingRegion?
        var worstRegion: TradingRegion?
        var lastUpdate: Date = Date()
        
        var formattedProfit: String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = "USD"
            return formatter.string(from: NSNumber(value: totalProfit)) ?? "$0"
        }
        
        var formattedWinRate: String {
            String(format: "%.1f%%", winRate * 100)
        }
    }
    
    init() {
        setupRegions()
        startCoordination()
        initializeMetrics()
    }
    
    private func setupRegions() {
        activeRegions = TradingRegion.allCases
        totalAccounts = 1000
        activeAccounts = 847
        globalAccuracy = 0.942
    }
    
    private func initializeMetrics() {
        // Initialize latency metrics for each region
        for region in activeRegions {
            latencyMetrics.regionalLatencies[region] = Double.random(in: 10...60)
        }
        
        latencyMetrics.averageLatency = latencyMetrics.regionalLatencies.values.reduce(0, +) / Double(latencyMetrics.regionalLatencies.count)
        latencyMetrics.maxLatency = latencyMetrics.regionalLatencies.values.max() ?? 0
        latencyMetrics.minLatency = latencyMetrics.regionalLatencies.values.min() ?? 0
        latencyMetrics.slaCompliance = latencyMetrics.averageLatency < latencyMetrics.targetLatency ? 1.0 : 0.8
        
        // Initialize global performance
        globalPerformance.totalAccuracy = globalAccuracy
        globalPerformance.winRate = Double.random(in: 0.65...0.85)
        globalPerformance.profitFactor = Double.random(in: 1.2...2.1)
        globalPerformance.totalTrades = Int.random(in: 1000...5000)
        globalPerformance.totalProfit = Double.random(in: 50000...250000)
        globalPerformance.maxDrawdown = Double.random(in: 0.05...0.15)
        
        // Set regional contributions
        for region in activeRegions {
            globalPerformance.regionalContributions[region] = Double.random(in: 10000...50000)
        }
        
        // Find best and worst regions
        if let bestRegion = globalPerformance.regionalContributions.max(by: { $0.value < $1.value }) {
            globalPerformance.bestRegion = bestRegion.key
        }
        if let worstRegion = globalPerformance.regionalContributions.min(by: { $0.value < $1.value }) {
            globalPerformance.worstRegion = worstRegion.key
        }
    }
    
    private func startCoordination() {
        Timer.publish(every: 5.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task {
                    await self?.performCoordination()
                }
            }
            .store(in: &cancellables)
    }
    
    func performCoordination() async {
        isCoordinating = true
        
        // Simulate coordination work
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Update metrics
        updateLatencyMetrics()
        updateGlobalPerformance()
        
        isCoordinating = false
    }
    
    private func updateLatencyMetrics() {
        // Simulate latency updates
        for region in activeRegions {
            let currentLatency = latencyMetrics.regionalLatencies[region] ?? 0
            let variation = Double.random(in: -5...5)
            let newLatency = max(5, min(100, currentLatency + variation))
            latencyMetrics.regionalLatencies[region] = newLatency
        }
        
        latencyMetrics.averageLatency = latencyMetrics.regionalLatencies.values.reduce(0, +) / Double(latencyMetrics.regionalLatencies.count)
        latencyMetrics.maxLatency = latencyMetrics.regionalLatencies.values.max() ?? 0
        latencyMetrics.minLatency = latencyMetrics.regionalLatencies.values.min() ?? 0
        latencyMetrics.slaCompliance = latencyMetrics.averageLatency < latencyMetrics.targetLatency ? 1.0 : 0.8
        latencyMetrics.lastMeasurement = Date()
    }
    
    private func updateGlobalPerformance() {
        // Simulate performance updates
        globalAccuracy = Double.random(in: 0.85...0.98)
        activeAccounts = Int.random(in: 800...1000)
        
        globalPerformance.totalAccuracy = globalAccuracy
        globalPerformance.winRate = max(0.5, min(0.95, globalPerformance.winRate + Double.random(in: -0.02...0.02)))
        globalPerformance.profitFactor = max(1.0, min(3.0, globalPerformance.profitFactor + Double.random(in: -0.1...0.1)))
        globalPerformance.totalTrades += Int.random(in: 0...10)
        globalPerformance.totalProfit += Double.random(in: -1000...5000)
        globalPerformance.lastUpdate = Date()
        
        // Update regional contributions
        for region in activeRegions {
            let currentContribution = globalPerformance.regionalContributions[region] ?? 0
            let change = Double.random(in: -2000...3000)
            globalPerformance.regionalContributions[region] = max(0, currentContribution + change)
        }
        
        // Update best/worst regions
        if let bestRegion = globalPerformance.regionalContributions.max(by: { $0.value < $1.value }) {
            globalPerformance.bestRegion = bestRegion.key
        }
        if let worstRegion = globalPerformance.regionalContributions.min(by: { $0.value < $1.value }) {
            globalPerformance.worstRegion = worstRegion.key
        }
    }
    
    func getCoordinationSummary() -> CoordinationSummary {
        return CoordinationSummary(
            globalAccuracy: globalAccuracy,
            totalAccounts: totalAccounts,
            activeAccounts: activeAccounts,
            activeRegions: activeRegions.count,
            averageLatency: latencyMetrics.averageLatency,
            systemHealth: calculateSystemHealth(),
            lastUpdate: Date()
        )
    }
    
    private func calculateSystemHealth() -> Double {
        let accuracyWeight = 0.4
        let latencyWeight = 0.3
        let accountWeight = 0.2
        let performanceWeight = 0.1
        
        let accuracyScore = globalAccuracy
        let latencyScore = latencyMetrics.slaCompliance
        let accountScore = Double(activeAccounts) / Double(totalAccounts)
        let performanceScore = globalPerformance.winRate
        
        return (accuracyScore * accuracyWeight) +
               (latencyScore * latencyWeight) +
               (accountScore * accountWeight) +
               (performanceScore * performanceWeight)
    }
    
    func getRegionalPerformance() -> [RegionalPerformance] {
        return activeRegions.map { region in
            RegionalPerformance(
                region: region,
                contribution: globalPerformance.regionalContributions[region] ?? 0,
                latency: latencyMetrics.regionalLatencies[region] ?? 0,
                accuracy: Double.random(in: 0.8...0.95),
                accounts: totalAccounts / activeRegions.count,
                status: .active
            )
        }
    }
    
    func startGlobalCoordination() {
        Task {
            await performCoordination()
        }
    }
    
    func pauseCoordination() {
        isCoordinating = false
        synchronizationStatus = .partialSync
    }
    
    func resumeCoordination() {
        synchronizationStatus = .syncing
        startGlobalCoordination()
    }
    
    func forceSync() {
        synchronizationStatus = .syncing
        Task {
            await performCoordination()
            synchronizationStatus = .synchronized
        }
    }
}

struct CoordinationSummary {
    let globalAccuracy: Double
    let totalAccounts: Int
    let activeAccounts: Int
    let activeRegions: Int
    let averageLatency: Double
    let systemHealth: Double
    let lastUpdate: Date
    
    var formattedAccuracy: String {
        String(format: "%.1f%%", globalAccuracy * 100)
    }
    
    var formattedHealth: String {
        String(format: "%.1f%%", systemHealth * 100)
    }
    
    var healthColor: Color {
        if systemHealth >= 0.9 { return .green }
        else if systemHealth >= 0.7 { return .orange }
        else { return .red }
    }
}

struct RegionalPerformance {
    let region: MultiTimezoneEngine.TradingRegion
    let contribution: Double
    let latency: Double
    let accuracy: Double
    let accounts: Int
    let status: Status
    
    enum Status: String, CaseIterable {
        case active = "Active"
        case standby = "Standby"
        case maintenance = "Maintenance"
        case offline = "Offline"
        
        var color: Color {
            switch self {
            case .active: return .green
            case .standby: return .yellow
            case .maintenance: return .orange
            case .offline: return .red
            }
        }
    }
    
    var formattedContribution: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: contribution)) ?? "$0"
    }
    
    var formattedLatency: String {
        String(format: "%.1f ms", latency)
    }
    
    var formattedAccuracy: String {
        String(format: "%.1f%%", accuracy * 100)
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "globe.americas.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Multi-Timezone Engine")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Global Trading Coordination")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                
                // Global Metrics
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                    MetricCard(title: "Global Accuracy", value: "94.2%", color: .green, icon: "target")
                    MetricCard(title: "Active Accounts", value: "847", color: .blue, icon: "person.3.fill")
                    MetricCard(title: "Regions", value: "6", color: .purple, icon: "globe")
                    MetricCard(title: "Avg Latency", value: "28ms", color: .orange, icon: "timer")
                    MetricCard(title: "System Health", value: "96.5%", color: .green, icon: "heart.fill")
                    MetricCard(title: "Sync Status", value: "Online", color: .green, icon: "checkmark.circle.fill")
                }
                
                // Regional Performance
                VStack(alignment: .leading, spacing: 12) {
                    Text("Regional Performance")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(["US", "EU", "Asia", "UK", "Canada", "Australia"], id: \.self) { region in
                            RegionCard(name: region, accuracy: Double.random(in: 0.85...0.95))
                        }
                    }
                }
                
                // System Status
                VStack(alignment: .leading, spacing: 12) {
                    Text("System Status")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 8) {
                        StatusRow(title: "Global Coordination", status: "Active", color: .green)
                        StatusRow(title: "Cross-Region Sync", status: "Synchronized", color: .green)
                        StatusRow(title: "Load Balancing", status: "Optimized", color: .blue)
                        StatusRow(title: "Failover Ready", status: "Standby", color: .orange)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Multi-Timezone Engine")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct RegionCard: View {
    let name: String
    let accuracy: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Circle()
                    .fill(.green)
                    .frame(width: 8, height: 8)
            }
            
            Text(String(format: "%.1f%%", accuracy * 100))
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.green)
            
            Text("Accuracy")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
    }
}

struct StatusRow: View {
    let title: String
    let status: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text(status)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
        .padding(.vertical, 4)
    }
}
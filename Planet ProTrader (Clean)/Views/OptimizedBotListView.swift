//
//  OptimizedBotListView.swift
//  Planet ProTrader (Clean)
//
//  🚀 ULTRA-OPTIMIZED UI FOR 5000+ BOTS - BUTTERY SMOOTH
//  Virtualized list with lazy loading for zero lag
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

struct OptimizedBotListView: View {
    @ObservedObject var armyManager: ProTraderArmyManager
    @StateObject private var performanceManager = PerformanceOptimizationManager.shared
    
    @State private var visibleRange: Range<Int> = 0..<50
    @State private var scrollOffset: CGFloat = 0
    @State private var listHeight: CGFloat = 0
    
    private let itemHeight: CGFloat = 80
    private let bufferSize = 10 // Load 10 extra items above/below visible area
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                DesignSystem.spaceGradient.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 📊 Performance Header
                    PerformanceHeaderView()
                        .padding(.horizontal)
                    
                    // 🚀 Virtualized Bot List
                    VirtualizedScrollView(
                        totalItems: armyManager.getTotalBotsCount(),
                        itemHeight: itemHeight,
                        visibleCount: Int(geometry.size.height / itemHeight) + bufferSize
                    ) { index in
                        OptimizedBotRowView(
                            bot: armyManager.getBotByIndex(index),
                            index: index
                        )
                    }
                }
            }
        }
        .navigationTitle("🚀 Elite Army (\(armyManager.activeBots))")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            optimizeForLargeList()
        }
    }
    
    private func optimizeForLargeList() {
        Task {
            await performanceManager.optimizeForMassDeployment(botCount: armyManager.activeBots)
        }
    }
}

// MARK: - 📊 Performance Header
struct PerformanceHeaderView: View {
    @StateObject private var performanceManager = PerformanceOptimizationManager.shared
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                // Memory Usage
                PerformanceMetricCard(
                    title: "Memory",
                    value: performanceManager.getPerformanceReport().memoryUsageFormatted,
                    color: memoryColor,
                    icon: "memorychip"
                )
                
                // CPU Usage
                PerformanceMetricCard(
                    title: "CPU",
                    value: performanceManager.getPerformanceReport().cpuUsageFormatted,
                    color: cpuColor,
                    icon: "cpu"
                )
                
                // Framerate
                PerformanceMetricCard(
                    title: "FPS",
                    value: performanceManager.getPerformanceReport().framerateFormatted,
                    color: framerateColor,
                    icon: "speedometer"
                )
                
                // Optimization Level
                PerformanceMetricCard(
                    title: "Mode",
                    value: performanceManager.optimizationLevel.emoji,
                    color: performanceManager.optimizationLevel.color,
                    icon: "gear"
                )
            }
            
            // Performance Grade
            HStack {
                Text("Performance Grade:")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(.secondary)
                
                Text(performanceManager.getPerformanceReport().performanceGrade)
                    .font(DesignSystem.Typography.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(gradeColor)
                
                Spacer()
                
                if performanceManager.isThrottlingActive {
                    HStack(spacing: 4) {
                        Image(systemName: "slowmo")
                            .foregroundColor(.orange)
                        Text("Throttling")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .solarCard()
    }
    
    private var memoryColor: Color {
        let usage = performanceManager.currentMemoryUsage
        if usage > 0.8 { return .red }
        else if usage > 0.6 { return .orange }
        else { return .green }
    }
    
    private var cpuColor: Color {
        let usage = performanceManager.currentCPUUsage
        if usage > 0.8 { return .red }
        else if usage > 0.6 { return .orange }
        else { return .green }
    }
    
    private var framerateColor: Color {
        let fps = performanceManager.framerate
        if fps >= 55 { return .green }
        else if fps >= 30 { return .orange }
        else { return .red }
    }
    
    private var gradeColor: LinearGradient {
        let grade = performanceManager.getPerformanceReport().performanceGrade
        if grade.hasPrefix("A") {
            return LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing)
        } else if grade.hasPrefix("B") {
            return LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing)
        } else {
            return LinearGradient(colors: [.orange, .yellow], startPoint: .leading, endPoint: .trailing)
        }
    }
}

struct PerformanceMetricCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            
            Text(value)
                .font(DesignSystem.Typography.headline)
                .fontWeight(.semibold)
                .foregroundStyle(color)
            
            Text(title)
                .font(DesignSystem.Typography.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - 🚀 Virtualized Scroll View
struct VirtualizedScrollView<Content: View>: View {
    let totalItems: Int
    let itemHeight: CGFloat
    let visibleCount: Int
    let content: (Int) -> Content
    
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(visibleItems, id: \.self) { index in
                        content(index)
                            .frame(height: itemHeight)
                    }
                }
                .padding(.horizontal)
                .background(
                    GeometryReader { scrollGeometry in
                        Color.clear.onAppear {
                            updateScrollOffset(scrollGeometry)
                        }
                        .onChange(of: scrollGeometry.frame(in: .global).minY) { _ in
                            updateScrollOffset(scrollGeometry)
                        }
                    }
                )
            }
        }
    }
    
    private var visibleItems: Range<Int> {
        let startIndex = max(0, Int(scrollOffset / itemHeight) - 5)
        let endIndex = min(totalItems, startIndex + visibleCount + 10)
        return startIndex..<endIndex
    }
    
    private func updateScrollOffset(_ geometry: GeometryProxy) {
        scrollOffset = max(0, -geometry.frame(in: .global).minY)
    }
}

// MARK: - 🎯 Optimized Bot Row
struct OptimizedBotRowView: View {
    let bot: ProTraderBot?
    let index: Int
    
    var body: some View {
        Group {
            if let bot = bot {
                HStack(spacing: 12) {
                    // Bot Avatar
                    BotAvatarOptimized(bot: bot)
                    
                    // Bot Info
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(bot.name)
                                .font(DesignSystem.Typography.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            StatusIndicator(isActive: bot.isActive)
                        }
                        
                        HStack {
                            Text(bot.strategy.rawValue)
                                .font(DesignSystem.Typography.body)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("XP: \(Int(bot.xp))")
                                .font(DesignSystem.Typography.caption)
                                .foregroundStyle(DesignSystem.primaryGold)
                        }
                        
                        // Performance Strip
                        HStack(spacing: 8) {
                            PerformanceChip(
                                title: "Confidence",
                                value: "\(Int(bot.confidence * 100))%",
                                color: confidenceColor(bot.confidence)
                            )
                            
                            PerformanceChip(
                                title: "P&L",
                                value: formatPnL(bot.totalPnL),
                                color: bot.totalPnL >= 0 ? .green : .red
                            )
                        }
                    }
                    
                    // Quick Actions
                    VStack(spacing: 4) {
                        Button(action: {}) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        
                        Button(action: {}) {
                            Image(systemName: bot.learningProgress > 0.0 ? "brain.head.profile" : "brain.head.profile.fill")
                                .font(.caption)
                                .foregroundColor(bot.learningProgress > 0.0 ? .green : .gray)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(bot.isActive ? DesignSystem.primaryGold.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
                        )
                )
            } else {
                // Placeholder for loading
                BotRowPlaceholder(index: index)
            }
        }
    }
    
    private func confidenceColor(_ confidence: Double) -> Color {
        if confidence >= 0.9 { return .green }
        else if confidence >= 0.8 { return .blue }
        else if confidence >= 0.7 { return .orange }
        else { return .red }
    }
    
    private func formatPnL(_ pnl: Double) -> String {
        let sign = pnl >= 0 ? "+" : ""
        return "\(sign)$\(String(format: "%.0f", pnl))"
    }
}

// MARK: - 🤖 Optimized Bot Avatar
struct BotAvatarOptimized: View {
    let bot: ProTraderBot
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: avatarColors,
                        center: .topLeading,
                        startRadius: 5,
                        endRadius: 25
                    )
                )
                .frame(width: 50, height: 50)
            
            Text(bot.name.prefix(2).uppercased())
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .overlay(
            Circle()
                .stroke(bot.isActive ? DesignSystem.primaryGold : .gray, lineWidth: 2)
        )
    }
    
    private var avatarColors: [Color] {
        let hash = abs(bot.name.hashValue)
        let colorIndex = hash % 6
        
        switch colorIndex {
        case 0: return [.blue, .cyan]
        case 1: return [.purple, .pink]
        case 2: return [.green, .mint]
        case 3: return [.orange, .yellow]
        case 4: return [.red, .pink]
        default: return [.indigo, .blue]
        }
    }
}

// MARK: - 📊 Performance Components
struct StatusIndicator: View {
    let isActive: Bool
    
    var body: some View {
        Circle()
            .fill(isActive ? .green : .gray)
            .frame(width: 8, height: 8)
            .overlay(
                Circle()
                    .fill(isActive ? .green.opacity(0.3) : .clear)
                    .frame(width: 16, height: 16)
                    .scaleEffect(isActive ? 1.5 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isActive)
            )
    }
}

struct PerformanceChip: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(color)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(
            Capsule()
                .fill(color.opacity(0.1))
                .overlay(
                    Capsule()
                        .stroke(color.opacity(0.3), lineWidth: 0.5)
                )
        )
    }
}

struct BotRowPlaceholder: View {
    let index: Int
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar placeholder
            Circle()
                .fill(.gray.opacity(0.3))
                .frame(width: 50, height: 50)
                .shimmer()
            
            VStack(alignment: .leading, spacing: 4) {
                Rectangle()
                    .fill(.gray.opacity(0.3))
                    .frame(height: 16)
                    .frame(maxWidth: 120)
                    .shimmer()
                
                Rectangle()
                    .fill(.gray.opacity(0.2))
                    .frame(height: 12)
                    .frame(maxWidth: 80)
                    .shimmer()
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - 💫 Shimmer Effect
extension View {
    func shimmer() -> some View {
        self.overlay(
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.4), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .rotationEffect(.degrees(30))
                .offset(x: -200)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false), value: true)
        )
        .clipped()
    }
}

#Preview {
    NavigationView {
        OptimizedBotListView(armyManager: ProTraderArmyManager())
    }
    .preferredColorScheme(.dark)
}
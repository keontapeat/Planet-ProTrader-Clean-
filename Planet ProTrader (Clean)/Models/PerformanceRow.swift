//
//  PerformanceRow.swift
//  Planet ProTrader - Performance Components
//
//  Reusable performance display components
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

struct PerformanceRow: View {
    let period: String
    let value: String
    let percentage: String
    let isPositive: Bool
    
    var body: some View {
        HStack {
            Text(period)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(value)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("\(isPositive ? "+" : "")\(percentage)")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(isPositive ? .green : .red)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct PerformanceCard: View {
    let title: String
    let value: String
    let change: String
    let isPositive: Bool
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                
                Spacer()
                
                Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                    .font(.caption)
                    .foregroundStyle(isPositive ? .green : .red)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
                
                Text(change)
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundStyle(isPositive ? .green : .red)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct MetricRow: View {
    let label: String
    let value: String
    let subtitle: String?
    let color: Color
    
    init(label: String, value: String, subtitle: String? = nil, color: Color = .white) {
        self.label = label
        self.value = value
        self.subtitle = subtitle
        self.color = color
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(color)
        }
        .padding(.vertical, 8)
    }
}

struct PerformanceSection: View {
    let title: String
    let icon: String
    let color: Color
    let content: () -> AnyView
    
    init(title: String, icon: String, color: Color, @ViewBuilder content: @escaping () -> some View) {
        self.title = title
        self.icon = icon
        self.color = color
        self.content = { AnyView(content()) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Text(icon)
                    .font(.title2)
                
                Text(title)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
            }
            
            content()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            PerformanceRow(
                period: "Today",
                value: "$245.75",
                percentage: "2.8%",
                isPositive: true
            )
            
            PerformanceRow(
                period: "This Week",
                value: "$-45.30",
                percentage: "-1.2%",
                isPositive: false
            )
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                PerformanceCard(
                    title: "Total P&L",
                    value: "$12,450",
                    change: "+8.5% today",
                    isPositive: true,
                    icon: "chart.xyaxis.line",
                    color: .green
                )
                
                PerformanceCard(
                    title: "Win Rate",
                    value: "87.2%",
                    change: "+2.1% this week",
                    isPositive: true,
                    icon: "target",
                    color: .blue
                )
            }
            
            PerformanceSection(title: "Metrics", icon: "📊", color: .purple) {
                VStack(spacing: 8) {
                    MetricRow(
                        label: "Active Bots",
                        value: "4,250",
                        subtitle: "of 5,000 total",
                        color: .green
                    )
                    
                    MetricRow(
                        label: "Average Confidence",
                        value: "92.5%",
                        subtitle: "AI confidence level",
                        color: .orange
                    )
                    
                    MetricRow(
                        label: "Daily Volume",
                        value: "$2.4M",
                        subtitle: "24h trading volume",
                        color: .blue
                    )
                }
            }
        }
        .padding(20)
    }
    .background(Color.black)
    .preferredColorScheme(.dark)
}
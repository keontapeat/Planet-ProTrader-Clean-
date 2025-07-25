//
//  LoadingView.swift
//  Planet ProTrader (Clean)
//
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

struct LoadingView: View {
    @State private var rotation = 0.0
    @State private var scale = 1.0
    @State private var opacity = 0.7
    
    var body: some View {
        VStack(spacing: 24) {
            // Main Loading Animation
            ZStack {
                // Outer Ring
                Circle()
                    .stroke(Color.blue.opacity(0.3), lineWidth: 8)
                    .frame(width: 80, height: 80)
                
                // Inner Animated Ring
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        LinearGradient(
                            colors: [Color.blue, Color.cyan, Color.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(rotation))
                    .animation(
                        .linear(duration: 1.5).repeatForever(autoreverses: false),
                        value: rotation
                    )
                
                // Center Icon
                Image(systemName: "brain.head.profile")
                    .font(.title)
                    .foregroundStyle(.white)
                    .scaleEffect(scale)
                    .animation(
                        .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                        value: scale
                    )
            }
            
            // Loading Text
            VStack(spacing: 8) {
                Text("🚀 Initializing ProTrader Army")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text("Connecting to 5,000 AI Trading Bots...")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(opacity))
                    .animation(
                        .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                        value: opacity
                    )
            }
            
            // Progress Dots
            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(.white.opacity(0.8))
                        .frame(width: 8, height: 8)
                        .scaleEffect(dotScale(for: index))
                        .animation(
                            .easeInOut(duration: 0.6)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.2),
                            value: rotation
                        )
                }
            }
        }
        .onAppear {
            rotation = 360
            scale = 1.2
            opacity = 1.0
        }
    }
    
    private func dotScale(for index: Int) -> CGFloat {
        let progress = (rotation / 360.0)
        let delay = Double(index) * 0.33
        let adjustedProgress = (progress + delay).truncatingRemainder(dividingBy: 1.0)
        return 1.0 + 0.5 * sin(adjustedProgress * .pi * 2)
    }
}

#Preview {
    LoadingView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .preferredColorScheme(.dark)
}
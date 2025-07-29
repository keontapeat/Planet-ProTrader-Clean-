//
//  ScaleButtonStyle.swift
//  Planet ProTrader - Custom Button Styles
//
//  Professional Button Interactions
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

struct ScaleEffectButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

struct PressEffectButtonStyle: ButtonStyle {
    let pressedColor: Color
    let normalColor: Color
    
    init(pressedColor: Color = .white.opacity(0.1), normalColor: Color = .clear) {
        self.pressedColor = pressedColor
        self.normalColor = normalColor
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(configuration.isPressed ? pressedColor : normalColor)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.15, dampingFraction: 0.9), value: configuration.isPressed)
    }
}

struct TradingButtonStyle: ButtonStyle {
    let type: TradingButtonType
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                LinearGradient(
                    colors: configuration.isPressed ? type.pressedColors : type.normalColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(type.borderColor, lineWidth: 1)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

enum TradingButtonType {
    case buy, sell, neutral
    
    var normalColors: [Color] {
        switch self {
        case .buy: return [Color(red: 0.2, green: 0.4, blue: 0.2), Color(red: 0.1, green: 0.3, blue: 0.1)]
        case .sell: return [Color(red: 0.4, green: 0.2, blue: 0.2), Color(red: 0.3, green: 0.1, blue: 0.1)]
        case .neutral: return [Color(red: 0.2, green: 0.2, blue: 0.2), Color(red: 0.1, green: 0.1, blue: 0.1)]
        }
    }
    
    var pressedColors: [Color] {
        switch self {
        case .buy: return [Color(red: 0.15, green: 0.35, blue: 0.15), Color(red: 0.05, green: 0.25, blue: 0.05)]
        case .sell: return [Color(red: 0.35, green: 0.15, blue: 0.15), Color(red: 0.25, green: 0.05, blue: 0.05)]
        case .neutral: return [Color(red: 0.15, green: 0.15, blue: 0.15), Color(red: 0.05, green: 0.05, blue: 0.05)]
        }
    }
    
    var borderColor: Color {
        switch self {
        case .buy: return .green.opacity(0.3)
        case .sell: return .red.opacity(0.3)
        case .neutral: return .white.opacity(0.2)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        Button("Buy") {}
            .buttonStyle(TradingButtonStyle(type: .buy))
            .frame(width: 100, height: 50)
        
        Button("Sell") {}
            .buttonStyle(TradingButtonStyle(type: .sell))
            .frame(width: 100, height: 50)
        
        Button("Scale Effect") {}
            .buttonStyle(ScaleEffectButtonStyle())
            .padding()
            .background(.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
    .padding()
    .preferredColorScheme(.dark)
}
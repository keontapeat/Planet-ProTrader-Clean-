//
//  TradeLockerStatCard.swift
//  Planet ProTrader - Trading Statistics Card Component
//
//  Clean stat card for trading interface
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

struct TradeLockerStatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.gray)
            
            Text(value)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 40)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    HStack(spacing: 8) {
        TradeLockerStatCard(
            title: "Balance",
            value: "$10,425",
            color: .blue
        )
        
        TradeLockerStatCard(
            title: "P&L",
            value: "+$245",
            color: .green
        )
        
        TradeLockerStatCard(
            title: "Equity",
            value: "$10,687",
            color: .green
        )
    }
    .padding()
    .preferredColorScheme(.dark)
    .background(Color.black)
}
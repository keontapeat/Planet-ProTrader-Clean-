//
//  ReplayView.swift
//  Planet ProTrader (Clean)
//
//  Created by Keonta  on 7/25/25.
//


// ReplayView.swift - Trade Replay Engine with Screenshot Playback

import SwiftUI

struct ReplayView: View {
    let trade: ReplayTrade
    @State private var selectedPhase: ReplayPhase = .entry

    var body: some View {
        VStack(spacing: 24) {
            // Title
            Text("🕹️ Trade Replay: \(trade.symbol)")
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundColor(.white)

            // Phase Picker
            Picker("Phase", selection: $selectedPhase) {
                ForEach(ReplayPhase.allCases) { phase in
                    Text(phase.rawValue.capitalized).tag(phase)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            // Screenshot Viewer
            VStack(spacing: 12) {
                if let image = trade.image(for: selectedPhase) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(20)
                        .padding()
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.white.opacity(0.05))
                        .frame(height: 220)
                        .overlay(
                            Text("No Screenshot Available")
                                .foregroundColor(.white.opacity(0.4))
                        )
                }

                // Labels
                HStack {
                    VStack(alignment: .leading) {
                        Text("🪙 Symbol: \(trade.symbol)")
                        Text("📈 Entry: \(trade.entryPrice, specifier: "%.2f")")
                        Text("🎯 TP: \(trade.takeProfit, specifier: "%.2f")  | 🛡️ SL: \(trade.stopLoss, specifier: "%.2f")")
                    }
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    Spacer()
                }
                .padding(.horizontal)
            }
            .background(Color.white.opacity(0.02))
            .cornerRadius(20)

            Spacer()
        }
        .padding()
        .background(
            LinearGradient(colors: [Color.black, Color(red: 0.04, green: 0.04, blue: 0.1)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }
}

// MARK: - Data Model

struct ReplayTrade {
    let symbol: String
    let entryPrice: Double
    let stopLoss: Double
    let takeProfit: Double
    let entryImage: UIImage?
    let duringImage: UIImage?
    let exitImage: UIImage?

    func image(for phase: ReplayPhase) -> UIImage? {
        switch phase {
        case .entry: return entryImage
        case .during: return duringImage
        case .exit: return exitImage
        }
    }
}

enum ReplayPhase: String, CaseIterable, Identifiable {
    case entry, during, exit
    var id: String { rawValue }
}

// MARK: - Preview with Placeholder

#Preview {
    ReplayView(
        trade: ReplayTrade(
            symbol: "XAUUSD",
            entryPrice: 1972.33,
            stopLoss: 1965.00,
            takeProfit: 1984.50,
            entryImage: UIImage(named: "entry_placeholder"),
            duringImage: UIImage(named: "during_placeholder"),
            exitImage: UIImage(named: "exit_placeholder")
        )
    )
    .preferredColorScheme(.dark)
}

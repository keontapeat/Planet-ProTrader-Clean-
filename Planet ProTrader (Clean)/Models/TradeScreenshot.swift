import SwiftUI

struct TradeScreenshotSampleView: View {
    private let sample = TradeScreenshot(
        tradeId: UUID().uuidString,
        phase: .after,
        imageName: "sample.png",
        analysis: "Perfect confluence: RSI divergence + trend continuation.",
        aiConfidence: 0.93,
        technicalIndicators: ["RSI", "MACD", "EMA"],
        marketCondition: "Trending",
        setupQuality: .elite,
        tradeGrade: .aPlusPlus,
        symbol: "XAUUSD",
        profitLoss: 185.40
    )
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Trade: \(sample.symbol)")
            HStack(spacing: 8) {
                Text(sample.tradeGrade.emoji)
                Text(sample.tradeGrade.rawValue)
                    .foregroundStyle(sample.tradeGrade.color)
            }
            Text("P&L: \(sample.profitLoss >= 0 ? "+" : "")$\(String(format: "%.2f", sample.profitLoss))")
                .foregroundStyle(sample.profitLoss >= 0 ? .green : .red)
            Text("AI: \(sample.aiAnalysisScore)")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    TradeScreenshotSampleView()
}
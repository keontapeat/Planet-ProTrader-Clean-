//
//  SharedTypes.swift
//  Planet ProTrader (Clean)
//
//  Shared types across all trading engines
//  Created by AI Assistant on 1/25/25.
//

import Foundation
import SwiftUI

// MARK: - SharedTypes Namespace
enum SharedTypes {
    
    // MARK: - Trend Direction
    enum TrendDirection {
        case bullish
        case bearish
        case neutral
        
        var color: Color {
            switch self {
            case .bullish: return .green
            case .bearish: return .red
            case .neutral: return .gray
            }
        }
        
        var emoji: String {
            switch self {
            case .bullish: return "🐂"
            case .bearish: return "🐻"
            case .neutral: return "➡️"
            }
        }
        
        var displayName: String {
            switch self {
            case .bullish: return "Bullish"
            case .bearish: return "Bearish"
            case .neutral: return "Neutral"
            }
        }
    }
    
    // MARK: - Trade Signal
    struct TradeSignal {
        let id = UUID()
        let direction: TradeDirection
        let entryPrice: Double
        let stopLoss: Double
        let takeProfit: Double
        let confidence: Double
        let timestamp: Date
        let reasoning: String
        let timeframe: String
        
        var riskRewardRatio: Double {
            let risk = abs(entryPrice - stopLoss)
            let reward = abs(takeProfit - entryPrice)
            return risk > 0 ? reward / risk : 0
        }
        
        var formattedEntryPrice: String {
            String(format: "$%.2f", entryPrice)
        }
        
        var formattedStopLoss: String {
            String(format: "$%.2f", stopLoss)
        }
        
        var formattedTakeProfit: String {
            String(format: "$%.2f", takeProfit)
        }
        
        var confidenceColor: Color {
            if confidence >= 0.8 { return .green }
            else if confidence >= 0.6 { return .orange }
            else { return .red }
        }
    }
}

// MARK: - TradingModels Namespace
enum TradingModels {
    
    // MARK: - Candlestick Data
    struct CandlestickData {
        let timestamp: Date
        let open: Double
        let high: Double
        let low: Double
        let close: Double
        let volume: Double
        
        var formattedPrice: String {
            String(format: "$%.2f", close)
        }
        
        var isGreen: Bool { close > open }
        var bodySize: Double { abs(close - open) }
        var wickSize: Double { high - low }
        var priceChange: Double { close - open }
        var priceChangePercent: Double {
            open > 0 ? ((close - open) / open) * 100 : 0
        }
    }
    
    // MARK: - MACD Data
    struct MACDData {
        let macd: Double
        let signal: Double
        let histogram: Double
        
        var isBullish: Bool { macd > signal }
        var strength: Double { abs(histogram) }
        
        var formattedMACD: String {
            String(format: "%.4f", macd)
        }
        
        var formattedSignal: String {
            String(format: "%.4f", signal)
        }
    }
    
    // MARK: - Fibonacci Levels
    struct FibonacciLevels {
        let levels: [FibLevel]
        let swingHigh: Double
        let swingLow: Double
        let direction: FibDirection
        
        struct FibLevel {
            let percentage: Double
            let price: Double
            let label: String
            
            var formattedPrice: String {
                String(format: "$%.2f", price)
            }
            
            var formattedPercentage: String {
                String(format: "%.1f%%", percentage * 100)
            }
        }
        
        enum FibDirection {
            case uptrend
            case downtrend
            
            var color: Color {
                switch self {
                case .uptrend: return .green
                case .downtrend: return .red
                }
            }
            
            var icon: String {
                switch self {
                case .uptrend: return "arrow.up.circle.fill"
                case .downtrend: return "arrow.down.circle.fill"
                }
            }
        }
    }
}

// MARK: - Enhanced Gold Data Point
struct EnhancedGoldDataPoint: Identifiable, Codable, Hashable {
    let id = UUID()
    let timestamp: Date
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let volume: Double?
    
    // Technical indicators (calculated)
    var rsi: Double?
    var macd: Double?
    var bollingerUpper: Double?
    var bollingerLower: Double?
    var sma20: Double?
    var ema50: Double?
    var stochastic: Double?
    var atr: Double?
    var obv: Double?
    var vwap: Double?
    
    // Market context
    var marketSession: MarketSession
    var dayOfWeek: Int
    var hourOfDay: Int
    var isWeekend: Bool
    var isHoliday: Bool
    
    // Price action metrics
    var bodySize: Double { abs(close - open) }
    var shadowSize: Double { high - low }
    var upperShadow: Double { high - max(open, close) }
    var lowerShadow: Double { min(open, close) - low }
    var midpoint: Double { (high + low) / 2 }
    var typical: Double { (high + low + close) / 3 }
    var weighted: Double { (high + low + close + close) / 4 }
    
    // Candle patterns
    var candleType: CandleType {
        let bodyRatio = bodySize / shadowSize
        let openCloseRatio = (close - open) / open
        
        if bodyRatio < 0.1 {
            return .doji
        } else if openCloseRatio > 0.02 {
            return .bullish
        } else if openCloseRatio < -0.02 {
            return .bearish
        } else {
            return .neutral
        }
    }
    
    var isGreen: Bool { close > open }
    var priceChange: Double { close - open }
    var priceChangePercent: Double { ((close - open) / open) * 100 }
    
    // Volume analysis
    var volumeProfile: VolumeProfile {
        guard let vol = volume else { return .unknown }
        
        if vol > 50000 {
            return .high
        } else if vol > 20000 {
            return .medium
        } else if vol > 5000 {
            return .low
        } else {
            return .veryLow
        }
    }
    
    // Data quality metrics
    var dataQuality: DataQuality {
        var score = 1.0
        
        // Check for valid OHLC relationships
        if high < max(open, close) || low > min(open, close) {
            score -= 0.5
        }
        
        // Check for reasonable price range
        if open < 500 || open > 5000 || close < 500 || close > 5000 {
            score -= 0.3
        }
        
        // Check for extreme volatility
        let volatility = shadowSize / ((high + low) / 2)
        if volatility > 0.1 { // More than 10% intraday range
            score -= 0.2
        }
        
        if score >= 0.9 {
            return .excellent
        } else if score >= 0.7 {
            return .good
        } else if score >= 0.5 {
            return .fair
        } else {
            return .poor
        }
    }
    
    // Legacy formatted price (for compatibility)
    var formattedPrice: String {
        String(format: "$%.2f", close)
    }
    
    // Legacy wickSize (for compatibility)
    var wickSize: Double { high - low }
    
    // MARK: - Initialization
    init(
        timestamp: Date,
        open: Double,
        high: Double,
        low: Double,
        close: Double,
        volume: Double? = nil,
        rsi: Double? = nil,
        macd: Double? = nil,
        bollingerUpper: Double? = nil,
        bollingerLower: Double? = nil,
        sma20: Double? = nil,
        ema50: Double? = nil,
        stochastic: Double? = nil,
        atr: Double? = nil,
        obv: Double? = nil,
        vwap: Double? = nil
    ) {
        self.timestamp = timestamp
        self.open = open
        self.high = high
        self.low = low
        self.close = close
        self.volume = volume
        self.rsi = rsi
        self.macd = macd
        self.bollingerUpper = bollingerUpper
        self.bollingerLower = bollingerLower
        self.sma20 = sma20
        self.ema50 = ema50
        self.stochastic = stochastic
        self.atr = atr
        self.obv = obv
        self.vwap = vwap
        
        // Calculate market context
        let calendar = Calendar.current
        self.dayOfWeek = calendar.component(.weekday, from: timestamp)
        self.hourOfDay = calendar.component(.hour, from: timestamp)
        self.isWeekend = dayOfWeek == 1 || dayOfWeek == 7 // Sunday or Saturday
        self.isHoliday = Self.isMarketHoliday(timestamp)
        self.marketSession = Self.determineMarketSession(timestamp)
    }
    
    // MARK: - Static Helper Methods
    static func determineMarketSession(_ date: Date) -> MarketSession {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        
        // Based on London/New York trading hours (GMT)
        switch hour {
        case 0...7:
            return .asian
        case 8...15:
            return .london
        case 16...22:
            return .newYork
        case 23:
            return .asian
        default:
            return .closed
        }
    }
    
    static func isMarketHoliday(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        // Major holidays affecting gold markets
        let holidays: [(month: Int, day: Int)] = [
            (1, 1),   // New Year's Day
            (7, 4),   // Independence Day (US)
            (12, 25), // Christmas Day
            (12, 26)  // Boxing Day
        ]
        
        return holidays.contains { $0.month == month && $0.day == day }
    }
    
    // MARK: - Technical Analysis Methods
    func calculateRSI(with period: Int = 14, previousPoints: [EnhancedGoldDataPoint]) -> Double {
        guard previousPoints.count >= period else { return 50.0 }
        
        let recentPoints = Array(previousPoints.suffix(period))
        var gains: [Double] = []
        var losses: [Double] = []
        
        for i in 1..<recentPoints.count {
            let change = recentPoints[i].close - recentPoints[i-1].close
            if change > 0 {
                gains.append(change)
                losses.append(0)
            } else {
                gains.append(0)
                losses.append(abs(change))
            }
        }
        
        let avgGain = gains.reduce(0, +) / Double(gains.count)
        let avgLoss = losses.reduce(0, +) / Double(losses.count)
        
        guard avgLoss != 0 else { return 100.0 }
        
        let rs = avgGain / avgLoss
        return 100 - (100 / (1 + rs))
    }
    
    func calculateSMA(period: Int, previousPoints: [EnhancedGoldDataPoint]) -> Double {
        let points = Array(previousPoints.suffix(period))
        guard points.count == period else { return close }
        
        let sum = points.reduce(0) { $0 + $1.close }
        return sum / Double(period)
    }
    
    func calculateEMA(period: Int, previousEMA: Double?) -> Double {
        let multiplier = 2.0 / Double(period + 1)
        
        if let prevEMA = previousEMA {
            return (close * multiplier) + (prevEMA * (1 - multiplier))
        } else {
            return close
        }
    }
    
    func calculateATR(period: Int = 14, previousPoints: [EnhancedGoldDataPoint]) -> Double {
        guard !previousPoints.isEmpty else { return shadowSize }
        
        let lastPoint = previousPoints.last!
        let trueRange = max(
            high - low,
            abs(high - lastPoint.close),
            abs(low - lastPoint.close)
        )
        
        // For simplicity, return current true range
        // In production, you'd calculate the average over the period
        return trueRange
    }
    
    // MARK: - Pattern Recognition
    func detectCandlePattern(with previousPoints: [EnhancedGoldDataPoint]) -> CandlePattern {
        guard previousPoints.count >= 2 else { return .none }
        
        let prev1 = previousPoints[previousPoints.count - 1]
        let prev2 = previousPoints.count > 1 ? previousPoints[previousPoints.count - 2] : prev1
        
        // Doji pattern
        if abs(priceChange) / open < 0.001 {
            return .doji
        }
        
        // Hammer pattern
        if lowerShadow > bodySize * 2 && upperShadow < bodySize * 0.5 {
            return .hammer
        }
        
        // Shooting star
        if upperShadow > bodySize * 2 && lowerShadow < bodySize * 0.5 {
            return .shootingStar
        }
        
        // Engulfing patterns
        if isGreen && !prev1.isGreen && 
           open < prev1.close && close > prev1.open {
            return .bullishEngulfing
        }
        
        if !isGreen && prev1.isGreen && 
           open > prev1.close && close < prev1.open {
            return .bearishEngulfing
        }
        
        return .none
    }
    
    // MARK: - Codable Implementation
    enum CodingKeys: String, CodingKey {
        case timestamp, open, high, low, close, volume
        case rsi, macd, bollingerUpper, bollingerLower
        case sma20, ema50, stochastic, atr, obv, vwap
        case marketSession, dayOfWeek, hourOfDay, isWeekend, isHoliday
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        open = try container.decode(Double.self, forKey: .open)
        high = try container.decode(Double.self, forKey: .high)
        low = try container.decode(Double.self, forKey: .low)
        close = try container.decode(Double.self, forKey: .close)
        volume = try container.decodeIfPresent(Double.self, forKey: .volume)
        
        rsi = try container.decodeIfPresent(Double.self, forKey: .rsi)
        macd = try container.decodeIfPresent(Double.self, forKey: .macd)
        bollingerUpper = try container.decodeIfPresent(Double.self, forKey: .bollingerUpper)
        bollingerLower = try container.decodeIfPresent(Double.self, forKey: .bollingerLower)
        sma20 = try container.decodeIfPresent(Double.self, forKey: .sma20)
        ema50 = try container.decodeIfPresent(Double.self, forKey: .ema50)
        stochastic = try container.decodeIfPresent(Double.self, forKey: .stochastic)
        atr = try container.decodeIfPresent(Double.self, forKey: .atr)
        obv = try container.decodeIfPresent(Double.self, forKey: .obv)
        vwap = try container.decodeIfPresent(Double.self, forKey: .vwap)
        
        marketSession = try container.decodeIfPresent(MarketSession.self, forKey: .marketSession) ?? .closed
        dayOfWeek = try container.decodeIfPresent(Int.self, forKey: .dayOfWeek) ?? 1
        hourOfDay = try container.decodeIfPresent(Int.self, forKey: .hourOfDay) ?? 0
        isWeekend = try container.decodeIfPresent(Bool.self, forKey: .isWeekend) ?? false
        isHoliday = try container.decodeIfPresent(Bool.self, forKey: .isHoliday) ?? false
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(open, forKey: .open)
        try container.encode(high, forKey: .high)
        try container.encode(low, forKey: .low)
        try container.encode(close, forKey: .close)
        try container.encodeIfPresent(volume, forKey: .volume)
        
        try container.encodeIfPresent(rsi, forKey: .rsi)
        try container.encodeIfPresent(macd, forKey: .macd)
        try container.encodeIfPresent(bollingerUpper, forKey: .bollingerUpper)
        try container.encodeIfPresent(bollingerLower, forKey: .bollingerLower)
        try container.encodeIfPresent(sma20, forKey: .sma20)
        try container.encodeIfPresent(ema50, forKey: .ema50)
        try container.encodeIfPresent(stochastic, forKey: .stochastic)
        try container.encodeIfPresent(atr, forKey: .atr)
        try container.encodeIfPresent(obv, forKey: .obv)
        try container.encodeIfPresent(vwap, forKey: .vwap)
        
        try container.encode(marketSession, forKey: .marketSession)
        try container.encode(dayOfWeek, forKey: .dayOfWeek)
        try container.encode(hourOfDay, forKey: .hourOfDay)
        try container.encode(isWeekend, forKey: .isWeekend)
        try container.encode(isHoliday, forKey: .isHoliday)
    }
    
    // MARK: - Hashable Implementation
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(timestamp)
        hasher.combine(close)
    }
    
    static func == (lhs: EnhancedGoldDataPoint, rhs: EnhancedGoldDataPoint) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Supporting Enums

enum MarketSession: String, Codable, CaseIterable {
    case asian = "Asian"
    case london = "London"
    case newYork = "New York"
    case closed = "Closed"
    
    var color: Color {
        switch self {
        case .asian: return .orange
        case .london: return .blue
        case .newYork: return .green
        case .closed: return .gray
        }
    }
    
    var timeRange: String {
        switch self {
        case .asian: return "00:00-08:00 GMT"
        case .london: return "08:00-16:00 GMT"
        case .newYork: return "16:00-23:00 GMT"
        case .closed: return "Market Closed"
        }
    }
}

enum CandleType: String, Codable, CaseIterable {
    case bullish = "Bullish"
    case bearish = "Bearish"
    case doji = "Doji"
    case neutral = "Neutral"
    
    var color: Color {
        switch self {
        case .bullish: return .green
        case .bearish: return .red
        case .doji: return .yellow
        case .neutral: return .gray
        }
    }
}

enum VolumeProfile: String, Codable, CaseIterable {
    case veryLow = "Very Low"
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case unknown = "Unknown"
    
    var color: Color {
        switch self {
        case .veryLow: return .gray
        case .low: return .yellow
        case .medium: return .orange
        case .high: return .red
        case .unknown: return .secondary
        }
    }
}

enum DataQuality: String, Codable, CaseIterable {
    case excellent = "Excellent"
    case good = "Good"
    case fair = "Fair"
    case poor = "Poor"
    
    var color: Color {
        switch self {
        case .excellent: return .green
        case .good: return .blue
        case .fair: return .orange
        case .poor: return .red
        }
    }
    
    var score: Double {
        switch self {
        case .excellent: return 1.0
        case .good: return 0.8
        case .fair: return 0.6
        case .poor: return 0.3
        }
    }
}

enum CandlePattern: String, Codable, CaseIterable {
    case none = "None"
    case doji = "Doji"
    case hammer = "Hammer"
    case shootingStar = "Shooting Star"
    case bullishEngulfing = "Bullish Engulfing"
    case bearishEngulfing = "Bearish Engulfing"
    case morningStar = "Morning Star"
    case eveningStar = "Evening Star"
    case pinBar = "Pin Bar"
    
    var significance: PatternSignificance {
        switch self {
        case .none: return .neutral
        case .doji: return .neutral
        case .hammer: return .bullish
        case .shootingStar: return .bearish
        case .bullishEngulfing: return .strongBullish
        case .bearishEngulfing: return .strongBearish
        case .morningStar: return .strongBullish
        case .eveningStar: return .strongBearish
        case .pinBar: return .neutral
        }
    }
}

enum PatternSignificance: String, Codable {
    case strongBullish = "Strong Bullish"
    case bullish = "Bullish"
    case neutral = "Neutral"
    case bearish = "Bearish"
    case strongBearish = "Strong Bearish"
    
    var color: Color {
        switch self {
        case .strongBullish: return .green
        case .bullish: return .mint
        case .neutral: return .gray
        case .bearish: return .orange
        case .strongBearish: return .red
        }
    }
}

// MARK: - Extension for Array Operations
extension Array where Element == EnhancedGoldDataPoint {
    func calculateTechnicalIndicators() -> [EnhancedGoldDataPoint] {
        var processedData = self
        
        for i in 0..<processedData.count {
            let previousPoints = Array(processedData[0..<i])
            
            // Calculate RSI
            if i >= 14 {
                processedData[i].rsi = processedData[i].calculateRSI(with: 14, previousPoints: previousPoints)
            }
            
            // Calculate SMA
            if i >= 20 {
                processedData[i].sma20 = processedData[i].calculateSMA(period: 20, previousPoints: previousPoints)
            }
            
            // Calculate EMA
            if i > 0 {
                let prevEMA = i >= 50 ? processedData[i-1].ema50 : nil
                processedData[i].ema50 = processedData[i].calculateEMA(period: 50, previousEMA: prevEMA)
            }
            
            // Calculate ATR
            if i > 0 {
                processedData[i].atr = processedData[i].calculateATR(period: 14, previousPoints: previousPoints)
            }
        }
        
        return processedData
    }
    
    func filterByQuality(_ minQuality: DataQuality) -> [EnhancedGoldDataPoint] {
        return self.filter { $0.dataQuality.score >= minQuality.score }
    }
    
    func groupByTimeframe(_ timeframe: TimeInterval) -> [[EnhancedGoldDataPoint]] {
        guard !isEmpty else { return [] }
        
        var groups: [[EnhancedGoldDataPoint]] = []
        var currentGroup: [EnhancedGoldDataPoint] = []
        var currentGroupStart = first!.timestamp
        
        for point in self {
            if point.timestamp.timeIntervalSince(currentGroupStart) >= timeframe {
                if !currentGroup.isEmpty {
                    groups.append(currentGroup)
                }
                currentGroup = [point]
                currentGroupStart = point.timestamp
            } else {
                currentGroup.append(point)
            }
        }
        
        if !currentGroup.isEmpty {
            groups.append(currentGroup)
        }
        
        return groups
    }
}

// MARK: - Enhanced Learning Session
struct EnhancedLearningSession {
    let id = UUID()
    let dataPoints: Int
    let xpGained: Double
    let confidenceGained: Double
    let patternsDiscovered: [String]
    let timestamp: Date
    
    var formattedXP: String {
        String(format: "%.0f XP", xpGained)
    }
    
    var formattedConfidence: String {
        String(format: "+%.1f%%", confidenceGained * 100)
    }
}

#Preview {
    VStack(spacing: 20) {
        Image(systemName: "arrow.triangle.branch")
            .font(.system(size: 50))
            .foregroundColor(.blue)
        
        Text("SharedTypes")
            .font(.title)
            .fontWeight(.bold)
        
        Text("Common Trading Types")
            .font(.subheadline)
            .foregroundColor(.secondary)
        
        HStack(spacing: 20) {
            VStack {
                Text("🐂")
                    .font(.title)
                Text("Bullish")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            
            VStack {
                Text("🐻")
                    .font(.title)
                Text("Bearish")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            VStack {
                Text("➡️")
                    .font(.title)
                Text("Neutral")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    .padding()
}
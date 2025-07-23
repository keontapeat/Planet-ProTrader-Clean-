//
//  FreeAPIModels.swift
//  Planet ProTrader - Free APIs Data Models
//
//  Comprehensive data models for all 10 free APIs
//  Created by AI Assistant on 1/25/25.
//

import Foundation
import SwiftUI

// MARK: - Finnhub Models
struct FinnhubQuote: Codable {
    let c: Double  // Current price
    let h: Double  // High price of the day
    let l: Double  // Low price of the day
    let o: Double  // Open price of the day
    let pc: Double // Previous close price
    let t: Int     // Timestamp
    
    var currentPrice: Double { c }
    var highPrice: Double { h }
    var lowPrice: Double { l }
    var openPrice: Double { o }
    var previousClose: Double { pc }
    var timestamp: Date { Date(timeIntervalSince1970: TimeInterval(t)) }
    var change: Double { c - pc }
    var changePercent: Double { ((c - pc) / pc) * 100 }
}

struct FinnhubNews: Codable {
    let category: String
    let datetime: Int
    let headline: String
    let id: Int
    let image: String
    let related: String
    let source: String
    let summary: String
    let url: String
    
    var publishedDate: Date { Date(timeIntervalSince1970: TimeInterval(datetime)) }
}

struct FinnhubCandle: Codable {
    let c: [Double] // Close prices
    let h: [Double] // High prices
    let l: [Double] // Low prices
    let o: [Double] // Open prices
    let t: [Int]    // Timestamps
    let v: [Double] // Volumes
    let s: String   // Status
    
    var candles: [CandleData] {
        guard c.count == h.count && h.count == l.count && 
              l.count == o.count && o.count == t.count && t.count == v.count else {
            return []
        }
        
        return (0..<c.count).map { index in
            CandleData(
                open: o[index],
                high: h[index],
                low: l[index],
                close: c[index],
                volume: v[index],
                timestamp: Date(timeIntervalSince1970: TimeInterval(t[index]))
            )
        }
    }
}

// MARK: - Alpha Vantage Models
struct AlphaVantageQuote: Codable {
    let globalQuote: GlobalQuote
    
    struct GlobalQuote: Codable {
        let symbol: String
        let open: String
        let high: String
        let low: String
        let price: String
        let volume: String
        let latestTradingDay: String
        let previousClose: String
        let change: String
        let changePercent: String
        
        enum CodingKeys: String, CodingKey {
            case symbol = "01. symbol"
            case open = "02. open"
            case high = "03. high"
            case low = "04. low"
            case price = "05. price"
            case volume = "06. volume"
            case latestTradingDay = "07. latest trading day"
            case previousClose = "08. previous close"
            case change = "09. change"
            case changePercent = "10. change percent"
        }
    }
}

struct AlphaVantageForex: Codable {
    let realtimeCurrencyExchangeRate: ForexRate
    
    struct ForexRate: Codable {
        let fromCurrencyCode: String
        let fromCurrencyName: String
        let toCurrencyCode: String
        let toCurrencyName: String
        let exchangeRate: String
        let lastRefreshed: String
        let timeZone: String
        let bidPrice: String
        let askPrice: String
        
        enum CodingKeys: String, CodingKey {
            case fromCurrencyCode = "1. From_Currency Code"
            case fromCurrencyName = "2. From_Currency Name"
            case toCurrencyCode = "3. To_Currency Code"
            case toCurrencyName = "4. To_Currency Name"
            case exchangeRate = "5. Exchange Rate"
            case lastRefreshed = "6. Last Refreshed"
            case timeZone = "7. Time Zone"
            case bidPrice = "8. Bid Price"
            case askPrice = "9. Ask Price"
        }
    }
}

// MARK: - CoinGecko Models
struct CoinGeckoPrice: Codable {
    let prices: [[Double]]
    let marketCaps: [[Double]]
    let totalVolumes: [[Double]]
    
    enum CodingKeys: String, CodingKey {
        case prices
        case marketCaps = "market_caps"
        case totalVolumes = "total_volumes"
    }
    
    var priceHistory: [PricePoint] {
        prices.map { data in
            PricePoint(
                timestamp: Date(timeIntervalSince1970: data[0] / 1000),
                price: data[1]
            )
        }
    }
}

struct CoinGeckoSimplePrice: Codable {
    let price: Double
    let marketCap: Double?
    let volume24h: Double?
    let change24h: Double?
    let changePercent24h: Double?
    let lastUpdated: String?
    
    // Dynamic keys for different cryptocurrencies
    private let container: [String: CryptoPrice]
    
    init(from decoder: Decoder) throws {
        container = try decoder.singleValueContainer().decode([String: CryptoPrice].self)
        
        // Get first crypto data
        let firstCrypto = container.values.first
        price = firstCrypto?.usd ?? 0
        marketCap = firstCrypto?.usdMarketCap
        volume24h = firstCrypto?.usd24hVol
        change24h = firstCrypto?.usd24hChange
        changePercent24h = firstCrypto?.usd24hChange
        lastUpdated = firstCrypto?.lastUpdatedAt
    }
    
    struct CryptoPrice: Codable {
        let usd: Double
        let usdMarketCap: Double?
        let usd24hVol: Double?
        let usd24hChange: Double?
        let lastUpdatedAt: String?
        
        enum CodingKeys: String, CodingKey {
            case usd
            case usdMarketCap = "usd_market_cap"
            case usd24hVol = "usd_24h_vol"
            case usd24hChange = "usd_24h_change"
            case lastUpdatedAt = "last_updated_at"
        }
    }
}

// MARK: - NewsAPI Models
struct NewsAPIResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [NewsArticle]
}

struct NewsArticle: Codable, Identifiable {
    let id = UUID()
    let source: NewsSource
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
    let content: String?
    
    var publishedDate: Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: publishedAt) ?? Date()
    }
    
    struct NewsSource: Codable {
        let id: String?
        let name: String
    }
}

// MARK: - Trading Economics Models
struct TradingEconomicsEvent: Codable, Identifiable {
    let id = UUID()
    let calendarId: String
    let date: String
    let country: String
    let category: String
    let event: String
    let reference: String?
    let source: String?
    let sourceURL: String?
    let actual: String?
    let previous: String?
    let forecast: String?
    let teforecast: String?
    let importance: Int
    let currency: String?
    let unit: String?
    
    enum CodingKeys: String, CodingKey {
        case calendarId = "CalendarId"
        case date = "Date"
        case country = "Country"
        case category = "Category"
        case event = "Event"
        case reference = "Reference"
        case source = "Source"
        case sourceURL = "SourceURL"
        case actual = "Actual"
        case previous = "Previous"
        case forecast = "Forecast"
        case teforecast = "TEForecast"
        case importance = "Importance"
        case currency = "Currency"
        case unit = "Unit"
    }
    
    var eventDate: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter.date(from: date) ?? Date()
    }
    
    var impactLevel: ImpactLevel {
        switch importance {
        case 3: return .high
        case 2: return .medium
        case 1: return .low
        default: return .low
        }
    }
    
    enum ImpactLevel {
        case low, medium, high
        
        var color: Color {
            switch self {
            case .low: return .green
            case .medium: return .orange
            case .high: return .red
            }
        }
        
        var description: String {
            switch self {
            case .low: return "Low Impact"
            case .medium: return "Medium Impact"
            case .high: return "High Impact"
            }
        }
    }
}

// MARK: - Fixer.io Models
struct FixerResponse: Codable {
    let success: Bool
    let timestamp: Int
    let base: String
    let date: String
    let rates: [String: Double]
    
    var exchangeDate: Date {
        Date(timeIntervalSince1970: TimeInterval(timestamp))
    }
}

// MARK: - Twelve Data Models
struct TwelveDataPrice: Codable {
    let symbol: String
    let price: String
    let percentChange: String?
    let change: String?
    let previousClose: String?
    let timestamp: Int?
    
    enum CodingKeys: String, CodingKey {
        case symbol
        case price
        case percentChange = "percent_change"
        case change
        case previousClose = "previous_close"
        case timestamp
    }
    
    var currentPrice: Double { Double(price) ?? 0 }
    var priceChange: Double { Double(change ?? "0") ?? 0 }
    var percentageChange: Double { Double(percentChange ?? "0") ?? 0 }
    var lastClose: Double { Double(previousClose ?? "0") ?? 0 }
}

struct TwelveDataTimeSeries: Codable {
    let meta: MetaData
    let values: [TimeSeriesValue]
    let status: String
    
    struct MetaData: Codable {
        let symbol: String
        let interval: String
        let currency: String?
        let exchangeTimezone: String?
        let exchange: String?
        let micCode: String?
        let type: String?
        
        enum CodingKeys: String, CodingKey {
            case symbol
            case interval
            case currency
            case exchangeTimezone = "exchange_timezone"
            case exchange
            case micCode = "mic_code"
            case type
        }
    }
    
    struct TimeSeriesValue: Codable {
        let datetime: String
        let open: String
        let high: String
        let low: String
        let close: String
        let volume: String?
        
        var date: Date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return formatter.date(from: datetime) ?? Date()
        }
        
        var candleData: CandleData {
            CandleData(
                open: Double(open) ?? 0,
                high: Double(high) ?? 0,
                low: Double(low) ?? 0,
                close: Double(close) ?? 0,
                volume: Double(volume ?? "0") ?? 0,
                timestamp: date
            )
        }
    }
}

// MARK: - Polygon.io Models
struct PolygonTicker: Codable {
    let ticker: String
    let todaysChangePerc: Double?
    let todaysChange: Double?
    let updated: Int64?
    let day: DayData?
    let lastQuote: LastQuote?
    let lastTrade: LastTrade?
    
    struct DayData: Codable {
        let c: Double? // Close
        let h: Double? // High
        let l: Double? // Low
        let o: Double? // Open
        let v: Double? // Volume
    }
    
    struct LastQuote: Codable {
        let a: Double? // Ask
        let b: Double? // Bid
        let t: Int64?  // Timestamp
    }
    
    struct LastTrade: Codable {
        let p: Double? // Price
        let s: Int?    // Size
        let t: Int64?  // Timestamp
    }
}

// MARK: - REST Countries Models
struct CountryInfo: Codable {
    let name: CountryName
    let currencies: [String: Currency]?
    let capital: [String]?
    let region: String?
    let subregion: String?
    let population: Int?
    let flags: Flags?
    let timezones: [String]?
    
    struct CountryName: Codable {
        let common: String
        let official: String
    }
    
    struct Currency: Codable {
        let name: String
        let symbol: String?
    }
    
    struct Flags: Codable {
        let png: String?
        let svg: String?
        let alt: String?
    }
}

// MARK: - Yahoo Finance Models
struct YahooFinanceResponse: Codable {
    let chart: Chart
    
    struct Chart: Codable {
        let result: [Result]?
        let error: ErrorInfo?
        
        struct Result: Codable {
            let meta: Meta
            let timestamp: [Int]?
            let indicators: Indicators
            
            struct Meta: Codable {
                let currency: String
                let symbol: String
                let exchangeName: String?
                let instrumentType: String?
                let firstTradeDate: Int?
                let regularMarketTime: Int?
                let gmtoffset: Int?
                let timezone: String?
                let exchangeTimezoneName: String?
                let regularMarketPrice: Double?
                let chartPreviousClose: Double?
                let previousClose: Double?
                let scale: Int?
                let priceHint: Int?
                let currentTradingPeriod: TradingPeriod?
                let tradingPeriods: [[TradingPeriod]]?
                let dataGranularity: String?
                let range: String?
                let validRanges: [String]?
            }
            
            struct TradingPeriod: Codable {
                let timezone: String?
                let start: Int?
                let end: Int?
                let gmtoffset: Int?
            }
            
            struct Indicators: Codable {
                let quote: [Quote]?
                let adjclose: [AdjClose]?
                
                struct Quote: Codable {
                    let open: [Double?]?
                    let high: [Double?]?
                    let low: [Double?]?
                    let close: [Double?]?
                    let volume: [Int?]?
                }
                
                struct AdjClose: Codable {
                    let adjclose: [Double?]?
                }
            }
        }
        
        struct ErrorInfo: Codable {
            let code: String
            let description: String
        }
    }
}

// MARK: - Common Models
struct CandleData: Identifiable {
    let id = UUID()
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let volume: Double
    let timestamp: Date
    
    var isGreen: Bool { close > open }
    var bodySize: Double { abs(close - open) }
    var shadowSize: Double { high - low }
    var upperShadow: Double { high - max(open, close) }
    var lowerShadow: Double { min(open, close) - low }
}

struct PricePoint: Identifiable {
    let id = UUID()
    let timestamp: Date
    let price: Double
}

struct MarketSentiment {
    let positive: Double
    let negative: Double
    let neutral: Double
    let overall: SentimentLevel
    
    enum SentimentLevel {
        case veryBearish, bearish, neutral, bullish, veryBullish
        
        var color: Color {
            switch self {
            case .veryBearish: return .red
            case .bearish: return .orange
            case .neutral: return .gray
            case .bullish: return .green
            case .veryBullish: return .mint
            }
        }
        
        var description: String {
            switch self {
            case .veryBearish: return "Very Bearish"
            case .bearish: return "Bearish"
            case .neutral: return "Neutral"
            case .bullish: return "Bullish"
            case .veryBullish: return "Very Bullish"
            }
        }
    }
}

// MARK: - Unified Models for UI
struct UnifiedQuote: Identifiable {
    let id = UUID()
    let symbol: String
    let currentPrice: Double
    let change: Double
    let changePercent: Double
    let high: Double
    let low: Double
    let volume: Double?
    let timestamp: Date
    let source: APIService
    
    var isPositive: Bool { change >= 0 }
    var formattedPrice: String { String(format: "%.4f", currentPrice) }
    var formattedChange: String { 
        let sign = change >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.4f", change))"
    }
    var formattedChangePercent: String {
        let sign = changePercent >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", changePercent))%"
    }
}

struct UnifiedNewsItem: Identifiable {
    let id = UUID()
    let title: String
    let summary: String
    let source: String
    let publishedAt: Date
    let url: String
    let imageURL: String?
    let apiSource: APIService
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: publishedAt, relativeTo: Date())
    }
}

#Preview {
    VStack {
        Text("Free API Models")
            .font(.title)
        Text("Comprehensive data structures for 10 APIs")
            .font(.caption)
    }
}
//
//  MarketNewsView.swift
//  Planet ProTrader - Solar System Edition
//
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

// MARK: - TradingTypes Namespace
enum TradingTypes {
    enum NewsImpact: String, CaseIterable, Codable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        case critical = "Critical"
        
        var color: Color {
            switch self {
            case .low: return .green
            case .medium: return .orange
            case .high: return .red
            case .critical: return .purple
            }
        }
        
        var emoji: String {
            switch self {
            case .low: return "info.circle.fill"
            case .medium: return "exclamationmark.circle.fill"
            case .high: return "exclamationmark.triangle.fill"
            case .critical: return "exclamationmark.octagon.fill"
            }
        }
        
        var priority: Int {
            switch self {
            case .low: return 1
            case .medium: return 2
            case .high: return 3
            case .critical: return 4
            }
        }
        
        var description: String {
            switch self {
            case .low: return "Minor market impact expected"
            case .medium: return "Moderate market movement anticipated"
            case .high: return "Significant market volatility likely"
            case .critical: return "Major market disruption possible"
            }
        }
    }
}

// MARK: - Market News Types
enum MarketNewsCategory: String, CaseIterable {
    case all = "all"
    case centralBank = "central_bank"
    case economic = "economic"
    case stocks = "stocks"
    case commodities = "commodities"
    case crypto = "crypto"
    case geopolitical = "geopolitical"
    
    var displayName: String {
        switch self {
        case .all: return "All"
        case .centralBank: return "Central Banks"
        case .economic: return "Economic"
        case .stocks: return "Stocks"
        case .commodities: return "Commodities"
        case .crypto: return "Crypto"
        case .geopolitical: return "Geopolitical"
        }
    }
    
    var iconName: String {
        switch self {
        case .all: return "globe.americas.fill"
        case .centralBank: return "building.columns.fill"
        case .economic: return "chart.line.uptrend.xyaxis"
        case .stocks: return "chart.bar.fill"
        case .commodities: return "leaf.fill"
        case .crypto: return "bitcoinsign.circle.fill"
        case .geopolitical: return "globe.europe.africa.fill"
        }
    }
}

enum NewsSentiment: String, CaseIterable {
    case bullish = "bullish"
    case neutral = "neutral"
    case bearish = "bearish"
    
    var displayName: String {
        switch self {
        case .bullish: return "Bullish"
        case .neutral: return "Neutral"
        case .bearish: return "Bearish"
        }
    }
    
    var icon: String {
        switch self {
        case .bullish: return "arrow.up.circle.fill"
        case .neutral: return "minus.circle.fill"
        case .bearish: return "arrow.down.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .bullish: return .green
        case .neutral: return .gray
        case .bearish: return .red
        }
    }
}

enum NewsTimeFilterConsolidated: String, CaseIterable {
    case all = "all"
    case lastHour = "last_hour"
    case today = "today"
    case thisWeek = "this_week"
}

struct NewsFilters {
    var impacts: Set<TradingTypes.NewsImpact> = Set(TradingTypes.NewsImpact.allCases)
    var sentiments: Set<NewsSentiment> = Set(NewsSentiment.allCases)
    var currencies: Set<String> = []
    var sources: Set<String> = []
    var timeFilter: NewsTimeFilterConsolidated = .all
}

struct MarketNewsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var newsManager = MarketNewsManager.shared
    @State private var selectedCategory: MarketNewsCategory = .all
    @State private var showingFilters = false
    @State private var selectedArticle: MarketNewsArticle?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with live updates
                headerSection
                
                // News categories
                categoriesSection
                
                // News list
                ScrollView {
                    LazyVStack(spacing: 16) {
                        if newsManager.isLoading {
                            loadingView
                        } else {
                            ForEach(filteredNews) { article in
                                newsCard(article: article)
                                    .onTapGesture {
                                        selectedArticle = article
                                    }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .refreshable {
                    await newsManager.refreshNews()
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle("📰 Market News")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        Button(action: { showingFilters = true }) {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(DesignSystem.primaryGold)
                        }
                        
                        Button("Done") {
                            dismiss()
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(DesignSystem.primaryGold)
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .sheet(isPresented: $showingFilters) {
            NewsFiltersView(newsManager: newsManager)
        }
        .sheet(item: $selectedArticle) { article in
            NewsDetailView(article: NewsArticleModel(from: article))
        }
        .onAppear {
            Task {
                await newsManager.loadNews()
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Live Market Updates")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                            .scaleEffect(newsManager.isLive ? 1.0 : 0.5)
                            .animation(.easeInOut(duration: 1.0).repeatForever(), value: newsManager.isLive)
                        
                        Text(newsManager.isLive ? "Live Updates" : "Offline")
                            .font(.caption)
                            .foregroundColor(newsManager.isLive ? .green : .secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(newsManager.totalNews)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.primaryGold)
                    
                    Text("articles")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Market Impact Summary
            marketImpactSummary
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 16)
        .background(Color(.systemGray6).opacity(0.5))
    }
    
    private var marketImpactSummary: some View {
        HStack(spacing: 16) {
            impactIndicator(
                title: "High Impact",
                count: newsManager.highImpactCount,
                color: .red
            )
            
            impactIndicator(
                title: "Medium Impact",
                count: newsManager.mediumImpactCount,
                color: .orange
            )
            
            impactIndicator(
                title: "Low Impact",
                count: newsManager.lowImpactCount,
                color: .green
            )
        }
    }
    
    private func impactIndicator(title: String, count: Int, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Categories Section
    
    private var categoriesSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(MarketNewsCategory.allCases, id: \.self) { category in
                    categoryButton(category: category)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 12)
        .background(Color(.systemGray6).opacity(0.3))
    }
    
    private func categoryButton(category: MarketNewsCategory) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedCategory = category
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: category.iconName)
                    .font(.caption2)
                
                Text(category.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                
                if category != .all {
                    Text("\(newsManager.getNewsCount(for: category))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(.systemGray5))
                        .cornerRadius(4)
                }
            }
            .foregroundColor(selectedCategory == category ? .white : .primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                selectedCategory == category 
                ? DesignSystem.primaryGold
                : Color(.systemBackground)
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        selectedCategory == category 
                        ? DesignSystem.primaryGold
                        : Color(.systemGray4), 
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - News Cards
    
    private var filteredNews: [MarketNewsArticle] {
        newsManager.getFilteredNews(category: selectedCategory)
    }
    
    private func newsCard(article: MarketNewsArticle) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with impact and time
            HStack {
                impactBadge(impact: article.impact)
                
                Spacer()
                
                Text(article.timeAgo)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Title and summary
            VStack(alignment: .leading, spacing: 8) {
                Text(article.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                if let summary = article.summary {
                    Text(summary)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
            }
            
            // Footer with source and currencies
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Image(systemName: "building.2.fill")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text(article.source)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if !article.affectedCurrencies.isEmpty {
                        HStack(spacing: 4) {
                            ForEach(Array(article.affectedCurrencies.prefix(3)), id: \.self) { currency in
                                Text(currency)
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 2)
                                    .background(currencyColor(currency))
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Sentiment indicator
                sentimentIndicator(sentiment: article.sentiment)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(article.impact.color.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func impactBadge(impact: TradingTypes.NewsImpact) -> some View {
        HStack(spacing: 4) {
            Image(systemName: impact.emoji)
                .font(.caption2)
            
            Text(impact.rawValue)
                .font(.caption2)
                .fontWeight(.bold)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(impact.color)
        .cornerRadius(6)
    }
    
    private func sentimentIndicator(sentiment: NewsSentiment) -> some View {
        HStack(spacing: 4) {
            Image(systemName: sentiment.icon)
                .font(.caption2)
            
            Text(sentiment.displayName)
                .font(.caption2)
                .fontWeight(.medium)
        }
        .foregroundColor(sentiment.color)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(sentiment.color.opacity(0.1))
        .cornerRadius(4)
    }
    
    private func currencyColor(_ currency: String) -> Color {
        switch currency {
        case "USD": return .blue
        case "EUR": return .purple
        case "GBP": return .green
        case "JPY": return .red
        case "CHF": return DesignSystem.primaryGold
        case "CAD": return .pink
        case "AUD": return .cyan
        case "NZD": return .mint
        default: return .gray
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ForEach(0..<5) { _ in
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.systemGray5))
                            .frame(width: 80, height: 20)
                        
                        Spacer()
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.systemGray5))
                            .frame(width: 50, height: 16)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.systemGray5))
                            .frame(height: 16)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.systemGray5))
                            .frame(width: 200, height: 14)
                    }
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(width: 150, height: 12)
                }
                .padding(16)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                .shimmering()
            }
        }
    }
}

// MARK: - Market News Manager
class MarketNewsManager: ObservableObject {
    static let shared = MarketNewsManager()
    
    @Published var news: [MarketNewsArticle] = []
    @Published var isLoading: Bool = false
    @Published var isLive: Bool = true
    
    // Filter properties
    @Published var activeFilters: NewsFilters = NewsFilters()
    
    private init() {
        // Start with sample data
        loadSampleNews()
    }
    
    var totalNews: Int { news.count }
    var highImpactCount: Int { news.filter { $0.impact == .high || $0.impact == .critical }.count }
    var mediumImpactCount: Int { news.filter { $0.impact == .medium }.count }
    var lowImpactCount: Int { news.filter { $0.impact == .low }.count }
    
    func loadNews() async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        // Simulate API call
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        DispatchQueue.main.async {
            self.loadSampleNews()
            self.isLoading = false
        }
    }
    
    func refreshNews() async {
        await loadNews()
    }
    
    func updateFilters(
        impacts: Set<TradingTypes.NewsImpact>,
        sentiments: Set<NewsSentiment>,
        currencies: Set<String>,
        sources: Set<String>,
        timeFilter: NewsTimeFilterConsolidated
    ) {
        activeFilters.impacts = impacts
        activeFilters.sentiments = sentiments
        activeFilters.currencies = currencies
        activeFilters.sources = sources
        activeFilters.timeFilter = timeFilter
    }
    
    func getFilteredNews(category: MarketNewsCategory) -> [MarketNewsArticle] {
        var filteredNews = news
        
        // Filter by category
        if category != .all {
            filteredNews = filteredNews.filter { $0.category == category }
        }
        
        // Apply active filters
        filteredNews = filteredNews.filter { article in
            // Impact filter
            if !activeFilters.impacts.isEmpty && !activeFilters.impacts.contains(article.impact) {
                return false
            }
            
            // Sentiment filter
            if !activeFilters.sentiments.isEmpty && !activeFilters.sentiments.contains(article.sentiment) {
                return false
            }
            
            // Currency filter
            if !activeFilters.currencies.isEmpty && Set(article.affectedCurrencies).isDisjoint(with: activeFilters.currencies) {
                return false
            }
            
            // Source filter
            if !activeFilters.sources.isEmpty && !activeFilters.sources.contains(article.source) {
                return false
            }
            
            // Time filter
            if !passesTimeFilter(article: article, filter: activeFilters.timeFilter) {
                return false
            }
            
            return true
        }
        
        return filteredNews.sorted { $0.timestamp > $1.timestamp }
    }
    
    func getNewsCount(for category: MarketNewsCategory) -> Int {
        return news.filter { $0.category == category }.count
    }
    
    private func passesTimeFilter(article: MarketNewsArticle, filter: NewsTimeFilterConsolidated) -> Bool {
        let now = Date()
        let articleTime = article.timestamp
        
        switch filter {
        case .all:
            return true
        case .lastHour:
            return articleTime > now.addingTimeInterval(-3600)
        case .today:
            return Calendar.current.isDate(articleTime, inSameDayAs: now)
        case .thisWeek:
            let weekAgo = now.addingTimeInterval(-7 * 24 * 3600)
            return articleTime > weekAgo
        }
    }
    
    private func loadSampleNews() {
        news = [
            MarketNewsArticle(
                title: "Federal Reserve Signals Pause in Interest Rate Hikes",
                summary: "Fed Chairman Powell indicates potential pause in rate increases, citing economic uncertainty and inflation concerns.",
                source: "Reuters",
                category: .centralBank,
                impact: .high,
                sentiment: .bearish,
                affectedCurrencies: ["USD", "EUR", "GBP"],
                timestamp: Date().addingTimeInterval(-300)
            ),
            MarketNewsArticle(
                title: "Gold Prices Surge to New Monthly Highs",
                summary: "Precious metals rally as investors seek safe haven amid market volatility and geopolitical tensions.",
                source: "MarketWatch",
                category: .commodities,
                impact: .medium,
                sentiment: .bullish,
                affectedCurrencies: ["XAU", "USD"],
                timestamp: Date().addingTimeInterval(-900)
            ),
            MarketNewsArticle(
                title: "European Central Bank Maintains Hawkish Stance",
                summary: "ECB officials continue to emphasize commitment to fighting inflation despite economic growth concerns.",
                source: "Bloomberg",
                category: .centralBank,
                impact: .high,
                sentiment: .neutral,
                affectedCurrencies: ["EUR", "USD"],
                timestamp: Date().addingTimeInterval(-1200)
            ),
            MarketNewsArticle(
                title: "Chinese Manufacturing Data Shows Improvement",
                summary: "Latest PMI data indicates recovering manufacturing activity in China, boosting risk sentiment globally.",
                source: "Financial Times",
                category: .economic,
                impact: .medium,
                sentiment: .bullish,
                affectedCurrencies: ["CNY", "AUD", "NZD"],
                timestamp: Date().addingTimeInterval(-1800)
            ),
            MarketNewsArticle(
                title: "Technology Stocks Rally on AI Optimism",
                summary: "Major technology stocks surge, improving market sentiment and supporting risk-sensitive currencies.",
                source: "CNBC",
                category: .stocks,
                impact: .low,
                sentiment: .bullish,
                affectedCurrencies: ["AUD", "NZD", "CAD"],
                timestamp: Date().addingTimeInterval(-2100)
            )
        ]
    }
}

// MARK: - Data Models
struct MarketNewsArticle: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let summary: String?
    let source: String
    let category: MarketNewsCategory
    let impact: TradingTypes.NewsImpact
    let sentiment: NewsSentiment
    let affectedCurrencies: [String]
    let timestamp: Date
    
    var timeAgo: String {
        let interval = Date().timeIntervalSince(timestamp)
        
        if interval < 60 {
            return "\(Int(interval))s ago"
        } else if interval < 3600 {
            return "\(Int(interval / 60))m ago"
        } else {
            return "\(Int(interval / 3600))h ago"
        }
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MarketNewsArticle, rhs: MarketNewsArticle) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - NewsArticleModel (for NewsDetailView compatibility)
struct NewsArticleModel: Identifiable {
    let id = UUID()
    let title: String
    let summary: String
    let content: String
    let impact: TradingTypes.NewsImpact
    let publishedAt: Date
    let source: String
    let category: String
    let tags: [String]
    
    init(from article: MarketNewsArticle) {
        self.title = article.title
        self.summary = article.summary ?? ""
        self.content = article.summary ?? "Full article content would be displayed here. This is a sample news article that demonstrates the structure and layout of the news detail view."
        self.impact = article.impact
        self.publishedAt = article.timestamp
        self.source = article.source
        self.category = article.category.displayName
        self.tags = article.affectedCurrencies
    }
    
    // Sample news for compatibility
    static let sampleNews: [NewsArticleModel] = [
        NewsArticleModel(
            from: MarketNewsArticle(
                title: "Sample News Article",
                summary: "This is a sample article",
                source: "Sample Source",
                category: .economic,
                impact: .medium,
                sentiment: .neutral,
                affectedCurrencies: ["USD"],
                timestamp: Date()
            )
        )
    ]
}

// MARK: - Shimmer Effect
extension View {
    func shimmering() -> some View {
        self.modifier(NewsShimmerModifier())
    }
}

struct NewsShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.clear,
                        Color.white.opacity(0.4),
                        Color.clear
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .rotationEffect(.degrees(45))
                .offset(x: phase)
                .clipped()
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 400
                }
            }
    }
}

// MARK: - Supporting Views

struct NewsFiltersView: View {
    @ObservedObject var newsManager: MarketNewsManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("🔧 News Filters")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.goldGradient)
                
                Text("Filter news by impact, sentiment, and more")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                VStack(spacing: 16) {
                    Text("Advanced filtering options coming soon!")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Filter by impact level, sentiment, currencies, sources, and time range")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(20)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                
                Spacer()
            }
            .padding()
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(DesignSystem.primaryGold)
                }
            }
        }
    }
}

#Preview {
    MarketNewsView()
}
import Foundation

enum MT5OrderType: String, Codable {
    case buy
    case sell
}

enum MT5BridgeMode: String, Codable {
    case restDirect
    case edgeFunction
}

struct MT5BridgeConfig: Codable {
    var enabled: Bool
    var mode: MT5BridgeMode
    var supabaseURL: URL?
    var supabaseApiKey: String?
    var edgeFunctionURL: URL?
    var simulateLocally: Bool
    
    init(
        enabled: Bool = false,
        mode: MT5BridgeMode = .restDirect,
        supabaseURL: URL? = URL(string: "https://bywgvdodipvotzuddzkp.supabase.co"),
        supabaseApiKey: String? = nil,
        edgeFunctionURL: URL? = nil,
        simulateLocally: Bool = true
    ) {
        self.enabled = enabled
        self.mode = mode
        self.supabaseURL = supabaseURL
        self.supabaseApiKey = supabaseApiKey
        self.edgeFunctionURL = edgeFunctionURL
        self.simulateLocally = simulateLocally
    }
}

final class MT5BridgeService {
    static let shared = MT5BridgeService()
    private init() {}
    
    var config = MT5BridgeConfig()
    
    struct TradeCommandRow: Codable {
        let id: String
        let created_at: String
        let status: String
        let symbol: String
        let volume: Double
        let type: String
        let account_login: String?
        let account_server: String?
        let bot_id: String
        let bot_name: String
        let mode: String
    }
    
    func placeOrder(
        accountLogin: String?,
        accountServer: String?,
        symbol: String,
        volume: Double,
        type: MT5OrderType,
        sl: Double? = nil,
        tp: Double? = nil,
        botId: String,
        botName: String,
        mode: String = "flip"
    ) async throws {
        if config.simulateLocally || !config.enabled {
            print("🟡 Simulated MT5 order: \(symbol) \(type.rawValue) \(volume) by \(botName)")
            return
        }
        
        switch config.mode {
        case .restDirect:
            try await enqueueDirectREST(
                accountLogin: accountLogin,
                accountServer: accountServer,
                symbol: symbol,
                volume: volume,
                type: type,
                botId: botId,
                botName: botName,
                mode: mode
            )
        case .edgeFunction:
            try await callEdgeFunction(
                accountLogin: accountLogin,
                accountServer: accountServer,
                symbol: symbol,
                volume: volume,
                type: type,
                botId: botId,
                botName: botName,
                mode: mode
            )
        }
    }
    
    private func enqueueDirectREST(
        accountLogin: String?,
        accountServer: String?,
        symbol: String,
        volume: Double,
        type: MT5OrderType,
        botId: String,
        botName: String,
        mode: String
    ) async throws {
        guard let base = config.supabaseURL, let apiKey = config.supabaseApiKey else {
            throw NSError(domain: "MT5Bridge", code: -2, userInfo: [NSLocalizedDescriptionKey: "Supabase URL/API key missing"])
        }
        let url = base.appendingPathComponent("/rest/v1/trade_commands")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        req.setValue(apiKey, forHTTPHeaderField: "apikey")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("return=minimal", forHTTPHeaderField: "Prefer")
        
        let row = TradeCommandRow(
            id: UUID().uuidString,
            created_at: ISO8601DateFormatter().string(from: Date()),
            status: "pending",
            symbol: symbol,
            volume: volume,
            type: type.rawValue,
            account_login: accountLogin,
            account_server: accountServer,
            bot_id: botId,
            bot_name: botName,
            mode: mode
        )
        req.httpBody = try JSONEncoder().encode(row)
        
        let (_, resp) = try await URLSession.shared.data(for: req)
        if let http = resp as? HTTPURLResponse, http.statusCode >= 300 {
            throw NSError(domain: "MT5Bridge", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: "REST enqueue HTTP \(http.statusCode)"])
        }
        
        print("🟢 Command enqueued (REST): \(botName) \(type.rawValue) \(symbol) \(volume)")
    }
    
    private func callEdgeFunction(
        accountLogin: String?,
        accountServer: String?,
        symbol: String,
        volume: Double,
        type: MT5OrderType,
        botId: String,
        botName: String,
        mode: String
    ) async throws {
        guard let endpoint = config.edgeFunctionURL, let apiKey = config.supabaseApiKey else {
            throw NSError(domain: "MT5Bridge", code: -3, userInfo: [NSLocalizedDescriptionKey: "Edge Function URL/API key missing"])
        }
        var req = URLRequest(url: endpoint)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        req.setValue(apiKey, forHTTPHeaderField: "apikey")
        let body: [String: Any] = [
            "accountLogin": accountLogin as Any,
            "accountServer": accountServer as Any,
            "symbol": symbol,
            "volume": volume,
            "type": type.rawValue,
            "botId": botId,
            "botName": botName,
            "mode": mode
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, resp) = try await URLSession.shared.data(for: req)
        if let http = resp as? HTTPURLResponse, http.statusCode >= 300 {
            throw NSError(domain: "MT5Bridge", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: "Function HTTP \(http.statusCode)"])
        }
        print("🟢 Command routed (Edge Function): \(botName) \(type.rawValue) \(symbol) \(volume)")
    }
}
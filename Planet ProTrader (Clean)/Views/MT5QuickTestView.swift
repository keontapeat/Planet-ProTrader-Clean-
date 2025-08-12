import SwiftUI

struct MT5QuickTestView: View {
    @State private var supabaseURL = "https://bywgvdodipvotzuddzkp.supabase.co"
    @State private var anonKey = ""
    @State private var symbol = "XAUUSD"
    @State private var volume = "0.01"
    @State private var status = "Idle"
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Supabase") {
                    TextField("Project URL", text: $supabaseURL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    SecureField("Anon Key", text: $anonKey)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                
                Section("Order") {
                    TextField("Symbol", text: $symbol)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    TextField("Volume", text: $volume)
                        .keyboardType(.decimalPad)
                }
                
                Section("Actions") {
                    HStack {
                        Button("Buy") { send(.buy) }
                            .buttonStyle(.borderedProminent)
                        Button("Sell") { send(.sell) }
                            .buttonStyle(.bordered)
                    }
                    
                    Text(status)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("MT5 Quick Test")
        }
    }
    
    private func configure() {
        var cfg = MT5BridgeService.shared.config
        cfg.enabled = true
        cfg.mode = .restDirect
        cfg.supabaseURL = URL(string: supabaseURL)
        cfg.supabaseApiKey = anonKey.isEmpty ? nil : anonKey
        cfg.simulateLocally = false
        MT5BridgeService.shared.config = cfg
    }
    
    private func send(_ type: MT5OrderType) {
        configure()
        guard let vol = Double(volume) else {
            status = "Invalid volume"
            return
        }
        Task {
            do {
                try await MT5BridgeService.shared.placeOrder(
                    accountLogin: nil,
                    accountServer: nil,
                    symbol: symbol,
                    volume: vol,
                    type: type,
                    botId: UUID().uuidString,
                    botName: "QuickTest",
                    mode: "quick"
                )
                await MainActor.run { status = "Sent \(type.rawValue.uppercased()) \(symbol) \(vol)" }
            } catch {
                await MainActor.run { status = "Error: \(error.localizedDescription)" }
            }
        }
    }
}

#Preview {
    MT5QuickTestView()
}
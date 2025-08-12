import SwiftUI

struct FlipModeView: View {
    @StateObject private var army = ProTraderArmyManager()
    @StateObject private var flip = FlipModeManager.shared
    
    @State private var selected: Set<UUID> = []
    @State private var startingBalance: Double = 1000
    @State private var targetEquity: Double = 5000
    @State private var enableLiveRouting = false
    
    @State private var broker = "Coinexx"
    @State private var server = "Coinexx-Demo"
    @State private var login = ""
    @State private var password = ""

    @State private var supabaseURLString = "https://bywgvdodipvotzuddzkp.supabase.co"
    @State private var supabaseAnonKey = ""
    @State private var simulateLocally = false
    @State private var useEdgeFunction = false
    @State private var edgeFunctionURLString = "https://bywgvdodipvotzuddzkp.supabase.co/functions/v1/mt5-execute"

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        headerSection
                        connectionSection
                        botPickerSection
                        leaderboardSection
                        tradesSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Flip Mode")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                Task { await army.quickSetup() }
                configureBridge()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(flip.isRunning ? "Stop" : "Start") {
                        if flip.isRunning {
                            flip.stopSession()
                        } else {
                            Task { await startFlip() }
                        }
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("🏆 Coinexx $1,000 ➜ $5,000 Flip Challenge")
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                Spacer()
                Text(flip.isRunning ? "LIVE" : "IDLE")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(flip.isRunning ? .green : .gray)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background((flip.isRunning ? Color.green : Color.gray).opacity(0.2), in: Capsule())
            }
            
            HStack(spacing: 12) {
                metricCard("Start", "$\(Int(startingBalance))", .blue, "flag.checkered")
                metricCard("Target", "$\(Int(targetEquity))", .green, "trophy.fill")
                metricCard("Bots", "\(selected.count)", .orange, "person.3.fill")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(.yellow.opacity(0.25), lineWidth: 1))
        )
    }
    
    private var connectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🔗 Execution Mode")
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                Spacer()
            }
            
            Toggle(isOn: $enableLiveRouting) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(enableLiveRouting ? "Route to MT5 EA (Direct Supabase — simplest)" : "Local Simulation (no EA required)")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                    Text(enableLiveRouting ? "MT5 EA on your PC reads pending commands from Supabase and executes." : "Fast on-device sim — perfect for testing")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .tint(.orange)

            if enableLiveRouting {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Direct Supabase (Recommended)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    TextField("Supabase URL (copy your project URL)", text: $supabaseURLString)
                        .textFieldStyle(.roundedBorder)
                    SecureField("Supabase Anon Key (paste yours here)", text: $supabaseAnonKey)
                        .textFieldStyle(.roundedBorder)
                    Toggle("Simulate locally (do not send to EA)", isOn: $simulateLocally)
                        .tint(.orange)

                    Toggle("Use Edge Function instead (advanced)", isOn: $useEdgeFunction)
                        .tint(.orange)
                    if useEdgeFunction {
                        TextField("Edge Function URL", text: $edgeFunctionURLString)
                            .textFieldStyle(.roundedBorder)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        TextField("Broker", text: $broker)
                            .textFieldStyle(.roundedBorder)
                        TextField("Server", text: $server)
                            .textFieldStyle(.roundedBorder)
                    }
                    HStack(spacing: 12) {
                        TextField("Login", text: $login)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                        SecureField("Password", text: $password)
                            .textFieldStyle(.roundedBorder)
                    }
                    Text("Keep your MT5 terminal on (home PC works). Attach ProTraderBridgeEA, set the same Supabase URL + Anon Key.")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(.cyan.opacity(0.25), lineWidth: 1))
        )
        .onChange(of: enableLiveRouting) { _, _ in configureBridge() }
        .onChange(of: supabaseURLString) { _, _ in configureBridge() }
        .onChange(of: supabaseAnonKey) { _, _ in configureBridge() }
        .onChange(of: simulateLocally) { _, _ in configureBridge() }
        .onChange(of: useEdgeFunction) { _, _ in configureBridge() }
        .onChange(of: edgeFunctionURLString) { _, _ in configureBridge() }
    }
    
    private var botPickerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🤖 Select Bots for Flip Race")
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                Spacer()
                Stepper("Start: $\(Int(startingBalance))", value: $startingBalance, in: 100...5000, step: 100)
                    .labelsHidden()
            }
            
            LazyVStack(spacing: 10) {
                ForEach(army.bots.sorted(by: { $0.confidence > $1.confidence }).prefix(30)) { bot in
                    Button {
                        toggleBot(bot)
                    } label: {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(selected.contains(bot.id) ? Color.green : Color.gray.opacity(0.4))
                                .frame(width: 10, height: 10)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(bot.name).foregroundColor(.white).fontWeight(.bold)
                                Text("Confidence: \(Int(bot.confidence * 100))% • PnL: +$\(Int(bot.profitLoss)) • W/L: \(bot.wins)/\(bot.losses)")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Image(systemName: selected.contains(bot.id) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selected.contains(bot.id) ? .green : .gray)
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(.green.opacity(0.25), lineWidth: 1))
        )
    }
    
    private var leaderboardSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🏁 Leaderboard")
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                Spacer()
                if let s = flip.currentSession, s.isCompleted {
                    Text("WINNER: \(s.bots.first(where: { $0.botId == s.winnerBotId })?.name ?? "-")")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.yellow.opacity(0.2), in: Capsule())
                }
            }
            
            if let session = flip.currentSession {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(session.bots.sorted(by: { $0.equity > $1.equity })) { b in
                            VStack(spacing: 8) {
                                Text(b.name).foregroundColor(.white).font(.subheadline).fontWeight(.bold).lineLimit(1)
                                Text("Equity: $\(Int(b.equity))").foregroundColor(.green).fontWeight(.black)
                                HStack(spacing: 10) {
                                    label("PnL", "+$\(Int(b.realizedPnL))", .mint)
                                    label("Win", "\(Int(b.winRate))%", .cyan)
                                    label("Trades", "\(b.tradesCount)", .orange)
                                }
                            }
                            .frame(width: 180)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))
                        }
                    }
                }
            } else {
                Text("Start a session to populate leaderboard")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(.yellow.opacity(0.25), lineWidth: 1))
        )
    }
    
    private var tradesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("📊 Recent Trades")
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                Spacer()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(flip.recentTrades.prefix(24)) { t in
                        VStack(spacing: 6) {
                            Text(t.symbol).foregroundColor(.white).font(.caption).fontWeight(.bold)
                            Text(t.action).font(.caption2)
                                .foregroundColor(t.action == "BUY" ? .green : .red)
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background((t.action == "BUY" ? Color.green : Color.red).opacity(0.2), in: Capsule())
                            Text("$\(String(format: "%.2f", t.profit))")
                                .font(.caption)
                                .foregroundColor(t.profit >= 0 ? .green : .red)
                            Text(t.timestamp, style: .time).font(.caption2).foregroundColor(.gray)
                        }
                        .frame(width: 90)
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 8).fill(.ultraThinMaterial))
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(.cyan.opacity(0.25), lineWidth: 1))
        )
    }
    
    private func metricCard(_ title: String, _ value: String, _ color: Color, _ icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon).foregroundColor(color)
            Text(value).foregroundColor(.white).font(.headline).fontWeight(.black)
            Text(title).foregroundColor(.gray).font(.caption)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial))
    }
    
    private func label(_ title: String, _ value: String, _ color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value).foregroundColor(color).fontWeight(.bold)
            Text(title).foregroundColor(.gray).font(.caption2)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func toggleBot(_ bot: ProTraderBot) {
        if selected.contains(bot.id) {
            selected.remove(bot.id)
        } else {
            selected.insert(bot.id)
        }
    }
    
    private func startFlip() async {
        configureBridge()
        let chosen = army.bots.filter { selected.contains($0.id) }
        guard !chosen.isEmpty else { return }
        let creds = enableLiveRouting
        ? FlipAccountCredentials(broker: broker, server: server, login: login, password: password)
        : nil
        await flip.startNewSession(
            title: "Coinexx Flip Challenge",
            startingBalance: startingBalance,
            targetEquity: targetEquity,
            selectedBots: chosen,
            coinexx: creds,
            liveRouting: enableLiveRouting
        )
    }

    private func configureBridge() {
        var cfg = MT5BridgeService.shared.config
        cfg.enabled = enableLiveRouting
        cfg.simulateLocally = !enableLiveRouting || simulateLocally
        cfg.supabaseURL = URL(string: supabaseURLString)
        cfg.supabaseApiKey = supabaseAnonKey.isEmpty ? nil : supabaseAnonKey
        cfg.mode = useEdgeFunction ? .edgeFunction : .restDirect
        cfg.edgeFunctionURL = URL(string: edgeFunctionURLString)
        MT5BridgeService.shared.config = cfg
    }
}

#Preview {
    FlipModeView()
        .preferredColorScheme(.dark)
}
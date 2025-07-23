import SwiftUI

struct ProTraderDashboardView: View {
    @EnvironmentObject var solarManager: SolarSystemManager
    @Environment(\.dismiss) private var dismiss
    @State private var headerAnimated = false
    @State private var animatedBalance: Double = 5000.0
    @State private var isBalanceHidden = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                // ProTrader gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.9),
                        Color.blue.opacity(0.6),
                        Color(.systemGroupedBackground)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        proTraderHeader
                        statisticsSection
                        recentChallengeSection
                        quickActionsSection
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            dismiss()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "chevron.left")
                                Text("Solar System")
                            }
                            .foregroundColor(.white)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack(spacing: 12) {
                            // Planet indicator
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: solarManager.selectedPlanet.gradientColors),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 20, height: 20)
                                    .overlay(
                                        Image(systemName: solarManager.selectedPlanet.icon)
                                            .font(.system(size: 10))
                                            .foregroundColor(.white)
                                    )
                                
                                Text(solarManager.selectedPlanet.name)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.2))
                            )
                        }
                    }
                }
            }
        }
        .task {
            withAnimation(Animation.spring(response: 0.6)) {
                headerAnimated = true
            }
        }
    }

    // MARK: - Subviews
    private var proTraderHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("PEAT")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(headerAnimated ? 1.0 : 0)
                    .offset(x: headerAnimated ? 0 : -50)
                    .animation(.easeOut(duration: 0.8).delay(0.2), value: headerAnimated)
                
                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Welcome to ProTrader Planet,")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .opacity(headerAnimated ? 1.0 : 0)
                    .offset(y: headerAnimated ? 0 : 20)
                    .animation(.easeOut(duration: 0.8).delay(0.3), value: headerAnimated)

                Text("Keonta")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(headerAnimated ? 1.0 : 0)
                    .offset(y: headerAnimated ? 0 : 30)
                    .animation(.easeOut(duration: 0.8).delay(0.4), value: headerAnimated)

                // Enhanced animated balance
                HStack(spacing: 8) {
                    Text(isBalanceHidden ? "••••••••" : formattedBalance(animatedBalance))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .opacity(headerAnimated ? 1.0 : 0)
                        .offset(y: headerAnimated ? 0 : 40)
                        .animation(.easeOut(duration: 0.8).delay(0.5), value: headerAnimated)
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isBalanceHidden.toggle()
                        }
                    }) {
                        Image(systemName: isBalanceHidden ? "eye.slash.fill" : "eye.fill")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .opacity(headerAnimated ? 1.0 : 0)
                    .animation(.easeOut(duration: 0.8).delay(0.6), value: headerAnimated)
                }
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isBalanceHidden.toggle()
                    }
                }
                
                // ProTrader Planet info
                HStack(spacing: 8) {
                    Image(systemName: "circle.fill")
                        .font(.caption2)
                        .foregroundColor(.cyan)
                    
                    Text("ProTrader Planet - PEAT Master")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("(Active)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
                .opacity(headerAnimated ? 1.0 : 0)
                .animation(.easeOut(duration: 0.8).delay(0.7), value: headerAnimated)
            }
        }
        .padding(.horizontal)
        .padding(.top, 60)
        .padding(.bottom, 20)
    }

    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Performance Overview")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ProTraderStatCard(title: "Win Rate", value: "73.2%", color: .green, icon: "chart.line.uptrend.xyaxis")
                ProTraderStatCard(title: "Profit Factor", value: "2.35", color: .blue, icon: "arrow.up.right.circle.fill")
                ProTraderStatCard(title: "Total Trades", value: "127", color: .orange, icon: "number.circle.fill")
                ProTraderStatCard(title: "Net P&L", value: "$1,247", color: .green, icon: "plus.circle.fill")
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private var recentChallengeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Challenge")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                Text("$50K Challenge - Phase 1")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                HStack {
                    Text("Progress:")
                    Spacer()
                    Text("78%")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray5))
                            .frame(height: 12)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue)
                            .frame(width: geometry.size.width * 0.78, height: 12)
                    }
                }
                .frame(height: 12)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                QuickActionCard(title: "New Trade", icon: "plus.circle", color: .green)
                QuickActionCard(title: "Analysis", icon: "chart.bar", color: .blue)
                QuickActionCard(title: "Journal", icon: "book", color: .orange)
                QuickActionCard(title: "Settings", icon: "gear", color: .gray)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }

    // MARK: - Helper Methods
    private func formattedBalance(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

// MARK: - Supporting Views
struct ProTraderStatCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                    .monospacedDigit()
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontWeight(.medium)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
struct ProTraderDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        ProTraderDashboardView()
            .environmentObject(SolarSystemManager())
            .preferredColorScheme(.light)
    }
}
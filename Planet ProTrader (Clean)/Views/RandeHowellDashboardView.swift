import SwiftUI

struct RandeHowellDashboardView: View {
    @EnvironmentObject var solarManager: SolarSystemManager
    @Environment(\.dismiss) private var dismiss
    @State private var headerAnimated = false
    @State private var emotionalBalance: Double = 7.8
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                // Rande Howell themed gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.orange.opacity(0.9),
                        Color.yellow.opacity(0.6),
                        Color.red.opacity(0.2),
                        Color(.systemGroupedBackground)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        randeHowellHeader
                        mindfulnessMetrics
                        emotionalIntelligence
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
                            
                            Text("Zen Trading")
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
        .task {
            withAnimation(Animation.spring(response: 0.6)) {
                headerAnimated = true
            }
        }
    }

    // MARK: - Subviews
    private var randeHowellHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Zen Trading")
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(headerAnimated ? 1.0 : 0)
                        .offset(x: headerAnimated ? 0 : -50)
                        .animation(.easeOut(duration: 0.8).delay(0.2), value: headerAnimated)
                    
                    Text("with Rande Howell")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange.opacity(0.9))
                        .opacity(headerAnimated ? 1.0 : 0)
                        .offset(x: headerAnimated ? 0 : -30)
                        .animation(.easeOut(duration: 0.8).delay(0.3), value: headerAnimated)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "figure.mind.and.body")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                        .opacity(headerAnimated ? 1.0 : 0)
                        .scaleEffect(headerAnimated ? 1.0 : 0.5)
                        .animation(.easeOut(duration: 0.8).delay(0.4), value: headerAnimated)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Today's Wisdom")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.9))
                
                Text("\"Trade from a state of emotional freedom\"")
                    .font(.subheadline)
                    .italic()
                    .foregroundColor(.orange.opacity(0.9))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                            )
                    )
            }
            .opacity(headerAnimated ? 1.0 : 0)
            .offset(y: headerAnimated ? 0 : 30)
            .animation(.easeOut(duration: 0.8).delay(0.5), value: headerAnimated)
        }
        .padding(.horizontal)
        .padding(.top, 60)
        .padding(.bottom, 20)
    }
    
    private var mindfulnessMetrics: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Mindfulness Metrics")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                RandeZenMetricCard(title: "Emotional Balance", value: "\(String(format: "%.1f", emotionalBalance))/10", color: .orange, icon: "scale.3d")
                RandeZenMetricCard(title: "Mindfulness", value: "89%", color: .yellow, icon: "brain.head.profile")
                RandeZenMetricCard(title: "Inner Peace", value: "High", color: .red, icon: "heart.fill")
                RandeZenMetricCard(title: "Clarity", value: "8.5/10", color: .orange, icon: "eye.fill")
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
    
    private var emotionalIntelligence: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Emotional Intelligence")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                RandeEmotionalProgressRow(title: "Self-Awareness", progress: 0.88, color: .orange)
                RandeEmotionalProgressRow(title: "Self-Regulation", progress: 0.75, color: .yellow)
                RandeEmotionalProgressRow(title: "Motivation", progress: 0.82, color: .red)
                RandeEmotionalProgressRow(title: "Empathy", progress: 0.69, color: .orange)
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
}

// MARK: - Supporting Views
struct RandeZenMetricCard: View {
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
    }
}

struct RandeEmotionalProgressRow: View {
    let title: String
    let progress: Double
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * progress, height: 8)
                }
            }
            .frame(width: 100, height: 8)
            
            Text("\(Int(progress * 100))%")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)
                .frame(width: 40, alignment: .trailing)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview
struct RandeHowellDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        RandeHowellDashboardView()
            .environmentObject(SolarSystemManager())
            .preferredColorScheme(.light)
    }
}
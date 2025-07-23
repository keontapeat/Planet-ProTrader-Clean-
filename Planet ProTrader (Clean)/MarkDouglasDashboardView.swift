import SwiftUI

struct MarkDouglasDashboardView: View {
    @EnvironmentObject var solarManager: SolarSystemManager
    @Environment(\.dismiss) private var dismiss
    @State private var headerAnimated = false
    @State private var disciplineScore: Double = 87.5
    @State private var mindsetQuote = "The hard reality is that every trade has an uncertain outcome."
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                // Mark Douglas themed gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.purple.opacity(0.9),
                        Color.indigo.opacity(0.7),
                        Color.black.opacity(0.1),
                        Color(.systemGroupedBackground)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        markDouglasHeader
                        disciplineMetrics
                        psychologyInsights
                        tradingMindsetSection
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
                            
                            Text("Discipline Planet")
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
    private var markDouglasHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Trading Psychology")
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(headerAnimated ? 1.0 : 0)
                        .offset(x: headerAnimated ? 0 : -50)
                        .animation(.easeOut(duration: 0.8).delay(0.2), value: headerAnimated)
                    
                    Text("with Mark Douglas")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.purple.opacity(0.9))
                        .opacity(headerAnimated ? 1.0 : 0)
                        .offset(x: headerAnimated ? 0 : -30)
                        .animation(.easeOut(duration: 0.8).delay(0.3), value: headerAnimated)
                }
                
                Spacer()
                
                // Brain icon with animation
                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                        .opacity(headerAnimated ? 1.0 : 0)
                        .scaleEffect(headerAnimated ? 1.0 : 0.5)
                        .animation(.easeOut(duration: 0.8).delay(0.4), value: headerAnimated)
                }
            }
            
            // Daily Quote
            VStack(alignment: .leading, spacing: 8) {
                Text("Today's Mindset")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.9))
                
                Text("\"\(mindsetQuote)\"")
                    .font(.subheadline)
                    .italic()
                    .foregroundColor(.purple.opacity(0.9))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                            )
                    )
                
                Text("- Mark Douglas")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .opacity(headerAnimated ? 1.0 : 0)
            .offset(y: headerAnimated ? 0 : 30)
            .animation(.easeOut(duration: 0.8).delay(0.5), value: headerAnimated)
        }
        .padding(.horizontal)
        .padding(.top, 60)
        .padding(.bottom, 20)
    }
    
    private var disciplineMetrics: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Discipline Metrics")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                DisciplineMetricCard(
                    title: "Discipline Score",
                    value: "\(String(format: "%.1f", disciplineScore))%",
                    icon: "target",
                    color: .purple,
                    progress: disciplineScore / 100.0
                )
                
                DisciplineMetricCard(
                    title: "Rule Following",
                    value: "94.2%",
                    icon: "checkmark.shield.fill",
                    color: .green,
                    progress: 0.942
                )
                
                DisciplineMetricCard(
                    title: "Emotional Control",
                    value: "8.7/10",
                    icon: "heart.circle.fill",
                    color: .blue,
                    progress: 0.87
                )
                
                DisciplineMetricCard(
                    title: "Consistency",
                    value: "Good",
                    icon: "arrow.up.right.circle.fill",
                    color: .orange,
                    progress: 0.75
                )
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
    
    private var psychologyInsights: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Psychology Insights")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                PsychologyInsightRow(
                    title: "Fear & Greed Balance",
                    description: "You're maintaining good emotional balance",
                    icon: "scale.3d",
                    color: .green,
                    status: "Balanced"
                )
                
                PsychologyInsightRow(
                    title: "Probability Thinking",
                    description: "Focus on thinking in probabilities, not certainties",
                    icon: "percent",
                    color: .blue,
                    status: "Developing"
                )
                
                PsychologyInsightRow(
                    title: "Market Uncertainty",
                    description: "Accept that each trade outcome is uncertain",
                    icon: "questionmark.circle.fill",
                    color: .purple,
                    status: "Good"
                )
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
    
    private var tradingMindsetSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Trading Mindset Development")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                MindsetProgressCard(
                    title: "Zone Mastery",
                    description: "Learn to trade from a state of objective observation",
                    progress: 0.65,
                    color: .purple
                )
                
                MindsetProgressCard(
                    title: "Belief System Analysis",
                    description: "Identify and transform limiting trading beliefs",
                    progress: 0.45,
                    color: .indigo
                )
                
                MindsetProgressCard(
                    title: "Probability Mindset",
                    description: "Think in terms of edges and probabilities",
                    progress: 0.78,
                    color: .blue
                )
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
struct DisciplineMetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let progress: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                    .monospacedDigit()
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontWeight(.medium)
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.systemGray5))
                            .frame(height: 6)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(color)
                            .frame(width: geometry.size.width * progress, height: 6)
                    }
                }
                .frame(height: 6)
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

struct PsychologyInsightRow: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let status: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(status)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(color.opacity(0.1))
                )
        }
        .padding(.vertical, 8)
    }
}

struct MindsetProgressCard: View {
    let title: String
    let description: String
    let progress: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.7), color],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}

// MARK: - Preview
struct MarkDouglasDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        MarkDouglasDashboardView()
            .environmentObject(SolarSystemManager())
            .preferredColorScheme(.light)
    }
}
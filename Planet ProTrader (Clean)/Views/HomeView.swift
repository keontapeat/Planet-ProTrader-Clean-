import SwiftUI

// MARK: - Home View (Now shows Solar System)
struct HomeView: View {
    @StateObject private var solarManager = SolarSystemManager()
    @State private var showingPlanetDashboard = false
    @State private var rotationAngle: Double = 0
    @State private var planetAnimations: [UUID: Bool] = [:]
    @Namespace private var planetTransition
    
    var body: some View {
        ZStack {
            // Space background
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.9),
                    Color.indigo.opacity(0.3),
                    Color.black
                ]),
                center: .center,
                startRadius: 50,
                endRadius: 400
            )
            .ignoresSafeArea()
            
            // Stars background
            ForEach(0..<50, id: \.self) { _ in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.3...1.0)))
                    .frame(width: CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 2...5))
                            .repeatForever(autoreverses: true),
                        value: rotationAngle
                    )
            }
            
            // FIXED HEADER - COMPLETELY STATIC WITH NO ANIMATIONS
            VStack {
                Text("Choose your trading mentor planet")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.top, 50) // INCREASED from 30 to 50 to move text down and avoid overlap
                Spacer()
            }
            .zIndex(10) // Put it on top so nothing affects it
            .animation(.none) // KILL ALL ANIMATIONS ON THIS
            .id("fixed-header-never-move") // Unique ID to prevent any layout changes
            
            VStack(spacing: 20) { 
                // Spacer to make room for fixed header
                Spacer()
                    .frame(height: 40) // Replace the dynamic header with fixed space
                
                // Solar System
                GeometryReader { geometry in
                    let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    
                    ZStack {
                        // Planet Orbits and Planets - NOW 6 PLANETS WITH BETTER SPACING
                        ForEach(Array(solarManager.planets.enumerated()), id: \.element.id) { index, planet in
                            let radius = CGFloat(60 + (index * 35)) // Better spacing for 6 planets
                            let angle = rotationAngle + Double(index * 60) // 360/6 = 60 degrees apart
                            let planetPosition = CGPoint(
                                x: center.x + radius * cos(angle * .pi / 180),
                                y: center.y + radius * sin(angle * .pi / 180)
                            )
                            
                            // Orbit path
                            Circle()
                                .stroke(planet.color.opacity(0.15), lineWidth: 1)
                                .frame(width: radius * 2, height: radius * 2)
                                .position(center)
                            
                            // Planet
                            PlanetView(
                                planet: planet,
                                isSelected: planet.id == solarManager.selectedPlanet.id,
                                isAnimating: planetAnimations[planet.id] ?? false
                            )
                            .position(planetPosition)
                            .matchedGeometryEffect(id: planet.id, in: planetTransition)
                            .onTapGesture {
                                impactFeedback()
                                if planet.unlocked {
                                    solarManager.selectPlanet(planet)
                                    animatePlanetSelection(planet)
                                } else {
                                    // Show unlock requirements
                                }
                            }
                        }
                    }
                }
                .frame(height: 180)
                .zIndex(1)
                
                // Add some space between planets and info card
                Spacer()
                    .frame(height: 60) // INCREASED from 45 to 60 to push caption DOWN even more
                
                // Selected Planet Info
                selectedPlanetInfo
                    .zIndex(2)
                
                // FIXED SPACER - REDUCED TO BRING BUTTON CLOSER TO CAPTION
                Spacer()
                    .frame(height: 2) // REDUCED from 5 to 2 to bring button much closer to caption
                
                // Enter Planet Button - FIXED POSITION
                enterPlanetButton
                    .padding(.bottom, 100) // Keep bottom padding the same
                    .zIndex(3)
            }
            .padding(.horizontal)
            .padding(.top, 0)
            .padding(.bottom, -15)
        }
        .navigationTitle("")
        .navigationBarHidden(false)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Trading Solar System")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
        }
        .toolbarBackground(.clear, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .preferredColorScheme(.dark)
        .onAppear {
            startOrbitAnimation()
            solarManager.loadSelectedPlanet()
        }
        .fullScreenCover(isPresented: $showingPlanetDashboard) {
            selectedPlanetDashboard
        }
    }
    
    // MARK: - Subviews
    // MARK: - Subviews - REMOVED DYNAMIC HEADER
    // Header is now completely static in the ZStack above
    private var selectedPlanetInfo: some View {
        VStack(spacing: 16) {
            // Planet header with slogan - COMPLETELY STATIC
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(solarManager.selectedPlanet.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6) // Allow heavy scaling to fit
                        .layoutPriority(1) // High priority to prevent clipping
                    Spacer()
                }
                
                HStack {
                    Text("\"\(solarManager.selectedPlanet.philosophy)\"")
                        .font(.callout.bold())
                        .foregroundStyle(planetPhilosophyGradient)
                        .shadow(color: solarManager.selectedPlanet.color.opacity(0.3), radius: 3, x: 0, y: 1)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                        .layoutPriority(1)
                    Spacer()
                }
                
                HStack {
                    Text("by \(solarManager.selectedPlanet.mentorName)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Spacer()
                }
            }
            
            // Planet details - STATIC LAYOUT
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(solarManager.selectedPlanet.description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .layoutPriority(1)
                    Spacer()
                }
                
                // Account Balance & Expertise - FIXED: Hide balance for Black Hole
                VStack(spacing: 8) {
                    // FIXED: Only show account balance if NOT Black Hole
                    if solarManager.selectedPlanet.name != "Black Hole" {
                        accountBalanceRow
                    }
                    tradingExpertiseRow
                }
            }
            
            // Subtitle - STATIC
            HStack {
                Text("Each planet is your personal trading account")
                    .font(.caption)
                    .italic()
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                Spacer()
            }
            .padding(.top, 4)
        }
        .frame(height: 240) // FIXED HEIGHT - NO DYNAMIC SIZING
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(planetInfoBackground)
        .clipped() // FORCE CLIP EVERYTHING
        .id(solarManager.selectedPlanet.id) // PREVENT ANIMATION INTERFERENCE
    }
    
    private var planetPhilosophyGradient: LinearGradient {
        // FIXED: White text for Black Hole philosophy
        if solarManager.selectedPlanet.name == "Black Hole" {
            return LinearGradient(
                colors: [Color.white, Color.white.opacity(0.9), Color.white],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            return LinearGradient(
                colors: [
                    solarManager.selectedPlanet.color,
                    solarManager.selectedPlanet.color.opacity(0.8),
                    solarManager.selectedPlanet.color
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }

    private var accountBalanceRow: some View {
        HStack {
            Text("Account Balance:")
                .font(.subheadline.bold())
                .foregroundColor(.white.opacity(0.8))
                .layoutPriority(1)
            
            Spacer()
            
            // FIXED: Handle Black Hole with no balance display
            if solarManager.selectedPlanet.name == "Black Hole" {
                Text("∞ INFINITE")
                    .font(.title3.bold())
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.purple, Color.white, Color.indigo],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: Color.purple.opacity(0.5), radius: 3, x: 0, y: 1)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            } else {
                Text("$\(String(format: "%.0f", solarManager.selectedPlanet.balance))")
                    .font(.title3.bold())
                    .foregroundColor(solarManager.selectedPlanet.color)
                    .shadow(color: solarManager.selectedPlanet.color.opacity(0.3), radius: 2, x: 0, y: 1)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .frame(height: 40) 
        .padding(.horizontal, 14)
        .background(accountBalanceBackground)
    }

    private var accountBalanceBackground: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(solarManager.selectedPlanet.color.opacity(0.1))  // FIXED: Use planet's natural color
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(solarManager.selectedPlanet.color.opacity(0.3), lineWidth: 1)  // FIXED: Use planet's natural color
            )
            .shadow(
                color: solarManager.selectedPlanet.color.opacity(0.2),  // FIXED: Use planet's natural color
                radius: 4,
                x: 0,
                y: 2
            )
    }

    private var tradingExpertiseRow: some View {
        HStack(alignment: .center) {
            Text("Trading Expertise:")
                .font(.subheadline.bold())
                .foregroundColor(.white.opacity(0.8))
                .layoutPriority(1)
            
            Spacer()
            
            Text(solarManager.selectedPlanet.expertise)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.trailing)
                .lineLimit(1) // FORCE SINGLE LINE
                .minimumScaleFactor(0.6) // Allow heavy scaling
                .layoutPriority(1)
        }
        .frame(height: 40) // FIXED ROW HEIGHT
        .padding(.horizontal, 14)
        .background(tradingExpertiseBackground)
    }

    private var tradingExpertiseBackground: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(.white.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
    }

    private var planetInfoBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(
                // FIXED: Better contrast for Black Hole like ProTrader
                solarManager.selectedPlanet.name == "Black Hole" ?
                Color.black.opacity(0.7) :  // Darker background for better pop
                Color.black.opacity(0.5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        // FIXED: Better border for Black Hole
                        solarManager.selectedPlanet.name == "Black Hole" ?
                        Color.white.opacity(0.6) :  // White border like space theme
                        solarManager.selectedPlanet.color.opacity(0.5),
                        lineWidth: solarManager.selectedPlanet.name == "Black Hole" ? 2 : 1
                    )
            )
            .shadow(
                color: solarManager.selectedPlanet.name == "Black Hole" ?
                Color.white.opacity(0.4) :  // White glow for cosmic effect
                solarManager.selectedPlanet.color.opacity(0.3),
                radius: solarManager.selectedPlanet.name == "Black Hole" ? 12 : 8,
                x: 0,
                y: 4
            )
    }

    private var enterPlanetButton: some View {
        Button(action: {
            impactFeedback()
            withAnimation(.easeInOut(duration: 0.5)) {
                showingPlanetDashboard = true
            }
        }) {
            HStack(spacing: 12) {
                // FIXED: Different icon for Black Hole
                Image(systemName: solarManager.selectedPlanet.name == "Black Hole" ? "books.vertical.fill" : "rocket.fill")
                    .font(.title2)
                
                // FIXED: Different text for Black Hole
                Text(solarManager.selectedPlanet.name == "Black Hole" ? "Access Knowledge Library" : "Enter \(solarManager.selectedPlanet.name)")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundColor(.white)
            .frame(width: 280, height: 50)
            .background(enterButtonBackground)
            .clipShape(Capsule())
            .shadow(
                color: solarManager.selectedPlanet.name == "Black Hole" ?
                Color.white.opacity(0.3) :
                solarManager.selectedPlanet.color.opacity(0.3),
                radius: 10,
                x: 0,
                y: 5
            )
            // FIXED: Add animated glow for Black Hole button only
            .overlay(
                solarManager.selectedPlanet.name == "Black Hole" ?
                AnimatedGlowOverlay() : nil
            )
        }
        .animation(.none)
        .id("enter-button-static")
    }

    private var enterButtonBackground: LinearGradient {
        // FIXED: Better gradient for Black Hole
        if solarManager.selectedPlanet.name == "Black Hole" {
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color.gray.opacity(0.8),
                    Color.white.opacity(0.6)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            return LinearGradient(
                gradient: Gradient(colors: solarManager.selectedPlanet.gradientColors),
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    @ViewBuilder
    private var selectedPlanetDashboard: some View {
        switch solarManager.selectedPlanet.name {
        case "ProTrader":
            ProTraderDashboardView()
                .environmentObject(solarManager)
        case "Golden Core":
            ProTraderDashboardView()
                .environmentObject(solarManager)
        case "Discipline":
            MarkDouglasDashboardView()
                .environmentObject(solarManager)
        case "Mental Game":
            JaredTendlerDashboardView()
                .environmentObject(solarManager)
        case "Zen Trading":
            RandeHowellDashboardView()
                .environmentObject(solarManager)
        default:
            ProTraderDashboardView()
                .environmentObject(solarManager)
        }
    }
    
    // MARK: - Helper Methods
    private func startOrbitAnimation() {
        withAnimation(Animation.linear(duration: 60).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
    }
    
    private func animatePlanetSelection(_ planet: TradingPlanet) {
        planetAnimations[planet.id] = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            planetAnimations[planet.id] = false
        }
    }
    
    private func impactFeedback() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
}

// MARK: - Animated Glow Overlay for Black Hole Button
struct AnimatedGlowOverlay: View {
    @State private var glowOffset: CGFloat = -300
    @State private var currentColors: [Color] = [.purple, .blue, .cyan, .white, .yellow, .orange, .red]
    @State private var colorIndex = 0
    
    var body: some View {
        // Animated color sweep effect
        LinearGradient(
            colors: [
                Color.clear,
                currentColors[colorIndex].opacity(0.8),
                currentColors[(colorIndex + 1) % currentColors.count].opacity(0.6),
                currentColors[(colorIndex + 2) % currentColors.count].opacity(0.4),
                Color.clear
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
        .mask(
            Capsule()
                .stroke(lineWidth: 3)
        )
        .offset(x: glowOffset)
        .onAppear {
            startGlowAnimation()
        }
    }
    
    private func startGlowAnimation() {
        // Continuous sweep animation
        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            glowOffset = 300
        }
        
        // Color cycling animation
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                colorIndex = (colorIndex + 1) % currentColors.count
            }
        }
    }
}

#Preview {
    HomeView()
}
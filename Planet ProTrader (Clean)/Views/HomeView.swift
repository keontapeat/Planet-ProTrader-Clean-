//
//  HomeView.swift
//  Planet ProTrader - Solar System Edition
//
//  Trading Solar System with Mentor Planets
//  Created by AI Assistant on 1/25/25.
//

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
            
            VStack(spacing: 20) {
                // Header
                headerView
                
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
                .frame(height: 200)
                .zIndex(1)
                
                // Selected Planet Info
                selectedPlanetInfo
                    .zIndex(2)
                
                Spacer()
                
                // Enter Planet Button
                enterPlanetButton
                    .zIndex(3)
            }
            .padding(.horizontal)
            .padding(.top, 20)
        }
        .navigationTitle("")
        .navigationBarHidden(false)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Trading Solar System")
                    .font(.headline)
                    .fontWeight(.bold)
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
    private var headerView: some View {
        VStack(spacing: 12) {
            Text("Choose your trading mentor planet")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.top, 20)
    }
    
    private var selectedPlanetInfo: some View {
        VStack(spacing: 16) {
            // Planet header with slogan in the middle
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(solarManager.selectedPlanet.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("\"\(solarManager.selectedPlanet.philosophy)\"")
                        .font(.title3.bold())
                        .foregroundStyle(planetPhilosophyGradient)
                        .shadow(color: solarManager.selectedPlanet.color.opacity(0.3), radius: 4, x: 0, y: 2)
                    
                    Text("by \(solarManager.selectedPlanet.mentorName)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
            }
            
            // Planet details
            VStack(alignment: .leading, spacing: 12) {
                Text(solarManager.selectedPlanet.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.leading)
                
                // Account Balance & Expertise (organized nicely)
                VStack(spacing: 8) {
                    accountBalanceRow
                    tradingExpertiseRow
                }
            }
            
            // Subtitle emphasizing the power
            Text("Each planet is your personal trading account")
                .font(.caption)
                .italic()
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .background(planetInfoBackground)
        .animation(.easeInOut(duration: 0.3), value: solarManager.selectedPlanet.id)
    }
    
    private var planetPhilosophyGradient: LinearGradient {
        LinearGradient(
            colors: [
                solarManager.selectedPlanet.color,
                solarManager.selectedPlanet.color.opacity(0.8),
                solarManager.selectedPlanet.color
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private var accountBalanceRow: some View {
        HStack {
            Text("Account Balance:")
                .font(.subheadline.bold())
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text("$\(String(format: "%.0f", solarManager.selectedPlanet.balance))")
                .font(.title3.bold())
                .foregroundColor(solarManager.selectedPlanet.color)
                .shadow(color: solarManager.selectedPlanet.color.opacity(0.3), radius: 2, x: 0, y: 1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(accountBalanceBackground)
    }

    private var accountBalanceBackground: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(solarManager.selectedPlanet.color.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(solarManager.selectedPlanet.color.opacity(0.3), lineWidth: 1)
            )
    }

    private var tradingExpertiseRow: some View {
        HStack {
            Text("Trading Expertise:")
                .font(.subheadline.bold())
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text(solarManager.selectedPlanet.expertise)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
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
            .fill(Color.black.opacity(0.3))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(solarManager.selectedPlanet.color.opacity(0.5), lineWidth: 1)
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
                Image(systemName: "rocket.fill")
                    .font(.title2)
                
                Text("Enter \(solarManager.selectedPlanet.name)")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(enterButtonBackground)
            .clipShape(Capsule())
            .shadow(color: solarManager.selectedPlanet.color.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .scaleEffect(planetAnimations[solarManager.selectedPlanet.id] ?? false ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: planetAnimations[solarManager.selectedPlanet.id])
    }

    private var enterButtonBackground: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: solarManager.selectedPlanet.gradientColors),
            startPoint: .leading,
            endPoint: .trailing
        )
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

#Preview {
    HomeView()
}
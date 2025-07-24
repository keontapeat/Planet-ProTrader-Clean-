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
                .frame(height: 320) // Increased height for better spacing
                
                // Selected Planet Info
                selectedPlanetInfo
                
                // Enter Planet Button
                enterPlanetButton
            }
            .padding(.horizontal)
            .padding(.top, 20)
            .padding(.bottom, 100) 
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
            Text("Trading Solar System")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("Choose your trading mentor planet")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.top, 20)
    }
    
    private var selectedPlanetInfo: some View {
        VStack(spacing: 16) {
            // Planet header
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(solarManager.selectedPlanet.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("by \(solarManager.selectedPlanet.mentorName)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
            }
            
            // Planet details
            VStack(alignment: .leading, spacing: 8) {
                Text(solarManager.selectedPlanet.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Text("Balance:")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("$\(String(format: "%.0f", solarManager.selectedPlanet.balance))")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(solarManager.selectedPlanet.color)
                    
                    Spacer()
                    
                    Text(solarManager.selectedPlanet.expertise)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            // Philosophy
            Text("\"\(solarManager.selectedPlanet.philosophy)\"")
                .font(.caption)
                .italic()
                .foregroundColor(solarManager.selectedPlanet.color)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(solarManager.selectedPlanet.color.opacity(0.5), lineWidth: 1)
                )
        )
        .animation(.easeInOut(duration: 0.3), value: solarManager.selectedPlanet.id)
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
            .background(
                LinearGradient(
                    gradient: Gradient(colors: solarManager.selectedPlanet.gradientColors),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(Capsule())
            .shadow(color: solarManager.selectedPlanet.color.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .scaleEffect(planetAnimations[solarManager.selectedPlanet.id] ?? false ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: planetAnimations[solarManager.selectedPlanet.id])
    }
    
    private var centralSun: some View {
        ZStack {
            // Sun glow (reduced intensity)
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.yellow.opacity(0.4),
                            Color.orange.opacity(0.2),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 5,
                        endRadius: 30
                    )
                )
                .frame(width: 60, height: 60)
                .scaleEffect(1.0 + sin(rotationAngle * .pi / 180) * 0.05)
            
            // Sun core - CLEAN NO UGLY CHART SYMBOL
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.yellow, Color.orange]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 40, height: 40)
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

#Preview {
    HomeView()
}
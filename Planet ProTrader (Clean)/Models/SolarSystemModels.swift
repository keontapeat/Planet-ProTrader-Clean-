// 
//  SolarSystemModels.swift
//  Planet ProTrader - Solar System Edition
//
//  Shared models and managers for the trading solar system
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

// MARK: - Trading Planet Model
struct TradingPlanet: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let mentorName: String
    let description: String
    let balance: Double
    let color: Color
    let gradientColors: [Color]
    let icon: String
    let expertise: String
    let unlocked: Bool
    let philosophy: String
    
    static func samplePlanets() -> [TradingPlanet] {
        return [
            TradingPlanet(
                name: "ProTrader",
                mentorName: "Keonta Peat",
                description: "The foundation planet for professional trading mastery - A blue world of endless possibilities",
                balance: 5000.0,
                color: .blue,
                gradientColors: [.blue, .cyan, .indigo],
                icon: "",
                expertise: "Technical Analysis & Risk Management",
                unlocked: true,
                philosophy: "Where Poverty Doesn't Exist"
            ),
            TradingPlanet(
                name: "Golden Core",
                mentorName: "Trading Hub",
                description: "The central trading command center - A golden planet of financial mastery",
                balance: 10000.0,
                color: .yellow,
                gradientColors: [.yellow, .orange, .red],
                icon: "",
                expertise: "Core Trading Systems",
                unlocked: true,
                philosophy: "Where Wealth Is Infinite"
            ),
            TradingPlanet(
                name: "Solar Command",
                mentorName: "Central Hub",
                description: "The bright center of trading operations - A radiant sun-like world",
                balance: 15000.0,
                color: .orange,
                gradientColors: [.yellow, .orange, .red],
                icon: "",
                expertise: "Central Trading Operations",
                unlocked: true,
                philosophy: "Where Success Burns Bright"
            ),
            TradingPlanet(
                name: "Discipline",
                mentorName: "Mark Douglas",
                description: "Master the psychological aspects of trading - A mystical purple realm of the mind",
                balance: 3500.0,
                color: .purple,
                gradientColors: [.purple, .pink, .indigo],
                icon: "brain.head.profile",
                expertise: "Trading Psychology & Mindset",
                unlocked: true,
                philosophy: "Where Mindset Conquers Markets"
            ),
            TradingPlanet(
                name: "Mental Game",
                mentorName: "Jared Tendler",
                description: "Optimize your mental performance - A lush green world of growth and potential",
                balance: 4200.0,
                color: .green,
                gradientColors: [.green, .mint, .teal],
                icon: "leaf.fill",
                expertise: "Mental Game Coaching",
                unlocked: true,
                philosophy: "Where Champions Are Made"
            ),
            TradingPlanet(
                name: "Zen Trading",
                mentorName: "Rande Howell",
                description: "Find inner peace and emotional balance - A serene desert world with majestic rings",
                balance: 3800.0,
                color: .orange,
                gradientColors: [.orange, .yellow, .red],
                icon: "figure.mind.and.body",
                expertise: "Emotional Intelligence & Mindfulness",
                unlocked: true,
                philosophy: "Where Peace Meets Profit"
            )
        ]
    }
}

// MARK: - Solar System Manager
class SolarSystemManager: ObservableObject {
    @Published var planets: [TradingPlanet] = TradingPlanet.samplePlanets()
    @Published var selectedPlanet: TradingPlanet = TradingPlanet.samplePlanets().first(where: { $0.name == "ProTrader" }) ?? TradingPlanet.samplePlanets()[0]
    @Published var showingPlanetDetail = false
    @Published var animateOrbits = false
    
    func selectPlanet(_ planet: TradingPlanet) {
        guard planet.unlocked else { return }
        
        withAnimation(.easeInOut(duration: 0.8)) {
            selectedPlanet = planet
        }
        
        // Save selection to UserDefaults
        UserDefaults.standard.set(planet.name, forKey: "selectedPlanetName")
    }
    
    func loadSelectedPlanet() {
        if let savedPlanetName = UserDefaults.standard.string(forKey: "selectedPlanetName"),
           let planet = planets.first(where: { $0.name == savedPlanetName }) {
            selectedPlanet = planet
        } else {
            // Default to ProTrader if nothing saved
            selectedPlanet = planets.first(where: { $0.name == "ProTrader" }) ?? planets[0]
        }
    }
}

// MARK: - Planet View
struct PlanetView: View {
    let planet: TradingPlanet
    let isSelected: Bool
    let isAnimating: Bool
    @StateObject private var textureManager = PlanetTextureManager()
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        ZStack {
            // Planetary aura (removed excessive glow for ProTrader)
            if isSelected && planet.name != "ProTrader" {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.clear,
                                planet.color.opacity(0.2),
                                planet.color.opacity(0.4),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 30,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .blur(radius: 6)
                    .opacity(0.5)
            }
            
            // ProTrader gets a subtle, professional glow
            if isSelected && planet.name == "ProTrader" {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.clear,
                                planet.color.opacity(0.1),
                                planet.color.opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 25,
                            endRadius: 45
                        )
                    )
                    .frame(width: 90, height: 90)
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                    .blur(radius: 3)
                    .opacity(0.6)
            }
            
            // Planet shadow (3D effect)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.black.opacity(0.9),
                            Color.black.opacity(0.5),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: 30
                    )
                )
                .frame(width: isSelected ? 58 : 48, height: isSelected ? 58 : 48)
                .offset(x: 5, y: 5)
                .blur(radius: 4)
            
            // Main realistic planet body
            ZStack {
                // Base planet with ultra-realistic gradients
                Circle()
                    .fill(createPhotoRealisticGradient(for: planet))
                    .frame(width: isSelected ? 55 : 45, height: isSelected ? 55 : 45)
                
                // NASA texture overlay (if available)
                if let texture = textureManager.getTexture(for: planet.name) {
                    Image(uiImage: texture)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: isSelected ? 55 : 45, height: isSelected ? 55 : 45)
                        .clipShape(Circle())
                        .opacity(0.85)
                        .rotationEffect(.degrees(rotationAngle * 0.05)) // Very slow rotation
                        .blendMode(.multiply)
                }
                
                // Surface terrain details
                createRealisticTerrain(for: planet, isSelected: isSelected)
                
                // Atmospheric layer
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.clear,
                                Color.clear,
                                getAtmosphereColor(for: planet).opacity(0.2),
                                getAtmosphereColor(for: planet).opacity(0.5)
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 28
                        )
                    )
                    .frame(width: isSelected ? 55 : 45, height: isSelected ? 55 : 45)
                    .blendMode(.screen)
                
                // Realistic sun reflection (3D lighting)
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.8),
                                Color.white.opacity(0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 2,
                            endRadius: 15
                        )
                    )
                    .frame(
                        width: isSelected ? 30 : 25,
                        height: isSelected ? 22 : 18
                    )
                    .offset(
                        x: isSelected ? -18 : -15,
                        y: isSelected ? -18 : -15
                    )
                    .blur(radius: 3)
                    .opacity(0.7)
                
                // Day/night terminator (shadow side)
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.clear,
                                Color.black.opacity(0.6),
                                Color.black.opacity(0.8)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: isSelected ? 55 : 45, height: isSelected ? 55 : 45)
                    .offset(x: isSelected ? 15 : 12)
                    .blendMode(.multiply)
                
                // Weather systems (clouds, storms)
                createWeatherSystems(for: planet, isSelected: isSelected)
            }
            .scaleEffect(isAnimating ? 1.3 : 1.0)
            .rotation3DEffect(
                .degrees(isSelected ? 8 : 0),
                axis: (x: 0.5, y: 1, z: 0)
            )
            
            // Planetary rings (for certain planets)
            if shouldHaveRings(planet) {
                createRealisticRings(isSelected: isSelected)
            }
        }
        .onAppear {
            startPlanetRotation()
        }
        .animation(.spring(response: 0.8, dampingFraction: 0.7), value: isSelected)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isAnimating)
    }
    
    // MARK: - Photo-Realistic Planet Functions
    
    private func createPhotoRealisticGradient(for planet: TradingPlanet) -> RadialGradient {
        switch planet.name {
        case "ProTrader":
            // Earth - Deep blue oceans with realistic depth
            return RadialGradient(
                colors: [
                    Color(red: 0.4, green: 0.7, blue: 0.95), // Shallow tropical water
                    Color(red: 0.15, green: 0.5, blue: 0.85), // Ocean blue
                    Color(red: 0.05, green: 0.3, blue: 0.7),  // Deep ocean
                    Color(red: 0.02, green: 0.15, blue: 0.4)  // Ocean abyss
                ],
                center: UnitPoint(x: 0.35, y: 0.35),
                startRadius: 3,
                endRadius: 35
            )
            
        case "Golden Core":
            // Sun/Venus hybrid - Golden metallic surface
            return RadialGradient(
                colors: [
                    Color(red: 1.0, green: 0.9, blue: 0.3),  // Bright gold
                    Color(red: 0.9, green: 0.7, blue: 0.2),  // Deep gold
                    Color(red: 0.8, green: 0.5, blue: 0.1),  // Bronze
                    Color(red: 0.6, green: 0.3, blue: 0.05)  // Dark bronze
                ],
                center: UnitPoint(x: 0.3, y: 0.3),
                startRadius: 4,
                endRadius: 28
            )
            
        case "Discipline":
            // Jupiter - Gas giant with realistic storm bands
            return RadialGradient(
                colors: [
                    Color(red: 0.85, green: 0.65, blue: 0.95), // Light ammonia clouds
                    Color(red: 0.65, green: 0.35, blue: 0.85), // Mid-level bands
                    Color(red: 0.45, green: 0.15, blue: 0.75), // Storm zones
                    Color(red: 0.25, green: 0.05, blue: 0.55)  // Deep atmosphere
                ],
                center: UnitPoint(x: 0.3, y: 0.4),
                startRadius: 5,
                endRadius: 32
            )
            
        case "Mental Game":
            // Venus - Thick sulfuric atmosphere
            return RadialGradient(
                colors: [
                    Color(red: 0.9, green: 0.95, blue: 0.7),  // Upper atmosphere
                    Color(red: 0.7, green: 0.85, blue: 0.5),  // Mid atmosphere
                    Color(red: 0.5, green: 0.65, blue: 0.3),  // Lower clouds
                    Color(red: 0.3, green: 0.45, blue: 0.2)   // Surface heat
                ],
                center: UnitPoint(x: 0.4, y: 0.3),
                startRadius: 6,
                endRadius: 30
            )
            
        case "Zen Trading":
            // Mars - Red planet with polar caps and dust storms
            return RadialGradient(
                colors: [
                    Color(red: 0.95, green: 0.85, blue: 0.65), // Polar ice caps
                    Color(red: 0.85, green: 0.55, blue: 0.35), // Desert plains
                    Color(red: 0.75, green: 0.35, blue: 0.15), // Iron oxide surface
                    Color(red: 0.55, green: 0.25, blue: 0.05)  // Deep canyon shadows
                ],
                center: UnitPoint(x: 0.25, y: 0.45),
                startRadius: 8,
                endRadius: 33
            )
            
        case "Solar Command":
            // Sun - Bright yellow surface
            return RadialGradient(
                colors: [
                    Color(red: 1.0, green: 1.0, blue: 0.2),  // Bright yellow
                    Color(red: 0.8, green: 0.7, blue: 0.1),  // Mid yellow
                    Color(red: 0.6, green: 0.4, blue: 0.05),  // Dark yellow
                    Color(red: 0.4, green: 0.2, blue: 0.02)   // Deep yellow
                ],
                center: UnitPoint(x: 0.3, y: 0.3),
                startRadius: 4,
                endRadius: 28
            )
            
        default:
            return RadialGradient(
                colors: planet.gradientColors,
                center: .center,
                startRadius: 5,
                endRadius: 25
            )
        }
    }
    
    private func createRealisticTerrain(for planet: TradingPlanet, isSelected: Bool) -> some View {
        ZStack {
            switch planet.name {
            case "ProTrader":
                // Earth continents and islands
                ForEach(0..<6, id: \.self) { i in
                    createLandmass(
                        size: CGSize(width: Double.random(in: 8...18), height: Double.random(in: 6...12)),
                        position: CGPoint(x: Double.random(in: -20...20), y: Double.random(in: -20...20)),
                        color: i % 2 == 0 ? Color(red: 0.2, green: 0.6, blue: 0.1) : Color(red: 0.4, green: 0.3, blue: 0.1),
                        isSelected: isSelected
                    )
                }
                
            case "Golden Core":
                // Golden planet with metallic formations
                ForEach(0..<5, id: \.self) { i in
                    createMetallicFormation(
                        size: CGSize(width: Double.random(in: 10...16), height: Double.random(in: 8...14)),
                        position: CGPoint(x: Double.random(in: -18...18), y: Double.random(in: -18...18)),
                        color: Color(red: 0.9, green: 0.8, blue: 0.3).opacity(0.7),
                        isSelected: isSelected
                    )
                }
                
            case "Mental Game":
                // Venus cloud formations
                ForEach(0..<4, id: \.self) { i in
                    createCloudFormation(
                        size: CGSize(width: Double.random(in: 12...20), height: Double.random(in: 4...8)),
                        position: CGPoint(x: Double.random(in: -15...15), y: Double.random(in: -15...15)),
                        color: Color(red: 0.8, green: 0.9, blue: 0.6).opacity(0.5),
                        isSelected: isSelected
                    )
                }
                
            case "Zen Trading":
                // Mars craters and canyons
                ForEach(0..<8, id: \.self) { i in
                    createCrater(
                        size: CGFloat.random(in: 3...8),
                        position: CGPoint(x: Double.random(in: -18...18), y: Double.random(in: -18...18)),
                        isSelected: isSelected
                    )
                }
                
            case "Solar Command":
                // Sun with solar flares
                ForEach(0..<4, id: \.self) { i in
                    createSolarFlare(
                        size: CGSize(width: Double.random(in: 8...12), height: Double.random(in: 8...12)),
                        position: CGPoint(x: Double.random(in: -18...18), y: Double.random(in: -18...18)),
                        color: Color(red: 1.0, green: 0.8, blue: 0.2).opacity(0.7),
                        isSelected: isSelected
                    )
                }
                
            default:
                EmptyView()
            }
        }
        .frame(width: isSelected ? 55 : 45, height: isSelected ? 55 : 45)
        .clipShape(Circle())
    }
    
    private func createWeatherSystems(for planet: TradingPlanet, isSelected: Bool) -> some View {
        ZStack {
            if planet.name == "ProTrader" {
                // Earth cloud systems
                ForEach(0..<4, id: \.self) { i in
                    Ellipse()
                        .fill(Color.white.opacity(0.6))
                        .frame(
                            width: CGFloat.random(in: 10...18),
                            height: CGFloat.random(in: 4...8)
                        )
                        .offset(
                            x: CGFloat.random(in: -18...18),
                            y: CGFloat.random(in: -18...18)
                        )
                        .blur(radius: 2)
                        .rotationEffect(.degrees(rotationAngle * 0.3))
                }
            }
        }
        .frame(width: isSelected ? 55 : 45, height: isSelected ? 55 : 45)
        .clipShape(Circle())
        .opacity(0.7)
    }
    
    private func createRealisticRings(isSelected: Bool) -> some View {
        ZStack {
            // Saturn-style ring system
            ForEach(0..<6, id: \.self) { ring in
                Ellipse()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                getRingColor(for: ring).opacity(0.8),
                                getRingColor(for: ring).opacity(0.6),
                                getRingColor(for: ring).opacity(0.4),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: CGFloat(4.0 - Double(ring) * 0.5)
                    )
                    .frame(
                        width: CGFloat(80 + ring * 12),
                        height: CGFloat(18 + ring * 3)
                    )
                    .rotationEffect(.degrees(12.0 + Double(ring * 3)))
                    .opacity(0.9 - Double(ring) * 0.1)
                    .blur(radius: Double(ring) * 0.4)
                    .rotationEffect(.degrees(rotationAngle * (0.3 + Double(ring) * 0.05)))
            }
            
            // Ring particles and debris
            ForEach(0..<25, id: \.self) { particle in
                Circle()
                    .fill(Color.orange.opacity(0.7))
                    .frame(width: CGFloat.random(in: 0.5...1.5), height: CGFloat.random(in: 0.5...1.5))
                    .offset(
                        x: cos(Double(particle) * 14.4 * .pi / 180 + rotationAngle * .pi / 180) * Double.random(in: 40...65),
                        y: sin(Double(particle) * 14.4 * .pi / 180 + rotationAngle * .pi / 180) * Double.random(in: 9...15)
                    )
                    .blur(radius: 0.5)
            }
        }
    }
    
    // MARK: - Helper Functions for Terrain
    
    private func createLandmass(size: CGSize, position: CGPoint, color: Color, isSelected: Bool) -> some View {
        Ellipse()
            .fill(color.opacity(0.8))
            .frame(width: size.width, height: size.height)
            .offset(x: position.x, y: position.y)
            .blur(radius: 1)
    }
    
    private func createMetallicFormation(size: CGSize, position: CGPoint, color: Color, isSelected: Bool) -> some View {
        Rectangle()
            .fill(color)
            .frame(width: size.width, height: size.height)
            .offset(x: position.x, y: position.y)
            .blur(radius: 1)
            .rotationEffect(.degrees(Double.random(in: 0...360)))
    }
    
    private func createMetallicTerrain(size: CGSize, position: CGPoint, color: Color, isSelected: Bool) -> some View {
        Rectangle()
            .fill(color.opacity(0.9))
            .frame(width: size.width, height: size.height)
            .offset(x: position.x, y: position.y)
            .blur(radius: 0.8)
    }
    
    private func createStormSystem(size: CGSize, position: CGPoint, color: Color, isSelected: Bool) -> some View {
        Ellipse()
            .fill(color.opacity(0.7))
            .frame(width: size.width, height: size.height)
            .offset(x: position.x, y: position.y)
            .blur(radius: 1.5)
            .rotationEffect(.degrees(rotationAngle * 0.2))
    }
    
    private func createStormBand(yPosition: Double, color: Color, isSelected: Bool) -> some View {
        Rectangle()
            .fill(color)
            .frame(width: isSelected ? 55 : 45, height: 3)
            .offset(y: yPosition)
            .blur(radius: 1)
            .clipShape(Circle())
    }
    
    private func createCloudFormation(size: CGSize, position: CGPoint, color: Color, isSelected: Bool) -> some View {
        Ellipse()
            .fill(color)
            .frame(width: size.width, height: size.height)
            .offset(x: position.x, y: position.y)
            .blur(radius: 2)
            .rotationEffect(.degrees(rotationAngle * 0.1))
    }
    
    private func createCrater(size: CGFloat, position: CGPoint, isSelected: Bool) -> some View {
        Circle()
            .fill(Color.black.opacity(0.6))
            .frame(width: size, height: size)
            .offset(x: position.x, y: position.y)
            .blur(radius: 0.5)
    }
    
    private func createSolarFlare(size: CGSize, position: CGPoint, color: Color, isSelected: Bool) -> some View {
        Ellipse()
            .fill(color)
            .frame(width: size.width, height: size.height)
            .offset(x: position.x, y: position.y)
            .blur(radius: 2)
            .rotationEffect(.degrees(rotationAngle * 0.1))
    }
    
    private func getRingColor(for ring: Int) -> Color {
        let colors: [Color] = [
            Color(red: 0.9, green: 0.7, blue: 0.4),  // Golden
            Color(red: 0.8, green: 0.5, blue: 0.3),  // Orange-brown
            Color(red: 0.7, green: 0.4, blue: 0.2),  // Rust
            Color(red: 0.6, green: 0.3, blue: 0.1),  // Dark brown
            Color(red: 0.5, green: 0.3, blue: 0.2),  // Deep brown
            Color(red: 0.4, green: 0.2, blue: 0.1)   // Almost black
        ]
        return colors[ring % colors.count]
    }
    
    private func shouldHaveRings(_ planet: TradingPlanet) -> Bool {
        return planet.name == "Zen Trading" || planet.name == "Solar Command"
    }
    
    private func getAtmosphereColor(for planet: TradingPlanet) -> Color {
        switch planet.name {
        case "ProTrader": return Color.cyan
        case "Golden Core": return Color.yellow
        case "Discipline": return Color.purple
        case "Mental Game": return Color.green
        case "Zen Trading": return Color.orange
        case "Solar Command": return Color.yellow
        default: return planet.color
        }
    }
    
    private func startPlanetRotation() {
        withAnimation(.linear(duration: 180).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
    }
}
import SwiftUI

// MARK: - Animated Glow Overlay for Black Hole Button
struct AnimatedGlowOverlay: View {
    @State private var glowOffset: CGFloat = -300
    @State private var currentColors: [Color] = [.purple, .blue, .cyan, .white, .yellow, .orange, .red]
    @State private var colorIndex = 0
    @State private var liquidOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            glowRectangle
            overlayRectangle
            particleEffects
            capsuleStroke
        }
        .onAppear {
            startLiquidGlowAnimation()
        }
    }
    
    private var glowRectangle: some View {
        Rectangle()
            .fill(primaryGradient)
            .frame(width: 120, height: 50)
            .offset(x: liquidOffset)
            .blur(radius: 2)
            .clipShape(Capsule())
            .blendMode(.screen)
    }
    
    private var overlayRectangle: some View {
        Rectangle()
            .fill(secondaryGradient)
            .frame(width: 100, height: 50)
            .offset(x: liquidOffset - 20)
            .blur(radius: 3)
            .clipShape(Capsule())
            .blendMode(.overlay)
    }
    
    private var particleEffects: some View {
        ForEach(0..<12, id: \.self) { particle in
            Circle()
                .fill(particleColor)
                .frame(width: particleSize, height: particleSize)
                .offset(x: liquidOffset + particleOffsetX, y: particleOffsetY)
                .blur(radius: 0.8)
                .opacity(abs(liquidOffset) < 200 ? 1.0 : 0.0)
        }
    }
    
    private var capsuleStroke: some View {
        Capsule()
            .stroke(strokeGradient, lineWidth: 2)
            .frame(width: 280, height: 50)
            .blur(radius: 1)
    }
    
    private var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.clear,
                Color.clear,
                currentColors[colorIndex].opacity(0.8),
                currentColors[(colorIndex + 1) % currentColors.count].opacity(0.9),
                currentColors[(colorIndex + 2) % currentColors.count].opacity(0.8),
                Color.clear,
                Color.clear
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var secondaryGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.clear,
                currentColors[(colorIndex + 3) % currentColors.count].opacity(0.6),
                currentColors[(colorIndex + 4) % currentColors.count].opacity(0.7),
                currentColors[(colorIndex + 5) % currentColors.count].opacity(0.6),
                Color.clear
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var strokeGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.clear,
                currentColors[colorIndex].opacity(0.5),
                currentColors[(colorIndex + 1) % currentColors.count].opacity(0.7),
                currentColors[colorIndex].opacity(0.5),
                Color.clear
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var particleColor: Color {
        [Color.white, Color.cyan, Color.purple, Color.yellow].randomElement()!
            .opacity(Double.random(in: 0.6...1.0))
    }
    
    private var particleSize: CGFloat {
        CGFloat.random(in: 1...3)
    }
    
    private var particleOffsetX: CGFloat {
        CGFloat.random(in: -60...60)
    }
    
    private var particleOffsetY: CGFloat {
        CGFloat.random(in: -15...15)
    }
    
    private func startLiquidGlowAnimation() {
        Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 2.0)) {
                liquidOffset = 350
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                liquidOffset = -350
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.4)) {
                colorIndex = (colorIndex + 1) % currentColors.count
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 2.0)) {
                liquidOffset = 350
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                liquidOffset = -350
            }
        }
    }
}

// MARK: - Meteor Data Models
struct RealisticMeteor: Identifiable {
    let id: UUID
    let startPosition: CGPoint
    var currentPosition: CGPoint
    let endPosition: CGPoint
    let size: CGFloat
    let speed: Double
    let rotationSpeed: Double
    let fireIntensity: Double
    let temperature: Double
    var atmosphericEntry: Bool
    let creationTime: Date
    let trailLength: Int
    let fragmentationChance: Double
}

struct FireParticle: Identifiable {
    let id: UUID
    let startPosition: CGPoint
    var currentPosition: CGPoint
    let velocity: CGVector
    let size: CGFloat
    var currentSize: CGFloat
    let color: Color
    let lifetime: Double
    var currentOpacity: Double
    let baseOpacity: Double
    let temperature: Double
    let creationTime: Date
}

struct Shockwave: Identifiable {
    let id: UUID
    let position: CGPoint
    let maxRadius: CGFloat
    var currentRadius: CGFloat
    var currentOpacity: Double
    let lifetime: Double
    let creationTime: Date
}

struct Spark: Identifiable {
    let id: UUID
    let startPosition: CGPoint
    var currentPosition: CGPoint
    let velocity: CGVector
    let color: Color
    let size: CGFloat
    let lifetime: Double
    var currentOpacity: Double
    let creationTime: Date
}

// MARK: - Particle Views
struct FireParticleView: View {
    let particle: FireParticle
    
    var body: some View {
        ZStack {
            Circle()
                .fill(primaryGradient)
                .frame(width: particle.currentSize, height: particle.currentSize)
            
            Circle()
                .fill(particle.color.opacity(particle.currentOpacity * 0.3))
                .frame(width: particle.currentSize * 2, height: particle.currentSize * 2)
                .blur(radius: 3)
        }
        .position(particle.currentPosition)
        .blendMode(.screen)
    }
    
    private var primaryGradient: RadialGradient {
        RadialGradient(
            colors: [
                particle.color.opacity(particle.currentOpacity),
                particle.color.opacity(particle.currentOpacity * 0.7),
                particle.color.opacity(particle.currentOpacity * 0.3),
                Color.clear
            ],
            center: .center,
            startRadius: 0,
            endRadius: particle.currentSize * 1.5
        )
    }
}

struct ShockwaveView: View {
    let shockwave: Shockwave
    
    var body: some View {
        Circle()
            .stroke(shockwaveGradient, lineWidth: 2)
            .frame(width: shockwave.currentRadius * 2, height: shockwave.currentRadius * 2)
            .position(shockwave.position)
            .blur(radius: 1)
            .blendMode(.screen)
    }
    
    private var shockwaveGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.yellow.opacity(shockwave.currentOpacity),
                Color.orange.opacity(shockwave.currentOpacity * 0.8),
                Color.red.opacity(shockwave.currentOpacity * 0.6),
                Color.clear
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

struct SparkView: View {
    let spark: Spark
    
    var body: some View {
        Rectangle()
            .fill(spark.color.opacity(spark.currentOpacity))
            .frame(width: spark.size, height: spark.size * 0.3)
            .blur(radius: 0.5)
            .position(spark.currentPosition)
            .blendMode(.screen)
    }
}

// MARK: - Meteor System Components
struct MeteorSystemLayers: View {
    let meteors: [RealisticMeteor]
    let fireParticles: [FireParticle]
    let shockwaves: [Shockwave]
    let sparks: [Spark]
    
    var body: some View {
        ZStack {
            shockwaveLayer
            fireParticleLayer
            sparkLayer
            meteorMainLayer
        }
    }
    
    private var shockwaveLayer: some View {
        ForEach(shockwaves) { shockwave in
            ShockwaveView(shockwave: shockwave)
        }
    }
    
    private var fireParticleLayer: some View {
        ForEach(fireParticles) { particle in
            FireParticleView(particle: particle)
        }
    }
    
    private var sparkLayer: some View {
        ForEach(sparks) { spark in
            SparkView(spark: spark)
        }
    }
    
    private var meteorMainLayer: some View {
        ForEach(meteors) { meteor in
            RealisticMeteorView(meteor: meteor)
        }
    }
}

// MARK: - Simplified Meteor System
struct RealisticMeteorSystem: View {
    @State private var meteors: [RealisticMeteor] = []
    @State private var fireParticles: [FireParticle] = []
    @State private var shockwaves: [Shockwave] = []
    @State private var sparks: [Spark] = []
    
    var body: some View {
        MeteorSystemLayers(
            meteors: meteors,
            fireParticles: fireParticles,
            shockwaves: shockwaves,
            sparks: sparks
        )
        .onAppear {
            startMeteorShower()
        }
    }
    
    private func startMeteorShower() {
        scheduleNextMeteor()
        
        Timer.scheduledTimer(withTimeInterval: 0.008, repeats: true) { _ in
            updateMeteorsAndParticles()
        }
    }
    
    private func scheduleNextMeteor() {
        let randomDelay = Double.random(in: 8.0...25.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + randomDelay) {
            createNewMeteor()
            scheduleNextMeteor()
        }
    }
    
    private func createNewMeteor() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let startPoint = CGPoint(
            x: Double.random(in: -50...screenWidth + 50),
            y: -Double.random(in: 50...150)
        )
        
        let endPoint = CGPoint(
            x: startPoint.x + Double.random(in: -200...200),
            y: screenHeight + Double.random(in: 50...150)
        )
        
        let meteorSize = CGFloat.random(in: 2...8)
        let meteorSpeed = Double.random(in: 3...12)
        
        let meteor = RealisticMeteor(
            id: UUID(),
            startPosition: startPoint,
            currentPosition: startPoint,
            endPosition: endPoint,
            size: meteorSize,
            speed: meteorSpeed,
            rotationSpeed: Double.random(in: 2...8),
            fireIntensity: Double.random(in: 0.6...1.0),
            temperature: 2000,
            atmosphericEntry: false,
            creationTime: Date(),
            trailLength: Int(meteorSize * 2),
            fragmentationChance: 0.02
        )
        
        meteors.append(meteor)
    }
    
    private func updateMeteorsAndParticles() {
        let currentTime = Date()
        
        // Update meteors
        for i in meteors.indices.reversed() {
            let meteor = meteors[i]
            let elapsed = currentTime.timeIntervalSince(meteor.creationTime)
            let progress = elapsed * meteor.speed / 10.0
            
            if progress >= 1.0 {
                meteors.remove(at: i)
                continue
            }
            
            let newX = meteor.startPosition.x + (meteor.endPosition.x - meteor.startPosition.x) * progress
            let newY = meteor.startPosition.y + (meteor.endPosition.y - meteor.startPosition.y) * progress
            meteors[i].currentPosition = CGPoint(x: newX, y: newY)
            
            // Create fire particles
            if Int.random(in: 0...3) == 0 {
                createFireParticle(for: meteor)
            }
        }
        
        // Update fire particles
        for i in fireParticles.indices.reversed() {
            let elapsed = currentTime.timeIntervalSince(fireParticles[i].creationTime)
            if elapsed > fireParticles[i].lifetime {
                fireParticles.remove(at: i)
                continue
            }
            
            let progress = elapsed / fireParticles[i].lifetime
            fireParticles[i].currentOpacity = (1.0 - progress) * fireParticles[i].baseOpacity
        }
        
        // Update shockwaves
        for i in shockwaves.indices.reversed() {
            let elapsed = currentTime.timeIntervalSince(shockwaves[i].creationTime)
            if elapsed > shockwaves[i].lifetime {
                shockwaves.remove(at: i)
                continue
            }
            
            let progress = elapsed / shockwaves[i].lifetime
            shockwaves[i].currentRadius = shockwaves[i].maxRadius * progress
            shockwaves[i].currentOpacity = (1.0 - progress) * 0.6
        }
        
        // Update sparks
        for i in sparks.indices.reversed() {
            let elapsed = currentTime.timeIntervalSince(sparks[i].creationTime)
            if elapsed > sparks[i].lifetime {
                sparks.remove(at: i)
                continue
            }
            
            let progress = elapsed / sparks[i].lifetime
            sparks[i].currentOpacity = (1.0 - progress)
        }
    }
    
    private func createFireParticle(for meteor: RealisticMeteor) {
        let particle = FireParticle(
            id: UUID(),
            startPosition: meteor.currentPosition,
            currentPosition: meteor.currentPosition,
            velocity: CGVector(dx: Double.random(in: -3...3), dy: Double.random(in: -2...4)),
            size: CGFloat.random(in: 2...5),
            currentSize: CGFloat.random(in: 2...5),
            color: [Color.red, Color.orange, Color.yellow].randomElement()!,
            lifetime: Double.random(in: 0.4...1.0),
            currentOpacity: 1.0,
            baseOpacity: Double.random(in: 0.7...1.0),
            temperature: 2000,
            creationTime: Date()
        )
        fireParticles.append(particle)
    }
}

// MARK: - Simplified Meteor View
struct RealisticMeteorView: View {
    let meteor: RealisticMeteor
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            atmosphericGlow
            meteorBody
        }
        .position(meteor.currentPosition)
        .onAppear {
            startRotation()
        }
    }
    
    private var atmosphericGlow: some View {
        Circle()
            .fill(glowGradient)
            .frame(width: meteor.size * 4, height: meteor.size * 4)
            .blur(radius: 6)
    }
    
    private var meteorBody: some View {
        Circle()
            .fill(meteorGradient)
            .frame(width: meteor.size, height: meteor.size)
            .rotationEffect(.degrees(rotation))
            .shadow(color: Color.red.opacity(0.8), radius: 8, x: 2, y: 2)
    }
    
    private var glowGradient: RadialGradient {
        RadialGradient(
            colors: [
                Color.yellow.opacity(0.9),
                Color.orange.opacity(0.7),
                Color.red.opacity(0.5),
                Color.clear
            ],
            center: .center,
            startRadius: 0,
            endRadius: meteor.size * 3
        )
    }
    
    private var meteorGradient: RadialGradient {
        RadialGradient(
            colors: [
                Color(red: 0.4, green: 0.4, blue: 0.4),
                Color(red: 0.3, green: 0.3, blue: 0.35),
                Color(red: 0.2, green: 0.2, blue: 0.25),
                Color.black
            ],
            center: UnitPoint(x: 0.3, y: 0.3),
            startRadius: 0,
            endRadius: meteor.size
        )
    }
    
    private func startRotation() {
        withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
            rotation = 360 * meteor.rotationSpeed
        }
    }
}

// MARK: - Home View Components
struct HomeViewBackground: View {
    var body: some View {
        ZStack {
            DesignSystem.AnimatedStarField()
                .ignoresSafeArea()
            
            RealisticMeteorSystem()
                .allowsHitTesting(false)
                .zIndex(0)
            
            headerText
        }
    }
    
    private var headerText: some View {
        VStack {
            Text("Choose your trading mentor planet")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .padding(.top, 50)
            Spacer()
        }
        .zIndex(10)
        .animation(.none, value: UUID())
        .id("fixed-header-never-move")
    }
}

struct SolarSystemView: View {
    @ObservedObject var solarManager: SolarSystemManager
    let rotationAngle: Double
    let planetAnimations: [UUID: Bool]
    let onPlanetTap: (TradingPlanet) -> Void
    @Namespace private var planetTransition
    
    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            
            ZStack {
                ForEach(Array(solarManager.planets.enumerated()), id: \.element.id) { index, planet in
                    PlanetSystemView(
                        planet: planet,
                        index: index,
                        center: center,
                        rotationAngle: rotationAngle,
                        solarManager: solarManager,
                        planetAnimations: planetAnimations,
                        planetTransition: planetTransition,
                        onPlanetTap: onPlanetTap
                    )
                }
            }
        }
        .frame(height: 180)
        .zIndex(1)
    }
}

struct PlanetSystemView: View {
    let planet: TradingPlanet
    let index: Int
    let center: CGPoint
    let rotationAngle: Double
    @ObservedObject var solarManager: SolarSystemManager
    let planetAnimations: [UUID: Bool]
    let planetTransition: Namespace.ID
    let onPlanetTap: (TradingPlanet) -> Void
    
    var body: some View {
        Group {
            orbitCircle
            planetView
        }
    }
    
    private var orbitCircle: some View {
        Circle()
            .stroke(planet.color.opacity(0.15), lineWidth: 1)
            .frame(width: radius * 2, height: radius * 2)
            .position(center)
    }
    
    private var planetView: some View {
        PlanetView(
            planet: planet,
            isSelected: planet.id == solarManager.selectedPlanet.id,
            isAnimating: planetAnimations[planet.id] ?? false
        )
        .position(planetPosition)
        .matchedGeometryEffect(id: planet.id, in: planetTransition)
        .onTapGesture {
            onPlanetTap(planet)
        }
    }
    
    private var radius: CGFloat {
        CGFloat(60 + (index * 35))
    }
    
    private var angle: Double {
        rotationAngle + Double(index * 60)
    }
    
    private var planetPosition: CGPoint {
        CGPoint(
            x: center.x + radius * cos(angle * .pi / 180),
            y: center.y + radius * sin(angle * .pi / 180)
        )
    }
}

struct PlanetInfoView: View {
    @ObservedObject var solarManager: SolarSystemManager
    
    var body: some View {
        VStack(spacing: 16) {
            planetHeaderSection
            planetDetailsSection
            planetSubtitle
        }
        .frame(height: 240)
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(planetInfoBackground)
        .clipped()
        .id(solarManager.selectedPlanet.id)
    }
    
    private var planetHeaderSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            planetNameRow
            philosophyRow
            mentorRow
        }
    }
    
    private var planetNameRow: some View {
        HStack {
            if solarManager.selectedPlanet.name == "Black Hole" {
                Text(solarManager.selectedPlanet.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(blackHoleTextGradient)
                    .addBlackHoleGlow()
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .layoutPriority(1)
            } else {
                Text(solarManager.selectedPlanet.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .layoutPriority(1)
            }
            Spacer()
        }
    }
    
    private var philosophyRow: some View {
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
    }
    
    private var mentorRow: some View {
        HStack {
            Text("by \(solarManager.selectedPlanet.mentorName)")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer()
        }
    }
    
    private var planetDetailsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            descriptionRow
            statsSection
        }
    }
    
    private var descriptionRow: some View {
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
    }
    
    private var statsSection: some View {
        VStack(spacing: 8) {
            if solarManager.selectedPlanet.name != "Black Hole" {
                accountBalanceRow
            }
            tradingExpertiseRow
        }
    }
    
    private var accountBalanceRow: some View {
        HStack {
            Text("Account Balance:")
                .font(.subheadline.bold())
                .foregroundColor(.white.opacity(0.8))
                .layoutPriority(1)
            
            Spacer()
            
            balanceText
        }
        .frame(height: 40)
        .padding(.horizontal, 14)
        .background(accountBalanceBackground)
    }
    
    private var balanceText: some View {
        Group {
            if solarManager.selectedPlanet.name == "Black Hole" {
                Text("∞ INFINITE")
                    .font(.title3.bold())
                    .foregroundStyle(infiniteBalanceGradient)
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
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .layoutPriority(1)
        }
        .frame(height: 40)
        .padding(.horizontal, 14)
        .background(tradingExpertiseBackground)
    }
    
    private var planetSubtitle: some View {
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
    
    // MARK: - Computed Properties
    private var blackHoleTextGradient: LinearGradient {
        LinearGradient(
            colors: [Color.white, Color.purple, Color.indigo, Color.white],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var planetPhilosophyGradient: LinearGradient {
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
    
    private var infiniteBalanceGradient: LinearGradient {
        LinearGradient(
            colors: [Color.purple, Color.white, Color.indigo],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var accountBalanceBackground: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(solarManager.selectedPlanet.color.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(solarManager.selectedPlanet.color.opacity(0.3), lineWidth: 1)
            )
            .shadow(
                color: solarManager.selectedPlanet.color.opacity(0.2),
                radius: 4,
                x: 0,
                y: 2
            )
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
        ZStack {
            mainCardBackground
            if solarManager.selectedPlanet.name == "Black Hole" {
                blackHoleGlowEffect
            }
        }
        .shadow(
            color: planetShadowColor,
            radius: planetShadowRadius,
            x: 0,
            y: 4
        )
    }
    
    private var mainCardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(planetBackgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(planetBorderColor, lineWidth: planetBorderWidth)
            )
    }
    
    private var blackHoleGlowEffect: some View {
        VStack {
            Rectangle()
                .fill(blackHoleGradient)
                .frame(height: 30)
                .blur(radius: 8)
                .overlay(glowOverlays)
            
            Spacer()
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private var glowOverlays: some View {
        ZStack {
            Rectangle()
                .fill(blackHoleSecondaryGradient)
                .frame(height: 20)
                .blur(radius: 4)
            
            Rectangle()
                .fill(blackHoleTertiaryGradient)
                .frame(height: 10)
                .blur(radius: 2)
        }
    }
    
    private var planetBackgroundColor: Color {
        solarManager.selectedPlanet.name == "Black Hole" ?
        Color.black.opacity(0.7) :
        Color.black.opacity(0.5)
    }
    
    private var planetBorderColor: Color {
        solarManager.selectedPlanet.name == "Black Hole" ?
        Color.white.opacity(0.6) :
        solarManager.selectedPlanet.color.opacity(0.5)
    }
    
    private var planetBorderWidth: CGFloat {
        solarManager.selectedPlanet.name == "Black Hole" ? 2 : 1
    }
    
    private var planetShadowColor: Color {
        solarManager.selectedPlanet.name == "Black Hole" ?
        Color.white.opacity(0.4) :
        solarManager.selectedPlanet.color.opacity(0.3)
    }
    
    private var planetShadowRadius: CGFloat {
        solarManager.selectedPlanet.name == "Black Hole" ? 12 : 8
    }
    
    private var blackHoleGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.8),
                Color.purple.opacity(0.6),
                Color.indigo.opacity(0.4),
                Color.clear
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var blackHoleSecondaryGradient: LinearGradient {
        LinearGradient(
            colors: [Color.white.opacity(0.6), Color.clear],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var blackHoleTertiaryGradient: LinearGradient {
        LinearGradient(
            colors: [Color.white.opacity(0.9), Color.clear],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

struct EnterPlanetButton: View {
    @ObservedObject var solarManager: SolarSystemManager
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            impactFeedback()
            action()
        }) {
            HStack(spacing: 12) {
                Image(systemName: buttonIcon)
                    .font(.title2)
                
                Text(buttonText)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundColor(.white)
            .frame(width: 280, height: 50)
            .background(enterButtonBackground)
            .clipShape(Capsule())
            .shadow(color: buttonShadowColor, radius: 10, x: 0, y: 5)
            .overlay(buttonOverlay)
        }
        .animation(.none, value: UUID())
        .id("enter-button-static")
    }
    
    private var buttonIcon: String {
        solarManager.selectedPlanet.name == "Black Hole" ? "books.vertical.fill" : "rocket.fill"
    }
    
    private var buttonText: String {
        solarManager.selectedPlanet.name == "Black Hole" ?
        "Access Knowledge Library" :
        "Enter \(solarManager.selectedPlanet.name)"
    }
    
    private var buttonShadowColor: Color {
        solarManager.selectedPlanet.name == "Black Hole" ?
        Color.white.opacity(0.3) :
        solarManager.selectedPlanet.color.opacity(0.3)
    }
    
    @ViewBuilder
    private var buttonOverlay: some View {
        if solarManager.selectedPlanet.name == "Black Hole" {
            AnimatedGlowOverlay()
        }
    }
    
    private var enterButtonBackground: LinearGradient {
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
    
    private func impactFeedback() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
}

// MARK: - Main Home View
struct HomeView: View {
    @StateObject private var solarManager = SolarSystemManager()
    @State private var showingPlanetDashboard = false
    @State private var showingGoldexControl = false
    @State private var rotationAngle: Double = 0
    @State private var planetAnimations: [UUID: Bool] = [:]
    @Namespace private var planetTransition
    
    var body: some View {
        ZStack {
            HomeViewBackground()
            
            VStack(spacing: 20) {
                Spacer().frame(height: 40)
                
                SolarSystemView(
                    solarManager: solarManager,
                    rotationAngle: rotationAngle,
                    planetAnimations: planetAnimations,
                    onPlanetTap: handlePlanetTap
                )
                
                Spacer().frame(height: 60)
                
                PlanetInfoView(solarManager: solarManager)
                
                Spacer().frame(height: 2)
                
                EnterPlanetButton(solarManager: solarManager) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showingPlanetDashboard = true
                    }
                }
                .padding(.bottom, 100)
                .zIndex(3)
            }
            .padding(.horizontal)
            .padding(.top, 0)
            .padding(.bottom, -15)
        }
        .applyNavigation()
        .applyPresentations(
            showingPlanetDashboard: $showingPlanetDashboard,
            showingGoldexControl: $showingGoldexControl,
            selectedPlanetDashboard: selectedPlanetDashboard
        )
        .onAppear {
            startOrbitAnimation()
            solarManager.loadSelectedPlanet()
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
    
    private func handlePlanetTap(_ planet: TradingPlanet) {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        if planet.unlocked {
            solarManager.selectPlanet(planet)
            animatePlanetSelection(planet)
        }
    }
    
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
}

// MARK: - View Extensions
extension View {
    func applyNavigation() -> some View {
        self
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
    }
    
    func applyPresentations(
        showingPlanetDashboard: Binding<Bool>,
        showingGoldexControl: Binding<Bool>,
        selectedPlanetDashboard: some View
    ) -> some View {
        self
            .fullScreenCover(isPresented: showingPlanetDashboard) {
                selectedPlanetDashboard
            }
            .sheet(isPresented: showingGoldexControl) {
                GoldexFlipModeControlView()
            }
    }
    
    func addBlackHoleGlow() -> some View {
        self
            .shadow(color: Color.white, radius: 8, x: 0, y: 0)
            .shadow(color: Color.purple, radius: 12, x: 0, y: 0)
            .shadow(color: Color.indigo, radius: 16, x: 0, y: 0)
            .shadow(color: Color.white, radius: 20, x: 0, y: 0)
            .overlay(
                self
                    .foregroundColor(.white)
                    .opacity(0.9)
            )
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView()
        }
        .preferredColorScheme(.dark)
    }
}
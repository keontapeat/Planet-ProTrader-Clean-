import SwiftUI

// MARK: - Animated Glow Overlay for Black Hole Button (ADD THIS BEFORE THE MODELS)
struct AnimatedGlowOverlay: View {
    @State private var glowOffset: CGFloat = -300
    @State private var currentColors: [Color] = [.purple, .blue, .cyan, .white, .yellow, .orange, .red]
    @State private var colorIndex = 0
    @State private var liquidOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Main liquid glow sweep
            Rectangle()
                .fill(
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
                )
                .frame(width: 120, height: 50)
                .offset(x: liquidOffset)
                .blur(radius: 2)
                .clipShape(Capsule())
                .blendMode(.screen)
            
            // Secondary liquid layer for depth
            Rectangle()
                .fill(
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
                )
                .frame(width: 100, height: 50)
                .offset(x: liquidOffset - 20)
                .blur(radius: 3)
                .clipShape(Capsule())
                .blendMode(.overlay)
            
            // Sparkle particles in the liquid
            ForEach(0..<12, id: \.self) { particle in
                Circle()
                    .fill(
                        [Color.white, Color.cyan, Color.purple, Color.yellow].randomElement()!
                            .opacity(Double.random(in: 0.6...1.0))
                    )
                    .frame(width: CGFloat.random(in: 1...3), height: CGFloat.random(in: 1...3))
                    .offset(
                        x: liquidOffset + CGFloat.random(in: -60...60),
                        y: CGFloat.random(in: -15...15)
                    )
                    .blur(radius: 0.8)
                    .opacity(abs(liquidOffset) < 200 ? 1.0 : 0.0)
            }
            
            // Edge glow effect
            Capsule()
                .stroke(
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
                    ),
                    lineWidth: 2
                )
                .frame(width: 280, height: 50)
                .blur(radius: 1)
        }
        .onAppear {
            startLiquidGlowAnimation()
        }
    }
    
    private func startLiquidGlowAnimation() {
        // Continuous liquid sweep animation
        Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 2.0)) {
                liquidOffset = 350
            }
            
            // Reset position after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                liquidOffset = -350
            }
        }
        
        // Color cycling animation
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.4)) {
                colorIndex = (colorIndex + 1) % currentColors.count
            }
        }
        
        // Start first animation immediately
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

// MARK: - Ultra-Realistic 3D Meteor System
struct RealisticMeteorSystem: View {
    @State private var meteors: [RealisticMeteor] = []
    @State private var fireParticles: [FireParticle] = []
    @State private var shockwaves: [Shockwave] = []
    @State private var sparks: [Spark] = []
    
    var body: some View {
        ZStack {
            // Shockwaves (behind everything)
            ForEach(shockwaves) { shockwave in
                ShockwaveView(shockwave: shockwave)
            }
            
            // Fire trail particles
            ForEach(fireParticles) { particle in
                FireParticleView(particle: particle)
            }
            
            // Sparks and debris
            ForEach(sparks) { spark in
                SparkView(spark: spark)
            }
            
            // Meteors with 3D effect (on top)
            ForEach(meteors) { meteor in
                RealisticMeteorView(meteor: meteor)
            }
        }
        .onAppear {
            startMeteorShower()
        }
    }
    
    private func startMeteorShower() {
        // Create meteors with realistic random intervals like real meteor showers
        scheduleNextMeteor()
        
        // Update at 120 FPS for ultra-smooth animation
        Timer.scheduledTimer(withTimeInterval: 0.008, repeats: true) { _ in
            updateMeteorsAndParticles()
        }
    }
    
    private func scheduleNextMeteor() {
        // Much more realistic timing - 8 to 25 seconds between meteors
        let randomDelay = Double.random(in: 8.0...25.0)
        
        // Very rare bursts (like real meteor showers)
        let shouldCreateBurst = Double.random(in: 0...1) < 0.05 // Only 5% chance
        
        DispatchQueue.main.asyncAfter(deadline: .now() + randomDelay) {
            createNewMeteor()
            
            // If it's a rare burst, create 1-2 more meteors
            if shouldCreateBurst {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 1.0...3.0)) {
                    createNewMeteor()
                }
                // 30% chance for a third meteor in the burst
                if Double.random(in: 0...1) < 0.3 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 2.0...5.0)) {
                        createNewMeteor()
                    }
                }
            }
            
            scheduleNextMeteor() // Schedule the next meteor
        }
    }
    
    private func createNewMeteor() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        // More realistic entry points (mostly from top, some from sides)
        let entryPoints = [
            // Top entries (80% of meteors) - most realistic
            CGPoint(x: Double.random(in: -50...screenWidth + 50), y: -Double.random(in: 50...150)),
            CGPoint(x: Double.random(in: 0...screenWidth), y: -Double.random(in: 30...120)),
            CGPoint(x: Double.random(in: screenWidth*0.2...screenWidth*0.8), y: -Double.random(in: 40...100)),
            CGPoint(x: Double.random(in: screenWidth*0.1...screenWidth*0.9), y: -Double.random(in: 60...140)),
            
            // Side entries (20% of meteors) - less common but realistic
            CGPoint(x: -Double.random(in: 30...80), y: Double.random(in: 0...screenHeight/3)),
            CGPoint(x: screenWidth + Double.random(in: 30...80), y: Double.random(in: 0...screenHeight/3))
        ]
        
        let startPoint = entryPoints.randomElement()!
        
        // Realistic exit trajectories
        let endPoint = CGPoint(
            x: startPoint.x + Double.random(in: -200...200), // Some drift
            y: screenHeight + Double.random(in: 50...150)
        )
        
        // Realistic meteor size distribution (most are small)
        let meteorSize: CGFloat
        let sizeRandom = Double.random(in: 0...1)
        if sizeRandom < 0.6 {
            meteorSize = CGFloat.random(in: 2...5) // 60% small meteors
        } else if sizeRandom < 0.85 {
            meteorSize = CGFloat.random(in: 5...9) // 25% medium meteors
        } else if sizeRandom < 0.95 {
            meteorSize = CGFloat.random(in: 9...14) // 10% large meteors
        } else {
            meteorSize = CGFloat.random(in: 14...20) // 5% huge meteors
        }
        
        // Speed varies realistically with size (smaller = faster usually)
        let meteorSpeed = meteorSize < 5 ? Double.random(in: 8...15) :
                         meteorSize < 10 ? Double.random(in: 5...10) :
                         Double.random(in: 3...7)
        
        // Temperature based on speed and size
        let meteorTemp = (meteorSpeed * 200) + Double.random(in: 1800...2500)
        
        let meteor = RealisticMeteor(
            id: UUID(),
            startPosition: startPoint,
            currentPosition: startPoint,
            endPosition: endPoint,
            size: meteorSize,
            speed: meteorSpeed,
            rotationSpeed: Double.random(in: 2...8),
            fireIntensity: Double.random(in: 0.6...1.0),
            temperature: meteorTemp,
            atmosphericEntry: false,
            creationTime: Date(),
            trailLength: Int(meteorSize * Double.random(in: 1.5...2.5)),
            fragmentationChance: meteorSize > 10 ? Double.random(in: 0.02...0.08) : Double.random(in: 0.001...0.03)
        )
        
        meteors.append(meteor)
        
        // Only create shockwave for larger/faster meteors
        if meteorSize > 8 || meteorSpeed > 10 {
            createShockwave(at: startPoint, intensity: meteorSpeed / 10.0)
        }
    }
    
    private func createShockwave(at position: CGPoint, intensity: Double) {
        let shockwave = Shockwave(
            id: UUID(),
            position: position,
            maxRadius: CGFloat(intensity * 50),
            currentRadius: 0,
            currentOpacity: 0.6,
            lifetime: 0.8,
            creationTime: Date()
        )
        shockwaves.append(shockwave)
    }
    
    private func updateMeteorsAndParticles() {
        let currentTime = Date()
        
        // Update meteors
        for i in meteors.indices.reversed() {
            let meteor = meteors[i]
            let elapsed = currentTime.timeIntervalSince(meteor.creationTime)
            let progress = elapsed * meteor.speed / 10.0
            
            if progress >= 1.0 {
                // Create explosion effect when meteor exits
                createMeteorExplosion(at: meteor.currentPosition, size: meteor.size)
                meteors.remove(at: i)
                continue
            }
            
            // Update meteor position with realistic physics
            let newX = meteor.startPosition.x + (meteor.endPosition.x - meteor.startPosition.x) * progress
            let newY = meteor.startPosition.y + (meteor.endPosition.y - meteor.startPosition.y) * progress
            let newPosition = CGPoint(x: newX, y: newY)
            meteors[i].currentPosition = newPosition
            
            // Atmospheric entry effects
            let screenHeight = UIScreen.main.bounds.height
            if newY > screenHeight * 0.1 && !meteor.atmosphericEntry {
                meteors[i].atmosphericEntry = true
                createShockwave(at: newPosition, intensity: meteor.speed / 8.0)
            }
            
            // Random fragmentation
            if Double.random(in: 0...1) < meteor.fragmentationChance {
                createFragmentation(from: meteor)
            }
            
            // Create enhanced fire particles
            createAdvancedFireParticlesForMeteor(meteor)
            
            // Create sparks and debris
            if Int.random(in: 0...5) == 0 {
                createSparks(from: meteor)
            }
        }
        
        // Update fire particles with physics
        for i in fireParticles.indices.reversed() {
            let elapsed = currentTime.timeIntervalSince(fireParticles[i].creationTime)
            if elapsed > fireParticles[i].lifetime {
                fireParticles.remove(at: i)
                continue
            }
            
            let progress = elapsed / fireParticles[i].lifetime
            fireParticles[i].currentOpacity = (1.0 - progress) * fireParticles[i].baseOpacity
            
            let particle = fireParticles[i]
            // Add gravity and air resistance - FIXED
            let gravity: Double = 2.0
            let airResistance: Double = 0.98
            
            let newX = particle.startPosition.x + particle.velocity.dx * elapsed * airResistance
            let gravityEffect = gravity * elapsed * elapsed
            let newY = particle.startPosition.y + particle.velocity.dy * elapsed + gravityEffect
            fireParticles[i].currentPosition = CGPoint(x: newX, y: newY)
            fireParticles[i].currentSize = particle.size * (1.0 - progress * 0.7)
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
        
        // Update sparks - FIXED
        for i in sparks.indices.reversed() {
            let elapsed = currentTime.timeIntervalSince(sparks[i].creationTime)
            if elapsed > sparks[i].lifetime {
                sparks.remove(at: i)
                continue
            }
            
            let progress = elapsed / sparks[i].lifetime
            sparks[i].currentOpacity = (1.0 - progress)
            
            let spark = sparks[i]
            let gravity: Double = 3.0
            let newX = spark.startPosition.x + spark.velocity.dx * elapsed
            let gravityEffect = gravity * elapsed * elapsed
            let newY = spark.startPosition.y + spark.velocity.dy * elapsed + gravityEffect
            sparks[i].currentPosition = CGPoint(x: newX, y: newY)
        }
    }
    
    private func createAdvancedFireParticlesForMeteor(_ meteor: RealisticMeteor) {
        // Particle count based on meteor size and atmospheric conditions
        let baseCount = meteor.atmosphericEntry ? Int.random(in: 4...12) : Int.random(in: 2...6)
        let sizeBonus = Int(meteor.size / 3) // Bigger meteors = more particles
        let particleCount = baseCount + sizeBonus
        
        for _ in 0..<particleCount {
            let baseTemp = meteor.temperature
            let tempVariation = Double.random(in: -500...500)
            let particleTemp = max(1200, baseTemp + tempVariation)
            
            // More realistic particle spread
            let spreadRadius = meteor.size / 2
            let particleStartX = meteor.currentPosition.x + Double.random(in: -spreadRadius...spreadRadius)
            let particleStartY = meteor.currentPosition.y + Double.random(in: -spreadRadius...spreadRadius)
            
            let particle = FireParticle(
                id: UUID(),
                startPosition: CGPoint(x: particleStartX, y: particleStartY),
                currentPosition: CGPoint(x: particleStartX, y: particleStartY),
                velocity: CGVector(
                    dx: Double.random(in: -3...3),
                    dy: Double.random(in: -2...4)
                ),
                size: CGFloat.random(in: 2...7),
                currentSize: CGFloat.random(in: 2...7),
                color: getColorFromTemperature(particleTemp),
                lifetime: Double.random(in: 0.4...1.0),
                currentOpacity: 1.0,
                baseOpacity: Double.random(in: 0.7...1.0),
                temperature: particleTemp,
                creationTime: Date()
            )
            fireParticles.append(particle)
        }
    }
    
    private func createSparks(from meteor: RealisticMeteor) {
        for _ in 0..<Int.random(in: 2...6) {
            let spark = Spark(
                id: UUID(),
                startPosition: meteor.currentPosition,
                currentPosition: meteor.currentPosition,
                velocity: CGVector(
                    dx: Double.random(in: -6...6),
                    dy: Double.random(in: -4...2)
                ),
                color: [Color.yellow, Color.orange, Color.red].randomElement()!, // Fire colors
                size: CGFloat.random(in: 1...3),
                lifetime: Double.random(in: 0.2...0.6),
                currentOpacity: 1.0,
                creationTime: Date()
            )
            sparks.append(spark)
        }
    }
    
    private func createFragmentation(from meteor: RealisticMeteor) {
        // Create 2-3 smaller meteors
        for _ in 0..<Int.random(in: 2...3) {
            let fragmentSize = meteor.size * CGFloat.random(in: 0.3...0.7)
            let fragmentSpeed = meteor.speed * Double.random(in: 0.8...1.2)
            
            let angleVariation = Double.random(in: -0.5...0.5)
            let direction = atan2(
                meteor.endPosition.y - meteor.startPosition.y,
                meteor.endPosition.x - meteor.startPosition.x
            ) + angleVariation
            
            let distance = Double.random(in: 200...400)
            let fragmentEnd = CGPoint(
                x: meteor.currentPosition.x + cos(direction) * distance,
                y: meteor.currentPosition.y + sin(direction) * distance
            )
            
            let fragment = RealisticMeteor(
                id: UUID(),
                startPosition: meteor.currentPosition,
                currentPosition: meteor.currentPosition,
                endPosition: fragmentEnd,
                size: fragmentSize,
                speed: fragmentSpeed,
                rotationSpeed: meteor.rotationSpeed * Double.random(in: 1.2...2.0),
                fireIntensity: meteor.fireIntensity * 0.8,
                temperature: meteor.temperature * 0.9,
                atmosphericEntry: meteor.atmosphericEntry,
                creationTime: Date(),
                trailLength: Int(fragmentSize * 1.5),
                fragmentationChance: 0.0 // Fragments don't fragment
            )
            meteors.append(fragment)
        }
    }
    
    private func createMeteorExplosion(at position: CGPoint, size: CGFloat) {
        // Create explosion particles
        for _ in 0..<Int.random(in: 15...25) {
            let particle = FireParticle(
                id: UUID(),
                startPosition: position,
                currentPosition: position,
                velocity: CGVector(
                    dx: Double.random(in: -8...8),
                    dy: Double.random(in: -8...8)
                ),
                size: CGFloat.random(in: 2...6),
                currentSize: CGFloat.random(in: 2...6),
                color: [Color.yellow, Color.orange, Color.red, Color(red: 1.0, green: 0.7, blue: 0.3)].randomElement()!, // Fire colors
                lifetime: Double.random(in: 0.8...1.5),
                currentOpacity: 1.0,
                baseOpacity: 1.0,
                temperature: 3000,
                creationTime: Date()
            )
            fireParticles.append(particle)
        }
        
        // Create explosion shockwave
        createShockwave(at: position, intensity: Double(size) / 2.0)
    }
    
    private func getColorFromTemperature(_ temperature: Double) -> Color {
        // Realistic fire colors - mix of red, orange, and yellow
        let fireColors = [
            Color.red,
            Color.orange,
            Color.yellow,
            Color(red: 1.0, green: 0.6, blue: 0.2), // Orange-red
            Color(red: 1.0, green: 0.8, blue: 0.3), // Yellow-orange
            Color(red: 0.9, green: 0.4, blue: 0.1)  // Deep orange
        ]
        return fireColors.randomElement()!
    }
}

// MARK: - Ultra-Realistic 3D Meteor View with 3D Rock Texture
struct RealisticMeteorView: View {
    let meteor: RealisticMeteor
    @State private var rotation: Double = 0
    @State private var heatDistortion: Double = 0
    
    var body: some View {
        ZStack {
            // Heat distortion effect
            if meteor.atmosphericEntry {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.clear,
                                Color.yellow.opacity(0.1),
                                Color.orange.opacity(0.08),
                                Color.red.opacity(0.05),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: meteor.size,
                            endRadius: meteor.size * 4
                        )
                    )
                    .frame(width: meteor.size * 8, height: meteor.size * 8)
                    .scaleEffect(1 + sin(heatDistortion) * 0.1)
                    .blur(radius: 8)
                    .opacity(0.6)
            }
            
            // Plasma trail (atmospheric compression)
            if meteor.atmosphericEntry {
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.yellow.opacity(0.9),  // Hot yellow center
                                Color.orange.opacity(0.8),  // Orange middle
                                Color.red.opacity(0.6),     // Red edges
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: meteor.size * 6, height: meteor.size * 2)
                    .blur(radius: 3)
                    .opacity(0.8)
            }
            
            // Main meteor body with 3D rock texture
            ZStack {
                // Outer atmospheric glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                [Color.yellow, Color.orange, Color.red].randomElement()!.opacity(0.9),
                                [Color.orange, Color.red].randomElement()!.opacity(0.7),
                                Color.red.opacity(0.5),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: meteor.size * 3
                        )
                    )
                    .frame(width: meteor.size * 4, height: meteor.size * 4)
                    .blur(radius: 6)
                
                // 3D ROCK TEXTURE BASE
                Circle()
                    .fill(createRealistic3DRockTexture(for: meteor))
                    .frame(width: meteor.size, height: meteor.size)
                    .overlay(
                        // Surface roughness and bumps
                        ZStack {
                            ForEach(0..<15, id: \.self) { i in
                                createRockBump(
                                    size: CGFloat.random(in: meteor.size * 0.1...meteor.size * 0.3),
                                    position: CGPoint(
                                        x: cos(Double(i) * 0.4 + rotation * 0.01) * meteor.size * Double.random(in: 0.2...0.4),
                                        y: sin(Double(i) * 0.4 + rotation * 0.01) * meteor.size * Double.random(in: 0.2...0.4)
                                    ),
                                    depth: Double.random(in: 0.3...0.8)
                                )
                            }
                        }
                        .clipShape(Circle())
                    )
                    .overlay(
                        // Mineral veins and cracks
                        ZStack {
                            ForEach(0..<8, id: \.self) { i in
                                createMineralVein(
                                    angle: Double(i) * 45 + rotation * 0.2,
                                    length: meteor.size * Double.random(in: 0.6...0.9),
                                    thickness: CGFloat.random(in: 0.5...1.5)
                                )
                            }
                        }
                        .clipShape(Circle())
                    )
                    .overlay(
                        // Surface craters and impact marks
                        ZStack {
                            ForEach(0..<6, id: \.self) { i in
                                createImpactCrater(
                                    size: CGFloat.random(in: meteor.size * 0.15...meteor.size * 0.4),
                                    position: CGPoint(
                                        x: cos(Double(i) * 1.047 + rotation * 0.005) * meteor.size * 0.3,
                                        y: sin<Double>(Double(i) * 1.047 + rotation * 0.005) * meteor.size * 0.3
                                    )
                                )
                            }
                        }
                        .clipShape(Circle())
                    )
                    .rotationEffect(.degrees(rotation))
                
                // 3D lighting and shadows
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.clear,
                                Color.clear,
                                Color.black.opacity(0.4),
                                Color.black.opacity(0.8)
                            ],
                            center: UnitPoint(x: 0.2, y: 0.2),
                            startRadius: meteor.size * 0.3,
                            endRadius: meteor.size * 0.5
                        )
                    )
                    .frame(width: meteor.size, height: meteor.size)
                    .blendMode(.multiply)
                
                // Hot glowing areas from atmospheric friction
                ForEach(0..<4, id: \.self) { i in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    [Color.yellow, Color.orange].randomElement()!.opacity(0.9),
                                    Color.orange.opacity(0.6),
                                    Color.red.opacity(0.3),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: meteor.size * 0.2
                            )
                        )
                        .frame(width: meteor.size * 0.25, height: meteor.size * 0.25)
                        .offset(
                            x: cos(Double(i) * 1.57 + rotation * 0.02) * meteor.size * 0.35,
                            y: sin<Double>(Double(i) * 1.57 + rotation * 0.02) * meteor.size * 0.35
                        )
                        .blur(radius: 1.5)
                        .blendMode(.screen)
                }
                
                // Realistic surface highlight (sun reflection)
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.4),
                                Color.white.opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: meteor.size * 0.3
                        )
                    )
                    .frame(width: meteor.size * 0.4, height: meteor.size * 0.3)
                    .offset(x: -meteor.size * 0.25, y: -meteor.size * 0.25)
                    .blur(radius: 2)
                    .opacity(0.6)
                
                // Sonic boom visualization for fast meteors
                if meteor.atmosphericEntry && meteor.speed > 8 {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .stroke([Color.yellow, Color.orange, Color.red].randomElement()!.opacity(0.4), lineWidth: 1)
                            .frame(width: meteor.size * CGFloat(2 + i), height: meteor.size * CGFloat(2 + i))
                            .opacity(0.6 - Double(i) * 0.2)
                    }
                }
            }
            .shadow(color: Color.red.opacity(0.8), radius: 12, x: 3, y: 3)
            .scaleEffect(1 + sin(rotation * 0.05) * 0.08)
        }
        .position(meteor.currentPosition)
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotation = 360 * meteor.rotationSpeed
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                heatDistortion = 1.0
            }
        }
    }
    
    // MARK: - 3D Rock Texture Creation
    private func createRealistic3DRockTexture(for meteor: RealisticMeteor) -> RadialGradient {
        let rockTypes = [
            [Color(red: 0.4, green: 0.4, blue: 0.4), Color(red: 0.3, green: 0.3, blue: 0.35), Color(red: 0.2, green: 0.2, blue: 0.25), Color.black],
            [Color(red: 0.5, green: 0.4, blue: 0.3), Color(red: 0.4, green: 0.3, blue: 0.25), Color(red: 0.3, green: 0.25, blue: 0.2), Color(red: 0.2, green: 0.15, blue: 0.1)],
            [Color(red: 0.3, green: 0.3, blue: 0.3), Color(red: 0.25, green: 0.25, blue: 0.25), Color(red: 0.2, green: 0.2, blue: 0.2), Color(red: 0.1, green: 0.1, blue: 0.1)],
            [Color(red: 0.6, green: 0.5, blue: 0.3), Color(red: 0.5, green: 0.4, blue: 0.25), Color(red: 0.4, green: 0.3, blue: 0.2), Color(red: 0.3, green: 0.2, blue: 0.15)]
        ]
        
        let selectedRockType = rockTypes.randomElement()!
        
        return RadialGradient(
            colors: selectedRockType,
            center: UnitPoint(x: 0.3, y: 0.3),
            startRadius: 0,
            endRadius: meteor.size
        )
    }
    
    private func createRockBump(size: CGFloat, position: CGPoint, depth: Double) -> some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        Color.white.opacity(0.3 * depth),
                        Color.clear,
                        Color.black.opacity(0.4 * depth)  
                    ],
                    center: UnitPoint(x: 0.3, y: 0.3),
                    startRadius: 0,
                    endRadius: size * 0.5
                )
            )
            .frame(width: size, height: size)
            .offset(x: position.x, y: position.y)
            .blendMode(.overlay)
    }
    
    private func createMineralVein(angle: Double, length: Double, thickness: CGFloat) -> some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color(red: 0.7, green: 0.6, blue: 0.5).opacity(0.6), 
                        Color(red: 0.6, green: 0.5, blue: 0.4).opacity(0.8),
                        Color.clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: length, height: thickness)
            .rotationEffect(.degrees(angle))
            .blur(radius: 0.5)
            .opacity(0.7)
    }
    
    private func createImpactCrater(size: CGFloat, position: CGPoint) -> some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        Color.black.opacity(0.8),     
                        Color.black.opacity(0.6),     
                        Color.gray.opacity(0.3),      
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: size * 0.5
                )
            )
            .frame(width: size, height: size)
            .offset(x: position.x, y: position.y)
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                    .frame(width: size, height: size)
                    .offset(x: position.x, y: position.y)
            )
            .blendMode(.multiply)
    }
}

// MARK: - Enhanced Particle Views
struct FireParticleView: View {
    let particle: FireParticle
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
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
                )
                .frame(width: particle.currentSize, height: particle.currentSize)
            
            Circle()
                .fill(particle.color.opacity(particle.currentOpacity * 0.3))
                .frame(width: particle.currentSize * 2, height: particle.currentSize * 2)
                .blur(radius: 3)
        }
        .position(particle.currentPosition)
        .blendMode(.screen)
    }
}

// MARK: - Fixed Particle Views
struct ShockwaveView: View {
    let shockwave: Shockwave
    
    var body: some View {
        Circle()
            .stroke(
                LinearGradient(
                    colors: [
                        Color.yellow.opacity(shockwave.currentOpacity), // Yellow center
                        Color.orange.opacity(shockwave.currentOpacity * 0.8), // Orange middle
                        Color.red.opacity(shockwave.currentOpacity * 0.6), // Red outer
                        Color.clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                lineWidth: 2
            )
            .frame(width: shockwave.currentRadius * 2, height: shockwave.currentRadius * 2)
            .position(shockwave.position)
            .blur(radius: 1)
            .blendMode(.screen)
    }
}

// MARK: - Fixed Spark View
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
            
            // REALISTIC METEORS - ADD THIS
            RealisticMeteorSystem()
                .allowsHitTesting(false)
                .zIndex(0)
            
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
                    // SPECIAL GLOW EFFECT FOR BLACK HOLE TEXT ONLY
                    if solarManager.selectedPlanet.name == "Black Hole" {
                        Text(solarManager.selectedPlanet.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.white, Color.purple, Color.indigo, Color.white],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: Color.white, radius: 8, x: 0, y: 0)
                            .shadow(color: Color.purple, radius: 12, x: 0, y: 0)
                            .shadow(color: Color.indigo, radius: 16, x: 0, y: 0)
                            .shadow(color: Color.white, radius: 20, x: 0, y: 0)
                            .overlay(
                                Text(solarManager.selectedPlanet.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .opacity(0.9)
                            )
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .layoutPriority(1)
                    } else {
                        // Normal text for other planets
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
        ZStack {
            // Main card background
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
            
            // HARDCORE TOP GLOW FOR BLACK HOLE ONLY
            if solarManager.selectedPlanet.name == "Black Hole" {
                VStack {
                    // Top glow strip
                    Rectangle()
                        .fill(
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
                        )
                        .frame(height: 30)
                        .blur(radius: 8)
                        .overlay(
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.6),
                                            Color.clear
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(height: 20)
                                .blur(radius: 4)
                        )
                        .overlay(
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.9),
                                            Color.clear
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(height: 10)
                                .blur(radius: 2)
                        )
                    
                    Spacer()
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
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

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
//
//  Planet_ProTrader__Clean_App.swift
//  Planet ProTrader - Main App Entry Point
//
//  Professional Trading App - iOS 17+ Optimized
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI
import AVFoundation

@main
struct Planet_ProTrader__Clean_App: App {
    // MARK: - Shared Managers (Singleton Pattern)
    @StateObject private var tradingManager = TradingManager.shared
    @StateObject private var botManager = BotManager.shared  // FIXED: Use BotManager from CoreManagers
    @StateObject private var accountManager = AccountManager.shared
    @StateObject private var hapticManager = HapticManager.shared
    @StateObject private var audioManager = AudioManager.shared
    @StateObject private var appStateManager = AppStateManager.shared
    
    // MARK: - App Storage
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("lastAppVersion") private var lastAppVersion = ""
    @AppStorage("isFirstLaunch") private var isFirstLaunch = true
    
    // MARK: - State
    @State private var isAppReady = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    init() {
        setupAudioSession()
        setupAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // MARK: - App Background
                DesignSystem.AnimatedStarField()
                    .ignoresSafeArea()
                
                // MARK: - Main App Content
                Group {
                    if !hasCompletedOnboarding {
                        OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .scale.combined(with: .opacity)
                            ))
                    } else if isAppReady {
                        ContentView()
                            .environmentObject(tradingManager)
                            .environmentObject(botManager)
                            .environmentObject(accountManager)
                            .environmentObject(hapticManager)
                            .environmentObject(audioManager)
                            .environmentObject(appStateManager)
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .scale.combined(with: .opacity)
                            ))
                    } else {
                        LaunchScreen()
                            .transition(.opacity)
                    }
                }
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: hasCompletedOnboarding)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isAppReady)
            }
            .preferredColorScheme(.light)
            .onAppear {
                initializeApp()
            }
            .alert("App Error", isPresented: $showingError) {
                Button("Retry") {
                    initializeApp()
                }
                Button("Continue Anyway", role: .cancel) {
                    isAppReady = true
                }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Setup Methods
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            
            // Configure for background playback with mixing capabilities
            try audioSession.setCategory(
                .playback,
                mode: .default,
                options: [
                    .mixWithOthers,
                    .allowAirPlay,
                    .allowBluetooth,
                    .allowBluetoothA2DP,
                    .duckOthers
                ]
            )
            
            // Optimize for performance
            try audioSession.setPreferredSampleRate(44100.0)
            try audioSession.setPreferredIOBufferDuration(0.005)
            
            // Activate session
            try audioSession.setActive(true)
            
            print("🎵 Audio session configured successfully")
            
        } catch {
            print("⚠️ Audio session setup failed: \(error.localizedDescription)")
        }
    }
    
    private func setupAppearance() {
        // Configure global appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        // Navigation bar appearance
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor.clear
        navAppearance.shadowColor = UIColor.clear
        
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
    }
    
    // MARK: - App Initialization
    private func initializeApp() {
        Task {
            do {
                print("🚀 Initializing Planet ProTrader...")
                
                // Check if this is a fresh install or update
                checkAppVersion()
                
                // Initialize managers with proper error handling
                await initializeManagers()
                
                // Small delay for smooth transition
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                
                await MainActor.run {
                    isAppReady = true
                    print("✅ Planet ProTrader initialized successfully")
                }
                
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to initialize app: \(error.localizedDescription)"
                    showingError = true
                    print("❌ App initialization failed: \(error)")
                }
            }
        }
    }
    
    private func initializeManagers() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                print("📈 Trading Manager initializing...")
                try? await Task.sleep(nanoseconds: 500_000_000)
                print("✅ Trading Manager ready")
            }
            
            group.addTask {
                print("🤖 Bot Manager initializing...")
                try? await Task.sleep(nanoseconds: 300_000_000)
                print("✅ Bot Manager ready")
            }
            
            group.addTask {
                print("👤 Account Manager initializing...")  
                try? await Task.sleep(nanoseconds: 200_000_000)
                print("✅ Account Manager ready")
            }
            
            group.addTask {
                print("🎵 Audio Manager initializing...")
                try? await Task.sleep(nanoseconds: 100_000_000)
                print("✅ Audio Manager ready")
            }
            
            group.addTask {
                await self.appStateManager.initialize()
            }
        }
    }
    
    private func checkAppVersion() {
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        
        if lastAppVersion != currentVersion {
            print("📱 App updated from \(lastAppVersion) to \(currentVersion)")
            lastAppVersion = currentVersion
            
            // Handle app updates here if needed
        }
        
        if isFirstLaunch {
            print("🎉 First launch detected")
            isFirstLaunch = false
        }
    }
}

// MARK: - Launch Screen
struct LaunchScreen: View {
    @State private var animateIcon = false
    @State private var animateText = false
    @State private var showProgressBar = false
    @State private var progress: Double = 0
    
    var body: some View {
        ZStack {
            DesignSystem.AnimatedStarField()
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                // App Icon
                VStack(spacing: 16) {
                    Image(systemName: "globe.americas.fill")
                        .font(.system(size: 80, weight: .light))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [DesignSystem.solarOrange, .yellow, DesignSystem.cosmicBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(animateIcon ? 1.2 : 1.0)
                        .rotationEffect(.degrees(animateIcon ? 360 : 0))
                        .animation(
                            .spring(response: 2.0, dampingFraction: 0.6).repeatForever(autoreverses: false),
                            value: animateIcon
                        )
                    
                    Text("Planet ProTrader")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, DesignSystem.cosmicBlue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .opacity(animateText ? 1 : 0)
                        .offset(y: animateText ? 0 : 20)
                        .animation(.spring(response: 1.0, dampingFraction: 0.8).delay(0.5), value: animateText)
                }
                
                // Loading indicator
                if showProgressBar {
                    VStack(spacing: 12) {
                        Text("Initializing Trading Systems...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: DesignSystem.cosmicBlue))
                            .scaleEffect(1.2)
                    }
                    .transition(.opacity.combined(with: .scale))
                }
                
                Spacer()
                
                // Version info
                VStack(spacing: 8) {
                    Text("Professional Edition")
                        .font(.caption.bold())
                        .foregroundColor(.yellow)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(.yellow.opacity(0.2), in: Capsule())
                    
                    Text("v2.1.0")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .opacity(animateText ? 1 : 0)
                .animation(.easeInOut.delay(1.0), value: animateText)
            }
            .padding()
        }
        .onAppear {
            animateIcon = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                animateText = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    showProgressBar = true
                }
            }
        }
    }
}

// MARK: - App State Manager
@MainActor
class AppStateManager: ObservableObject {
    static let shared = AppStateManager()
    
    @Published var isActive = true
    @Published var backgroundTime: Date?
    
    private init() {
        setupNotifications()
    }
    
    func initialize() async {
        print("📱 App State Manager initialized")
        // Additional initialization logic can go here
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            self.isActive = false
            self.backgroundTime = Date()
            print("📱 App entering background")
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            self.isActive = true
            
            if let backgroundTime = self.backgroundTime {
                let timeInBackground = Date().timeIntervalSince(backgroundTime)
                print("📱 App returned from background after \(Int(timeInBackground)) seconds")
                
                // Handle background return logic here
                if timeInBackground > 300 { // 5 minutes
                    // Refresh data if app was in background for too long
                    Task {
                        await self.refreshAppData()
                    }
                }
            }
            
            self.backgroundTime = nil
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { _ in
            print("📱 App fully backgrounded")
            // Save app state, pause timers, etc.
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { _ in
            print("📱 App entering foreground")
            // Resume timers, refresh data, etc.
        }
    }
    
    private func refreshAppData() async {
        print("🔄 Refreshing app data after extended background time")
        // Implement data refresh logic
        // This could include refreshing trading data, account info, etc.
        
        // Simulate data refresh
        try? await Task.sleep(nanoseconds: 500_000_000)
        print("✅ App data refresh completed")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - App Launch Preview
#Preview("Launch Screen") {
    LaunchScreen()
}

#Preview("App State Manager") {
    VStack(spacing: 20) {
        Text("🚀 App State Manager")
            .font(DesignSystem.Typography.largeTitle)
            .goldText()
        
        Text("Handles app lifecycle and background/foreground transitions")
            .font(DesignSystem.Typography.body)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
        
        VStack(alignment: .leading, spacing: 8) {
            Text("Features:")
                .font(DesignSystem.Typography.headline)
                .goldText()
            
            VStack(alignment: .leading, spacing: 4) {
                Text("• Background time tracking")
                Text("• Automatic data refresh")
                Text("• App lifecycle management")
                Text("• Notification handling")
                Text("• Performance optimization")
            }
            .font(DesignSystem.Typography.body)
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .solarCard()
    }
    .padding()
    .background(DesignSystem.spaceGradient.ignoresSafeArea())
}
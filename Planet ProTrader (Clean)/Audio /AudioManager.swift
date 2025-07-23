//
//  AudioManager.swift
//  Planet ProTrader - Enhanced Audio System
//
//  Professional background music and sound effects manager
//  Created by AI Assistant on 1/25/25.
//

import AVFoundation
import SwiftUI
import Combine

// MARK: - Enhanced Audio Manager
@MainActor
class AudioManager: NSObject, ObservableObject {
    static let shared = AudioManager()
    
    // MARK: - Published Properties
    @Published var isMusicEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(isMusicEnabled, forKey: "audio_music_enabled")
            if isMusicEnabled && currentTrack == nil {
                playInterstellarTheme()
            } else if !isMusicEnabled {
                stopMusic()
            }
        }
    }
    
    @Published var isSFXEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(isSFXEnabled, forKey: "audio_sfx_enabled")
        }
    }
    
    @Published var musicVolume: Float = 0.6 {
        didSet {
            UserDefaults.standard.set(musicVolume, forKey: "audio_music_volume")
            backgroundPlayer?.volume = musicVolume
        }
    }
    
    @Published var sfxVolume: Float = 0.8 {
        didSet {
            UserDefaults.standard.set(sfxVolume, forKey: "audio_sfx_volume")
        }
    }
    
    @Published var isPlaying: Bool = false
    @Published var currentTrack: AudioTrack?
    @Published var playbackPosition: TimeInterval = 0
    @Published var trackDuration: TimeInterval = 0
    @Published var audioFileStatus: String = "Checking audio files..."
    
    // MARK: - Private Properties
    private var backgroundPlayer: AVAudioPlayer?
    private var sfxPlayer: AVAudioPlayer?
    private var fadeTimer: Timer?
    private var positionTimer: Timer?
    private var audioSession = AVAudioSession.sharedInstance()
    
    // MARK: - Audio Tracks
    enum AudioTrack: String, CaseIterable {
        case interstellarTheme = "interstellar_theme"
        case cosmicAmbience = "cosmic_ambience"
        case tradingTension = "trading_tension"
        case victoryFanfare = "victory_fanfare"
        
        var displayName: String {
            switch self {
            case .interstellarTheme: return "Interstellar Theme"
            case .cosmicAmbience: return "Cosmic Ambience"
            case .tradingTension: return "Trading Tension"
            case .victoryFanfare: return "Victory Fanfare"
            }
        }
        
        var icon: String {
            switch self {
            case .interstellarTheme: return "music.note"
            case .cosmicAmbience: return "sparkles"
            case .tradingTension: return "waveform.path.ecg"
            case .victoryFanfare: return "trophy.fill"
            }
        }
    }
    
    // MARK: - SFX Sounds
    enum SFXSound: String, CaseIterable {
        case buttonTap = "button_tap"
        case success = "success_chime"
        case error = "error_beep"
        case notification = "notification_ping"
        case deploy = "bot_deploy"
        case achievement = "achievement_unlock"
        
        var systemSoundID: SystemSoundID {
            switch self {
            case .buttonTap: return 1104 // Modern click
            case .success: return 1016 // SMS received
            case .error: return 1053 // Popcorn
            case .notification: return 1150 // Tweet sent
            case .deploy: return 1013 // Text tone input
            case .achievement: return 1054 // Glass
            }
        }
    }
    
    private override init() {
        super.init()
        loadUserPreferences()
        setupAudioSession()
        setupInterruptionHandling()
        
        // Debug: List all audio files on startup
        print("🚀 AudioManager initializing...")
        checkAudioFiles()
        
        // Auto-start interstellar theme if enabled
        if isMusicEnabled {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.playInterstellarTheme()
            }
        }
    }
    
    // MARK: - Audio File Checking
    private func checkAudioFiles() {
        print("🔍 Checking for audio files...")
        audioFileStatus = "Checking audio files..."
        
        // Check for interstellar theme specifically
        if let audioURL = findAudioFile(named: "interstellar_theme") {
            print("✅ Interstellar theme found at: \(audioURL.path)")
            audioFileStatus = "✅ Audio files found"
        } else {
            print("❌ Audio files not found in bundle")
            audioFileStatus = "❌ Audio files missing from bundle"
            showAudioSetupInstructions()
        }
        
        listAvailableAudioFiles()
    }
    
    private func showAudioSetupInstructions() {
        print("""
        
        📁 AUDIO SETUP INSTRUCTIONS:
        
        Your interstellar_theme.mp3 file exists but isn't in the Xcode project bundle.
        
        To fix this:
        1. Open Xcode
        2. Right-click on your project in the navigator
        3. Select "Add Files to [ProjectName]"
        4. Navigate to: /Users/keonta/Documents/Planet ProTrader (Clean)/Planet ProTrader (Clean)/Audio/
        5. Select interstellar_theme.mp3
        6. Make sure "Add to target" is checked for your main app target
        7. Click "Add"
        
        Alternative method:
        1. Drag interstellar_theme.mp3 directly from Finder into your Xcode project
        2. Choose "Copy items if needed" 
        3. Make sure your app target is selected
        
        The file should appear in your project navigator after adding it.
        
        """)
    }
    
    // MARK: - Audio Session Configuration
    private func setupAudioSession() {
        do {
            try audioSession.setCategory(
                .playback,
                mode: .default,
                options: []
            )
            
            try audioSession.setPreferredSampleRate(44100.0)
            try audioSession.setPreferredIOBufferDuration(0.005)
            try audioSession.setActive(true)
            
            print("✅ Audio session configured successfully for background playback")
            
        } catch {
            print("❌ Failed to configure audio session: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Interruption Handling
    private func setupInterruptionHandling() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: audioSession
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange),
            name: AVAudioSession.routeChangeNotification,
            object: audioSession
        )
    }
    
    @objc private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            pauseMusic()
            print("🔇 Audio interrupted - pausing music")
            
        case .ended:
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) && isMusicEnabled {
                    resumeMusic()
                    print("🔊 Audio interruption ended - resuming music")
                }
            }
            
        @unknown default:
            break
        }
    }
    
    @objc private func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }
        
        switch reason {
        case .oldDeviceUnavailable:
            pauseMusic()
            print("🎧 Audio device disconnected - pausing music")
            
        default:
            break
        }
    }
    
    // MARK: - Music Playback Controls
    
    func playInterstellarTheme() {
        playMusic(track: .interstellarTheme)
    }
    
    func playMusic(track: AudioTrack, loop: Bool = true) {
        guard isMusicEnabled else { 
            print("🔇 Music disabled, not playing \(track.displayName)")
            return 
        }
        
        print("🎵 Attempting to play music track: \(track.displayName)")
        
        // Stop current music if playing
        stopMusic(fadeOut: false)
        
        // Find the audio file
        guard let audioURL = findAudioFile(named: track.rawValue) else {
            print("❌ Could not find audio file: \(track.rawValue)")
            audioFileStatus = "❌ Audio file not found: \(track.displayName)"
            
            // Try system sound as fallback
            playFallbackSystemSound()
            return
        }
        
        do {
            // Create and configure player
            backgroundPlayer = try AVAudioPlayer(contentsOf: audioURL)
            backgroundPlayer?.delegate = self
            backgroundPlayer?.volume = 0.0 // Start silent for fade-in
            backgroundPlayer?.numberOfLoops = loop ? -1 : 0
            backgroundPlayer?.prepareToPlay()
            
            print("🎼 Audio player created successfully for: \(track.displayName)")
            print("⏱️ Track duration: \(backgroundPlayer?.duration ?? 0) seconds")
            
            // Start playback
            let success = backgroundPlayer?.play() ?? false
            if success {
                currentTrack = track
                isPlaying = true
                trackDuration = backgroundPlayer?.duration ?? 0
                audioFileStatus = "🎵 Playing: \(track.displayName)"
                
                // Start position tracking
                startPositionTracking()
                
                // Fade in
                fadeVolume(to: musicVolume, duration: 2.0)
                
                print("✅ Started playing: \(track.displayName) at volume \(musicVolume)")
            } else {
                print("❌ Failed to start playback for: \(track.displayName)")
                audioFileStatus = "❌ Failed to play: \(track.displayName)"
            }
            
        } catch {
            print("❌ Error creating audio player: \(error.localizedDescription)")
            audioFileStatus = "❌ Error: \(error.localizedDescription)"
        }
    }
    
    private func playFallbackSystemSound() {
        print("🔔 Playing fallback system sound")
        AudioServicesPlaySystemSound(1016) // SMS received sound as musical fallback
        
        // Create a fake "playing" state for UI purposes
        currentTrack = .interstellarTheme
        isPlaying = true
        trackDuration = 3.0
        audioFileStatus = "🔔 Playing system sound (fallback)"
        
        // Auto-stop after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.isPlaying = false
            self.currentTrack = nil
            self.audioFileStatus = "🔕 System sound finished"
        }
    }
    
    func pauseMusic() {
        backgroundPlayer?.pause()
        isPlaying = false
        stopPositionTracking()
        audioFileStatus = "⏸️ Music paused"
        print("⏸️ Music paused")
    }
    
    func resumeMusic() {
        guard let player = backgroundPlayer else { return }
        let success = player.play()
        if success {
            isPlaying = true
            startPositionTracking()
            if let track = currentTrack {
                audioFileStatus = "🎵 Playing: \(track.displayName)"
            }
            print("▶️ Music resumed")
        }
    }
    
    func stopMusic(fadeOut: Bool = true) {
        if fadeOut && backgroundPlayer?.isPlaying == true {
            fadeVolume(to: 0.0, duration: 1.5) { [weak self] in
                self?.backgroundPlayer?.stop()
                self?.cleanupPlayer()
            }
        } else {
            backgroundPlayer?.stop()
            cleanupPlayer()
        }
    }
    
    private func cleanupPlayer() {
        backgroundPlayer = nil
        currentTrack = nil
        isPlaying = false
        playbackPosition = 0
        trackDuration = 0
        audioFileStatus = "⏹️ Music stopped"
        stopPositionTracking()
        print("⏹️ Music stopped")
    }
    
    // MARK: - Sound Effects
    
    func playSFX(_ sound: SFXSound) {
        guard isSFXEnabled else { return }
        
        // Try custom sound file first
        if let audioURL = findAudioFile(named: sound.rawValue) {
            playSFXFromFile(audioURL)
        } else {
            // Fallback to system sound
            playSystemSound(sound.systemSoundID)
        }
    }
    
    private func playSFXFromFile(_ url: URL) {
        do {
            sfxPlayer = try AVAudioPlayer(contentsOf: url)
            sfxPlayer?.volume = sfxVolume
            sfxPlayer?.play()
        } catch {
            print("❌ Error playing SFX: \(error.localizedDescription)")
        }
    }
    
    private func playSystemSound(_ soundID: SystemSoundID) {
        AudioServicesPlaySystemSound(soundID)
    }
    
    // MARK: - Volume Control
    
    private func fadeVolume(to targetVolume: Float, duration: TimeInterval, completion: (() -> Void)? = nil) {
        fadeTimer?.invalidate()
        
        guard let player = backgroundPlayer else {
            completion?()
            return
        }
        
        let steps = Int(duration * 20) // 20 steps per second
        let stepDuration = duration / Double(steps)
        let volumeStep = (targetVolume - player.volume) / Float(steps)
        
        var currentStep = 0
        
        fadeTimer = Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { [weak self] timer in
            guard let self = self, let player = self.backgroundPlayer else {
                timer.invalidate()
                completion?()
                return
            }
            
            if currentStep >= steps {
                player.volume = targetVolume
                timer.invalidate()
                completion?()
            } else {
                player.volume += volumeStep
                currentStep += 1
            }
        }
    }
    
    // MARK: - Playback Position Tracking
    
    private func startPositionTracking() {
        stopPositionTracking()
        
        positionTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.backgroundPlayer else { return }
            self.playbackPosition = player.currentTime
        }
    }
    
    private func stopPositionTracking() {
        positionTimer?.invalidate()
        positionTimer = nil
    }
    
    // MARK: - File Management
    
    private func findAudioFile(named fileName: String) -> URL? {
        print("🔍 Looking for audio file: \(fileName)")
        
        // Try different file extensions
        let extensions = ["mp3", "m4a", "wav", "caf", "aac"]
        
        // Try with extensions first
        for ext in extensions {
            if let url = Bundle.main.url(forResource: fileName, withExtension: ext) {
                print("✅ Found audio file: \(fileName).\(ext) at \(url.path)")
                return url
            }
        }
        
        // Try without extension (in case it's already included)
        if let url = Bundle.main.url(forResource: fileName, withExtension: nil) {
            print("✅ Found audio file: \(fileName) at \(url.path)")
            return url
        }
        
        // Check Audio subdirectory
        for ext in extensions {
            if let url = Bundle.main.url(forResource: fileName, withExtension: ext, subdirectory: "Audio") {
                print("✅ Found audio file in Audio/: \(fileName).\(ext) at \(url.path)")
                return url
            }
        }
        
        // Try in Audio subdirectory without extension
        if let url = Bundle.main.url(forResource: fileName, withExtension: nil, subdirectory: "Audio") {
            print("✅ Found audio file in Audio/: \(fileName) at \(url.path)")
            return url
        }
        
        print("❌ Audio file not found: \(fileName)")
        return nil
    }
    
    private func listAvailableAudioFiles() {
        print("🔍 === AUDIO FILE DIAGNOSTIC ===")
        
        guard let bundlePath = Bundle.main.resourcePath else { 
            print("❌ Could not get bundle resource path")
            return 
        }
        
        print("📁 Bundle path: \(bundlePath)")
        
        let fileManager = FileManager.default
        let audioExtensions = ["mp3", "m4a", "wav", "caf", "aac"]
        
        do {
            // Check main bundle
            let files = try fileManager.contentsOfDirectory(atPath: bundlePath)
            let audioFiles = files.filter { file in
                let ext = (file as NSString).pathExtension.lowercased()
                return audioExtensions.contains(ext)
            }
            
            print("🎵 Audio files in main bundle: \(audioFiles.isEmpty ? "NONE" : audioFiles.joined(separator: ", "))")
            
            // Check Audio subdirectory
            let audioPath = bundlePath + "/Audio"
            if fileManager.fileExists(atPath: audioPath) {
                let audioSubFiles = try fileManager.contentsOfDirectory(atPath: audioPath)
                let audioSubAudioFiles = audioSubFiles.filter { file in
                    let ext = (file as NSString).pathExtension.lowercased()
                    return audioExtensions.contains(ext)
                }
                print("🎵 Audio files in Audio/ subdirectory: \(audioSubAudioFiles.isEmpty ? "NONE" : audioSubAudioFiles.joined(separator: ", "))")
            } else {
                print("📁 Audio/ subdirectory does not exist")
            }
            
            // Show first 10 files in bundle for reference
            print("📋 Sample bundle contents:")
            for file in files.prefix(10) {
                print("  - \(file)")
            }
            if files.count > 10 {
                print("  ... and \(files.count - 10) more files")
            }
            
        } catch {
            print("❌ Error listing files: \(error)")
        }
        
        print("=== END DIAGNOSTIC ===")
    }
    
    // MARK: - User Preferences
    
    private func loadUserPreferences() {
        isMusicEnabled = UserDefaults.standard.object(forKey: "audio_music_enabled") as? Bool ?? true
        isSFXEnabled = UserDefaults.standard.object(forKey: "audio_sfx_enabled") as? Bool ?? true
        musicVolume = UserDefaults.standard.object(forKey: "audio_music_volume") as? Float ?? 0.6
        sfxVolume = UserDefaults.standard.object(forKey: "audio_sfx_volume") as? Float ?? 0.8
    }
    
    // MARK: - Public Convenience Methods
    
    func toggleMusic() {
        isMusicEnabled.toggle()
    }
    
    func toggleSFX() {
        isSFXEnabled.toggle()
    }
    
    func recheckAudioFiles() {
        checkAudioFiles()
    }
    
    // Quick SFX methods
    func playButtonTap() { playSFX(.buttonTap) }
    func playSuccess() { playSFX(.success) }
    func playError() { playSFX(.error) }
    func playNotification() { playSFX(.notification) }
    func playDeploy() { playSFX(.deploy) }
    func playAchievement() { playSFX(.achievement) }
}

// MARK: - AVAudioPlayerDelegate
extension AudioManager: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            if player == AudioManager.shared.backgroundPlayer && flag {
                print("🏁 Track finished playing")
                AudioManager.shared.cleanupPlayer()
            }
        }
    }
    
    nonisolated func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        Task { @MainActor in
            print("❌ Audio decode error: \(error?.localizedDescription ?? "Unknown error")")
            AudioManager.shared.audioFileStatus = "❌ Decode error: \(error?.localizedDescription ?? "Unknown")"
            AudioManager.shared.cleanupPlayer()
        }
    }
}

// MARK: - Enhanced Audio Control View
struct AudioControlView: View {
    @StateObject private var audioManager = AudioManager.shared
    @State private var showingDetailedControls = false
    @State private var showingDiagnostics = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Audio Status Indicator
            HStack {
                Circle()
                    .fill(audioManager.isPlaying ? .green : .red)
                    .frame(width: 8, height: 8)
                
                Text(audioManager.audioFileStatus)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Spacer()
                
                Button("Recheck Files") {
                    audioManager.recheckAudioFiles()
                    audioManager.playButtonTap()
                }
                .font(.caption2)
                .foregroundColor(.blue)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.ultraThinMaterial)
            )
            
            // Quick Controls
            HStack(spacing: 16) {
                // Music Toggle
                Button(action: {
                    audioManager.toggleMusic()
                    audioManager.playButtonTap()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: audioManager.isMusicEnabled ? "music.note" : "music.note.slash")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text(audioManager.isMusicEnabled ? "Music On" : "Music Off")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                    }
                    .foregroundColor(audioManager.isMusicEnabled ? .green : .gray)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Capsule()
                                    .stroke(audioManager.isMusicEnabled ? .green : .gray, lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
                
                // Play Interstellar Theme Button
                Button(action: {
                    print("🎵 Manual play button pressed")
                    audioManager.playInterstellarTheme()
                    audioManager.playButtonTap()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text(audioManager.isPlaying ? "Pause" : "Play")
                            .font(.caption.bold())
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Capsule()
                                    .stroke(.blue, lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
                
                // SFX Toggle
                Button(action: {
                    audioManager.toggleSFX()
                    audioManager.playButtonTap()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: audioManager.isSFXEnabled ? "speaker.2.fill" : "speaker.slash.fill")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text(audioManager.isSFXEnabled ? "SFX On" : "SFX Off")
                            .font(.caption.bold())
                    }
                    .foregroundColor(audioManager.isSFXEnabled ? .blue : .gray)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Capsule()
                                    .stroke(audioManager.isSFXEnabled ? .blue : .gray, lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
                
                // Detailed Controls Toggle
                Button(action: {
                    showingDetailedControls.toggle()
                    audioManager.playButtonTap()
                }) {
                    Image(systemName: showingDetailedControls ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Circle().fill(.ultraThinMaterial))
                }
                .buttonStyle(.plain)
            }
            
            // Detailed Controls
            if showingDetailedControls {
                VStack(spacing: 12) {
                    // Currently Playing
                    if let track = audioManager.currentTrack {
                        VStack(spacing: 8) {
                            HStack {
                                Text("Now Playing:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text(track.displayName)
                                    .font(.caption.bold())
                                    .foregroundColor(.white)
                            }
                            
                            // Progress Bar
                            if audioManager.trackDuration > 0 {
                                ProgressView(value: audioManager.playbackPosition, total: audioManager.trackDuration)
                                    .tint(.blue)
                            }
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.ultraThinMaterial)
                        )
                    }
                    
                    // Volume Controls
                    VStack(spacing: 8) {
                        HStack {
                            Text("Music Volume")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("\(Int(audioManager.musicVolume * 100))%")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                        }
                        
                        Slider(value: $audioManager.musicVolume, in: 0...1)
                            .tint(.green)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.ultraThinMaterial)
                    )
                    
                    // Diagnostics Button
                    Button("Show Audio Diagnostics") {
                        showingDiagnostics.toggle()
                        audioManager.playButtonTap()
                    }
                    .font(.caption)
                    .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
        )
        .alert("Audio Setup Required", isPresented: $showingDiagnostics) {
            Button("OK") { }
        } message: {
            Text("""
            To add the interstellar_theme.mp3 file:
            
            1. Open Xcode
            2. Right-click project → "Add Files"
            3. Select your interstellar_theme.mp3
            4. Check "Add to target"
            5. Click "Add"
            
            Or drag the file from Finder into Xcode.
            """)
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 24) {
            Text("Enhanced Audio Controls")
                .font(.title2.bold())
                .foregroundColor(.white)
            
            AudioControlView()
        }
        .padding()
    }
}
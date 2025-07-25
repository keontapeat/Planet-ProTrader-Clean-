//
//  AudioManager.swift
//  Planet ProTrader - FIXED Audio System
//
//  Professional background music and sound effects manager
//  Created by AI Assistant on 1/25/25.
//

import AVFoundation
import SwiftUI
import Combine

// MARK: - FIXED Enhanced Audio Manager
@MainActor
class AudioManager: NSObject, ObservableObject {
    static let shared = AudioManager()
    
    // MARK: - Published Properties
    @Published var isMusicEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(isMusicEnabled, forKey: "audio_music_enabled")
            Task {
                if isMusicEnabled && currentTrack == nil {
                    await playInterstellarTheme()
                } else if !isMusicEnabled {
                    stopMusic()
                }
            }
        }
    }
    
    @Published var isSFXEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(isSFXEnabled, forKey: "audio_sfx_enabled")
        }
    }
    
    @Published var musicVolume: Float = 0.8 {
        didSet {
            UserDefaults.standard.set(musicVolume, forKey: "audio_music_volume")
            backgroundPlayer?.volume = musicVolume
            print("🔊 Volume set to: \(Int(musicVolume * 100))%")
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
    @Published var audioFileStatus: String = "🎵 Audio ready"
    
    // MARK: - Private Properties
    private var backgroundPlayer: AVAudioPlayer?
    private var sfxPlayer: AVAudioPlayer?
    private var fadeTimer: Timer?
    private var positionTimer: Timer?
    private var audioSession = AVAudioSession.sharedInstance()
    private var isAudioSessionConfigured = false
    
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
            case .buttonTap: return 1104
            case .success: return 1322
            case .error: return 1107
            case .notification: return 1315
            case .deploy: return 1322
            case .achievement: return 1315
            }
        }
    }
    
    private override init() {
        super.init()
        loadUserPreferences()
        
        // FIXED: Setup audio session immediately and synchronously
        setupAudioSessionSync()
        setupInterruptionHandling()
        
        audioFileStatus = "🎵 Audio system initialized"
        print("🚀 AudioManager initialized - ready to play music!")
    }
    
    // MARK: - FIXED Audio Session Configuration (Synchronous)
    private func setupAudioSessionSync() {
        do {
            // FIXED: Use .playback category for background music
            try audioSession.setCategory(
                .playback,
                mode: .default,
                options: [.allowAirPlay, .allowBluetooth]
            )
            
            try audioSession.setPreferredSampleRate(44100.0)
            try audioSession.setActive(true)
            isAudioSessionConfigured = true
            
            print("✅ Audio session configured for background playback")
            audioFileStatus = "✅ Audio session active"
            
        } catch {
            print("❌ Failed to configure audio session: \(error.localizedDescription)")
            audioFileStatus = "⚠️ Audio session setup failed"
            isAudioSessionConfigured = false
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
                    Task { await resumeMusic() }
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
    
    // MARK: - FIXED Music Playback Controls
    
    func playInterstellarTheme() async {
        await playMusic(track: .interstellarTheme)
    }
    
    func playMusic(track: AudioTrack, loop: Bool = true) async {
        guard isMusicEnabled else { 
            print("🔇 Music disabled, not playing \(track.displayName)")
            audioFileStatus = "🔇 Music disabled"
            return 
        }
        
        if !isAudioSessionConfigured {
            print("⚠️ Audio session not configured, setting up now...")
            setupAudioSessionSync()
            if !isAudioSessionConfigured {
                audioFileStatus = "❌ Audio session failed"
                return
            }
        }
        
        print("🎵 Playing music track: \(track.displayName)")
        
        // Stop current music if playing
        stopMusic(fadeOut: false)
        
        // FIXED: Find the audio file with corrected path logic
        guard let audioURL = findAudioFileFixed(named: track.rawValue) else {
            print("❌ Could not find audio file: \(track.rawValue)")
            audioFileStatus = "⚠️ Missing: \(track.displayName).mp3"
            return
        }
        
        do {
            // Create and configure player
            backgroundPlayer = try AVAudioPlayer(contentsOf: audioURL)
            backgroundPlayer?.delegate = self
            backgroundPlayer?.volume = musicVolume
            backgroundPlayer?.numberOfLoops = loop ? -1 : 0
            backgroundPlayer?.prepareToPlay()
            
            print("🎼 Audio player created for: \(track.displayName)")
            print("⏱️ Track duration: \(backgroundPlayer?.duration ?? 0) seconds")
            print("📁 Playing from: \(audioURL.path)")
            
            // Start playback
            let success = backgroundPlayer?.play() ?? false
            if success {
                currentTrack = track
                isPlaying = true
                trackDuration = backgroundPlayer?.duration ?? 0
                audioFileStatus = "🎵 Playing: \(track.displayName)"
                
                // Start position tracking
                startPositionTracking()
                
                print("✅ Successfully started playing: \(track.displayName)")
                
            } else {
                print("❌ Failed to start playback for: \(track.displayName)")
                audioFileStatus = "❌ Playback failed: \(track.displayName)"
                cleanupPlayer()
            }
            
        } catch {
            print("❌ Error creating audio player: \(error.localizedDescription)")
            audioFileStatus = "❌ Audio error: \(getErrorDescription(error))"
            cleanupPlayer()
        }
    }
    
    // FIXED: Corrected file finding logic
    private func findAudioFileFixed(named fileName: String) -> URL? {
        print("🔍 Looking for audio file: \(fileName)")
        
        // FIXED: Try M4A first since that's what the file actually is
        let searchOptions: [(String?, String?, String?)] = [
            // Check for M4A format first (the actual file format)
            (fileName, "m4a", nil),
            (fileName, "m4a", "Audio "),
            (fileName, "m4a", "Audio"),
            
            // Then try other formats
            (fileName, "mp3", nil),
            (fileName, "wav", nil),
            (fileName, "caf", nil),
            (fileName, nil, nil),
            
            // FIXED: Check in "Audio " subdirectory (note the space in folder name)
            (fileName, "mp3", "Audio "),
            (fileName, "wav", "Audio "),
            (fileName, nil, "Audio "),
            
            // Also try without space in case folder was renamed
            (fileName, "mp3", "Audio"),
            (fileName, "wav", "Audio"),
            (fileName, nil, "Audio")
        ]
        
        for (resourceName, fileExtension, subdirectory) in searchOptions {
            let url: URL?
            if let subdirectory = subdirectory {
                url = Bundle.main.url(forResource: resourceName, withExtension: fileExtension, subdirectory: subdirectory)
            } else {
                url = Bundle.main.url(forResource: resourceName, withExtension: fileExtension)
            }
            
            if let foundURL = url {
                // Verify file exists and is readable
                if FileManager.default.fileExists(atPath: foundURL.path) {
                    print("✅ Found audio file: \(foundURL.lastPathComponent)")
                    print("📁 Full path: \(foundURL.path)")
                    
                    // Check file size to ensure it's valid
                    do {
                        let attributes = try FileManager.default.attributesOfItem(atPath: foundURL.path)
                        if let fileSize = attributes[.size] as? Int64 {
                            print("📊 File size: \(fileSize) bytes")
                            if fileSize > 1000 { // At least 1KB
                                return foundURL
                            } else {
                                print("⚠️ File too small, might be corrupted")
                            }
                        }
                    } catch {
                        print("⚠️ Could not check file attributes: \(error)")
                        return foundURL // Still try to use it
                    }
                } else {
                    print("❌ File exists in bundle but not accessible: \(foundURL.path)")
                }
            }
        }
        
        print("❌ Audio file not found: \(fileName)")
        print("💡 Ensure \(fileName).mp3 is added to your Xcode project bundle")
        return nil
    }
    
    private func getErrorDescription(_ error: Error) -> String {
        if let audioError = error as? AVError {
            switch audioError.code {
            case .fileFormatNotRecognized:
                return "Invalid file format"
            case .decoderNotFound:
                return "Audio decoder not found"
            case .decoderTemporarilyUnavailable:
                return "Audio decoder unavailable"
            default:
                return "Audio system error"
            }
        }
        return "Unknown error"
    }
    
    func pauseMusic() {
        backgroundPlayer?.pause()
        isPlaying = false
        stopPositionTracking()
        audioFileStatus = "⏸️ Music paused"
        print("⏸️ Music paused")
    }
    
    func resumeMusic() async {
        guard let player = backgroundPlayer else { 
            // If no player, restart music
            if isMusicEnabled {
                await playInterstellarTheme()
            }
            return 
        }
        
        let success = player.play()
        if success {
            isPlaying = true
            startPositionTracking()
            player.volume = musicVolume
            if let track = currentTrack {
                audioFileStatus = "🎵 Playing: \(track.displayName)"
            }
            print("▶️ Music resumed at volume: \(Int(musicVolume * 100))%")
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
        print("⏹️ Music stopped and cleaned up")
    }
    
    // MARK: - Sound Effects (Simplified)
    
    func playSFX(_ sound: SFXSound) {
        guard isSFXEnabled else { return }
        
        // Try custom sound file first
        if let audioURL = findAudioFileFixed(named: sound.rawValue) {
            playSFXFromFile(audioURL)
        } else {
            // Fallback to system sound
            AudioServicesPlaySystemSound(sound.systemSoundID)
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
    
    // MARK: - Volume Control
    
    private func fadeVolume(to targetVolume: Float, duration: TimeInterval, completion: (() -> Void)? = nil) {
        fadeTimer?.invalidate()
        
        guard let player = backgroundPlayer else {
            completion?()
            return
        }
        
        let steps = Int(duration * 20)
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
    
    // MARK: - User Preferences
    
    private func loadUserPreferences() {
        isMusicEnabled = UserDefaults.standard.object(forKey: "audio_music_enabled") as? Bool ?? true
        isSFXEnabled = UserDefaults.standard.object(forKey: "audio_sfx_enabled") as? Bool ?? true
        musicVolume = UserDefaults.standard.object(forKey: "audio_music_volume") as? Float ?? 0.8
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
        audioFileStatus = "🔍 Checking audio files..."
        
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second
            
            if findAudioFileFixed(named: "interstellar_theme") != nil {
                audioFileStatus = "✅ Audio files found"
            } else {
                audioFileStatus = "⚠️ Add interstellar_theme.mp3 to project"
            }
        }
    }
    
    // FIXED: Test method that actually works
    func forceTestAudio() async {
        print("🎵 FORCE TEST: Testing audio system...")
        audioFileStatus = "🔊 Testing audio..."
        
        // First test system sound
        AudioServicesPlaySystemSound(1322)
        
        // Wait and then try actual music
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        if isMusicEnabled {
            await playInterstellarTheme()
        } else {
            audioFileStatus = "🔊 Audio test complete - enable music to play theme"
        }
    }
    
    // Quick SFX methods
    func playButtonTap() async { 
        guard isSFXEnabled else { return }
        playSFX(.buttonTap) 
    }
    
    func playSuccess() async { 
        guard isSFXEnabled else { return }
        playSFX(.success) 
    }
    
    func playError() async { 
        guard isSFXEnabled else { return }
        playSFX(.error) 
    }
    
    func playNotification() async { 
        guard isSFXEnabled else { return }
        playSFX(.notification) 
    }
    
    func playDeploy() async { 
        guard isSFXEnabled else { return }
        playSFX(.deploy) 
    }
    
    func playAchievement() async { 
        guard isSFXEnabled else { return }
        playSFX(.achievement) 
    }
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
            AudioManager.shared.audioFileStatus = "❌ Decode error"
            AudioManager.shared.cleanupPlayer()
        }
    }
}

// MARK: - Enhanced Audio Control View
struct AudioControlView: View {
    @StateObject private var audioManager = AudioManager.shared
    @State private var showingDetailedControls = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Audio Status Indicator
            HStack {
                Circle()
                    .fill(audioManager.isPlaying ? .green : .orange)
                    .frame(width: 8, height: 8)
                
                Text(audioManager.audioFileStatus)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Spacer()
                
                Button("Test") {
                    Task {
                        await audioManager.forceTestAudio()
                    }
                }
                .font(.caption2)
                .foregroundColor(.cyan)
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
                    Task { await audioManager.playButtonTap() }
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
                
                // Play/Pause Button
                Button(action: {
                    Task {
                        if audioManager.isPlaying {
                            audioManager.pauseMusic()
                        } else {
                            await audioManager.playInterstellarTheme()
                        }
                        await audioManager.playButtonTap()
                    }
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
                
                // Volume Up Quick Button
                Button(action: {
                    audioManager.musicVolume = min(1.0, audioManager.musicVolume + 0.2)
                    Task { await audioManager.playButtonTap() }
                }) {
                    Image(systemName: "speaker.plus.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.orange)
                        .padding(8)
                        .background(Circle().fill(.ultraThinMaterial))
                }
                .buttonStyle(.plain)
            }
            
            // Volume Display
            if audioManager.isMusicEnabled {
                HStack {
                    Text("Volume: \(Int(audioManager.musicVolume * 100))%")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Slider(value: $audioManager.musicVolume, in: 0...1)
                        .tint(.orange)
                        .frame(width: 100)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.ultraThinMaterial)
                )
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
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 24) {
            Text("FIXED Audio Controls")
                .font(.title2.bold())
                .foregroundColor(.white)
            
            AudioControlView()
        }
        .padding()
    }
}
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
            case .buttonTap: return 1104 // Simple click
            case .success: return 1322 // Camera capture - clean
            case .error: return 1107 // Simple error beep  
            case .notification: return 1315 // Mail sent - clean
            case .deploy: return 1322 // Camera capture
            case .achievement: return 1315 // Mail sent
            }
        }
    }
    
    private override init() {
        super.init()
        loadUserPreferences()
        setupAudioSession()
        setupInterruptionHandling()
        
        audioFileStatus = "🎵 Audio system ready"
        print("🚀 AudioManager initialized with volume: \(Int(musicVolume * 100))%")
    }
    
    // MARK: - Audio Session Configuration
    private func setupAudioSession() {
        do {
            try audioSession.setCategory(
                .playback,
                mode: .default,
                options: [.duckOthers] // Lower other audio when playing
            )
            
            try audioSession.setPreferredSampleRate(44100.0)
            try audioSession.setActive(true)
            
            print("✅ Audio session configured for playback")
            
        } catch {
            print("❌ Failed to configure audio session: \(error.localizedDescription)")
            audioFileStatus = "⚠️ Audio session setup failed"
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
            audioFileStatus = "🔇 Music disabled"
            return 
        }
        
        print("🎵 Attempting to play music track: \(track.displayName)")
        
        // Stop current music if playing
        stopMusic(fadeOut: false)
        
        // Find the audio file with better error handling
        guard let audioURL = findAudioFile(named: track.rawValue) else {
            print("❌ Could not find audio file: \(track.rawValue)")
            audioFileStatus = "⚠️ Missing: \(track.displayName).mp3"
            
            // Try to play system sound as elegant fallback
            playMusicalSystemSound()
            return
        }
        
        do {
            // Create and configure player
            backgroundPlayer = try AVAudioPlayer(contentsOf: audioURL)
            backgroundPlayer?.delegate = self
            backgroundPlayer?.volume = musicVolume // Start at full volume
            backgroundPlayer?.numberOfLoops = loop ? -1 : 0
            backgroundPlayer?.prepareToPlay()
            
            print("🎼 Audio player created successfully for: \(track.displayName)")
            print("⏱️ Track duration: \(backgroundPlayer?.duration ?? 0) seconds")
            print("🔊 Starting playback at volume: \(Int(musicVolume * 100))%")
            
            // Start playback
            let success = backgroundPlayer?.play() ?? false
            if success {
                currentTrack = track
                isPlaying = true
                trackDuration = backgroundPlayer?.duration ?? 0
                audioFileStatus = "🎵 Playing: \(track.displayName) at \(Int(musicVolume * 100))%"
                
                // Start position tracking
                startPositionTracking()
                
                // Ensure volume is audible
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.backgroundPlayer?.volume = self.musicVolume
                    print("🔊 Volume confirmed at: \(Int(self.musicVolume * 100))%")
                }
                
                print("✅ Started playing: \(track.displayName)")
                
                // Test if audio is actually working
                testAudioOutput()
                
            } else {
                print("❌ Failed to start playback for: \(track.displayName)")
                audioFileStatus = "❌ Playback failed: \(track.displayName)"
                playMusicalSystemSound()
            }
            
        } catch {
            print("❌ Error creating audio player: \(error.localizedDescription)")
            audioFileStatus = "❌ Audio error: \(getErrorDescription(error))"
            
            // Fallback to system sound
            playMusicalSystemSound()
        }
    }
    
    private func testAudioOutput() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let player = self.backgroundPlayer, player.isPlaying {
                print("✅ Audio confirmed playing - current time: \(player.currentTime)")
                
                // Check device volume
                let volume = AVAudioSession.sharedInstance().outputVolume
                if volume == 0 {
                    self.audioFileStatus = "🔇 Device volume is muted! Use volume buttons"
                    print("⚠️ Device volume is muted!")
                }
            } else {
                print("❌ Audio not playing - falling back to system sound")
                self.playMusicalSystemSound()
            }
        }
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
    
    private func playMusicalSystemSound() {
        print("🎶 Playing musical system sound as fallback")
        
        // Play ONE clean system sound instead of looping sequence
        AudioServicesPlaySystemSound(1322) // Camera capture - clean single sound
        
        // Create a fake "playing" state for UI consistency
        currentTrack = .interstellarTheme
        isPlaying = true
        trackDuration = 2.0
        audioFileStatus = "🎶 System sound mode (add MP3 for full audio)"
        
        // Start position tracking for UI
        startPositionTracking()
        
        // Stop after 2 seconds - NO MORE LOOPING
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isPlaying = false
            self.currentTrack = nil
            self.audioFileStatus = "🔔 Add interstellar_theme.mp3 to hear full audio"
            self.stopPositionTracking()
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
        guard let player = backgroundPlayer else { 
            // If no player, restart music
            if isMusicEnabled {
                playInterstellarTheme()
            }
            return 
        }
        
        let success = player.play()
        if success {
            isPlaying = true
            startPositionTracking()
            player.volume = musicVolume // Ensure volume is set
            if let track = currentTrack {
                audioFileStatus = "🎵 Playing: \(track.displayName) at \(Int(musicVolume * 100))%"
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
        // Only play if SFX is enabled - single sound only
        guard isSFXEnabled else { return }
        
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
            guard let self = self else { return }
            
            if let player = self.backgroundPlayer {
                self.playbackPosition = player.currentTime
            } else if self.currentTrack != nil && self.isPlaying {
                // For system sound mode, simulate progress
                self.playbackPosition = min(self.playbackPosition + 0.1, self.trackDuration)
            }
        }
    }
    
    private func stopPositionTracking() {
        positionTimer?.invalidate()
        positionTimer = nil
    }
    
    // MARK: - File Management
    
    private func findAudioFile(named fileName: String) -> URL? {
        print("🔍 Looking for audio file: \(fileName)")
        
        // Try different file extensions and locations
        let searchOptions: [(String?, String?)] = [
            // Main bundle root
            (fileName, "mp3"),
            (fileName, "m4a"),
            (fileName, "wav"),
            (fileName, "caf"),
            (fileName, nil),
            // Audio subdirectory
            ("Audio/\(fileName)", "mp3"),
            ("Audio/\(fileName)", "m4a"),
            ("Audio/\(fileName)", nil)
        ]
        
        for (resourceName, fileExtension) in searchOptions {
            if let url = Bundle.main.url(forResource: resourceName, withExtension: fileExtension) {
                print("✅ Found audio file: \(url.lastPathComponent) at \(url.path)")
                
                // Verify file exists and is readable
                if FileManager.default.fileExists(atPath: url.path) {
                    print("✅ File verified as accessible")
                    return url
                } else {
                    print("❌ File exists in bundle but not accessible")
                }
            }
        }
        
        print("❌ Audio file not found: \(fileName)")
        return nil
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if self.findAudioFile(named: "interstellar_theme") != nil {
                self.audioFileStatus = "✅ Audio files found"
            } else {
                self.audioFileStatus = "⚠️ Add interstellar_theme.mp3 to Xcode project"
            }
        }
    }
    
    // Test method to force play audio - FIXED TO NOT LOOP
    func forceTestAudio() {
        print("🎵 FORCE TEST: Playing test sound...")
        audioFileStatus = "🔊 Testing audio output..."
        
        // Play ONE test sound
        AudioServicesPlaySystemSound(1322) // Camera sound
        
        // Update status after test
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if self.isMusicEnabled {
                self.playInterstellarTheme()
            } else {
                self.audioFileStatus = "🔊 Audio test complete"
            }
        }
    }
    
    // Quick SFX methods with cleaner implementation
    func playButtonTap() { 
        guard isSFXEnabled else { return }
        playSFX(.buttonTap) 
    }
    
    func playSuccess() { 
        guard isSFXEnabled else { return }
        playSFX(.success) 
    }
    
    func playError() { 
        guard isSFXEnabled else { return }
        playSFX(.error) 
    }
    
    func playNotification() { 
        guard isSFXEnabled else { return }
        playSFX(.notification) 
    }
    
    func playDeploy() { 
        guard isSFXEnabled else { return }
        playSFX(.deploy) 
    }
    
    func playAchievement() { 
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
            AudioManager.shared.audioFileStatus = "❌ Decode error: \(AudioManager.shared.getErrorDescription(error ?? NSError()))"
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
                    .fill(audioManager.isPlaying ? .green : .orange)
                    .frame(width: 8, height: 8)
                
                Text(audioManager.audioFileStatus)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Spacer()
                
                Button("Force Test") {
                    audioManager.forceTestAudio()
                }
                .font(.caption2)
                .foregroundColor(.red)
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
                
                // Play/Pause Button
                Button(action: {
                    if audioManager.isPlaying {
                        audioManager.pauseMusic()
                    } else {
                        audioManager.playInterstellarTheme()
                    }
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
                
                // Volume Up Quick Button
                Button(action: {
                    audioManager.musicVolume = min(1.0, audioManager.musicVolume + 0.2)
                    audioManager.playButtonTap()
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
            Text("Enhanced Audio Controls")
                .font(.title2.bold())
                .foregroundColor(.white)
            
            AudioControlView()
        }
        .padding()
    }
}
import AVFoundation
import AudioToolbox
import SwiftUI

class BackgroundAudioPlayer: ObservableObject {
    static let shared = BackgroundAudioPlayer()
    private var player: AVAudioPlayer?
    private var fadeTimer: Timer?

    func play(sound: String, volume: Float = 0.82, loop: Bool = true) {
        stop() // stop previous if needed
        
        // Debug: Print the file we're looking for
        print("🎵 BackgroundAudioPlayer looking for: \(sound)")
        
        // Try to find the audio file
        guard let url = findAudioFileURL(named: sound) else {
            print("❌ BackgroundAudioPlayer: Audio file not found - \(sound)")
            print("📋 This means the audio file isn't added to the Xcode project bundle.")
            print("💡 Solution: Add \(sound).mp3 to your Xcode project")
            
            // Play a system sound as fallback
            AudioServicesPlaySystemSound(1016) // SMS sound as musical fallback
            return
        }
        
        playAudio(from: url, volume: volume, loop: loop)
    }
    
    private func findAudioFileURL(named fileName: String) -> URL? {
        // Try different extensions without subdirectory first
        let basicOptions: [(String, String?)] = [
            (fileName, "mp3"),
            (fileName, "m4a"),
            (fileName, "wav"),
            (fileName, "caf"),
            (fileName, "aac"),
            (fileName, nil)
        ]
        
        // Check basic options first
        for (name, ext) in basicOptions {
            if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                print("✅ Found audio file: \(url.lastPathComponent) at \(url.path)")
                return url
            }
        }
        
        // Try with subdirectory
        let subdirectoryOptions: [(String, String?, String)] = [
            (fileName, "mp3", "Audio"),
            (fileName, "m4a", "Audio"),
            (fileName, "wav", "Audio"),
            (fileName, nil, "Audio")
        ]
        
        for (name, ext, subdir) in subdirectoryOptions {
            if let url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: subdir) {
                print("✅ Found audio file: \(url.lastPathComponent) at \(url.path)")
                return url
            }
        }
        
        return nil
    }
    
    private func playAudio(from url: URL, volume: Float, loop: Bool) {
        do {
            // Configure audio session for background playback
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url)
            player?.volume = 0 // begin silent for fade-in
            player?.numberOfLoops = loop ? -1 : 0
            player?.prepareToPlay()
            
            let success = player?.play() ?? false
            if success {
                print("✅ BackgroundAudioPlayer: Audio started playing successfully")
                print("⏱️ Duration: \(player?.duration ?? 0) seconds")
                // Fade in
                fade(to: volume, duration: 1.5)
            } else {
                print("❌ BackgroundAudioPlayer: Failed to start audio playback")
            }
        } catch {
            print("❌ BackgroundAudioPlayer error: \(error.localizedDescription)")
        }
    }

    func stop(fadeOut: Bool = true) {
        guard let player = player else { return }
        fadeTimer?.invalidate()
        if fadeOut {
            fade(to: 0, duration: 1.2) { [weak self] in
                self?.player?.stop()
                self?.player = nil
                print("⏹️ BackgroundAudioPlayer: Stopped with fade out")
            }
        } else {
            player.stop()
            self.player = nil
            print("⏹️ BackgroundAudioPlayer: Stopped immediately")
        }
    }

    private func fade(to targetVolume: Float, duration: TimeInterval, completion: (() -> Void)? = nil) {
        fadeTimer?.invalidate()
        guard let player = player else { 
            completion?()
            return 
        }
        
        let steps = 30 // More steps for smoother fade
        let stepDuration = duration / Double(steps)
        let volumeStep = (targetVolume - player.volume) / Float(steps)
        var currentStep = 0

        fadeTimer = Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { [weak self] timer in
            guard let self = self, let player = self.player else { 
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
    
    // Public method to check if audio is playing
    var isPlaying: Bool {
        return player?.isPlaying ?? false
    }
    
    // Public method to get current volume
    var currentVolume: Float {
        return player?.volume ?? 0.0
    }
    
    // Public method to set volume
    func setVolume(_ volume: Float) {
        player?.volume = volume
    }
}

// ENHANCED BUTTON SOUND FX PLAYER
class ButtonSFXPlayer {
    static func play() {
        // Use a more pleasant system sound
        AudioServicesPlaySystemSound(1104) // Modern click sound
    }
    
    static func playSuccess() {
        AudioServicesPlaySystemSound(1016) // SMS received
    }
    
    static func playError() {
        AudioServicesPlaySystemSound(1053) // Popcorn
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("Background Audio Player")
            .font(.title)
            .fontWeight(.bold)
        
        Button("Play Test Sound") {
            BackgroundAudioPlayer.shared.play(sound: "test_audio")
        }
        .padding()
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(10)
        
        Button("Stop Audio") {
            BackgroundAudioPlayer.shared.stop()
        }
        .padding()
        .background(Color.red)
        .foregroundColor(.white)
        .cornerRadius(10)
        
        Button("Button SFX") {
            ButtonSFXPlayer.play()
        }
        .padding()
        .background(Color.green)
        .foregroundColor(.white)
        .cornerRadius(10)
    }
    .padding()
}
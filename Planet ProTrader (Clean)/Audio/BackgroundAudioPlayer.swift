import AVFoundation
import AudioToolbox

class BackgroundAudioPlayer: ObservableObject {
    static let shared = BackgroundAudioPlayer()
    private var player: AVAudioPlayer?
    private var fadeTimer: Timer?

    func play(sound: String, volume: Float = 0.82, loop: Bool = true) {
        stop() // stop previous if needed
        
        // Debug: Print the file we're looking for
        print("🎵 Looking for audio file: \(sound)")
        
        // Try multiple variations of the filename
        let possibleNames = [
            sound, // exact name as provided
            "interstellar_theme", // without extension
            "interstellar_theme.mp3", // with .mp3
            "interstellar_theme.m4a", // with .m4a
            "interstellar_theme.wav", // with .wav
            "interstellar_theme.caf" // with .caf
        ]
        
        var foundURL: URL?
        
        for fileName in possibleNames {
            if let url = Bundle.main.url(forResource: fileName, withExtension: nil) {
                foundURL = url
                print("✅ Found audio file: \(fileName) at \(url)")
                break
            } else if fileName.contains(".") {
                // If filename has extension, try splitting it
                let components = fileName.components(separatedBy: ".")
                if components.count == 2 {
                    if let url = Bundle.main.url(forResource: components[0], withExtension: components[1]) {
                        foundURL = url
                        print("✅ Found audio file: \(components[0]).\(components[1]) at \(url)")
                        break
                    }
                }
            }
        }
        
        guard let url = foundURL else {
            print("❌ Audio file not found. Tried: \(possibleNames)")
            print("📁 Listing all audio files in bundle:")
            listAudioFiles()
            return
        }
        
        playAudio(from: url, volume: volume, loop: loop)
    }
    
    private func listAudioFiles() {
        guard let bundlePath = Bundle.main.resourcePath else {
            print("❌ Could not get bundle path")
            return
        }
        
        let fileManager = FileManager.default
        do {
            let files = try fileManager.contentsOfDirectory(atPath: bundlePath)
            let audioFiles = files.filter { file in
                let ext = (file as NSString).pathExtension.lowercased()
                return ["mp3", "wav", "m4a", "aac", "caf"].contains(ext)
            }
            print("🎵 Available audio files: \(audioFiles)")
            
            // Also check subdirectories
            for file in files {
                let fullPath = bundlePath + "/" + file
                var isDirectory: ObjCBool = false
                if fileManager.fileExists(atPath: fullPath, isDirectory: &isDirectory) && isDirectory.boolValue {
                    do {
                        let subFiles = try fileManager.contentsOfDirectory(atPath: fullPath)
                        let subAudioFiles = subFiles.filter { subFile in
                            let ext = (subFile as NSString).pathExtension.lowercased()
                            return ["mp3", "wav", "m4a", "aac", "caf"].contains(ext)
                        }
                        if !subAudioFiles.isEmpty {
                            print("🎵 Audio files in \(file)/: \(subAudioFiles)")
                        }
                    } catch {
                        print("❌ Error reading directory \(file): \(error)")
                    }
                }
            }
        } catch {
            print("❌ Error listing files: \(error)")
        }
    }
    
    private func playAudio(from url: URL, volume: Float, loop: Bool) {
        do {
            // Configure audio session for background playback
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url)
            player?.volume = 0 // begin silent for fade-in
            player?.numberOfLoops = loop ? -1 : 0
            player?.prepareToPlay()
            
            let success = player?.play() ?? false
            if success {
                print("✅ Audio started playing successfully")
                // Fade in
                fade(to: volume, duration: 1)
            } else {
                print("❌ Failed to start audio playback")
            }
        } catch {
            print("❌ Error playing audio: \(error.localizedDescription)")
        }
    }

    func stop(fadeOut: Bool = true) {
        guard let player = player else { return }
        fadeTimer?.invalidate()
        if fadeOut {
            fade(to: 0, duration: 1.2) { [weak self] in
                self?.player?.stop()
                self?.player = nil
            }
        } else {
            player.stop()
            self.player = nil
        }
    }

    private func fade(to targetVolume: Float, duration: TimeInterval, completion: (() -> Void)? = nil) {
        fadeTimer?.invalidate()
        guard let player = player else { completion?(); return }
        let steps = 24
        let delta = (targetVolume - player.volume) / Float(steps)
        var currentStep = 0

        fadeTimer = Timer.scheduledTimer(withTimeInterval: duration / Double(steps), repeats: true) { [weak self] timer in
            guard let self = self, let player = self.player else { timer.invalidate(); completion?(); return }
            if currentStep >= steps {
                player.volume = targetVolume
                timer.invalidate()
                completion?()
            } else {
                player.volume += delta
                currentStep += 1
            }
        }
    }
    
    // Public method to check if audio is playing
    var isPlaying: Bool {
        return player?.isPlaying ?? false
    }
}

// BUTTON SOUND FX PLAYER
class ButtonSFXPlayer {
    static func play() {
        // Create a simple beep sound programmatically if no sound file
        AudioServicesPlaySystemSound(1104) // Modern pop sound
    }
}
import AVFoundation

class BackgroundAudioPlayer: ObservableObject {
    static let shared = BackgroundAudioPlayer()
    private var player: AVAudioPlayer?
    private var fadeTimer: Timer?

    func play(sound: String, volume: Float = 0.82, loop: Bool = true) {
        stop() // stop previous if needed
        
        // Debug: Print the file we're looking for
        print("🎵 Looking for audio file: \(sound)")
        
        guard let url = Bundle.main.url(forResource: sound, withExtension: nil) else {
            print("❌ Audio file \(sound) not found in bundle")
            
            // Let's try without extension
            if let urlWithoutExt = Bundle.main.url(forResource: String(sound.dropLast(4)), withExtension: "mp3") {
                print("✅ Found file without extension: \(String(sound.dropLast(4)))")
                playAudio(from: urlWithoutExt, volume: volume, loop: loop)
            } else {
                print("❌ Still not found. Available audio files:")
                if let bundlePath = Bundle.main.resourcePath {
                    let fileManager = FileManager.default
                    if let files = try? fileManager.contentsOfDirectory(atPath: bundlePath) {
                        let audioFiles = files.filter { $0.hasSuffix(".mp3") || $0.hasSuffix(".wav") || $0.hasSuffix(".m4a") }
                        print("📁 Available audio files: \(audioFiles)")
                    }
                }
            }
            return
        }
        
        print("✅ Found audio file at: \(url)")
        playAudio(from: url, volume: volume, loop: loop)
    }
    
    private func playAudio(from url: URL, volume: Float, loop: Bool) {
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.volume = 0 // begin silent for fade-in
            player?.numberOfLoops = loop ? -1 : 0
            player?.play()
            print("✅ Audio started playing successfully")
            // Fade in
            fade(to: volume, duration: 1)
        } catch {
            print("❌ Error playing audio: \(error)")
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
}

// BUTTON SOUND FX PLAYER
class ButtonSFXPlayer {
    static func play() {
        guard let url = Bundle.main.url(forResource: "swoosh_fx.mp3", withExtension: nil) else { return }
        var sfxPlayer: AVAudioPlayer?
        do {
            sfxPlayer = try AVAudioPlayer(contentsOf: url)
            sfxPlayer?.volume = 0.95
            sfxPlayer?.play()
            // let go, will deallocate itself
        } catch { }
    }
}
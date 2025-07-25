//
//  SimpleAudioTest.swift
//  Planet ProTrader - Simple Audio Test
//
//  Direct audio testing without complex dependencies
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI
import AVFoundation
import AudioToolbox

// MARK: - Simple Working Audio Test
struct SimpleAudioTest: View {
    @State private var status = "Ready to test audio"
    @State private var isPlaying = false
    @State private var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("🎵 Simple Audio Test")
                    .font(.title.bold())
                    .foregroundColor(.white)
                
                Text(status)
                    .font(.headline)
                    .foregroundColor(.green)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                
                VStack(spacing: 20) {
                    Button("🔊 Test System Sound") {
                        testSystemSound()
                    }
                    .buttonStyle(TestButtonStyle(color: .blue))
                    
                    Button("🎵 Test Bundle Audio") {
                        testBundleAudio()
                    }
                    .buttonStyle(TestButtonStyle(color: .green))
                    
                    Button("📦 Check Bundle Files") {
                        checkBundleFiles()
                    }
                    .buttonStyle(TestButtonStyle(color: .orange))
                    
                    if isPlaying {
                        Button("⏹️ Stop Audio") {
                            stopAudio()
                        }
                        .buttonStyle(TestButtonStyle(color: .red))
                    }
                }
            }
            .padding()
        }
    }
    
    private func testSystemSound() {
        status = "🔊 Playing system sound..."
        AudioServicesPlaySystemSound(1322) // Success sound
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            status = "✅ System sound test complete"
        }
    }
    
    private func testBundleAudio() {
        status = "🔍 Looking for audio files..."
        
        // Try different file types and locations
        let searchOptions = [
            ("interstellar_theme", "mp3"),
            ("interstellar_theme", "m4a"),
            ("interstellar_theme", "aac"),
            ("interstellar_theme", "wav")
        ]
        
        var foundFile = false
        
        for (name, ext) in searchOptions {
            if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                status = "✅ Found: \(name).\(ext)"
                playAudioFile(url: url)
                foundFile = true
                break
            }
            
            // Also try in Audio subdirectory
            if let url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: "Audio") {
                status = "✅ Found in Audio/: \(name).\(ext)"
                playAudioFile(url: url)
                foundFile = true
                break
            }
        }
        
        if !foundFile {
            status = "❌ No audio files found in bundle"
        }
    }
    
    private func playAudioFile(url: URL) {
        do {
            // Configure audio session
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            // Create player
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = 0.8
            audioPlayer?.prepareToPlay()
            
            let success = audioPlayer?.play() ?? false
            if success {
                isPlaying = true
                status = "🎵 Playing audio! Volume up!"
            } else {
                status = "❌ Failed to play audio"
            }
            
        } catch {
            status = "❌ Audio error: \(error.localizedDescription)"
        }
    }
    
    private func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        status = "⏹️ Audio stopped"
    }
    
    private func checkBundleFiles() {
        status = "📦 Checking bundle contents..."
        
        guard let bundlePath = Bundle.main.resourcePath else {
            status = "❌ Cannot access bundle"
            return
        }
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: bundlePath)
            let audioFiles = contents.filter { file in
                let ext = (file as NSString).pathExtension.lowercased()
                return ["mp3", "m4a", "wav", "aac", "caf"].contains(ext)
            }
            
            if audioFiles.isEmpty {
                status = "❌ No audio files in bundle"
            } else {
                status = "✅ Audio files: \(audioFiles.joined(separator: ", "))"
            }
            
        } catch {
            status = "❌ Error reading bundle: \(error.localizedDescription)"
        }
    }
}

// MARK: - Custom Button Style
struct TestButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.bold())
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(color.opacity(configuration.isPressed ? 0.7 : 1.0))
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

#Preview {
    SimpleAudioTest()
}
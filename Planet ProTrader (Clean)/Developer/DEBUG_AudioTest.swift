//
//  DEBUG_AudioTest.swift
//  Simple Audio Test - Debug Version
//
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI
import AVFoundation

// MARK: - Simple Audio Test Manager
@MainActor
class SimpleAudioManager: ObservableObject {
    @Published var status = "🔍 Testing..."
    @Published var isPlaying = false
    
    private var player: AVAudioPlayer?
    
    func testAudioSystem() {
        status = "🔍 Checking audio file..."
        
        // Test 1: Check if file exists
        guard let audioURL = findAudioFile() else {
            status = "❌ Audio file not found in bundle"
            return
        }
        
        status = "✅ Audio file found: \(audioURL.lastPathComponent)"
        
        // Test 2: Setup audio session
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
            status = "✅ Audio session configured"
        } catch {
            status = "❌ Audio session failed: \(error.localizedDescription)"
            return
        }
        
        // Test 3: Create player
        do {
            player = try AVAudioPlayer(contentsOf: audioURL)
            player?.prepareToPlay()
            status = "✅ Audio player created"
        } catch {
            status = "❌ Player creation failed: \(error.localizedDescription)"
            return
        }
        
        // Test 4: Play audio
        let success = player?.play() ?? false
        if success {
            status = "🎵 Playing audio!"
            isPlaying = true
        } else {
            status = "❌ Playback failed"
        }
    }
    
    func stopAudio() {
        player?.stop()
        isPlaying = false
        status = "⏹️ Stopped"
    }
    
    private func findAudioFile() -> URL? {
        print("🔍 Looking for interstellar_theme.mp3...")
        
        // Try different paths
        let searchPaths = [
            ("interstellar_theme", "mp3", nil),
            ("interstellar_theme", "mp3", "Audio "),
            ("interstellar_theme", "mp3", "Audio")
        ]
        
        for (name, ext, subdir) in searchPaths {
            let url: URL?
            if let subdir = subdir {
                url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: subdir)
            } else {
                url = Bundle.main.url(forResource: name, withExtension: ext)
            }
            
            if let foundURL = url {
                print("✅ Found: \(foundURL.path)")
                return foundURL
            } else {
                print("❌ Not found at: \(subdir ?? "root")/\(name).\(ext)")
            }
        }
        
        // List all resources to debug
        if let resourcePath = Bundle.main.resourcePath {
            print("📁 Bundle resources:")
            do {
                let contents = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
                for item in contents.prefix(10) {
                    print("  - \(item)")
                }
            } catch {
                print("❌ Could not list bundle contents")
            }
        }
        
        return nil
    }
}

// MARK: - Debug Test View
struct DEBUG_AudioTestView: View {
    @StateObject private var audioManager = SimpleAudioManager()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("🎵 Audio Debug Test")
                    .font(.title.bold())
                    .foregroundColor(.white)
                
                Text(audioManager.status)
                    .font(.headline)
                    .foregroundColor(.green)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                
                HStack(spacing: 20) {
                    Button("Test Audio") {
                        audioManager.testAudioSystem()
                    }
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .padding()
                    .background(.blue, in: RoundedRectangle(cornerRadius: 10))
                    
                    Button("Stop") {
                        audioManager.stopAudio()
                    }
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .padding()
                    .background(.red, in: RoundedRectangle(cornerRadius: 10))
                }
                
                if audioManager.isPlaying {
                    Text("🎵 Music should be playing!")
                        .font(.headline)
                        .foregroundColor(.green)
                        .padding()
                        .background(.green.opacity(0.2), in: RoundedRectangle(cornerRadius: 8))
                }
                
                Text("If no music plays, check:\n• Volume is up\n• Silent mode is off\n• Audio file is in Xcode project")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
    }
}

#Preview {
    DEBUG_AudioTestView()
}
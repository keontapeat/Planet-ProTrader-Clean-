//
//  AudioDebugView.swift
//  Planet ProTrader - Comprehensive Audio Debug Tool
//
//  Deep audio system diagnostics and testing
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI
import AVFoundation
import AudioToolbox

// MARK: - Comprehensive Audio Debug View
struct AudioDebugView: View {
    @StateObject private var audioManager = AudioManager.shared
    @State private var debugResults: [String] = []
    @State private var isRunningTests = false
    @State private var currentTestStep = ""
    @State private var audioSessionInfo = ""
    @State private var bundleInfo = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Space Background
                LinearGradient(
                    colors: [Color.black, Color.purple.opacity(0.3), Color.black],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 20) {
                        // Header
                        headerSection
                        
                        // Current Status
                        statusSection
                        
                        // Quick Tests
                        quickTestsSection
                        
                        // Detailed Tests
                        detailedTestsSection
                        
                        // Debug Results
                        debugResultsSection
                        
                        // Audio Session Info
                        audioSessionSection
                        
                        // Bundle Info
                        bundleInfoSection
                    }
                    .padding()
                }
            }
            .navigationTitle("🎵 Audio Debug")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear") {
                        debugResults.removeAll()
                        audioSessionInfo = ""
                        bundleInfo = ""
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .onAppear {
            loadInitialInfo()
        }
    }
    
    // MARK: - UI Sections
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("🔍")
                .font(.system(size: 50))
            
            Text("Audio System Diagnostics")
                .font(.title2.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("Deep analysis of audio playback issues")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📊 Current Status")
                .font(.headline.bold())
                .foregroundColor(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                AudioStatusCard(title: "Music Enabled", value: audioManager.isMusicEnabled ? "✅ Yes" : "❌ No", color: audioManager.isMusicEnabled ? .green : .red)
                AudioStatusCard(title: "Currently Playing", value: audioManager.isPlaying ? "🎵 Yes" : "⏸️ No", color: audioManager.isPlaying ? .green : .orange)
                AudioStatusCard(title: "Volume", value: "\(Int(audioManager.musicVolume * 100))%", color: .blue)
                AudioStatusCard(title: "Current Track", value: audioManager.currentTrack?.displayName ?? "None", color: .purple)
            }
            
            // Status Message
            Text(audioManager.audioFileStatus)
                .font(.subheadline.bold())
                .foregroundColor(.cyan)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var quickTestsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🚀 Quick Tests")
                .font(.headline.bold())
                .foregroundColor(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                QuickTestButton(title: "System Sound", icon: "speaker.wave.2", color: .green) {
                    testSystemSound()
                }
                
                QuickTestButton(title: "Play Music", icon: "music.note", color: .blue) {
                    Task {
                        await testMusicPlayback()
                    }
                }
                
                QuickTestButton(title: "Stop Music", icon: "stop.fill", color: .red) {
                    testStopMusic()
                }
                
                QuickTestButton(title: "Volume Test", icon: "speaker.plus", color: .orange) {
                    testVolumeControl()
                }
            }
        }
    }
    
    private var detailedTestsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🔬 Detailed Tests")
                .font(.headline.bold())
                .foregroundColor(.white)
            
            VStack(spacing: 8) {
                DetailedTestButton(title: "Full Audio System Test", icon: "checkmark.circle", color: .green, isRunning: isRunningTests) {
                    Task {
                        await runFullAudioTest()
                    }
                }
                
                DetailedTestButton(title: "Bundle Resource Check", icon: "folder", color: .blue) {
                    checkBundleResources()
                }
                
                DetailedTestButton(title: "Audio Session Analysis", icon: "waveform", color: .purple) {
                    analyzeAudioSession()
                }
                
                DetailedTestButton(title: "File System Check", icon: "doc.magnifyingglass", color: .orange) {
                    checkFileSystem()
                }
            }
            
            if isRunningTests {
                HStack {
                    ProgressView()
                        .tint(.cyan)
                    Text(currentTestStep)
                        .font(.subheadline)
                        .foregroundColor(.cyan)
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
            }
        }
    }
    
    private var debugResultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📋 Debug Results")
                .font(.headline.bold())
                .foregroundColor(.white)
            
            if debugResults.isEmpty {
                Text("No debug results yet. Run some tests!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            } else {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(debugResults.enumerated()), id: \.offset) { index, result in
                        Text("\(index + 1). \(result)")
                            .font(.caption.monospaced())
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                    }
                }
                .frame(maxHeight: 300)
            }
        }
    }
    
    private var audioSessionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🎛️ Audio Session Info")
                .font(.headline.bold())
                .foregroundColor(.white)
            
            Text(audioSessionInfo.isEmpty ? "Run audio session analysis" : audioSessionInfo)
                .font(.caption.monospaced())
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var bundleInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📦 Bundle Info")
                .font(.headline.bold())
                .foregroundColor(.white)
            
            Text(bundleInfo.isEmpty ? "Run bundle resource check" : bundleInfo)
                .font(.caption.monospaced())
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // MARK: - Test Functions
    
    private func loadInitialInfo() {
        addDebugResult("🚀 Audio Debug View loaded")
        addDebugResult("📱 Device: \(UIDevice.current.model)")
        addDebugResult("📊 iOS Version: \(UIDevice.current.systemVersion)")
    }
    
    private func testSystemSound() {
        addDebugResult("🔊 Testing system sound...")
        AudioServicesPlaySystemSound(1322) // Success sound
        addDebugResult("✅ System sound played (if you heard it)")
    }
    
    private func testMusicPlayback() async {
        addDebugResult("🎵 Testing music playback...")
        await audioManager.playInterstellarTheme()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if audioManager.isPlaying {
                addDebugResult("✅ Music playback started successfully")
            } else {
                addDebugResult("❌ Music playback failed to start")
            }
        }
    }
    
    private func testStopMusic() {
        addDebugResult("⏹️ Stopping music...")
        audioManager.stopMusic()
        addDebugResult("✅ Stop command sent")
    }
    
    private func testVolumeControl() {
        addDebugResult("🔊 Testing volume control...")
        let originalVolume = audioManager.musicVolume
        audioManager.musicVolume = 0.5
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            audioManager.musicVolume = originalVolume
            addDebugResult("✅ Volume test completed")
        }
    }
    
    private func runFullAudioTest() async {
        isRunningTests = true
        debugResults.removeAll()
        
        currentTestStep = "Initializing..."
        addDebugResult("🔬 Starting full audio system test")
        await Task.sleep(500_000_000) // 0.5 sec
        
        // Test 1: Audio Session
        currentTestStep = "Testing audio session..."
        addDebugResult("📱 Testing audio session configuration...")
        analyzeAudioSession()
        await Task.sleep(500_000_000)
        
        // Test 2: Bundle Resources
        currentTestStep = "Checking bundle resources..."
        addDebugResult("📦 Checking bundle resources...")
        checkBundleResources()
        await Task.sleep(500_000_000)
        
        // Test 3: File Access
        currentTestStep = "Testing file access..."
        addDebugResult("🗂️ Testing file system access...")
        checkFileSystem()
        await Task.sleep(500_000_000)
        
        // Test 4: Audio Player Creation
        currentTestStep = "Testing audio player..."
        addDebugResult("🎵 Testing audio player creation...")
        await testAudioPlayerCreation()
        await Task.sleep(500_000_000)
        
        // Test 5: Playback Test
        currentTestStep = "Testing playback..."
        addDebugResult("▶️ Testing actual playback...")
        await testMusicPlayback()
        await Task.sleep(1_000_000_000) // 1 sec
        
        currentTestStep = "Test completed!"
        addDebugResult("✅ Full audio test completed!")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isRunningTests = false
            currentTestStep = ""
        }
    }
    
    private func testAudioPlayerCreation() async {
        do {
            // Try to find the audio file
            guard let audioURL = findAudioFile() else {
                addDebugResult("❌ Audio file not found in bundle")
                return
            }
            
            addDebugResult("✅ Audio file found: \(audioURL.lastPathComponent)")
            addDebugResult("📁 File path: \(audioURL.path)")
            
            // Check file size
            let attributes = try FileManager.default.attributesOfItem(atPath: audioURL.path)
            if let fileSize = attributes[.size] as? Int64 {
                addDebugResult("📊 File size: \(fileSize) bytes")
                if fileSize < 1000 {
                    addDebugResult("⚠️ Warning: File size seems too small")
                }
            }
            
            // Try to create player
            let player = try AVAudioPlayer(contentsOf: audioURL)
            addDebugResult("✅ AVAudioPlayer created successfully")
            addDebugResult("⏱️ Duration: \(String(format: "%.2f", player.duration)) seconds")
            
            player.prepareToPlay()
            addDebugResult("✅ Audio player prepared")
            
        } catch {
            addDebugResult("❌ Audio player creation failed: \(error.localizedDescription)")
        }
    }
    
    private func findAudioFile() -> URL? {
        let searchOptions = [
            ("interstellar_theme", "mp3", nil as String?),
            ("interstellar_theme", "mp3", "Audio "),
            ("interstellar_theme", "mp3", "Audio"),
            ("interstellar_theme", "m4a", nil as String?),
            ("interstellar_theme", "wav", nil as String?),
        ]
        
        for (name, ext, subdir) in searchOptions {
            let url: URL?
            if let subdir = subdir {
                url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: subdir)
            } else {
                url = Bundle.main.url(forResource: name, withExtension: ext)
            }
            
            if let foundURL = url, FileManager.default.fileExists(atPath: foundURL.path) {
                return foundURL
            }
        }
        
        return nil
    }
    
    private func checkBundleResources() {
        var info = "📦 Bundle Resource Analysis:\n\n"
        
        // Main bundle path
        if let bundlePath = Bundle.main.resourcePath {
            info += "📁 Bundle Path: \(bundlePath)\n\n"
            
            // List all audio files
            do {
                let contents = try FileManager.default.contentsOfDirectory(atPath: bundlePath)
                let audioFiles = contents.filter { file in
                    let ext = (file as NSString).pathExtension.lowercased()
                    return ["mp3", "m4a", "wav", "caf", "aac"].contains(ext)
                }
                
                info += "🎵 Audio files in main bundle:\n"
                if audioFiles.isEmpty {
                    info += "  ❌ No audio files found\n"
                } else {
                    for file in audioFiles {
                        info += "  ✅ \(file)\n"
                    }
                }
                
                // Check Audio subdirectory
                let audioDir = bundlePath + "/Audio "
                if FileManager.default.fileExists(atPath: audioDir) {
                    info += "\n📁 Audio/ subdirectory found:\n"
                    let audioContents = try FileManager.default.contentsOfDirectory(atPath: audioDir)
                    let audioSubFiles = audioContents.filter { file in
                        let ext = (file as NSString).pathExtension.lowercased()
                        return ["mp3", "m4a", "wav", "caf", "aac"].contains(ext)
                    }
                    
                    for file in audioSubFiles {
                        info += "  ✅ \(file)\n"
                    }
                } else {
                    info += "\n❌ Audio/ subdirectory not found\n"
                }
                
            } catch {
                info += "❌ Error reading bundle contents: \(error.localizedDescription)\n"
            }
        } else {
            info += "❌ Could not get bundle resource path\n"
        }
        
        bundleInfo = info
        addDebugResult("📦 Bundle analysis completed")
    }
    
    private func analyzeAudioSession() {
        let session = AVAudioSession.sharedInstance()
        var info = "🎛️ Audio Session Analysis:\n\n"
        
        info += "📱 Category: \(session.category.rawValue)\n"
        info += "🎯 Mode: \(session.mode.rawValue)\n"
        info += "⚙️ Options: \(session.categoryOptions)\n"
        info += "🔊 Output Volume: \(session.outputVolume)\n"
        info += "🎧 Output Route: \(session.currentRoute.outputs.first?.portName ?? "Unknown")\n"
        info += "📺 Available Inputs: \(session.availableInputs?.count ?? 0)\n"
        info += "🔄 Sample Rate: \(session.sampleRate) Hz\n"
        info += "⏱️ IO Buffer Duration: \(session.ioBufferDuration) seconds\n"
        
        audioSessionInfo = info
        addDebugResult("🎛️ Audio session analyzed")
    }
    
    private func checkFileSystem() {
        addDebugResult("🗂️ Checking file system permissions...")
        
        // Test basic file operations
        if FileManager.default.fileExists(atPath: Bundle.main.bundlePath) {
            addDebugResult("✅ Bundle path accessible")
        } else {
            addDebugResult("❌ Bundle path not accessible")
        }
        
        // Test URL creation
        if let _ = Bundle.main.url(forResource: "Info", withExtension: "plist") {
            addDebugResult("✅ Bundle URL creation works")
        } else {
            addDebugResult("❌ Bundle URL creation failed")
        }
        
        addDebugResult("✅ File system check completed")
    }
    
    private func addDebugResult(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        debugResults.append("[\(timestamp)] \(message)")
    }
}

// MARK: - Supporting Views

struct AudioStatusCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption.bold())
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(color)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct QuickTestButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

struct DetailedTestButton: View {
    let title: String
    let icon: String
    let color: Color
    var isRunning: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if isRunning {
                    ProgressView()
                        .tint(color)
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(color)
                        .frame(width: 20)
                }
                
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .disabled(isRunning)
    }
}

// MARK: - Extension for Task.sleep
extension Task where Success == Never, Failure == Never {
    static func sleep(_ nanoseconds: UInt64) async {
        try? await Task.sleep(nanoseconds: nanoseconds)
    }
}

#Preview {
    AudioDebugView()
}
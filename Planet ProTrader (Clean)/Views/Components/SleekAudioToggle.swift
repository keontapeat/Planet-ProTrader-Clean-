//
//  SleekAudioToggle.swift
//  Planet ProTrader - Audio Toggle Component
//
//  Sleek audio control toggle for quick access
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

// MARK: - Sleek Audio Toggle Component
struct SleekAudioToggle: View {
    @StateObject private var audioManager = AudioManager.shared
    @State private var showingVolume = false
    @State private var pulseAnimation = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Main Audio Toggle Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    audioManager.toggleMusic()
                }
                audioManager.playButtonTap()
                
                // Pulse animation feedback
                withAnimation(.easeInOut(duration: 0.2)) {
                    pulseAnimation.toggle()
                }
            }) {
                ZStack {
                    // Background Circle
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Circle()
                                .stroke(
                                    audioManager.isMusicEnabled ? .green : .gray,
                                    lineWidth: 2
                                )
                        )
                        .frame(width: 50, height: 50)
                        .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                    
                    // Audio Icon
                    Image(systemName: audioManager.isMusicEnabled ? "music.note" : "music.note.slash")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(audioManager.isMusicEnabled ? .green : .gray)
                    
                    // Playing Indicator
                    if audioManager.isPlaying {
                        Circle()
                            .fill(.green)
                            .frame(width: 8, height: 8)
                            .offset(x: 15, y: -15)
                            .opacity(0.8)
                    }
                }
            }
            .buttonStyle(.plain)
            
            // Volume Control (appears when music is enabled)
            if audioManager.isMusicEnabled && showingVolume {
                VStack(spacing: 8) {
                    Text("Volume")
                        .font(.caption2.bold())
                        .foregroundColor(.white)
                    
                    Slider(
                        value: $audioManager.musicVolume,
                        in: 0...1
                    ) {
                        Text("Volume")
                    } minimumValueLabel: {
                        Image(systemName: "speaker.fill")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    } maximumValueLabel: {
                        Image(systemName: "speaker.3.fill")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                    .tint(.green)
                    .frame(width: 80)
                    
                    Text("\(Int(audioManager.musicVolume * 100))%")
                        .font(.caption2.bold())
                        .foregroundColor(.green)
                }
                .padding(12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                .transition(.opacity.combined(with: .scale))
            }
            
            // Play/Pause Quick Controls
            if audioManager.isMusicEnabled {
                HStack(spacing: 8) {
                    // Play/Pause
                    Button(action: {
                        if audioManager.isPlaying {
                            audioManager.pauseMusic()
                        } else {
                            audioManager.playInterstellarTheme()
                        }
                        audioManager.playButtonTap()
                    }) {
                        Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.blue)
                            .frame(width: 24, height: 24)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .buttonStyle(.plain)
                    
                    // Volume Toggle
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showingVolume.toggle()
                        }
                        audioManager.playButtonTap()
                    }) {
                        Image(systemName: showingVolume ? "speaker.slash" : "speaker.2")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.orange)
                            .frame(width: 24, height: 24)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .buttonStyle(.plain)
                }
                .transition(.opacity.combined(with: .scale))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Compact Audio Toggle (for smaller spaces)
struct CompactAudioToggle: View {
    @StateObject private var audioManager = AudioManager.shared
    
    var body: some View {
        Button(action: {
            audioManager.toggleMusic()
            audioManager.playButtonTap()
        }) {
            HStack(spacing: 6) {
                Image(systemName: audioManager.isMusicEnabled ? "music.note" : "music.note.slash")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(audioManager.isMusicEnabled ? .green : .gray)
                
                if audioManager.isPlaying {
                    Circle()
                        .fill(.green)
                        .frame(width: 4, height: 4)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(
                Capsule()
                    .stroke(audioManager.isMusicEnabled ? .green : .gray, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Audio Status Bar (for debug/info)
struct AudioStatusBar: View {
    @StateObject private var audioManager = AudioManager.shared
    
    var body: some View {
        HStack(spacing: 8) {
            // Status Indicator
            Circle()
                .fill(audioManager.isPlaying ? .green : .orange)
                .frame(width: 6, height: 6)
            
            // Status Text
            Text(audioManager.audioFileStatus)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            Spacer()
            
            // Quick Test Button
            Button("Test") {
                audioManager.forceTestAudio()
            }
            .font(.caption2.bold())
            .foregroundColor(.blue)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(.ultraThinMaterial, in: Capsule())
    }
}

// MARK: - Previews
#Preview("Sleek Audio Toggle") {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 20) {
            Text("Audio Controls")
                .font(.title.bold())
                .foregroundColor(.white)
            
            SleekAudioToggle()
            
            CompactAudioToggle()
            
            AudioStatusBar()
        }
        .padding()
    }
}

#Preview("Compact Toggle") {
    ZStack {
        Color.black.ignoresSafeArea()
        
        CompactAudioToggle()
            .padding()
    }
}
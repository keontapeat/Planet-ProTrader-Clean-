//
//  SleekAudioToggle.swift
//  Planet ProTrader - Sleek Audio Controls
//
//  Ultra-minimal audio toggle that expands on tap
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

struct SleekAudioToggle: View {
    @StateObject private var audioManager = AudioManager.shared
    @State private var isExpanded = false
    @State private var showVolumeSlider = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Main compact toggle button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    if isExpanded {
                        // If expanded, toggle music and collapse
                        audioManager.toggleMusic()
                        audioManager.playButtonTap()
                        isExpanded = false
                        showVolumeSlider = false
                    } else {
                        // If collapsed, just expand
                        isExpanded = true
                    }
                }
            }) {
                ZStack {
                    // Background circle
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Circle()
                                .stroke(audioManager.isMusicEnabled ? .green : .gray, lineWidth: 1.5)
                        )
                    
                    // Music icon
                    Image(systemName: audioManager.isMusicEnabled ? "music.note" : "music.note.slash")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(audioManager.isMusicEnabled ? .green : .gray)
                }
            }
            .scaleEffect(isExpanded ? 1.1 : 1.0)
            
            // Expanded controls (slide down)
            if isExpanded {
                VStack(spacing: 8) {
                    // Control buttons row
                    HStack(spacing: 12) {
                        // Play/Pause button
                        Button(action: {
                            if audioManager.isPlaying {
                                audioManager.pauseMusic()
                            } else {
                                audioManager.playInterstellarTheme()
                            }
                            audioManager.playButtonTap()
                        }) {
                            Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.blue)
                                .frame(width: 24, height: 24)
                                .background(Circle().fill(.ultraThinMaterial))
                        }
                        
                        // Volume slider toggle
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showVolumeSlider.toggle()
                            }
                            audioManager.playButtonTap()
                        }) {
                            Image(systemName: "speaker.2.fill")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.orange)
                                .frame(width: 24, height: 24)
                                .background(Circle().fill(.ultraThinMaterial))
                        }
                        
                        // SFX toggle
                        Button(action: {
                            audioManager.toggleSFX()
                            audioManager.playButtonTap()
                        }) {
                            Image(systemName: audioManager.isSFXEnabled ? "waveform" : "waveform.slash")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(audioManager.isSFXEnabled ? .purple : .gray)
                                .frame(width: 24, height: 24)
                                .background(Circle().fill(.ultraThinMaterial))
                        }
                        
                        // Close button
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                isExpanded = false
                                showVolumeSlider = false
                            }
                            audioManager.playButtonTap()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 24, height: 24)
                                .background(Circle().fill(.red.opacity(0.8)))
                        }
                    }
                    .padding(.top, 8)
                    
                    // Volume slider (conditional)
                    if showVolumeSlider {
                        VStack(spacing: 4) {
                            HStack {
                                Text("Volume")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text("\(Int(audioManager.musicVolume * 100))%")
                                    .font(.caption2.bold())
                                    .foregroundColor(.white)
                            }
                            
                            Slider(value: $audioManager.musicVolume, in: 0...1)
                                .tint(.orange)
                                .frame(width: 120)
                        }
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.ultraThinMaterial)
                        )
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    // Now playing info (if music is playing)
                    if audioManager.isPlaying, let track = audioManager.currentTrack {
                        VStack(spacing: 2) {
                            Text("♪ \(track.displayName)")
                                .font(.caption2.bold())
                                .foregroundColor(.green)
                                .lineLimit(1)
                            
                            if audioManager.trackDuration > 0 {
                                ProgressView(value: audioManager.playbackPosition, total: audioManager.trackDuration)
                                    .tint(.green)
                                    .frame(width: 100)
                                    .scaleEffect(0.8)
                            }
                        }
                        .padding(6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(.green.opacity(0.1))
                        )
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.white.opacity(0.1), lineWidth: 1)
                        )
                )
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.8).combined(with: .opacity).combined(with: .move(edge: .top)),
                    removal: .scale(scale: 0.8).combined(with: .opacity).combined(with: .move(edge: .top))
                ))
            }
        }
        .frame(maxWidth: isExpanded ? 160 : 36)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isExpanded)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                SleekAudioToggle()
                    .padding(.trailing, 20)
                    .padding(.bottom, 100)
            }
        }
    }
}
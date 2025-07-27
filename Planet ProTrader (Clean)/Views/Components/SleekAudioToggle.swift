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
                // FIXED: Wrap async call in Task
                Task {
                    await audioManager.playButtonTap()
                }
                
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
                        // FIXED: Wrap async calls in Task
                        Task {
                            if audioManager.isPlaying {
                                audioManager.pauseMusic()
                            } else {
                                await audioManager.playInterstellarTheme()
                            }
                            await audioManager.playButtonTap()
                        }
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
                        // FIXED: Wrap async call in Task
                        Task {
                            await audioManager.playButtonTap()
                        }
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
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Compact Audio Toggle (for smaller spaces)
struct CompactAudioToggle: View {
    @StateObject private var audioManager = AudioManager.shared
    
    var body: some View {
        Button(action: {
            audioManager.toggleMusic()
            // FIXED: Wrap async call in Task with explicit priority
            Task {
                await audioManager.playButtonTap()
            }
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
                // FIXED: Wrap async call in Task
                Task {
                    await audioManager.forceTestAudio()
                }
            }
            .font(.caption2.bold())
            .foregroundColor(.blue)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(.ultraThinMaterial, in: Capsule())
    }
}

// MARK: - Enhanced Audio Toggle with Advanced Controls
struct AdvancedAudioToggle: View {
    @StateObject private var audioManager = AudioManager.shared
    @State private var showingAdvancedControls = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Main Toggle Section
            HStack(spacing: 16) {
                // Large Play/Pause Button
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
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [DesignSystem.cosmicBlue, DesignSystem.stellarPurple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(.plain)
                .disabled(!audioManager.isMusicEnabled)
                
                // Status Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(audioManager.isMusicEnabled ? "Music Enabled" : "Music Disabled")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(audioManager.isMusicEnabled ? .green : .gray)
                    
                    Text(audioManager.audioFileStatus)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    if audioManager.isPlaying {
                        Text("♪ Playing cosmic ambience")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()
                
                // Settings Button
                Button(action: {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        showingAdvancedControls.toggle()
                    }
                    Task {
                        await audioManager.playButtonTap()
                    }
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.orange)
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .buttonStyle(.plain)
            }
            
            // Advanced Controls (expandable)
            if showingAdvancedControls {
                VStack(spacing: 12) {
                    // Music Toggle
                    HStack {
                        Text("Background Music")
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Toggle("", isOn: $audioManager.isMusicEnabled)
                            .tint(.green)
                    }
                    
                    // Volume Control
                    if audioManager.isMusicEnabled {
                        VStack(spacing: 8) {
                            HStack {
                                Text("Volume")
                                    .font(DesignSystem.Typography.body)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text("\(Int(audioManager.musicVolume * 100))%")
                                    .font(DesignSystem.Typography.body)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                            
                            Slider(value: $audioManager.musicVolume, in: 0...1) {
                                Text("Volume")
                            } minimumValueLabel: {
                                Image(systemName: "speaker.fill")
                                    .foregroundColor(.gray)
                            } maximumValueLabel: {
                                Image(systemName: "speaker.3.fill")
                                    .foregroundColor(.green)
                            }
                            .tint(.green)
                        }
                    }
                    
                    // Sound Effects Toggle
                    HStack {
                        Text("Sound Effects")
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Toggle("", isOn: $audioManager.isSFXEnabled)
                            .tint(.blue)
                    }
                    
                    // Test Button
                    Button(action: {
                        Task {
                            await audioManager.forceTestAudio()
                        }
                    }) {
                        HStack {
                            Image(systemName: "waveform.and.mic")
                                .font(.system(size: 16, weight: .semibold))
                            
                            Text("Test Audio System")
                                .font(DesignSystem.Typography.body)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [DesignSystem.cosmicBlue, DesignSystem.stellarPurple],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: RoundedRectangle(cornerRadius: 10)
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .scale.combined(with: .opacity)
                ))
            }
        }
        .solarCard()
    }
}

// MARK: - Previews
#Preview("Sleek Audio Toggle") {
    ZStack {
        DesignSystem.AnimatedStarField()
            .ignoresSafeArea()
        
        VStack(spacing: 20) {
            Text("🎵 Audio Controls")
                .font(DesignSystem.Typography.largeTitle)
                .goldText()
            
            Text("Professional Audio Management")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(.white)
                .opacity(0.8)
            
            SleekAudioToggle()
            
            HStack(spacing: 20) {
                CompactAudioToggle()
                
                AudioStatusBar()
                    .frame(maxWidth: 200)
            }
            
            // Demo Controls Info
            VStack(alignment: .leading, spacing: 8) {
                Text("🎛️ Audio Features")
                    .font(DesignSystem.Typography.headline)
                    .goldText()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("• Full music playback control")
                    Text("• Volume adjustment slider")
                    Text("• Visual playing indicators")
                    Text("• Haptic feedback support")
                    Text("• Compact mode for toolbars")
                    Text("• Professional audio status")
                }
                .font(DesignSystem.Typography.body)
                .foregroundColor(.white)
                .opacity(0.9)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .solarCard()
        }
        .padding()
    }
}

#Preview("Advanced Audio Toggle") {
    ZStack {
        DesignSystem.AnimatedStarField()
            .ignoresSafeArea()
        
        VStack(spacing: 20) {
            Text("🎛️ Advanced Audio Controls")
                .font(DesignSystem.Typography.largeTitle)
                .goldText()
            
            AdvancedAudioToggle()
            
            Text("Complete audio management interface")
                .font(DesignSystem.Typography.caption)
                .foregroundColor(.white)
                .opacity(0.7)
        }
        .padding()
    }
}

#Preview("Compact Toggle") {
    ZStack {
        DesignSystem.spaceGradient
            .ignoresSafeArea()
        
        VStack(spacing: 16) {
            Text("Compact Audio Toggle")
                .font(DesignSystem.Typography.title2)
                .goldText()
            
            CompactAudioToggle()
                .solarCard()
            
            Text("Perfect for navigation bars and toolbars")
                .font(DesignSystem.Typography.caption)
                .foregroundColor(.white)
                .opacity(0.7)
        }
        .padding()
    }
}

#Preview("Audio Status Bar") {
    ZStack {
        DesignSystem.spaceGradient
            .ignoresSafeArea()
        
        VStack(spacing: 16) {
            Text("Audio Status Monitor")
                .font(DesignSystem.Typography.title2)
                .goldText()
            
            AudioStatusBar()
                .solarCard()
            
            Text("Debug and monitoring interface")
                .font(DesignSystem.Typography.caption)
                .foregroundColor(.white)
                .opacity(0.7)
        }
        .padding()
    }
}
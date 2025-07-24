//
//  PlanetTextureManager.swift
//  Planet ProTrader - NASA Realistic Planets
//
//  Ultra-realistic planet textures using NASA data
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI
import Combine

// MARK: - Planet Texture Manager
class PlanetTextureManager: ObservableObject {
    @Published var textureImages: [String: UIImage] = [:]
    @Published var isLoading: Bool = false
    
    // NASA Texture URLs (High Resolution)
    private let nasaTextures: [String: String] = [
        "earth": "https://www.solarsystemscope.com/textures/download/2k_earth_daymap.jpg",
        "mars": "https://www.solarsystemscope.com/textures/download/2k_mars.jpg",
        "jupiter": "https://www.solarsystemscope.com/textures/download/2k_jupiter.jpg",
        "venus": "https://www.solarsystemscope.com/textures/download/2k_venus_surface.jpg",
        "moon": "https://www.solarsystemscope.com/textures/download/2k_moon.jpg"
    ]
    
    init() {
        loadAllTextures()
    }
    
    func loadAllTextures() {
        isLoading = true
        
        let group = DispatchGroup()
        
        for (planet, url) in nasaTextures {
            group.enter()
            loadTexture(for: planet, from: url) {
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.isLoading = false
            print("🚀 All NASA planet textures loaded!")
        }
    }
    
    private func loadTexture(for planet: String, from urlString: String, completion: @escaping () -> Void) {
        guard let url = URL(string: urlString) else {
            completion()
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            defer { completion() }
            
            guard let data = data,
                  let image = UIImage(data: data) else {
                print("❌ Failed to load texture for \(planet)")
                return
            }
            
            DispatchQueue.main.async {
                self?.textureImages[planet] = image
                print("✅ Loaded NASA texture for \(planet)")
            }
        }.resume()
    }
    
    func getTexture(for planetName: String) -> UIImage? {
        let key = planetTextureKey(for: planetName)
        return textureImages[key]
    }
    
    private func planetTextureKey(for planetName: String) -> String {
        switch planetName {
        case "ProTrader": return "earth"
        case "Discipline": return "jupiter"
        case "Mental Game": return "venus"
        case "Zen Trading": return "mars"
        default: return "moon"
        }
    }
}

// MARK: - NASA Planet Texture View
struct NASAPlanetTextureView: View {
    let planetName: String
    let isSelected: Bool
    let textureImage: UIImage?
    
    var body: some View {
        ZStack {
            if let texture = textureImage {
                // NASA texture as background
                Image(uiImage: texture)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(
                        width: isSelected ? 50 : 40,
                        height: isSelected ? 50 : 40
                    )
                    .clipShape(Circle())
                    .overlay(
                        // Atmospheric effect overlay
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.clear,
                                        Color.clear,
                                        getPlanetColor(for: planetName).opacity(0.3)
                                    ],
                                    center: .center,
                                    startRadius: 15,
                                    endRadius: 25
                                )
                            )
                            .blendMode(.overlay)
                    )
                    .overlay(
                        // Realistic lighting effect
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.4),
                                        Color.clear,
                                        Color.black.opacity(0.6)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .blendMode(.overlay)
                    )
            } else {
                // Fallback gradient while loading
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                getPlanetColor(for: planetName).opacity(0.8),
                                getPlanetColor(for: planetName),
                                getPlanetColor(for: planetName).opacity(0.6)
                            ],
                            center: .center,
                            startRadius: 5,
                            endRadius: 25
                        )
                    )
                    .frame(
                        width: isSelected ? 50 : 40,
                        height: isSelected ? 50 : 40
                    )
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    )
            }
        }
    }
    
    private func getPlanetColor(for planetName: String) -> Color {
        switch planetName {
        case "ProTrader": return .blue
        case "Discipline": return .purple
        case "Mental Game": return .green
        case "Zen Trading": return .orange
        default: return .gray
        }
    }
}
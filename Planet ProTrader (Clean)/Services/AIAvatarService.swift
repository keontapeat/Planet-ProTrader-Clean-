//
//  AIAvatarService.swift
//  Planet ProTrader (Clean)
//
//  Created by AI Assistant on 1/25/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class AIAvatarService: ObservableObject {
    static let shared = AIAvatarService()
    
    // HuggingFace is FREE! Get your token at: https://huggingface.co/settings/tokens
    // Add your API key to environment variables or replace the placeholder below
    private let apiKey = ProcessInfo.processInfo.environment["HUGGINGFACE_API_KEY"] ?? "YOUR_HUGGINGFACE_API_KEY_HERE"
    private let baseURL = "https://api-inference.huggingface.co/models"
    private let imageCache = ImageCache.shared
    
    @Published private(set) var isGenerating = false
    @Published private(set) var generationProgress: Double = 0.0
    @Published private(set) var currentProvider = "HuggingFace (Free)"
    
    // Available free models
    private let models = [
        "stabilityai/stable-diffusion-2-1",
        "runwayml/stable-diffusion-v1-5",
        "CompVis/stable-diffusion-v1-4",
        "prompthero/openjourney-v4", // Midjourney-style, completely free!
        "wavymulder/Analog-Diffusion" // Film photography style
    ]
    
    private init() {}
    
    // MARK: - Public Methods
    
    func generateBotAvatar(for bot: MarketplaceBotModel) async throws -> UIImage {
        let cacheKey = "bot_avatar_\(bot.id.uuidString)"
        
        // Check cache first
        if let cachedImage = imageCache.getImage(forKey: cacheKey) {
            return cachedImage
        }
        
        // For demo purposes, always use local generation to prevent API key issues
        return generateLocalAvatar(bot: bot)
    }
    
    func clearCache() {
        imageCache.clearCache()
    }
    
    // MARK: - Local Avatar Generation (Always works!)
    
    private func generateLocalAvatar(bot: MarketplaceBotModel) -> UIImage {
        let size = CGSize(width: 512, height: 512)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            
            // Create gradient background based on rarity
            let colors = avatarGradientColors(for: bot.rarity)
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                    colors: colors.map { $0.cgColor } as CFArray,
                                    locations: [0.0, 0.5, 1.0])!
            
            context.cgContext.drawRadialGradient(gradient,
                                               startCenter: CGPoint(x: size.width * 0.3, y: size.height * 0.3),
                                               startRadius: 0,
                                               endCenter: CGPoint(x: size.width * 0.5, y: size.height * 0.5),
                                               endRadius: size.width * 0.7,
                                               options: [])
            
            // Add geometric patterns based on trading style
            addTradingStylePattern(context: context.cgContext, rect: rect, style: bot.tradingStyle)
            
            // Add bot initials
            let initials = getBotInitials(bot.name)
            let font = UIFont.systemFont(ofSize: size.width * 0.3, weight: .black)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.white,
                .strokeColor: UIColor.black.withAlphaComponent(0.3),
                .strokeWidth: -2
            ]
            
            let textSize = initials.size(withAttributes: attributes)
            let textRect = CGRect(x: (size.width - textSize.width) / 2,
                                y: (size.height - textSize.height) / 2,
                                width: textSize.width,
                                height: textSize.height)
            
            initials.draw(in: textRect, withAttributes: attributes)
        }
    }
    
    // MARK: - Helper Methods
    
    private func avatarGradientColors(for rarity: BotRarity) -> [UIColor] {
        switch rarity {
        case .common:
            return [UIColor.systemGray4, UIColor.systemGray5, UIColor.systemGray6]
        case .uncommon:
            return [UIColor.systemGreen.withAlphaComponent(0.7), UIColor.systemGreen.withAlphaComponent(0.3), UIColor.systemGreen.withAlphaComponent(0.1)]
        case .rare:
            return [UIColor.systemBlue.withAlphaComponent(0.7), UIColor.systemBlue.withAlphaComponent(0.3), UIColor.systemBlue.withAlphaComponent(0.1)]
        case .epic:
            return [UIColor.systemPurple.withAlphaComponent(0.7), UIColor.systemPurple.withAlphaComponent(0.3), UIColor.systemPurple.withAlphaComponent(0.1)]
        case .legendary:
            return [UIColor.systemOrange.withAlphaComponent(0.8), UIColor.systemYellow.withAlphaComponent(0.4), UIColor.systemOrange.withAlphaComponent(0.2)]
        case .mythic:
            return [UIColor.systemRed.withAlphaComponent(0.8), UIColor.systemPink.withAlphaComponent(0.4), UIColor.systemRed.withAlphaComponent(0.2)]
        case .godTier:
            return [UIColor.systemYellow, UIColor.systemOrange, UIColor.systemYellow.withAlphaComponent(0.3)]
        }
    }
    
    private func addTradingStylePattern(context: CGContext, rect: CGRect, style: TradingStyle) {
        context.setAlpha(0.2)
        context.setLineWidth(2.0)
        context.setStrokeColor(UIColor.white.cgColor)
        
        switch style {
        case .scalping:
            // Lightning bolt pattern
            let path = CGMutablePath()
            path.move(to: CGPoint(x: rect.width * 0.4, y: rect.height * 0.2))
            path.addLine(to: CGPoint(x: rect.width * 0.6, y: rect.height * 0.4))
            path.addLine(to: CGPoint(x: rect.width * 0.5, y: rect.height * 0.4))
            path.addLine(to: CGPoint(x: rect.width * 0.7, y: rect.height * 0.8))
            context.addPath(path)
            context.strokePath()
            
        case .dayTrading:
            // Sun rays
            for i in 0..<8 {
                let angle = Double(i) * .pi / 4
                let startX = rect.width * 0.5 + cos(angle) * rect.width * 0.2
                let startY = rect.height * 0.5 + sin(angle) * rect.height * 0.2
                let endX = rect.width * 0.5 + cos(angle) * rect.width * 0.4
                let endY = rect.height * 0.5 + sin(angle) * rect.height * 0.4
                
                context.move(to: CGPoint(x: startX, y: startY))
                context.addLine(to: CGPoint(x: endX, y: endY))
                context.strokePath()
            }
            
        case .swingTrading:
            // Wave pattern
            let path = CGMutablePath()
            path.move(to: CGPoint(x: rect.width * 0.1, y: rect.height * 0.5))
            for i in 0...20 {
                let x = rect.width * 0.1 + (rect.width * 0.8) * Double(i) / 20.0
                let y = rect.height * 0.5 + sin(Double(i) * .pi / 5) * rect.height * 0.1
                path.addLine(to: CGPoint(x: x, y: y))
            }
            context.addPath(path)
            context.strokePath()
            
        default:
            // Geometric pattern for other styles
            context.strokeEllipse(in: CGRect(x: rect.width * 0.3, y: rect.height * 0.3, 
                                           width: rect.width * 0.4, height: rect.height * 0.4))
        }
    }
    
    private func getBotInitials(_ name: String) -> String {
        let words = name.components(separatedBy: " ")
        if words.count >= 2 {
            return String(words[0].prefix(1)) + String(words[1].prefix(1))
        } else {
            return String(name.prefix(2))
        }
    }
}

// MARK: - Error Types

enum AIAvatarError: LocalizedError {
    case invalidResponse
    case apiError(Int)
    case invalidImageURL
    case invalidImageData
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from AI service"
        case .apiError(let code):
            return "API error with code: \(code)"
        case .invalidImageURL:
            return "Invalid image URL"
        case .invalidImageData:
            return "Invalid image data received"
        case .networkError:
            return "Network connection error"
        }
    }
}
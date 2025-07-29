//
//  BotCharacter.swift
//  Planet ProTrader - Bot Character System
//
//  Customizable bot characters and personalities
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI
import Foundation

struct ABotCharacter: Codable, Identifiable {
    let id = UUID()
    var avatar: String
    var name: String
    var personality: BotPersonality
    var backstory: String
    var specialties: [String]
    var catchPhrase: String
    var voiceStyle: VoiceStyle
    var customization: CharacterCustomization
    
    enum BotPersonality: String, CaseIterable, Codable {
        case aggressive = "Aggressive Trader"
        case conservative = "Conservative Analyst"
        case analytical = "Data Scientist"
        case intuitive = "Market Psychic"
        case social = "Social Trader"
        case rebellious = "Rule Breaker"
        case wise = "Market Sage"
        case energetic = "Energy Trader"
        
        var traits: [String] {
            switch self {
            case .aggressive:
                return ["High risk tolerance", "Quick decisions", "Profit focused"]
            case .conservative:
                return ["Risk averse", "Steady growth", "Long-term thinking"]
            case .analytical:
                return ["Data driven", "Statistical approach", "Pattern recognition"]
            case .intuitive:
                return ["Market feeling", "Emotional intelligence", "Trend sensing"]
            case .social:
                return ["Community driven", "Social signals", "Crowd wisdom"]
            case .rebellious:
                return ["Contrarian", "Anti-trend", "Unconventional"]
            case .wise:
                return ["Experience based", "Historical knowledge", "Patient"]
            case .energetic:
                return ["Fast paced", "High frequency", "Active trading"]
            }
        }
        
        var color: Color {
            switch self {
            case .aggressive: return .red
            case .conservative: return .blue
            case .analytical: return .purple
            case .intuitive: return .cyan
            case .social: return .green
            case .rebellious: return .orange
            case .wise: return .yellow
            case .energetic: return .pink
            }
        }
    }
    
    enum VoiceStyle: String, CaseIterable, Codable {
        case professional = "Professional"
        case casual = "Casual"
        case humorous = "Humorous"
        case technical = "Technical"
        case motivational = "Motivational"
        case mysterious = "Mysterious"
        case friendly = "Friendly"
        case serious = "Serious"
        case energetic = "Energetic"
        
        var samplePhrase: String {
            switch self {
            case .professional:
                return "Based on my analysis, I recommend this position."
            case .casual:
                return "Hey! This looks like a sweet trade opportunity."
            case .humorous:
                return "Time to make some money! 💰 Let's do this!"
            case .technical:
                return "RSI indicates oversold conditions with bullish divergence."
            case .motivational:
                return "We're going to crush this market! Success is ours!"
            case .mysterious:
                return "The market whispers secrets... I hear opportunity."
            case .friendly:
                return "Hope you're having a great day! Found a nice trade for us."
            case .serious:
                return "Market conditions require immediate attention."
            case .energetic:
                return "Let's go! Fast trades, big profits! ⚡"
            }
        }
    }
    
    struct CharacterCustomization: Codable {
        var isCustomized: Bool = false
        var colorScheme: CustomColorScheme
        var accessories: [String] = []
        var background: String = "default"
        var effects: [String] = []
        
        struct CustomColorScheme: Codable {
            var primary: String = "#FFD700"
            var secondary: String = "#1E90FF"
            var accent: String = "#FF6B6B"
        }
    }
    
    // Default characters for new bots
    static let defaultCharacters: [ABotCharacter] = [
        ABotCharacter(
            avatar: "🤖",
            name: "Alex",
            personality: .analytical,
            backstory: "Former quantitative analyst at Goldman Sachs",
            specialties: ["Technical Analysis", "Risk Management"],
            catchPhrase: "Data never lies!",
            voiceStyle: VoiceStyle.technical,
            customization: CharacterCustomization(colorScheme: CharacterCustomization.CustomColorScheme())
        ),
        ABotCharacter(
            avatar: "👨‍💼",
            name: "Marcus",
            personality: .aggressive,
            backstory: "Wall Street veteran with 15 years experience",
            specialties: ["Day Trading", "Momentum Trading"],
            catchPhrase: "Fortune favors the bold!",
            voiceStyle: VoiceStyle.motivational,
            customization: CharacterCustomization(colorScheme: CharacterCustomization.CustomColorScheme())
        ),
        ABotCharacter(
            avatar: "👩‍🔬",
            name: "Dr. Sarah",
            personality: .conservative,
            backstory: "PhD in Economics, specializes in market research",
            specialties: ["Fundamental Analysis", "Long-term Investing"],
            catchPhrase: "Slow and steady wins the race.",
            voiceStyle: .professional,
            customization: CharacterCustomization(colorScheme: CharacterCustomization.CustomColorScheme())
        ),
        ABotCharacter(
            avatar: "🧙‍♂️",
            name: "Gandalf",
            personality: .wise,
            backstory: "Mystical market wizard with ancient trading secrets",
            specialties: ["Pattern Recognition", "Market Cycles"],
            catchPhrase: "The market speaks to those who listen.",
            voiceStyle: .mysterious,
            customization: CharacterCustomization(colorScheme: CharacterCustomization.CustomColorScheme())
        ),
        ABotCharacter(
            avatar: "👨‍🎓",
            name: "Professor Lee",
            personality: .analytical,
            backstory: "MIT graduate, algorithm development specialist",
            specialties: ["Algorithmic Trading", "Machine Learning"],
            catchPhrase: "Let the algorithms do the work.",
            voiceStyle: VoiceStyle.technical,
            customization: CharacterCustomization(colorScheme: CharacterCustomization.CustomColorScheme())
        ),
        ABotCharacter(
            avatar: "🦊",
            name: "Foxy",
            personality: .intuitive,
            backstory: "Street-smart trader with incredible market intuition",
            specialties: ["Scalping", "Market Psychology"],
            catchPhrase: "Trust your instincts!",
            voiceStyle: VoiceStyle.casual,
            customization: CharacterCustomization(colorScheme: CharacterCustomization.CustomColorScheme())
        ),
        ABotCharacter(
            avatar: "🚀",
            name: "Rocket",
            personality: .energetic,
            backstory: "High-frequency trading specialist from Silicon Valley",
            specialties: ["High-Frequency Trading", "Arbitrage"],
            catchPhrase: "Speed is everything in trading!",
            voiceStyle: VoiceStyle.energetic,
            customization: CharacterCustomization(colorScheme: CharacterCustomization.CustomColorScheme())
        ),
        ABotCharacter(
            avatar: "🏴‍☠️",
            name: "Captain Rebel",
            personality: .rebellious,
            backstory: "Contrarian trader who profits from market chaos",
            specialties: ["Contrarian Trading", "Crisis Trading"],
            catchPhrase: "When others fear, I trade!",
            voiceStyle: VoiceStyle.humorous,
            customization: CharacterCustomization(colorScheme: CharacterCustomization.CustomColorScheme())
        )
    ]
    
    // Generate random character
    static func randomCharacter() -> ABotCharacter {
        let avatars = ["🤖", "👨‍💼", "👩‍💼", "👨‍🔬", "👩‍🔬", "🧙‍♂️", "🧙‍♀️", "👨‍🎓", "👩‍🎓", "🦊", "🐺", "🦅", "🚀", "⚡", "🔥", "💎", "🏴‍☠️", "👑", "🦸‍♂️", "🦸‍♀️"]
        let names = ["Alex", "Morgan", "Jordan", "Taylor", "Casey", "Riley", "Sage", "Phoenix", "Nova", "Zane", "Luna", "Orion", "Vex", "Echo", "Kai", "Raven", "Storm", "Blaze", "Frost", "Shadow"]
        
        return ABotCharacter(
            avatar: avatars.randomElement()!,
            name: names.randomElement()!,
            personality: BotPersonality.allCases.randomElement()!,
            backstory: generateRandomBackstory(),
            specialties: generateRandomSpecialties(),
            catchPhrase: generateRandomCatchPhrase(),
            voiceStyle: VoiceStyle.allCases.randomElement()!,
            customization: CharacterCustomization(colorScheme: CharacterCustomization.CustomColorScheme())
        )
    }
    
    private static func generateRandomBackstory() -> String {
        let backgrounds = [
            "Former hedge fund manager turned AI trader",
            "MIT graduate with 10 years trading experience",
            "Self-taught trader who started with $1000",
            "Former Goldman Sachs quantitative analyst",
            "Trading prodigy who made millions by age 25",
            "Market psychology expert with PhD in Finance",
            "High-frequency trading specialist from Chicago",
            "Cryptocurrency pioneer from early Bitcoin days",
            "Risk management expert from major investment bank",
            "Independent trader with proven track record"
        ]
        return backgrounds.randomElement()!
    }
    
    private static func generateRandomSpecialties() -> [String] {
        let allSpecialties = [
            "Day Trading", "Swing Trading", "Scalping", "Position Trading",
            "Technical Analysis", "Fundamental Analysis", "Quantitative Analysis",
            "Risk Management", "Portfolio Management", "Algorithmic Trading",
            "High-Frequency Trading", "Cryptocurrency Trading", "Forex Trading",
            "Options Trading", "Futures Trading", "Commodity Trading",
            "Market Psychology", "Trend Following", "Momentum Trading",
            "Contrarian Trading", "Arbitrage", "Machine Learning"
        ]
        return Array(allSpecialties.shuffled().prefix(Int.random(in: 2...4)))
    }
    
    private static func generateRandomCatchPhrase() -> String {
        let phrases = [
            "Trade smart, profit big!",
            "The market rewards the prepared mind.",
            "Risk management is everything!",
            "Data-driven decisions win every time.",
            "Patience pays in trading.",
            "Buy low, sell high, repeat!",
            "The trend is your friend.",
            "Never trade with emotions.",
            "Diversification is key to success.",
            "Knowledge is the ultimate edge."
        ]
        return phrases.randomElement()!
    }
}

// Character management for customization
@MainActor
class BotCharacterManager: ObservableObject {
    @Published var availableCharacters: [ABotCharacter] = []
    @Published var userCustomizedCharacters: [ABotCharacter] = []
    
    init() {
        loadCharacters()
    }
    
    func loadCharacters() {
        availableCharacters = ABotCharacter.defaultCharacters
        loadUserCustomizations()
    }
    
    func customizeCharacter(_ character: ABotCharacter, customization: ABotCharacter.CharacterCustomization) {
        var customizedCharacter = character
        customizedCharacter.customization = customization
        customizedCharacter.customization.isCustomized = true
        
        // Save to user customizations
        if let index = userCustomizedCharacters.firstIndex(where: { $0.id == character.id }) {
            userCustomizedCharacters[index] = customizedCharacter
        } else {
            userCustomizedCharacters.append(customizedCharacter)
        }
        
        saveUserCustomizations()
    }
    
    private func loadUserCustomizations() {
        // Load from UserDefaults or Core Data
        if let data = UserDefaults.standard.data(forKey: "UserCustomizedCharacters"),
           let characters = try? JSONDecoder().decode([ABotCharacter].self, from: data) {
            userCustomizedCharacters = characters
        }
    }
    
    private func saveUserCustomizations() {
        if let data = try? JSONEncoder().encode(userCustomizedCharacters) {
            UserDefaults.standard.set(data, forKey: "UserCustomizedCharacters")
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("🎨 Bot Characters")
            .font(.title)
            .fontWeight(.bold)
        
        ScrollView(.horizontal) {
            HStack(spacing: 16) {
                ForEach(ABotCharacter.defaultCharacters.prefix(5)) { character in
                    VStack(spacing: 8) {
                        Text(character.avatar)
                            .font(.system(size: 50))
                        
                        Text(character.name)
                            .font(.caption)
                            .fontWeight(.bold)
                        
                        Text(character.personality.rawValue)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Text(character.catchPhrase)
                            .font(.caption2)
                            .foregroundColor(.blue)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .frame(width: 120)
                }
            }
            .padding()
        }
    }
}
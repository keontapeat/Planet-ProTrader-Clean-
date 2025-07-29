//
//  BotCustomizationView.swift
//  Planet ProTrader (Clean)
//
//  Bot customization interface
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

struct BotCustomizationView: View {
    let bot: MarketplaceBotModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var cartManager = BotCartManager.shared
    @State private var customization = ABotCharacter.CharacterCustomization(
        colorScheme: ABotCharacter.CharacterCustomization.CustomColorScheme()
    )
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Preview section
                    previewSection
                    
                    // Color customization
                    colorCustomizationSection
                    
                    // Accessories section
                    accessoriesSection
                    
                    // Effects section
                    effectsSection
                }
                .padding()
            }
            .navigationTitle("Customize \(bot.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save & Hire") {
                        saveCustomization()
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.primaryGold)
                }
            }
        }
    }
    
    private var previewSection: some View {
        VStack(spacing: 16) {
            Text("🎨 Preview")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            // Bot preview with customizations
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: customization.colorScheme.primary).opacity(0.8),
                                Color(hex: customization.colorScheme.secondary).opacity(0.4)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Text(bot.character.avatar)
                    .font(.system(size: 60))
                
                // Accessories overlay
                ForEach(customization.accessories, id: \.self) { accessory in
                    Text(accessory)
                        .font(.system(size: 20))
                        .offset(x: 40, y: -40)
                }
            }
            .overlay(
                Circle()
                    .stroke(Color(hex: customization.colorScheme.accent), lineWidth: 3)
                    .frame(width: 120, height: 120)
            )
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
    
    private var colorCustomizationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🎨 Color Scheme")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                ColorPickerRow(
                    title: "Primary Color",
                    color: Binding(
                        get: { Color(hex: customization.colorScheme.primary) },
                        set: { customization.colorScheme.primary = $0.toHex() }
                    )
                )
                
                ColorPickerRow(
                    title: "Secondary Color",
                    color: Binding(
                        get: { Color(hex: customization.colorScheme.secondary) },
                        set: { customization.colorScheme.secondary = $0.toHex() }
                    )
                )
                
                ColorPickerRow(
                    title: "Accent Color",
                    color: Binding(
                        get: { Color(hex: customization.colorScheme.accent) },
                        set: { customization.colorScheme.accent = $0.toHex() }
                    )
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
    
    private var accessoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("👑 Accessories")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            let availableAccessories = ["👑", "🎩", "🕶️", "⚡", "💎", "🔥", "⭐", "💰"]
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(availableAccessories, id: \.self) { accessory in
                    Button(action: {
                        toggleAccessory(accessory)
                    }) {
                        Text(accessory)
                            .font(.title2)
                            .padding()
                            .background(
                                customization.accessories.contains(accessory)
                                ? DesignSystem.primaryGold.opacity(0.3)
                                : .gray.opacity(0.2)
                            )
                            .cornerRadius(12)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
    
    private var effectsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("✨ Effects")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            let availableEffects = ["Sparkle", "Glow", "Pulse", "Rotate", "Rainbow"]
            
            VStack(spacing: 8) {
                ForEach(availableEffects, id: \.self) { effect in
                    HStack {
                        Text(effect)
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Toggle("", isOn: Binding(
                            get: { customization.effects.contains(effect) },
                            set: { isOn in
                                if isOn {
                                    customization.effects.append(effect)
                                } else {
                                    customization.effects.removeAll { $0 == effect }
                                }
                            }
                        ))
                        .toggleStyle(SwitchToggleStyle(tint: DesignSystem.primaryGold))
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(.gray.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
    
    private func toggleAccessory(_ accessory: String) {
        if customization.accessories.contains(accessory) {
            customization.accessories.removeAll { $0 == accessory }
        } else {
            customization.accessories.append(accessory)
        }
    }
    
    private func saveCustomization() {
        customization.isCustomized = true
        // Apply customization to cart item if needed
        cartManager.addToCart(bot)
        // In a real app, you'd save the customization data
    }
}

struct ColorPickerRow: View {
    let title: String
    @Binding var color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white)
            
            Spacer()
            
            ColorPicker("", selection: $color)
                .frame(width: 40, height: 30)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

// Helper extensions
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    func toHex() -> String {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            return "#000000"
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
}

#Preview {
    BotCustomizationView(bot: MarketplaceBotModel.generateRandomBot())
}
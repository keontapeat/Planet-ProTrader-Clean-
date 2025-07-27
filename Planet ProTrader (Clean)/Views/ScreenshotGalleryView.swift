//
//  ScreenshotGalleryView.swift
//  Planet ProTrader (Clean)
//
//  LEGENDARY SCREENSHOT GALLERY WITH SWIPE FUNCTIONALITY
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI
import PhotosUI

struct LegendaryScreenshotGalleryView: View {
    let trade: PlaybookTrade
    @StateObject private var galleryManager = ScreenshotGalleryManager()
    @State private var selectedPhase: TradeScreenshot.TradePhase = .before
    @State private var currentImageIndex = 0
    @State private var showingImagePicker = false
    @State private var showingAnalysis = false
    @State private var isAnalyzing = false
    @State private var dragOffset: CGSize = .zero
    @State private var showingFullScreen = false
    
    var screenshots: [TradeScreenshot] {
        galleryManager.getScreenshots(for: trade.id)
    }
    
    var currentPhaseScreenshots: [TradeScreenshot] {
        screenshots.filter { $0.phase == selectedPhase }
    }
    
    var body: some View {
        ZStack {
            // Enhanced animated background - YOUR SIGNATURE STYLE
            DesignSystem.AnimatedStarField()
                .ignoresSafeArea()
            
            ScrollView {
                LazyVStack(spacing: 24) {
                    legendaryHeaderSection
                    phaseSelector
                    
                    if currentPhaseScreenshots.isEmpty {
                        legendaryEmptyStateView
                    } else {
                        screenshotGallery
                        aiAnalysisSection
                    }
                    
                    addScreenshotSection
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .background(Color.black.opacity(0.3))
        }
        .navigationTitle("Trade Screenshots")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker { image in
                Task {
                    await addNewScreenshot(image)
                }
            }
        }
        .sheet(isPresented: $showingFullScreen) {
            if !currentPhaseScreenshots.isEmpty {
                FullScreenImageView(
                    screenshots: currentPhaseScreenshots,
                    currentIndex: $currentImageIndex
                )
            }
        }
    }
    
    // MARK: - View Components
    
    private var legendaryHeaderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("📸 LEGENDARY SCREENSHOT GALLERY")
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .tracking(1.2)
                
                Spacer()
                
                Text("AI ANALYZED")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.cyan)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.cyan.opacity(0.2), in: Capsule())
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(trade.symbol)
                        .font(.title)
                        .fontWeight(.bold)
                        .goldText()
                    
                    Text(trade.setupDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(screenshots.count)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.cyan)
                    
                    Text("Screenshots")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Text(trade.formattedPnL)
                    .font(.headline)
                    .fontWeight(.bold)
                    .profitLossText(trade.pnl >= 0)
                
                Spacer()
                
                Text(trade.date.formatted(.dateTime.month().day().hour().minute()))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(DesignSystem.primaryGold.opacity(0.3), lineWidth: 2)
                )
        )
    }
    
    private var phaseSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📊 TRADE PHASES")
                .font(.headline)
                .fontWeight(.black)
                .foregroundColor(.white)
                .tracking(1.2)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(TradeScreenshot.TradePhase.allCases, id: \.self) { phase in
                        phaseButton(for: phase)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.blue.opacity(0.3), lineWidth: 2)
                )
        )
    }
    
    private func phaseButton(for phase: TradeScreenshot.TradePhase) -> some View {
        let phaseScreenshots = screenshots.filter { $0.phase == phase }
        let hasScreenshots = !phaseScreenshots.isEmpty
        
        return Button(action: {
            withAnimation(.spring()) {
                selectedPhase = phase
                currentImageIndex = 0
            }
        }) {
            VStack(spacing: 8) {
                Text(phase.emoji)
                    .font(.title2)
                
                VStack(spacing: 2) {
                    Text(phase.rawValue)
                        .font(.caption)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("\(phaseScreenshots.count)")
                        .font(.caption2)
                        .opacity(0.8)
                }
                
                if hasScreenshots {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }
            .foregroundStyle(selectedPhase == phase ? .white : phase.color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                Group {
                    if selectedPhase == phase {
                        LinearGradient(
                            colors: [phase.color, phase.color.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    } else {
                        Color.clear
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        selectedPhase == phase ? Color.clear : phase.color.opacity(0.3),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var screenshotGallery: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🖼️ \(selectedPhase.rawValue.uppercased()) GALLERY")
                .font(.headline)
                .fontWeight(.black)
                .foregroundColor(.white)
                .tracking(1.2)
            
            VStack(spacing: 20) {
                // Image viewer with swipe functionality
                TabView(selection: $currentImageIndex) {
                    ForEach(currentPhaseScreenshots.indices, id: \.self) { index in
                        ScreenshotImageView(
                            screenshot: currentPhaseScreenshots[index],
                            onTap: {
                                showingFullScreen = true
                            }
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // Screenshot info
                if !currentPhaseScreenshots.isEmpty && currentImageIndex < currentPhaseScreenshots.count {
                    let screenshot = currentPhaseScreenshots[currentImageIndex]
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text(screenshot.qualityDescription)
                                .font(.headline)
                                .foregroundStyle(screenshot.setupQuality.color)
                            
                            Spacer()
                            
                            Text("AI: \(screenshot.aiAnalysisScore)")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                        }
                        
                        Text(screenshot.analysis)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                        
                        if !screenshot.technicalIndicators.isEmpty {
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 8) {
                                ForEach(screenshot.technicalIndicators, id: \.self) { indicator in
                                    Text(indicator)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(.blue.opacity(0.2))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        
                        HStack {
                            Text(screenshot.formattedTimestamp)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Button("Full Analysis") {
                                showingAnalysis = true
                            }
                            .font(.caption)
                            .foregroundStyle(.cyan)
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(selectedPhase.color.opacity(0.3), lineWidth: 2)
                )
        )
    }
    
    private var aiAnalysisSection: some View {
        Group {
            if !currentPhaseScreenshots.isEmpty && currentImageIndex < currentPhaseScreenshots.count {
                let screenshot = currentPhaseScreenshots[currentImageIndex]
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("🤖 AI ANALYSIS ENGINE")
                            .font(.headline)
                            .fontWeight(.black)
                            .foregroundColor(.white)
                            .tracking(1.2)
                        
                        Spacer()
                        
                        if isAnalyzing {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Button("RE-ANALYZE") {
                                Task {
                                    await reanalyzeScreenshot(screenshot)
                                }
                            }
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.cyan)
                            .clipShape(Capsule())
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Setup Quality:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text(screenshot.setupQuality.rawValue)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(screenshot.setupQuality.color)
                        }
                        
                        HStack {
                            Text("Market Condition:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text(screenshot.marketCondition)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(.orange)
                        }
                        
                        HStack {
                            Text("AI Confidence:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text(screenshot.aiAnalysisScore)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(.green)
                        }
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Analysis Summary:")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(screenshot.analysis)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.purple.opacity(0.3), lineWidth: 2)
                        )
                )
            } else {
                EmptyView()
            }
        }
    }
    
    private var legendaryEmptyStateView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(selectedPhase.color.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "camera.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(selectedPhase.color)
            }
            
            VStack(spacing: 12) {
                Text("NO \(selectedPhase.rawValue.uppercased()) SCREENSHOTS")
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .tracking(1.2)
                
                Text(selectedPhase.description)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Button("⚡ ADD SCREENSHOT") {
                showingImagePicker = true
            }
            .font(.headline)
            .fontWeight(.bold)
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(selectedPhase.color)
            .clipShape(Capsule())
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(selectedPhase.color.opacity(0.3), lineWidth: 2)
                )
        )
    }
    
    private var addScreenshotSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("📷 ADD SCREENSHOT")
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .tracking(1.2)
                
                Spacer()
                
                Button("ADD NEW") {
                    showingImagePicker = true
                }
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(DesignSystem.primaryGold)
                .clipShape(Capsule())
            }
            
            Text("Capture and analyze your trading screenshots to build a comprehensive visual record of your trades.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(DesignSystem.primaryGold.opacity(0.3), lineWidth: 2)
                )
        )
    }
    
    // MARK: - Helper Methods
    
    private func addNewScreenshot(_ image: UIImage) async {
        isAnalyzing = true
        defer { isAnalyzing = false }
        
        let analysis = await ScreenshotAnalysisEngine.analyzeTradeSetup(image)
        
        let screenshot = TradeScreenshot(
            tradeId: trade.id,
            phase: selectedPhase,
            imageName: "\(trade.id)_\(selectedPhase.rawValue.lowercased())_\(Date().timeIntervalSince1970).jpg",
            analysis: generateAnalysisText(from: analysis),
            aiConfidence: analysis.confidence,
            technicalIndicators: analysis.technicalIndicators,
            marketCondition: analysis.marketCondition.rawValue,
            setupQuality: analysis.qualityScore
        )
        
        await galleryManager.addScreenshot(screenshot, image: image)
    }
    
    private func reanalyzeScreenshot(_ screenshot: TradeScreenshot) async {
        isAnalyzing = true
        defer { isAnalyzing = false }
        
        let newAnalysis = await galleryManager.analyzeScreenshot(screenshot)
        // Update screenshot with new analysis
        // In a real implementation, you would update the screenshot object
    }
    
    private func generateAnalysisText(from analysis: ScreenshotAnalysis) -> String {
        return "\(analysis.setupType.emoji) \(analysis.setupType.rawValue) setup identified with \(analysis.formattedConfidence) confidence. Risk-reward ratio: \(analysis.formattedRiskReward). Market showing \(analysis.marketCondition.rawValue.lowercased()) conditions."
    }
}

// MARK: - Screenshot Image View

struct ScreenshotImageView: View {
    let screenshot: TradeScreenshot
    let onTap: () -> Void
    @StateObject private var galleryManager = ScreenshotGalleryManager()
    
    var body: some View {
        ZStack {
            // Placeholder or actual image
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [.gray.opacity(0.3), .gray.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Group {
                        if let image = galleryManager.loadImage(for: screenshot) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .font(.system(size: 40))
                                    .foregroundStyle(screenshot.phase.color)
                                
                                Text("Trading Chart")
                                    .font(.headline)
                                    .foregroundStyle(screenshot.phase.color)
                                
                                Text(screenshot.phase.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                )
                .overlay(
                    // Quality badge
                    VStack {
                        HStack {
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Text(screenshot.setupQuality.emoji)
                                    .font(.caption)
                                
                                Text(screenshot.setupQuality.rawValue)
                                    .font(.caption2)
                                    .fontWeight(.bold)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .padding(.top, 12)
                            .padding(.trailing, 12)
                        }
                        
                        Spacer()
                        
                        // Phase indicator
                        HStack {
                            HStack(spacing: 6) {
                                Text(screenshot.phase.emoji)
                                    .font(.caption)
                                
                                Text(screenshot.phase.rawValue)
                                    .font(.caption)
                                    .fontWeight(.bold)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .padding(.bottom, 12)
                            .padding(.leading, 12)
                            
                            Spacer()
                        }
                    }
                )
        }
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Full Screen Image View

struct FullScreenImageView: View {
    let screenshots: [TradeScreenshot]
    @Binding var currentIndex: Int
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var galleryManager = ScreenshotGalleryManager()
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            TabView(selection: $currentIndex) {
                ForEach(screenshots.indices, id: \.self) { index in
                    ZStack {
                        if let image = galleryManager.loadImage(for: screenshots[index]) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .tag(index)
                        } else {
                            VStack(spacing: 20) {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .font(.system(size: 80))
                                    .foregroundStyle(screenshots[index].phase.color)
                                
                                Text("Trading Chart")
                                    .font(.title)
                                    .foregroundStyle(screenshots[index].phase.color)
                                
                                Text(screenshots[index].phase.rawValue)
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                            .tag(index)
                        }
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            
            VStack {
                HStack {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                    .padding()
                    
                    Spacer()
                }
                
                Spacer()
            }
        }
    }
}

// MARK: - Image Picker

struct ImagePicker: UIViewControllerRepresentable {
    let onImagePicked: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    if let image = image as? UIImage {
                        DispatchQueue.main.async {
                            self.parent.onImagePicked(image)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        LegendaryScreenshotGalleryView(trade: PlaybookTrade.sampleTrades.first!)
    }
}
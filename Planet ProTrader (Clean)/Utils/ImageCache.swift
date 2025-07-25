//
//  ImageCache.swift
//  Planet ProTrader (Clean)
//
//  Created by AI Assistant on 1/25/25.
//

import Foundation
import UIKit
import SwiftUI

/// High-performance image cache for bot avatars and AI-generated images
@MainActor
class ImageCache: ObservableObject {
    static let shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    @Published private(set) var cacheSize: Int64 = 0
    @Published private(set) var itemCount: Int = 0
    
    private init() {
        // Setup cache directory
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        cacheDirectory = documentsPath.appendingPathComponent("ImageCache")
        
        // Create cache directory if needed
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        
        // Configure NSCache
        cache.countLimit = 100 // Max 100 images in memory
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB memory limit
        
        // Calculate initial cache size
        updateCacheStats()
        
        // Listen for memory warnings
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.clearMemoryCache()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public Methods
    
    /// Get image from cache (memory first, then disk)
    func getImage(forKey key: String) -> UIImage? {
        // Check memory cache first
        if let image = cache.object(forKey: key as NSString) {
            return image
        }
        
        // Check disk cache
        let fileURL = cacheDirectory.appendingPathComponent("\(key).jpg")
        guard fileManager.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }
        
        // Store in memory cache for faster access next time
        cache.setObject(image, forKey: key as NSString, cost: estimateImageSize(image))
        
        return image
    }
    
    /// Store image in cache (both memory and disk)
    func setImage(_ image: UIImage, forKey key: String) {
        // Store in memory cache
        let cost = estimateImageSize(image)
        cache.setObject(image, forKey: key as NSString, cost: cost)
        
        // Store on disk asynchronously
        Task {
            await saveToDisk(image: image, key: key)
            await updateCacheStats()
        }
    }
    
    /// Remove specific image from cache
    func removeImage(forKey key: String) {
        // Remove from memory
        cache.removeObject(forKey: key as NSString)
        
        // Remove from disk
        let fileURL = cacheDirectory.appendingPathComponent("\(key).jpg")
        try? fileManager.removeItem(at: fileURL)
        
        Task {
            await updateCacheStats()
        }
    }
    
    /// Clear all cached images
    func clearCache() {
        // Clear memory cache
        cache.removeAllObjects()
        
        // Clear disk cache
        Task {
            await clearDiskCache()
            await updateCacheStats()
        }
    }
    
    /// Clear only memory cache (useful for memory warnings)
    func clearMemoryCache() {
        cache.removeAllObjects()
        print("📱 ImageCache: Memory cache cleared due to memory pressure")
    }
    
    /// Get cache statistics
    func getCacheStats() -> (size: Int64, count: Int) {
        return (cacheSize, itemCount)
    }
    
    // MARK: - Private Methods
    
    private func saveToDisk(image: UIImage, key: String) async {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        
        let fileURL = cacheDirectory.appendingPathComponent("\(key).jpg")
        try? data.write(to: fileURL)
    }
    
    private func clearDiskCache() async {
        guard let items = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil) else {
            return
        }
        
        for item in items {
            try? fileManager.removeItem(at: item)
        }
    }
    
    private func updateCacheStats() {
        guard let items = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey]) else {
            cacheSize = 0
            itemCount = 0
            return
        }
        
        var totalSize: Int64 = 0
        
        for item in items {
            if let resources = try? item.resourceValues(forKeys: [.fileSizeKey]),
               let size = resources.fileSize {
                totalSize += Int64(size)
            }
        }
        
        DispatchQueue.main.async {
            self.cacheSize = totalSize
            self.itemCount = items.count
        }
    }
    
    private func estimateImageSize(_ image: UIImage) -> Int {
        return Int(image.size.width * image.size.height * 4) // Rough estimate for RGBA
    }
}

// MARK: - Cache Statistics View

struct ImageCacheStatsView: View {
    @StateObject private var cache = ImageCache.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🗂️ Image Cache Stats")
                .font(.headline.bold())
                .foregroundColor(.white)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Items Cached")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(cache.itemCount)")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Cache Size")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatBytes(cache.cacheSize))
                        .font(.title2.bold())
                        .foregroundColor(.white)
                }
            }
            
            HStack(spacing: 12) {
                Button("Clear Cache") {
                    cache.clearCache()
                    GlobalToastManager.shared.show("Cache cleared!", type: .success)
                }
                .foregroundColor(.red)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.red.opacity(0.2), in: RoundedRectangle(cornerRadius: 8))
                
                Button("Clear Memory") {
                    cache.clearMemoryCache()
                    GlobalToastManager.shared.show("Memory cache cleared!", type: .info)
                }
                .foregroundColor(.orange)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.orange.opacity(0.2), in: RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ImageCacheStatsView()
            .padding()
    }
}
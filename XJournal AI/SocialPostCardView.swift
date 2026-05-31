//
//  SocialPostCardView.swift
//  The Final Journal AI
//
//  Instagram-style card view for social posts with image carousel
//

import SwiftUI
import UIKit

struct SocialPostCardView: View {
    let post: SocialPost
    @Environment(\.colorScheme) private var colorScheme
    @State private var currentImageIndex: Int = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Image Carousel
                if !post.images.isEmpty {
                    TabView(selection: $currentImageIndex) {
                        ForEach(Array(post.images.enumerated()), id: \.offset) { index, imageName in
                            imageView(for: imageName)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page)
                    .frame(height: 400)
                    .overlay(
                        // Page indicators for image carousel
                        VStack {
                            Spacer()
                            if post.images.count > 1 {
                                HStack(spacing: 6) {
                                    ForEach(0..<post.images.count, id: \.self) { index in
                                        Circle()
                                            .fill(index == currentImageIndex ? Color.white : Color.white.opacity(0.4))
                                            .frame(width: 6, height: 6)
                                    }
                                }
                                .padding(.bottom, 12)
                            }
                        }
                    )
                } else {
                    // Placeholder when no images
                    ZStack {
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                        
                        Image(systemName: "photo")
                            .font(.system(size: 60))
                            .foregroundStyle(Momentum.contentSecondary)
                    }
                    .frame(height: 400)
                }
                
                // Caption and Metadata Section
                VStack(alignment: .leading, spacing: 16) {
                    // Title
                    if !post.title.isEmpty {
                        Text(post.title)
                            .font(.title2.weight(.bold))
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                    }
                    
                    // Metadata Row
                    HStack(spacing: 12) {
                        if let category = post.category {
                            Label(category, systemImage: "tag.fill")
                                .font(.caption)
                                .foregroundStyle(Momentum.contentSecondary)
                        }
                        
                        Text(post.author)
                            .font(.caption)
                            .foregroundStyle(Momentum.contentSecondary)
                        
                        Text(post.createdDate, style: .relative)
                            .font(.caption)
                            .foregroundStyle(Momentum.contentSecondary)
                    }
                    .padding(.horizontal, 20)
                    
                    // Caption
                    if !post.caption.isEmpty {
                        Text(post.caption)
                            .font(.body)
                            .lineSpacing(4)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                    }
                }
            }
        }
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                .ignoresSafeArea()
        )
    }
    
    @ViewBuilder
    private func imageView(for imageName: String) -> some View {
        // For now, use SF Symbols or placeholder
        // In the future, this can load actual images from bundle or remote
        if let systemImage = systemImageForName(imageName) {
            ZStack {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                
                Image(systemName: systemImage)
                    .font(.system(size: 80))
                    .foregroundStyle(.primary)
            }
        } else {
            // Try to load from bundle
            if let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
            } else {
                // Placeholder
                ZStack {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                    
                    Image(systemName: "photo")
                        .font(.system(size: 60))
                        .foregroundStyle(Momentum.contentSecondary)
                }
            }
        }
    }
    
    private func systemImageForName(_ name: String) -> String? {
        // Map common names to SF Symbols for initial implementation
        let mapping: [String: String] = [
            "microphone": "mic.fill",
            "soundcard": "waveform",
            "logic": "music.note",
            "protools": "music.note.list",
            "setup": "gearshape.fill",
            "audio": "speaker.wave.2.fill"
        ]
        
        let lowercased = name.lowercased()
        for (key, symbol) in mapping {
            if lowercased.contains(key) {
                return symbol
            }
        }
        return nil
    }
}

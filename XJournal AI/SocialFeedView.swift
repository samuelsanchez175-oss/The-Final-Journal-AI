//
//  SocialFeedView.swift
//  The Final Journal AI
//
//  Main social feed view with Instagram-style carousel navigation
//

import SwiftUI
import SwiftData

struct SocialFeedView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: [SortDescriptor(\SocialPost.order, order: .forward)]) private var posts: [SocialPost]
    @Environment(\.colorScheme) private var colorScheme
    @State private var currentPostIndex: Int = 0
    @AppStorage("didSeedSocialPosts") private var didSeedSocialPosts: Bool = false
    
    var body: some View {
        NavigationStack {
            Group {
                if posts.isEmpty {
                    emptyStateView
                } else {
                    TabView(selection: $currentPostIndex) {
                        ForEach(Array(posts.enumerated()), id: \.element.id) { index, post in
                            SocialPostCardView(post: post)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page)
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                    .onAppear {
                        // Reset to first post when view appears
                        if !posts.isEmpty && currentPostIndex >= posts.count {
                            currentPostIndex = 0
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
            .navigationTitle("Social")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Momentum.contentSecondary)
                    }
                    .accessibilityLabel("Close")
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .task {
            if !didSeedSocialPosts {
                seedSocialPosts()
                didSeedSocialPosts = true
            }
        }
    }
    
    private func seedSocialPosts() {
        let samplePosts: [SocialPost] = [
            SocialPost(
                title: "Microphone Leveling Basics",
                caption: """
                Getting the right input level is crucial for clean recordings. Here's how to properly level your microphone:
                
                1. **Set your gain to -12dB to -6dB** - This leaves headroom and prevents clipping
                2. **Speak or sing at your normal volume** - Don't adjust your performance, adjust the gain
                3. **Watch the meters** - Aim for peaks around -6dB, average around -12dB
                4. **Test with your loudest passage** - Make sure you don't clip during dynamic moments
                
                Remember: It's better to record a bit quiet and boost later than to clip and lose audio quality forever.
                """,
                images: ["microphone", "setup"],
                category: "Microphone Setup",
                order: 1
            ),
            SocialPost(
                title: "First-Time Logic Pro Setup",
                caption: """
                New to Logic Pro? Here's your quick start guide:
                
                **Initial Setup:**
                1. Open Logic Pro and create a new project
                2. Select "Empty Project" or "Voice" template
                3. Choose your audio interface in Preferences > Audio
                4. Set your buffer size to 128 or 256 for recording (lower latency)
                
                **For Recording Vocals:**
                - Create an Audio Track (Track > New Audio Track)
                - Select your input (the microphone channel on your interface)
                - Enable Record Enable (R button) and Monitoring
                - Press Record and start performing
                
                **Pro Tip:** Use the built-in metronome (⌘U) to keep time, even for free-form poetry readings.
                """,
                images: ["logic", "setup"],
                category: "Logic Pro",
                order: 2
            ),
            SocialPost(
                title: "ProTools First Steps",
                caption: """
                Getting started with ProTools? Here's what you need to know:
                
                **Creating Your First Session:**
                1. File > New Session
                2. Choose your sample rate (48kHz is standard)
                3. Select your I/O settings (your audio interface)
                4. Create a new track: Track > New > Audio Track
                
                **Recording Setup:**
                - Set your track input to match your microphone
                - Enable Input Monitoring (speaker icon)
                - Arm the track for recording (red button)
                - Press Spacebar or F12 to record
                
                **Essential Shortcuts:**
                - Spacebar: Play/Stop
                - F12: Record
                - ⌘S: Save (do this often!)
                - ⌘Z: Undo
                
                ProTools has a learning curve, but once you master the basics, it's incredibly powerful for vocal recording and editing.
                """,
                images: ["protools", "setup"],
                category: "ProTools",
                order: 3
            ),
            SocialPost(
                title: "Sound Card Configuration",
                caption: """
                Your audio interface (sound card) is the bridge between your microphone and your DAW. Here's how to configure it properly:
                
                **Driver Settings:**
                - Use ASIO drivers on Windows (lowest latency)
                - Use Core Audio on Mac (built-in, works great)
                - Set buffer size: 128-256 for recording, 512-1024 for mixing
                
                **Input Levels:**
                - Use the gain knobs on your interface, not just software
                - Most interfaces have LED meters - watch for clipping (red)
                - Phantom power (48V) for condenser microphones only
                
                **Common Issues:**
                - No sound? Check your interface is selected in DAW preferences
                - Latency? Lower your buffer size (if your computer can handle it)
                - Clicks/pops? Increase buffer size or check sample rate mismatch
                
                **Recommended Settings:**
                - Sample Rate: 48kHz (standard for most work)
                - Bit Depth: 24-bit (gives you more headroom)
                - Buffer: 128-256 samples for recording
                """,
                images: ["soundcard", "audio"],
                category: "Sound Cards",
                order: 4
            ),
            SocialPost(
                title: "Microphone Types for Poets & Writers",
                caption: """
                Choosing the right microphone depends on your voice and recording space:
                
                **Condenser Microphones:**
                - Best for: Clear, detailed vocals, quiet spaces
                - Examples: Audio-Technica AT2020, Rode NT1-A
                - Need: Phantom power (48V) from your interface
                - Great for: Poetry readings, spoken word, clear vocals
                
                **Dynamic Microphones:**
                - Best for: Noisy environments, powerful voices
                - Examples: Shure SM58, SM7B
                - Need: More gain (louder preamp)
                - Great for: Rap, energetic performances, live feel
                
                **USB Microphones:**
                - Best for: Quick setup, beginners, podcasting
                - Examples: Blue Yeti, Audio-Technica ATR2100x
                - Need: Just plug in and go
                - Great for: Getting started quickly, simple setups
                
                **Pro Tip:** Start with what you have. A well-positioned, properly leveled cheap mic beats an expensive mic used poorly.
                """,
                images: ["microphone", "audio"],
                category: "Microphone Setup",
                order: 5
            ),
            SocialPost(
                title: "Recording Best Practices",
                caption: """
                Follow these tips for professional-sounding recordings:
                
                **Room Setup:**
                - Record in a quiet space (turn off AC, close windows)
                - Use soft surfaces to reduce echo (blankets, curtains)
                - Position mic 6-12 inches from your mouth
                - Use a pop filter to reduce plosives (P, B sounds)
                
                **Performance Tips:**
                - Warm up your voice before recording
                - Stay hydrated (water, not coffee before recording)
                - Take breaks between takes
                - Record multiple takes - you can comp the best parts
                
                **Technical:**
                - Record at 24-bit, 48kHz minimum
                - Leave headroom (don't peak above -6dB)
                - Use headphones to monitor (prevents feedback)
                - Save your project frequently (⌘S / Ctrl+S)
                
                **Editing:**
                - Remove breaths if they're distracting
                - Use fades to smooth transitions
                - Normalize or compress lightly for consistency
                - Export at the same sample rate you recorded
                """,
                images: ["audio", "setup"],
                category: "Audio Recording",
                order: 6
            )
        ]
        
        for post in samplePosts {
            modelContext.insert(post)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to seed social posts: \(error.localizedDescription)")
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.2.fill")
                .font(.system(size: 60))
                .foregroundStyle(Momentum.contentSecondary)
            
            Text("No Posts Yet")
                .font(.title2.weight(.semibold))
            
            Text("Check back soon for curated tips and guides for writers and poets using Logic Pro, ProTools, and audio equipment.")
                .font(.body)
                .foregroundStyle(Momentum.contentSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

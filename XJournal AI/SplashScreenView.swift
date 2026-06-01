import SwiftUI
import UIKit

// MARK: - Splash Screen View

struct SplashScreenView: View {
    let id: SplashScreenID
    let title: String
    let message: String
    let onDismiss: () -> Void
    
    @ObservedObject private var splashManager = SplashScreenManager.shared
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with X button
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Button {
                    splashManager.dismissSplash(id)
                    onDismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Momentum.contentSecondary)
                        .frame(width: 28, height: 28)
                        .background(
                            Circle()
                                .fill(Momentum.surfaceElevated)
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            Divider()
                .opacity(0.15)
            
            // Content
            VStack(alignment: .leading, spacing: 16) {
                Text(message)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            
            Divider()
                .opacity(0.15)
            
            // Footer buttons
            HStack(spacing: 12) {
                Button {
                    splashManager.neverShowSplash(id)
                    onDismiss()
                } label: {
                    Text("\"Never show again\"")
                        .font(.subheadline)
                        .foregroundStyle(Momentum.contentSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Momentum.surfaceElevated)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .frame(maxWidth: 400)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(
                            Color.primary.opacity(0.1),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Splash Screen Modifier

struct SplashScreenModifier: ViewModifier {
    let id: SplashScreenID
    let title: String
    let message: String
    
    @ObservedObject private var splashManager = SplashScreenManager.shared
    @State private var showSplash: Bool = false
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if showSplash {
                        ZStack {
                            // Backdrop
                            Color.black.opacity(0.3)
                                .ignoresSafeArea()
                                .onTapGesture {
                                    splashManager.dismissSplash(id)
                                    showSplash = false
                                }
                            
                            // Splash screen
                            SplashScreenView(
                                id: id,
                                title: title,
                                message: message,
                                onDismiss: {
                                    showSplash = false
                                }
                            )
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
            )
            .onAppear {
                if splashManager.shouldShowSplash(id) {
                    // Small delay to ensure view is fully rendered
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showSplash = true
                        }
                    }
                }
            }
    }
}

extension View {
    func splashScreen(id: SplashScreenID, title: String, message: String) -> some View {
        modifier(SplashScreenModifier(id: id, title: title, message: message))
    }
}

// MARK: - Hero Splash View

struct HeroSplashView: View {
    let onDismiss: () -> Void
    
    @ObservedObject private var splashManager = SplashScreenManager.shared
    @Environment(\.colorScheme) private var colorScheme
    @State private var showContent: Bool = false
    
    var body: some View {
        ZStack {
            // Backdrop
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // App Icon
                Group {
                    if let appIcon = Bundle.main.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any],
                       let primaryIcon = appIcon["CFBundlePrimaryIcon"] as? [String: Any],
                       let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
                       let firstIcon = iconFiles.first,
                       let iconImage = UIImage(named: firstIcon) {
                        Image(uiImage: iconImage)
                            .resizable()
                            .frame(width: 120, height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                    } else {
                        // Fallback to SF Symbol if icon not found
                        Image(systemName: "doc.text")
                            .font(.system(size: 60))
                            .foregroundStyle(.blue)
                            .frame(width: 120, height: 120)
                            .background(
                                RoundedRectangle(cornerRadius: 26, style: .continuous)
                                    .fill(Momentum.surfaceElevated)
                            )
                            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                    }
                }
                .scaleEffect(showContent ? 1.0 : 0.8)
                .opacity(showContent ? 1.0 : 0.0)
                
                // App Name
                Text("The Final Journal AI")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.primary)
                    .opacity(showContent ? 1.0 : 0.0)
                
                // Description
                VStack(spacing: 16) {
                    Text("Your intelligent writing companion for rap lyrics and journaling")
                        .font(.title3)
                        .foregroundStyle(Momentum.contentSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        FeatureRow(icon: "sparkles", text: "AI-powered lyric suggestions")
                        FeatureRow(icon: "text.magnifyingglass", text: "Real-time rhyme analysis")
                        FeatureRow(icon: "waveform", text: "Audio recording & transcription")
                        FeatureRow(icon: "doc.text", text: "Smart journaling tools")
                    }
                    .padding(.top, 8)
                }
                .opacity(showContent ? 1.0 : 0.0)
                
                Spacer()
                
                // Get Started Button
                Button {
                    splashManager.markOnboardingComplete()
                    splashManager.dismissSplash(.heroScreen)
                    onDismiss()
                } label: {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: 280)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(.blue)
                        )
                }
                .opacity(showContent ? 1.0 : 0.0)
                .scaleEffect(showContent ? 1.0 : 0.9)
                
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                showContent = true
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.blue)
                .frame(width: 24)
            
            Text(text)
                .font(.body)
                .foregroundStyle(Momentum.contentSecondary)
        }
    }
}

// MARK: - Toolbar Overview Splash View

struct ToolbarOverviewSplashView: View {
    let toolbarFrame: CGRect?
    let onDismiss: () -> Void
    let onNext: () -> Void
    
    @ObservedObject private var splashManager = SplashScreenManager.shared
    @Environment(\.colorScheme) private var colorScheme
    @State private var showContent: Bool = false
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Backdrop
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            // Toolbar Highlight Overlay
            if let frame = toolbarFrame {
                ToolbarHighlightOverlay(toolbarFrame: frame, pulseScale: pulseScale)
            }
            
            // Splash Content
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 20) {
                    Text("Your Writing Toolbar")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    Text("The dynamic toolbar at the bottom of your screen contains powerful tools to enhance your writing. It includes AI assistance, rhyme analysis, audio recording, and more. Let's explore each button together.")
                        .font(.body)
                        .foregroundStyle(Momentum.contentSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    
                    HStack(spacing: 12) {
                        Button {
                            splashManager.neverShowSplash(.toolbarOverview)
                            splashManager.neverShowSplash(.toolbarPaperclip)
                            splashManager.neverShowSplash(.toolbarAISparkle)
                            splashManager.neverShowSplash(.toolbarUndoRedo)
                            splashManager.neverShowSplash(.toolbarEyeToggle)
                            splashManager.neverShowSplash(.toolbarMagnifyingGlass)
                            splashManager.neverShowSplash(.toolbarDiagnostics)
                            onDismiss()
                        } label: {
                            Text("Skip All")
                                .font(.subheadline)
                                .foregroundStyle(Momentum.contentSecondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Momentum.surfaceElevated)
                                )
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            splashManager.dismissSplash(.toolbarOverview)
                            onNext()
                        } label: {
                            Text("Next")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(.blue)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                }
                .padding(.vertical, 32)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.regularMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .strokeBorder(
                                    Color.primary.opacity(0.1),
                                    lineWidth: 1
                                )
                        )
                )
                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
                .scaleEffect(showContent ? 1.0 : 0.9)
                .opacity(showContent ? 1.0 : 0.0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.2)) {
                showContent = true
            }
            
            // Pulsing animation for toolbar highlight
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulseScale = 1.05
            }
        }
    }
}

// MARK: - Toolbar Highlight Overlay

struct ToolbarHighlightOverlay: View {
    let toolbarFrame: CGRect
    let pulseScale: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            let frame = toolbarFrame
            
            ZStack {
                // Dimmed overlay with cutout for toolbar
                Path { path in
                    let screenBounds = geometry.frame(in: .local)
                    path.addRect(screenBounds)
                    path.addRoundedRect(
                        in: CGRect(
                            x: frame.minX - 10,
                            y: frame.minY - 10,
                            width: frame.width + 20,
                            height: frame.height + 20
                        ),
                        cornerSize: CGSize(width: 20, height: 20)
                    )
                }
                .fill(style: FillStyle(eoFill: true))
                .fill(Color.black.opacity(0.4))
                
                // Glowing border around toolbar
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [.blue.opacity(0.8), .blue.opacity(0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: frame.width + 20, height: frame.height + 20)
                    .position(x: frame.midX, y: frame.midY)
                    .scaleEffect(pulseScale)
                    .shadow(color: .blue.opacity(0.5), radius: 20)
            }
        }
    }
}

// MARK: - Toolbar Button Splash View

struct ToolbarButtonSplashView: View {
    let id: SplashScreenID
    let buttonFrame: CGRect?
    let title: String
    let description: String
    let icon: String
    let onDismiss: () -> Void
    let onNext: (() -> Void)?
    
    @ObservedObject private var splashManager = SplashScreenManager.shared
    @Environment(\.colorScheme) private var colorScheme
    @State private var showContent: Bool = false
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Backdrop
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            // Button Highlight Overlay
            if let frame = buttonFrame {
                ButtonHighlightOverlay(buttonFrame: frame, pulseScale: pulseScale)
            }
            
            // Splash Content
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 20) {
                    // Icon
                    Image(systemName: icon)
                        .font(.system(size: 48, weight: .medium))
                        .foregroundStyle(.blue)
                        .frame(width: 80, height: 80)
                        .background(
                            Circle()
                                .fill(.blue.opacity(0.1))
                        )
                    
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    Text(description)
                        .font(.body)
                        .foregroundStyle(Momentum.contentSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    
                    HStack(spacing: 12) {
                        Button {
                            splashManager.neverShowSplash(id)
                            if let next = onNext {
                                next()
                            } else {
                                onDismiss()
                            }
                        } label: {
                            Text("Never show again")
                                .font(.subheadline)
                                .foregroundStyle(Momentum.contentSecondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Momentum.surfaceElevated)
                                )
                        }
                        .buttonStyle(.plain)
                        
                        if onNext != nil {
                            Button {
                                splashManager.dismissSplash(id)
                                onNext?()
                            } label: {
                                Text("Next")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(.blue)
                                    )
                            }
                            .buttonStyle(.plain)
                        } else {
                            Button {
                                splashManager.dismissSplash(id)
                                onDismiss()
                            } label: {
                                Text("Got it")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(.blue)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                }
                .padding(.vertical, 32)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.regularMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .strokeBorder(
                                    Color.primary.opacity(0.1),
                                    lineWidth: 1
                                )
                        )
                )
                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
                .scaleEffect(showContent ? 1.0 : 0.9)
                .opacity(showContent ? 1.0 : 0.0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.2)) {
                showContent = true
            }
            
            // Pulsing animation for button highlight
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulseScale = 1.1
            }
        }
    }
}

// MARK: - Button Highlight Overlay

struct ButtonHighlightOverlay: View {
    let buttonFrame: CGRect
    let pulseScale: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            let frame = buttonFrame
            
            ZStack {
                // Dimmed overlay with cutout for button
                Path { path in
                    let screenBounds = geometry.frame(in: .local)
                    path.addRect(screenBounds)
                    path.addEllipse(in: CGRect(
                        x: frame.midX - frame.width / 2 - 15,
                        y: frame.midY - frame.height / 2 - 15,
                        width: frame.width + 30,
                        height: frame.height + 30
                    ))
                }
                .fill(style: FillStyle(eoFill: true))
                .fill(Color.black.opacity(0.4))
                
                // Glowing circle around button
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [.blue.opacity(0.8), .blue.opacity(0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: frame.width + 30, height: frame.height + 30)
                    .position(x: frame.midX, y: frame.midY)
                    .scaleEffect(pulseScale)
                    .shadow(color: .blue.opacity(0.5), radius: 15)
                
                // Arrow pointing to button
                if frame.midY < geometry.size.height / 2 {
                    // Button is in upper half, arrow points down
                    Image(systemName: "arrow.down")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.blue)
                        .position(x: frame.midX, y: frame.midY - frame.height / 2 - 40)
                } else {
                    // Button is in lower half, arrow points up
                    Image(systemName: "arrow.up")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.blue)
                        .position(x: frame.midX, y: frame.midY + frame.height / 2 + 40)
                }
            }
        }
    }
}

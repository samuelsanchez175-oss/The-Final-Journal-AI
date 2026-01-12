import SwiftUI

// MARK: - Achievement Badge View
// Displays achievement badges and celebration popups

struct AchievementBadgeView: View {
    let achievement: Achievement
    let size: CGFloat
    
    init(achievement: Achievement, size: CGFloat = 80) {
        self.achievement = achievement
        self.size = size
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        achievement.unlockedAt != nil
                            ? LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [.gray.opacity(0.3), .gray.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                    )
                    .frame(width: size, height: size)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: size * 0.4, weight: .semibold))
                    .foregroundStyle(achievement.unlockedAt != nil ? .white : .gray)
                
                if achievement.unlockedAt != nil {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: size * 0.3))
                        .foregroundStyle(.white)
                        .offset(x: size * 0.35, y: -size * 0.35)
                }
            }
            
            if size > 60 {
                VStack(spacing: 4) {
                    Text(achievement.title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    if achievement.unlockedAt == nil {
                        Text("\(Int(achievement.progress * 100))%")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: size + 20)
            }
        }
    }
}

// MARK: - Achievement Celebration View
// Popup shown when achievement is unlocked

struct AchievementCelebrationView: View {
    let achievement: Achievement
    let onDismiss: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.0
    @State private var rotation: Double = -180
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            
            VStack(spacing: 24) {
                // Achievement badge with animation
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .shadow(color: .blue.opacity(0.5), radius: 20, x: 0, y: 10)
                    
                    Image(systemName: achievement.icon)
                        .font(.system(size: 50, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    // Sparkle effect
                    ForEach(0..<8) { index in
                        Image(systemName: "sparkle")
                            .font(.system(size: 12))
                            .foregroundStyle(.white)
                            .offset(
                                x: cos(Double(index) * .pi / 4) * 70,
                                y: sin(Double(index) * .pi / 4) * 70
                            )
                            .opacity(opacity)
                    }
                }
                .scaleEffect(scale)
                .rotationEffect(.degrees(rotation))
                
                VStack(spacing: 8) {
                    Text("Achievement Unlocked!")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.primary)
                    
                    Text(achievement.title)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.blue)
                    
                    Text(achievement.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Button {
                    dismiss()
                } label: {
                    Text("Awesome!")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(.blue)
                        )
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
            )
            .padding(40)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
                rotation = 0
            }
            
            // Haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
    
    private func dismiss() {
        withAnimation(.easeOut(duration: 0.3)) {
            scale = 0.8
            opacity = 0.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}

// MARK: - Achievement Collection View
// Shows all achievements in a grid

struct AchievementCollectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedCategory: AchievementCategory? = nil
    
    private var achievements: [Achievement] {
        let all = AchievementSystem.shared.getAllAchievements()
        if let category = selectedCategory {
            return all.filter { $0.category == category }
        }
        return all
    }
    
    private var unlockedCount: Int {
        AchievementSystem.shared.getUnlockedAchievements().count
    }
    
    private var totalCount: Int {
        AchievementSystem.shared.getAllAchievements().count
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header stats
                    VStack(spacing: 8) {
                        Text("\(unlockedCount) / \(totalCount)")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundStyle(.blue)
                        
                        Text("Achievements Unlocked")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.gray.opacity(0.2))
                                    .frame(height: 8)
                                
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        LinearGradient(
                                            colors: [.blue, .purple],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(
                                        width: geometry.size.width * (Double(unlockedCount) / Double(totalCount)),
                                        height: 8
                                    )
                            }
                        }
                        .frame(height: 8)
                        .padding(.horizontal, 40)
                    }
                    .padding(.top, 20)
                    
                    // Category filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            CategoryFilterButton(
                                category: nil,
                                isSelected: selectedCategory == nil,
                                action: { selectedCategory = nil }
                            )
                            
                            ForEach(AchievementCategory.allCases, id: \.self) { category in
                                CategoryFilterButton(
                                    category: category,
                                    isSelected: selectedCategory == category,
                                    action: { selectedCategory = category }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Achievements grid
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 24) {
                        ForEach(achievements) { achievement in
                            AchievementBadgeView(achievement: achievement, size: 100)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                    .ignoresSafeArea()
            )
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Category Filter Button

struct CategoryFilterButton: View {
    let category: AchievementCategory?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category?.rawValue ?? "All")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Group {
                        if isSelected {
                            Capsule(style: .continuous)
                                .fill(Color.blue)
                        } else {
                            Capsule(style: .continuous)
                                .fill(.ultraThinMaterial)
                        }
                    }
                )
        }
    }
}

// MARK: - Achievement Category Extensions

extension AchievementCategory: CaseIterable {
    static var allCases: [AchievementCategory] {
        [.writing, .words, .streak, .features, .quality]
    }
}

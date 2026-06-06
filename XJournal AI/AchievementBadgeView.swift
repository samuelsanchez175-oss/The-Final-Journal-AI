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
                let unlocked = achievement.unlockedAt != nil
                Circle()
                    .fill(Momentum.surfaceElevated)
                    .overlay(Circle().stroke(unlocked ? Momentum.accent : Momentum.hairline,
                                             lineWidth: unlocked ? Momentum.lineThick : Momentum.lineThin))
                    .frame(width: size, height: size)

                Image(systemName: achievement.icon)
                    .font(.system(size: size * 0.4, weight: .semibold))
                    .foregroundStyle(unlocked ? Momentum.contentPrimary : Momentum.contentSecondary)

                if unlocked {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: size * 0.3))
                        .foregroundStyle(Momentum.accent)
                        .offset(x: size * 0.35, y: -size * 0.35)
                }
            }

            if size > 60 {
                VStack(spacing: 4) {
                    Text(achievement.title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Momentum.contentPrimary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)

                    if achievement.unlockedAt == nil {
                        Text("\(Int(achievement.progress * 100))%")
                            .font(.caption2)
                            .foregroundStyle(Momentum.contentSecondary)
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
                    Circle().stroke(Momentum.contentPrimary.opacity(0.15), lineWidth: Momentum.lineThin)
                        .frame(width: 120, height: 120)
                    Circle().stroke(Momentum.contentPrimary.opacity(0.3), lineWidth: Momentum.lineThin)
                        .frame(width: 86, height: 86)
                    Circle().stroke(Momentum.accent, lineWidth: Momentum.lineThick)
                        .frame(width: 56, height: 56)

                    Image(systemName: achievement.icon)
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundStyle(Momentum.contentPrimary)
                    
                    // Sparkle effect
                    ForEach(0..<8) { index in
                        Image(systemName: "sparkle")
                            .font(.system(size: 12))
                            .foregroundStyle(Momentum.accent)
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
                        .foregroundStyle(Momentum.contentPrimary)

                    Text(achievement.title)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Momentum.accent)

                    Text(achievement.description)
                        .font(.subheadline)
                        .foregroundStyle(Momentum.contentSecondary)
                        .multilineTextAlignment(.center)
                }

                Button {
                    dismiss()
                } label: {
                    Text("Awesome!").frame(maxWidth: .infinity)
                }
                .buttonStyle(MomentumSquareButtonStyle(fill: .inverse))
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Momentum.surfaceElevated)
                    .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Momentum.hairline, lineWidth: Momentum.lineThin))
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
            HapticFeedbackManager.shared.success()
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
                            .foregroundStyle(Momentum.accent)
                        
                        Text("Achievements Unlocked")
                            .font(.headline)
                            .foregroundStyle(Momentum.contentSecondary)
                        
                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Momentum.hairline)
                                    .frame(height: 8)
                                
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Momentum.accent)
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
                    .fill(Momentum.surfaceElevated)
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
        MomentumChip(title: category?.rawValue ?? "All", active: isSelected, action: action)
    }
}

// MARK: - Achievement Category Extensions

extension AchievementCategory: CaseIterable {
    static var allCases: [AchievementCategory] {
        [.writing, .words, .streak, .features, .quality]
    }
}

import SwiftUI

// MARK: - Writers Critique Sheet

struct WritersCritiqueSheet: View {
    let mode: SignalMode
    let profile: SignalProfile
    @Environment(\.dismiss) private var dismiss
    
    private var critique: WritersCritique {
        WritersCritiqueGenerator.shared.generateCritique(for: mode, profile: profile)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header Section
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "book.closed.fill")
                                .font(.title2)
                                .foregroundStyle(.orange)
                            Text("Writer's Room")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        
                        Text("What kind of writer you're being right now")
                            .font(.subheadline)
                            .foregroundStyle(Momentum.contentSecondary)
                    }
                    .padding(.bottom, 8)
                    
                    Divider()
                    
                    // Mode Explanation
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Current Mode")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        Text(critique.modeExplanation)
                            .font(.body)
                            .foregroundStyle(Momentum.contentSecondary)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.orange.opacity(0.1))
                            )
                    }
                    
                    // What's Allowed
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text("What's Allowed")
                                .font(.headline)
                        }
                        
                        Text(critique.whatIsAllowed)
                            .font(.body)
                            .foregroundStyle(Momentum.contentSecondary)
                    }
                    
                    // What's Unsafe
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                            Text("What's Unsafe")
                                .font(.headline)
                        }
                        
                        Text(critique.whatIsUnsafe)
                            .font(.body)
                            .foregroundStyle(Momentum.contentSecondary)
                    }
                    
                    // What's Premature
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 6) {
                            Image(systemName: "clock.fill")
                                .foregroundStyle(.red)
                            Text("What's Premature")
                                .font(.headline)
                        }
                        
                        Text(critique.whatIsPremature)
                            .font(.body)
                            .foregroundStyle(Momentum.contentSecondary)
                    }
                    
                    // Full Critique
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Full Critique")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        Text(critique.fullCritique)
                            .font(.body)
                            .foregroundStyle(.primary)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.orange.opacity(0.15))
                            )
                    }
                    
                    // Note about Signal Notes
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How This Connects to Signal Notes")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        Text("The Signal Notes you see on suggestions are based on this mode. They explain why certain lines work or don't work within your current writing posture.")
                            .font(.caption)
                            .foregroundStyle(Momentum.contentSecondary)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.blue.opacity(0.1))
                            )
                    }
                }
                .padding()
            }
            .navigationTitle("Writer's Critique")
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

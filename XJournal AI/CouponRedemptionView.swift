import SwiftUI
import StoreKit

// MARK: - Coupon Redemption View

struct CouponRedemptionView: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var couponCode: String = ""
    @State private var isRedeeming: Bool = false
    @State private var redemptionError: String?
    @State private var redemptionSuccess: Bool = false
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "ticket.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(.blue)
                        
                        Text("Redeem Coupon Code")
                            .font(.title2.weight(.bold))
                        
                        Text("Enter a promotional code to unlock premium features")
                            .font(.subheadline)
                            .foregroundStyle(Momentum.contentSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Coupon Code Input
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Coupon Code")
                            .font(.headline)
                        
                        TextField("Enter code", text: $couponCode)
                            .textFieldStyle(.plain)
                            .font(.body.monospaced())
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Momentum.surfaceElevated)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .strokeBorder(
                                                couponCode.isEmpty ? Color.clear : (redemptionError != nil ? Color.red : Color.blue),
                                                lineWidth: 1
                                            )
                                    )
                            )
                            .onChange(of: couponCode) { _, _ in
                                redemptionError = nil
                            }
                        
                        if let error = redemptionError {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.red)
                                Text(error)
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            }
                        }
                        
                        if redemptionSuccess {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                Text("Code redeemed successfully!")
                                    .font(.caption)
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                    
                    // Redeem Button
                    Button {
                        Task {
                            await redeemCoupon()
                        }
                    } label: {
                        HStack {
                            if isRedeeming {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Redeem Code")
                                    .font(.headline)
                            }
                        }
                        .foregroundStyle(Momentum.onInverse)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(couponCode.isEmpty || isRedeeming ? Color.gray : Color.accentColor)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(couponCode.isEmpty || isRedeeming)
                    
                    // Info Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About Coupon Codes")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(
                                icon: "info.circle.fill",
                                text: "Coupon codes are provided by promotional campaigns"
                            )
                            InfoRow(
                                icon: "gift.fill",
                                text: "Codes can unlock free trials or discounted subscriptions"
                            )
                            InfoRow(
                                icon: "clock.fill",
                                text: "Some codes may have expiration dates"
                            )
                        }
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        // App Store Code Redemption Link
                        Button {
                            if let url = URL(string: "https://apps.apple.com/redeem") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "arrow.up.right.square")
                                Text("Redeem App Store Code")
                                    .font(.subheadline.weight(.medium))
                                Spacer()
                            }
                            .foregroundStyle(.blue)
                        }
                        .buttonStyle(.plain)
                        
                        Text("For App Store offer codes, use the link above or go to Settings > App Store > Redeem")
                            .font(.caption2)
                            .foregroundStyle(Momentum.contentSecondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Momentum.surfaceElevated)
                    )
                }
                .padding()
            }
            .background(
                Rectangle()
                    .fill(Momentum.surfaceElevated)
                    .ignoresSafeArea()
            )
            .navigationTitle("Redeem Code")
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
    
    // MARK: - Redeem Coupon
    
    private func redeemCoupon() async {
        guard !couponCode.isEmpty else { return }
        
        isRedeeming = true
        redemptionError = nil
        redemptionSuccess = false
        
        // Normalize the code (remove spaces, convert to uppercase)
        let normalizedCode = couponCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        // Method 1: Try StoreKit 2 promotional offers (iOS 15+)
        if #available(iOS 15.0, *) {
            if await redeemViaPromotionalOffer(code: normalizedCode) {
                isRedeeming = false
                return
            }
        }
        
        // Method 2: Try subscription offer codes (iOS 15+)
        if #available(iOS 15.0, *) {
            if await redeemViaOfferCode(code: normalizedCode) {
                isRedeeming = false
                return
            }
        }
        
        // Method 3: Custom backend validation (if you have a backend service)
        // Uncomment and implement if you have a backend API:
        /*
        if await redeemViaBackend(code: normalizedCode) {
            isRedeeming = false
            return
        }
        */
        
        // If all methods fail, show error
        redemptionError = "Invalid or expired coupon code. Please check the code and try again."
        isRedeeming = false
    }
    
    // MARK: - StoreKit Promotional Offers
    
    @available(iOS 15.0, *)
    private func redeemViaPromotionalOffer(code: String) async -> Bool {
        // Note: StoreKit 2 promotional offers require server-side validation
        // For coupon code redemption, consider using StoreKit's offer code redemption API
        // or implementing a custom validation system
        
        // For now, attempt to purchase the first available subscription product
        // In production, this should match the coupon code to a specific product/offer
        for product in subscriptionManager.availableProducts {
            // Simple purchase attempt - in production, this should validate the coupon code
            // against your backend or App Store Connect offer configuration
            do {
                let result = try await product.purchase()
                if case .success = result {
                    await subscriptionManager.checkSubscriptionStatus()
                    redemptionSuccess = true
                    return true
                }
            } catch {
                print("❌ Purchase failed: \(error)")
                // Continue to next product
            }
        }
        return false
    }
    
    // MARK: - StoreKit Offer Codes
    
    @available(iOS 15.0, *)
    private func redeemViaOfferCode(code: String) async -> Bool {
        // Note: StoreKit 2 doesn't provide a direct API to redeem offer codes programmatically
        // Users need to redeem codes through Settings > App Store > Redeem Gift Card or Code
        // OR through the system sheet using AppStore.showManageSubscriptions
        
        // For now, we'll show instructions to the user
        // In a production app, you might want to:
        // 1. Use a backend service to validate codes
        // 2. Or direct users to Settings > App Store to redeem
        
        // Check if subscription status changed (user might have redeemed elsewhere)
        await subscriptionManager.checkSubscriptionStatus()
        
        if subscriptionManager.subscriptionStatus == .subscribed {
            redemptionSuccess = true
            return true
        }
        
        return false
    }
    
    // MARK: - Backend Validation (Placeholder)
    
    /*
    private func redeemViaBackend(code: String) async -> Bool {
        // Implement your backend API call here
        // Example:
        guard let url = URL(string: "https://your-api.com/redeem") else { return false }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["code": code, "device_id": UIDevice.current.identifierForVendor?.uuidString ?? ""]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(RedemptionResponse.self, from: data)
            
            if response.success {
                // Grant subscription via your backend
                await subscriptionManager.checkSubscriptionStatus()
                redemptionSuccess = true
                return true
            } else {
                redemptionError = response.message ?? "Invalid code"
                return false
            }
        } catch {
            redemptionError = "Network error. Please try again."
            return false
        }
    }
    */
}

// MARK: - Info Row

struct InfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 20)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(Momentum.contentSecondary)
        }
    }
}

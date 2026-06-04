import SwiftUI

struct ProviderPricingView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Cost per Ghost suggestion").font(.headline)
            Text("Your AI key decides which model runs. Rough estimates (~750 in / 40 out).")
                .font(.caption).foregroundStyle(.secondary)
            ForEach(ProviderPricing.all) { p in
                HStack {
                    Text(p.provider).fontWeight(.medium)
                    Text(p.model).font(.caption).foregroundStyle(.secondary)
                    Spacer()
                    Text(p.perSuggestion).monospacedDigit()
                }
                .padding(.vertical, 2)
                Divider().opacity(0.3)
            }
            Text("Free Ghost is always $0 (offline).").font(.footnote).foregroundStyle(.secondary)
        }
        .padding()
    }
}

//
//  LuxuryLexiconService.swift
//  XJournal AI
//
//  Model G Core v1.0 — Theme/style-aware luxury layer sampling.
//

import Foundation

final class LuxuryLexiconService {
    private let store: LuxuryLexiconStore

    init(store: LuxuryLexiconStore = .shared) {
        self.store = store
    }

    func sampleForContext(
        theme: String,
        style: StyleProfile,
        volume: SignalVolume,
        barIndex: Int = 0,
        isHook: Bool = false
    ) -> LuxuryLayer {
        let themeLower = theme.lowercased()
        let wealthForwardTheme = themeLower.contains("wealth")
            || themeLower.contains("luxury")
            || themeLower.contains("status")
            || themeLower.contains("fashion")

        let styleHint = style.name
        let brandLimit: Int = {
            switch volume {
            case .loud:
                return wealthForwardTheme ? 3 : 2
            case .mixed:
                return wealthForwardTheme ? 2 : 1
            case .subtle:
                return 0
            }
        }()
        let specLimit: Int = {
            switch volume {
            case .loud:
                return 2
            case .mixed:
                return 2
            case .subtle:
                return 3
            }
        }()
        let environmentLimit = isHook ? 1 : 2
        let provenanceLimit = (!isHook && barIndex % 3 == 0) ? 1 : 0
        let archiveLimit = (!isHook && barIndex % 5 == 0) ? 1 : 0

        let brands = store.sample(
            category: .brand,
            volume: volume,
            styleHint: styleHint,
            limit: brandLimit
        )
        let specs = store.sample(
            category: .spec,
            volume: volume,
            styleHint: styleHint,
            limit: specLimit
        )
        let environments = store.sample(
            category: .environment,
            volume: volume,
            styleHint: styleHint,
            limit: environmentLimit
        )
        let provenance = store.sample(
            category: .provenance,
            volume: volume,
            styleHint: styleHint,
            limit: provenanceLimit
        )
        let archives = store.sample(
            category: .archive,
            volume: volume,
            styleHint: styleHint,
            limit: archiveLimit
        )

        return LuxuryLayer(
            brands: brands,
            specs: specs,
            environments: environments,
            provenance: provenance,
            archives: archives
        )
    }
}

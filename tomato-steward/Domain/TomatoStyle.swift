import Foundation

enum TomatoStyle: String, CaseIterable, Codable, Identifiable {
    case diced
    case wholePeeled
    case crushed
    case stewed

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .diced: return "Diced"
        case .wholePeeled: return "Whole Peeled"
        case .crushed: return "Crushed"
        case .stewed: return "Stewed"
        }
    }

    /// Multiplicative time factor based on style surface area and prep.
    var reductionFactor: Double {
        switch self {
        case .diced: return 0.95
        case .wholePeeled: return 1.10
        case .crushed: return 1.00
        case .stewed: return 1.08
        }
    }
}


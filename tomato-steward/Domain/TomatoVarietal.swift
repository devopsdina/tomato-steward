import Foundation

enum TomatoVarietal: String, CaseIterable, Codable, Identifiable {
    case roma
    case sanMarzano
    case cherry
    case genovese
    case beefsteak
    case plum

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .roma: return "Roma"
        case .sanMarzano: return "San Marzano"
        case .cherry: return "Cherry"
        case .genovese: return "Genovese"
        case .beefsteak: return "Beefsteak"
        case .plum: return "Plum"
        }
    }

    /// Multiplicative time factor based on varietal moisture and structure.
    var reductionFactor: Double {
        switch self {
        case .roma: return 1.00
        case .sanMarzano: return 0.95
        case .cherry: return 1.10
        case .genovese: return 1.05
        case .beefsteak: return 1.12
        case .plum: return 1.02
        }
    }
}


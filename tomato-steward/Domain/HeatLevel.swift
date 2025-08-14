import Foundation

enum HeatLevel: String, Codable, CaseIterable, Identifiable {
    case lowSimmer
    case mediumSimmer

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .lowSimmer: return "Low Simmer"
        case .mediumSimmer: return "Medium Simmer"
        }
    }

    var fahrenheitRangeText: String {
        switch self {
        case .lowSimmer: return "≈185–200°F"
        case .mediumSimmer: return "≈195–205°F"
        }
    }

    var celsiusRangeText: String {
        switch self {
        case .lowSimmer: return "≈85–93°C"
        case .mediumSimmer: return "≈90–96°C"
        }
    }
}


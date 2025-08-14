import Foundation

struct StewPlan: Codable, Equatable {
    let totalMinutes: Int
    let heatLevel: HeatLevel
    let rationale: String
    let advancedTips: [String]

    var fahrenheitText: String {
        "\(heatLevel.displayName) (\(heatLevel.fahrenheitRangeText))"
    }

    var celsiusText: String {
        "\(heatLevel.displayName) (\(heatLevel.celsiusRangeText))"
    }
}


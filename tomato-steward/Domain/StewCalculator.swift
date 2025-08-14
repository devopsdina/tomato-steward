import Foundation

enum ReductionModel: String {
    case v1
    case v2
}

struct StewCalculator {
    static func computePlan(
        inputs: StewInputs,
        model: ReductionModel,
        includeAdvancedTips: Bool
    ) -> StewPlan {
        let baseMinutes: Double
        let exponent: Double
        let varietalFactor: Double
        let styleFactor: Double

        switch model {
        case .v1:
            baseMinutes = 30.0
            exponent = 0.85
            varietalFactor = inputs.varietal.reductionFactor
            styleFactor = inputs.style.reductionFactor
        case .v2:
            baseMinutes = 28.0
            exponent = 0.90
            varietalFactor = inputs.varietal.reductionFactor * 1.03
            styleFactor = inputs.style.reductionFactor
        }

        let weightScale = pow(inputs.weightOunces / 28.0, exponent)
        var minutes = baseMinutes * weightScale * varietalFactor * styleFactor

        // Clamp 20…120 minutes
        minutes = max(20.0, min(120.0, minutes))

        let heat: HeatLevel = minutes < 35.0 ? .lowSimmer : .mediumSimmer
        let roundedMinutes = Int(round(minutes))

        let rationale = rationaleText(inputs: inputs, minutes: roundedMinutes, model: model)
        let tips = includeAdvancedTips ? advancedTips(for: inputs) : []

        return StewPlan(
            totalMinutes: roundedMinutes,
            heatLevel: heat,
            rationale: rationale,
            advancedTips: tips
        )
    }

    private static func rationaleText(inputs: StewInputs, minutes: Int, model: ReductionModel) -> String {
        "Based on \(Int(round(inputs.weightOunces))) oz, \(inputs.varietal.displayName) and \(inputs.style.displayName), model \(model.rawValue) suggests \(minutes) min."
    }

    private static func advancedTips(for inputs: StewInputs) -> [String] {
        var tips: [String] = []
        switch inputs.style {
        case .wholePeeled:
            tips.append("Crush by hand after 10–15 min to increase surface area.")
        default:
            break
        }
        switch inputs.varietal {
        case .cherry, .beefsteak:
            tips.append("Simmer partially uncovered to aid reduction.")
        default:
            break
        }
        tips.append("Stir every 5–7 min to prevent scorching; add salt early, basil late; finish with olive oil off-heat.")
        return tips
    }
}


import Foundation

struct StewInputs: Codable, Equatable {
    var weightOunces: Double
    var varietal: TomatoVarietal
    var style: TomatoStyle

    static let minWeight: Double = 4.0
    static let maxWeight: Double = 128.0

    func validationError() -> String? {
        if weightOunces.isNaN || !weightOunces.isFinite {
            return "Please enter a valid number of ounces."
        }
        if weightOunces < StewInputs.minWeight || weightOunces > StewInputs.maxWeight {
            return "Weight must be between 4 and 128 ounces."
        }
        return nil
    }
}


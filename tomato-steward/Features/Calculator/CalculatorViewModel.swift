import Foundation
import Combine

final class CalculatorViewModel: ObservableObject {
    @Published var weightText: String = "28"
    @Published var selectedVarietal: TomatoVarietal = .roma
    @Published var selectedStyle: TomatoStyle = .crushed
    @Published private(set) var plan: StewPlan?
    @Published private(set) var validationMessage: String?
    @Published private(set) var useCelsius: Bool = false

    private let ldService: LaunchDarklyService
    private let settingsStore: SettingsStore
    private var cancellables = Set<AnyCancellable>()

    init(ldService: LaunchDarklyService, settingsStore: SettingsStore) {
        self.ldService = ldService
        self.settingsStore = settingsStore

        // Load persisted inputs
        if let last = settingsStore.loadLastInputs() {
            weightText = String(format: "%.0f", last.weightOunces)
            selectedVarietal = last.varietal
            selectedStyle = last.style
        }

        // Units preference
        useCelsius = settingsStore.preferredUnitsIsCelsius()

        // Observe default units flag
        ldService.$defaultCelsius
            .receive(on: DispatchQueue.main)
            .sink { [weak self] defaultCelsius in
                guard let self = self else { return }
                // Default units flag only influences initial preference if not set by user
                if self.plan == nil {
                    self.useCelsius = defaultCelsius
                }
            }
            .store(in: &cancellables)
    }

    func toggleUnits() {
        useCelsius.toggle()
        settingsStore.savePreferredUnits(isCelsius: useCelsius)
    }

    func computePlan() {
        guard let weight = Double(weightText) else {
            validationMessage = "Please enter a valid number of ounces."
            return
        }
        let inputs = StewInputs(weightOunces: weight, varietal: selectedVarietal, style: selectedStyle)
        if let error = inputs.validationError() {
            validationMessage = error
            return
        }
        validationMessage = nil

        let model: ReductionModel = ldService.algoReductionModel == "v2" ? .v2 : .v1
        let includeTips = ldService.showAdvancedTips
        let result = StewCalculator.computePlan(inputs: inputs, model: model, includeAdvancedTips: includeTips)
        plan = result
        settingsStore.saveLastInputs(inputs)
    }

    func clearPlan() {
        plan = nil
        validationMessage = nil
    }
}


import Foundation

final class SettingsStore {
    private let userDefaults: UserDefaults
    private let lastInputsKey = "lastInputs"
    private let preferredUnitsKey = "preferredUnits"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func saveLastInputs(_ inputs: StewInputs) {
        do {
            let data = try JSONEncoder().encode(inputs)
            userDefaults.set(data, forKey: lastInputsKey)
        } catch {
            // Persist errors are non-fatal; ignore
        }
    }

    func loadLastInputs() -> StewInputs? {
        guard let data = userDefaults.data(forKey: lastInputsKey) else { return nil }
        return try? JSONDecoder().decode(StewInputs.self, from: data)
    }

    func savePreferredUnits(isCelsius: Bool) {
        userDefaults.set(isCelsius ? "C" : "F", forKey: preferredUnitsKey)
    }

    func preferredUnitsIsCelsius() -> Bool {
        let value = userDefaults.string(forKey: preferredUnitsKey) ?? "F"
        return value == "C"
    }
}


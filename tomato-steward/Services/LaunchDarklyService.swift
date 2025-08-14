import Foundation
import Combine

// Import LaunchDarkly at compile time only when the pod is available.
#if canImport(LaunchDarkly)
import LaunchDarkly
#endif

struct Flags: Equatable {
    var algoReductionModel: String = "v1"
    var showAdvancedTips: Bool = false
    var enableLogin: Bool = false
    var defaultCelsius: Bool = false
    var showUnitsToggle: Bool = true
    var showThemeToggle: Bool = false
}

final class LaunchDarklyService: ObservableObject {
    static let shared = LaunchDarklyService()

    @Published private(set) var flags = Flags()

    private var ldClient: AnyObject?
    private let deviceKey: String = {
        if let existing = UserDefaults.standard.string(forKey: "device_uuid") {
            return existing
        }
        let newId = UUID().uuidString
        UserDefaults.standard.set(newId, forKey: "device_uuid")
        return newId
    }()

    private func logFlags(_ flags: Flags, context: String) {
        let lines = [
            "🚩 [LaunchDarkly] \(context)",
            "  algo.reductionModel = \(flags.algoReductionModel)",
            "  ui.showAdvancedTips = \(flags.showAdvancedTips)",
            "  ui.enableLogin = \(flags.enableLogin)",
            "  units.defaultCelsius = \(flags.defaultCelsius)",
            "  ui.showUnitsToggle = \(flags.showUnitsToggle)",
            "  ui.theme = \(flags.showThemeToggle)"
        ]
        print(lines.joined(separator: "\n"))
    }

    func configure(sdkKey: String) {
        #if canImport(LaunchDarkly)
        guard !sdkKey.isEmpty else {
            // No SDK key; keep defaults and operate offline
            print("🚩 [LaunchDarkly] No SDK key present. Operating with default flags (offline).")
            logFlags(flags, context: "defaults")
            return
        }
        let config = LDConfig(mobileKey: sdkKey)
        let user = LDUser(key: deviceKey)
        LDClient.start(config: config, user: user)
        ldClient = LDClient.get() as AnyObject?
        print("🚩 [LaunchDarkly] Client started. Fetching flags…")
        refreshFlags()
        #else
        print("🚩 [LaunchDarkly] SDK unavailable at build time. Using default flags.")
        logFlags(flags, context: "defaults")
        #endif
    }

    func refreshFlags() {
        #if canImport(LaunchDarkly)
        guard let client = LDClient.get() else { return }
        let algo = client.stringVariation(forKey: "algo.reductionModel", defaultValue: "v1")
        let tips = client.boolVariation(forKey: "ui.showAdvancedTips", defaultValue: false)
        let login = client.boolVariation(forKey: "ui.enableLogin", defaultValue: false)
        let celsius = client.boolVariation(forKey: "units.defaultCelsius", defaultValue: false)
        let unitsToggle = client.boolVariation(forKey: "ui.showUnitsToggle", defaultValue: true)
        let newFlags = Flags(
            algoReductionModel: algo,
            showAdvancedTips: tips,
            enableLogin: login,
            defaultCelsius: celsius,
            showUnitsToggle: unitsToggle,
            showThemeToggle: client.boolVariation(forKey: "ui.theme", defaultValue: false)
        )
        DispatchQueue.main.async {
            self.flags = newFlags
            self.logFlags(newFlags, context: "fetched")
        }
        #endif
    }
}


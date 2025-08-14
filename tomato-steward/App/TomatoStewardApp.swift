import SwiftUI

@main
struct TomatoStewardApp: App {
    private let settingsStore = SettingsStore()
    private let ldService = LaunchDarklyService.shared

    init() {
        // Prefer Info.plist key `LD_MOBILE_KEY`. Fallback to env var of same name.
        let sdkKey = (Bundle.main.object(forInfoDictionaryKey: "LD_MOBILE_KEY") as? String)
            ?? ProcessInfo.processInfo.environment["LD_MOBILE_KEY"]
            ?? ProcessInfo.processInfo.environment["LAUNCHDARKLY_SDK_KEY"]
            ?? ""
        ldService.configure(sdkKey: sdkKey)

        // Apply global brand appearances
        Brand.applyAppearance()
    }

    var body: some Scene {
        WindowGroup {
            RootView(
                ldService: ldService,
                settingsStore: settingsStore
            )
            .tint(Brand.primary)
        }
    }
}


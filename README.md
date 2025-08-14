# Tomato Steward (iOS • Swift • CocoaPods • LaunchDarkly)

Tomato Steward computes a recommendation for how long to stew tomatoes and how much heat to use for optimal marinara flavor. The main objective with the app is to show how to use LaunchDarkly feature flags and context in an iOS app.  This app is not meant to be published to the app store, or have ci/cd setup.  It is just meant for a code example.

- Inputs: weight (oz), varietal, style
- Outputs: total time (minutes), heat guidance with temperatures in °F/°C, rationale, optional advanced tips

## Tech
- Swift 5.9+, iOS 15+
- MVVM with a small domain layer
- SwiftUI layout; MaterialComponents for styled controls
- LaunchDarkly for feature flags
- Persistence via UserDefaults only

## Setup
1) Create an Xcode iOS App project named `TomatoSteward` (Swift, SwiftUI, iOS 15+), saved at the repo root.
2) Install pods:
```bash
cd .
pod install
open TomatoSteward.xcworkspace
```
3) Add your LaunchDarkly mobile SDK key:
   - Option A (preferred, no code changes): In Xcode, select Product → Scheme → Edit Scheme… → Run → Arguments → Environment Variables, then add:
     - `LD_MOBILE_KEY = <your_key>`
   - Option B (Info.plist): Add an Info.plist key `LD_MOBILE_KEY` with your key value.
   - Option C (environment alternative): set `LAUNCHDARKLY_SDK_KEY` in the Run scheme’s Environment Variables.
   The app will read `LD_MOBILE_KEY` from Info.plist, `LD_MOBILE_KEY` env var, then `LAUNCHDARKLY_SDK_KEY` env var (first non-empty wins).

4) Build the app in xCode and use the simulator.  Logging is set to show the default values of the feature flags.

## Feature Flags (keys and defaults)
- `algo.reductionModel` (string) — default "v1"; "v2" enables alternate formula. Located in the `Services.LaunchDarklyService.swift`
- `ui.showAdvancedTips` (bool) — default false
- `ui.enableLogin` (bool) — default false
- `units.defaultCelsius` (bool) — default false
- `ui.showUnitsToggle` (bool) — default false
- `ui.DarkMode` (bool) — default false (light mode)

## Algorithm Summary
Baseline (v1): time = 30 * (weight_oz / 28)^0.85 * varietalFactor * styleFactor

Alternate (v2): time = 28 * (weight_oz / 28)^0.90 * (varietalFactor * 1.03) * styleFactor

Clamp 20…120 minutes. If time < 35 → Low Simmer (≈185–200°F / 85–93°C), else Medium Simmer (≈195–205°F / 90–96°C).

## Persistence
- `lastInputs` (JSON-encoded `StewInputs`)
- `preferredUnits` ("F"/"C")

## Notes
- We are using the SwiftUI App lifecycle, our main entry point is `App/TomatoStewardApp.swift`.  This file handles app initialization & global configuration. Other iOS repos may have `AppDelegate.swift` as their main entry if they are using the traditional UIKit approach.
import Foundation
import Combine
import OSLog

// Import LaunchDarkly at compile time only when the pod is available.
#if canImport(LaunchDarkly)
import LaunchDarkly
#endif

final class LaunchDarklyService: ObservableObject {
    static let shared = LaunchDarklyService()

    @Published private(set) var algoReductionModel: String = "v1"
    @Published private(set) var showAdvancedTips: Bool = false
    @Published private(set) var enableLogin: Bool = false
    @Published private(set) var defaultCelsius: Bool = false
    @Published private(set) var showUnitsToggle: Bool = false
    @Published private(set) var isDarkMode: Bool = false

    private var ldClient: AnyObject?
    private let deviceKey: String = {
        if let existing = UserDefaults.standard.string(forKey: "device_uuid") {
            return existing
        }
        let newId = UUID().uuidString
        UserDefaults.standard.set(newId, forKey: "device_uuid")
        return newId
    }()


    
    // Update functions for each flag (following the example pattern)
    private func updateAlgoReductionModel(flagKey: String, value: String, isChange: Bool = false) {
        if isChange { print("! 🧠 [LaunchDarkly] \(flagKey) changed to: \(value)") }
        
        // Handle different algorithm versions
        switch value {
        case "v1":
            print("📊 [LaunchDarkly] Using algorithm v1 - standard reduction model")
        case "v2":
            print("🚀 [LaunchDarkly] Using algorithm v2 - enhanced reduction model")
        default:
            print("⚠️ [LaunchDarkly] Unknown algorithm version: \(value), falling back to standard")
        }
        
        DispatchQueue.main.async {
            self.algoReductionModel = value
        }
    }
    
    private func updateShowAdvancedTips(flagKey: String, value: Bool, isChange: Bool = false) {
        if isChange { print("! 💡 [LaunchDarkly] \(flagKey) changed to: \(value)") }
        
        // Handle on/off states
        if value {
            print("🔛 [LaunchDarkly] Advanced tips enabled - showing detailed cooking guidance")
        } else {
            print("🔴 [LaunchDarkly] Advanced tips disabled - showing basic guidance only")
        }
        
        DispatchQueue.main.async {
            self.showAdvancedTips = value
        }
    }
    
    private func updateEnableLogin(flagKey: String, value: Bool, isChange: Bool = false) {
        if isChange { print("! 🔐 [LaunchDarkly] \(flagKey) changed to: \(value)") }
        
        // Handle on/off states  
        if value {
            print("🔛 [LaunchDarkly] Login enabled - user authentication available")
        } else {
            print("🔴 [LaunchDarkly] Login disabled - running in guest mode")
        }
        
        DispatchQueue.main.async {
            self.enableLogin = value
        }
    }
    
    private func updateDefaultCelsius(flagKey: String, value: Bool, isChange: Bool = false) {
        if isChange { print("! 🌡️ [LaunchDarkly] \(flagKey) changed to: \(value)") }
        
        // Handle on/off states
        if value {
            print("🔛 [LaunchDarkly] Default Celsius enabled - temperature defaults to Celsius")
        } else {
            print("🔴 [LaunchDarkly] Default Celsius disabled - temperature defaults to Fahrenheit")
        }
        
        DispatchQueue.main.async {
            self.defaultCelsius = value
        }
    }
    
    private func updateShowUnitsToggle(flagKey: String, value: Bool, isChange: Bool = false) {
        if isChange { print("! ⚙️ [LaunchDarkly] \(flagKey) changed to: \(value)") }
        
        // Handle on/off states (like the example)
        if value {
            // Toggle ON: Show units toggle in UI
            print("🔛 [LaunchDarkly] Units toggle enabled - showing Celsius/Fahrenheit option")
        } else {
            // Toggle OFF: Hide units toggle in UI  
            print("🔴 [LaunchDarkly] Units toggle disabled - hiding Celsius/Fahrenheit option")
        }
        
        DispatchQueue.main.async {
            self.showUnitsToggle = value
        }
    }
    
    private func updateDarkMode(flagKey: String, value: Bool, isChange: Bool = false) {
        if isChange { print("! 🌙 [LaunchDarkly] \(flagKey) changed to: \(value)") }
        
        // Handle dark mode on/off states (like the example)
        if value {
            print("🔛 [LaunchDarkly] Dark mode enabled - switching to dark theme with brand colors")
            Brand.enableDarkMode()
        } else {
            print("☀️ [LaunchDarkly] Dark mode disabled - switching to light theme with brand colors")
            Brand.enableLightMode()
        }
        
        DispatchQueue.main.async {
            self.isDarkMode = value
        }
    }
    
    func configure(sdkKey: String) {
        #if canImport(LaunchDarkly)
        guard !sdkKey.isEmpty else {
            // No SDK key; keep defaults and operate offline
            print("🚩 [LaunchDarkly] No SDK key present. Operating with default flags (offline).")
            return
        }
        var config = LDConfig(mobileKey: sdkKey, autoEnvAttributes: .enabled)
        config.isDebugMode = true   // Enable flag change logging
        config.diagnosticOptOut = true  // Keep diagnostic reporting disabled
        // config.logger = OSLog.disabled  // Allow SDK logging for flag changes
        var contextBuilder = LDContextBuilder(key: deviceKey)
        contextBuilder.kind("user")
        
        guard case .success(let context) = contextBuilder.build() else {
            print("🚩 [LaunchDarkly] Failed to create context")
            return
        }
        
        print("🚩 [LaunchDarkly] Starting client with 30s timeout...")
        LDClient.start(config: config, context: context, startWaitSeconds: 30)
        
        ldClient = LDClient.get() as AnyObject?
        print("🚩 [LaunchDarkly] Client started. Setting up direct flag observations...")
        
        // Small delay to ensure client is fully ready, then set up observers
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.setupDirectFlagObservations()
        }
        #else
        print("🚩 [LaunchDarkly] SDK unavailable at build time. Using default flags.")
        #endif
    }
    
    private func setupDirectFlagObservations() {
        #if canImport(LaunchDarkly)
        guard let client = LDClient.get() else { 
            print("❌ [DEBUG] LDClient.get() returned nil - cannot set up observers")
            return 
        }
        
        print("✅ [DEBUG] Setting up flag observers...")
        
        // Direct observation for algo.reductionModel
        client.observe(key: "algo.reductionModel", owner: self) { [weak self] changedFlag in
            guard let me = self else { return }
            guard case .string(let value) = changedFlag.newValue else { return }
            me.updateAlgoReductionModel(flagKey: changedFlag.key, value: value, isChange: true)
        }
        let currentAlgo = client.stringVariation(forKey: "algo.reductionModel", defaultValue: "v1")
        updateAlgoReductionModel(flagKey: "algo.reductionModel", value: currentAlgo)
        
        // Direct observation for ui.showAdvancedTips
        client.observe(key: "ui.showAdvancedTips", owner: self) { [weak self] changedFlag in
            guard let me = self else { return }
            guard case .bool(let value) = changedFlag.newValue else { return }
            me.updateShowAdvancedTips(flagKey: changedFlag.key, value: value, isChange: true)
        }
        let currentAdvancedTips = client.boolVariation(forKey: "ui.showAdvancedTips", defaultValue: false)
        updateShowAdvancedTips(flagKey: "ui.showAdvancedTips", value: currentAdvancedTips)
        
        // Direct observation for ui.enableLogin
        client.observe(key: "ui.enableLogin", owner: self) { [weak self] changedFlag in
            guard let me = self else { return }
            guard case .bool(let value) = changedFlag.newValue else { return }
            me.updateEnableLogin(flagKey: changedFlag.key, value: value, isChange: true)
        }
        let currentEnableLogin = client.boolVariation(forKey: "ui.enableLogin", defaultValue: false)
        updateEnableLogin(flagKey: "ui.enableLogin", value: currentEnableLogin)
        
        // Direct observation for units.defaultCelsius
        client.observe(key: "units.defaultCelsius", owner: self) { [weak self] changedFlag in
            guard let me = self else { return }
            guard case .bool(let value) = changedFlag.newValue else { return }
            me.updateDefaultCelsius(flagKey: changedFlag.key, value: value, isChange: true)
        }
        let currentDefaultCelsius = client.boolVariation(forKey: "units.defaultCelsius", defaultValue: false)
        updateDefaultCelsius(flagKey: "units.defaultCelsius", value: currentDefaultCelsius)
        
        // Direct observation for ui.showUnitsToggle (following the example pattern)
        print("🔧 [DEBUG] Registering observer for ui.showUnitsToggle...")
        client.observe(key: "ui.showUnitsToggle", owner: self) { [weak self] changedFlag in
            print("🔄 [DEBUG] ui.showUnitsToggle observer triggered - oldValue: \(changedFlag.oldValue), newValue: \(changedFlag.newValue)")
            guard let me = self else { return }
            guard case .bool(let value) = changedFlag.newValue else { 
                print("❌ [DEBUG] ui.showUnitsToggle newValue is not a bool: \(changedFlag.newValue)")
                return 
            }
            me.updateShowUnitsToggle(flagKey: changedFlag.key, value: value, isChange: true)
            print("🔄 [DEBUG] showUnitsToggle updated via function")
        }
        
        // Immediately get current value and update UI (like the example)
        let currentUnitsToggle = client.boolVariation(forKey: "ui.showUnitsToggle", defaultValue: false)
        print("🎯 [DEBUG] Current ui.showUnitsToggle from SDK: \(currentUnitsToggle)")
        updateShowUnitsToggle(flagKey: "ui.showUnitsToggle", value: currentUnitsToggle)
        print("✅ [DEBUG] ui.showUnitsToggle set to current value: \(currentUnitsToggle)")
        
        // Direct observation for ui.DarkMode
        client.observe(key: "ui.DarkMode", owner: self) { [weak self] changedFlag in
            guard let me = self else { return }
            guard case .bool(let value) = changedFlag.newValue else { return }
            me.updateDarkMode(flagKey: changedFlag.key, value: value, isChange: true)
        }
        let currentDarkMode = client.boolVariation(forKey: "ui.DarkMode", defaultValue: false)
        updateDarkMode(flagKey: "ui.DarkMode", value: currentDarkMode)
        
        print("🎯 [DEBUG] All observers registered and current values set")
        #endif
    }
    
    deinit {
        // Clean up observers when service is deallocated
        #if canImport(LaunchDarkly)
        LDClient.get()?.stopObserving(owner: self)
        #endif
    }
}


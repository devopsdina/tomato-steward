import SwiftUI

struct RootView: View {
    let ldService: LaunchDarklyService
    let settingsStore: SettingsStore

    @State private var isReady: Bool = false

    var body: some View {
        Group {
            if isReady {
                CalculatorView(
                    viewModel: CalculatorViewModel(
                        ldService: ldService,
                        settingsStore: settingsStore
                    )
                )
            } else {
                SplashView()
            }
        }
        .task {
            // Simulate startup work while feature flags/config load.
            // If LaunchDarkly completes faster, we still show a short splash for polish.
            try? await Task.sleep(nanoseconds: 800_000_000) // 0.8s
            withAnimation(.easeOut(duration: 0.25)) {
                isReady = true
            }
        }
    }
}

#if DEBUG
struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(ldService: LaunchDarklyService.shared, settingsStore: SettingsStore())
    }
}
#endif



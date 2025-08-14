import SwiftUI

struct SplashView: View {
    @State private var isPulsing: Bool = false

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Text("Tomato")
                    .foregroundColor(Brand.title)
                    .font(.system(size: 42, weight: .bold, design: .rounded))

                HStack(spacing: 12) {
                    Text("🍅")
                    Text("🇮🇹")
                }
                .font(.system(size: 64))
                .scaleEffect(isPulsing ? 1.08 : 0.92)
                .opacity(isPulsing ? 1.0 : 0.85)
                .animation(
                    .easeInOut(duration: 0.9)
                    .repeatForever(autoreverses: true),
                    value: isPulsing
                )

                Text("Steward")
                    .foregroundColor(Brand.title)
                    .font(.system(size: 42, weight: .bold, design: .rounded))
            }
            .multilineTextAlignment(.center)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Tomato Steward is loading")
        }
        .onAppear { isPulsing = true }
    }
}

#if DEBUG
struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
            .preferredColorScheme(.light)
        SplashView()
            .preferredColorScheme(.dark)
    }
}
#endif



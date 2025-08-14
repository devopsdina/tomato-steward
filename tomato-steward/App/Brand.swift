import SwiftUI
import UIKit

extension Color {
    init(hex: String, alpha: Double = 1.0) {
        var hexSanitized = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        self = Color(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
    
    init(light: Color, dark: Color) {
        self = Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexSanitized = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}

enum Brand {
    // Core brand colors (subset from provided palette)
    static let primary = Color(hex: "#405bff")      // blue500
    static let accent = Color(hex: "#3dd6f5")       // cyan500
    static let danger = Color(hex: "#e83b3b")       // red500
    static let warning = Color(hex: "#eec340")      // sYellow500
    static let success = Color(hex: "#00da7b")      // green500
    
    // Adaptive colors that change based on appearance
    static let surface = Color(light: Color(hex: "#f8f8f8"), dark: Color(hex: "#1c1c1e"))      // light: gray01, dark: dark gray
    static let surfaceStroke = Color(light: Color(hex: "#d8e5ee"), dark: Color(hex: "#3a3a3c")) // light: border, dark: separator
    static let title = Color(light: Color(hex: "#282828"), dark: Color(hex: "#ffffff"))         // light: black100, dark: white
    static let body = Color(light: Color(hex: "#414042"), dark: Color(hex: "#ebebf5"))          // light: gray09, dark: secondaryLabel

    // UIKit counterparts with adaptive colors
    static let uiPrimary = UIColor(hex: "#405bff")
    static let uiAccent = UIColor(hex: "#3dd6f5")
    static let uiSurface = UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? UIColor(hex: "#1c1c1e") : UIColor(hex: "#f8f8f8")
    }
    static let uiTitle = UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor(hex: "#282828")
    }
    static let uiBody = UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? UIColor(hex: "#ebebf5") : UIColor(hex: "#414042")
    }

    /// Apply global UIKit appearances to match the brand in SwiftUI containers.
    static func applyAppearance() {
        // UINavigationBar appearance with gradient background
        let nav = UINavigationBarAppearance()
        nav.configureWithOpaqueBackground()
        nav.backgroundImage = Brand.makeNavGradientImage()
        nav.titleTextAttributes = [.foregroundColor: UIColor.white]
        nav.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav
        UINavigationBar.appearance().tintColor = .white

        // UISegmentedControl appearance (used by .segmented pickers)
        UISegmentedControl.appearance().selectedSegmentTintColor = Brand.uiPrimary
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: Brand.uiBody], for: .normal)

        // UISwitch (Toggle) brand color
        UISwitch.appearance().onTintColor = Brand.uiPrimary.withAlphaComponent(0.35)
        UISwitch.appearance().thumbTintColor = Brand.uiPrimary
    }
    
    /// Apply dark mode theme to the app
    static func enableDarkMode() {
        DispatchQueue.main.async {
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .forEach { $0.overrideUserInterfaceStyle = .dark }
        }
    }
    
    /// Apply light mode theme to the app  
    static func enableLightMode() {
        DispatchQueue.main.async {
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .forEach { $0.overrideUserInterfaceStyle = .light }
        }
    }
    
    /// Return to system default theme
    static func useSystemTheme() {
        DispatchQueue.main.async {
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .forEach { $0.overrideUserInterfaceStyle = .unspecified }
        }
    }

    private static func makeNavGradientImage() -> UIImage? {
        let size = CGSize(width: 2, height: 1)
        let layer = CAGradientLayer()
        layer.frame = CGRect(origin: .zero, size: size)
        layer.colors = [Brand.uiPrimary.cgColor, Brand.uiAccent.cgColor]
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        defer { UIGraphicsEndImageContext() }
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
        layer.render(in: ctx)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}



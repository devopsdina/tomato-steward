import SwiftUI

#if canImport(MaterialComponents)
import MaterialComponents

struct MDCTextFieldView: UIViewRepresentable {
    final class Coordinator: NSObject, UITextFieldDelegate {
        var parent: MDCTextFieldView
        init(_ parent: MDCTextFieldView) {
            self.parent = parent
        }
        func textFieldDidBeginEditing(_ textField: UITextField) {
            parent.onBeginEditing?()
            print("🧷 MDCTextField begin editing (isFirstResponder=\(textField.isFirstResponder))")
        }
        func textFieldDidEndEditing(_ textField: UITextField) {
            parent.onEndEditing?()
            print("🧷 MDCTextField end editing")
        }
        func textFieldDidChangeSelection(_ textField: UITextField) {
            let newText = textField.text ?? ""
            // Defer publishing to next runloop to avoid "Publishing changes from within view updates" warnings
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if self.parent.text != newText {
                    self.parent.text = newText
                    print("🧷 MDCTextField changed → \(newText)")
                }
            }
        }
        @objc func doneTapped() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            parent.onEndEditing?()
        }
    }

    var label: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var onBeginEditing: (() -> Void)? = nil
    var onEndEditing: (() -> Void)? = nil

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> MDCOutlinedTextField {
        let textField = MDCOutlinedTextField(frame: .zero)
        textField.label.text = label
        textField.placeholder = "(oz)"
        textField.keyboardType = keyboardType
        textField.delegate = context.coordinator
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        // Brand styling
        textField.setOutlineColor(Brand.uiPrimary.withAlphaComponent(0.35), for: .normal)
        textField.setOutlineColor(Brand.uiPrimary, for: .editing)
        textField.setFloatingLabelColor(Brand.uiPrimary, for: .editing)
        textField.setTextColor(Brand.uiTitle, for: .normal)

        // Rely on SwiftUI's .toolbar(placement: .keyboard) Done button.
        // Custom UIToolbar here can trigger width=0 constraint warnings inside SwiftUI hosting.
        textField.inputAccessoryView = nil
        print("🧷 MDCTextField makeUIView")
        return textField
    }

    func updateUIView(_ uiView: MDCOutlinedTextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        if uiView.keyboardType != keyboardType {
            uiView.keyboardType = keyboardType
        }
        // Layout guards to avoid NaN sizes
        if !uiView.bounds.width.isFinite || !uiView.bounds.height.isFinite {
            uiView.bounds.size = CGSize(width: 180, height: 56)
            print("🧷 MDCTextField bounds corrected to finite size")
        }
    }
}

// MDCSegmentedControl was removed from upstream MaterialComponents. If needed in the future,
// re-introduce a wrapper here guarded by availability and the correct component import.

struct MDCButtonView: UIViewRepresentable {
    final class Coordinator {
        let action: () -> Void
        init(action: @escaping () -> Void) { self.action = action }
        @objc func tap() { action() }
    }

    var title: String
    var action: () -> Void

    func makeCoordinator() -> Coordinator { Coordinator(action: action) }

    func makeUIView(context: Context) -> MDCButton {
        let button = MDCButton(type: .system)
        button.setTitle(title, for: .normal)
        button.addTarget(context.coordinator, action: #selector(Coordinator.tap), for: .touchUpInside)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        // Brand styling
        button.layer.cornerRadius = 8
        button.setBackgroundColor(Brand.uiPrimary, for: .normal)
        button.setBackgroundColor(Brand.uiPrimary.withAlphaComponent(0.85), for: .highlighted)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.white, for: .highlighted)
        return button
    }

    func updateUIView(_ uiView: MDCButton, context: Context) {
        uiView.setTitle(title, for: .normal)
    }
}

#endif

// Compatibility modifier to ensure a visible toolbar background without
// relying on overloaded toolbarBackground initializers that can be ambiguous
// across SwiftUI versions.
struct NavBarBackgroundCompat: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                // Appearance is already set via Brand.applyAppearance().
                // This modifier exists to keep a stable call site in CalculatorView.
            }
    }
}

// Transparent background that dismisses the keyboard when tapped.
struct KeyboardDismissBackground: View {
    var isActive: Bool
    var body: some View {
        Color.clear
            .contentShape(Rectangle())
            .onTapGesture {
                if isActive {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
    }
}


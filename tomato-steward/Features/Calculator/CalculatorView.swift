import SwiftUI
import Combine
import UIKit

#if canImport(MaterialComponents)
import MaterialComponents
#endif

struct CalculatorView: View {
    @ObservedObject var viewModel: CalculatorViewModel
    @ObservedObject private var launchDarklyService = LaunchDarklyService.shared
    @FocusState private var weightFieldFocused: Bool
    @State private var isKeyboardVisible: Bool = false
    @State private var showCustomPad: Bool = false
	@State private var lastKeyboardEvent: String = ""
    private let controlWidth: CGFloat = 180

	var body: some View {
		NavigationView {
			ZStack(alignment: .bottom) {
				ScrollView(.vertical, showsIndicators: true) {
					VStack(alignment: .leading, spacing: 16) {
						varietalPicker()
						stylePicker()
						weightInput()
						computeButton()
						unitsToggle()
                    if let plan = viewModel.plan {
                        HStack {
                            Spacer()
                            resultsCard(plan: plan)
                            Spacer()
                        }
                    }
						if let msg = viewModel.validationMessage {
							Text(msg)
								.foregroundColor(.red)
								.accessibilityLabel("Validation Error")
						}
					}
					.padding()
				}
				// Bottom content: show custom pad if requested
				Group {
					if showCustomPad {
						numberPad()
							.frame(maxWidth: .infinity)
							.ignoresSafeArea(edges: .bottom)
					}
				}
			}
			.navigationBarTitleDisplayMode(.inline)
			.toolbar(content: navigationToolbarContent)
			.toolbar(content: keyboardToolbarContent)
			.toolbar(content: bottomToolbarContent)
			.modifier(NavBarBackgroundCompat())
			.accentColor(Brand.primary)
			.toolbarBackground(.visible, for: .bottomBar)
			.toolbarBackground(Color(UIColor.systemGray6), for: .bottomBar)
			.background(KeyboardDismissBackground(isActive: isKeyboardVisible || showCustomPad))
			.onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
				isKeyboardVisible = true
				lastKeyboardEvent = "show"
				print("🎛️ Keyboard will show → isKeyboardVisible=true")
			}
			.onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
				isKeyboardVisible = false
				lastKeyboardEvent = "hide"
				print("🎛️ Keyboard will hide → isKeyboardVisible=false")
			}
			.onChange(of: weightFieldFocused) { focused in
				if focused {
					viewModel.clearPlan()
					viewModel.weightText = ""
					showCustomPad = true
					print("🔎 Weight field focused → showCustomPad=true, keyboardVisible=\(isKeyboardVisible)")
				} else {
					showCustomPad = false
					print("🔎 Weight field unfocused → showCustomPad=false")
				}
			}
			.onChange(of: showCustomPad) { value in
				print("⌨️ CustomPad visibility changed → \(value ? "SHOW" : "HIDE") (lastKeyboardEvent=\(lastKeyboardEvent))")
			}
			.onChange(of: viewModel.weightText) { newValue in
				let parsed = Double(newValue)
				print("🔢 weightText=\(newValue.isEmpty ? "<empty>" : newValue) parsed=\(String(describing: parsed))")
			}
		}
	}

    private func weightInput() -> some View {
        Group {
            #if canImport(MaterialComponents)
            VStack(alignment: .leading, spacing: 8) {
                Text("Weight")
                    .font(.title3).bold()
                MDCTextFieldView(
                    label: "",
                    text: $viewModel.weightText,
                    keyboardType: .decimalPad,
                    onBeginEditing: {
                        // Ensure pad shows immediately on Material path and clear stale state
                        DispatchQueue.main.async {
                            print("🔎 onBeginEditing → focusing weight, showing custom pad")
                            weightFieldFocused = true
                            viewModel.clearPlan()
                            viewModel.weightText = ""
                            showCustomPad = true
                        }
                    },
                    onEndEditing: {
                        DispatchQueue.main.async {
                            print("🔎 onEndEditing → hide custom pad")
                            weightFieldFocused = false
                            showCustomPad = false
                        }
                    }
                )
                    .frame(width: controlWidth, height: 56)
                    .accessibilityLabel("Weight in ounces")
            }
            #else
            VStack(alignment: .leading, spacing: 8) {
                Text("Weight")
                    .font(.title3).bold()
                TextField("(oz)", text: $viewModel.weightText)
                    .keyboardType(.decimalPad)
                    .focused($weightFieldFocused)
                    .submitLabel(.done)
                    .onTapGesture {
                        DispatchQueue.main.async { weightFieldFocused = true }
                    }
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 8)
                    .frame(width: controlWidth, height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Brand.primary.opacity(0.25), lineWidth: 1)
                    )
                    .accessibilityLabel("Weight in ounces")
            }
            #endif
        }
    }

    private func varietalPicker() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Varietal")
                .font(.title3).bold()
            Menu {
                ForEach(TomatoVarietal.allCases) { varietal in
                    Button(varietal.displayName) {
                        viewModel.selectedVarietal = varietal
                    }
                }
            } label: {
                HStack {
                    Text(viewModel.selectedVarietal.displayName)
                        .font(.title3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: "chevron.down")
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .frame(width: controlWidth)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Brand.primary.opacity(0.25), lineWidth: 1)
                )
            }
            .accessibilityLabel("Tomato varietal")
        }
    }

    private func stylePicker() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Style")
                .font(.title3).bold()
            Menu {
                ForEach(TomatoStyle.allCases) { style in
                    Button(style.displayName) {
                        viewModel.selectedStyle = style
                    }
                }
            } label: {
                HStack {
                    Text(viewModel.selectedStyle.displayName)
                        .font(.title3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: "chevron.down")
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .frame(width: controlWidth)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Brand.primary.opacity(0.25), lineWidth: 1)
                )
            }
            .accessibilityLabel("Tomato style")
        }
    }

    private func computeButton() -> some View {
        Group {
            #if canImport(MaterialComponents)
            MDCButtonView(title: "Compute Cook Time", action: computeAction)
                .frame(maxWidth: .infinity, minHeight: 52)
                .accessibilityLabel("Compute Plan")
            #else
            Button(action: computeAction) {
                Text("Compute Cook Time")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Brand.primary)
            .frame(minHeight: 52)
            .accessibilityLabel("Compute Plan")
            #endif
        }
    }

    private func computeAction() {
        // Dismiss keyboard first
        weightFieldFocused = false
        showCustomPad = false
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        // Then compute
        viewModel.computePlan()
    }

    private func unitsToggle() -> some View {
        Group {
            if launchDarklyService.showUnitsToggle {
                Toggle(isOn: Binding(get: { viewModel.useCelsius }, set: { _ in viewModel.toggleUnits() })) {
                    Text("Use Celsius")
                        .font(.title3)
                }
            }
        }
    }

    // MARK: - Custom Number Pad (fallback for Simulator when software keyboard is hidden)
    private func numberPad() -> some View {
        VStack(spacing: 8) {
            let rows: [[String]] = [["1","2","3"],["4","5","6"],["7","8","9"],[".","0","⌫"]]
            ForEach(0..<rows.count, id: \.self) { r in
                HStack(spacing: 8) {
                    ForEach(rows[r], id: \.self) { key in
                        Button(action: { handleKey(key) }) {
                            Text(key)
                                .frame(maxWidth: .infinity, minHeight: 48)
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            Button("Done") {
                computeAction()
            }
            .buttonStyle(.borderedProminent)
            .tint(Brand.primary)
        }
        .padding(.horizontal)
        .padding(.bottom)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 260)
        .background(
            GeometryReader { proxy in
                let w = proxy.size.width
                let h = proxy.size.height
                DispatchQueue.main.async {
                    print("📐 numberPad size → w=\(w), h=\(h)")
                }
                return Color.clear
            }
            .background(.ultraThinMaterial)
        )
    }

	private func handleKey(_ key: String) {
        switch key {
        case "⌫":
            if !viewModel.weightText.isEmpty { _ = viewModel.weightText.removeLast() }
        case ".":
            if !viewModel.weightText.contains(".") { viewModel.weightText.append(".") }
        default:
            viewModel.weightText.append(key)
        }
		print("⌨️ Key tapped=\(key) → weightText=\(viewModel.weightText)")
    }

    @ToolbarContentBuilder
    private func navigationToolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .principal) {
            HStack(spacing: 8) {
                Text("🍅")
                Text("Tomato Steward")
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundColor(.white)
                Text("🍅")
            }
        }
        
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            if launchDarklyService.isDarkMode {
                Menu {
                    Button("Light Mode") { Brand.enableLightMode() }
                    Button("Dark Mode") { Brand.enableDarkMode() }
                    Button("System Default") { Brand.useSystemTheme() }
                } label: {
                    Image(systemName: "circle.lefthalf.filled")
                        .foregroundColor(.white)
                }
                .accessibilityLabel("Theme Options - Currently in Dark Mode via ui.DarkMode Flag")
            }
        }
    }
    
    @ToolbarContentBuilder
    private func keyboardToolbarContent() -> some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button(action: {
                weightFieldFocused = false
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }) {
                Text("Done")
                    .bold()
            }
            .buttonStyle(.borderedProminent)
            .tint(Brand.primary)
        }
    }
    
    @ToolbarContentBuilder
    private func bottomToolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            Button("Quit") {
                UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    exit(0)
                }
            }
            .buttonStyle(.bordered)
            .tint(Brand.danger)
            .frame(width: 140)
        }
    }

    private func resultsCard(plan: StewPlan) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Stew for \(plan.totalMinutes) minutes")
                .font(.title2)
                .bold()
            Text(viewModel.useCelsius ? plan.celsiusText : plan.fahrenheitText)
                .foregroundColor(.secondary)
            Text(plan.rationale)
                .font(.subheadline)
            if !plan.advancedTips.isEmpty {
                DisclosureGroup("Advanced Tips") {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(plan.advancedTips, id: \.self) { tip in
                            Text("• \(tip)")
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Brand.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Brand.surfaceStroke)
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Results Card")
    }
}

struct CalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        CalculatorView(viewModel: CalculatorViewModel(ldService: LaunchDarklyService.shared, settingsStore: SettingsStore()))
    }
}


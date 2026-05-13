import SwiftData
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

private struct FormulaPreset: Codable, Identifiable, Equatable {
    let id: UUID
    let name: String
    let values: [String: String]
    let createdAt: Date
}

private enum DurationUnit: String, Codable {
    case years
    case months
}

private struct ProfitLossChargeBreakdown {
    let buyTurnover: Double
    let sellTurnover: Double
    let turnover: Double
    let brokerageAmount: Double
    let sttAmount: Double
    let exchangeAmount: Double
    let gstOnBrokerageAmount: Double
    let stampDutyAmount: Double
    let sebiAmount: Double
    let grossPnL: Double
    let totalCharges: Double
    let netPnL: Double
    let breakEvenPrice: Double
    let returnPercent: Double
}

private struct CalculatorResultRoute: Identifiable, Hashable {
    let id = UUID()
    let formula: FormulaDefinition
    let result: FormulaResult
    let title: String
    let inputValues: [String: String]
    let steps: [FormulaStep]
    let variableRows: [(symbol: String, meaning: String, value: String)]
    let substitutedExpression: [FormulaExpressionSegment]
    let selectedCurrencyCode: String

    static func == (lhs: CalculatorResultRoute, rhs: CalculatorResultRoute) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct FormulaDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    @Environment(CurrencyManager.self) private var currencyManager
    @Environment(AdManager.self) private var adManager
    @Query(sort: \FavoriteFormula.sortOrder) private var favoriteFormulas: [FavoriteFormula]

    let formula: FormulaDefinition

    @State private var inputValues: [String: String] = [:]
    @State private var result: FormulaResult?
    @State private var showResult: Bool = false
    @State private var invalidInputKeys: Set<String> = []
    @State private var showValidationError: Bool = false
    @State private var validationMessage: String = ""
    @State private var shakeTrigger: Int = 0
    @State private var formulaInfoExpanded: Bool = true
    @State private var showFormulaSheet: Bool = false
    @State private var showAdvancedCharges: Bool = false
    @State private var favoriteButtonState: Bool = false
    @State private var isFocusModeEnabled: Bool = false
    @State private var presets: [FormulaPreset] = []
    @State private var showingSavePresetAlert = false
    @State private var newPresetName = ""
    @State private var isCalculating = false
    @State private var durationUnitByInputKey: [String: DurationUnit] = [:]
    @State private var activeResultRoute: CalculatorResultRoute?
    @AppStorage("settings.decimals") private var decimalPlaces: Int = 2
    @AppStorage("mm.lastViewedFormulaID") private var lastViewedFormulaID = ""
    @FocusState private var focusedInputKey: String?
    private var formulaTitle: String { FormulaDisplayText.name(for: formula.id) }
    private var detailAccent: Color { MMPalette.categoryAccent(formula.category) }

    private static let grainDots: [(CGPoint, Double)] = (0..<1200).map { _ in
        (CGPoint(x: .random(in: 0...1), y: .random(in: 0...1)), Double.random(in: 0.01...0.03))
    }

    init(formula: FormulaDefinition) {
        self.formula = formula
        var defaults: [String: String] = [:]
        var durationDefaults: [String: DurationUnit] = [:]
        for input in formula.inputs {
            defaults[input.key] = input.defaultValue ?? ""
            if FormulaDetailView.supportsDurationUnitSelection(for: input.key) {
                durationDefaults[input.key] = .years
            }
        }
        _inputValues = State(initialValue: defaults)
        _durationUnitByInputKey = State(initialValue: durationDefaults)
    }

    var body: some View {
        let narrative = FormulaKnowledge.narrative(for: formula.id, fallbackExpression: formula.formulaExpressionKey)

        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: MMGrid.x16) {
                    simpleHeader(narrative: narrative)
                    pinFormulaSection

                    groupedInputSection

                    Button {
                        guard !isCalculating else { return }
                        HapticManager.impact(.medium)
                        Task {
                            await calculate()
                        }
                    } label: {
                        calculateButtonLabel
                    }
                    .buttonStyle(.plain)
                    .disabled(isCalculating || !canCalculate)

                    if let result, showResult {
                        simpleResultCard(result)
                            .id("result-section")
                            .transition(MMMotion.fadeSlide)
                    }

                    if showValidationError {
                        Text(validationMessage.isEmpty ? "Please check your inputs and try again." : validationMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                .padding(MMGrid.horizontalPadding)
                .mmAdaptiveReadableWidth(720)
                .safeAreaPadding(.bottom, 120)

            }
            .onChange(of: showResult) { _, shown in
                guard shown else { return }
                withAnimation(MMMotion.navigation) {
                    proxy.scrollTo("result-section", anchor: .top)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            dismissKeyboard()
        }
        .background(.clear)
        .navigationTitle(formulaTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $activeResultRoute) { route in
            CalculatorResultView(
                route: route,
                detailAccent: detailAccent
            )
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                EmptyView()
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    dismissKeyboard()
                    focusedInputKey = nil
                }
            }
        }
        .onAppear {
            favoriteButtonState = isFavoriteFormula
            presets = loadPresets()
            persistUsageSignals()
        }
        .onChange(of: favoriteFormulas.map(\.formulaID)) { _, _ in
            favoriteButtonState = isFavoriteFormula
        }
        .onChange(of: inputValues) { _, _ in
            if showValidationError {
                showValidationError = false
                validationMessage = ""
            }
            guard formula.id == "F76", !isCalculating else { return }
            guard (number("grossSalary") ?? 0) > 0 else {
                showResult = false
                result = nil
                return
            }
            Task {
                await calculate(shouldSaveHistory: false, shouldNavigateToResult: false)
            }
        }
        .alert("Save Preset", isPresented: $showingSavePresetAlert) {
            TextField("Preset name", text: $newPresetName)
            Button("Cancel", role: .cancel) {
                newPresetName = ""
            }
            Button("Save") {
                let fallback = "Preset \(presets.count + 1)"
                let trimmed = newPresetName.trimmingCharacters(in: .whitespacesAndNewlines)
                saveCurrentPreset(named: trimmed.isEmpty ? fallback : trimmed)
                newPresetName = ""
            }
        } message: {
            Text("Save current inputs as a reusable template for this formula.")
        }
        .sheet(isPresented: $showFormulaSheet) {
            FormulaExplanationSheet(
                title: formulaTitle,
                expression: FormulaKnowledge.narrative(for: formula.id, fallbackExpression: formula.formulaExpressionKey).fullExpression,
                substitutedExpression: substitutedExpressionSegments(),
                variableRows: formulaVariableRows(),
                steps: currentFormulaSteps(),
                onClose: { showFormulaSheet = false }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.ultraThinMaterial)
        }
    }

    @ViewBuilder
    private var pinFormulaSection: some View {
        HStack {
            FavoriteButton(isFavorite: $favoriteButtonState) { _ in
                toggleFavoriteFormula()
            }
            Spacer()
            if favoriteButtonState {
                Text("Pinned for quick access")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var calculateButtonLabel: some View {
        let enabled = canCalculate
        return HStack(spacing: 10) {
            if isCalculating {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
                    .scaleEffect(0.9)
            }
            Text(isCalculating ? "Calculating..." : "Calculate Result")
                .font(.headline.weight(.semibold))
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, minHeight: 56)
        .background(
            LinearGradient(
                colors: enabled
                    ? [MMPalette.toneBlue, MMPalette.toneBlue.opacity(0.72)]
                    : [Color.secondary.opacity(0.65), Color.secondary.opacity(0.35)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
        .opacity(enabled ? 1 : 0.5)
        .scaleEffect(isCalculating ? 0.985 : 1)
        .animation(MMMotion.selection, value: isCalculating)
    }

    @ViewBuilder
    private func simpleHeader(narrative: FormulaNarrative) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(formula.category.displayName)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(formulaTitle)
                        .font(.title.weight(.bold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.75)
                        .allowsTightening(true)
                    Text(narrative.cardExpression)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                Spacer()
            }
        }
        .padding(.top, 4)
    }

    @ViewBuilder
    private func detailHeader(narrative: FormulaNarrative) -> some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            formula.category.color.opacity(0.88),
                            formula.category.color.opacity(0.54),
                            .black.opacity(0.74)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Circle()
                .fill(formula.category.color)
                .frame(width: 200)
                .blur(radius: 60)
                .offset(x: -50, y: -30)
                .opacity(0.5)
            Circle()
                .fill(formula.category.color.opacity(0.6))
                .frame(width: 120)
                .blur(radius: 40)
                .offset(x: 120, y: 40)
            Circle()
                .fill(.white.opacity(0.07))
                .frame(width: 90)
                .blur(radius: 25)
                .offset(x: 130, y: -70)

            Canvas { context, size in
                for dot in Self.grainDots {
                    context.fill(
                        Path(ellipseIn: CGRect(x: dot.0.x * size.width, y: dot.0.y * size.height, width: 1, height: 1)),
                        with: .color(.white.opacity(dot.1 * (colorScheme == .dark ? 1.0 : 0.55)))
                    )
                }
            }
            .drawingGroup()
            .allowsHitTesting(false)

            Image(systemName: formula.sfSymbol)
                .font(.system(size: 160, weight: .black))
                .foregroundStyle(.white.opacity(0.08))
                .offset(x: 60, y: 20)

            LinearGradient(
                colors: [Color.black.opacity(0.7), .clear],
                startPoint: .bottom,
                endPoint: .center
            )

            VStack {
                LinearGradient(
                    colors: [.white.opacity(colorScheme == .dark ? 0.20 : 0.10), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 44)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 5) {
                    Image(systemName: formula.category.sfSymbol)
                        .font(.system(size: 9, weight: .bold))
                    Text(formula.category.displayName.uppercased())
                        .font(.system(size: 9, weight: .black, design: .monospaced))
                        .tracking(1.5)
                }
                .foregroundStyle(formula.category.color)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(Color.clear)
                        .glassEffect(in: Capsule())
                        .overlay(Capsule().strokeBorder(formula.category.color.opacity(0.4), lineWidth: 0.5))
                )

                Text(FormulaDisplayText.name(for: formula.id))
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(colorScheme == .dark ? .white : .primary)
                    .lineLimit(2)

                Text(narrative.cardExpression)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(formula.category.color)
                    .lineLimit(2)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .frame(height: 280)
        .overlay(
            RoundedRectangle(cornerRadius: 0)
                .strokeBorder(colorScheme == .dark ? .white.opacity(0.10) : .black.opacity(0.08), lineWidth: 0.7)
        )
    }

    @ViewBuilder
    private func flowTokens(_ tokens: [FormulaToken]) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 7)], alignment: .leading, spacing: 7) {
            ForEach(tokens) { token in
                Text(token.text)
                    .font(.system(.caption, design: .monospaced).weight(.semibold))
                    .foregroundStyle(token.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(token.color.opacity(0.12), in: Capsule(style: .continuous))
            }
        }
    }

    @ViewBuilder
    private var groupedInputSection: some View {
        if formula.id == "F01" {
            VStack(alignment: .leading, spacing: 12) {
                Text("Trade Details")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)

                ForEach(formula.inputs.filter { ["buyPrice", "sellPrice", "quantity"].contains($0.key) }, id: \.id) { input in
                    simpleInputRow(input)
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Charges & Taxes")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Spacer()
                    Button(showAdvancedCharges ? "Hide Charges" : "Show All Charges") {
                        withAnimation(MMMotion.content) {
                            showAdvancedCharges.toggle()
                        }
                    }
                    .font(.footnote.weight(.semibold))
                    .buttonStyle(.plain)
                }

                let baseKeys = ["brokerage", "stt"]
                let advancedKeys = ["exchangeCharges", "stampDuty"]
                ForEach(formula.inputs.filter { baseKeys.contains($0.key) }, id: \.id) { input in
                    simpleInputRow(input)
                }

                if showAdvancedCharges {
                    ForEach(formula.inputs.filter { advancedKeys.contains($0.key) }, id: \.id) { input in
                        simpleInputRow(input)
                    }

                    computedChargeRow(
                        title: InputDisplayText.label(for: "gstOnBrokerageAmount", category: formula.category),
                        value: formattedCurrencyValue(profitLossChargeBreakdown?.gstOnBrokerageAmount ?? 0)
                    )
                    computedChargeRow(
                        title: InputDisplayText.label(for: "sebiChargesAmount", category: formula.category),
                        value: formattedCurrencyValue(profitLossChargeBreakdown?.sebiAmount ?? 0)
                    )
                }
            }
        } else if formula.id == "F76" {
            VStack(alignment: .leading, spacing: 12) {
                Text("Salary Details")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)
                ForEach(formula.inputs.filter { ["grossSalary", "standardDeduction", "hraExemption"].contains($0.key) }, id: \.id) { input in
                    simpleInputRow(input)
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Deductions")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)
                ForEach(formula.inputs.filter { ["section80C", "section80D", "nps80ccd1b", "homeLoan24b", "otherDeductions"].contains($0.key) }, id: \.id) { input in
                    simpleInputRow(input)
                }
                Text("Limits auto-applied: 80C ₹1,50,000 • 80CCD(1B) ₹50,000 • 24(b) ₹2,00,000")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } else {
            VStack(alignment: .leading, spacing: 12) {
                Text("Inputs")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)

                ForEach(formula.inputs, id: \.id) { input in
                    simpleInputRow(input)
                }
            }
        }
    }

    @ViewBuilder
    private func computedChargeRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.system(.body, design: .monospaced).weight(.semibold))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 14)
        .frame(minHeight: 46)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    @ViewBuilder
    private var presetsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Templates")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)
                Spacer()
                Text("\(presets.count)")
                    .font(.caption.bold().monospaced())
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .mmCardSurface(corner: 10)
            }

            HStack(spacing: 10) {
                Button {
                    showingSavePresetAlert = true
                } label: {
                    Label("Save Current", systemImage: "square.and.arrow.down")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .mmNativeProminentGlassButton(tint: MMPalette.appTint.opacity(0.72))

                Menu {
                    if presets.isEmpty {
                        Text("No saved templates yet")
                    } else {
                        Section("Apply Template") {
                            ForEach(presets) { preset in
                                Button(preset.name) {
                                    applyPreset(preset)
                                }
                            }
                        }
                        Section("Delete Template") {
                            ForEach(presets) { preset in
                                Button("Delete \(preset.name)", role: .destructive) {
                                    deletePreset(preset)
                                }
                            }
                        }
                    }
                } label: {
                    Label("Apply", systemImage: "tray.and.arrow.down")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .mmNativeGlassButton(tint: .secondary.opacity(0.55))
            }

            if !presets.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(presets.prefix(10)) { preset in
                            Button {
                                applyPreset(preset)
                            } label: {
                                Text(preset.name)
                                    .font(.caption.weight(.semibold))
                                    .lineLimit(1)
                                    .padding(.horizontal, 10)
                                    .frame(minHeight: 34)
                            }
                            .mmNativeGlassButton(tint: MMPalette.appTint.opacity(0.34))
                        }
                    }
                    .padding(.horizontal, 2)
                }
            }
        }
        .padding(14)
        .mmCardSurface(corner: 18, tint: MMPalette.appTint.opacity(0.16))
    }

    @ViewBuilder
    private func simpleInputRow(_ input: InputDefinition) -> some View {
        let unit = displayUnitLabel(for: input)
        let label = displayInputLabel(for: input)
        let isFocused = focusedInputKey == input.key
        let showSellWarning = input.key == "sellPrice" && isSellPriceBelowBuyPrice

        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            if FormulaDetailView.supportsDurationUnitSelection(for: input.key) {
                Picker("Duration Unit", selection: durationBinding(for: input.key)) {
                    Text("Years").tag(DurationUnit.years)
                    Text("Months").tag(DurationUnit.months)
                }
                .pickerStyle(.segmented)
                .tint(.secondary)
                .padding(.bottom, 4)
            }

            HStack(spacing: 10) {
                TextField(
                    placeholderText(for: input),
                    text: Binding(
                        get: { inputValues[input.key, default: ""] },
                        set: { inputValues[input.key] = sanitizedInput($0, for: input.key) }
                    )
                )
                .font(.title3.weight(.medium))
                .keyboardType(keyboardType(for: input.key))
                .focused($focusedInputKey, equals: input.key)
                .onChange(of: inputValues[input.key, default: ""]) { _, newValue in
                    applyInputFormatting(for: input.key, rawValue: newValue)
                }

                if !unit.isEmpty {
                    Text(unit)
                        .font(.body.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .frame(minHeight: MMGrid.textFieldHeight)
            .background {
                let shape = RoundedRectangle(cornerRadius: 12, style: .continuous)
                shape
                    .fill(Color(.systemBackground).opacity(colorScheme == .dark ? 0.38 : 0.86))
                    .glassEffect(in: shape)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(
                        invalidInputKeys.contains(input.key) || showSellWarning
                            ? Color.red.opacity(0.6)
                            : (isFocused ? Color.primary.opacity(0.28) : Color(.separator).opacity(0.22)),
                        lineWidth: (invalidInputKeys.contains(input.key) || showSellWarning) ? 1.4 : 1
                    )
            )

            if showSellWarning {
                Text("Sell price is below buy price.")
                    .font(.caption2)
                    .foregroundStyle(.red)
            }
        }
    }

    @ViewBuilder
    private func simpleResultCard(_ result: FormulaResult) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(resultHeaderTitle())
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .tracking(1.6)
                .foregroundStyle(.secondary)

            Text(formattedPrimaryResult(result))
                .font(.system(size: 60, weight: .black))
                .lineLimit(1)
                .minimumScaleFactor(0.4)
                .foregroundStyle(.primary)

            if !result.secondaryValues.isEmpty {
                HStack(spacing: 0) {
                    ForEach(Array(result.secondaryValues.prefix(2).enumerated()), id: \.offset) { index, item in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(item.label.uppercased())
                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                            Text(formattedSecondaryValue(unit: item.unit, value: item.value))
                                .font(.system(size: 31, weight: .bold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .foregroundStyle(.primary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        if index == 0 {
                            Divider().padding(.horizontal, 10)
                        }
                    }
                }
                .padding(.top, 2)
            }

            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(result.interpretation.color)
                    .padding(.top, 1)
                Text(userFriendlyResultHint(for: result))
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 2)
        }
        .padding(18)
        .mmCardSurface(corner: 20, tint: detailAccent.opacity(colorScheme == .dark ? 0.18 : 0.26))
    }

    private func formattedPrimaryResult(_ result: FormulaResult) -> String {
        let localizedUnit = localizedCurrencyUnit(result.primaryUnit)
        if let currencyComposite = formattedCurrencyComposite(value: result.primaryFormatted, unit: localizedUnit) {
            return currencyComposite
        }
        switch localizedUnit {
        case "%":
            return "\(result.primaryFormatted)%"
        case "":
            return result.primaryFormatted
        default:
            return "\(result.primaryFormatted) \(localizedUnit)"
        }
    }

    private func formattedSecondaryValue(unit: String, value: String) -> String {
        let localizedUnit = localizedCurrencyUnit(unit)
        if let currencyComposite = formattedCurrencyComposite(value: value, unit: localizedUnit) {
            return currencyComposite
        }
        switch localizedUnit {
        case "":
            return value
        default:
            return "\(value) \(localizedUnit)"
        }
    }

    private func localizedCurrencyUnit(_ rawUnit: String) -> String {
        rawUnit
    }

    private func formattedCurrencyComposite(value: String, unit: String) -> String? {
        let symbol = currencyManager.currencySymbol
        guard unit.contains(symbol) else {
            return nil
        }
        let suffix = unit.replacingOccurrences(of: symbol, with: "").trimmingCharacters(in: .whitespaces)
        if suffix.isEmpty {
            return currencyManager.isSymbolPrefix ? "\(symbol)\(value)" : "\(value)\(symbol)"
        }
        if currencyManager.isSymbolPrefix {
            return "\(symbol)\(value) \(suffix)"
        }
        return "\(value)\(symbol) \(suffix)"
    }

    private func formattedCurrencyValue(_ value: Double) -> String {
        currencyManager.formatAmount(value)
    }

    private func resultHeaderTitle() -> String {
        switch formula.id {
        case "F01": return "NET PROFIT / LOSS"
        case "F02": return "AVERAGE SHARE PRICE"
        case "F03": return "SIP FUTURE VALUE"
        case "F04": return "LUMPSUM MATURITY VALUE"
        case "F53": return "MONTHLY EMI"
        case "F54": return "SIMPLE INTEREST"
        case "F71": return "NET WORTH"
        default:
            return "\(FormulaDisplayText.shortName(for: formula.id).uppercased()) RESULT"
        }
    }

    private func userFriendlyResultHint(for result: FormulaResult) -> String {
        switch formula.id {
        case "F53":
            let annualRate = number("annualRate") ?? 0
            let years = number("years") ?? 0
            let emiValue = formattedCurrencyValue(result.primaryValue)
            if annualRate >= 11 {
                return "EMI is \(emiValue)/month, high for this rate. Compare lenders and reduce rate if possible."
            }
            if years >= 20 {
                return "EMI is \(emiValue)/month with a long tenure. Lower monthly burden, but higher total interest."
            }
            return "EMI is \(emiValue)/month. Try to keep total EMIs below 40% of monthly income."
        case "F58":
            let availableEMI = result.primaryValue
            let availableFormatted = formattedCurrencyValue(availableEMI)
            let income = number("monthlyIncome") ?? 0
            if result.primaryValue <= 0 {
                return "Current EMIs are already high vs income. Avoid taking additional EMI now."
            }
            if income > 0 {
                let headroomPercent = (availableEMI / income) * 100
                if headroomPercent < 10 {
                    return "Only \(availableFormatted)/month headroom (~\(String(format: "%.1f", headroomPercent))% of income). Keep a strong buffer."
                }
            }
            return "EMI headroom is \(availableFormatted)/month. Capacity looks healthy, but keep an emergency buffer."
        case "F59":
            let yield = result.primaryValue
            let annualRent = (number("monthlyRent") ?? 0) * 12
            let annualRentFormatted = formattedCurrencyValue(annualRent)
            if yield < 2 {
                return "Annual rent is \(annualRentFormatted). Yield is low for this property value."
            }
            if yield < 4 {
                return "Annual rent is \(annualRentFormatted). Yield is moderate; check growth and maintenance costs."
            }
            return "Annual rent is \(annualRentFormatted). Yield looks healthy for this property value."
        default:
            return result.interpretationText
        }
    }

    private func number(_ key: String) -> Double? {
        guard let raw = inputValues[key]?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else {
            return nil
        }
        guard let value = parseLocalizedNumber(raw) else { return nil }
        return normalizedDurationValueIfNeeded(value, for: key)
    }

    private func parseLocalizedNumber(_ raw: String) -> Double? {
        let formatter = NumberFormatter()
        formatter.locale = currencyManager.selectedLocale
        formatter.numberStyle = .decimal
        if let number = formatter.number(from: raw) {
            return number.doubleValue
        }
        return currencyManager.parseAmount(raw)
    }

    private var canCalculate: Bool {
        formula.inputs.allSatisfy { input in
            let raw = inputValues[input.key, default: ""].trimmingCharacters(in: .whitespacesAndNewlines)
            if raw.isEmpty {
                return input.isOptional
            }
            if input.isDynamic {
                return !parseNumbers(from: raw).isEmpty
            }
            return parseLocalizedNumber(raw) != nil
        }
    }

    private var isSellPriceBelowBuyPrice: Bool {
        guard let buy = number("buyPrice"), let sell = number("sellPrice") else { return false }
        return formula.id == "F01" && sell < buy
    }

    private func keyboardType(for key: String) -> UIKeyboardType {
        if key == "quantity" {
            return .numberPad
        }
        return .decimalPad
    }

    private func placeholderText(for input: InputDefinition) -> String {
        switch input.key {
        case "buyPrice":
            return "Enter buy price per share"
        case "sellPrice":
            return "Enter sell price per share"
        case "quantity":
            return "Number of shares"
        case "weight":
            return "Allocation %, e.g. 30"
        case "return", "returns", "portfolioReturn", "stockReturn", "marketReturn", "actualReturn", "annualReturn":
            return "Return %, e.g. 12"
        case "beta":
            return "Beta, e.g. 1.10"
        case "riskFree":
            return "Risk-free %, e.g. 7"
        case "stdDev", "dailyVolatility", "volatility":
            return "Volatility %, e.g. 18"
        case "years", "time":
            return "Duration, e.g. 5 years"
        case "months":
            return "Duration, e.g. 12 months"
        default:
            if let defaultValue = input.defaultValue, !defaultValue.isEmpty {
                return defaultValue
            }
            return "Enter \(displayInputLabel(for: input))"
        }
    }

    private func sanitizedInput(_ value: String, for key: String) -> String {
        let allowDecimal = key != "quantity"
        let decimalSeparator = currencyManager.selectedLocale.decimalSeparator ?? "."
        var hasDecimalSeparator = false
        let filtered = value.filter { char in
            if char.isNumber { return true }
            if String(char) == decimalSeparator && allowDecimal && !hasDecimalSeparator {
                hasDecimalSeparator = true
                return true
            }
            return false
        }

        if !allowDecimal {
            return String(filtered.prefix(9))
        }
        return String(filtered.prefix(18))
    }

    private func applyInputFormatting(for key: String, rawValue: String) {
        guard shouldApplyLocaleGrouping(for: key) else { return }
        guard !rawValue.isEmpty else { return }
        let decimalSeparator = currencyManager.selectedLocale.decimalSeparator ?? "."
        let containsDecimal = rawValue.contains(decimalSeparator)
        let parts = rawValue.components(separatedBy: decimalSeparator)
        let integerPart = parts.first ?? rawValue
        let fractionPart = parts.count > 1 ? parts[1] : nil
        let grouped = groupedInteger(integerPart)

        let newValue: String
        if containsDecimal {
            newValue = grouped + decimalSeparator + (fractionPart ?? "")
        } else {
            newValue = grouped
        }
        if newValue != rawValue {
            inputValues[key] = newValue
        }
    }

    private func shouldApplyLocaleGrouping(for key: String) -> Bool {
        if key == "quantity" { return false }
        let unit = InputDisplayText.unit(for: key, category: formula.category)
        return unit == currencyManager.currencySymbol || key.contains("price") || key.contains("amount") || key.contains("income") || key.contains("cost")
    }

    private func groupedInteger(_ digits: String) -> String {
        let groupingSeparator = currencyManager.selectedLocale.groupingSeparator ?? ","
        let plain = digits
            .replacingOccurrences(of: groupingSeparator, with: "")
            .replacingOccurrences(of: "\u{00A0}", with: "")
            .replacingOccurrences(of: " ", with: "")
        guard let value = Double(plain) else { return plain }
        let formatter = NumberFormatter()
        formatter.locale = currencyManager.selectedLocale
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? plain
    }

    private var profitLossChargeBreakdown: ProfitLossChargeBreakdown? {
        guard formula.id == "F01",
              let buy = number("buyPrice"),
              let sell = number("sellPrice"),
              let qty = number("quantity"),
              qty > 0 else { return nil }

        let brokeragePct = min(max(number("brokerage") ?? 0.1, 0), 100)
        let sttPct = max(number("stt") ?? 0.1, 0)
        let exchangePct = max(number("exchangeCharges") ?? 0.00345, 0)
        let stampDutyPct = max(number("stampDuty") ?? 0.015, 0)
        let sebiPct = 0.0001

        let buyTurnover = buy * qty
        let sellTurnover = sell * qty
        let turnover = buyTurnover + sellTurnover
        let gross = (sell - buy) * qty
        let brokerage = turnover * brokeragePct / 100
        let stt = sellTurnover * sttPct / 100
        let exchange = turnover * exchangePct / 100
        let gst = brokerage * 0.18
        let stamp = buyTurnover * stampDutyPct / 100
        let sebi = turnover * sebiPct / 100
        let charges = brokerage + stt + exchange + gst + stamp + sebi
        let net = gross - charges
        let breakEven = buy + (charges / qty)
        let ret = buyTurnover == 0 ? 0 : (net / buyTurnover) * 100

        return ProfitLossChargeBreakdown(
            buyTurnover: buyTurnover,
            sellTurnover: sellTurnover,
            turnover: turnover,
            brokerageAmount: brokerage,
            sttAmount: stt,
            exchangeAmount: exchange,
            gstOnBrokerageAmount: gst,
            stampDutyAmount: stamp,
            sebiAmount: sebi,
            grossPnL: gross,
            totalCharges: charges,
            netPnL: net,
            breakEvenPrice: breakEven,
            returnPercent: ret
        )
    }

    private static func supportsDurationUnitSelection(for key: String) -> Bool {
        key == "years" || key == "time"
    }

    private func normalizedDurationValueIfNeeded(_ value: Double, for key: String) -> Double {
        guard Self.supportsDurationUnitSelection(for: key) else { return value }
        let selectedUnit = durationUnitByInputKey[key] ?? .years
        switch selectedUnit {
        case .years:
            return value
        case .months:
            return value / 12.0
        }
    }

    private func displayUnitLabel(for input: InputDefinition) -> String {
        guard Self.supportsDurationUnitSelection(for: input.key) else {
            return localizedCurrencyUnit(InputDisplayText.unit(for: input.key, category: formula.category))
        }
        return durationUnitByInputKey[input.key] == .months ? "months" : "years"
    }

    private func displayInputLabel(for input: InputDefinition) -> String {
        let baseLabel = InputDisplayText.label(for: input.key, category: formula.category)
        guard Self.supportsDurationUnitSelection(for: input.key) else { return baseLabel }
        return baseLabel.replacingOccurrences(of: " (Years)", with: "")
    }

    private func durationBinding(for key: String) -> Binding<DurationUnit> {
        Binding(
            get: { durationUnitByInputKey[key] ?? .years },
            set: { newValue in
                durationUnitByInputKey[key] = newValue
                HapticManager.play(.selection)
            }
        )
    }

    private func focusBinding(for key: String) -> Binding<Bool> {
        Binding(
            get: { focusedInputKey == key },
            set: { focusedInputKey = $0 ? key : nil }
        )
    }

    private func numbers(prefix: String) -> [Double] {
        inputValues.keys
            .filter { $0.hasPrefix(prefix) }
            .sorted()
            .flatMap { key in
                parseNumbers(from: inputValues[key, default: ""])
            }
    }

    private func parseNumbers(from raw: String) -> [Double] {
        let localeDecimalSeparator = currencyManager.selectedLocale.decimalSeparator ?? "."
        return raw
            .split(whereSeparator: { character in
                if character == " " || character == "\n" || character == "\t" || character == ";" {
                    return true
                }
                if character == ",", localeDecimalSeparator != "," {
                    return true
                }
                return false
            })
            .compactMap { parseLocalizedNumber(String($0).trimmingCharacters(in: .whitespacesAndNewlines)) }
    }

    @MainActor
    private func calculate(
        shouldSaveHistory: Bool = true,
        shouldNavigateToResult: Bool = true
    ) async {
        dismissKeyboard()
        HapticManager.play(.tap)
        invalidInputKeys = invalidNumericKeys()
        guard invalidInputKeys.isEmpty else {
            showValidationError = true
            validationMessage = "Please enter valid numeric values for required fields."
            if !reduceMotion {
                withAnimation(MMMotion.press) {
                    shakeTrigger += 1
                }
            }
            HapticManager.play(.error)
            return
        }

        isCalculating = true
        let start = Date()
        let calculated: FormulaResult?

        switch formula.id {
        case "F01":
            calculated = FormulaEngine.profitAndLoss(
                buyPrice: number("buyPrice") ?? -1,
                sellPrice: number("sellPrice") ?? -1,
                quantity: number("quantity") ?? -1,
                brokeragePercent: min(max(number("brokerage") ?? 0.1, 0), 100),
                sttPercent: number("stt") ?? 0.1,
                exchangeChargePercent: number("exchangeCharges") ?? 0.00345,
                stampDutyPercent: number("stampDuty") ?? 0.015
            )
        case "F02":
            calculated = FormulaEngine.costAveraging(
                oldShares: number("oldShares") ?? -1,
                oldAveragePrice: number("oldAvg") ?? -1,
                newShares: number("newShares") ?? -1,
                newBuyPrice: number("newPrice") ?? -1
            )
        case "F03":
            calculated = FormulaEngine.sip(
                monthly: number("monthly") ?? -1,
                annualReturnPercent: number("annualReturn") ?? -1,
                years: number("years") ?? -1
            )
        case "F04":
            calculated = FormulaEngine.lumpsum(
                investment: number("investment") ?? -1,
                annualReturnPercent: number("annualReturn") ?? -1,
                years: number("years") ?? -1
            )
        case "F05":
            calculated = FormulaEngine.roi(initial: number("initial") ?? -1, final: number("final") ?? -1)
        case "F06":
            calculated = FormulaEngine.cagr(beginning: number("beginning") ?? -1, ending: number("ending") ?? -1, years: number("years") ?? -1)
        case "F07":
            calculated = FormulaEngine.peRatio(marketPrice: number("marketPrice") ?? -1, eps: number("eps") ?? -1)
        case "F08":
            calculated = FormulaEngine.eps(netIncome: number("netIncome") ?? -1, preferredDividends: number("preferredDividends") ?? 0, sharesOutstanding: number("sharesOutstanding") ?? -1)
        case "F09":
            calculated = FormulaEngine.roe(netIncome: number("netIncome") ?? -1, shareholdersEquity: number("equity") ?? -1)
        case "F10":
            calculated = FormulaEngine.dividendYield(dividendPerShare: number("dividend") ?? -1, sharePrice: number("price") ?? -1)
        case "F11":
            calculated = FormulaEngine.netProfitMargin(netProfit: number("netProfit") ?? -1, revenue: number("revenue") ?? -1)
        case "F12":
            calculated = FormulaEngine.debtToEquity(totalLiabilities: number("liabilities") ?? -1, shareholdersEquity: number("equity") ?? -1)
        case "F13":
            calculated = FormulaEngine.totalReturn(buyPrice: number("buyPrice") ?? -1, sellPrice: number("sellPrice") ?? -1, dividends: number("dividends") ?? 0)
        case "F14":
            calculated = FormulaEngine.holdingPeriodReturn(initialValue: number("initialValue") ?? -1, endValue: number("endValue") ?? -1, income: number("income") ?? 0)
        case "F15":
            calculated = FormulaEngine.annualizedReturn(totalReturnPercent: number("totalReturn") ?? -1, years: number("years") ?? -1)
        case "F16":
            calculated = FormulaEngine.absoluteReturn(investedAmount: number("invested") ?? -1, currentValue: number("current") ?? -1)
        case "F17":
            calculated = FormulaEngine.realReturn(nominalReturnPercent: number("nominal") ?? -1, inflationPercent: number("inflation") ?? -1)
        case "F18":
            calculated = FormulaEngine.pbRatio(marketPrice: number("marketPrice") ?? -1, bookValuePerShare: number("bookValue") ?? -1)
        case "F19":
            calculated = FormulaEngine.pegRatio(peRatio: number("pe") ?? -1, epsGrowthPercent: number("growth") ?? -1)
        case "F20":
            calculated = FormulaEngine.evToEbitda(marketCap: number("marketCap") ?? -1, totalDebt: number("debt") ?? 0, cash: number("cash") ?? 0, ebitda: number("ebitda") ?? -1)
        case "F21":
            calculated = FormulaEngine.grahamIntrinsicValue(eps: number("eps") ?? -1, growthRatePercent: number("growth") ?? 0, aaaBondYieldPercent: number("yield") ?? -1, marketPrice: number("marketPrice"))
        case "F22":
            calculated = FormulaEngine.dcf(annualCashFlow: number("cashFlow") ?? -1, discountRatePercent: number("discount") ?? -1, years: number("years") ?? -1)
        case "F23":
            calculated = FormulaEngine.earningsYield(eps: number("eps") ?? -1, marketPrice: number("marketPrice") ?? -1)
        case "F24":
            calculated = FormulaEngine.dividendPayoutRatio(dividendPerShare: number("dividend") ?? -1, eps: number("eps") ?? -1)
        case "F25":
            calculated = FormulaEngine.sharpeRatio(portfolioReturnPercent: number("portfolioReturn") ?? -1, riskFreeRatePercent: number("riskFree") ?? -1, stdDeviationPercent: number("stdDev") ?? -1)
        case "F26":
            calculated = FormulaEngine.portfolioWeightedReturn(weights: numbers(prefix: "weight"), returns: numbers(prefix: "return"))
        case "F27":
            calculated = FormulaEngine.portfolioBeta(weights: numbers(prefix: "weight"), betas: numbers(prefix: "beta"))
        case "F28":
            calculated = FormulaEngine.beta(stockReturnPercent: number("stockReturn") ?? -1, marketReturnPercent: number("marketReturn") ?? -1, riskFreeRatePercent: number("riskFree") ?? -1)
        case "F29":
            calculated = FormulaEngine.alpha(actualReturnPercent: number("actualReturn") ?? -1, riskFreeRatePercent: number("riskFree") ?? -1, beta: number("beta") ?? -1, marketReturnPercent: number("marketReturn") ?? -1)
        case "F30":
            calculated = FormulaEngine.standardDeviation(returns: numbers(prefix: "returns"))
        case "F31":
            calculated = FormulaEngine.valueAtRisk(portfolioValue: number("portfolioValue") ?? -1, confidenceLevel: number("confidence") ?? 95, dailyVolatilityPercent: number("dailyVolatility") ?? -1, days: number("days") ?? -1)
        case "F32":
            calculated = FormulaEngine.maximumDrawdown(values: numbers(prefix: "portfolioValue"))
        case "F33":
            calculated = FormulaEngine.rsi(avgGainPercent: number("avgGain") ?? -1, avgLossPercent: number("avgLoss") ?? -1, period: number("period") ?? 14)
        case "F34":
            calculated = FormulaEngine.sma(prices: numbers(prefix: "price"))
        case "F35":
            calculated = FormulaEngine.ema(previousEMA: number("previousEMA") ?? -1, currentPrice: number("currentPrice") ?? -1, period: number("period") ?? -1)
        case "F36":
            calculated = FormulaEngine.macd(ema12: number("ema12") ?? -1, ema26: number("ema26") ?? -1, previousSignalEMA9: number("signalPrev") ?? 0)
        case "F37":
            calculated = FormulaEngine.bollingerBands(sma: number("sma") ?? -1, stdDeviation: number("stdDev") ?? -1, multiplier: number("multiplier") ?? 2)
        case "F38":
            calculated = FormulaEngine.stochasticOscillator(currentClose: number("close") ?? -1, lowestLow: number("low") ?? -1, highestHigh: number("high") ?? -1)
        case "F39":
            calculated = FormulaEngine.pivotPoints(high: number("high") ?? -1, low: number("low") ?? -1, close: number("close") ?? -1)
        case "F40":
            calculated = FormulaEngine.roa(netIncome: number("netIncome") ?? -1, totalAssets: number("assets") ?? -1)
        case "F41":
            calculated = FormulaEngine.currentRatio(currentAssets: number("currentAssets") ?? -1, currentLiabilities: number("currentLiabilities") ?? -1)
        case "F42":
            calculated = FormulaEngine.operatingMargin(operatingIncome: number("operatingIncome") ?? -1, revenue: number("revenue") ?? -1)
        case "F43":
            calculated = FormulaEngine.grossMargin(revenue: number("revenue") ?? -1, cogs: number("cogs") ?? -1)
        case "F44":
            calculated = FormulaEngine.interestCoverageRatio(ebit: number("ebit") ?? -1, interestExpense: number("interestExpense") ?? -1)
        case "F45":
            calculated = FormulaEngine.assetTurnover(netSales: number("sales") ?? -1, beginningAssets: number("beginAssets") ?? -1, endingAssets: number("endAssets") ?? -1)
        case "F46":
            calculated = FormulaEngine.ytm(annualCoupon: number("coupon") ?? -1, faceValue: number("face") ?? -1, currentPrice: number("price") ?? -1, yearsToMaturity: number("years") ?? -1)
        case "F47":
            calculated = FormulaEngine.bondPrice(faceValue: number("face") ?? -1, couponRatePercent: number("couponRate") ?? -1, marketRatePercent: number("marketRate") ?? -1, years: number("years") ?? -1)
        case "F48":
            calculated = FormulaEngine.couponRate(annualCouponPayment: number("couponPayment") ?? -1, faceValue: number("face") ?? -1)
        case "F49":
            calculated = FormulaEngine.optionsBreakeven(strikePrice: number("strike") ?? -1, premiumPaid: number("premium") ?? -1, isCall: (number("isCall") ?? 1) >= 1)
        case "F50":
            calculated = FormulaEngine.optionIntrinsicValue(stockPrice: number("stock") ?? -1, strikePrice: number("strike") ?? -1, isCall: (number("isCall") ?? 1) >= 1, premium: number("premium"))
        case "F51":
            calculated = FormulaEngine.putCallParity(callPrice: number("callPrice"), putPrice: number("putPrice"), strikePrice: number("strike") ?? -1, riskFreeRatePercent: number("riskFree") ?? -1, timeYears: number("time") ?? -1, spotPrice: number("stock") ?? -1)
        case "F52":
            calculated = FormulaEngine.blackScholes(stockPrice: number("stock") ?? -1, strikePrice: number("strike") ?? -1, riskFreeRatePercent: number("riskFree") ?? -1, timeYears: number("time") ?? -1, volatilityPercent: number("volatility") ?? -1)
        case "F53":
            calculated = FormulaEngine.emi(loanAmount: number("loanAmount") ?? -1, annualRatePercent: number("annualRate") ?? -1, years: number("years") ?? -1)
        case "F54":
            calculated = FormulaEngine.simpleInterest(principal: number("principal") ?? -1, ratePercent: number("rate") ?? -1, years: number("years") ?? -1)
        case "F55":
            calculated = FormulaEngine.gstBreakup(amount: number("amount") ?? -1, gstRatePercent: number("gstRate") ?? -1)
        case "F56":
            calculated = FormulaEngine.discount(markedPrice: number("markedPrice") ?? -1, sellingPrice: number("sellingPrice") ?? -1)
        case "F57":
            calculated = FormulaEngine.requiredMonthlySavings(targetAmount: number("target") ?? -1, annualReturnPercent: number("annualReturn") ?? -1, years: number("years") ?? -1)
        case "F58":
            calculated = FormulaEngine.affordabilityEMI(monthlyIncome: number("monthlyIncome") ?? -1, foirPercent: number("foir") ?? 45, existingObligations: number("existingObligations") ?? 0)
        case "F59":
            calculated = FormulaEngine.rentalYield(monthlyRent: number("monthlyRent") ?? -1, propertyPrice: number("propertyPrice") ?? -1)
        case "F60":
            calculated = FormulaEngine.breakEvenUnits(fixedCost: number("fixedCost") ?? -1, sellingPricePerUnit: number("sellingPricePerUnit") ?? -1, variableCostPerUnit: number("variableCostPerUnit") ?? -1)
        case "F61":
            calculated = FormulaEngine.grossProfitAmount(revenue: number("revenue") ?? -1, cogs: number("cogs") ?? -1)
        case "F62":
            calculated = FormulaEngine.emergencyFundTarget(monthlyExpense: number("monthlyExpense") ?? -1, months: number("months") ?? -1)
        case "F63":
            calculated = FormulaEngine.fireCorpus(annualExpense: number("annualExpense") ?? -1, withdrawalRatePercent: number("withdrawalRate") ?? -1)
        case "F64":
            calculated = FormulaEngine.ruleOf72(annualReturnPercent: number("annualReturn") ?? -1)
        case "F65":
            calculated = FormulaEngine.futureCost(currentCost: number("currentCost") ?? -1, inflationPercent: number("inflation") ?? -1, years: number("years") ?? -1)
        case "F66":
            calculated = FormulaEngine.capitalGainsTax(gainAmount: number("gainAmount") ?? -1, taxRatePercent: number("taxRate") ?? -1)
        case "F67":
            calculated = FormulaEngine.takeHomeIncome(grossIncome: number("grossIncome") ?? -1, effectiveTaxRatePercent: number("effectiveTaxRate") ?? -1)
        case "F68":
            calculated = FormulaEngine.requiredPreTaxIncome(targetNetIncome: number("targetNetIncome") ?? -1, effectiveTaxRatePercent: number("effectiveTaxRate") ?? -1)
        case "F69":
            calculated = FormulaEngine.debtToIncome(monthlyDebt: number("monthlyDebt") ?? -1, monthlyIncome: number("monthlyIncome") ?? -1)
        case "F70":
            calculated = FormulaEngine.savingsRate(monthlySavings: number("monthlySavings") ?? -1, monthlyIncome: number("monthlyIncome") ?? -1)
        case "F71":
            calculated = FormulaEngine.netWorth(totalAssets: number("totalAssets") ?? -1, totalLiabilities: number("totalLiabilities") ?? -1)
        case "F72":
            calculated = FormulaEngine.emergencyRunway(cashReserve: number("cashReserve") ?? -1, monthlyExpense: number("monthlyExpense") ?? -1)
        case "F73":
            calculated = FormulaEngine.requiredCagrForTarget(currentAmount: number("currentAmount") ?? -1, targetAmount: number("targetAmount") ?? -1, years: number("years") ?? -1)
        case "F74":
            calculated = FormulaEngine.loanPrepaymentSavings(loanAmount: number("loanAmount") ?? -1, annualRatePercent: number("annualRate") ?? -1, years: number("years") ?? -1, extraEMI: number("extraEMI") ?? 0)
        case "F75":
            calculated = FormulaEngine.monthlyWithdrawalFromCorpus(corpus: number("corpus") ?? -1, annualReturnPercent: number("annualReturn") ?? -1, years: number("years") ?? -1)
        case "F76":
            calculated = FormulaEngine.taxRegimeComparison(
                grossSalary: number("grossSalary") ?? -1,
                standardDeductionOld: number("standardDeduction") ?? 50_000,
                hraExemption: number("hraExemption") ?? 0,
                section80C: number("section80C") ?? 0,
                section80D: number("section80D") ?? 0,
                nps80CCD1B: number("nps80ccd1b") ?? 0,
                homeLoan24B: number("homeLoan24b") ?? 0,
                otherDeductions: number("otherDeductions") ?? 0
            )
        default:
            calculated = nil
        }

        guard let calculated else {
            isCalculating = false
            showValidationError = true
            validationMessage = "Unable to calculate with current values. Check for zero or invalid ranges."
            HapticManager.play(.error)
            return
        }

        let elapsed = Date().timeIntervalSince(start)
        let minimumLoaderDuration: Double = 0.45
        if elapsed < minimumLoaderDuration {
            let remaining = UInt64((minimumLoaderDuration - elapsed) * 1_000_000_000)
            try? await Task.sleep(nanoseconds: remaining)
        }

        showValidationError = false
        validationMessage = ""
        isCalculating = false

        withAnimation(reduceMotion ? MMMotion.navigation : MMMotion.content) {
            result = calculated
            showResult = true
        }
        if shouldNavigateToResult {
            activeResultRoute = CalculatorResultRoute(
                formula: formula,
                result: calculated,
                title: formulaTitle,
                inputValues: inputValues,
                steps: currentFormulaSteps(),
                variableRows: formulaVariableRows(),
                substitutedExpression: substitutedExpressionSegments(),
                selectedCurrencyCode: currencyManager.currencyCode
            )
        }
        HapticManager.play(calculated.isPositive == false ? .warning : .success)

        if shouldSaveHistory {
            saveHistory(result: calculated)
            adManager.maybeShowInterstitialAfterCalculation()
        }
    }

    private func invalidNumericKeys() -> Set<String> {
        Set(
            formula.inputs.compactMap { input in
                let raw = inputValues[input.key, default: ""].trimmingCharacters(in: .whitespacesAndNewlines)
                if raw.isEmpty { return input.isOptional ? nil : input.key }
                if input.isDynamic {
                    if input.isOptional { return nil }
                    return parseNumbers(from: raw).isEmpty ? input.key : nil
                }
                return parseLocalizedNumber(raw) == nil ? input.key : nil
            }
        )
    }

    private func saveHistory(result: FormulaResult) {
        let history = CalculationHistory(
            formulaID: formula.id,
            formulaName: FormulaDisplayText.name(for: formula.id),
            formulaShortName: FormulaDisplayText.shortName(for: formula.id),
            formulaExpression: FormulaKnowledge.narrative(for: formula.id, fallbackExpression: "").fullExpression,
            category: formula.category.rawValue,
            inputsJSON: inputsJSON(),
            resultPrimary: result.primaryFormatted,
            secondaryResultsJSON: secondaryResultsJSON(result),
            resultUnit: result.primaryUnit,
            resultIsPositive: result.isPositive ?? true,
            interpretation: result.interpretationText,
            interpretationLevel: result.interpretation.label,
            timestamp: Date(),
            isFavorite: false
        )
        modelContext.insert(history)
        do {
            try modelContext.save()
        } catch {
            modelContext.delete(history)
            showValidationError = true
            validationMessage = "Result calculated, but history could not be saved."
        }
    }

    private func secondaryResultsJSON(_ result: FormulaResult) -> String {
        let payload = result.secondaryValues.map { item in
            ["label": item.label, "value": item.value, "unit": item.unit]
        }
        guard let data = try? JSONSerialization.data(withJSONObject: payload, options: [.sortedKeys]) else {
            return "[]"
        }
        return String(data: data, encoding: .utf8) ?? "[]"
    }

    private func inputsJSON() -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: inputValues, options: [.sortedKeys]) else {
            return "{}"
        }
        return String(data: data, encoding: .utf8) ?? "{}"
    }

    private var isFavoriteFormula: Bool {
        if let existing = favoriteFormulas.first(where: { $0.formulaID == formula.id }) {
            return existing.formulaID == formula.id
        }
        return (try? modelContext.fetch(FetchDescriptor<FavoriteFormula>()))?
            .contains(where: { $0.formulaID == formula.id }) ?? false
    }

    private func toggleFavoriteFormula() {
        if let existing = findFavoriteFormulaInStore() {
            modelContext.delete(existing)
            do {
                try modelContext.save()
                HapticManager.impact(.light)
            } catch {
                HapticManager.notify(.error)
            }
            return
        }

        let nextOrder = (favoriteFormulas.map(\.sortOrder).max() ?? -1) + 1
        let favorite = FavoriteFormula(
            formulaID: formula.id,
            formulaName: FormulaDisplayText.name(for: formula.id),
            formulaExpression: FormulaKnowledge.narrative(for: formula.id, fallbackExpression: formula.formulaExpressionKey).fullExpression,
            category: formula.category.rawValue,
            sortOrder: nextOrder
        )
        modelContext.insert(favorite)
        do {
            try modelContext.save()
            HapticManager.notify(.success)
        } catch {
            modelContext.delete(favorite)
            HapticManager.notify(.error)
        }
    }

    private func persistUsageSignals() {
        lastViewedFormulaID = formula.id

        let defaults = UserDefaults.standard
        var recent = defaults.stringArray(forKey: "mm.recentFormulaIDs") ?? []
        recent.removeAll { $0 == formula.id }
        recent.insert(formula.id, at: 0)
        defaults.set(Array(recent.prefix(12)), forKey: "mm.recentFormulaIDs")

        var categoryCounts = defaults.dictionary(forKey: "mm.categoryOpenCounts") as? [String: Int] ?? [:]
        categoryCounts[formula.category.rawValue, default: 0] += 1
        defaults.set(categoryCounts, forKey: "mm.categoryOpenCounts")
    }

    private func findFavoriteFormulaInStore() -> FavoriteFormula? {
        let descriptor = FetchDescriptor<FavoriteFormula>()
        let all = (try? modelContext.fetch(descriptor)) ?? []
        return all.first(where: { $0.formulaID == formula.id })
    }

    private var presetsStorageKey: String {
        "formula.presets.\(formula.id)"
    }

    private func loadPresets() -> [FormulaPreset] {
        guard let data = UserDefaults.standard.data(forKey: presetsStorageKey),
              let decoded = try? JSONDecoder().decode([FormulaPreset].self, from: data) else {
            return []
        }
        return decoded.sorted { $0.createdAt > $1.createdAt }
    }

    private func persistPresets(_ value: [FormulaPreset]) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        UserDefaults.standard.set(data, forKey: presetsStorageKey)
    }

    private func saveCurrentPreset(named name: String) {
        let populated = inputValues.filter { !$0.value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        guard !populated.isEmpty else {
            HapticManager.notify(.error)
            return
        }

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        var updated = presets
        if let existingIndex = updated.firstIndex(where: { $0.name.caseInsensitiveCompare(trimmedName) == .orderedSame }) {
            updated[existingIndex] = FormulaPreset(id: updated[existingIndex].id, name: trimmedName, values: populated, createdAt: Date())
        } else {
            updated.append(FormulaPreset(id: UUID(), name: trimmedName, values: populated, createdAt: Date()))
        }

        presets = updated.sorted { $0.createdAt > $1.createdAt }
        persistPresets(presets)
        HapticManager.notify(.success)
    }

    private func applyPreset(_ preset: FormulaPreset) {
        for input in formula.inputs {
            if let value = preset.values[input.key] {
                inputValues[input.key] = value
            }
        }
        HapticManager.play(.selection)
    }

    private func deletePreset(_ preset: FormulaPreset) {
        presets.removeAll { $0.id == preset.id }
        persistPresets(presets)
        HapticManager.impact(.light)
    }

    private func dismissKeyboard() {
        #if canImport(UIKit)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #endif
    }

    private func currentFormulaSteps() -> [FormulaStep] {
        let substituted = substitutedExpression(from: FormulaKnowledge.narrative(for: formula.id, fallbackExpression: formula.formulaExpressionKey).fullExpression)
        let resultText = result.map(formattedPrimaryResult) ?? "Result appears here after calculation"

        var steps = formula.formulaSteps
        if !steps.isEmpty {
            steps[0] = FormulaStep(
                title: steps[0].title,
                expression: FormulaKnowledge.narrative(for: formula.id, fallbackExpression: formula.formulaExpressionKey).fullExpression,
                result: steps[0].result,
                explanation: steps[0].explanation
            )
        }
        if steps.count > 1 {
            steps[1] = FormulaStep(
                title: steps[1].title,
                expression: substituted,
                result: "Using your current values",
                explanation: steps[1].explanation
            )
        }
        if steps.count > 2 {
            steps[2] = FormulaStep(
                title: steps[2].title,
                expression: "Final output",
                result: resultText,
                explanation: steps[2].explanation
            )
        }
        return steps
    }

    private func formulaVariableRows() -> [(symbol: String, meaning: String, value: String)] {
        let variables = FormulaKnowledge.variableLines(for: formula)
        return formula.inputs.enumerated().map { index, input in
            let variable = index < variables.count
                ? variables[index]
                : FormulaVariableLine(symbol: input.key, meaning: InputDisplayText.label(for: input.key, category: formula.category))
            return (variable.symbol, variable.meaning, displayValue(for: input))
        }
    }

    private func substitutedExpressionSegments() -> [FormulaExpressionSegment] {
        let expression = FormulaKnowledge.narrative(for: formula.id, fallbackExpression: formula.formulaExpressionKey).fullExpression
        var substituted = expression
        let rows = formula.inputs.enumerated().map { index, input -> (key: String, symbol: String, value: String) in
            let variables = FormulaKnowledge.variableLines(for: formula)
            let symbol = index < variables.count ? variables[index].symbol : input.key
            return (input.key, symbol, displayValue(for: input))
        }

        let candidates = rows.flatMap { row in
            substitutionTokens(forKey: row.key, symbol: row.symbol).map { ($0, row.value) }
        }
        .sorted { $0.0.count > $1.0.count }

        for (token, value) in candidates where !token.isEmpty {
            substituted = replaceToken(token, with: "⟪\(value)⟫", in: substituted)
        }
        return parseFormulaExpressionSegments(from: substituted)
    }

    private func parseFormulaExpressionSegments(from value: String) -> [FormulaExpressionSegment] {
        let pattern = "⟪(.*?)⟫"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return [FormulaExpressionSegment(text: value, isValue: false)]
        }

        let nsValue = value as NSString
        let matches = regex.matches(in: value, range: NSRange(location: 0, length: nsValue.length))
        guard !matches.isEmpty else {
            return [FormulaExpressionSegment(text: value, isValue: false)]
        }

        var segments: [FormulaExpressionSegment] = []
        var cursor = 0

        for match in matches {
            let fullRange = match.range(at: 0)
            if fullRange.location > cursor {
                let plain = nsValue.substring(with: NSRange(location: cursor, length: fullRange.location - cursor))
                segments.append(FormulaExpressionSegment(text: plain, isValue: false))
            }

            if match.numberOfRanges > 1 {
                let valueRange = match.range(at: 1)
                let token = nsValue.substring(with: valueRange)
                segments.append(FormulaExpressionSegment(text: token, isValue: true))
            }
            cursor = fullRange.location + fullRange.length
        }

        if cursor < nsValue.length {
            let trailing = nsValue.substring(from: cursor)
            segments.append(FormulaExpressionSegment(text: trailing, isValue: false))
        }
        return segments
    }

    private func formulaSubstitutionText(_ segments: [FormulaExpressionSegment]) -> Text {
        let attributed = segments.reduce(into: AttributedString()) { partial, segment in
            var part = AttributedString(segment.text)
            part.foregroundColor = segment.isValue ? .green : .secondary
            partial.append(part)
        }
        return Text(attributed)
    }

    private func tokenizedFormulaRows(narrative: FormulaNarrative) -> (title: String, tokens: [FormulaToken]) {
        let lhs = narrative.fullExpression.components(separatedBy: "=").first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Formula"
        let rows = formula.inputs.enumerated().map { index, input -> FormulaToken in
            let variable = FormulaKnowledge.variableLines(for: formula)
            let symbol = index < variable.count ? variable[index].symbol : input.key
            let value = displayValue(for: input)
            let color = tokenColor(for: input.key, index: index)
            return FormulaToken(text: "\(symbol): \(value)", color: color)
        }
        return (lhs, rows)
    }

    private func tokenColor(for key: String, index: Int) -> Color {
        if formula.id == "F01" {
            switch key {
            case "buyPrice": return MMPalette.toneBlue
            case "sellPrice": return MMPalette.toneGreen
            case "quantity": return MMPalette.toneOrange
            case "brokerage": return MMPalette.tonePurple
            case "stt": return MMPalette.negative
            default: return .secondary
            }
        }
        let palette: [Color] = [.blue, .green, .orange, .purple, .red, .mint, .teal, .indigo]
        return palette[index % palette.count]
    }

    private func liveFormulaSteps() -> [String] {
        if formula.id == "F01", let details = profitLossChargeBreakdown, let qty = number("quantity") {
            let step1 = details.sellTurnover / qty - details.buyTurnover / qty
            let step2 = step1 * qty
            let step3 = details.brokerageAmount + details.sttAmount
            return [
                "Sell Price - Buy Price = \(formattedDecimal(step1))",
                "\(formattedDecimal(step1)) × Quantity = \(formattedDecimal(step2))",
                "Brokerage + STT = \(formattedDecimal(step3))",
                "Net P&L = \(formattedDecimal(details.netPnL))"
            ]
        }
        return currentFormulaSteps().map { "\($0.title): \($0.result)" }
    }

    private func formattedDecimal(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = currencyManager.selectedLocale
        formatter.minimumFractionDigits = min(max(decimalPlaces, 0), 6)
        formatter.maximumFractionDigits = min(max(decimalPlaces, 0), 6)
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
    }

    private func specificCaseLine() -> String {
        let terms = inputVariableRows().map { "\($0.0)=\($0.1)" }
        return terms.joined(separator: "   •   ")
    }

    private func substitutedExpression(from expression: String) -> String {
        var substituted = expression
        let rows = formula.inputs.enumerated().map { index, input -> (key: String, symbol: String, value: String) in
            let variables = FormulaKnowledge.variableLines(for: formula)
            let symbol = index < variables.count ? variables[index].symbol : input.key
            return (input.key, symbol, displayValue(for: input))
        }

        let candidates = rows.flatMap { row in
            substitutionTokens(forKey: row.key, symbol: row.symbol).map { ($0, row.value) }
        }
        .sorted { $0.0.count > $1.0.count }

        for (token, value) in candidates where !token.isEmpty {
            substituted = replaceToken(token, with: value, in: substituted)
        }
        return substituted
    }

    private func substitutionTokens(forKey key: String, symbol: String) -> [String] {
        let phrase: String? = switch key {
        case "buyPrice": "Buy Price"
        case "sellPrice": "Sell Price"
        case "quantity": "Quantity"
        case "brokerage": "Brokerage"
        case "stt": "STT"
        case "exchangeCharges": "Exchange Charges"
        case "stampDuty": "Stamp Duty"
        case "oldShares": "Old Shares"
        case "oldAvg": "Old Avg"
        case "newShares": "New Shares"
        case "newPrice": "Current Price"
        case "targetAvg": "Target Average Price"
        case "monthly": "M"
        case "annualReturn": "r"
        case "years": "Years"
        case "initial": "Initial"
        case "final": "Final"
        case "beginning": "Beginning"
        case "ending": "Ending"
        case "marketPrice": "Market Price"
        case "eps": "EPS"
        case "dividend": "Dividend"
        case "price": "Price"
        case "revenue": "Revenue"
        case "equity": "Equity"
        case "liabilities": "Liabilities"
        case "riskFree": "Risk Free Rate"
        case "stdDev": "Std Deviation"
        case "strike": "Strike"
        case "stock": "Stock"
        case "time": "T"
        case "volatility": "Volatility"
        case "gainAmount": "Gain Amount"
        case "taxRate": "Tax Rate"
        case "grossIncome": "Gross Income"
        case "effectiveTaxRate": "Effective Tax Rate"
        case "grossSalary": "Gross Salary"
        case "standardDeduction": "Standard Deduction"
        case "hraExemption": "HRA Exemption"
        case "section80C": "Section 80C"
        case "section80D": "Section 80D"
        case "nps80ccd1b": "NPS 80CCD(1B)"
        case "homeLoan24b": "Home Loan 24(b)"
        case "otherDeductions": "Other Deductions"
        case "targetNetIncome": "Target Net Income"
        case "monthlyDebt": "Monthly Debt"
        case "monthlySavings": "Monthly Savings"
        case "totalAssets": "Total Assets"
        case "totalLiabilities": "Total Liabilities"
        case "cashReserve": "Cash Reserve"
        default: nil
        }

        if let phrase {
            return [phrase, symbol]
        }
        return [symbol]
    }

    private func replaceToken(_ token: String, with replacement: String, in expression: String) -> String {
        let escaped = NSRegularExpression.escapedPattern(for: token)
        if token.range(of: #"^[A-Za-z0-9_]+$"#, options: .regularExpression) != nil {
            let pattern = #"(?<![A-Za-z0-9_])\#(escaped)(?![A-Za-z0-9_])"#
            return expression.replacingOccurrences(of: pattern, with: replacement, options: .regularExpression)
        }
        return expression.replacingOccurrences(of: token, with: replacement)
    }

    private func inputVariableRows() -> [(String, String)] {
        let variables = FormulaKnowledge.variableLines(for: formula)
        return formula.inputs.enumerated().map { index, input in
            let symbol = index < variables.count ? variables[index].symbol : input.key
            return (symbol, displayValue(for: input))
        }
    }

    private func displayValue(for input: InputDefinition) -> String {
        let typed = inputValues[input.key]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !typed.isEmpty { return typed }
        if let defaultValue = input.defaultValue, !defaultValue.isEmpty { return defaultValue }
        if !input.placeholderKey.isEmpty {
            return input.placeholderKey
                .replacingOccurrences(of: "placeholder.", with: "")
                .replacingOccurrences(of: "_", with: " ")
                .capitalized
        }
        return "—"
    }

    private func quickSuggestions(for key: String) -> [String] {
        let normalized = key.lowercased()
        if normalized.contains("year") || normalized.contains("month") || normalized == "n" || normalized.contains("period") {
            return ["5", "10", "15", "20", "30"]
        }
        if normalized.contains("rate") || normalized.contains("return") || normalized.contains("riskfree") || normalized.contains("inflation") || normalized.contains("brokerage") || normalized.contains("stt") || normalized.contains("foir") {
            return ["5", "8", "10", "12", "15"]
        }
        if normalized.contains("amount") || normalized.contains("price") || normalized.contains("value") || normalized.contains("investment") || normalized.contains("loan") || normalized.contains("corpus") {
            return ["1000", "5000", "10000", "50000", "100000"]
        }
        if normalized.contains("quantity") || normalized.contains("shares") || normalized.contains("units") || normalized.contains("days") {
            return ["1", "10", "25", "50", "100"]
        }
        return ["1", "5", "10", "25"]
    }

    @ViewBuilder
    private func smartScenarioSection(for result: FormulaResult) -> some View {
        let scenarios = projectedScenarios(for: result)
        LiquidGlassCard(categoryColor: MMPalette.appTint.opacity(0.26), cornerRadius: 18, contentPadding: 0, isPressed: false) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 11, weight: .semibold))
                    Text("SMART SCENARIOS")
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .tracking(2)
                }
                .foregroundStyle(MMPalette.appTint)

                Text("Projected outcomes from your current inputs.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    ForEach(scenarios, id: \.title) { scenario in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(scenario.title)
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .tracking(1.5)
                                .foregroundStyle(.secondary)
                            Text(formatProjectedValue(scenario.value))
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(scenarioColor(base: result, projected: scenario.value))
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                            Text(result.primaryUnit)
                                .font(.system(size: 9, weight: .medium, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity, minHeight: 78, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.clear)
                                .glassEffect(in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(scenario.stroke.opacity(0.26), lineWidth: 0.8)
                        )
                    }
                }

                Text(coachInsightText(for: result))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(14)
        }
    }

    private func projectedScenarios(for result: FormulaResult) -> [(title: String, value: Double, stroke: Color)] {
        let factors: (Double, Double) = {
            if hasGrowthInputSignal {
                return (0.92, 1.10)
            }
            if hasCostInputSignal {
                return (0.90, 1.08)
            }
            return (0.93, 1.07)
        }()

        return [
            ("Conservative", result.primaryValue * factors.0, .red),
            ("Base", result.primaryValue, MMPalette.appTint),
            ("Upside", result.primaryValue * factors.1, .green)
        ]
    }

    private var hasGrowthInputSignal: Bool {
        let keys = formula.inputs.map { $0.key.lowercased() }
        return keys.contains(where: { key in
            key.contains("rate") || key.contains("return") || key.contains("growth") || key.contains("yield") || key.contains("inflation")
        })
    }

    private var hasCostInputSignal: Bool {
        let keys = formula.inputs.map { $0.key.lowercased() }
        return keys.contains(where: { key in
            key.contains("price") || key.contains("cost") || key.contains("expense") || key.contains("loan") || key.contains("principal")
        })
    }

    private func scenarioColor(base: FormulaResult, projected: Double) -> Color {
        if let isPositive = base.isPositive {
            if isPositive {
                return projected >= base.primaryValue ? .green : .red
            }
            return projected <= base.primaryValue ? .green : .red
        }
        return MMPalette.appTint
    }

    private func formatProjectedValue(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let stored = UserDefaults.standard.object(forKey: "settings.decimals") == nil ? 2 : UserDefaults.standard.integer(forKey: "settings.decimals")
        let clamped = min(max(stored, 0), 8)
        formatter.minimumFractionDigits = clamped
        formatter.maximumFractionDigits = clamped
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
    }

    private func coachInsightText(for result: FormulaResult) -> String {
        if let isPositive = result.isPositive, !isPositive {
            return "Coach tip: reduce high-impact inputs first and rerun to move this result into a safer range."
        }
        switch result.interpretation {
        case .excellent:
            return "Coach tip: this output is strong. Save this setup as your reference baseline."
        case .good:
            return "Coach tip: you are in a healthy range. Use Upside as a target and Conservative as your risk guard."
        case .neutral:
            return "Coach tip: you are near balance. Small input changes can significantly improve the outcome."
        case .caution, .poor:
            return "Coach tip: this is a caution zone. Stress test assumptions before committing to a decision."
        }
    }
}

private struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 4
    var shakesPerUnit: CGFloat = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: amount * sin(animatableData * .pi * shakesPerUnit), y: 0))
    }
}

private struct FormulaExpressionSegment: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let isValue: Bool
}

private struct FormulaToken: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let color: Color
}

private struct FormulaExplanationSheet: View {
    let title: String
    let expression: String
    let substitutedExpression: [FormulaExpressionSegment]
    let variableRows: [(symbol: String, meaning: String, value: String)]
    let steps: [FormulaStep]
    let onClose: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    sectionCard(title: "Formula") {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(expression)
                                .font(.system(.body, design: .monospaced).weight(.semibold))
                                .foregroundStyle(.primary)
                                .fixedSize(horizontal: false, vertical: true)

                            formulaSubstitutedText()
                                .font(.system(.body, design: .monospaced))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    sectionCard(title: "Step by Step") {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(steps) { step in
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(step.title)
                                        .font(.headline.weight(.semibold))
                                        .foregroundStyle(.primary)
                                    Text(step.expression)
                                        .font(.system(.footnote, design: .monospaced))
                                        .foregroundStyle(.primary)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Text(step.result)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.green)
                                    Text(step.explanation)
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(12)
                                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                        }
                    }

                    sectionCard(title: "What is this?") {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(Array(variableRows.enumerated()), id: \.offset) { _, row in
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 6) {
                                        Text(row.symbol)
                                            .font(.system(.footnote, design: .monospaced).weight(.semibold))
                                            .foregroundStyle(.primary)
                                        Text("=")
                                            .font(.system(.footnote, design: .monospaced))
                                            .foregroundStyle(.secondary)
                                        Text(row.value)
                                            .font(.system(.footnote, design: .monospaced).weight(.semibold))
                                            .foregroundStyle(.green)
                                    }
                                    Text(row.meaning)
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 18)
            }
            .background(.ultraThinMaterial)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onClose()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                    }
                    .accessibilityLabel("Close formula sheet")
                }
            }
        }
    }

    @ViewBuilder
    private func sectionCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.secondary)
            content()
        }
        .padding(14)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func formulaSubstitutedText() -> Text {
        var attributed = AttributedString()
        for segment in substitutedExpression {
            var part = AttributedString(segment.text)
            part.foregroundColor = segment.isValue ? .green : .secondary
            attributed.append(part)
        }
        return Text(attributed)
    }
}

private struct CalculatorResultView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(CurrencyManager.self) private var currencyManager
    let route: CalculatorResultRoute
    let detailAccent: Color
    @State private var showTaxBreakdown = false

    private var isProfit: Bool { route.result.isPositive ?? (route.result.primaryValue >= 0) }
    private var taxDetails: TaxRegimeComparisonDetails? {
        guard route.formula.id == "F76" else { return nil }
        func val(_ key: String, fallback: Double = 0) -> Double {
            let raw = route.inputValues[key, default: ""].replacingOccurrences(of: ",", with: "")
            return Double(raw) ?? fallback
        }
        return FormulaEngine.taxRegimeComparisonDetails(
            grossSalary: val("grossSalary", fallback: -1),
            standardDeductionOld: val("standardDeduction", fallback: 50_000),
            hraExemption: val("hraExemption"),
            section80C: val("section80C"),
            section80D: val("section80D"),
            nps80CCD1B: val("nps80ccd1b"),
            homeLoan24B: val("homeLoan24b"),
            otherDeductions: val("otherDeductions")
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                if route.formula.id == "F76" {
                    taxComparisonContent
                } else {
                    primaryResultCard
                    tradeSummaryCard
                    breakevenCard
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .navigationTitle(route.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var taxComparisonContent: some View {
        if let details = taxDetails {
            let oldBetter = details.betterRegime == "Old"

            HStack(alignment: .top, spacing: 12) {
                taxRegimeCard(
                    title: "Old Regime",
                    data: details.oldRegime,
                    isBetter: oldBetter,
                    isHigherTax: !oldBetter
                )
                taxRegimeCard(
                    title: "New Regime",
                    data: details.newRegime,
                    isBetter: !oldBetter,
                    isHigherTax: oldBetter
                )
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("You save \(currency(details.savingsAmount)) with \(details.betterRegime) regime")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(MMPalette.positive)

                Button(showTaxBreakdown ? "Hide Slab Breakdown" : "Show Slab Breakdown") {
                    withAnimation(MMMotion.content) {
                        showTaxBreakdown.toggle()
                    }
                }
                .buttonStyle(.plain)
                .font(.footnote.weight(.semibold))

                if showTaxBreakdown {
                    slabBreakdownCard(title: "Old Regime Slabs", data: details.oldRegime)
                    slabBreakdownCard(title: "New Regime Slabs", data: details.newRegime)
                }
            }
            .padding(14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }

    @ViewBuilder
    private func taxRegimeCard(
        title: String,
        data: TaxRegimeComputation,
        isBetter: Bool,
        isHigherTax: Bool
    ) -> some View {
        let accent = isBetter ? MMPalette.positive : (isHigherTax ? MMPalette.negative : .secondary)
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Text(title)
                    .font(.headline.weight(.semibold))
                Spacer()
                if isBetter {
                    Text("Better for you ✓")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(MMPalette.positive)
                }
            }

            taxLine("Taxable income", currency(data.taxableIncome))
            taxLine("Total tax", currency(data.totalTax))
            taxLine("Monthly tax", currency(data.monthlyTax))
            taxLine("Take home monthly", currency(data.takeHomeMonthly))
            taxLine("Take home annual", currency(data.takeHomeAnnual))
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(accent.opacity(0.55), lineWidth: 1.2)
        )
    }

    @ViewBuilder
    private func slabBreakdownCard(title: String, data: TaxRegimeComputation) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline.weight(.semibold))
            ForEach(data.slabs, id: \.label) { slab in
                HStack {
                    Text(slab.label)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(currency(slab.taxAmount))
                        .font(.system(.caption, design: .monospaced).weight(.semibold))
                }
            }
            Divider()
            taxLine("Base Tax", currency(data.baseTax))
            taxLine("Rebate", currency(data.rebate))
            taxLine("Cess (4%)", currency(data.cess))
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    @ViewBuilder
    private func taxLine(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.system(.caption, design: .monospaced).weight(.semibold))
                .foregroundStyle(.primary)
        }
    }

    private func currency(_ value: Double) -> String {
        currencyManager.formatAmount(value)
    }

    private var primaryResultCard: some View {
        let color = isProfit ? MMPalette.positive : MMPalette.negative
        return VStack(spacing: 6) {
            Text(formattedPrimary(route.result))
                .font(.system(size: 42, weight: .black))
                .foregroundStyle(color)
                .multilineTextAlignment(.center)
            Text(isProfit ? "Profit" : "Loss")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.secondary)
            if let returnItem = route.result.secondaryValues.first(where: { $0.label.lowercased().contains("return") }) {
                Text("\(returnItem.value)% return")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .padding(.horizontal, 16)
        .background(
            LinearGradient(
                colors: [color.opacity(0.12), color.opacity(0.04)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
    }

    @ViewBuilder
    private var tradeSummaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Trade Summary")
                .font(.headline.weight(.semibold))
            ForEach(route.result.secondaryValues, id: \.label) { item in
                HStack {
                    Text(item.label)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(formattedSecondary(item))
                        .font(.system(.subheadline, design: .monospaced).weight(.semibold))
                        .foregroundStyle(.primary)
                }
            }
            Divider()
            HStack {
                Text("Net P&L")
                    .font(.headline.weight(.bold))
                Spacer()
                Text(formattedPrimary(route.result))
                    .font(.system(.headline, design: .monospaced).weight(.bold))
                    .foregroundStyle(isProfit ? MMPalette.positive : MMPalette.negative)
            }
        }
        .padding(14)
        .mmCardSurface(corner: 18, tint: detailAccent.opacity(colorScheme == .dark ? 0.16 : 0.22))
    }

    @ViewBuilder
    private var breakevenCard: some View {
        if let breakEven = route.result.secondaryValues.first(where: { $0.label.lowercased().contains("break-even") })?.value {
            VStack(alignment: .leading, spacing: 8) {
                Text("Breakeven")
                    .font(.headline.weight(.semibold))
                Text("You need to sell above \(breakEven) to profit.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.secondary.opacity(0.22))
                        Capsule().fill((isProfit ? MMPalette.positive : MMPalette.negative).opacity(0.7))
                            .frame(width: proxy.size.width * 0.72)
                    }
                }
                .frame(height: 8)
            }
            .padding(14)
            .mmCardSurface(corner: 18, tint: detailAccent.opacity(colorScheme == .dark ? 0.16 : 0.22))
        }
    }

    private func formattedSecondary(_ item: (label: String, value: String, unit: String)) -> String {
        if item.unit.isEmpty { return item.value }
        if let composite = composedCurrencyValue(value: item.value, unit: item.unit) {
            return composite
        }
        return "\(item.value) \(item.unit)"
    }

    private func formattedPrimary(_ result: FormulaResult) -> String {
        if result.primaryUnit.isEmpty { return result.primaryFormatted }
        if let composite = composedCurrencyValue(value: result.primaryFormatted, unit: result.primaryUnit) {
            return composite
        }
        return "\(result.primaryFormatted) \(result.primaryUnit)"
    }

    private func composedCurrencyValue(value: String, unit: String) -> String? {
        let symbol = currencyManager.currencySymbol
        guard unit.contains(symbol) else { return nil }
        let suffix = unit.replacingOccurrences(of: symbol, with: "").trimmingCharacters(in: .whitespaces)
        if suffix.isEmpty {
            return currencyManager.isSymbolPrefix ? "\(symbol)\(value)" : "\(value)\(symbol)"
        }
        if currencyManager.isSymbolPrefix {
            return "\(symbol)\(value) \(suffix)"
        }
        return "\(value)\(symbol) \(suffix)"
    }
}

private extension Array where Element == FormulaExpressionSegment {
    var substitutedExpressionText: String {
        reduce(into: AttributedString()) { partial, segment in
            var run = AttributedString(segment.text)
            run.foregroundColor = segment.isValue ? .green : .secondary
            partial.append(run)
        }
        .description
    }
}

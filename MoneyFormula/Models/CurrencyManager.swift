import Foundation
import Observation

@Observable
final class CurrencyManager {
    private let storage = UserDefaults.standard
    private let storageKey = "settings.currency"
    private let supportedCurrencyCodes = ["INR", "USD", "EUR", "GBP", "JPY"]

    var selectedCurrency: Currency
    var selectedLocale: Locale
    private(set) var supportedCurrencies: [Currency]

    var currencySymbol: String { selectedCurrency.symbol }
    var currencyCode: String { selectedCurrency.code }
    var isSymbolPrefix: Bool { selectedCurrency.symbolPosition == .prefix }

    init() {
        let detectedLocale = Locale.autoupdatingCurrent
        let detectedCurrencyCode = detectedLocale.currency?.identifier ?? "USD"
        let persistedCurrencyCode = storage.string(forKey: storageKey)
        let activeCode = persistedCurrencyCode ?? detectedCurrencyCode

        let all = Self.buildCurrencies(supportedCodes: supportedCurrencyCodes, deviceCode: detectedCurrencyCode)
        let resolvedCurrency = all.first(where: { $0.code == activeCode }) ?? all.first ?? Currency(
            code: "USD",
            symbol: "$",
            name: "US Dollar",
            localeIdentifier: "en_US",
            symbolPosition: .prefix,
            decimalPlaces: 2
        )
        let resolvedLocale = Locale(identifier: resolvedCurrency.localeIdentifier)

        self.supportedCurrencies = all
        self.selectedCurrency = resolvedCurrency
        self.selectedLocale = resolvedLocale

        storage.set(selectedCurrency.code, forKey: storageKey)
    }

    func setCurrency(code: String) {
        guard let found = supportedCurrencies.first(where: { $0.code == code }) else { return }
        selectedCurrency = found
        selectedLocale = Locale(identifier: found.localeIdentifier)
        storage.set(found.code, forKey: storageKey)
    }

    func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = selectedLocale
        formatter.numberStyle = .currency
        formatter.currencyCode = selectedCurrency.code
        formatter.currencySymbol = selectedCurrency.symbol
        formatter.minimumFractionDigits = selectedCurrency.decimalPlaces
        formatter.maximumFractionDigits = selectedCurrency.decimalPlaces
        return formatter.string(from: NSNumber(value: amount)) ?? "\(selectedCurrency.symbol)\(amount)"
    }

    func formatPercentage(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = selectedLocale
        formatter.numberStyle = .percent
        formatter.multiplier = 1
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)%"
    }

    func formatDuration(_ value: Double, unit: String) -> String {
        let formatter = NumberFormatter()
        formatter.locale = selectedLocale
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        let amount = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
        switch unit.lowercased() {
        case "years", "year":
            return "\(amount) years"
        case "months", "month":
            return "\(amount) months"
        default:
            return "\(amount) \(unit)"
        }
    }

    func formatNumber(_ value: Double, minimumFractionDigits: Int = 0, maximumFractionDigits: Int = 6) -> String {
        let formatter = NumberFormatter()
        formatter.locale = selectedLocale
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = minimumFractionDigits
        formatter.maximumFractionDigits = maximumFractionDigits
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    func parseAmount(_ string: String) -> Double? {
        let formatter = NumberFormatter()
        formatter.locale = selectedLocale
        formatter.numberStyle = .decimal

        let cleaned = string
            .replacingOccurrences(of: selectedCurrency.symbol, with: "")
            .replacingOccurrences(of: "\u{00A0}", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if let number = formatter.number(from: cleaned) {
            return number.doubleValue
        }

        let grouping = selectedLocale.groupingSeparator ?? ","
        let decimal = selectedLocale.decimalSeparator ?? "."
        let normalized = cleaned
            .replacingOccurrences(of: grouping, with: "")
            .replacingOccurrences(of: decimal, with: ".")
            .replacingOccurrences(of: " ", with: "")
        return Double(normalized)
    }

    private static func buildCurrencies(supportedCodes: [String], deviceCode: String) -> [Currency] {
        let catalog: [Currency] = [
            Currency(code: "INR", symbol: "₹", name: "Indian Rupee", localeIdentifier: "en_IN", symbolPosition: .prefix, decimalPlaces: 2),
            Currency(code: "USD", symbol: "$", name: "US Dollar", localeIdentifier: "en_US", symbolPosition: .prefix, decimalPlaces: 2),
            Currency(code: "EUR", symbol: "€", name: "Euro", localeIdentifier: "en_IE", symbolPosition: .prefix, decimalPlaces: 2),
            Currency(code: "GBP", symbol: "£", name: "British Pound", localeIdentifier: "en_GB", symbolPosition: .prefix, decimalPlaces: 2),
            Currency(code: "JPY", symbol: "¥", name: "Japanese Yen", localeIdentifier: "ja_JP", symbolPosition: .prefix, decimalPlaces: 0)
        ]

        var items = catalog.filter { supportedCodes.contains($0.code) }
        items.sort { lhs, rhs in
            if lhs.code == deviceCode { return true }
            if rhs.code == deviceCode { return false }
            return lhs.code < rhs.code
        }
        return items
    }
}

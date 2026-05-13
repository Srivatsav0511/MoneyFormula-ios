import Foundation
import SwiftData

@Model
final class AppSettings {
    var id: UUID = UUID()
    var currencyCode: String = "USD"
    var localeIdentifier: String = Locale.autoupdatingCurrent.identifier
    var isDarkMode: Bool = false
    var showFormulaByDefault: Bool = true
    var enableHaptics: Bool = true
    var enableAutoCalculate: Bool = true
    var autoCalculateDelay: Double = 0.5
    var defaultDurationUnit: String = "years"
    var hasCompletedOnboarding: Bool = false
    var lastOpenedCalculatorId: String?
    var appOpenCount: Int = 0
    var reviewRequested: Bool = false

    init() {}
}

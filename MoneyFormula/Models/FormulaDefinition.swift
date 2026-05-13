import Foundation
import SwiftUI

struct FormulaStep: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    let title: String
    let expression: String
    let result: String
    let explanation: String

    init(
        id: UUID = UUID(),
        title: String,
        expression: String,
        result: String,
        explanation: String
    ) {
        self.id = id
        self.title = title
        self.expression = expression
        self.result = result
        self.explanation = explanation
    }
}

struct InputDefinition: Identifiable, Hashable, Codable, Sendable {
    let key: String
    let labelKey: String
    let unitKey: String
    let placeholderKey: String
    let isOptional: Bool
    let defaultValue: String?
    let isDynamic: Bool

    var id: String { key }

    var label: LocalizedStringKey { LocalizedStringKey(labelKey) }
    var unit: LocalizedStringKey { LocalizedStringKey(unitKey) }
    var placeholder: LocalizedStringKey { LocalizedStringKey(placeholderKey) }
}

struct FormulaDefinition: Identifiable, Hashable, Codable, Sendable {
    let id: String
    let nameKey: String
    let shortNameKey: String
    let descriptionKey: String
    let formulaExpressionKey: String
    let category: FormulaCategory
    let sfSymbol: String
    let inputs: [InputDefinition]
    let isPriority: Bool
    let displayOrder: Int

    var name: LocalizedStringKey { LocalizedStringKey(nameKey) }
    var shortName: LocalizedStringKey { LocalizedStringKey(shortNameKey) }
    var description: LocalizedStringKey { LocalizedStringKey(descriptionKey) }
    var formulaExpression: LocalizedStringKey { LocalizedStringKey(formulaExpressionKey) }
}

extension FormulaDefinition {
    var displayName: String { FormulaDisplayText.name(for: id) }
    var alias: String { FormulaDisplayText.shortName(for: id) }
    var cardExpression: String { FormulaKnowledge.narrative(for: id, fallbackExpression: "").cardExpression }
    var narrativeDescription: String { FormulaKnowledge.narrative(for: id, fallbackExpression: "").explanation }
    var formulaSteps: [FormulaStep] { FormulaKnowledge.formulaSteps(for: self) }
}

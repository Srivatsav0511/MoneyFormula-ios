import Foundation
import SwiftData

@Model
final class CalculationHistory {
    var id: UUID = UUID()
    var formulaID: String = ""
    var formulaName: String = ""
    var formulaShortName: String = ""
    var formulaExpression: String = ""
    var category: String = ""
    var inputsJSON: String = ""
    var resultPrimary: String = ""
    var secondaryResultsJSON: String = ""
    var resultUnit: String = ""
    var resultIsPositive: Bool = true
    var interpretation: String = ""
    var interpretationLevel: String = ""
    var timestamp: Date = Date()
    var isFavorite: Bool = false

    init(
        id: UUID = UUID(),
        formulaID: String = "",
        formulaName: String = "",
        formulaShortName: String = "",
        formulaExpression: String = "",
        category: String = "",
        inputsJSON: String = "",
        resultPrimary: String = "",
        secondaryResultsJSON: String = "",
        resultUnit: String = "",
        resultIsPositive: Bool = true,
        interpretation: String = "",
        interpretationLevel: String = "",
        timestamp: Date = Date(),
        isFavorite: Bool = false
    ) {
        self.id = id
        self.formulaID = formulaID
        self.formulaName = formulaName
        self.formulaShortName = formulaShortName
        self.formulaExpression = formulaExpression
        self.category = category
        self.inputsJSON = inputsJSON
        self.resultPrimary = resultPrimary
        self.secondaryResultsJSON = secondaryResultsJSON
        self.resultUnit = resultUnit
        self.resultIsPositive = resultIsPositive
        self.interpretation = interpretation
        self.interpretationLevel = interpretationLevel
        self.timestamp = timestamp
        self.isFavorite = isFavorite
    }
}

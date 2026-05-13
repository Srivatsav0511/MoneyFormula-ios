import Foundation
import SwiftData

@Model
final class FavoriteFormula {
    var id: UUID = UUID()
    var formulaID: String = ""
    var formulaName: String = ""
    var formulaExpression: String = ""
    var category: String = ""
    var sortOrder: Int = 0

    init(
        id: UUID = UUID(),
        formulaID: String = "",
        formulaName: String = "",
        formulaExpression: String = "",
        category: String = "",
        sortOrder: Int = 0
    ) {
        self.id = id
        self.formulaID = formulaID
        self.formulaName = formulaName
        self.formulaExpression = formulaExpression
        self.category = category
        self.sortOrder = sortOrder
    }
}

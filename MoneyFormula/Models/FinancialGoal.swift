import Foundation
import SwiftData

@Model
final class FinancialGoal {
    var id: UUID = UUID()
    var name: String = ""
    var targetAmount: Double = 0
    var currentAmount: Double = 0
    var targetDate: Date = Date()
    var categoryID: String = ""
    var monthlyContribution: Double = 0
    var createdAt: Date = Date()
    var notes: String = ""

    init(
        id: UUID = UUID(),
        name: String = "",
        targetAmount: Double = 0,
        currentAmount: Double = 0,
        targetDate: Date = Date(),
        categoryID: String = "",
        monthlyContribution: Double = 0,
        createdAt: Date = Date(),
        notes: String = ""
    ) {
        self.id = id
        self.name = name
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.targetDate = targetDate
        self.categoryID = categoryID
        self.monthlyContribution = monthlyContribution
        self.createdAt = createdAt
        self.notes = notes
    }
}

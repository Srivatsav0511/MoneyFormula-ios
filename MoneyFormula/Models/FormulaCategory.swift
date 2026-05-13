import SwiftUI

enum FormulaCategory: String, CaseIterable, Identifiable, Codable, Sendable {
    case returns
    case taxation
    case valuation
    case risk
    case technical
    case fundamental
    case planning
    case portfolio
    case bonds
    case sipAndMF
    case options

    var id: String { rawValue }

    var displayOrder: Int {
        switch self {
        case .taxation:
            0
        case .sipAndMF:
            1
        case .returns:
            2
        case .portfolio:
            3
        case .risk:
            4
        case .planning:
            5
        case .fundamental:
            6
        case .valuation:
            7
        case .bonds:
            8
        case .technical:
            9
        case .options:
            10
        }
    }

    var nameKey: LocalizedStringKey {
        switch self {
        case .returns:
            "category.returns"
        case .taxation:
            "category.taxation"
        case .valuation:
            "category.valuation"
        case .risk:
            "category.risk"
        case .technical:
            "category.technical"
        case .fundamental:
            "category.fundamental"
        case .planning:
            "category.planning"
        case .portfolio:
            "category.portfolio"
        case .bonds:
            "category.bonds"
        case .sipAndMF:
            "category.sip_mf"
        case .options:
            "category.options"
        }
    }

    var displayName: String {
        switch self {
        case .returns: "Tax & Returns"
        case .taxation: "Taxation"
        case .valuation: "Asset Valuation"
        case .risk: "Loans & EMI"
        case .technical: "Business"
        case .fundamental: "Retirement"
        case .planning: "Financial Planning"
        case .portfolio: "Stocks"
        case .bonds: "Insurance"
        case .sipAndMF: "SIP & Investments"
        case .options: "Crypto"
        }
    }

    var localizedDisplayName: String {
        switch self {
        case .returns:
            String(localized: "category.returns.title", defaultValue: "Tax & Returns")
        case .taxation:
            String(localized: "category.taxation.title", defaultValue: "Taxation")
        case .valuation:
            String(localized: "category.valuation.title", defaultValue: "Asset Valuation")
        case .risk:
            String(localized: "category.risk.title", defaultValue: "Loans & EMI")
        case .technical:
            String(localized: "category.technical.title", defaultValue: "Business")
        case .fundamental:
            String(localized: "category.fundamental.title", defaultValue: "Retirement")
        case .planning:
            String(localized: "category.planning.title", defaultValue: "Financial Planning")
        case .portfolio:
            String(localized: "category.portfolio.title", defaultValue: "Stocks")
        case .bonds:
            String(localized: "category.bonds.title", defaultValue: "Insurance")
        case .sipAndMF:
            String(localized: "category.sip_mf.title", defaultValue: "SIP & Investments")
        case .options:
            String(localized: "category.options.title", defaultValue: "Crypto")
        }
    }

    var shortNameKey: LocalizedStringKey {
        switch self {
        case .returns:
            "category.short.returns"
        case .taxation:
            "category.short.taxation"
        case .valuation:
            "category.short.valuation"
        case .risk:
            "category.short.risk"
        case .technical:
            "category.short.technical"
        case .fundamental:
            "category.short.fundamental"
        case .planning:
            "category.short.planning"
        case .portfolio:
            "category.short.portfolio"
        case .bonds:
            "category.short.bonds"
        case .sipAndMF:
            "category.short.sip_mf"
        case .options:
            "category.short.options"
        }
    }

    var sfSymbol: String {
        switch self {
        case .returns:
            "doc.text.fill"
        case .taxation:
            "percent"
        case .valuation:
            "house.fill"
        case .risk:
            "indianrupeesign.circle.fill"
        case .technical:
            "briefcase.fill"
        case .fundamental:
            "person.fill.checkmark"
        case .planning:
            "calendar.badge.clock"
        case .portfolio:
            "chart.line.uptrend.xyaxis"
        case .bonds:
            "shield.fill"
        case .sipAndMF:
            "calendar.badge.plus"
        case .options:
            "bitcoinsign.circle.fill"
        }
    }

    var color: Color {
        MMPalette.categoryAccent(self)
    }
}

extension FormulaCategory {
    static var ordered: [FormulaCategory] {
        allCases.sorted { $0.displayOrder < $1.displayOrder }
    }

    var premiumGradientTop: Color {
        color.opacity(1.0)
    }

    var premiumGradientBottom: Color {
        color.opacity(0.78)
    }

    var premiumIconTileTop: Color {
        color.opacity(0.56)
    }

    var premiumIconTileBottom: Color {
        color.opacity(0.34)
    }

    var premiumBorderOpacity: Double {
        0.32
    }
}

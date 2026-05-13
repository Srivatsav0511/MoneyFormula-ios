import Foundation
import SwiftUI

struct FormulaResult: Sendable {
    let primaryValue: Double
    let primaryFormatted: String
    let primaryUnit: String
    let secondaryValues: [(label: String, value: String, unit: String)]
    let interpretation: InterpretationLevel
    let interpretationText: String
    let detailedExplanation: String
    let isPositive: Bool?
}

struct TaxSlabBreakdownItem: Sendable, Hashable {
    let label: String
    let taxablePortion: Double
    let ratePercent: Double
    let taxAmount: Double
}

struct TaxRegimeComputation: Sendable, Hashable {
    let taxableIncome: Double
    let baseTax: Double
    let rebate: Double
    let cess: Double
    let totalTax: Double
    let monthlyTax: Double
    let takeHomeMonthly: Double
    let takeHomeAnnual: Double
    let slabs: [TaxSlabBreakdownItem]
}

struct TaxRegimeComparisonDetails: Sendable, Hashable {
    let grossSalary: Double
    let oldRegime: TaxRegimeComputation
    let newRegime: TaxRegimeComputation
    let betterRegime: String
    let savingsAmount: Double
}

enum InterpretationLevel: Sendable {
    case excellent
    case good
    case neutral
    case caution
    case poor

    var color: Color {
        switch self {
        case .excellent, .good:
            .green
        case .neutral:
            .secondary
        case .caution:
            .orange
        case .poor:
            .red
        }
    }

    var label: String {
        switch self {
        case .excellent:
            "EXCELLENT"
        case .good:
            "GOOD"
        case .neutral:
            "NEUTRAL"
        case .caution:
            "CAUTION"
        case .poor:
            "RISKY"
        }
    }

    var icon: String {
        switch self {
        case .excellent:
            "star.circle.fill"
        case .good:
            "checkmark.seal.fill"
        case .neutral:
            "minus.circle.fill"
        case .caution:
            "exclamationmark.triangle.fill"
        case .poor:
            "xmark.octagon.fill"
        }
    }
}

enum FormulaEngine {
    private static let knownCurrencySymbols: Set<String> = {
        var symbols = Set<String>()
        for identifier in Locale.availableIdentifiers {
            let locale = Locale(identifier: identifier)
            if let symbol = locale.currencySymbol, !symbol.isEmpty {
                symbols.insert(symbol)
            }
        }
        return symbols
    }()

    private static var activeCurrencySymbol: String {
        let defaults = UserDefaults.standard
        if let localeIdentifier = defaults.string(forKey: "settings.locale.identifier") {
            let locale = Locale(identifier: localeIdentifier)
            if let symbol = locale.currencySymbol, !symbol.isEmpty {
                return symbol
            }
        }

        if let code = defaults.string(forKey: "settings.currency"), !code.isEmpty {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = code
            if let symbol = formatter.currencySymbol, !symbol.isEmpty {
                return symbol
            }
        }

        return Locale.autoupdatingCurrent.currencySymbol ?? "¤"
    }

    private static func normalizedUnit(_ unit: String) -> String {
        guard !unit.isEmpty else { return unit }
        var normalized = unit
        for symbol in knownCurrencySymbols where symbol != activeCurrencySymbol {
            normalized = normalized.replacingOccurrences(of: symbol, with: activeCurrencySymbol)
        }
        return normalized
    }

    private static var configuredNumberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let storedLocale = UserDefaults.standard.string(forKey: "settings.locale.identifier")
        formatter.locale = Locale(identifier: storedLocale ?? Locale.autoupdatingCurrent.identifier)
        let defaults = UserDefaults.standard
        let stored = defaults.object(forKey: "settings.decimals") == nil ? 2 : defaults.integer(forKey: "settings.decimals")
        let clamped = min(max(stored, 0), 8)
        formatter.minimumFractionDigits = clamped
        formatter.maximumFractionDigits = clamped
        return formatter
    }

    private static func safeDiv(_ numerator: Double, _ denominator: Double) -> Double? {
        guard denominator != 0 else { return nil }
        let value = numerator / denominator
        return value.isFinite ? value : nil
    }

    private static func safeSqrt(_ value: Double) -> Double? {
        guard value >= 0 else { return nil }
        let root = sqrt(value)
        return root.isFinite ? root : nil
    }

    private static func safeLog(_ value: Double) -> Double? {
        guard value > 0 else { return nil }
        let logged = log(value)
        return logged.isFinite ? logged : nil
    }

    private static func safePow(_ base: Double, _ exponent: Double) -> Double? {
        guard base.isFinite, exponent.isFinite else { return nil }
        let value = pow(base, exponent)
        return value.isFinite ? value : nil
    }

    private static func format(_ value: Double) -> String {
        configuredNumberFormatter.string(from: NSNumber(value: value)) ?? String(value)
    }

    private static func makeResult(
        value: Double,
        unit: String,
        interpretation: InterpretationLevel,
        interpretationText: String,
        detailedExplanation: String? = nil,
        isPositive: Bool? = nil,
        secondaryValues: [(String, String, String)] = []
    ) -> FormulaResult? {
        guard value.isFinite else { return nil }
        let normalizedPrimaryUnit = normalizedUnit(unit)
        let normalizedSecondaryValues = secondaryValues.map { item in
            (item.0, item.1, normalizedUnit(item.2))
        }
        return FormulaResult(
            primaryValue: value,
            primaryFormatted: format(value),
            primaryUnit: normalizedPrimaryUnit,
            secondaryValues: normalizedSecondaryValues,
            interpretation: interpretation,
            interpretationText: interpretationText,
            detailedExplanation: detailedExplanation ?? interpretationText,
            isPositive: isPositive
        )
    }

    static func profitAndLoss(
        buyPrice: Double,
        sellPrice: Double,
        quantity: Double,
        brokeragePercent: Double,
        sttPercent: Double,
        exchangeChargePercent: Double = 0,
        stampDutyPercent: Double = 0.015,
        sebiChargePercent: Double = 0.0001,
        gstOnBrokeragePercent: Double = 18
    ) -> FormulaResult? {
        guard quantity > 0, buyPrice >= 0, sellPrice >= 0 else { return nil }

        let gross = (sellPrice - buyPrice) * quantity
        let buyTurnover = buyPrice * quantity
        let sellTurnover = sellPrice * quantity
        let turnover = buyTurnover + sellTurnover
        let brokerage = turnover * (brokeragePercent / 100)
        let stt = sellTurnover * (sttPercent / 100)
        let exchangeCharges = turnover * (exchangeChargePercent / 100)
        let gstOnBrokerage = brokerage * (gstOnBrokeragePercent / 100)
        let stampDuty = buyTurnover * (stampDutyPercent / 100)
        let sebiCharges = turnover * (sebiChargePercent / 100)
        let totalCharges = brokerage + stt + exchangeCharges + gstOnBrokerage + stampDuty + sebiCharges
        let net = gross - totalCharges
        let invested = buyPrice * quantity

        guard let returnPct = safeDiv(net * 100, invested) else { return nil }
        let perShareCost = totalCharges / quantity
        let breakEven = buyPrice + perShareCost

        let interpretation: InterpretationLevel = net > 0 ? .good : (net < 0 ? .poor : .neutral)
        let text = net > 0 ? "Net profitable after costs" : (net < 0 ? "Net loss after charges" : "Break-even after costs")

        return makeResult(
            value: net,
            unit: "₹",
            interpretation: interpretation,
            interpretationText: text,
            isPositive: net >= 0,
            secondaryValues: [
                ("Buy Value", format(buyTurnover), "₹"),
                ("Sell Value", format(sellTurnover), "₹"),
                ("Gross P&L", format(gross), "₹"),
                ("Brokerage", format(brokerage), "₹"),
                ("STT", format(stt), "₹"),
                ("Exchange", format(exchangeCharges), "₹"),
                ("GST", format(gstOnBrokerage), "₹"),
                ("Stamp Duty", format(stampDuty), "₹"),
                ("SEBI", format(sebiCharges), "₹"),
                ("Total Charges", format(totalCharges), "₹"),
                ("Return", format(returnPct), "%"),
                ("Break-even", format(breakEven), "₹")
            ]
        )
    }

    static func costAveraging(
        oldShares: Double,
        oldAveragePrice: Double,
        newShares: Double,
        newBuyPrice: Double
    ) -> FormulaResult? {
        guard oldShares >= 0, newShares >= 0, oldAveragePrice >= 0, newBuyPrice >= 0 else { return nil }
        let totalShares = oldShares + newShares
        guard totalShares > 0 else { return nil }

        let totalInvested = oldShares * oldAveragePrice + newShares * newBuyPrice
        let newAverage = totalInvested / totalShares
        let delta = newAverage - oldAveragePrice
        let deltaPct = oldAveragePrice == 0 ? 0 : (delta / oldAveragePrice) * 100

        let interpretation: InterpretationLevel = newBuyPrice < oldAveragePrice ? .good : (newBuyPrice > oldAveragePrice ? .caution : .neutral)
        let text = newBuyPrice < oldAveragePrice ? "Averaging down lowers cost base" : (newBuyPrice > oldAveragePrice ? "Averaging up increases cost base" : "Cost base remains unchanged")

        return makeResult(
            value: newAverage,
            unit: "₹",
            interpretation: interpretation,
            interpretationText: text,
            isPositive: delta <= 0,
            secondaryValues: [
                ("Total Shares", format(totalShares), "shares"),
                ("Total Invested", format(totalInvested), "₹"),
                ("Needs to Reach", format(newAverage), "₹"),
                ("Change", format(delta), "₹"),
                ("Change %", format(deltaPct), "%")
            ]
        )
    }

    static func sharesNeededForTargetAverage(
        oldShares: Double,
        oldAveragePrice: Double,
        newBuyPrice: Double,
        targetAveragePrice: Double
    ) -> FormulaResult? {
        guard oldShares >= 0, oldAveragePrice >= 0, newBuyPrice >= 0, targetAveragePrice > 0 else { return nil }
        let numerator = oldShares * (oldAveragePrice - targetAveragePrice)
        let denominator = targetAveragePrice - newBuyPrice
        guard let sharesNeeded = safeDiv(numerator, denominator), sharesNeeded >= 0 else { return nil }

        return makeResult(
            value: sharesNeeded,
            unit: "shares",
            interpretation: .neutral,
            interpretationText: "Additional shares needed to reach target average"
        )
    }

    static func sip(monthly: Double, annualReturnPercent: Double, years: Double) -> FormulaResult? {
        guard monthly > 0, years > 0, annualReturnPercent >= 0 else { return nil }
        let months = years * 12
        let r = annualReturnPercent / 100 / 12

        let corpus: Double
        if r == 0 {
            corpus = monthly * months
        } else {
            guard let factor = safePow(1 + r, months) else { return nil }
            corpus = monthly * ((factor - 1) / r) * (1 + r)
        }

        let invested = monthly * months
        let gained = corpus - invested
        let gainPct = invested == 0 ? 0 : (gained / invested) * 100

        return makeResult(
            value: corpus,
            unit: "₹",
            interpretation: .good,
            interpretationText: "Long-term compounding can create substantial wealth",
            isPositive: true,
            secondaryValues: [
                ("Invested", format(invested), "₹"),
                ("Estimated Returns", format(gained), "₹"),
                ("Wealth Gained", format(gainPct), "%")
            ]
        )
    }

    static func lumpsum(investment: Double, annualReturnPercent: Double, years: Double) -> FormulaResult? {
        guard investment > 0, annualReturnPercent >= 0, years > 0 else { return nil }
        guard let growth = safePow(1 + annualReturnPercent / 100, years) else { return nil }
        let maturity = investment * growth
        let gain = maturity - investment

        return makeResult(
            value: maturity,
            unit: "₹",
            interpretation: .good,
            interpretationText: "Projected maturity from compounded lump-sum investment",
            isPositive: true,
            secondaryValues: [("Wealth Gained", format(gain), "₹")]
        )
    }

    static func emi(loanAmount: Double, annualRatePercent: Double, years: Double) -> FormulaResult? {
        guard loanAmount > 0, annualRatePercent >= 0, years > 0 else { return nil }
        let months = years * 12
        guard months > 0 else { return nil }
        let monthlyRate = annualRatePercent / 100 / 12

        let monthlyEMI: Double
        if monthlyRate == 0 {
            monthlyEMI = loanAmount / months
        } else {
            guard let growth = safePow(1 + monthlyRate, months) else { return nil }
            monthlyEMI = loanAmount * monthlyRate * growth / (growth - 1)
        }

        let totalPayment = monthlyEMI * months
        let totalInterest = totalPayment - loanAmount
        return makeResult(
            value: monthlyEMI,
            unit: "₹ / month",
            interpretation: .neutral,
            interpretationText: "Estimated monthly EMI for your loan",
            secondaryValues: [
                ("Total Payment", format(totalPayment), "₹"),
                ("Total Interest", format(totalInterest), "₹"),
                ("Loan Tenure", format(months), "months")
            ]
        )
    }

    static func simpleInterest(principal: Double, ratePercent: Double, years: Double) -> FormulaResult? {
        guard principal > 0, ratePercent >= 0, years > 0 else { return nil }
        let interest = principal * ratePercent * years / 100
        let maturity = principal + interest
        return makeResult(
            value: interest,
            unit: "₹",
            interpretation: .neutral,
            interpretationText: "Simple interest earned on principal",
            isPositive: true,
            secondaryValues: [
                ("Principal", format(principal), "₹"),
                ("Total Amount", format(maturity), "₹")
            ]
        )
    }

    static func gstBreakup(amount: Double, gstRatePercent: Double) -> FormulaResult? {
        guard amount >= 0, gstRatePercent >= 0 else { return nil }
        let gstValue = amount * gstRatePercent / 100
        let total = amount + gstValue
        return makeResult(
            value: total,
            unit: "₹",
            interpretation: .neutral,
            interpretationText: "Final bill amount including GST",
            secondaryValues: [
                ("Base Amount", format(amount), "₹"),
                ("GST", format(gstValue), "₹")
            ]
        )
    }

    static func discount(markedPrice: Double, sellingPrice: Double) -> FormulaResult? {
        guard markedPrice > 0, sellingPrice >= 0, sellingPrice <= markedPrice else { return nil }
        let saved = markedPrice - sellingPrice
        guard let discountPct = safeDiv(saved * 100, markedPrice) else { return nil }
        return makeResult(
            value: discountPct,
            unit: "%",
            interpretation: discountPct >= 20 ? .good : .neutral,
            interpretationText: "Discount percentage on marked price",
            isPositive: discountPct >= 0,
            secondaryValues: [
                ("You Save", format(saved), "₹"),
                ("Final Price", format(sellingPrice), "₹")
            ]
        )
    }

    static func requiredMonthlySavings(targetAmount: Double, annualReturnPercent: Double, years: Double) -> FormulaResult? {
        guard targetAmount > 0, years > 0, annualReturnPercent >= 0 else { return nil }
        let months = years * 12
        let monthlyRate = annualReturnPercent / 100 / 12

        let monthly: Double
        if monthlyRate == 0 {
            monthly = targetAmount / months
        } else {
            guard let growth = safePow(1 + monthlyRate, months) else { return nil }
            let denominator = (growth - 1) * (1 + monthlyRate)
            guard denominator > 0 else { return nil }
            monthly = targetAmount * monthlyRate / denominator
        }

        return makeResult(
            value: monthly,
            unit: "₹ / month",
            interpretation: .good,
            interpretationText: "Required monthly saving to hit your target",
            secondaryValues: [
                ("Target", format(targetAmount), "₹"),
                ("Tenure", format(months), "months"),
                ("Expected Return", format(annualReturnPercent), "%")
            ]
        )
    }

    static func affordabilityEMI(monthlyIncome: Double, foirPercent: Double, existingObligations: Double) -> FormulaResult? {
        guard monthlyIncome > 0, foirPercent > 0, foirPercent <= 100, existingObligations >= 0 else { return nil }
        let allowed = monthlyIncome * foirPercent / 100
        let available = max(allowed - existingObligations, 0)
        return makeResult(
            value: available,
            unit: "₹ / month",
            interpretation: available > 0 ? .good : .caution,
            interpretationText: "Estimated additional EMI you can afford",
            secondaryValues: [
                ("Allowed EMI", format(allowed), "₹ / month"),
                ("Existing EMIs", format(existingObligations), "₹ / month")
            ]
        )
    }

    static func rentalYield(monthlyRent: Double, propertyPrice: Double) -> FormulaResult? {
        guard monthlyRent >= 0, propertyPrice > 0 else { return nil }
        let annualRent = monthlyRent * 12
        guard let yieldPct = safeDiv(annualRent * 100, propertyPrice) else { return nil }
        return makeResult(
            value: yieldPct,
            unit: "%",
            interpretation: yieldPct >= 4 ? .good : .neutral,
            interpretationText: "Gross annual rental yield",
            secondaryValues: [
                ("Annual Rent", format(annualRent), "₹"),
                ("Property Value", format(propertyPrice), "₹")
            ]
        )
    }

    static func breakEvenUnits(fixedCost: Double, sellingPricePerUnit: Double, variableCostPerUnit: Double) -> FormulaResult? {
        guard fixedCost >= 0, sellingPricePerUnit > 0, variableCostPerUnit >= 0 else { return nil }
        let contribution = sellingPricePerUnit - variableCostPerUnit
        guard contribution > 0 else { return nil }
        let units = fixedCost / contribution
        return makeResult(
            value: units,
            unit: "units",
            interpretation: .neutral,
            interpretationText: "Units needed to break even",
            secondaryValues: [
                ("Contribution / Unit", format(contribution), "₹"),
                ("Fixed Cost", format(fixedCost), "₹")
            ]
        )
    }

    static func grossProfitAmount(revenue: Double, cogs: Double) -> FormulaResult? {
        guard revenue >= 0, cogs >= 0 else { return nil }
        let gross = revenue - cogs
        let margin = revenue > 0 ? (gross / revenue) * 100 : 0
        return makeResult(
            value: gross,
            unit: "₹",
            interpretation: gross >= 0 ? .good : .poor,
            interpretationText: "Revenue left after direct costs",
            isPositive: gross >= 0,
            secondaryValues: [
                ("Revenue", format(revenue), "₹"),
                ("Gross Margin", format(margin), "%")
            ]
        )
    }

    static func emergencyFundTarget(monthlyExpense: Double, months: Double) -> FormulaResult? {
        guard monthlyExpense >= 0, months > 0 else { return nil }
        let target = monthlyExpense * months
        return makeResult(
            value: target,
            unit: "₹",
            interpretation: .neutral,
            interpretationText: "Recommended emergency reserve corpus",
            secondaryValues: [
                ("Monthly Expense", format(monthlyExpense), "₹"),
                ("Coverage", format(months), "months")
            ]
        )
    }

    static func fireCorpus(annualExpense: Double, withdrawalRatePercent: Double) -> FormulaResult? {
        guard annualExpense > 0, withdrawalRatePercent > 0 else { return nil }
        guard let corpus = safeDiv(annualExpense * 100, withdrawalRatePercent) else { return nil }
        return makeResult(
            value: corpus,
            unit: "₹",
            interpretation: .neutral,
            interpretationText: "Estimated corpus required for financial independence",
            secondaryValues: [
                ("Annual Expense", format(annualExpense), "₹"),
                ("Withdrawal Rate", format(withdrawalRatePercent), "%")
            ]
        )
    }

    static func ruleOf72(annualReturnPercent: Double) -> FormulaResult? {
        guard annualReturnPercent > 0 else { return nil }
        let years = 72 / annualReturnPercent
        return makeResult(
            value: years,
            unit: "years",
            interpretation: annualReturnPercent >= 12 ? .good : .neutral,
            interpretationText: "Approximate time required to double money"
        )
    }

    static func futureCost(currentCost: Double, inflationPercent: Double, years: Double) -> FormulaResult? {
        guard currentCost >= 0, inflationPercent >= 0, years >= 0 else { return nil }
        guard let growth = safePow(1 + inflationPercent / 100, years) else { return nil }
        let future = currentCost * growth
        let increase = future - currentCost
        return makeResult(
            value: future,
            unit: "₹",
            interpretation: .neutral,
            interpretationText: "Projected future cost after inflation",
            secondaryValues: [
                ("Current Cost", format(currentCost), "₹"),
                ("Increase", format(increase), "₹")
            ]
        )
    }

    static func roi(initial: Double, final: Double) -> FormulaResult? {
        guard initial > 0, final >= 0 else { return nil }
        let profit = final - initial
        guard let roiPct = safeDiv(profit * 100, initial) else { return nil }

        return makeResult(
            value: roiPct,
            unit: "%",
            interpretation: roiPct > 0 ? .good : (roiPct < 0 ? .poor : .neutral),
            interpretationText: "Return relative to initial investment",
            isPositive: roiPct >= 0,
            secondaryValues: [("Profit/Loss", format(profit), "₹")]
        )
    }

    static func cagr(beginning: Double, ending: Double, years: Double) -> FormulaResult? {
        guard beginning > 0, ending >= 0, years > 0 else { return nil }
        let ratio = ending / beginning
        guard ratio >= 0 else { return nil }
        guard let powered = safePow(ratio, 1 / years) else { return nil }
        let cagr = (powered - 1) * 100

        return makeResult(
            value: cagr,
            unit: "%",
            interpretation: cagr >= 15 ? .excellent : (cagr >= 10 ? .good : (cagr >= 0 ? .neutral : .poor)),
            interpretationText: "Annualized compounded growth rate",
            isPositive: cagr >= 0
        )
    }

    static func peRatio(marketPrice: Double, eps: Double) -> FormulaResult? {
        guard marketPrice >= 0, eps > 0 else { return nil }
        guard let pe = safeDiv(marketPrice, eps) else { return nil }

        let level: InterpretationLevel
        if pe < 10 { level = .good }
        else if pe <= 20 { level = .neutral }
        else if pe <= 30 { level = .caution }
        else { level = .poor }

        return makeResult(value: pe, unit: "x", interpretation: level, interpretationText: "Valuation multiple based on earnings")
    }

    static func eps(netIncome: Double, preferredDividends: Double, sharesOutstanding: Double) -> FormulaResult? {
        guard sharesOutstanding > 0 else { return nil }
        guard let epsValue = safeDiv(netIncome - preferredDividends, sharesOutstanding) else { return nil }
        return makeResult(value: epsValue, unit: "₹", interpretation: epsValue > 0 ? .good : .poor, interpretationText: "Earnings per share")
    }

    static func roe(netIncome: Double, shareholdersEquity: Double) -> FormulaResult? {
        guard shareholdersEquity > 0 else { return nil }
        guard let value = safeDiv(netIncome * 100, shareholdersEquity) else { return nil }
        let level: InterpretationLevel = value > 20 ? .excellent : (value >= 15 ? .good : (value >= 10 ? .neutral : .poor))
        return makeResult(value: value, unit: "%", interpretation: level, interpretationText: "Return on shareholders equity", isPositive: value >= 0)
    }

    static func dividendYield(dividendPerShare: Double, sharePrice: Double) -> FormulaResult? {
        guard sharePrice > 0, dividendPerShare >= 0 else { return nil }
        guard let value = safeDiv(dividendPerShare * 100, sharePrice) else { return nil }
        return makeResult(value: value, unit: "%", interpretation: value >= 3 ? .good : .neutral, interpretationText: "Annual dividend return relative to price")
    }

    static func netProfitMargin(netProfit: Double, revenue: Double) -> FormulaResult? {
        guard revenue > 0 else { return nil }
        guard let value = safeDiv(netProfit * 100, revenue) else { return nil }
        return makeResult(value: value, unit: "%", interpretation: value >= 20 ? .excellent : (value >= 10 ? .good : .caution), interpretationText: "Net income as a percentage of revenue")
    }

    static func debtToEquity(totalLiabilities: Double, shareholdersEquity: Double) -> FormulaResult? {
        guard shareholdersEquity > 0 else { return nil }
        guard let value = safeDiv(totalLiabilities, shareholdersEquity) else { return nil }
        let level: InterpretationLevel = value < 0.5 ? .good : (value <= 1 ? .neutral : (value <= 2 ? .caution : .poor))
        return makeResult(value: value, unit: "x", interpretation: level, interpretationText: "Leverage level based on liabilities versus equity")
    }

    static func totalReturn(buyPrice: Double, sellPrice: Double, dividends: Double) -> FormulaResult? {
        guard buyPrice > 0 else { return nil }
        let gain = (sellPrice - buyPrice) + dividends
        guard let value = safeDiv(gain * 100, buyPrice) else { return nil }
        return makeResult(value: value, unit: "%", interpretation: value >= 0 ? .good : .poor, interpretationText: "Price gain plus dividends relative to buy price", isPositive: value >= 0)
    }

    static func holdingPeriodReturn(initialValue: Double, endValue: Double, income: Double) -> FormulaResult? {
        guard initialValue > 0 else { return nil }
        let net = endValue - initialValue + income
        guard let value = safeDiv(net * 100, initialValue) else { return nil }
        return makeResult(value: value, unit: "%", interpretation: value >= 0 ? .good : .poor, interpretationText: "Total return for the holding period", isPositive: value >= 0)
    }

    static func annualizedReturn(totalReturnPercent: Double, years: Double) -> FormulaResult? {
        guard years > 0 else { return nil }
        let total = totalReturnPercent / 100
        let base = 1 + total
        guard base > 0, let powered = safePow(base, 1 / years) else { return nil }
        let value = (powered - 1) * 100
        return makeResult(value: value, unit: "%", interpretation: value > 12 ? .good : .neutral, interpretationText: "Annualized equivalent of cumulative return", isPositive: value >= 0)
    }

    static func absoluteReturn(investedAmount: Double, currentValue: Double) -> FormulaResult? {
        guard investedAmount > 0 else { return nil }
        let delta = currentValue - investedAmount
        guard let value = safeDiv(delta * 100, investedAmount) else { return nil }
        return makeResult(value: value, unit: "%", interpretation: value >= 0 ? .good : .poor, interpretationText: "Absolute change from invested amount", isPositive: value >= 0)
    }

    static func realReturn(nominalReturnPercent: Double, inflationPercent: Double) -> FormulaResult? {
        guard nominalReturnPercent > -100, inflationPercent > -100 else { return nil }
        let nominal = 1 + nominalReturnPercent / 100
        let inflation = 1 + inflationPercent / 100
        guard inflation != 0 else { return nil }
        let value = ((nominal / inflation) - 1) * 100
        return makeResult(value: value, unit: "%", interpretation: value > 0 ? .good : .caution, interpretationText: "Inflation-adjusted return", isPositive: value >= 0)
    }

    static func pbRatio(marketPrice: Double, bookValuePerShare: Double) -> FormulaResult? {
        guard bookValuePerShare > 0 else { return nil }
        guard let value = safeDiv(marketPrice, bookValuePerShare) else { return nil }
        let level: InterpretationLevel = value < 1 ? .good : (value <= 3 ? .neutral : .caution)
        return makeResult(value: value, unit: "x", interpretation: level, interpretationText: "Price-to-book valuation multiple")
    }

    static func pegRatio(peRatio: Double, epsGrowthPercent: Double) -> FormulaResult? {
        guard epsGrowthPercent > 0 else { return nil }
        guard let value = safeDiv(peRatio, epsGrowthPercent) else { return nil }
        let level: InterpretationLevel = value < 1 ? .good : (value <= 2 ? .neutral : .poor)
        return makeResult(value: value, unit: "x", interpretation: level, interpretationText: "P/E adjusted for earnings growth")
    }

    static func evToEbitda(marketCap: Double, totalDebt: Double, cash: Double, ebitda: Double) -> FormulaResult? {
        guard ebitda > 0 else { return nil }
        let ev = marketCap + totalDebt - cash
        guard let value = safeDiv(ev, ebitda) else { return nil }
        let level: InterpretationLevel = value < 10 ? .good : (value <= 15 ? .neutral : (value <= 20 ? .caution : .poor))
        return makeResult(value: value, unit: "x", interpretation: level, interpretationText: "Enterprise value to EBITDA multiple")
    }

    static func grahamIntrinsicValue(eps: Double, growthRatePercent: Double, aaaBondYieldPercent: Double, marketPrice: Double?) -> FormulaResult? {
        guard aaaBondYieldPercent > 0 else { return nil }
        let intrinsic = eps * (8.5 + 2 * growthRatePercent) * 4.4 / aaaBondYieldPercent
        var secondaries: [(String, String, String)] = []
        if let marketPrice {
            secondaries.append(("Market Price", format(marketPrice), "₹"))
            secondaries.append(("Difference", format(intrinsic - marketPrice), "₹"))
        }
        return makeResult(value: intrinsic, unit: "₹", interpretation: .neutral, interpretationText: "Graham intrinsic valuation estimate", secondaryValues: secondaries)
    }

    static func dcf(annualCashFlow: Double, discountRatePercent: Double, years: Double) -> FormulaResult? {
        guard annualCashFlow >= 0, discountRatePercent > -100, years > 0 else { return nil }
        let roundedYears = Int(years.rounded(.down))
        guard roundedYears >= 1 else { return nil }
        let rate = discountRatePercent / 100
        var pv = 0.0
        for year in 1...roundedYears {
            let factor = pow(1 + rate, Double(year))
            guard factor != 0 else { return nil }
            pv += annualCashFlow / factor
        }
        return makeResult(value: pv, unit: "₹", interpretation: .neutral, interpretationText: "Present value of projected cash flows")
    }

    static func earningsYield(eps: Double, marketPrice: Double) -> FormulaResult? {
        guard marketPrice > 0 else { return nil }
        guard let value = safeDiv(eps * 100, marketPrice) else { return nil }
        return makeResult(value: value, unit: "%", interpretation: value >= 8 ? .good : .neutral, interpretationText: "Inverse of P/E ratio")
    }

    static func dividendPayoutRatio(dividendPerShare: Double, eps: Double) -> FormulaResult? {
        guard eps > 0 else { return nil }
        guard let value = safeDiv(dividendPerShare * 100, eps) else { return nil }
        let level: InterpretationLevel = value < 30 ? .good : (value <= 60 ? .neutral : .caution)
        return makeResult(value: value, unit: "%", interpretation: level, interpretationText: "Portion of earnings distributed as dividends")
    }

    static func sharpeRatio(portfolioReturnPercent: Double, riskFreeRatePercent: Double, stdDeviationPercent: Double) -> FormulaResult? {
        guard stdDeviationPercent > 0 else { return nil }
        guard let value = safeDiv(portfolioReturnPercent - riskFreeRatePercent, stdDeviationPercent) else { return nil }
        let level: InterpretationLevel = value > 2 ? .excellent : (value >= 1 ? .good : (value >= 0 ? .neutral : .poor))
        return makeResult(value: value, unit: "", interpretation: level, interpretationText: "Risk-adjusted return quality")
    }

    static func portfolioWeightedReturn(weights: [Double], returns: [Double]) -> FormulaResult? {
        guard !weights.isEmpty, weights.count == returns.count else { return nil }
        let totalWeight = weights.reduce(0, +)
        guard totalWeight > 0 else { return nil }

        let weighted = zip(weights, returns).reduce(0.0) { partial, pair in
            partial + pair.0 * pair.1
        }
        let value = weighted / totalWeight

        return makeResult(value: value, unit: "%", interpretation: value >= 0 ? .good : .poor, interpretationText: "Portfolio return weighted by allocation", isPositive: value >= 0)
    }

    static func portfolioBeta(weights: [Double], betas: [Double]) -> FormulaResult? {
        guard !weights.isEmpty, weights.count == betas.count else { return nil }
        let totalWeight = weights.reduce(0, +)
        guard totalWeight > 0 else { return nil }

        let weighted = zip(weights, betas).reduce(0.0) { partial, pair in
            partial + pair.0 * pair.1
        }
        let value = weighted / totalWeight
        let level: InterpretationLevel = value < 0.8 ? .good : (value <= 1.2 ? .neutral : .caution)

        return makeResult(value: value, unit: "β", interpretation: level, interpretationText: "Portfolio sensitivity versus market")
    }

    static func beta(stockReturnPercent: Double, marketReturnPercent: Double, riskFreeRatePercent: Double) -> FormulaResult? {
        let marketExcess = marketReturnPercent - riskFreeRatePercent
        guard marketExcess != 0 else { return nil }
        guard let value = safeDiv(stockReturnPercent - riskFreeRatePercent, marketExcess) else { return nil }
        return makeResult(value: value, unit: "β", interpretation: .neutral, interpretationText: "Relative volatility against market")
    }

    static func alpha(actualReturnPercent: Double, riskFreeRatePercent: Double, beta: Double, marketReturnPercent: Double) -> FormulaResult? {
        let expected = riskFreeRatePercent + beta * (marketReturnPercent - riskFreeRatePercent)
        let value = actualReturnPercent - expected
        return makeResult(value: value, unit: "%", interpretation: value > 0 ? .good : .poor, interpretationText: "Jensens alpha versus expected CAPM return", isPositive: value >= 0)
    }

    static func standardDeviation(returns: [Double]) -> FormulaResult? {
        guard !returns.isEmpty else { return nil }
        let mean = returns.reduce(0, +) / Double(returns.count)
        let variance = returns.reduce(0.0) { partial, value in
            let diff = value - mean
            return partial + diff * diff
        } / Double(returns.count)

        guard let sd = safeSqrt(variance) else { return nil }
        return makeResult(
            value: sd,
            unit: "%",
            interpretation: sd < 10 ? .good : (sd < 20 ? .neutral : .caution),
            interpretationText: "Volatility of periodic returns",
            secondaryValues: [("Mean Return", format(mean), "%")]
        )
    }

    static func valueAtRisk(portfolioValue: Double, confidenceLevel: Double, dailyVolatilityPercent: Double, days: Double) -> FormulaResult? {
        guard portfolioValue >= 0, dailyVolatilityPercent >= 0, days > 0 else { return nil }

        let zScore: Double
        switch confidenceLevel {
        case 90: zScore = 1.28
        case 95: zScore = 1.645
        case 99: zScore = 2.326
        default: return nil
        }

        guard let dayFactor = safeSqrt(days) else { return nil }
        let varAmount = portfolioValue * (dailyVolatilityPercent / 100) * zScore * dayFactor
        return makeResult(value: varAmount, unit: "₹", interpretation: .caution, interpretationText: "Estimated maximum loss at selected confidence level", isPositive: false)
    }

    static func maximumDrawdown(values: [Double]) -> FormulaResult? {
        guard values.count >= 2 else { return nil }
        var peak = values[0]
        var trough = values[0]
        var maxDrawdown = 0.0
        var maxDrawdownPeak = values[0]
        var maxDrawdownTrough = values[0]

        for value in values {
            if value > peak {
                peak = value
                trough = value
            } else if value < trough {
                trough = value
            }

            if peak > 0 {
                let dd = ((peak - value) / peak) * 100
                if dd > maxDrawdown {
                    maxDrawdown = dd
                    maxDrawdownPeak = peak
                    maxDrawdownTrough = value
                }
            }
        }

        return makeResult(
            value: maxDrawdown,
            unit: "%",
            interpretation: maxDrawdown < 10 ? .good : (maxDrawdown < 20 ? .caution : .poor),
            interpretationText: "Largest peak-to-trough decline",
            isPositive: false,
            secondaryValues: [
                ("Peak", format(maxDrawdownPeak), "₹"),
                ("Trough", format(maxDrawdownTrough), "₹")
            ]
        )
    }

    static func rsi(avgGainPercent: Double, avgLossPercent: Double, period: Double) -> FormulaResult? {
        guard period > 0, avgGainPercent >= 0, avgLossPercent >= 0 else { return nil }
        if avgGainPercent == 0, avgLossPercent == 0 {
            return makeResult(value: 50, unit: "", interpretation: .neutral, interpretationText: "No directional momentum")
        }
        guard avgLossPercent > 0 else {
            return makeResult(value: 100, unit: "", interpretation: .caution, interpretationText: "Overbought zone")
        }

        guard let rs = safeDiv(avgGainPercent, avgLossPercent) else { return nil }
        let rsiValue = 100 - (100 / (1 + rs))
        let level: InterpretationLevel = rsiValue < 30 ? .good : (rsiValue <= 70 ? .neutral : .caution)
        return makeResult(value: rsiValue, unit: "", interpretation: level, interpretationText: "Momentum oscillator from 0 to 100")
    }

    static func sma(prices: [Double]) -> FormulaResult? {
        guard !prices.isEmpty else { return nil }
        let value = prices.reduce(0, +) / Double(prices.count)
        return makeResult(value: value, unit: "₹", interpretation: .neutral, interpretationText: "Simple moving average")
    }

    static func ema(previousEMA: Double, currentPrice: Double, period: Double) -> FormulaResult? {
        guard period > 0 else { return nil }
        let multiplier = 2 / (period + 1)
        let value = currentPrice * multiplier + previousEMA * (1 - multiplier)
        return makeResult(value: value, unit: "₹", interpretation: .neutral, interpretationText: "Exponential moving average")
    }

    static func macd(ema12: Double, ema26: Double, previousSignalEMA9: Double) -> FormulaResult? {
        let macdValue = ema12 - ema26
        let smoothing = 2.0 / 10.0
        let signal = previousSignalEMA9 + smoothing * (macdValue - previousSignalEMA9)
        let histogram = macdValue - signal
        return makeResult(
            value: macdValue,
            unit: "",
            interpretation: histogram >= 0 ? .good : .caution,
            interpretationText: "MACD line relative to signal",
            secondaryValues: [
                ("Signal", format(signal), ""),
                ("Histogram", format(histogram), "")
            ]
        )
    }

    static func bollingerBands(sma: Double, stdDeviation: Double, multiplier: Double) -> FormulaResult? {
        guard multiplier >= 0, stdDeviation >= 0 else { return nil }
        let upper = sma + multiplier * stdDeviation
        let lower = sma - multiplier * stdDeviation
        return makeResult(
            value: upper,
            unit: "₹",
            interpretation: .neutral,
            interpretationText: "Volatility bands around moving average",
            secondaryValues: [
                ("Middle", format(sma), "₹"),
                ("Lower", format(lower), "₹")
            ]
        )
    }

    static func stochasticOscillator(currentClose: Double, lowestLow: Double, highestHigh: Double) -> FormulaResult? {
        let range = highestHigh - lowestLow
        guard range > 0 else { return nil }
        let rawValue = ((currentClose - lowestLow) / range) * 100
        let value = min(max(rawValue, 0), 100)
        let level: InterpretationLevel = value < 20 ? .good : (value <= 80 ? .neutral : .caution)
        return makeResult(value: value, unit: "%", interpretation: level, interpretationText: "Position in recent high-low range")
    }

    static func pivotPoints(high: Double, low: Double, close: Double) -> FormulaResult? {
        let pivot = (high + low + close) / 3
        let r1 = 2 * pivot - low
        let r2 = pivot + (high - low)
        let s1 = 2 * pivot - high
        let s2 = pivot - (high - low)
        return makeResult(
            value: pivot,
            unit: "₹",
            interpretation: .neutral,
            interpretationText: "Key intraday support and resistance levels",
            secondaryValues: [
                ("R1", format(r1), "₹"),
                ("R2", format(r2), "₹"),
                ("S1", format(s1), "₹"),
                ("S2", format(s2), "₹")
            ]
        )
    }

    static func roa(netIncome: Double, totalAssets: Double) -> FormulaResult? {
        guard totalAssets > 0 else { return nil }
        guard let value = safeDiv(netIncome * 100, totalAssets) else { return nil }
        return makeResult(value: value, unit: "%", interpretation: value >= 10 ? .good : .neutral, interpretationText: "Return generated from total assets", isPositive: value >= 0)
    }

    static func currentRatio(currentAssets: Double, currentLiabilities: Double) -> FormulaResult? {
        guard currentLiabilities > 0 else { return nil }
        guard let value = safeDiv(currentAssets, currentLiabilities) else { return nil }
        let level: InterpretationLevel = value < 1 ? .poor : (value <= 2 ? .neutral : .good)
        return makeResult(value: value, unit: "x", interpretation: level, interpretationText: "Short-term liquidity coverage")
    }

    static func operatingMargin(operatingIncome: Double, revenue: Double) -> FormulaResult? {
        guard revenue > 0 else { return nil }
        guard let value = safeDiv(operatingIncome * 100, revenue) else { return nil }
        return makeResult(value: value, unit: "%", interpretation: value >= 15 ? .good : .neutral, interpretationText: "Operating income as a share of revenue")
    }

    static func grossMargin(revenue: Double, cogs: Double) -> FormulaResult? {
        guard revenue > 0 else { return nil }
        let grossProfit = revenue - cogs
        guard let value = safeDiv(grossProfit * 100, revenue) else { return nil }
        return makeResult(value: value, unit: "%", interpretation: value >= 40 ? .excellent : (value >= 20 ? .good : .caution), interpretationText: "Gross profitability before operating expenses")
    }

    static func interestCoverageRatio(ebit: Double, interestExpense: Double) -> FormulaResult? {
        guard interestExpense > 0 else { return nil }
        guard let value = safeDiv(ebit, interestExpense) else { return nil }
        let level: InterpretationLevel = value < 1.5 ? .poor : (value <= 3 ? .caution : .good)
        return makeResult(value: value, unit: "x", interpretation: level, interpretationText: "Ability to service interest payments")
    }

    static func assetTurnover(netSales: Double, beginningAssets: Double, endingAssets: Double) -> FormulaResult? {
        let averageAssets = (beginningAssets + endingAssets) / 2
        guard averageAssets > 0 else { return nil }
        guard let value = safeDiv(netSales, averageAssets) else { return nil }
        return makeResult(value: value, unit: "x", interpretation: value >= 1 ? .good : .neutral, interpretationText: "Revenue generated per unit of assets")
    }

    static func ytm(annualCoupon: Double, faceValue: Double, currentPrice: Double, yearsToMaturity: Double) -> FormulaResult? {
        guard faceValue > 0, currentPrice > 0, yearsToMaturity > 0 else { return nil }
        let numerator = annualCoupon + (faceValue - currentPrice) / yearsToMaturity
        let denominator = (faceValue + currentPrice) / 2
        guard let value = safeDiv(numerator * 100, denominator) else { return nil }
        return makeResult(value: value, unit: "%", interpretation: .neutral, interpretationText: "Approximate yield to maturity")
    }

    static func bondPrice(faceValue: Double, couponRatePercent: Double, marketRatePercent: Double, years: Double) -> FormulaResult? {
        guard faceValue > 0, years > 0, marketRatePercent > -100 else { return nil }
        let n = Int(years.rounded(.down))
        guard n >= 1 else { return nil }

        let coupon = faceValue * (couponRatePercent / 100)
        let rate = marketRatePercent / 100
        var pvCoupons = 0.0
        for t in 1...n {
            pvCoupons += coupon / pow(1 + rate, Double(t))
        }
        let pvFace = faceValue / pow(1 + rate, Double(n))
        let price = pvCoupons + pvFace

        return makeResult(
            value: price,
            unit: "₹",
            interpretation: price >= faceValue ? .caution : .good,
            interpretationText: price >= faceValue ? "Bond trades at premium" : "Bond trades at discount",
            secondaryValues: [("Difference vs Face", format(price - faceValue), "₹")]
        )
    }

    static func couponRate(annualCouponPayment: Double, faceValue: Double) -> FormulaResult? {
        guard faceValue > 0 else { return nil }
        guard let value = safeDiv(annualCouponPayment * 100, faceValue) else { return nil }
        return makeResult(value: value, unit: "%", interpretation: .neutral, interpretationText: "Annual coupon as a percentage of face value")
    }

    static func optionsBreakeven(strikePrice: Double, premiumPaid: Double, isCall: Bool) -> FormulaResult? {
        guard strikePrice >= 0, premiumPaid >= 0 else { return nil }
        let breakeven = isCall ? strikePrice + premiumPaid : strikePrice - premiumPaid
        let maxLoss = premiumPaid
        let maxProfit = isCall ? Double.infinity : max(0, strikePrice - premiumPaid)

        var secondary: [(String, String, String)] = [("Max Loss", format(maxLoss), "₹")]
        if maxProfit.isFinite {
            secondary.append(("Max Profit", format(maxProfit), "₹"))
        } else {
            secondary.append(("Max Profit", "Unlimited", ""))
        }

        return makeResult(value: breakeven, unit: "₹", interpretation: .neutral, interpretationText: "Underlying price needed to break even", secondaryValues: secondary)
    }

    static func optionIntrinsicValue(stockPrice: Double, strikePrice: Double, isCall: Bool, premium: Double?) -> FormulaResult? {
        guard stockPrice >= 0, strikePrice >= 0 else { return nil }
        let intrinsic = isCall ? max(stockPrice - strikePrice, 0) : max(strikePrice - stockPrice, 0)
        var secondary: [(String, String, String)] = []
        if let premium, premium >= 0 {
            secondary.append(("Time Value", format(max(premium - intrinsic, 0)), "₹"))
        }
        return makeResult(value: intrinsic, unit: "₹", interpretation: intrinsic > 0 ? .good : .neutral, interpretationText: "Immediate exercise value of option", secondaryValues: secondary)
    }

    static func putCallParity(callPrice: Double?, putPrice: Double?, strikePrice: Double, riskFreeRatePercent: Double, timeYears: Double, spotPrice: Double) -> FormulaResult? {
        guard strikePrice >= 0, timeYears >= 0, spotPrice >= 0 else { return nil }
        let hasCall = callPrice != nil
        let hasPut = putPrice != nil
        guard hasCall != hasPut else { return nil }
        let r = riskFreeRatePercent / 100
        let pvK = strikePrice * exp(-r * timeYears)

        if let callPrice, callPrice >= 0 {
            let put = callPrice + pvK - spotPrice
            return makeResult(value: put, unit: "₹", interpretation: .neutral, interpretationText: "Theoretical put price from parity", secondaryValues: [("PV(K)", format(pvK), "₹")])
        }

        if let putPrice, putPrice >= 0 {
            let call = putPrice + spotPrice - pvK
            return makeResult(value: call, unit: "₹", interpretation: .neutral, interpretationText: "Theoretical call price from parity", secondaryValues: [("PV(K)", format(pvK), "₹")])
        }

        return nil
    }

    static func blackScholes(stockPrice: Double, strikePrice: Double, riskFreeRatePercent: Double, timeYears: Double, volatilityPercent: Double) -> FormulaResult? {
        guard stockPrice > 0, strikePrice > 0, timeYears > 0, volatilityPercent > 0 else { return nil }
        let r = riskFreeRatePercent / 100
        let sigma = volatilityPercent / 100

        guard let logSK = safeLog(stockPrice / strikePrice), let sqrtT = safeSqrt(timeYears) else { return nil }
        let sigmaSqrtT = sigma * sqrtT
        guard sigmaSqrtT != 0 else { return nil }

        let d1 = (logSK + (r + 0.5 * sigma * sigma) * timeYears) / sigmaSqrtT
        let d2 = d1 - sigmaSqrtT

        let nd1 = normalCDF(d1)
        let nd2 = normalCDF(d2)
        let discount = exp(-r * timeYears)

        let call = stockPrice * nd1 - strikePrice * discount * nd2
        let put = strikePrice * discount * normalCDF(-d2) - stockPrice * normalCDF(-d1)

        return makeResult(
            value: call,
            unit: "₹",
            interpretation: .neutral,
            interpretationText: "Black-Scholes theoretical option pricing",
            secondaryValues: [("Put Price", format(put), "₹")]
        )
    }

    static func taxRegimeComparison(
        grossSalary: Double,
        standardDeductionOld: Double,
        hraExemption: Double,
        section80C: Double,
        section80D: Double,
        nps80CCD1B: Double,
        homeLoan24B: Double,
        otherDeductions: Double
    ) -> FormulaResult? {
        guard let details = taxRegimeComparisonDetails(
            grossSalary: grossSalary,
            standardDeductionOld: standardDeductionOld,
            hraExemption: hraExemption,
            section80C: section80C,
            section80D: section80D,
            nps80CCD1B: nps80CCD1B,
            homeLoan24B: homeLoan24B,
            otherDeductions: otherDeductions
        ) else { return nil }

        return makeResult(
            value: details.savingsAmount,
            unit: "₹",
            interpretation: .good,
            interpretationText: "Comparison between old and new tax regimes",
            isPositive: true,
            secondaryValues: [
                ("Old Taxable", format(details.oldRegime.taxableIncome), "₹"),
                ("New Taxable", format(details.newRegime.taxableIncome), "₹"),
                ("Old Tax", format(details.oldRegime.totalTax), "₹"),
                ("New Tax", format(details.newRegime.totalTax), "₹"),
                ("Old Monthly Tax", format(details.oldRegime.monthlyTax), "₹"),
                ("New Monthly Tax", format(details.newRegime.monthlyTax), "₹"),
                ("Old Take Home", format(details.oldRegime.takeHomeAnnual), "₹"),
                ("New Take Home", format(details.newRegime.takeHomeAnnual), "₹"),
                ("Better", details.betterRegime, ""),
                ("Savings", format(details.savingsAmount), "₹")
            ]
        )
    }

    static func taxRegimeComparisonDetails(
        grossSalary: Double,
        standardDeductionOld: Double,
        hraExemption: Double,
        section80C: Double,
        section80D: Double,
        nps80CCD1B: Double,
        homeLoan24B: Double,
        otherDeductions: Double
    ) -> TaxRegimeComparisonDetails? {
        guard grossSalary > 0 else { return nil }

        let oldStandard = max(0, standardDeductionOld)
        let capped80C = min(max(0, section80C), 150_000)
        let cappedNPS = min(max(0, nps80CCD1B), 50_000)
        let cappedHomeLoan = min(max(0, homeLoan24B), 200_000)
        let hra = max(0, hraExemption)
        let sec80d = max(0, section80D)
        let other = max(0, otherDeductions)

        let oldTotalDeductions = oldStandard + hra + capped80C + sec80d + cappedNPS + cappedHomeLoan + other
        let oldTaxable = max(0, grossSalary - oldTotalDeductions)
        let oldSlabs: [(Double, Double)] = [
            (250_000, 0),
            (250_000, 5),
            (500_000, 20),
            (Double.greatestFiniteMagnitude, 30)
        ]
        let oldRegime = computeRegime(
            grossSalary: grossSalary,
            taxableIncome: oldTaxable,
            slabs: oldSlabs,
            rebateThreshold: 500_000,
            rebateMax: 12_500
        )

        let newStandard = 75_000.0
        let newTaxable = max(0, grossSalary - newStandard)
        let newSlabs: [(Double, Double)] = [
            (300_000, 0),
            (400_000, 5),
            (300_000, 10),
            (200_000, 15),
            (300_000, 20),
            (Double.greatestFiniteMagnitude, 30)
        ]
        let newRegime = computeRegime(
            grossSalary: grossSalary,
            taxableIncome: newTaxable,
            slabs: newSlabs,
            rebateThreshold: 700_000,
            rebateMax: 25_000
        )

        let betterRegime = oldRegime.totalTax <= newRegime.totalTax ? "Old" : "New"
        let savingsAmount = abs(oldRegime.totalTax - newRegime.totalTax)

        return TaxRegimeComparisonDetails(
            grossSalary: grossSalary,
            oldRegime: oldRegime,
            newRegime: newRegime,
            betterRegime: betterRegime,
            savingsAmount: savingsAmount
        )
    }

    private static func computeRegime(
        grossSalary: Double,
        taxableIncome: Double,
        slabs: [(limit: Double, ratePercent: Double)],
        rebateThreshold: Double,
        rebateMax: Double
    ) -> TaxRegimeComputation {
        var remaining = taxableIncome
        var slabItems: [TaxSlabBreakdownItem] = []
        var lowerBound = 0.0
        var baseTax = 0.0

        for (limit, rate) in slabs where remaining > 0 {
            let slabAmount = min(remaining, limit)
            let slabTax = slabAmount * rate / 100
            let upperBound = lowerBound + slabAmount
            let label = "\(format(lowerBound)) - \(format(upperBound)) @ \(format(rate))%"
            slabItems.append(
                TaxSlabBreakdownItem(
                    label: label,
                    taxablePortion: slabAmount,
                    ratePercent: rate,
                    taxAmount: slabTax
                )
            )
            baseTax += slabTax
            remaining -= slabAmount
            lowerBound = upperBound
        }

        let rebate: Double
        if taxableIncome <= rebateThreshold {
            rebate = min(baseTax, rebateMax)
        } else {
            rebate = 0
        }

        let taxAfterRebate = max(0, baseTax - rebate)
        let cess = taxAfterRebate * 0.04
        let totalTax = taxAfterRebate + cess
        let monthlyTax = totalTax / 12
        let takeHomeAnnual = grossSalary - totalTax
        let takeHomeMonthly = takeHomeAnnual / 12

        return TaxRegimeComputation(
            taxableIncome: taxableIncome,
            baseTax: baseTax,
            rebate: rebate,
            cess: cess,
            totalTax: totalTax,
            monthlyTax: monthlyTax,
            takeHomeMonthly: takeHomeMonthly,
            takeHomeAnnual: takeHomeAnnual,
            slabs: slabItems
        )
    }

    static func capitalGainsTax(gainAmount: Double, taxRatePercent: Double) -> FormulaResult? {
        guard gainAmount >= 0, taxRatePercent >= 0 else { return nil }
        let tax = gainAmount * taxRatePercent / 100
        let postTaxGain = gainAmount - tax
        return makeResult(
            value: tax,
            unit: "₹",
            interpretation: taxRatePercent <= 10 ? .good : (taxRatePercent <= 20 ? .neutral : .caution),
            interpretationText: "Estimated tax on realized gains",
            secondaryValues: [
                ("Post-Tax Gain", format(postTaxGain), "₹"),
                ("Effective Tax", format(taxRatePercent), "%")
            ]
        )
    }

    static func takeHomeIncome(grossIncome: Double, effectiveTaxRatePercent: Double) -> FormulaResult? {
        guard grossIncome >= 0, effectiveTaxRatePercent >= 0, effectiveTaxRatePercent < 100 else { return nil }
        let tax = grossIncome * effectiveTaxRatePercent / 100
        let netIncome = grossIncome - tax
        return makeResult(
            value: netIncome,
            unit: "₹",
            interpretation: .neutral,
            interpretationText: "Estimated post-tax take-home income",
            secondaryValues: [
                ("Tax Amount", format(tax), "₹"),
                ("Retention", format(100 - effectiveTaxRatePercent), "%")
            ]
        )
    }

    static func requiredPreTaxIncome(targetNetIncome: Double, effectiveTaxRatePercent: Double) -> FormulaResult? {
        guard targetNetIncome >= 0, effectiveTaxRatePercent >= 0, effectiveTaxRatePercent < 100 else { return nil }
        let netRetention = 1 - (effectiveTaxRatePercent / 100)
        guard let requiredGross = safeDiv(targetNetIncome, netRetention) else { return nil }
        let taxComponent = requiredGross - targetNetIncome
        return makeResult(
            value: requiredGross,
            unit: "₹",
            interpretation: .neutral,
            interpretationText: "Required gross income to hit target take-home",
            secondaryValues: [("Tax Component", format(taxComponent), "₹")]
        )
    }

    static func debtToIncome(monthlyDebt: Double, monthlyIncome: Double) -> FormulaResult? {
        guard monthlyDebt >= 0, monthlyIncome > 0 else { return nil }
        guard let ratio = safeDiv(monthlyDebt * 100, monthlyIncome) else { return nil }
        let level: InterpretationLevel = ratio <= 30 ? .good : (ratio <= 40 ? .caution : .poor)
        return makeResult(
            value: ratio,
            unit: "%",
            interpretation: level,
            interpretationText: "Debt-to-income ratio based on monthly obligations",
            secondaryValues: [("Free Income", format(monthlyIncome - monthlyDebt), "₹")]
        )
    }

    static func savingsRate(monthlySavings: Double, monthlyIncome: Double) -> FormulaResult? {
        guard monthlySavings >= 0, monthlyIncome > 0, monthlySavings <= monthlyIncome else { return nil }
        guard let rate = safeDiv(monthlySavings * 100, monthlyIncome) else { return nil }
        let level: InterpretationLevel = rate >= 30 ? .excellent : (rate >= 20 ? .good : (rate >= 10 ? .neutral : .caution))
        return makeResult(
            value: rate,
            unit: "%",
            interpretation: level,
            interpretationText: "Portion of monthly income saved",
            secondaryValues: [("Monthly Spend", format(monthlyIncome - monthlySavings), "₹")]
        )
    }

    static func netWorth(totalAssets: Double, totalLiabilities: Double) -> FormulaResult? {
        guard totalAssets >= 0, totalLiabilities >= 0 else { return nil }
        let value = totalAssets - totalLiabilities
        let level: InterpretationLevel = value > 0 ? .good : (value == 0 ? .neutral : .caution)
        return makeResult(
            value: value,
            unit: "₹",
            interpretation: level,
            interpretationText: "Net worth from assets minus liabilities",
            isPositive: value >= 0,
            secondaryValues: [("Debt-to-Asset", format(totalAssets == 0 ? 0 : (totalLiabilities / totalAssets) * 100), "%")]
        )
    }

    static func emergencyRunway(cashReserve: Double, monthlyExpense: Double) -> FormulaResult? {
        guard cashReserve >= 0, monthlyExpense > 0 else { return nil }
        guard let months = safeDiv(cashReserve, monthlyExpense) else { return nil }
        let level: InterpretationLevel = months >= 12 ? .excellent : (months >= 6 ? .good : (months >= 3 ? .neutral : .caution))
        return makeResult(
            value: months,
            unit: "months",
            interpretation: level,
            interpretationText: "How long reserves can cover monthly expenses",
            secondaryValues: [("Recommended (6 months)", format(monthlyExpense * 6), "₹")]
        )
    }

    static func requiredCagrForTarget(currentAmount: Double, targetAmount: Double, years: Double) -> FormulaResult? {
        guard currentAmount > 0, targetAmount > 0, years > 0 else { return nil }
        guard let growthFactor = safeDiv(targetAmount, currentAmount),
              let root = safePow(growthFactor, 1 / years) else { return nil }
        let cagr = (root - 1) * 100
        let level: InterpretationLevel = cagr <= 10 ? .good : (cagr <= 15 ? .neutral : .caution)
        return makeResult(
            value: cagr,
            unit: "%",
            interpretation: level,
            interpretationText: "Annual return required to reach your target on time",
            isPositive: cagr >= 0,
            secondaryValues: [
                ("Current Amount", format(currentAmount), "₹"),
                ("Target Amount", format(targetAmount), "₹")
            ]
        )
    }

    static func loanPrepaymentSavings(loanAmount: Double, annualRatePercent: Double, years: Double, extraEMI: Double) -> FormulaResult? {
        guard loanAmount > 0, annualRatePercent >= 0, years > 0, extraEMI >= 0 else { return nil }
        let n = Int((years * 12).rounded())
        guard n > 0 else { return nil }
        let monthlyRate = annualRatePercent / 100 / 12

        let baseEMI: Double
        if monthlyRate == 0 {
            baseEMI = loanAmount / Double(n)
        } else {
            guard let growth = safePow(1 + monthlyRate, Double(n)) else { return nil }
            baseEMI = loanAmount * monthlyRate * growth / (growth - 1)
        }

        guard baseEMI + extraEMI > 0 else { return nil }

        func amortization(emi: Double) -> (interest: Double, months: Int) {
            var balance = loanAmount
            var interestPaid = 0.0
            var months = 0
            let maxMonths = 1200

            while balance > 0.01 && months < maxMonths {
                let interest = balance * monthlyRate
                let principal = max(emi - interest, 0)
                if principal <= 0.000001 { break }
                balance = max(balance + interest - emi, 0)
                interestPaid += interest
                months += 1
            }
            return (interestPaid, months)
        }

        let basePlan = amortization(emi: baseEMI)
        let prepaidPlan = amortization(emi: baseEMI + extraEMI)
        guard basePlan.months > 0, prepaidPlan.months > 0 else { return nil }

        let interestSaved = max(basePlan.interest - prepaidPlan.interest, 0)
        let monthsSaved = max(basePlan.months - prepaidPlan.months, 0)

        return makeResult(
            value: interestSaved,
            unit: "₹",
            interpretation: interestSaved > 0 ? .good : .neutral,
            interpretationText: "Estimated interest saved with monthly prepayment",
            isPositive: interestSaved >= 0,
            secondaryValues: [
                ("Regular EMI", format(baseEMI), "₹/month"),
                ("With Prepay", format(baseEMI + extraEMI), "₹/month"),
                ("Months Saved", format(Double(monthsSaved)), "months")
            ]
        )
    }

    static func monthlyWithdrawalFromCorpus(corpus: Double, annualReturnPercent: Double, years: Double) -> FormulaResult? {
        guard corpus > 0, annualReturnPercent >= 0, years > 0 else { return nil }
        let months = years * 12
        let monthlyRate = annualReturnPercent / 100 / 12

        let withdrawal: Double
        if monthlyRate == 0 {
            withdrawal = corpus / months
        } else {
            guard let discountFactor = safePow(1 + monthlyRate, -months) else { return nil }
            let denominator = 1 - discountFactor
            guard denominator > 0 else { return nil }
            withdrawal = corpus * monthlyRate / denominator
        }

        return makeResult(
            value: withdrawal,
            unit: "₹ / month",
            interpretation: .neutral,
            interpretationText: "Estimated monthly withdrawal sustainable for selected duration",
            secondaryValues: [
                ("Corpus", format(corpus), "₹"),
                ("Duration", format(years), "years")
            ]
        )
    }

    static func normalCDF(_ x: Double) -> Double {
        let a1 = 0.319381530
        let a2 = -0.356563782
        let a3 = 1.781477937
        let a4 = -1.821255978
        let a5 = 1.330274429

        let l = abs(x)
        let k = 1.0 / (1.0 + 0.2316419 * l)
        let poly = ((((a5 * k + a4) * k + a3) * k + a2) * k + a1) * k
        let rsqrt2pi = 0.3989422804014327
        let cnd = 1.0 - rsqrt2pi * exp(-0.5 * l * l) * poly
        return x < 0 ? 1.0 - cnd : cnd
    }
}

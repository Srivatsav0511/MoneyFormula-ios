import Foundation

enum InputDisplayText {
    static func label(for key: String, category: FormulaCategory? = nil) -> String {
        if category == .valuation {
            switch key {
            case "marketPrice", "price": return "Asset Price"
            case "bookValue": return "Net Asset Value"
            case "dividend": return "Annual Cash Flow"
            case "eps": return "Earnings Value"
            case "equity": return "Net Equity Value"
            default: break
            }
        }

        switch key {
        case "buyPrice": return "Buy Price"
        case "sellPrice": return "Sell Price"
        case "quantity": return "Quantity"
        case "brokerage": return "Brokerage"
        case "stt": return "STT"
        case "exchangeCharges": return "Exchange Transaction Charges"
        case "gstOnBrokerageAmount": return "GST (18% on brokerage)"
        case "stampDuty": return "Stamp Duty"
        case "sebiChargesAmount": return "SEBI Charges"
        case "oldShares": return "Old Shares"
        case "oldAvg": return "Old Average Price"
        case "newShares": return "New Shares to Buy"
        case "newPrice": return "Current Price"
        case "targetAvg": return "Target Average Price"
        case "monthly": return "Monthly SIP Amount"
        case "annualReturn": return "Expected Return"
        case "years": return "Duration"
        case "initial": return "Initial Investment"
        case "final": return "Final Value"
        case "beginning": return "Beginning Value"
        case "ending": return "Ending Value"
        case "marketPrice": return "Market Price"
        case "eps": return "EPS"
        case "dividend": return "Dividend"
        case "price": return "Price"
        case "revenue": return "Revenue"
        case "equity": return "Shareholders Equity"
        case "liabilities": return "Total Liabilities"
        case "riskFree": return "Risk-Free Rate"
        case "stdDev": return "Std Deviation"
        case "volatility": return "Volatility"
        case "strike": return "Strike Price"
        case "stock": return "Stock Price"
        case "time": return "Time"
        case "loanAmount": return "Loan Amount"
        case "annualRate": return "Annual Interest Rate"
        case "principal": return "Principal Amount"
        case "rate": return "Interest Rate"
        case "amount": return "Base Amount"
        case "gstRate": return "GST Rate"
        case "markedPrice": return "Marked Price"
        case "sellingPrice": return "Selling Price"
        case "target": return "Target Amount"
        case "monthlyIncome": return "Monthly Income"
        case "foir": return "FOIR Limit"
        case "existingObligations": return "Existing EMI"
        case "monthlyRent": return "Monthly Rent"
        case "propertyPrice": return "Property Price"
        case "fixedCost": return "Fixed Cost"
        case "sellingPricePerUnit": return "Selling Price / Unit"
        case "variableCostPerUnit": return "Variable Cost / Unit"
        case "monthlyExpense": return "Monthly Expense"
        case "months": return "Coverage Months"
        case "annualExpense": return "Annual Expense"
        case "withdrawalRate": return "Withdrawal Rate"
        case "currentCost": return "Current Cost"
        case "gainAmount": return "Taxable Gain"
        case "taxRate": return "Tax Rate"
        case "grossIncome": return "Gross Income"
        case "effectiveTaxRate": return "Effective Tax Rate"
        case "targetNetIncome": return "Target Net Income"
        case "monthlyDebt": return "Monthly Debt Payments"
        case "monthlySavings": return "Monthly Savings"
        case "totalAssets": return "Total Assets"
        case "totalLiabilities": return "Total Liabilities"
        case "cashReserve": return "Cash Reserve"
        case "currentAmount": return "Current Amount"
        case "targetAmount": return "Target Amount"
        case "extraEMI": return "Extra Monthly EMI"
        case "corpus": return "Retirement Corpus"
        case "grossSalary": return "Annual Gross Salary"
        case "standardDeduction": return "Standard Deduction"
        case "hraExemption": return "HRA Exemption"
        case "section80C": return "Section 80C Investments"
        case "section80D": return "Section 80D Premium"
        case "nps80ccd1b": return "NPS 80CCD(1B)"
        case "homeLoan24b": return "Home Loan Interest 24(b)"
        case "otherDeductions": return "Other Deductions"
        default:
            return key
                .replacingOccurrences(of: "_", with: " ")
                .replacingOccurrences(of: "([a-z])([A-Z])", with: "$1 $2", options: .regularExpression)
                .capitalized
        }
    }

    static func unit(for key: String, category: FormulaCategory? = nil) -> String {
        if category == .valuation {
            switch key {
            case "sharesOutstanding": return "units"
            default: break
            }
        }

        switch key {
        case "quantity", "oldShares", "newShares", "sharesOutstanding": return "shares"
        case "years", "time": return "years"
        case "months": return "months"
        case "days": return "days"
        case "period": return "periods"
        case "isCall", "stockName": return ""
        case "brokerage", "stt", "exchangeCharges", "stampDuty", "annualReturn", "annualRate", "riskFree", "stdDev", "volatility", "confidence", "growth", "nominal", "inflation", "return", "returns", "weight", "totalReturn", "dailyVolatility", "couponRate", "marketRate", "rate", "gstRate", "foir", "withdrawalRate", "taxRate", "effectiveTaxRate", "portfolioReturn", "marketReturn", "stockReturn", "actualReturn", "avgGain", "avgLoss": return "%"
        case "beta", "pe": return "x"
        default: return "₹"
        }
    }

    static func help(for key: String, category: FormulaCategory? = nil) -> String {
        switch key {
        case "weight":
            return "Weight is how much of your portfolio is in that asset, usually in percent."
        case "return", "returns", "portfolioReturn", "stockReturn", "marketReturn", "actualReturn", "annualReturn", "totalReturn":
            return "Return is the percentage gain or loss for the selected period."
        case "beta":
            return "Beta measures how strongly an asset moves compared to the market (1 is market-like)."
        case "riskFree":
            return "Risk-free rate is the return from a low-risk benchmark like government bonds."
        case "stdDev", "dailyVolatility", "volatility":
            return "Volatility shows how much returns fluctuate; higher means more uncertainty."
        case "quantity", "oldShares", "newShares", "sharesOutstanding":
            return "Enter the number of shares or units."
        case "years", "time":
            return "Enter total duration in years."
        case "months":
            return "Enter total duration in months."
        case "days":
            return "Enter the number of days."
        case "price", "marketPrice", "buyPrice", "sellPrice", "strike", "stock":
            return "Enter per-unit price for this input."
        case "loanAmount", "principal", "investment", "initial", "final", "beginning", "ending", "amount", "portfolioValue":
            return "Enter the amount value for this field."
        case "taxRate", "effectiveTaxRate", "gstRate", "couponRate", "marketRate", "rate":
            return "Enter this rate as a percentage."
        default:
            let label = label(for: key, category: category)
            let normalized = label.prefix(1).lowercased() + label.dropFirst()
            let resolvedUnit = unit(for: key, category: category)
            switch resolvedUnit {
            case "%":
                return "Enter \(normalized) as a percentage."
            case "₹":
                return "Enter \(normalized) as an amount."
            case "shares":
                return "Enter \(normalized) in shares."
            case "years", "months", "days":
                return "Enter \(normalized) in \(resolvedUnit)."
            default:
                return "Enter \(normalized) for this formula."
            }
        }
    }
}
